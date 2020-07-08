local color_white = ui.col.White

local function doorEsp()
		for k, v in ipairs(ents.GetAll()) do
			if v:IsDoor() and (not v:IsPropertyOwnable()) and (not v:IsPropertyTeamOwned()) and (not v:IsPropertyHotelOwned()) then
				local pos = v:GetPos()
				pos = pos:ToScreen()
				pos.y = pos.y + 100
				draw.Box(pos.x- 15, pos.y - 40, 16, 16, color_white)
				draw.SimpleTextOutlined('DOOR ', 'HudFont', pos.x, pos.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
			end
		end
	end

concommand.Add('dooresp', function()
	if (not LocalPlayer():IsRoot()) then return end

	if hook.GetTable()['HUDPaint']['dooresp'] then
		hook.Remove('HUDPaint', 'dooresp')
	else
		hook.Add('HUDPaint', 'dooresp', doorEsp)
	end
end)
