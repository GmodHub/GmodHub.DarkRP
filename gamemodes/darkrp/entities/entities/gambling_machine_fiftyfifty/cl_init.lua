dash.IncludeSH 'shared.lua'

ENT.BackgroundMaterial = Material 'gmh/entities/fiftyfifty.png'

local color_white = ui.col.White
function ENT:DrawScreen()
	surface.SetFont('3d2d')
	surface.SetTextColor(255,255,255)
	surface.SetTextPos(-475, -1375)
	surface.DrawText(self:GetPlayerRoll())

	surface.SetTextPos(225, -1375)
	surface.DrawText(self:GetHouseRoll())

	surface.SetTextPos(225, -1375)
	surface.DrawText(self:GetHouseRoll())
	draw.SimpleText(rp.FormatMoney(self:Getprice()), '3d2d', 0, -1160, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end