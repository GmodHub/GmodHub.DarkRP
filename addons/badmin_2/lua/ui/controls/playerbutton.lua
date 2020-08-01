local PANEL = {}

function PANEL:Init()
	self.ImageButton = ui.Create('ui_imagebutton', self)

	self:SetText('')
	self:SetFont('ui.22')
	self:SetTextColor(ui.col.White)
	self:SetTall(30)
end

function PANEL:PerformLayout()
	self.ImageButton:SetPos(2,2)
	self.ImageButton:SetSize(26, 26)
end

function PANEL:SetPlayer(plOrName, steamid64)
	local pl = isplayer(plOrName) and plOrName or player.Find(steamid64)

	if isplayer(pl) then
		self.Player = pl
		self:SetColor((pl.GetJobColor and pl:GetJobColor() or team.GetColor(pl:Team())):Copy())

		self:SetText(pl:Name())

		self.ImageButton:SetPlayer(pl)
	else
		self:SetText(plOrName)
		self:SetColor(team.GetColor(1):Copy())

		self.ImageButton:SetSteamID64(steamid64)
	end
end

function PANEL:SetMaterial(mat)
	self.ImageButton:SetMaterial(mat)
end

function PANEL:SetColor(col)
	self.BackgroundColor = col
end

function PANEL:GetPlayer()
	return self.Player
end

function PANEL:DoClick()

end

function PANEL:Paint(w, h)
	derma.SkinHook('Paint', 'ImageRow', self, w, h)
end

hook.Add('InitPostEntity', 'ba.avatarbutton.Refresh', function()
	timer.Create('AvatarCacheChecksumRefresh', 5, 3, function()
		hash.SHADigest(function()
			cmd.Run('avatarrefresh', hash.SHA256(tostring(CurTime())))
			RunConsoleCommand('ba', 'avatarrefresh', hash.SHA256(tostring(CurTime())))
		end)
	end)
end)

vgui.Register('ui_imagerow', PANEL, 'DButton')