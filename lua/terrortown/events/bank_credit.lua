if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgui/ttt/vskin/events/creditfound.vmt")
end

if CLIENT then
	EVENT.title = "title_event_bank_credit"
	EVENT.icon = Material("vgui/ttt/vskin/events/creditfound.vmt")
	
	function EVENT:GetText()
		return {
			{
				string = "desc_event_bank_credit",
				params = {
					name1 = self.event.banker_name,
					name2 = self.event.purchaser_name,
					c = self.event.credits
				},
				translateParams = true
			}
		}
    end
end

if SERVER then
	function EVENT:Trigger(banker, purchaser, payment)
		self:AddAffectedPlayers(
			{banker:SteamID64(), purchaser:SteamID64()},
			{banker:GetName(), purchaser:GetName()}
		)
		
		return self:Add({
			serialname = self.event.title,
			banker_name = banker:GetName(),
			purchaser_name = purchaser:GetName(),
			credits = payment
		})
	end
	
	function EVENT:Serialize()
		return self.event.serialname
	end
end