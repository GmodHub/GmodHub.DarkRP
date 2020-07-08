local w, h = surface.GetTextureSize(surface.GetTextureID('effects/blood_core'))
local size = math.random(3, 10)
w, h = w * size , h * size
local a = math.random(25, 255)

local function DrawCumShot()
	surface.SetTexture(surface.GetTextureID('effects/blood_core'))
	surface.SetDrawColor(255,255,255,a)
	surface.DrawTexturedRect(ScrW() * .5 - w  * .5, ScrH() - h + 10, w, h)
end

net('RapeFinish', function()
	w, h = surface.GetTextureSize(surface.GetTextureID('effects/blood_core'))
	local size = math.random(3, 10)
	w, h = w * size , h * size
	a = math.random(25, 255)

	hook('HUDPaint', 'RapistEffect', DrawCumShot)
	timer.Simple(10, function()
		hook.Remove('HUDPaint', 'RapistEffect')
	end)
end)
