dash.IncludeSH 'shared.lua'

local X = -50
local Y = -100
local W = 100
local H = 200
local VEC_ZERO = Vector(0, 0, 0)

local color_black = Color(0,0,0)
local color_outline = Color(255,255,255)
local color_entry = Color(50, 75, 50, 255)

local KeyPos =	{
	{X+5, Y+100, 25, 25, -2.2, 3.45, 1.3, -0},
	{X+37.5, Y+100, 25, 25, -0.6, 1.85, 1.3, -0},
	{X+70, Y+100, 25, 25, 1.0, 0.25, 1.3, -0},

	{X+5, Y+132.5, 25, 25, -2.2, 3.45, 2.9, -1.6},
	{X+37.5, Y+132.5, 25, 25, -0.6, 1.85, 2.9, -1.6},
	{X+70, Y+132.5, 25, 25, 1.0, 0.25, 2.9, -1.6},

	{X+5, Y+165, 25, 25, -2.2, 3.45, 4.55, -3.3},
	{X+37.5, Y+165, 25, 25, -0.6, 1.85, 4.55, -3.3},
	{X+70, Y+165, 25, 25, 1.0, 0.25, 4.55, -3.3},

	{X+5, Y+67.5, 50, 25, -2.2, 4.7, -0.3, 1.6, 'KeypadButton'},
	{X+60, Y+67.5, 35, 25, 0.3, 1.65, -0.3, 1.6}
}

local down = {}

local keypad_buttons = {}
keypad_buttons[KEY_PAD_1] = 1
keypad_buttons[KEY_PAD_2] = 2
keypad_buttons[KEY_PAD_3] = 3
keypad_buttons[KEY_PAD_4] = 4
keypad_buttons[KEY_PAD_5] = 5
keypad_buttons[KEY_PAD_6] = 6
keypad_buttons[KEY_PAD_7] = 7
keypad_buttons[KEY_PAD_8] = 8
keypad_buttons[KEY_PAD_9] = 9
keypad_buttons[KEY_ENTER] = KEY_ENTER
keypad_buttons[KEY_PAD_ENTER] = KEY_PAD_ENTER
keypad_buttons[KEY_PAD_MINUS] = KEY_PAD_MINUS
keypad_buttons[KEY_PAD_PLUS] = KEY_PAD_PLUS

local keypad_reference = {}
keypad_reference[10] = KEY_PAD_MINUS
keypad_reference[11] = KEY_ENTER

local traceBase = {}
local lookEnt
local traceRes

surface.CreateFont("Keypad", {font = "Calibri", size = 55, weight = 900})
surface.CreateFont("KeypadButton", {font = "roboto", size = 24, weight = 500})
surface.CreateFont("KeypadSButton", {font = "Trebuchet", size = 22, weight = 900})

function ENT:Draw()
	self.BaseClass.Draw(self)

	local LP = LocalPlayer()

	if (IsValid(LP)) then
		local distance = LP:EyePos():DistToSqr(self:GetPos())
		if (distance > 562500) then return end

		local pos = self:GetPos() + self:GetForward() * 1.1
		local ang = self:GetAngles()

		ang:RotateAroundAxis(ang:Right(), -90)
		ang:RotateAroundAxis(ang:Up(), 90)

		cam.Start3D2D(pos, ang, 0.05)
			local pos = lookEnt and lookEnt == self and self:WorldToLocal(traceRes.HitPos)
			local num = self:GetNumStars()
			local status = self:GetStatus()

			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(X-5, Y-5, W+10, H+10)

			-- neutral = 0 or nil, granted = 1, denied = 2
			local status = self:GetStatus() or 0

			if (status == 2) then
				surface.SetTextColor(255, 50, 50)
			elseif (status == 1) then
				surface.SetTextColor(50, 255, 50)
			else
				surface.SetTextColor(255, 255, 255)
			end
			surface.SetDrawColor(50, 75, 50, 255)
			surface.DrawRect(X+5, Y+5, 90, 50)

			surface.SetFont("Keypad")
			surface.SetTextPos(X + 5, Y + 10)
			surface.DrawText(string.rep('*', self:GetNumStars()))

			local hovered = false
			for k, v in ipairs(KeyPos) do
				local text = k
				local textx = v[1] + 7
				local texty = v[2] + 1
				local x = pos and ((pos.y - v[5]) / (v[5] + v[6]))
				local y = pos and (1 - (pos.z + v[7]) / (v[7] + v[8]))

				if (k == 10) then
					text = "✘"
					textx = v[1] + 16
					texty = v[2]
					surface.SetTextColor(255, 50, 50)
					surface.SetDrawColor(90, 25, 25, 255)
				elseif (k == 11) then
					textx = v[1] + 8
					texty = v[2] + 1
					text = "✔"
					surface.SetTextColor(50, 255, 50, 255)
					surface.SetDrawColor(25, 90, 25, 255)
				else
					surface.SetTextColor(150, 150, 150, 255)
					surface.SetDrawColor(50, 50, 50, 255)
				end

				if (lookEnt and lookEnt == self) and (x >= 0) and (y >= 0) and (x <= 1) and (y <= 1) then
					if (k <= 9) then
						surface.SetTextColor(0, 0, 0)
						surface.SetDrawColor(200, 200, 200, 255)
					elseif (k == 10) then
						surface.SetTextColor(255, 255, 255)
						surface.SetDrawColor(200, 50, 50, 255)
					elseif (k == 11) then
						surface.SetTextColor(255, 255, 255)
						surface.SetDrawColor(50, 200, 50, 255)
					end

					surface.DrawRect(v[1], v[2], v[3], v[4])

					if (LP:KeyDown(IN_USE)) then
						surface.SetDrawColor(0, 0, 0)
						surface.DrawOutlinedRect(v[1], v[2], v[3], v[4])
						if (!LP.KeypadCooldown or SysTime() > LP.KeypadCooldown) then
							self:EnterKey(LP, k)
						end
					end

					hovered = true
				else
					surface.DrawRect(v[1], v[2], v[3], v[4])
				end

				surface.SetFont(v[9] or "KeypadSButton")
				surface.SetTextPos(textx, texty)
				surface.DrawText(text)
			end
		cam.End3D2D()
	end
end

function ENT:SendCommand(command, data)
	net.Start("Keypad")
		net.WriteEntity(self)
		net.WriteUInt(command, 4)

		if data then
			net.WriteUInt(data, 8)
		end
	net.SendToServer()
end

function ENT:EnterKey(LP, k)
	k = keypad_buttons[k] or keypad_reference[k] or k
	LP.KeypadCooldown = SysTime() + 1

	if (k <= 9) then
		net.Start("Keypad")
			net.WriteEntity(self)
			net.WriteUInt(self.Command_Enter, 4)
			net.WriteUInt(k, 8)
		net.SendToServer()
	else
		local isSubmit = k == KEY_ENTER or k == KEY_PAD_ENTER
		net.Start("rp.keypad.Open")
			net.WriteEntity(self)
			net.WriteBool(isSubmit)
		net.SendToServer()
	end
end

hook.Add("Think", "rp.keypads.Think", function()
	local LP = LocalPlayer()
	if (IsValid(LP)) then
		traceBase.start = LP:GetShootPos()
		traceBase.endpos = LP:GetAimVector() * 32 + traceBase.start
		traceBase.filter = LP
		local tr = util.TraceLine(traceBase)

		if (IsValid(tr.Entity) and tr.Entity:GetClass() == "pad_key") then
			lookEnt = tr.Entity
			traceRes = tr

			for k, v in pairs(keypad_buttons) do
				if (keypad_buttons[k]) then
					if (input.IsKeyDown(k) and !down[k] and (!LP.KeypadCooldown or SysTime() > LP.KeypadCooldown)) then
						down[k] = true
						tr.Entity:EnterKey(LP, k)
					elseif (down[k] and !input.IsKeyDown(k)) then
						down[k] = nil
						LP.KeypadCooldown = SysTime() + 0.1
					end
				end
			end
		else
			lookEnt = nil
			traceRes = nil
		end
	end
end)

hook.Add("KeyRelease", "rp.keypads.KeyRelease", function(LP, k)
	if (!IsFirstTimePredicted()) then return end

	if (k == IN_USE) then
		LP.KeypadCooldown = SysTime() + 0.1
	end
end)