local mat_checked = Material 'gmh/ui/check.png'
local mat_unchecked = Material 'gmh/ui/x.png'

local PANEL = {}

function PANEL:Init()
	self.Title = ui.Create('DLabel', self)

	self.Label = ui.Create('DLabel', self)

	self.Button = ui.Create('DButton', self)
	self.Button.DoClick = function(s)
		if self.IsChecked and (not self.IsClaimed) then
			net.Start 'ba.rewards.Claim'
				net.WriteString(self.ClaimType)
			net.SendToServer()

			self.IsClaimed = true
		else
			self:DoClick()
		end
	end
	self.Button.Think = function(s)
		s:SetDisabled(self.IsChecked and self.IsClaimed)

		if (not self.IsClaimed) and self.IsChecked then
			s:SetText('Бонус')
		else
			s:SetText(self.IsChecked and '✗' or '✓')
		end
	end

	self:SetTall(50)
end

function PANEL:ApplySchemeSettings()
	self.Title:SetFont('ui.22')
	self.Label:SetFont('ui.18')
end

function PANEL:PerformLayout(w, h)
	self.Title:SizeToContents()
	self.Title:SetPos((self:GetWide() * 0.5) - (self.Title:GetWide() * 0.5), 5)

	self.Label:SizeToContents()
	self.Label:SetPos((self:GetWide() * 0.5) - (self.Label:GetWide() * 0.5), 27.5)

	self.Button:SetSize(h, h)
	self.Button:SetPos(self:GetWide() - self.Button:GetWide(), 0)
end

function PANEL:Paint(w, h)
	draw.OutlinedBox(0, 0, w, h, ui.col.Background, ui.col.Outline)

	draw.OutlinedBox(0, 0, h, h, ui.col.FlatBlack, ui.col.Outline)

	surface.SetDrawColor(self.IsChecked and ui.col.Green or ui.col.Red)
	surface.SetMaterial(self.IsChecked and mat_checked or mat_unchecked)

	local s = h - 10
	surface.DrawTexturedRect(5, 5, s, s)
end

function PANEL:SetTitle(title)
	self.Title:SetText(title)
end

function PANEL:SetValue(desc)
	self.Label:SetText(desc)
end

function PANEL:DoClick()
end

vgui.Register('ui_reawrd_check', PANEL, 'Panel')


local PANEL = {}
local paneldata = {}

local name = PLAYER.SteamName or PLAYER.Name
function PANEL:Init()
	self.SteamGroup = ui.Create('ui_reawrd_check', self)
	self.SteamGroup:SetTitle('Steam - 150 Кредитов')
	self.SteamGroup:SetValue('Вступить в нашу группу в Steam')
	self.SteamGroup.ClaimType = 'award_steam'
	self.SteamGroup.IsChecked = paneldata.award_steam
	self.SteamGroup.IsClaimed = paneldata.award_steam_claimed
	self.SteamGroup.DoClick = function()
		self.HasDoneOne = true
		gui.OpenURL('https://steamcommunity.com/gid/103582791467798968/')
	end

	self.Forums = ui.Create('ui_reawrd_check', self)
	self.Forums:SetTitle('VK - 150 Кредитов')
	self.Forums:SetValue('Вступить в нашу группу в VK')
	self.Forums.ClaimType = 'award_forums'
	self.Forums.IsChecked = paneldata.award_forums
	self.Forums.IsClaimed = paneldata.award_forums_claimed
	self.Forums.DoClick = function()
		self.HasDoneOne = true
		gui.OpenURL('https://vk.com/gmdhub')
	end

	self.SyncTS = ui.Create('ui_reawrd_check', self)
	self.SyncTS:SetTitle('Discord - 150 Кредитов')
	self.SyncTS:SetValue('Вступить в наш дискорд сервер')
	self.SyncTS.ClaimType = 'award_teamspeak'
	self.SyncTS.IsChecked = paneldata.award_teamspeak
	self.SyncTS.IsClaimed = paneldata.award_teamspeak_claimed
	self.SyncTS.DoClick = function()
		self.HasDoneOne = true
		ui.Create('ui_frame', function(self)
			self:SetTitle('Sync TeamSpeak')
			self:SetWide(550)
			self:Center()
			self:MakePopup()
			ui.Create('ui_teamspeak_sync', function(self, p)
				local x, y = p:GetDockPos()
				self:SetPos(x, y)
				self:SetWide(p:GetWide() - 10)
				p:SetTall(y + self:GetTall())
				p:Focus()
			end, self)
		end)
	end

	self.SteamName = ui.Create('ui_reawrd_check', self)
	self.SteamName:SetTitle('Имя Steam - 5 Кредитов в день')
	self.SteamName:SetValue('Добавьте \'gmodhub.com\' в имя Steam')
	self.SteamName.ClaimType = 'award_name'
	self.SteamName.IsClaimed = paneldata.award_name_claimed
	self.SteamName.Think = function(s)
		s.IsChecked = (string.find(name(LocalPlayer()):lower(), 'gmodhub.com') ~= nil) or (string.find(name(LocalPlayer()):lower(), 'gmodhub') ~= nil)
	end
	self.SteamName.DoClick = function()
		self.HasDoneOne = true
		gui.OpenURL('https://steamcommunity.com/profiles/' .. LocalPlayer():SteamID64() .. '/edit')
	end
end

function PANEL:PerformLayout()
	local w, x = 400

	self.SteamGroup:SetPos(0, 0)
	self.SteamGroup:SetWide(w)

	self.Forums:SetPos(0, 49)
	self.Forums:SetWide(w)

	self.SyncTS:SetPos(0, 98)
	self.SyncTS:SetWide(w)

	self.SteamName:SetPos(0, 147)
	self.SteamName:SetWide(w)
end

function PANEL:OnRemove()
	if self.HasDoneOne then
		timer.Simple(300, function()
			http.Fetch('https://gmod-api.superiorservers.co/api/rewards/' .. LocalPlayer():SteamID64())
		end)
	end
end

vgui.Register('ui_reward_panel', PANEL, 'Panel')


hook.Add('ba.GetLoadInElements', 'ba.rewards.LoadIn', function(self)
	http.Fetch('https://gmod-api.superiorservers.co/api/rewards/' .. LocalPlayer():SteamID64(), function(body)
		local data = util.JSONToTable(body)
		if data then
			paneldata = data
		end

		if IsValid(self) then
			local x, y = self:GetSize()

			local panels = ui.Create('ui_reward_panel', function(s, p)
				s:SetSize(400, (4 * 49) + 2)
				s:SetPos((p:GetWide() * 0.5) + 7.5, p:GetTall() - (s:GetTall() + 125))
			end, self)

			local x, y = panels:GetPos()
			local w, h = panels:GetSize()

			ui.Create('DButton', function(s, p)
				s:SetText('Получить Бесплатные Кредиты')
				s:SetDisabled(true)
				s:SetSize(w, 30)
				s:SetPos(x, y - 29)
			end, self)
		end
	end, function(error)
		print(error)
	end)
end)
