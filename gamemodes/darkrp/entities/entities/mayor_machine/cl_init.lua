include('shared.lua')

--[[ basic 3d2d interaction shit ]]
local origin
local scale
local angle
local normal

local ang0 = Angle(0, 0, 0)
local function getCursorPos()
	if (!origin) then return end

	local p = util.IntersectRayWithPlane(LocalPlayer():EyePos(), LocalPlayer():GetAimVector(), origin, normal)

	if (!p) then return -1, -1 end
	if (WorldToLocal(LocalPlayer():GetShootPos(), ang0, origin, angle).z < 0) then return -1, -1 end

	local pos = WorldToLocal(p, ang0, origin, angle)
	return pos.x / scale, -pos.y / scale
end

local offset = Vector(0, -10.88, 24.555)
local w, h = 1598, 1208

local buttons = {
	{
		x = 0,
		y = h * 0.25,
		w = w * 0.5,
		h = h * 0.25,
		text = "Законы",
		func = 'laws'
	},
	{
		x = w * 0.5,
		y = h * 0.25,
		w = w * 0.5,
		h = h * 0.25,
		text = "Лотерея",
		func = function()
			local recurse

			recurse = function(tried)
				ui.StringRequest("Лотерея", "На какую сумму будет лотерея?" .. (tried and " Пожалуйста, введите ЧИСЛО." or ""), 1000, function(val)
					if (val and tonumber(val) and tostring(tonumber(val)) == val) then
						cmd.Run('lotto', tonumber(val))
					else
						recurse(true)
					end
				end)
			end

			recurse()
		end
	},
	{
		x = 0,
		y = h * 0.5,
		w = w,
		h = h * 0.25,
		text = "Начать Комендантский Час",
		func = function()
			if nw.GetGlobal('lockdown') then
				cmd.Run('unlockdown')
				return
			end
			ui.BoolRequest('Комендантский Час', 'Вы уверены, что хотите начать комендантский час?', function(yes)
				if yes then
					cmd.Run('lockdown')
				end
			end)
		end
	},
	{
		x = 0,
		y = h * 0.75,
		w = w,
		h = h * 0.25,
		text = "Освободить Заключённого",
		func = 'bail'
	},
}

function ENT:Draw()
	self:DrawModel()

	if (not self:InDistance(125000)) then return end

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 90)

	origin = self:LocalToWorld(offset) - (self:GetForward() * -0.3)
	scale = 0.013
	angle = ang
	normal = ang:Up()

	cam.Start3D2D(origin, ang, scale)
		surface.SetDrawColor(0, 0, 0)
		surface.DrawRect(0, 0, w, h)

		local mayor = team.GetPlayers(TEAM_MAYOR)[1]
		if IsValid(mayor) then
			draw.SimpleText(mayor:Name(), '3d2d', w * 0.5, 10, mayor:GetJobColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end

		local chief = team.GetPlayers(TEAM_CHIEF)[1]
		if IsValid(chief) then
			draw.SimpleText(chief:Name(), '3d2d', w * 0.5, h * 0.1225, chief:GetJobColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end

		local mx, my = getCursorPos()

		for k, v in ipairs(buttons) do
			if (mx and mx > v.x and mx < v.x + v.w and my > v.y and my < v.y + v.h) then
				surface.SetDrawColor(200, 200, 200, 15)
				surface.DrawRect(v.x, v.y, v.w, v.h)
			end

			surface.SetDrawColor(rp.col.Outline)
			surface.DrawOutlinedRect(v.x, v.y, v.w, v.h)
			surface.DrawOutlinedRect(v.x + 1, v.y + 1, v.w - 2, v.h - 2)
			surface.DrawOutlinedRect(v.x + 2, v.y + 2, v.w - 4, v.h - 4)
			draw.SimpleText(v.text, '3d2d', v.x + (v.w * 0.5), v.y + (v.h * 0.5), ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		if (!LocalPlayer():IsMayor()) then
			surface.SetDrawColor(0, 0, 0, 252)
			surface.DrawRect(0, 0, w, h)
			draw.SimpleText('Доступ Запрещён!', '3d2d', 800, 604, ui.col.Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			surface.SetDrawColor(rp.col.White)
		else
			surface.SetDrawColor(rp.col.Red)
		end

		if (mx > 0 and mx < w and my > 0 and my < h) then
			surface.DrawLine(mx - 10, my, mx + 10, my)
			surface.DrawLine(mx, my - 10, mx, my + 10)
		end
	cam.End3D2D()
end

function ENT:PlayerUse()
	if (LocalPlayer():IsMayor()) then
		local mx, my = getCursorPos()

		for k, v in ipairs(buttons) do
			if (mx and mx > v.x and mx < v.x + v.w and my > v.y and my < v.y + v.h) then
				if (v.func) then
					if (isstring(v.func)) then
						cmd.Run(v.func)
					else
						v.func()
					end
				end

				break
			end
		end
	end
end
