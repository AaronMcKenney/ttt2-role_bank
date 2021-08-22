if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_bank.vmt")
end

if CLIENT then
	EVENT.title = "title_event_bank_will"
	EVENT.icon = Material("vgui/ttt/dynamic/roles/icon_bank.vmt")
	
	function EVENT:GetText()
		return {
			{
				string = "desc_event_bank_will",
				params = {
					name1 = self.event.banker_name,
					name2 = self.event.recipient_name,
					c = self.event.credits
				},
				translateParams = true
			}
		}
    end
end

if SERVER then
	function EVENT:Trigger(banker, recipient, payment)
		self:AddAffectedPlayers(
			{banker:SteamID64(), recipient:SteamID64()},
			{banker:GetName(), recipient:GetName()}
		)
		
		return self:Add({
			serialname = self.event.title,
			banker_name = banker:GetName(),
			recipient_name = recipient:GetName(),
			recipient_id = recipient:SteamID64(),
			credits = payment
		})
	end
	
	function EVENT:CalculateScore()
		self:SetPlayerScore(self.event.recipient_id, {
			score = 1
		})
	end
	
	function EVENT:Serialize()
		return self.event.serialname
	end
end