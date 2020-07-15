/*KombatPlayers = KombatPlayers or {};
local kombatInf;
local kombatting = false;

local function DrawKombatRing()
	if (!kombatting) then return; end

	local box = kombatInf.Box;
	local ft = FrameTime() / 5;
	local zVal = kombatInf.ZCutOff + 90;

	if (!kombatInf.GraphicsMade) then
		kombatInf.GraphicsMade = true;

		for k, v in pairs(box) do
			local dist = math.sqrt((v.x2 - v.x) ^ 2 + (v.y2 - v.y) ^ 2);
			local ang;

			if (v.x == v.x2) then
				if (v.y2 > v.y) then
					ang = Angle(0, 90, 90);
				else
					ang = Angle(0, 270, 90);
				end
			else
				if (v.x2 > v.x) then
					ang = Angle(0, 0, 90);
				else
					ang = Angle(0, 180, 90);
				end
			end

			v.dist = dist;
			v.ang = ang;

			v.g1 = 0;
			v.g2 = dist / 2;
		end
	end

	for k, v in pairs(box) do
		local cutOff = nil;
		if (box[k-1]) then
			cutOff = box[k-1].cutOff or nil;
		else
			cutOff = box[#box].cutOff or nil;
		end

		local vec = Vector(v.x, v.y, zVal);
		local maxWide = v.dist / 4;
		local g1w = math.Clamp(maxWide, 0, v.dist - v.g1);
		local g2w = math.Clamp(maxWide, 0, v.dist - v.g2);

		if (SysTime() % 1 < 0.5) then
			surface.SetDrawColor(200, 50, 50);
		else
			surface.SetDrawColor(200, 200, 200);
		end

		cam.Start3D2D(vec, v.ang, 1);
				surface.DrawRect(v.g1, 0, g1w, 90);
				surface.DrawRect(v.g2, 0, g2w, 90);

				if (cutOff) then
					surface.DrawRect(0, 0, cutOff, 90);
				end
		cam.End3D2D();

		v.g1 = v.g1 + ft * v.dist;
		v.g2 = v.g2 + ft * v.dist;

		if (v.g1 > v.dist) then v.g1 = 0; end
		if (v.g2 > v.dist) then v.g2 = 0; end

		if (g1w < maxWide) then
			cutOff = maxWide - g1w;
		elseif (g2w < maxWide) then
			cutOff = maxWide - g2w;
		else
			cutOff = nil;
		end

		v.cutOff = cutOff;
	end
end

function BeginKombat(pls)
	kombatInf = GetKombatInfo();
	kombatting = true;
	hook("PostDrawOpaqueRenderables", "DrawKombatRing", DrawKombatRing);
end
net("KombatBegin", function(length) BeginKombat(); end);
concommand.Add("fkombat", BeginKombat)

function EndKombat()
	kombatInf.GraphicsMade = nil;

	for k, v in pairs(kombatInf.Box) do
		v.g1 = nil;
		v.g2 = nil;
	end

	kombatting = false;
	kombatInf = nil;

	LocalPlayer():ConCommand("stopsound");
	hook.Remove("PostDrawOpaqueRenderables", "DrawKombatRing");
end
net("KombatEnd", function(length) EndKombat(); end);
concommand.Add("ekombat", EndKombat)
net("KombatStartTime", function(len)
	local startTime = SysTime() + (net.ReadFloat() - CurTime())
	chat.AddText("БУДИТ МЯСО! Через " .. math.Round(startTime - SysTime()) .. " секунд.");

	hook("HUDPaint", "DrawKombatStartTime", function()
		surface.SetTextColor(255, 255, 255)

		local diff = math.Clamp(startTime - SysTime(), 0, math.huge)
		local mul = 1 - math.Clamp((diff - 5) / 5, 0, 1)
		local rem = math.floor(diff)

		surface.SetFont('rp.ui.' .. (22 + math.floor(mul * 18)))

		local hw, hh = surface.GetTextSize("Kombat:")
		local tw = surface.GetTextSize(rem)

		local x = 5 + mul * (((ScrW() - hw) * 0.5) - 5)
		local x2 = (x + (hw * 0.5)) - (tw * 0.5)
		local y = ScrH() * 0.5 - hh

		surface.SetTextPos(x, y)
		surface.DrawText("Бой:")

		y = y + hh

		surface.SetTextPos(x2, y)
		surface.DrawText(rem)

		if (rem == 0) then
			hook.Remove("HUDPaint", "DrawKombatStartTime")
		end
	end)
end)
