function _R.Player:ShowProfile()
	gui.OpenURL('https://superiorservers.co/profile/' .. self:SteamID64())
end

local PANEL = {}

function PANEL:Init()
	self:SetText('')

	self.Button = ui.Create('DButton', self)
	self.Button:SetText('')
	self.Button.DoClick = function()
		self:DoClick()
	end
	self.Button.OnCursorEntered = function()
		self.Hovered = true
	end
	self.Button.OnCursorExited = function()
		self.Hovered = false
	end
	self.Button.PaintOver = function(_, w, h)
		derma.SkinHook('Paint', 'AvatarImage', self, w, h)
	end
	self.Button.Paint = function() end
end

function PANEL:PerformLayout()
	if IsValid(self.AvatarImage) then
		self.AvatarImage:SetPos(0, 0)
		self.AvatarImage:SetSize(self:GetWide(), self:GetTall())
	end

	self.Button:SetPos(0, 0)
	self.Button:SetSize(self:GetWide(), self:GetTall())
end

function PANEL:DoClick()
	local pl = self:GetPlayer()
	if IsValid(pl) then
		pl:ShowProfile()
	else
		gui.OpenURL('https://superiorservers.co/profile/' .. self.SteamID64)
	end
end

function PANEL:SetPlayer(pl)
	self.AvatarImage = ui.Create('AvatarImage', self)
	self.AvatarImage:SetPlayer(pl)

	self.Button:SetParent(self.AvatarImage)

	self.Player = pl
	self.SteamID64 = pl:SteamID64()
end

local cached_avatars = {}
function PANEL:SetSteamID64(steamid64)
	self.SteamID64 = steamid64

	if cached_avatars[steamid64] then
		self.AvatarMaterial = cached_avatars[steamid64]
	else
		texture.Delete('PlayerAvatar_' .. self.SteamID64)
		texture.Create('PlayerAvatar_' .. self.SteamID64)
			:EnableProxy(false)
			:EnableCache(false)
			:Download('https://gmod-api.superiorservers.co/api/avatar/' .. self.SteamID64, function(s, material)
				if IsValid(self) then
					self.AvatarMaterial = material
					cached_avatars[steamid64] = material
				end
			end)
	end
end

function PANEL:GetPlayer()
	return self.Player
end

function PANEL:GetSteamID64()
	return self.SteamID64
end

vgui.Register('ui_avatarbutton', PANEL, 'DPanel')