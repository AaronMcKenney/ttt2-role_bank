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

end
