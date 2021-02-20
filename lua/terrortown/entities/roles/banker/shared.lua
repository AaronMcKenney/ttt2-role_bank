if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_banker.vmt")
	util.AddNetworkString("TTT2BankerBroadcastMurderer")
	util.AddNetworkString("TTT2BankerUpdateHandoutsGiven")
end

function ROLE:PreInitialize()
	self.color = Color(133, 187, 101, 255) -- color of a USA Dollar Bill
	self.abbr = "bank" -- abbreviation
	
	self.scoreKillsMultiplier = 1
	self.scoreTeamKillsMultiplier = -8
	
	self.fallbackTable = {}
	self.unknownTeam = true -- disables team voice chat.

	self.defaultTeam = TEAM_INNOCENT -- the team name: roles with same team name are working together
	self.defaultEquipment = SPECIAL_EQUIPMENT -- here you can set up your own default equipment

	-- ULX ConVars
	self.conVarData = {
		pct = 0.13, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		minPlayers = 5, -- minimum amount of players until this role is able to get selected
		credits = 2, -- the starting credits of a specific role
		creditsTraitorKill = 0,
		creditsTraitorDead = 1,
		shopFallback = SHOP_FALLBACK_DETECTIVE,
		togglable = true, -- option to toggle a role for a client if possible (F1 menu)
		random = 30
	}
end

function ROLE:Initialize()
	roles.SetBaseRole(self, ROLE_DETECTIVE)
end

if SERVER then
	local function GetAllBankers()
		banker_list = {}
		for _, ply in ipairs(player.GetAll()) do
			if ply:IsTerror() and ply:Alive() and ply:GetSubRole() == ROLE_BANKER then
				banker_list[#banker_list + 1] = ply
			end
		end
		
		return banker_list
	end
	
	local function PayBankers(banker_list, credits)
		local credit_ceiling = GetConVar("ttt2_banker_credit_ceiling"):GetInt()
		
		--Transfer all credits that the ply paid to the banker(s) semi-evenly.
		--It's a bit like communism, but only for the rich.
		--First, distribute all of the credits that can be equally distributed.
		local base_payment = math.floor(credits / #banker_list)
		local bonuses_left = credits - #banker_list * base_payment 
		for _, banker in ipairs(banker_list) do
			if credit_ceiling < 0 then
				banker.banker_tmp_payment = base_payment
			else
				--math.max is here in case credit_ceiling drops in the middle of a round.
				banker.banker_tmp_payment = math.max(math.min(base_payment, credit_ceiling - banker.banker_credits_recv), 0)
				
				--If this banker hit the ceiling, anything they didn't receive will be redistributed to others.
				bonuses_left = bonuses_left + (base_payment - banker.banker_tmp_payment)
			end
		end
		
		--Now distribute the remaining credits as "bonuses"
		if bonuses_left > 0 then
			--We will be divvying up the bonuses by giving a portion of the bankers an extra credit.
			--banker_recv_bonus will be used to ensure that a singular banker doesn't receive the majority of the bonuses.
			for _, banker in ipairs(banker_list) do
				if bonuses_left > 0 and not banker.banker_recv_bonus then
					if credit_ceiling >= 0 and banker.banker_credits_recv + banker.banker_tmp_payment >= credit_ceiling then
						--Give the bonus to someone else as this banker has hit their quota
						continue
					end
					
					banker.banker_tmp_payment = banker.banker_tmp_payment + 1
					banker.banker_recv_bonus = true
					bonuses_left = bonuses_left - 1
				end
			end
			
			if bonuses_left > 0 then
				--At this point, all of the bankers have received a bonus at some point.
				--e.x. banker_recv_bonus is true for all, or some banker hit their credit ceiling but others didn't.
				--It is time to reset banker_missed_out while also dishing out the rest of the credits.
				for _, banker in ipairs(banker_list) do
					if bonuses_left > 0 then
						if credit_ceiling >= 0 and banker.banker_credits_recv + banker.banker_tmp_payment >= credit_ceiling then
							--Give the bonus to someone else as this banker has hit their quota
							banker.banker_recv_bonus = false
							continue
						end
						
						banker.banker_tmp_payment = banker.banker_tmp_payment + 1
						banker.banker_recv_bonus = true
						bonuses_left = bonuses_left - 1
					else
						banker.banker_recv_bonus = false
					end
				end
			end
		end
		
		--Finally, send those paychecks!
		--Do this even if the banker is being given 0 credits, to inform them that someone bought something.
		for _, banker in ipairs(banker_list) do
			--print("BANK_DEBUG PayBankers: name=" .. banker:GetName() .. ", prev_recv=" .. banker.banker_credits_recv .. ", tmp=" .. banker.banker_tmp_payment .. ", recv_bonus=" .. tostring(banker.banker_recv_bonus))
			
			banker:AddCredits(banker.banker_tmp_payment)
			banker.banker_credits_recv = banker.banker_credits_recv + banker.banker_tmp_payment
			LANG.Msg(banker, "receive_credits_" .. BANKER.name, {c = banker.banker_tmp_payment})
			banker.banker_tmp_payment = nil
		end
	end
	
	local function SendHandoutsGivenToClient(ply)
		--Send the updated number of buffs to the client
		net.Start("TTT2BankerUpdateHandoutsGiven")
		net.WriteInt(ply.banker_handouts_given, 16)
		net.Send(ply)
	end
	
	hook.Add("TTTPrepareRound", "BankerPrepareRoundForServer", function()
		for _, ply in ipairs(player.GetAll()) do
			ply.banker_recv_bonus = nil
			ply.banker_handouts_given = nil
			ply.banker_will = nil
			ply.banker_tmp_payment = nil
			ply.banker_credits_recv = nil
		end
	end)
	
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		--Maintain banker_recv_bonus across role changes to maintain long term equity.
		if not ply.banker_recv_bonus then
			ply.banker_recv_bonus = false
		end
		
		--Always reset the number of handouts given.
		--Reward players for breaking the system via exuberant role switching (for fun!)
		ply.banker_handouts_given = 0
		SendHandoutsGivenToClient(ply)
		
		--Same idea for keeping track of how many credits they were given
		ply.banker_credits_recv = 0
	end
	
	hook.Add("TTT2OrderedEquipment", "BankerReceiveCreditsFromShopOrders", function(ply, cls, is_item, credits, ignoreCost)
		if credits <= 0 or ignoreCost or ply:GetSubRole() == ROLE_BANKER then
			return
		end
		
		banker_list = GetAllBankers()
		if #banker_list > 0 then
			PayBankers(banker_list, credits)
		end
	end)
	
	hook.Add("EntityTakeDamage", "BankerModifyDamage", function(target, dmg_info)
		local attacker = dmg_info:GetAttacker()
		
		if not IsValid(target) or not target:IsPlayer() or target:GetSubRole() ~= ROLE_BANKER then
			return
		end
		
		dmg_info:SetDamage(dmg_info:GetDamage() * GetConVar("ttt2_banker_recv_dmg_multi"):GetFloat())
	end)
	
	hook.Add("DoPlayerDeath", "BankerDoPlayerDeath", function(ply, attacker, dmginfo)
		--DoPlayerDeath is called, followed by PostPlayerDeath, and then finally by PostPlayerDeath.
		--Player isn't technically dead at this point.
		if not GetConVar("ttt2_banker_ron_swanswon_will"):GetBool() or not IsValid(ply) or not ply:IsPlayer() or ply:GetSubRole() ~= ROLE_BANKER or not IsValid(attacker) or not attacker:IsPlayer() or not attacker:IsShopper() then
			return
		end
		
		--The player's credits are transferred to their corpse after this hook normally, where we'll be unable to touch it until someone searches the corpse.
		--So, for this feature we quickly move the credits to a temporary field to access later.
		ply.banker_will = ply:GetCredits()
		ply:SetCredits(0)
	end)
	
	hook.Add("TTT2PostPlayerDeath", "BankerPostPlayerDeath", function(victim, inflictor, attacker)
		if not IsValid(victim) or not victim:IsPlayer() or victim:GetSubRole() ~= ROLE_BANKER or not IsValid(attacker) or not attacker:IsPlayer() or attacker:SteamID64() == victim:SteamID64() then
			--Just get rid of banker_will if it exists (as the credits will transfer to the corpse)
			victim.banker_will = nil
			return
		end
		
		if GetConVar("ttt2_banker_ron_swanswon_will"):GetBool() and victim.banker_will and victim.banker_will > 0 then
			--Give all of the victim's credits (as noted in their will) to the attacker
			attacker:AddCredits(victim.banker_will)
			
			--Send the good news to the attacker.
			LANG.Msg(attacker, "will_" .. BANKER.name, {c = victim.banker_will})
		end
		
		if GetConVar("ttt2_banker_broadcast_murderer"):GetBool() then
			net.Start("TTT2BankerBroadcastMurderer")
			net.WriteString(attacker:GetName())
			net.Broadcast()
		end
		
		--Destroy the evidence.
		victim.banker_will = nil
	end)
	
	hook.Add("TTT2CanTransferCredits", "BankerCanTransferCreditsForServer", function(ply, target, credits)
		--This hook is called in the server right before the transaction takes place.
		if ply:GetSubRole() ~= ROLE_BANKER then
			return
		end
		
		local max_handouts = GetConVar("ttt2_banker_max_num_handouts"):GetInt()
		--Extra check here in case there is a sync issue between Server and Client
		local handouts_given = 0
		if ply.banker_handouts_given then
			handouts_given = ply.banker_handouts_given
		end
		
		if max_handouts >= 0 and handouts_given >= max_handouts then
			return false, nil
		end
		
		--Keep track of # handouts even if max_handouts == -1 in case max_handouts changes in the middle of the round.
		ply.banker_handouts_given = handouts_given + 1
		SendHandoutsGivenToClient(ply)
		
		return true, nil
	end)
end

if CLIENT then
	net.Receive("TTT2BankerBroadcastMurderer", function()
		local client = LocalPlayer()
		local murderer_name = net.ReadString()
		
		EPOP:AddMessage({text = LANG.GetParamTranslation("broadcast_murderer" .. BANKER.name, {name = murderer_name}), color = COLOR_RED}, "", 6)
	end)
	
	net.Receive("TTT2BankerUpdateHandoutsGiven", function()
		local client = LocalPlayer()
		local handouts_given = net.ReadInt(16)
		
		client.banker_handouts_given = handouts_given
	end)
	
	hook.Add("TTTPrepareRound", "BankerPrepareRoundForClient", function()
		local client = LocalPlayer()
		client.banker_handouts_given = nil
	end)
	
	hook.Add("TTT2CanTransferCredits", "BankerCanTransferCreditsForClient", function(ply, target, credits)
		--This hook is called in the client to determine if they should be given the option of making a transfer.
		if ply:GetSubRole() ~= ROLE_BANKER then
			return
		end
		
		local max_handouts = GetConVar("ttt2_banker_max_num_handouts"):GetInt()
		local msg = nil
		--Extra check here in case there is a sync issue between Server and Client
		local handouts_given = 0
		if ply.banker_handouts_given then
			handouts_given = ply.banker_handouts_given
		end
		
		if max_handouts >= 0 then
			if handouts_given >= max_handouts then
				return false, LANG.GetTranslation("no_handouts_" .. BANKER.name)
			end
			
			local remaining_handouts = max_handouts - handouts_given
			msg = LANG.GetParamTranslation("remaining_handouts_" .. BANKER.name, {n = remaining_handouts})
		else
			msg = LANG.GetParamTranslation("handouts_given_" .. BANKER.name, {n = handouts_given})
		end
		
		return true, msg
	end)
end

------------
-- SHARED --
------------

hook.Add("TTTPlayerSpeedModifier", "BankerModifySpeed", function(ply, _, _, no_lag)
	if not IsValid(ply) or ply:GetSubRole() ~= ROLE_BANKER then
		return
	end
	
	no_lag[1] = no_lag[1] * GetConVar("ttt2_banker_speed_multi"):GetFloat()
end)

hook.Add("TTT2StaminaDrain", "BankerModifyStaminaDrain", function(ply, stamina_drain_mod)
	if not IsValid(ply) or ply:GetSubRole() ~= ROLE_BANKER then
		return
	end
	
	stamina_drain_mod[1] = stamina_drain_mod[1] * GetConVar("ttt2_banker_stamina_drain"):GetFloat()
end)

hook.Add("TTT2StaminaRegen", "BankerModifyStaminaRegen", function(ply, stamina_regen_mod)
	if not IsValid(ply) or ply:GetSubRole() ~= ROLE_BANKER then
		return
	end
	
	stamina_regen_mod[1] = stamina_regen_mod[1] * GetConVar("ttt2_banker_stamina_regen"):GetFloat()
end)
