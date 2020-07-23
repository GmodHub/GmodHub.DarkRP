local PANEL = {}

local micon = Material('gmh/gui/scoreboard/micon.png', 'smooth')
local micoff = Material('gmh/gui/scoreboard/micoff.png', 'smooth')

function PANEL:Init()
	self:SetTall(25)
	self:SetText ''

	self.Avatar = ui.Create('ui_avatarbutton', self)

	self.Mute = ui.Create('DImageButton', self)
	self.Mute:SetMaterial(micon)
	self.Mute:SetColor(ui.col.White)
	self.Mute.DoClick = function()
		if (self.Player == LocalPlayer()) then return end

		self.Player:Block(!self.Player:IsBlocked())
		if !self.Player:IsBlocked() then
			self.Mute:SetMaterial(micon)
			LocalPlayer():ChatPrint(self.Player:Name() .. ' был разблокирован для вас.')
		else
			self.Mute:SetMaterial(micoff)
			LocalPlayer():ChatPrint(self.Player:Name() .. ' был заблокирован для вас.')
		end
	end

	self.InfoCard = ui.Create('rp_scoreboard_playerinfo', self)
end

function PANEL:PerformLayout()
	self.Avatar:SetPos(1, 1)
 	self.Avatar:SetSize(23, 23)

	self.Mute:SetPos(self:GetWide() - 22, 3)
	self.Mute:SetSize(18, 18)

	self.InfoCard:SetPos(2, 25)
	self.InfoCard:SetSize(self:GetWide() - 4, self:GetTall() - 27)

	self:Update()
end

function PANEL:DoClick()
	if self.Open then
		self.TargetHeight = 25
		self.Open = nil
	else
		self.TargetHeight = 145
		self.Open = true
	end
end

function PANEL:Think()
	if (self.TargetHeight and self:GetTall() ~= self.TargetHeight) then
		local tall = self:GetTall()
		local mul = tall > self.TargetHeight and -1 or 1

		tall = tall + FrameTime() * (tall - self.TargetHeight * -mul) * 3 * mul
		if (math.abs(tall - self.TargetHeight) < 1) then
			tall = self.TargetHeight
			if (self.TargetHeight == 145) then
				self.TargetHeight = 135
			else
				self.TargetHeight = nil
			end
		end
		self:SetTall(tall)
		rp.Scoreboard.PlayerList:InvalidateLayout()
	end
end

function PANEL:Update()
	if (not IsValid(self.Player)) then return end

	local w = self:GetWide()

	self.PlayerColor 	= self.Player:GetJobColor()

	local badgeimg 		= (self.Player:IsRoot() and 'icon16/tux.png') or (self.Player:IsGA() and 'icon16/world.png') or (self.Player:IsSA() and 'icon16/shield_add.png') or (self.Player:IsAdmin() and 'icon16/shield.png') or (self.Player:IsVIP() and 'icon16/star.png') or 'icon16/user.png'
	self.RankMaterial 	= Material(badgeimg)

	self.PlayerName = ((self.Player:GetNickName() and self.Player:GetNickName() ~= '') and (self.Player:Name() .. ' (' .. self.Player:GetNickName() .. ')') or self.Player:Name())

	if (not self.Player:Alive()) and LocalPlayer():IsAdmin() then
		self.PlayerNameSize = surface.GetTextSize(self.PlayerName)
		self.DrawName = self.DrawNameDead
	elseif self.Player:IsWanted() then
		self.DrawName = self.DrawNameWanted
	else
		self.DrawName = self.DrawNameNormal
	end

	surface.SetFont('ui.18')

	self.JobName 		= self.Player:GetJobName()
	self.JobNamePos 	= (w * 0.33)

	self.TimePlayed 	= ba.str.FormatTime(self.Player:GetPlayTime()) .. ' (' .. self.Player:GetPlayTimeRank() .. ')'
	self.TimePlayedPos 	= (w * 0.66)

	local ping = self.Player:Ping()
	if (ping > 300) then
		self.DrawPing 	= self.DrawOneBar
	elseif (ping < 300) and (ping > 125) then
		self.DrawPing = self.DrawTwoBar
	else
		self.DrawPing = self.DrawThreeBar
	end

	self.BarHeight1 = (25 * 0.7)
	self.BarPos1	= (25 * 0.3) - 1
	self.BarHeight2 = (25 * 0.4)
	self.BarPos2	= (25 * 0.6) - 2

	self.InfoCard:Update()
end

local ccmat = Material 'gmh/flags/us.png'
function PANEL:SetPlayer(pl)
	self.Player = pl
	self.Avatar:SetPlayer(pl)
	self.Mute:SetMaterial(pl:IsBlocked() and micoff or micon)
	self.InfoCard:SetPlayer(pl)

	local cc = pl:GetCountry()
	local matname = 'FLAG_' ..  cc

	if texture.Get(matname) then
		self.CountryMaterial = texture.Get(matname)
	else
		self.CountryMaterial =  ccmat
		texture.Create(matname)
			:EnableProxy(false)
			:Download('http://cdn.superiorservers.co/rp/flags/' .. cc .. '.png', function(s, material)
				if IsValid(self) then
					self.CountryMaterial = material
				end
			end)
	end

	local osimg = (pl:GetOS() == 'linux' and 'icon16/tux.png') or 'gmh/gui/os/' .. pl:GetOS() .. '.png'
	self.OSMaterial = Material(osimg)

	self:Update()
end

function PANEL:DrawNameNormal()
	surface.SetTextColor(255, 255, 255, 255)
	surface.DrawText(self.PlayerName)
end

function PANEL:DrawNameWanted()
	surface.SetTextColor(255, math.sin(CurTime() * math.pi) * 255, math.sin(CurTime() * math.pi) * 255, 255)
	surface.DrawText(self.PlayerName)
end

function PANEL:DrawNameDead()
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(101, 12.5, self.PlayerNameSize, 1)

	surface.SetTextColor(0, 0, 0, 255)
	surface.DrawText(self.PlayerName)
end

function PANEL:DrawOneBar(w, h)
	draw.Box(w - 46, self.BarHeight1, 5, self.BarPos1, ui.col.Red)
end

function PANEL:DrawTwoBar(w, h)
	draw.Box(w - 46, self.BarHeight1, 5, self.BarPos1, ui.col.Orange)
	draw.Box(w - 39, self.BarHeight2, 5, self.BarPos2, ui.col.Orange)
end

function PANEL:DrawThreeBar(w, h)
	draw.Box(w - 46, self.BarHeight1, 5, self.BarPos1, ui.col.Green)
	draw.Box(w - 39, self.BarHeight2, 5, self.BarPos2, ui.col.Green)
	draw.Box(w - 32, 2, 5, h - 4, ui.col.Green)
end

local texure_grad 	= surface.GetTextureID 'gui/center_gradient'
local color_grad 	= Color(200,200,200,100)
local color_spacer 	= Color(50,50,50,100)
function PANEL:Paint(w, h)
	draw.Box(0, 0, w, h, self.PlayerColor)

	-- Icons
	--draw.Box(0, 0, 98, h - 1, ui.col.FlatBlack)

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(self.RankMaterial)
	surface.DrawTexturedRect(27, 4, 16, 16)

	if self.CountryMaterial then
		surface.SetMaterial(self.CountryMaterial)
		surface.DrawTexturedRect(49, 0, 24, 24)
	end

	surface.SetMaterial(self.OSMaterial)
	surface.DrawTexturedRect(78, 4, 16, 16)

	-- Gradient
	surface.SetTexture(texure_grad)
	surface.SetDrawColor(color_grad)
	surface.DrawTexturedRect(0, 0, w, 25)

	-- Spacers
	surface.SetDrawColor(color_spacer)
	surface.DrawOutlinedRect(1, 0, w - 2 , 25)
	surface.DrawLine(25, 0, 25, 25)
	surface.DrawLine(45, 0, 45, 25)
	surface.DrawLine(76, 0, 76, 25)
	surface.DrawLine(96, 0, 96, 25)

	-- Player Info
	surface.SetFont('ui.18')
	surface.SetTextPos(101, 3)
	self:DrawName()

	surface.SetTextColor(255, 255, 255, 255)
	surface.SetTextPos(self.JobNamePos, 3)
	surface.DrawText(self.JobName)

	surface.SetTextPos(self.TimePlayedPos, 3)
	surface.DrawText(self.TimePlayed)

	-- Ping & Mute
	--draw.Box(w - 49, 0, 50, h - 1, ui.col.FlatBlack)

	self:DrawPing(w, 25)
end

vgui.Register('rp_scoreboard_player', PANEL, 'DButton')
