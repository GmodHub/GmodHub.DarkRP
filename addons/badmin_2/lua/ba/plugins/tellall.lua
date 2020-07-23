term.Add('AdminSentStaffMessage', '# отправил сообщение администрации серверу: #')

-------------------------------------------------
-- Tell All
-------------------------------------------------
ba.AddCommand('TellAll', function(pl, message)
	net.Start('ba.TellAll')
		net.WriteString(message)
	net.Broadcast()

	ba.notify_all(term.Get('AdminSentStaffMessage'), pl, message)
end)
:AddParam(cmd.STRING)
:SetFlag 'A'
:SetHelp 'Sends a message to the server'


if (SERVER) then
	util.AddNetworkString 'ba.TellAll'
	return
end

surface.CreateFont('ba.ui.tellall', {font = 'Prototype [RUS by Daymarius]', size = 40, weight = 750, extended = true})

local tellallQueue = {}

local PANEL = {}
function PANEL:Init()
	surface.PlaySound('HL1/fvox/beep.wav')

	self.Lines 		= {}
	self.Time 		= 15
	self.EndTime 	= CurTime() + self.Time

	self.Title = ui.Create('DLabel', self)
	self.Title:SetText('Сообщение Администрации!')
end

function PANEL:PerformLayout(w, h)
	self.Title:SizeToContents()
	self.Title:SetPos((w * 0.5) - (self.Title:GetWide() * 0.5), 5)
	self.Title:SetSize(self.Title:GetWide(), 20)

	for k, v in ipairs(self.Lines) do
		v:SetPos((w * 0.5) - (v:GetWide() * 0.5), (k * 30))
	end
end

function PANEL:ApplySchemeSettings()
	self.Title:SetFont('ui.22')
	self.Title:SetColor(ui.col.White)
end

function PANEL:Think()
	self:MoveToFront()

	if self.Anim then
		self.Anim:Run()
	end

	if self.MoveAnim then
		self.MoveAnim:Run()
	end
end

function PANEL:FadeIn(speed, cback)
	self.Anim = Derma_Anim('Fade Panel', self, function(panel, animation, delta, data)
		panel:SetAlpha(delta * 255)
		if (animation.Finished) then
			self.Anim = nil
			if cback then cback() end
		end
	end)

	if (self.Anim) then
		self.Anim:Start(speed)
	end
end

function PANEL:FadeOut(speed, cback)
	self.Anim = Derma_Anim('Fade Panel', self, function(panel, animation, delta, data)
		panel:SetAlpha(255 - (delta * 255))
		if (animation.Finished) then
			self.Anim = nil
			if cback then cback() end
		end
	end)

	if (self.Anim) then
		self.Anim:Start(speed)
	end
end

function PANEL:MoveDown(dist, speed, cback)
	local start = self.NextY or self.y
	self.NextY = start + dist
	self.MoveAnim = Derma_Anim('Move Panel', self, function(panel, animation, delta, data)
		panel.y = start + (delta * dist)
		if animation.Finished then
			self.MoveAnim = nil
			self.NextY = nil
			if cback then cback() end
		end
	end)

	if self.MoveAnim then
		self.MoveAnim:Start(speed)
	end
end

function PANEL:SetText(message)
	local lines = string.Wrap('ba.ui.tellall', message, ScrW() * 0.8)

	self:SetWide(175)

	for k, v in ipairs(lines) do
		self.Lines[#self.Lines + 1] = ui.Create('DLabel', function(s)
			s:SetFont('ba.ui.tellall')
			s:SetTextColor(ui.col.White)
			s:SetText(v)
			s:SizeToContents()

			if ((s:GetWide() + 20) > self:GetWide()) then
				self:SetWide(s:GetWide() + 20)
			end
		end, self)
	end

	self:SetTall(41 + (#lines * 30))
	self:SetPos((ScrW() * 0.5) - (self:GetWide() * 0.5))

	self:FadeIn(0.2)
	self:MoveDown(ScrH() * 0.1, 0.2)

	for k, v in ipairs(tellallQueue) do
		v:MoveDown(self:GetTall() + 10, 0.2)
	end

	tellallQueue[#tellallQueue + 1] = self

	timer.Simple(self.Time, function()
		local pnl = table.remove(tellallQueue, 1)
		if IsValid(pnl) then
			pnl:FadeOut(0.2, function()
				pnl:Remove()
			end)
		end
	end)
end

local bar_color = ui.col.Red:Copy()
bar_color.a = 25
function PANEL:Paint(w, h)
	derma.SkinHook('Paint', 'Frame', self, w, h)

	draw.Box(0, 0, w * ((self.EndTime - CurTime())/self.Time), 30, bar_color)

	surface.SetDrawColor(CurTime() % 2 < 1 and ui.col.Red or ui.col.Outline)
	surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register('ba_tellall', PANEL, 'Panel')


net('ba.TellAll', function()
	ui.Create('ba_tellall', function(self)
		self:SetText(net.ReadString())
	end)
end)
