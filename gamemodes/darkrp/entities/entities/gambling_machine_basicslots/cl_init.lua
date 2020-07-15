dash.IncludeSH 'shared.lua'

ENT.BackgroundMaterial = Material 'gmh/entities/basicslots.png'

local color_white = ui.col.White
function ENT:DrawScreen()
	surface.SetFont('3d2d')
	surface.SetTextColor(255,255,255)
	surface.SetTextPos(-235, -1375)
	surface.DrawText(self:GetRoll1())

	surface.SetTextPos(-80, -1375)
	surface.DrawText(self:GetRoll2())

	surface.SetTextPos(75, -1375)
	surface.DrawText(self:GetRoll3())

	draw.SimpleText(rp.FormatMoney(self:Getprice()), '3d2d', -50, -845, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end