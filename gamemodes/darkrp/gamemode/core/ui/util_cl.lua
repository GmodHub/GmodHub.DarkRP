rp.ui = rp.ui or {}

local color_bg 		= ui.col.Background
local color_outline = ui.col.Outline

local math_clamp	= math.Clamp
local Color 		= Color

function rp.ui.DrawBar(x, y, w, h, perc)
	local color = Color(255 - (perc * 255), perc * 255, 0, 255)

	draw.OutlinedBox(x, y, math_clamp((w * perc), 3, w), h, color, color_outline)
end

function rp.ui.DrawProgress(x, y, w, h, perc, noSpacer)
	local color = Color(255 - (perc * 255), perc * 255, 0, 255)

	if (noSpacer) then
		draw.OutlinedBox(x, y, w, h, color_bg, color_outline)
		draw.Box(x + 1, y + 1, math_clamp((w * perc), 3, w - 2), h - 2, color)
	else
		draw.OutlinedBox(x, y, w, h, color_bg, color_outline)
		draw.OutlinedBox(x + 5, y + 5, math_clamp((w * perc) - 10, 3, w), h - 10, color, color_outline)
	end
end

local dcpY
local dcpCT = -1
function rp.ui.DrawCenteredProgress(text, prog)
	surface.SetFont('ui.5percent')
	local w, h = surface.GetTextSize(text)
	w = w + 16
	local x = (ScrW() - w) * 0.5

	if (dcpCT != FrameNumber()) then
		dcpY = ScrH() * 0.15
		dcpCT = FrameNumber()
	end
	local y = dcpY

	surface.SetDrawColor(rp.col.Outline)
	surface.DrawOutlinedRect(x, y, w, h)

	surface.SetDrawColor(rp.col.Background)
	surface.DrawRect(x, y, w, h)

	surface.SetTextPos(x + 8, y)
	surface.SetTextColor(200, 50, 50, (prog and math.abs(math.sin(RealTime() * 2)) or 1) * 255)
	surface.DrawText(text)

	if (prog and prog > 0) then
		surface.SetDrawColor(rp.col.Green)
		surface.DrawRect(x + prog * w, y, 5, h)
	end

	dcpY = dcpY + h + 5
end
