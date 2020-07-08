if (CLIENT) then
local vec0 = Vector()
local ang0 = Angle()

concommand.Add("debug_spawnzone", function(p, c, a)
	if (a[1] and a[1] == "0") then
		hook.Remove("PostDrawOpaqueRenderables", "debug_spawnzone")
	else
		PrintTable(rp.cfg.Spawns[game.GetMap()] or {})
		hook.Add("PostDrawOpaqueRenderables", "debug_spawnzone", function()
			render.SetColorMaterial()
			for k, v in ipairs(rp.cfg.Spawns[game.GetMap()] or {}) do
				render.DrawBox(vec0, ang0, v[1], v[2])
			end
		end)
	end
end)

concommand.Add("debug_pos", function(p, c, a)
	if (a[1] and a[1] == "0") then
		hook.Remove("HUDPaint", "debug_pos")
	else
		hook.Add("HUDPaint", "debug_pos", function()
			surface.SetFont("ui.5percent")
			
			local pos = LocalPlayer():GetPos()
			local aimPos = LocalPlayer():GetEyeTrace().HitPos
			local _, h = surface.GetTextSize(" ")
			surface.SetDrawColor(0, 0, 0)
			surface.DrawRect(0, 50, ScrW(), h + h + 5)
			surface.SetTextColor(225, 225, 225)
			surface.SetTextPos(50, 50)
			surface.DrawText(pos.x .. ", " .. pos.y .. ", " .. pos.z)
			surface.SetTextPos(50, 50 + h + 5)
			surface.DrawText(aimPos.x .. ", " .. aimPos.y .. ", " .. aimPos.z)
		end)
	end
end)
end