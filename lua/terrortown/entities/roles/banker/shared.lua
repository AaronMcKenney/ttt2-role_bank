if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_banker.vmt")
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
		credits = 1, -- the starting credits of a specific role
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
	
	local function PayBankers(banker_list)
		for _, banker in ipairs(banker_list) do
			banker:AddCredits(banker.tmp_payment)
			LANG.Msg(banker, "receive_credits_" .. BANKER.name, {c = banker.tmp_payment})
			banker.tmp_payment = nil
		end
	end
	
	local function ResetBankerData()
		for _, ply in ipairs(player.GetAll()) do
			ply.banker_recv_bonus = false
		end
	end
	hook.Add("TTTPrepareRound", "ResetBankerOnPrepareRound", ResetBankerData)
	hook.Add("TTTBeginRound", "ResetBankerOnBeginRound", ResetBankerData)
	
	hook.Add("TTT2OrderedEquipment", "BankerReceiveCreditsFromShopOrders", function(ply, cls, is_item, credits, ignoreCost)
		if credits <= 0 or ignoreCost or ply:GetSubRole() == ROLE_BANKER then
			return
		end
		
		banker_list = GetAllBankers()
		if #banker_list <= 0 then
			return
		end
		
		local credits_left = credits
		for _, banker in ipairs(banker_list) do
		
		end
		
		--Transfer all credits that the ply paid to the banker(s) semi-evenly.
		--It's a bit like communism, but only for the rich.
		--First, distribute all of the credits that can be equally distributed.
		local base_payment = math.floor(credits / #banker_list)
		for _, banker in ipairs(banker_list) do
			banker.tmp_payment = base_payment
		end
		
		--Now distribute the remaining credits as "bonuses"
		local bonuses_left = credits - #banker_list * base_payment 
		if bonuses_left > 0 then
			--We will be divvying up the bonuses by giving a portion of the bankers an extra credit.
			--banker_recv_bonus will be used to ensure that a singular banker doesn't receive the majority of the bonuses.
			for _, banker in ipairs(banker_list) do
				if bonuses_left > 0 and not banker.banker_recv_bonus then
					banker.tmp_payment = banker.tmp_payment + 1
					banker.banker_recv_bonus = true
					bonuses_left = bonuses_left - 1
				end
			end
			
			if bonuses_left > 0 then
				--At this point, all of the bankers have received a bonus at some point.
				--i.e. banker_recv_bonus is true for all.
				--It is time to reset banker_missed_out while also dishing out the rest of the credits.
				for _, banker in ipairs(banker_list) do
					if bonuses_left > 0 then
						banker.tmp_payment = banker.tmp_payment + 1
						banker.banker_recv_bonus = true --For sanity
						bonuses_left = bonuses_left - 1
					else
						banker.banker_recv_bonus = false
					end
				end
			end
		end
		
		--Finally, send those paychecks!
		PayBankers(banker_list)
	end)
	
	hook.Add("TTT2CanTransferCredits", "BankerCanTransferCredits", function(ply, target, credits)
		if not GetConVar("ttt2_banker_give_handouts"):GetBool() and ply:GetSubRole() == ROLE_BANKER then
			LANG.Msg(banker, "no_handouts_" .. BANKER.name)
			return false
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
		if not GetConVar("ttt2_banker_ron_swanswon_will"):GetBool() or not IsValid(victim) or not victim:IsPlayer() or victim:GetSubRole() ~= ROLE_BANKER or not IsValid(attacker) or not attacker:IsPlayer() or not attacker:IsShopper() then
			--Just get rid of banker_will if it exists (as the credits will transfer to the corpse)
			victim.banker_will = nil
			return
		end
		
		if victim.banker_will and victim.banker_will > 0 then
			--Give all of the victim's credits (as noted in their will) to the attacker
			attacker:AddCredits(victim.banker_will)
			
			--Send the good news to the attacker.
			LANG.Msg(attacker, "will_" .. BANKER.name, {c = victim.banker_will})
		end
		
		--Destroy the evidence.
		victim.banker_will = nil
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
