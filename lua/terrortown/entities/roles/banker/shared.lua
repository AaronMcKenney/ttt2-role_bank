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
		for _, ply in pairs(player.GetAll()) do
			if ply:IsTerror() and ply:Alive() and ply:GetSubRole() == ROLE_BANKER then
				banker_list[#banker_list + 1] = ply
			end
		end
		
		return banker_list
	end
	
	local function ResetBankerData()
		for _, ply in pairs(player.GetAll()) do
			ply.credit_bank = 0
		end
	end
	
	hook.Add("TTTPrepareRound", "ResetBankerOnPrepareRound", ResetBankerData)
	hook.Add("TTTBeginRound", "ResetBankerOnBeginRound", ResetBankerData)
	
	hook.Add("TTT2OrderedEquipment", "BankerReceiveCreditsFromShopOrders", function(ply, cls, is_item, credits, ignoreCost)
		if credits == 0 or ignoreCost then
			return
		end
		
		banker_list = GetAllBankers()
		if #banker_list <= 0 then
			return
		end
		
		--Transfer all credits that ply paid to the banker(s).
		--In case of multiple bankers split the payment evenly (and keep track of fractional credits to accrue later)
		payment = credits / #banker_list
		for banker in banker_list do
			--Accrue all credits that the banker could receive (even fractional credits)
			banker.credit_bank = banker.credit_bank + payment
			local real_credits = math.floor(banker.credit_bank)
			
			--Send whole credits, and accrue the remaining fractional credits for later use.
			banker:AddCredits(real_credits)
			banker.credit_bank = banker.credit_bank - real_credits
			LANG.Msg(banker, "receive_credits_" .. BANKER.name, {c = payment})
		end
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
	
	hook.Add("TTT2PostPlayerDeath", "BankerPostPlayerDeath", function(victim, inflictor, attacker)
		if not GetConVar("ttt2_banker_ron_swanswon_will"):GetBool() or not IsValid(victim) or not victim:IsPlayer() or victim:GetSubRole() ~= ROLE_BANKER or not IsValid(attacker) or not attacker:IsPlayer() then
			return
		end
		
		--Give both the real credits and the fractional credits to the attacker (in case the attacker is another banker, or the attacker has killed multiple bankers who all have fractional credits)
		attacker.credit_bank = attacker.credit_bank + victim:GetCredits() + victim.credit_bank
		
		--Give all of the real credits to the attacker
		local real_credits = math.floor(attacker.credit_bank)
		attacker:AddCredits(real_credits)
		attacker.credit_bank = attacker.credit_bank - real_credits
		
		--Reset the victim's credits now that they've all been donated.
		victim.credit_bank = 0
		victim:SetCredits(0)
		
		--Send the good news to the attacker.
		LANG.Msg(attacker, "will_" .. BANKER.name, {banker_name = victim:GetName(), c = payment})
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
