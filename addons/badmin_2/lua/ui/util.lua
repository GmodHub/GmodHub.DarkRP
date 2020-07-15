surface.CreateFont('ui.60', {font = 'roboto', size = 60, weight = 700, extended = true})
surface.CreateFont('ui.40', {font = 'roboto', size = 40, weight = 500, extended = true})
surface.CreateFont('ui.39', {font = 'roboto', size = 39, weight = 500, extended = true})
surface.CreateFont('ui.38', {font = 'roboto', size = 38, weight = 500, extended = true})
surface.CreateFont('ui.37', {font = 'roboto', size = 37, weight = 500, extended = true})
surface.CreateFont('ui.36', {font = 'roboto', size = 36, weight = 500, extended = true})
surface.CreateFont('ui.35', {font = 'roboto', size = 35, weight = 500, extended = true})
surface.CreateFont('ui.34', {font = 'roboto', size = 34, weight = 500, extended = true})
surface.CreateFont('ui.33', {font = 'roboto', size = 33, weight = 500, extended = true})
surface.CreateFont('ui.32', {font = 'roboto', size = 32, weight = 500, extended = true})
surface.CreateFont('ui.31', {font = 'roboto', size = 31, weight = 500, extended = true})
surface.CreateFont('ui.30', {font = 'roboto', size = 30, weight = 500, extended = true})
surface.CreateFont('ui.29', {font = 'roboto', size = 29, weight = 500, extended = true})
surface.CreateFont('ui.28', {font = 'roboto', size = 28, weight = 500, extended = true})
surface.CreateFont('ui.27', {font = 'roboto', size = 27, weight = 400, extended = true})
surface.CreateFont('ui.26', {font = 'roboto', size = 26, weight = 400, extended = true})
surface.CreateFont('ui.25', {font = 'roboto', size = 25, weight = 400, extended = true})
surface.CreateFont('ui.24', {font = 'roboto', size = 24, weight = 400, extended = true})
surface.CreateFont('ui.23', {font = 'roboto', size = 23, weight = 400, extended = true})
surface.CreateFont('ui.22', {font = 'roboto', size = 22, weight = 400, extended = true})
surface.CreateFont('ui.20', {font = 'roboto', size = 20, weight = 400, extended = true})
surface.CreateFont('ui.19', {font = 'roboto', size = 19, weight = 400, extended = true})
surface.CreateFont('ui.18', {font = 'roboto', size = 18, weight = 400, extended = true})
surface.CreateFont('ui.17', {font = 'roboto', size = 15, weight = 550, extended = true})
surface.CreateFont('ui.15', {font = 'roboto', size = 15, weight = 550, extended = true})
surface.CreateFont('ui.12', {font = 'roboto', size = 12, weight = 550, extended = true})
surface.CreateFont('ui.5percent', {font = 'Roboto', size = math.ceil(ScrH() * 0.05), weight = 500, antialias = true, extended = true})

local vguiFucs = {
	['DTextEntry'] = function(self, p)
		self:SetFont('ui.20')
	end,
	['DLabel'] = function(self, p)
		self:SetFont('ui.22')
		self:SetColor(ui.col.White)
	end,
	['DButton'] = function(self, p)
		self:SetFont('ui.20')
	end,
	['DComboBox'] = function(self, p)
		self:SetFont('ui.22')
	end,
}

timer.Simple(0, function()
	vgui.GetControlTable('DButton').SetBackgroundColor = function(self, color)
		self.BackgroundColor = color
	end
end)

function ui.Create(t, f, p)
	local parent
	if (not isfunction(f)) and (f ~= nil) then
		parent = f
	elseif not isfunction(p) and (p ~= nil) then
		parent = p
	end

	local v = vgui.Create(t, parent)
	v:SetSkin('SUP')

	if vguiFucs[t] then vguiFucs[t](v, parent) end

	if isfunction(f) then f(v, parent) elseif isfunction(p) then p(v, f) end

	return v
end

function ui.Label(txt, font, x, y, parent)
	return ui.Create('DLabel', function(self, p)
		self:SetText(txt)
		self:SetFont(font)
		self:SetTextColor(ui.col.White)
		self:SetPos(x, y)
		self:SizeToContents()
		self:SetWrap(true)
		self:SetAutoStretchVertical(true)
	end, parent)
end

function ui.DermaMenu(pM)

	if (not parentmenu) then CloseDermaMenus() end

	return ui.Create("DMenu", function(self)
		self:SetTall(30)
	end, p)

end

function ui.BoolRequest(title, text, cback)
	local m = ui.Create('ui_frame', function(self)
		self:SetTitle(title)
		self:ShowCloseButton(false)
		self:SetWide(ScrW() * .2)
		self:MakePopup()
	end)

	local txt = string.Wrap('ui.18', text, m:GetWide() - 10)
	local y = m:GetTitleHeight()

	for k, v in ipairs(txt) do
		local lbl = ui.Create('DLabel', function(self, p)
			self:SetText(v)
			self:SetFont('ui.18')
			self:SizeToContents()
			self:SetPos((p:GetWide() - self:GetWide()) / 2, y)
			y = y + self:GetTall() + 5
		end, m)
	end

	local btnOK = ui.Create('DButton', function(self, p)
		self:SetText('Да')
		self:SetPos(5, y)
		self:SetSize(p:GetWide()/2 - 7.5, 25)
		self.DoClick = function(s)
			p:Close()
			cback(true)
		end
	end, m)

	local btnCan = ui.Create('DButton', function(self, p)
		self:SetText('Нет')
		self:SetPos(btnOK:GetWide() + 10, y)
		self:SetSize(btnOK:GetWide(), 25)
		self:RequestFocus()
		self.DoClick = function(s)
			p:Close()
			cback(false)
		end
		y = y + self:GetTall() + 5
	end, m)

	m:SetTall(y)
	m:Center()

	m:Focus()
	return m
end

function ui.StringRequest(title, text, default, cback)
	local m = ui.Create('ui_frame', function(self)
		self:SetTitle(title)
		self:ShowCloseButton(false)
		self:SetWide(ScrW() * .3)
		self:MakePopup()
	end)

	local txt = string.Wrap('ui.18', text, m:GetWide() - 10)
	local y = m:GetTitleHeight()

	for k, v in ipairs(txt) do
		local lbl = ui.Create('DLabel', function(self, p)
			self:SetText(v)
			self:SetFont('ui.18')
			self:SizeToContents()
			self:SetPos((p:GetWide() - self:GetWide()) / 2, y)
			y = y + self:GetTall()
		end, m)
	end

	local tb = ui.Create('DTextEntry', function(self, p)
		self:SetPos(5, y + 5)
		self:SetSize(p:GetWide() - 10, 25)
		self:SetValue(default or '')
		y = y + self:GetTall() + 10
		self.OnEnter = function(s)
			p:Close()
			cback(self:GetValue())
		end
	end, m)

	local btnOK = ui.Create('DButton', function(self, p)
		self:SetText('Хорошо')
		self:SetPos(5, y)
		self:SetSize(p:GetWide()/2 - 7.5, 25)
		self.DoClick = function(s)
			p:Close()
			cback(tb:GetValue())
		end
	end, m)

	local btnCan = ui.Create('DButton', function(self, p)
		self:SetText('Отмена')
		self:SetPos(btnOK:GetWide() + 10, y)
		self:SetSize(btnOK:GetWide(), 25)
		self:RequestFocus()
		self.DoClick = function(s)
			m:Close()
		end
		y = y + self:GetTall() + 5
	end, m)

	m:SetTall(y)
	m:Center()

	m:Focus()
	return m
end

function ui.PlayerRequest(players, cback)
	if isfunction(players) then
		cback = players
		players = nil
	end

	local fr = ui.Create('ui_frame', function(self)
		self:SetTitle('Выберите Игрока')
		self:SetSize(.2, .3)
		self:Center()
		self:MakePopup()
	end)

	ui.Create('ui_playerrequest', function(self, p)
		self:DockToFrame()
		if players then
			self:SetPlayers(players)
		end
		self.OnSelection = function(self, row, pl)
			fr:Close()
			cback(pl)
		end
	end, fr)

	fr:Focus()
	return m
end

function ui.OpenURL(url, title)
	local w, h = ScrW() * .9, ScrH() * .9

	local fr = ui.Create('ui_frame', function(self)
		self:SetSize(w, h)
		self:SetTitle(url)
		self:Center()
		self:MakePopup()
	end)

	ui.Create('HTML', function(self)
		self:SetPos(5, 32)
		self:SetSize(w - 10, h - 37)
		self:OpenURL(url)
	end, fr)

	return fr
end
