--ConVar syncing
CreateConVar("ttt2_banker_ron_swanswon_will", "1", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_banker_give_handouts", "1", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_banker_recv_dmg_multi", "1.25", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_banker_speed_multi", "0.8", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_banker_stamina_regen", "0.35", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_banker_stamina_drain", "1.25", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicBankerCVars", function(tbl)
	tbl[ROLE_BANKER] = tbl[ROLE_BANKER] or {}
	
	--# Should the banker's killer receive all of their credits (provided that they are a shopping role)?
	--  ttt2_banker_ron_swanswon_will [0/1] (default: 1)
	table.insert(tbl[ROLE_BANKER], {
		cvar = "ttt2_banker_ron_swanswon_will",
		checkbox = true,
		desc = "ttt2_banker_ron_swanswon_will (Def: 1)"
	})
	
	--# Should the banker be able to transfer credits to others?
	--  ttt2_banker_give_handouts [0/1] (default: 1)
	table.insert(tbl[ROLE_BANKER], {
		cvar = "ttt2_banker_give_handouts",
		checkbox = true,
		desc = "ttt2_banker_give_handouts (Def: 1)"
	})
	
	--# This multiplier applies directly to the damage that the banker would receive (ex. 2x means the banker takes twice as much damage from all sources).
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
	--  ttt2_banker_speed_multi [0.0..n.m] (default: 0.8)
	table.insert(tbl[ROLE_BANKER], {
		cvar = "ttt2_banker_speed_multi",
		slider = true,
		min = 0.1,
		max = 1.0,
		decimal = 2,
		desc = "ttt2_banker_speed_multi (Def: 0.8)"
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
	SetGlobalBool("ttt2_banker_ron_swanswon_will", GetConVar("ttt2_banker_ron_swanswon_will"):GetBool())
	SetGlobalBool("ttt2_banker_give_handouts", GetConVar("ttt2_banker_give_handouts"):GetBool())
	SetGlobalFloat("ttt2_banker_recv_dmg_multi", GetConVar("ttt2_banker_recv_dmg_multi"):GetFloat())
	SetGlobalFloat("ttt2_banker_speed_multi", GetConVar("ttt2_banker_speed_multi"):GetFloat())
	SetGlobalFloat("ttt2_banker_stamina_regen", GetConVar("ttt2_banker_stamina_regen"):GetFloat())
	SetGlobalFloat("ttt2_banker_stamina_drain", GetConVar("ttt2_banker_stamina_drain"):GetFloat())
end)

cvars.AddChangeCallback("ttt2_banker_ron_swanswon_will", function(name, old, new)
	SetGlobalBool("ttt2_banker_ron_swanswon_will", tobool(tonumber(new)))
end)
cvars.AddChangeCallback("ttt2_banker_give_handouts", function(name, old, new)
	SetGlobalBool("ttt2_banker_give_handouts", tobool(tonumber(new)))
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
