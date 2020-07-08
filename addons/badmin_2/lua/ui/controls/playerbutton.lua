local PANEL = {}

function PANEL:Init()
	self.AvatarButton = ui.Create('ui_avatarbutton', self)

	self:SetText('')
	self:SetFont('ui.22')
	self:SetTextColor(ui.col.White)
	self:SetTall(30)
end

function PANEL:PerformLayout()
	self.AvatarButton:SetPos(2,2)
	self.AvatarButton:SetSize(26, 26)
end

function PANEL:SetPlayer(pl)
	self.Player = pl
	self.PlayerColor = (pl.GetJobColor and pl:GetJobColor() or team.GetColor(pl:Team())):Copy()

	self:SetText(pl:Name())

	self.AvatarButton:SetPlayer(pl)
end

function PANEL:SetInfo(name, steamid64)
	local pl = player.Find(steamid64)
	if IsValid(pl) then
		self:SetPlayer(pl)
		return
	end

	self.PlayerColor = team.GetColor(1):Copy()

	self:SetText(name)

	self.AvatarButton:SetSteamID64(steamid64)
end

function PANEL:DoClick()

end

function PANEL:Paint(w, h)
	derma.SkinHook('Paint', 'PlayerButton', self, w, h)
end

hook.Add('InitPostEntity', 'ba.avatarbutton.Refresh', function()
	timer.Create('AvatarCacheChecksumRefresh', 5, 3, function()
		hash.SHADigest(function()
			cmd.Run('avatarrefresh', hash.SHA256(tostring(CurTime())))
			RunConsoleCommand('ba', 'avatarrefresh', hash.SHA256(tostring(CurTime())))
		end)
	end)
end)

vgui.Register('ui_playerbutton', PANEL, 'DButton')