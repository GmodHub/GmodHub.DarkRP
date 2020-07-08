local fr

local texGradient = surface.GetTextureID("gui/center_gradient")

net.Receive("quicktime_cue", function(len)
	local lp = LocalPlayer()
	local successLevel = 1
	local startTime = SysTime()

	local id = net.ReadString()
	local title = net.ReadString()

	local curKey = 1
	local numKeys = net.ReadUInt(6)
	local keys = {}
	for i=1, numKeys do
		keys[i] = {
			net.ReadUInt(7), -- key ID
			net.ReadFloat() -- time
		}
	end

	local successLevelStep= 1 / numKeys
	local duration = 0
	for k, v in pairs(keys) do
		duration = duration + v[2]
		v[2] = startTime + duration -- v[2] becomes the SysTime at which key needs pressed
	end

	local container = ui.Create("ui_frame", function(self)
		self:SetSize(ScrW(), ScrH())
		self:MakePopup()
		self:SetTitle("")
		self:ShowCloseButton(false)

		self.Paint = function(self, w, h)
			draw.BlurResample()
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawRect(0, 0, w, h)
			draw.BlurPanel(self)

			surface.SetFont("ui.30")
			surface.SetTextColor(200, 200, 200)
			local tw, th = surface.GetTextSize("Press the keys as they roll by!")
			surface.SetTextPos((w - tw) * 0.5, fr.y + fr:GetTall())
			surface.DrawText("Press the keys as they roll by!")
		end
	end)

	fr = ui.Create("ui_frame", function(self)
		self:SetTitle("")
		self:SetSize(400, 64)
		self:ShowCloseButton(false)
		self:Center()
		self:MakePopup()

		self.Container = container
	end)

	fr.Think = function(self)
		if (self.Exiting) then return end

		self.CurKey = keys[curKey]

		if (!self.CurKey) then
			self:Exit()
		end
	end

	fr.OnKeyCodePressed = function(self, key)
		if (self.Exiting) then return end
		if (key == MOUSE_LEFT or key == MOUSE_RIGHT or key == MOUSE_MIDDLE) then return end

		local t = SysTime()

		if (key == self.CurKey[1]) then
			local diffTime = math.abs(self.CurKey[2] - t)

			if (diffTime < 0.25) then -- success!
				local successStep = (diffTime / 0.25)
				if (successStep < 0.4) then successStep = 0 end

				self.CurKey[3] = 1 - successStep
				successLevel = successLevel - (successStep * 0.8) * successLevelStep
				curKey = curKey + 1

				surface.PlaySound("sup/ui/beep.ogg")

				return
			end
		end

		self.CurKey[3] = 0
		successLevel = successLevel - successLevelStep
		curKey = curKey + 1

		//surface.PlaySound("ui/beep-30.mp3")
	end

	fr.OP = fr.Paint
	fr.Paint = function(self, w, h)
		surface.SetTexture(texGradient)
		surface.SetDrawColor(0, 0, 0)
		surface.DrawTexturedRect(0, 27, w, h - 27)
		surface.SetDrawColor(200, 200, 200, 150)
		surface.DrawTexturedRect(0, 27, w, 1)
		surface.DrawTexturedRect(0, h - 1, w, 1)

		local t = SysTime()
		local x = w * 0.5

		local boxPix = w * 0.1
		surface.SetDrawColor(200, 200, 200, 200)
		surface.DrawLine(x - boxPix * 0.5, 27, x - boxPix * 0.5, h - 1)
		surface.DrawLine(x + boxPix * 0.5, 27, x + boxPix * 0.5, h - 1)
		surface.SetDrawColor(50, 255, 50, 50)
		surface.DrawRect(x - boxPix * 0.5, 28, boxPix, h - 29)

		//surface.DrawLine()
		if (self.Exiting) then return end

		for k, v in ipairs(keys) do
			local diff = v[2] - t

			if (diff > -0.25) then
				v.x = x + (diff * w * 0.2)
			else
				v.x = v.x - (FrameTime() * w)
				if (!v[3] and curKey == k) then
					self:OnKeyCodePressed(-1)
				end
			end

			if (v.x > w) then break end
			if (v.x < -50) then continue end

			local a = math.Clamp((w - v.x) / 50, 0, 1) - math.Clamp((50 - v.x) / 50, 0, 1)

			local key = input.GetKeyName(v[1]):upper()

			//surface.DrawLine(v.x, 0, v.x, h)

			if (v[3]) then
				surface.SetTextColor(255 - v[3] * 205, 50 + v[3] * 205, 50, a * 255)
			else
				surface.SetTextColor(200, 200, 200, a * 255)
			end
			local tw, th = surface.GetTextSize(key)
			surface.SetFont("ui.38")
			surface.SetTextPos(v.x - (tw * 0.5), 26)
			surface.DrawText(key)
		end

		surface.SetFont("ui.30")
		surface.SetTextColor(200, 200, 200)
		local tw, th = surface.GetTextSize(title)
		surface.SetTextPos((w - tw) * 0.5, -3)
		surface.DrawText(title)
	end

	fr.Exit = function(self)
		self.Exiting = true

		net.Start("quicktime_res")
			net.WriteString(id)
			net.WriteFloat(math.Clamp(successLevel, 0, 1))
		net.SendToServer()

		self:Close()
		self.Container:Close()
	end
end)