function _R.Player:ShowProfile()
	gui.OpenURL('https://gmodhub.com/profile/' .. self:SteamID64())
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
		derma.SkinHook('Paint', 'ImageButton', self, w, h)
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
	elseif self:GetSteamID64() then
		gui.OpenURL('https://gmodhub.com/profile/' .. self.SteamID64)
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

	self:SetURL('https://gmodhub.com/api/avatar/' .. self.SteamID64, false)
end

local cachedImages = {}
function PANEL:SetURL(url, proxy)
	self.Url = url

	if cachedImages[url] then
		self.Material = cachedImages[url]
	else
		texture.Delete('ImageButton_' .. url)
		texture.Create('ImageButton_' .. url)
			:EnableProxy(proxy)
			:EnableCache(false)
			:Download(url, function(s, material)
				if IsValid(self) then
					self.Material = material
					cachedImages[url] = material
				end
			end)
	end
end

function PANEL:SetMaterial(mat)
	self.Material = mat
end

function PANEL:GetPlayer()
	return self.Player
end

function PANEL:GetSteamID64()
	return self.SteamID64
end

function PANEL:GetURL()
	return self.Url
end

vgui.Register('ui_imagebutton', PANEL, 'DPanel')