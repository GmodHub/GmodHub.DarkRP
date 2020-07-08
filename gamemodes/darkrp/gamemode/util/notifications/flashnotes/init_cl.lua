local notificationQueue = {}

local PANEL = {}
function PANEL:Init()
	self.Lines 		= {}
	self.Time 		= 4
	self.EndTime 	= CurTime() + self.Time

	self.Title = ui.Create('DLabel', self)
end

function PANEL:PerformLayout(w, h)
	self.Title:SizeToContents()
	self.Title:SetPos((w * 0.5) - (self.Title:GetWide() * 0.5), 2)

	for k, v in ipairs(self.Lines) do
		v:SetPos(5, 8.5 + (k * v:GetTall()))
	end
end

function PANEL:ApplySchemeSettings()
	self.Title:SetFont('ui.22')
	self.Title:SetColor(ui.col.White)
end

function PANEL:Think()
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

function PANEL:SetInfo(title, message)
	self.Title:SetText(title)

	surface.SetFont('ui.22')
	local tW = surface.GetTextSize(title)

	self:SetWide(tW + 15)

	local lines = string.Wrap('ui.18', message, 275)

	for k, v in ipairs(lines) do
		self.Lines[#self.Lines + 1] = ui.Create('DLabel', function(s)
			s:SetFont('ui.18')
			s:SetTextColor(ui.col.White)
			s:SetText(v:Trim())
			s:SizeToContents()

			if ((s:GetWide() + 10) > self:GetWide()) then
				self:SetWide(s:GetWide() + 10)
			end
		end, self)
	end

	self:SetTall(27 + (#lines * self.Lines[1]:GetTall()))
	self:SetPos((ScrW() * 0.5) - (self:GetWide() * 0.5))

	self:FadeIn(0.2)
	self:MoveDown(ScrH() * 0.1, 0.2)

	for k, v in ipairs(notificationQueue) do
		v:MoveDown(self:GetTall() + 10, 0.2)
	end

	local queueSize = #notificationQueue
	notificationQueue[queueSize + 1] = self

	if (queueSize >= 4) then
		local pnl = table.remove(notificationQueue, 1)
		if IsValid(pnl) then
			pnl:FadeOut(0.2, function()
				pnl:Remove()
			end)
		end
	end

	timer.Simple(self.Time, function()
		if IsValid(self) then
			for k, v in ipairs(notificationQueue) do
				if (v == self) then
					table.remove(notificationQueue, k)
					break
				end
			end

			self:FadeOut(0.2, function()
				self:Remove()
			end)
		end
	end)
end

local color_background 	= ui.col.Background
local color_outline 	= ui.col.Outline
local bar_color 		= ui.col.SUP:Copy()
bar_color.a 			= 25
function PANEL:Paint(w, h)
	if (hook.Call('HUDShouldDraw', GAMEMODE, 'FashNotes') == false) then return end

	draw.Blur(self)

	draw.OutlinedBox(0, 0, w, h, color_background, color_outline)
	draw.OutlinedBox(0, 0, w, 26, color_background, color_outline)

	draw.Box(1, 1, 3, 24, ui.col.SUP)

	draw.Box(0, 0, w * ((self.EndTime - CurTime())/self.Time), 26, bar_color)
end
vgui.Register('rp_flashnote', PANEL, 'Panel')


function rp.FlashNotify(title, text)
	ui.Create('rp_flashnote', function(self)
		self:SetInfo(title, text)
	end)
end

net('rp.FlashString', function()
	if (not IsValid(LocalPlayer())) then return end
	rp.FlashNotify(net.ReadString(), rp.ReadMsg())
end)

net('rp.FlashTerm', function()
	if (not IsValid(LocalPlayer())) then return end
	rp.FlashNotify(net.ReadString(), net.ReadTerm())
end)


concommand.Add('flashnote_test', function()
	rp.FlashNotify('Test1', 'this is a test!!')
	rp.FlashNotify('Test1', 'this is a test!!')
	rp.FlashNotify('Test1', 'this is a test!!')
	rp.FlashNotify('Test1', 'this is a test!!')

	timer.Simple(1, function()
		rp.FlashNotify('Test2', 'this is a test!! this is a test!! this is a test!! this is a test!!')
	end)
	timer.Simple(1.5, function()
		rp.FlashNotify('Test3', 'this is a test!! this is a test!! this is a test!! this is a test!! this is a test!! this is a test!! this is a test!! this is a test!! this is a test!!')
	end)
	timer.Simple(2, function()
		rp.FlashNotify('Test4', 'this is a test!! this is a test!! this is a test!! this is a test!! this is a test!! this is a test!! this is a test!! this is a test!! this is a test!!')
	end)
	timer.Simple(2.5, function()
		rp.FlashNotify('Test5', 'this is a test!! this is a test!! this is a test!! this is a test!! this is a test!! this is a test!! this is a test!! this is a test!! this is a test!!')
	end)
end)
