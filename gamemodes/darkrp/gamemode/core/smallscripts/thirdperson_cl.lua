cvar.Register 'enable_thirdperson'
	:SetDefault(false, true)
	:AddMetadata('Menu', 'Включить режим от 3-его лица')
	:ConCommand(function(self, pl, args)
		if (!args[1]) then
			self:SetValue(!self:GetValue())
		else
			self:SetValue(args[1] == "1")
		end
	end)

cvar.Register 'invert_thirdp_mouse'
	:SetDefault(false, true)
	:AddMetadata('Menu', 'Инвертированная мышь в режиме от 3-его лица')

rp.thirdPerson = {}

local toggleCamLock = false

local x = CreateClientConVar('sup_thirdperson_x', '120')
local y = CreateClientConVar('sup_thirdperson_y', '0')
local z = CreateClientConVar('sup_thirdperson_z', '15')

local xmin, xmax = 40, 120
local ymin, ymax = -40, 40
local zmin, zmax = -15, 15

local fov = 90
local dist = 0

local function isThirdPerson(pl)
	pl = pl or LocalPlayer()
	if ((IsValid(pl:GetViewEntity()) and pl:GetViewEntity():GetClass() == "gmod_cameraprop") or (IsValid(pl:GetActiveWeapon()) and pl:GetActiveWeapon():GetClass() == "gmod_camera")) then return false end

	return cvar.GetValue('enable_thirdperson') and (not pl:InVehicle()) and (pl:GetObserverMode() == OBS_MODE_NONE) and pl:Alive()
end
rp.thirdPerson.isEnabled = isThirdPerson
local view = {}
local freecam_ang
local lastAim = nil
local htfilter = function(ent)
	return !(ent:GetParent() == LocalPlayer() or ent:IsPlayer()) and (ent:GetCollisionGroup() != COLLISION_GROUP_WORLD)
end
hook('CalcView', 'ThirdPerson.CalcView', function(pl, pos, angles)
	local tp = isThirdPerson(pl)
	if ((tp or dist > 0) and pl.camera_ang) then
		if (tp) then
			dist = math.min(dist + (1 - dist) * FrameTime() * 9, 1)
			if (dist > .99) then dist = 1 end
		else
			dist = math.max(dist - dist * FrameTime() * 9, 0)
			if (dist < .01) then dist = 0 end
		end

		local toggleCamLock = toggleCamLock
		if (pl:KeyDown(IN_WALK)) then toggleCamLock = !toggleCamLock end

		if (freecam_ang and !toggleCamLock) then
			pl.camera_ang = Angle(freecam_ang.p, freecam_ang.y, freecam_ang.r)
			freecam_ang = nil
		elseif (!freecam_ang and toggleCamLock) then
			freecam_ang = Angle(pl.camera_ang.p, pl.camera_ang.y, pl.camera_ang.r)
		end

		pos = pos + (pl.camera_ang:Forward() * dist * (-math.Clamp(x:GetInt(), xmin, xmax))) + (pl.camera_ang:Right() * dist * (math.Clamp(y:GetInt(), ymin, ymax))) + (pl.camera_ang:Up() * dist * (math.Clamp(z:GetInt(), zmin, zmax)))

		local hulltr = util.TraceHull({
			start = pl:GetShootPos(),
			endpos = pos,
			filter = htfilter,
			mask = MASK_SOLID,
			mins = Vector(-10, -10, -10),
			maxs = Vector(10, 10, 10)
		})

		if (hulltr.Hit) then
			pos = hulltr.HitPos + (pl:GetShootPos() - hulltr.HitPos):GetNormal() * 10
		end

		local aimtr = util.TraceLine({
			start = pl:EyePos(),--pos + (pl.camera_ang:Forward() * (-z:GetInt() + 45)),
			endpos = pos + (pl.camera_ang:Forward() * 100000),
			filter = htfilter
		})

		view.origin = pos
		view.fov = fov
		view.angles = pl.camera_ang
		view.drawviewer = true

		if (tp and pl:GetMoveType() == MOVETYPE_NOCLIP) then
			pl:SetEyeAngles(freecam_ang or pl.camera_ang)
		elseif (tp and !toggleCamLock) then
			local newAng = (aimtr.HitPos - pl:EyePos()):Angle()
			sp = aimtr.HitPos
			pl:SetEyeAngles(newAng)
		end

		return view
	else
		if (view and view.drawviewer) then
			view.drawviewer = false
			return view
		end
	end
end)

hook("CreateMove", "ThirdPerson.CreateMove", function(cmd)
	local pl = LocalPlayer()

	if (isThirdPerson(pl) and pl.camera_ang and pl:GetMoveType() != MOVETYPE_NOCLIP) then
		local realAng = freecam_ang or pl.camera_ang
		local plAng = pl:GetAimVector():Angle()

		local curVec = Vector(cmd:GetForwardMove(), cmd:GetSideMove(), cmd:GetUpMove())

		curVec:Rotate(plAng - realAng)

		cmd:SetForwardMove(curVec.x)
		cmd:SetSideMove(curVec.y)
		cmd:SetUpMove(curVec.z)

		return false
	end
end)

hook("InputMouseApply", "ThirdPerson.InputMouseApply", function(cmd, x, y, ang)
	local pl = LocalPlayer()

	if (isThirdPerson(pl)) then
		if (!pl.camera_ang) then
			pl.camera_ang = pl:EyeAngles()
		end

		if (cvar.GetValue("invert_thirdp_mouse")) then
			y = -y
		end

		pl.camera_ang.p = math.Clamp(math.NormalizeAngle(pl.camera_ang.p + y / 50), -90, 90)
		pl.camera_ang.y = math.NormalizeAngle(pl.camera_ang.y - x / 50)

		return true
	else
		pl.camera_ang = pl:EyeAngles()
	end
end)

/*hook('ShouldDrawLocalPlayer', 'ThirdPersonDrawPlayer', function()
	if cvar.GetValue('enable_thirdperson') then
		return isThirdPerson(LocalPlayer())
	end
end)*/

local lastPress
hook("PlayerBindPress", "ThirdPerson.PlayerBindPress", function(pl, bind, pressed)
	if (pressed and bind:lower() == "+walk") then
		local st = SysTime()

		if (lastPress and lastPress > st - 0.75) then
			toggleCamLock = !toggleCamLock
		end

		lastPress = st
	end
end)

-- Edit menu!
local fr, chk, chk2
hook('OnContextMenuOpen', 'rp.ThirdPerson.OnContextMenuOpen', function()
	local pl = LocalPlayer()

	chk = ui.Create('ui_checkbox', function(self, p)
		self:SetPos(10, 40)
		self:SetText('Включить режим от 3-его лица')
		self:SizeToContents()
		self:SetConVar('enable_thirdperson')
		self:SetMouseInputEnabled(true)
	end, g_ContextMenu)

	if (isThirdPerson(pl) and pl.camera_ang) then
		chk2 = ui.Create('ui_checkbox', function(self, p)
			self:SetPos(10, 61)
			self:SetText('Инвертированное управление мышью')
			self:SizeToContents()
			self:SetConVar('invert_thirdp_mouse')
			self:SetMouseInputEnabled(true)
		end, g_ContextMenu)

		fr = ui.Create('ui_frame', function(self, p)
			self:SetPos(10, 82)
			self:SetSize(159, 168)
			self:SetTitle("Расположение Камеры")
			self:ShowCloseButton(false)
			self:SetMouseInputEnabled(true)
			self:SetDraggable(false)
		end, g_ContextMenu)
		local btn
		local grid = ui.Create('Panel', function(self, p)
			self:SetSize(128, 128)
			self:SetPos(fr:GetDockPos())
			self.Paint = function(s, w, h)
				surface.SetDrawColor(ui.col.OffWhite)
				surface.DrawOutlinedRect(0, 0, w, h)
				surface.DrawLine(btn.x+8, 0, btn.x+8, h)
				surface.DrawLine(0, btn.y+8, w, btn.y+8)

				surface.SetDrawColor(ui.col.Hover)
				surface.DrawOutlinedRect(w * .25, h * .25, w * .5, h * .5)
				surface.DrawLine(0, h * .5, w, h * .5)
				surface.DrawLine(w * .5, 0, w * .5, h)
			end
		end, fr)

		btn = ui.Create('DButton', function(self, p)
			self:SetText('')
			self:SetSize(16, 16)
			self.OnMousePressed = function(s)
				s.Dragging = true
			end
			self.Think = function(s)
				if (s.Dragging) then
					if (!input.IsMouseDown(MOUSE_LEFT)) then
						s.Dragging = false
						return
					end

					local mx, my = grid:CursorPos()
					local sx, sy = self.x, self.y
					self:SetPos(math.Clamp(mx - 8, 0, grid:GetWide() - 16), math.Clamp(my - 8, 0, grid:GetTall() - 16))

					if (self.x != sx or self.y != sy) then
						local ymul = self.x / (grid:GetWide() - 16)
						local zmul = 1 - (self.y / (grid:GetTall() - 16))

						y:SetInt(ymin + (ymul * (ymax - ymin)))
						z:SetInt(zmin + (zmul * (zmax - zmin)))
					end
				end
			end
		end, grid)

		local slider = ui.Create('ui_slider_vertical', function(self, p)
			local _, y = fr:GetDockPos()
			self:SetPos(138, y)
			self:SetTall(128)

			self.OnChange = function(self, val)
				val = 1 - val
				x:SetInt(xmin + (val * (xmax - xmin)))
			end
		end, fr);

		slider:SetValue(1 - ((x:GetInt() - xmin) / (xmax - xmin)))

		local bx = ((y:GetInt() - ymin) / (ymax - ymin)) * (grid:GetWide() - 16)
		local by = (1 - ((z:GetInt() - zmin) / (zmax - zmin))) * (grid:GetTall() - 16)
		btn:SetPos(bx, by)
	end
end)
hook('OnContextMenuClose', 'rp.ThirdPerson.OnContextMenuClose', function()
	if (IsValid(fr)) then
		fr:Remove()
	end

	if (IsValid(chk)) then
		chk:Remove()
	end

	if (IsValid(chk2)) then
		chk2:Remove()
	end
end)