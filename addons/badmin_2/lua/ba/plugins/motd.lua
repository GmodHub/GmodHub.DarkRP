-------------------------------------------------
-- MoTD
-------------------------------------------------
ba.AddCommand 'MoTD'
:RunOnClient(function(args)
	ba.OpenMoTD()
end)
:SetHelp 'Opens the rules of the server'
:AddAlias 'rules'

-------------------------------------------------
-- SetMoTD
-------------------------------------------------
term.Add('MOTDSet', 'MoTD изменено на "#".')
term.Add('FAQSet', 'FAW изменён на "#".')

ba.AddCommand('SetMoTD', function(pl, url)
	ba.svar.Set('motd', url)
	ba.notify(pl, term.Get('MOTDSet'), url)
end)
:AddParam(cmd.STRING)
:SetFlag '*'
:SetHelp 'Sets the MoTD URL for the server'

-------------------------------------------------
-- Staff MoTD
-------------------------------------------------
ba.AddCommand 'SMoTD'
:RunOnClient(function(args)
	gui.OpenURL(ba.svar.Get('smotd'))
end)
:SetHelp 'Opens the staff MoTD'

-------------------------------------------------
-- SetSMoTD
-------------------------------------------------
ba.AddCommand('SetSMoTD', function(pl, url)
	ba.svar.Set('smotd', url)
end)
:AddParam(cmd.STRING)
:SetFlag '*'
:SetHelp 'Sets the SMoTD URL for the server'


if (SERVER) then
	ba.svar.Create('motd', nil, true)
	ba.svar.Create('smotd', nil, true)

	resource.AddFile 'resource/fonts/Michroma.ttf'
	resource.AddFile 'materials/gmh/gui/loading.vmt'
	return
end

surface.CreateFont('ba.LoadIn', {
	font = 'Prototype [RUS by Daymarius]',
	size = 30,
	weight = 600,
	antialias = true,
	extended = true
})

cvar.Register('ba_has_read_motd')
	:SetDefault(false, true)

local messages = {
	'Загрузка...',
	'Загрузка Информации Об Игроке',
	'Инициализация Сети',
	'Получение Информации',
	'Проверка Пакетов',
	'Готово'
}

local PANEL = {}
function PANEL:Init()
	texture.Create('SUP_Background')
		:EnableProxy(false)
		:Download('https://gmodhub.com/static/images/bg_gmod.png', function(s, material)
			if IsValid(self) then
				self.BackgroundMaterial = material
			end
		end)
	texture.Create('SUP_Background')
		:EnableProxy(false)
		:Download('https://gmodhub.com/static/images/favicon.png', function(s, material)
			if IsValid(self) then
				self.LogoMaterial = material
			end
		end)

	self.Text = {}
	self.Accent = true

	self:SetSize(ScrW(), ScrH())
	self:MakePopup()

	timer.Simple(2, function()
		local rep = 1
		timer.Create('ba.LoadInMessages', 0.75, #messages + 1, function()
			if (not IsValid(self)) then
				timer.Destroy('ba.LoadInMessages')
				return
			end

			table.insert(self.Text, 1, messages[rep])
			rep = rep + 1

			if (rep > (#messages + 1)) then
				self:AddButtons()

				self.Text = {
					'Добро пожаловать на GmodHub!',
					'Приятной игры.'
				}

				local alert = hook.Call('ba.GetLoadInAlerts')

				if (not alert) then return end

				self.Alerts = string.Wrap('ui.20', alert, self:GetWide())

				self.AlertHeader = ui.Create('DButton', function(s, p)
					s:SetSize(815, 30)
					s:SetPos((p:GetWide() * 0.5) - (s:GetWide() * 0.5), (p:GetTall() - 385) - (#self.Alerts * 22) - 10)
					s:SetText(#self.Alerts > 1 and 'Alerts:' or 'Alert')
					s.TextColor = ui.col.Red
					s:SetDisabled(true)
				end, self)
			end
		end)
	end)
end

function PANEL:AddButtons()
	self:SetSize(ScrW() * 0.9, ScrH() * 0.9)
	self:Center()

	self.RulesButton = ui.Create('DButton', self)
	self.RulesButton:SetText('Правила')
	self.RulesButton.fontset = true
	self.RulesButton:SetFont('ui.24')
	self.RulesButton.DoClick = function()
		ba.OpenMoTD()
	end

	self.CreditsButton = ui.Create('DButton', self)
	self.CreditsButton:SetText('Донат')
	self.CreditsButton.fontset = true
	self.CreditsButton:SetFont('ui.24')
	self.CreditsButton.DoClick = function()
		cmd.Run('upgrades')
	end

	self.CloseButton = ui.Create('DButton', self)
	self.CloseButton:SetText('Закрыть')
	self.CloseButton.fontset = true
	self.CloseButton:SetFont('ui.24')
	self.CloseButton.DoClick = function()
		self:Remove()

		hook.Call('PlayerCloseLoadInScreen')

		if ((LocalPlayer():GetPlayTime() or 0) < 100) or (not cvar.GetValue('ba_has_read_motd')) then
			ba.OpenMoTD()
		end
	end

	self.UpdateHeader = ui.Create('DButton', self)
	self.UpdateHeader:SetText('Последние Обновления')
	self.UpdateHeader:SetDisabled(true)

	self.UpdateButtons = {}

	http.Fetch('https://gmodhub.com/api/changelogs', function(body)
		local dat = util.JSONToTable(body)
		if dat then
			for k, v in ipairs(dat) do
				if (not IsValid(self)) then return end
				self.UpdateButtons[#self.UpdateButtons + 1] = ui.Create('DButton', function(s)
					s:SetText(v.Title)
					s.DoClick = function()
						gui.OpenURL(v.Url)
					end
					if ((os.time() - v.Start) < 259200) then
						s.TextColor = ui.col.Gold
						s:SetText('[НОВОЕ] ' .. v.Title)
					end
				end, self)
			end
		end
	end)

	hook.Call('ba.GetLoadInElements', nil, self)

	self:MakePopup()

	self.IsLoaded = true
end

function PANEL:PerformLayout(w, h)
	local c = w * 0.5

	if (not self.IsLoaded) then return end

	self.RulesButton:SetSize(400, 40)
	self.RulesButton:SetPos(c - 407.5, h - 110)

	self.CreditsButton:SetSize(400, 40)
	self.CreditsButton:SetPos(c + 7.5, h - 110)

	self.CloseButton:SetSize(150, 40)
	self.CloseButton:SetPos(c - 75, h - 55)

	local x, y = (w * 0.5) - 407.5, h - ((4 * 49) + 2) - 125

	self.UpdateHeader:SetSize(400, 30)
	self.UpdateHeader:SetPos(x, y - 29)

	for k, v in ipairs(self.UpdateButtons) do
		v:SetSize(400, 50)
		v:SetPos(x, y)

		y = y + 49
	end
end

local mat_loading = Material 'gmh/gui/loading'
function PANEL:Paint(w, h)
	if self.BackgroundMaterial then
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(self.BackgroundMaterial)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	local s = ((ScrH() < 850) and self.IsLoaded) and 128 or 256
	local spiny = self.IsLoaded and h * 0.25 or h * 0.26

	if self.LogoMaterial then
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(self.LogoMaterial)
		surface.DrawTexturedRect(w * 0.5 - (s * 0.5), spiny, s, s)
	end

	local x, y = w * 0.5, s + spiny
	for k, v in ipairs(self.Text) do
		local c = 255-k*255/10
		draw.SimpleText(v, 'ba.LoadIn', x, y, Color(c,c,c,255), TEXT_ALIGN_CENTER)
		y = y + 35
	end

	if self.Alerts and IsValid(self.AlertHeader) then
		x, y = self.AlertHeader:GetPos()

		draw.OutlinedBox(x, y + 24, self.AlertHeader:GetWide(), (#self.Alerts * 22) + 10, ui.col.Background, ui.col.Outline)

		y = y + 30
		for k, v in ipairs(self.Alerts) do
			draw.SimpleText(v, 'ui.20', w * 0.5, y, ui.col.White, TEXT_ALIGN_CENTER)
			y = y + 22
		end
	end


	surface.SetDrawColor(ui.col.Outline)
	surface.DrawOutlinedRect(0, 0, w, h)
end
vgui.Register('ba_loadscreen', PANEL)


concommand.Add('load_menu', function()
	if IsValid(LOAD) then LOAD:Remove() end
	LOAD = ui.Create('ba_loadscreen')
end)


function ba.OpenMoTD()
	cvar.SetValue('ba_has_read_motd', true)

	local motd_url = ba.svar.Get('motd')
	local faq_url = ba.svar.Get('faq')

	if (not motd_url) or (motd_url == '') then return end

	local w, h = ScrW() * .9, ScrH() * .9

	local fr = ui.Create('ui_frame', function(self)
		self:SetTitle('Добро Пожаловать!')
		self:SetSize(w, h)
		self:MakePopup()
		self:Center()
	end)

	local tabList = ui.Create('ui_tablist', function(self, p)
		self:DockToFrame()
	end, fr)

	local function tabthink(self)
		if (not IsValid(self.HTML)) then
			self.HTML = ui.Create('HTML', function(self, p)
				self:SetPos(1, 1)
				self:SetSize(p:GetWide() - 1, p:GetTall() - 1)
				self:OpenURL(p.URL)
			end, self)

			for k, v in ipairs(tabList:GetButtons()) do
				if IsValid(v.Tab.HTML) and (v.Tab ~= self) then
					v.Tab.HTML:Remove()
				end
			end
		end
	end

	tabList:AddTab('Правила', function(self)
		local tab = ui.Create('ui_panel')
		tab.Think = tabthink
		tab.URL = motd_url

		return tab
	end, true)

	/*if (faq_url and faq_url != '') then
		local tab = ui.Create('ui_panel')
		tab.Think = tabthink
		tab.URL = faq_url
		tabList:AddTab('FAQ', tab, true)
	end*/

	tabList:AddButton('Сайт', function()
		fr:Close()
		gui.OpenURL('https://gmodhub.com')
	end)

	tabList:AddButton('Steam', function()
		fr:Close()
		gui.OpenURL('https://steamcommunity.com/groups/gmodhub')
	end)

	if rp or swrp then
		tabList:AddButton('Донат', function()
			fr:Close()
			cmd.Run('upgrades')
		end)
	end

	tabList:AddButton('Закрыть', function()
		fr:Close()
	end)
end

hook.Add('InitPostEntity', function()
	if (not hook.Call("SuppressBadminLoadScreen", GAMEMODE)) then
		ui.Create('ba_loadscreen')
	end
end)
