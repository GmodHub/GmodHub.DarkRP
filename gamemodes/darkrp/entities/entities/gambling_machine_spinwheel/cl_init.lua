dash.IncludeSH 'shared.lua'


local mat_bg = Material 'gmh/entities/spinwheel_background.png'
local mat_wheel = Material 'gmh/entities/spinwheel_wheel.png'
local color_white = ui.col.White

function ENT:DrawScreen()
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(-840, -1900, 1600, 1225)

	surface.SetDrawColor(255, 255, 255, 255)

	surface.SetMaterial(mat_wheel)
	surface.DrawTexturedRectRotated(-30, -1292, 1595, 1003, 360 * (self:GetRoll()/8))

	surface.SetMaterial(mat_bg)
	surface.DrawTexturedRect(-835, -1790, 1595, 1003)

	draw.SimpleText(rp.FormatMoney(self:Getprice()), '3d2d', 450, -895, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
