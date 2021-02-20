--ConVar syncing
CreateConVar("ttt2_banker_credit_ceiling", "-1", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_banker_ron_swanswon_will", "0", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_banker_broadcast_death_mode", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_banker_broadcast_covert_search", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_banker_max_num_handouts", "2", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_banker_recv_dmg_multi", "1.25", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_banker_speed_multi", "1.0", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_banker_stamina_regen", "0.35", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_banker_stamina_drain", "1.25", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicBankerCVars", function(tbl)
	tbl[ROLE_BANKER] = tbl[ROLE_BANKER] or {}
	
	--# Banker's starting credits
	--  ttt_bank_credits_starting [0..n] (default: 2)
	
	--# How many credits can the Banker receive from purchases other shoppers make (infinite if -1)?
	--  ttt2_banker_credit_ceiling [-1..n] (default: -1)
	table.insert(tbl[ROLE_BANKER], {
		cvar = "ttt2_banker_credit_ceiling",
		slider = true,
		min = -1,
		max = 10,
		decimal = 0,
		desc = "ttt2_banker_credit_ceiling (Def: -1)"
	})
	
	--# Should the banker's murderer receive all of their credits (provided that they are a shopping role)?
	--  ttt2_banker_ron_swanswon_will [0/1] (default: 0)
	table.insert(tbl[ROLE_BANKER], {
		cvar = "ttt2_banker_ron_swanswon_will",
		checkbox = true,
		desc = "ttt2_banker_ron_swanswon_will (Def: 0)"
	})
	
	--# If the Banker dies, how should everyone be informed?
	--  ttt2_banker_broadcast_death_mode [0..2] (default: 1)
	--  # 0: No broadcasting will occur
	--  # 1: Everyone will be informed that the Banker committed suicide, regardless of what actually happened
	--  # 2: If possible, the Banker's murderer will be made known to all, otherwise broadcast that they died under mysterious circumstances
	table.insert(tbl[ROLE_BANKER], {
		cvar = "ttt2_banker_broadcast_death_mode",
		combobox = true,
		desc = "ttt2_banker_broadcast_death_mode (Def: 1)",
		choices = {
			"0 - No broadcasting will occur",
			"1 - Tell everyone Banker committed suicide even if this is incorrect",
			"2 - If possible, the Banker's murderer will be made known to all"
		},
		numStart = 0
	})
	
	--# Should the server broadcast anyone who covertly searches the Banker's dead body?
	--  ttt2_banker_broadcast_covert_search [0/1] (default: 0)
	table.insert(tbl[ROLE_BANKER], {
		cvar = "ttt2_banker_broadcast_covert_search",
		checkbox = true,
		desc = "ttt2_banker_broadcast_covert_search (Def: 0)"
	})
	
	--# How many credits can the Banker give out to others per round (infinite if -1)?
	--  ttt2_banker_max_num_handouts [-1..n] (default: 2)
	table.insert(tbl[ROLE_BANKER], {
		cvar = "ttt2_banker_max_num_handouts",
		slider = true,
		min = -1,
		max = 10,
		decimal = 0,
		desc = "ttt2_banker_max_num_handouts (Def: 2)"
	})
	
	--# This multiplier applies directly to the damage that the banker would receive (ex. 2.0 means the banker takes twice as much damage from all sources).
	--  ttt2_banker_recv_dmg_multi [0.0..n.m] (default: 1.25)
	table.insert(tbl[ROLE_BANKER], {
		cvar = "ttt2_banker_recv_dmg_multi",
		slider = true,
		min = 1.0,
		max = 3.0,
		decimal = 2,
		desc = "ttt2_banker_recv_dmg_multi (Def: 1.25)"
	})
	
	--# This multiplier applies directly to the banker's speed (ex. 0.5 means the banker moves half as fast).
	--  ttt2_banker_speed_multi [0.0..n.m] (default: 1.0)
	table.insert(tbl[ROLE_BANKER], {
		cvar = "ttt2_banker_speed_multi",
		slider = true,
		min = 0.1,
		max = 1.0,
		decimal = 2,
		desc = "ttt2_banker_speed_multi (Def: 1.0)"
	})
	
	--# This multiplier applies directly to the banker's stamina regen (ex. 0.5 means the sprint bar fills up half the normal speed).
	--  ttt2_banker_stamina_regen [0.0..n.m] (default: 0.35)
	table.insert(tbl[ROLE_BANKER], {
		cvar = "ttt2_banker_stamina_regen",
		slider = true,
		min = 0.1,
		max = 1.0,
		decimal = 2,
		desc = "ttt2_banker_stamina_regen (Def: 0.35)"
	})
	
	--# This multiplier applies directly to how fast the banker's stamina bar depletes (ex. 2.0 means the sprint bar decays twice as fast).
	--  ttt2_banker_stamina_drain [0.0..n.m] (default: 1.25)
	table.insert(tbl[ROLE_BANKER], {
		cvar = "ttt2_banker_stamina_drain",
		slider = true,
		min = 1.0,
		max = 3.0,
		decimal = 2,
		desc = "ttt2_banker_stamina_drain (Def: 1.25)"
	})
end)

hook.Add("TTT2SyncGlobals", "AddBankerGlobals", function()
	SetGlobalInt("ttt2_banker_credit_ceiling", GetConVar("ttt2_banker_credit_ceiling"):GetInt())
	SetGlobalBool("ttt2_banker_ron_swanswon_will", GetConVar("ttt2_banker_ron_swanswon_will"):GetBool())
	SetGlobalInt("ttt2_banker_broadcast_death_mode", GetConVar("ttt2_banker_broadcast_death_mode"):GetInt())
	SetGlobalBool("ttt2_banker_broadcast_covert_search", GetConVar("ttt2_banker_broadcast_covert_search"):GetBool())
	SetGlobalInt("ttt2_banker_max_num_handouts", GetConVar("ttt2_banker_max_num_handouts"):GetInt())
	SetGlobalFloat("ttt2_banker_recv_dmg_multi", GetConVar("ttt2_banker_recv_dmg_multi"):GetFloat())
	SetGlobalFloat("ttt2_banker_speed_multi", GetConVar("ttt2_banker_speed_multi"):GetFloat())
	SetGlobalFloat("ttt2_banker_stamina_regen", GetConVar("ttt2_banker_stamina_regen"):GetFloat())
	SetGlobalFloat("ttt2_banker_stamina_drain", GetConVar("ttt2_banker_stamina_drain"):GetFloat())
end)

cvars.AddChangeCallback("ttt2_banker_credit_ceiling", function(name, old, new)
	SetGlobalInt("ttt2_banker_credit_ceiling", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_banker_ron_swanswon_will", function(name, old, new)
	SetGlobalBool("ttt2_banker_ron_swanswon_will", tobool(tonumber(new)))
end)
cvars.AddChangeCallback("ttt2_banker_broadcast_death_mode", function(name, old, new)
	SetGlobalInt("ttt2_banker_broadcast_death_mode", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_banker_broadcast_covert_search", function(name, old, new)
	SetGlobalBool("ttt2_banker_broadcast_covert_search", tobool(tonumber(new)))
end)
cvars.AddChangeCallback("ttt2_banker_max_num_handouts", function(name, old, new)
	SetGlobalInt("ttt2_banker_max_num_handouts", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_banker_recv_dmg_multi", function(name, old, new)
	SetGlobalFloat("ttt2_banker_recv_dmg_multi", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_banker_speed_multi", function(name, old, new)
	SetGlobalFloat("ttt2_banker_speed_multi", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_banker_stamina_regen", function(name, old, new)
	SetGlobalFloat("ttt2_banker_stamina_regen", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_banker_stamina_drain", function(name, old, new)
	SetGlobalFloat("ttt2_banker_stamina_drain", tonumber(new))
end)
