surface.CreateFont('rp.Scoreboard.Label', {
	font = 'Prototype [RUS by Daymarius]',
	size = 14,
	weight = 250,
	extended = true
})


local PANEL = {}

function PANEL:Init()
	self:SetVisible(false)

	-- Size logic YES
	local w = ScrW() * 0.9
	local h = w * 0.625

	-- fuck your small screens you dirty niggers
	if (h > ScrH() * 0.9) then
		h = ScrH() * 0.9
		w = h * 1.6
	end

	self:SetSize(w, h)

	self.PlayerRows = {}

	self.PlayerList = ui.Create('ui_scrollpanel', self)
	self.PlayerList.PerformLayout = function(self)
		local canvas = self:GetCanvas()

		if (canvas:GetWide() ~= self:GetWide()) then
			canvas:SetWide(self:GetWide())
		end

		local y = 0
		local sorted = {}

		for i = 1, #rp.teams do
			sorted[i] = {}
		end

		for k, v in pairs(self:GetParent().PlayerRows) do
			if IsValid(k) and sorted[k:GetJob()] then
				table.insert(sorted[k:GetJob()], v)
			end
		end

		for _, t in ipairs(sorted) do
			table.sort(t, function (a, b) return a.Player:Name():lower() < b.Player:Name():lower() end)
			for k, v in ipairs(t) do
				local childY = y + self.SpaceTop
				if (v.x ~= self.Padding or v.y ~= childY) then
					v:SetPos(self.Padding, y + self.SpaceTop)
				end
				v.y = childY
				if (v:GetWide() ~= self:GetWide() - self.Padding * 2) then
					v:SetWide(self:GetWide() - self.Padding * 2)
				end

				y = y + v:GetTall() - 1
			end
		end
		y = math.Clamp(y - self.SpaceTop, 0, math.huge)
		canvas:SetTall(y)

		if (canvas:GetTall() <= self:GetTall()) then
			canvas:SetTall(self:GetTall())

			self.scrollBar:SetVisible(false)
		else
			self.scrollBar:SetVisible(true)
		end

		local maxOffset = (self:GetCanvas():GetTall() - self:GetTall())

		if (self.yOffset > maxOffset) then
			self.yOffset = maxOffset
		end

		if (self.yOffset < 0) then
			self.yOffset = 0
		end

		canvas:SetPos(0, -self.yOffset)

		self.scrollBar:InvalidateLayout()
	end
	self.PlayerList.Paint = function(self, w, h) end

	self.LogoButton = ui.Create('DButton', self)
	self.LogoButton:SetText('')
	self.LogoButton.Paint = function() end
	self.LogoButton.DoClick = function()
		gui.OpenURL('https://gmodhub.com')
	end
end

function PANEL:PerformLayout()
	local w, h = math.ceil(self:GetWide() * 0.9703125), math.ceil(self:GetTall() * 0.95)
	self.PlayerList:SetSize(w, h)

	local x, y = math.ceil(self:GetWide() - w)/2, math.ceil((self:GetTall() - h) - (self:GetTall() * 0.025))
	self.PlayerList:SetPos(x, 20)
	self.PlayerList:SetPadding(-1)

	self.LogoButton:SetPos(self:GetWide()/2 - 75, 40)
	self.LogoButton:SetSize(150, 175)
end

function PANEL:Open()
	self.StartAnim = SysTime()
	self.StartY = self.ActualY or -self:GetTall()
	self.EndY = (ScrH() - self:GetTall()) * 0.5
	self.ActualY = self.StartY
	self.Opening = true

	self:SetVisible(true)
end

function PANEL:Close()
	self.StartAnim = SysTime()
	self.StartY = self.ActualY or 0
	self.EndY = -self:GetTall()
	self.ActualY = self.StartY
	self.Opening = false
end

function PANEL:Update()
	local players = player.GetAll()
	local total_players, active_players, total_staff, active_staff = player.GetCount(), 0, 0, 0
	for k, v in ipairs(players) do
		if v:IsAdmin() then
			total_staff = total_staff + 1
		end
		if v:Alive() or (v:Team() ~= 1) then
			active_players = active_players + 1
			if v:IsAdmin() then
				active_staff = active_staff + 1
			end
		end
		if (not self.PlayerRows[v]) then
			local row = ui.Create('rp_scoreboard_player')
			row:SetPlayer(v)
			self.PlayerList:AddItem(row)
			self.PlayerRows[v] = row
		end
	end
	for k, v in pairs(self.PlayerRows) do
		if (not IsValid(k)) then
			v:Remove()
			self.PlayerRows[k] = nil
		else
			self.PlayerRows[k]:Update()
		end
	end

	local ponline = 'Players online: ' ..  total_players
	if (LocalPlayer():IsAdmin()) then
		ponline = ponline .. ' (' .. active_players .. ' Active) | Staff Online:' .. total_staff .. ' (' .. active_staff .. ' Active)'
	end

	self.LabelPlayers = ponline
	surface.SetFont('rp.Scoreboard.Label')
	self.LabelPlayersPos = self:GetWide() - surface.GetTextSize(self.LabelPlayers) - 20

	self.LabelYPos = self:GetTall() - ((self:GetTall() * 0.01484375) * 1.5)

	local hours = math.floor(CurTime() / 3600)
	local minutes = math.floor((CurTime() % 3600) / 60)
	local seconds = math.floor(CurTime() - (hours * 3600) - (minutes * 60))
	if (minutes < 10) then minutes = '0' .. minutes end
	if (seconds < 10) then seconds = '0' .. seconds end
	self.LabelUptime = 'Время работы сервера: ' .. hours .. ':' .. minutes .. ':' .. seconds
end

function PANEL:Think()
	if self:IsVisible() then
		self:MoveToFront()

		if (not self.NextThink) or (self.NextThink < CurTime()) then
			self:Update()
			self.NextThink = CurTime() + 1
		end

		local mul = self.Opening and
			(math.sin(math.Clamp((SysTime() - self.StartAnim) / .5, 0, 1) * (math.pi / 1.42)) * 1.25)
		or
			(1 - math.sin((math.Clamp((SysTime() - self.StartAnim) / .3, 0, 1) - 2.42) * (math.pi / 1.42)) * 1.25)

		self.ActualY = self.StartY + mul * (self.EndY - self.StartY)
		self:SetPos((ScrW() - self:GetWide()) * 0.5, self.ActualY)

		if (!self.Opening and math.Round(mul) == 1) then self:SetVisible(false) end
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(0, 0, 0, 120)
	surface.DrawTexturedRect(0, 0, w, h)

	surface.SetFont('rp.Scoreboard.Label')
	surface.SetTextColor(ui.col.OffWhite)

	surface.SetTextPos(20, self.LabelYPos)
	surface.DrawText(self.LabelUptime)

	surface.SetTextPos(self.LabelPlayersPos, self.LabelYPos)
	surface.DrawText(self.LabelPlayers)
end

vgui.Register('rp_scoreboard', PANEL, 'EditablePanel')
