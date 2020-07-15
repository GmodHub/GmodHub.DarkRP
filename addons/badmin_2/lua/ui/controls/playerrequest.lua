local PANEL = {}

function PANEL:Init()
	self.Players = player.GetAll()

	self.SearchBar = ui.Create('DTextEntry', self)
	self.SearchBar:RequestFocus()
	self.SearchBar:SetPlaceholderText('Поиск...')
	self.SearchBar.OnChange = function(s)
		self.PlayerList:AddPlayers(s:GetValue())
	end

	self.PlayerList = ui.Create('ui_listview', self)
	self.PlayerList.AddPlayers = function(s, inf)
		inf = inf and inf:Trim()

		s:Reset()

		local count = 0
		for k, v in ipairs(self.Players) do
			if IsValid(v) and (v ~= LocalPlayer()) then
				if (not inf) or (inf and string.find(v:Name():lower(), inf:lower(), 1, true) or (v:SteamID() == inf) or (v:SteamID64() == inf)) then
					s:AddPlayer(v).DoClick = function(row) self:OnSelection(row, v) end
					count = count + 1
				end
			end
		end

		if (count <= 0) then
			s:AddSpacer('No players found!')
		end
	end

	self.PlayerList:AddPlayers()
end

function PANEL:PerformLayout()
	self.SearchBar:SetPos(0, 0)
	self.SearchBar:SetSize(self:GetWide(), 25)

	self.PlayerList:SetPos(0, 30)
	self.PlayerList:SetSize(self:GetWide(), self:GetTall() - 30)
end

function PANEL:SetPlayers(pls)
	self.Players = pls
	self.PlayerList:AddPlayers()
end

function PANEL:OnSelection(row, pl)

end

function PANEL:DockToFrame()
	local p = self:GetParent()
	local x, y = p:GetDockPos()
	self:SetPos(x, y)
	self:SetSize(p:GetWide() - 10, p:GetTall() - (y + 5))
end

vgui.Register('ui_playerrequest', PANEL, 'Panel')
