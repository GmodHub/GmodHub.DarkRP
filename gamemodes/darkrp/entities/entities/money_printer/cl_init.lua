include('shared.lua')

local color_red 	= Color(255,50,50)
local color_yellow 	= Color(255,255,50)
local color_green 	= Color(50,255,50)
local color_grey 	= Color(50,50,50)
local color_black 	= Color(0,0,0)
local color_white 	= Color(245,245,245)

local surface_SetDrawColor 		= surface.SetDrawColor
local surface_DrawRect 			= surface.DrawRect
local surface_SetMaterial 		= surface.SetMaterial
local surface_DrawTexturedRect 	= surface.DrawTexturedRect
local draw_SimpleText 			= draw.SimpleText
local draw_Outline 				= draw.Outline
local draw_Box 					= draw.Box
local cam_Start3D2D 			= cam.Start3D2D
local cam_End3D2D 				= cam.End3D2D
local math_Clamp 				= math.Clamp
local math_Round 				= math.Round
local CurTime 					= CurTime
local IsValid 					= IsValid

local font 			= '3d2d'
local printdelay 	= rp.cfg.PrintDelay

local x, y, w, h = -475, 634, 2081, 458
local bx1, by1, bh1, bw1 = x + 10, 			y + 200, w/3 - 10, h - 210
local bx2, by2, bh2, bw2 = bx1 + bh1 + 10, 	y + 200, w/3 - 10, h - 210
local bx3, by3, bh3, bw3 = bx2 + bh2 + 10, 	y + 200, w/3 - 10, h - 210
local tx, ty = w * .5 + x, y + 30

local function predict(timeValue, value)
	return math_Clamp(math_Round((CurTime() - timeValue)/value, 2), 0, 1)
end

local function barcolor(perc)
	return ((perc <= .39) and color_red or ((perc <= .75) and color_yellow or color_green))
end

local function drawbar(x, y, w, h, perc, mat, text)
	local s = h - 40
	surface_SetDrawColor(color_black.r, color_black.g, color_black.b)
	surface_DrawRect(x + 5, y + 5, h - 5, h - 5)

	draw_Outline(x, y, w, h, color_white, 5)
	draw_Outline(x, y, h, h, color_white, 5)

	surface_SetMaterial(mat)
	surface_DrawTexturedRect(x + 20, y + 20, s, s)

	local bw = (w - h - 4)
	bw =  math_Clamp((bw * perc), 0, bw)
	if (bw > 0) then
		draw_Box(x + h, y + 5, bw, h - 10, barcolor(perc))
	end

	draw_SimpleText(text or (perc * 100 .. '%'), font, x + ((w + h) * .5), y + (h * .5), color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end


local material_ink 		= Material 'gmh/printer/ink-cartridge-refill.png'
local material_hp 		= Material 'gmh/printer/health-care.png'
local material_print 	= Material 'gmh/printer/printer.png'

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	if (not self:InDistance(150000)) then return end

	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 39.6)

	cam_Start3D2D(pos + ang:Up() * 24.97, ang, 0.01)
		draw_Box(x, y, w, h, color_grey)

		drawbar(bx1, by1, bh1, bw1, self:GetInk()/self:GetMaxInk(), material_ink, self:GetInk() .. '/' .. self:GetMaxInk())
		drawbar(bx2, by2, bh2, bw2, self:GetHP()/100, material_hp)

		local printperc = predict(self:GetLastPrint(), printdelay)
		drawbar(bx3, by3, bh3, bw3, printperc, material_print)

		local pl = self:Getowning_ent()
		if IsValid(pl) then
			local tp, tw = draw_SimpleText(pl:Name(), font, tx, ty, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			if (pl:GetOrg() ~= nil) then
				local mat = rp.orgs.GetBanner(pl:GetOrg())

				if (mat ~= nil) then
					surface_SetDrawColor(255,255,255)
					surface_SetMaterial(mat)
					local s = h * .5 - 50
					surface_DrawTexturedRect((tx - 20) - s - tp/2, y + 10, s, s)
				end
			end

		else
			draw_SimpleText('Неизвестно', font, tx, ty, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	cam_End3D2D()
end
