cvar.Register 'player_nicknames'
	:SetDefault('')
	:SetEncrypted()

function PLAYER:SetNickName(name)
	local cv = cvar.Get('player_nicknames')
	cv:AddMetadata(self:SteamID(), name)
	cv:Save()
end

function PLAYER:GetNickName()
	return cvar.Get('player_nicknames'):GetMetadata(self:SteamID())
end

local PANEL = {}

function PANEL:Init()
	self.Rank = ui.Create('DButton', self)
	self.Rank:SetDisabled(true)

	self.PlayTime = ui.Create('DButton', self)
	self.PlayTime:SetDisabled(true)

	self.Org = ui.Create('DButton', self)
	self.Org:SetDisabled(true)

	self.Nickname = ui.Create('DButton', self)
	self.Nickname:SetText('Изменить Никнейм')
	self.Nickname.DoClick = function()
		ui.StringRequest('Никнейм', 'Какой никнейм ' .. self.Player:Name() .. ' вы хотели бы видеть?', '', function(a)
			self.Player:SetNickName(a)
		end)
	end

	self.Steam = ui.Create('DButton', self)
	self.Steam:SetText('GMDHUB Профиль')
	self.Steam.DoClick = function()
		//self.Player:ShowProfile()
	end

	self.SteamID = ui.Create('DButton', self)
	self.SteamID.DoClick = function()
		SetClipboardText(self.Player:SteamID())

		self.SteamID.Copied = true
		self.SteamID:SetText('Скопировано в буфер обмена')

		timer.Simple(2.5, function()
			if IsValid(self) and IsValid(self.SteamID) then
				self.SteamID.Copied = nil
			end
		end)
	end

	self.GiftCredits = ui.Create('DButton', self)
	self.GiftCredits:SetText((self.Player == LocalPlayer()) and 'Приобрести Кредиты' or 'Подарить Кредиты')
	self.GiftCredits.DoClick = function()
		if IsValid(self.Player) then
			gui.OpenURL(rp.cfg.CreditsURL .. self.Player:SteamID())
			GAMEMODE:ScoreboardHide()
		end
	end
end

function PANEL:PerformLayout()
	local w, h = ((self:GetWide()/3) - 155), (self:GetTall()/3) - 3

	if (not self.SteamID.Copied) then
		if IsValid(self.Player) then
			self.SteamID:SetText(self.Player:SteamID())
		end
	end

	self.Rank:SetPos(2, 2)
	self.Rank:SetSize(w, h)

	self.PlayTime:SetPos(2, h + 4)
	self.PlayTime:SetSize(w, h)

	self.Org:SetPos(2, (h * 2) + 6)
	self.Org:SetSize(w, h)

	self.Nickname:SetSize(w, h)
	self.Nickname:SetPos(w + 4, 2)

	self.Steam:SetSize(w, h)
	self.Steam:SetPos(w + 4, h + 4)

	self.SteamID:SetSize(w, h)
	self.SteamID:SetPos(w + 4, h * 2 + 6)

	self.GiftCredits:SetSize(w, h)
	self.GiftCredits:SetPos((w + 4) * 2, 2)
end

function PANEL:Update()
	if (not IsValid(self.Player)) or (self:GetParent():GetTall() <= 25) then return end

	self.Rank:SetText('Ранг: ' .. self.Player:GetUserGroup())

	self.PlayTime:SetText('Отыграно: ' .. ba.str.FormatTime(self.Player:GetPlayTime()) .. ' (' .. self.Player:GetPlayTimeRank() .. ')')

	self.Org:SetText('Банда: ' .. (self.Player:GetOrg() and self.Player:GetOrg() or 'Отсутствует'))
end

function PANEL:SetPlayer(pl)
	self.Player = pl

	self:Update()
end

function PANEL:Paint(w, h)
	draw.Box(0, 0, w, h, ui.col.OffWhite)

	local org = self.Player:GetOrg()
	local banner = (IsValid(self.Player) and org) and rp.orgs.GetBanner(org)

	if org and banner then
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(banner)
		local size = h - 10
		surface.DrawTexturedRect(w - size - 5, 5, size, size)
	end
end

vgui.Register('rp_scoreboard_playerinfo', PANEL, 'Panel')
