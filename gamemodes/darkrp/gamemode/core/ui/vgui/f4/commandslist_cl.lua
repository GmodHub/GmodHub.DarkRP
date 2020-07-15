local commands = {}
function rp.AddMenuCommand(cat, name, cback, custom)
	if (not commands[cat]) then
		commands[cat] = {}
	end
	table.insert(commands[cat], {
		name = name,
		cback = cback,
		custom = custom or function() return true end
	})
end


local cat = 'Деньги'
rp.AddMenuCommand(cat, 'Передать деньги', function()
	ui.StringRequest('Количество денег', 'Сколько денег вы хотите передать?', '', function(a)
		cmd.Run('give', tostring(a))
	end)
end)
rp.AddMenuCommand(cat, 'Выбросить деньги', function()
	ui.StringRequest('Количество денег', 'Сколько денег вы хотите выбросить?', '', function(a)
		cmd.Run('dropmoney', tostring(a))
	end)
end)
rp.AddMenuCommand(cat, 'Выписать чек', function()
	ui.PlayerRequest(function(v)
		ui.StringRequest('Выписать чек', 'На какую суммы выписать чек?', '', function(a)
			if IsValid(v) then
				cmd.Run('cheque', v:SteamID(), a)
			end
		end)
	end)
end)
rp.AddMenuCommand(cat, 'Перевести деньги (20% налог)', function()
	ui.PlayerRequest(function(v)
		ui.StringRequest('Перевести', 'Колличество денег к переводу?', '', function(a)
			if IsValid(v) then
				cmd.Run('wiremoney', v:SteamID(), a)
			end
		end)
	end)
end)


cat = 'Действия'
rp.AddMenuCommand(cat, 'Вылечиться за ' .. rp.FormatMoney(rp.cfg.HealthCost), 'buyhealth')
rp.AddMenuCommand(cat, 'Продать всю собственность', 'sellproperty')
rp.AddMenuCommand(cat, 'Выбросить текущее оружие', 'drop')
rp.AddMenuCommand(cat, 'Разместить заказ', function()
	ui.PlayerRequest(function(v)
		ui.StringRequest('Hit', 'How much would you like to place a hit for (' .. rp.FormatMoney(rp.cfg.HitMinCost) .. ' - ' .. rp.FormatMoney(rp.cfg.HitMaxCost) .. ')?', '', function(a)
			if IsValid(v) then
				cmd.Run('hit', v:SteamID(), a)
			end
		end)
	end)
end)
rp.AddMenuCommand(cat, 'Уволить игрока', function()
	ui.PlayerRequest(function(v)
		ui.StringRequest('Увольнение', 'Почему вы хотите уволить этого игрока?', '', function(a)
			if IsValid(v) then
				cmd.Run('demote', v:SteamID(), a)
			end
		end)
	end)
end)
rp.AddMenuCommand(cat, 'Уволиться', 'quitjob', function()
	return LocalPlayer():IsHired()
end)
rp.AddMenuCommand(cat, 'Установить стоимость работы', function()
	ui.StringRequest('Hire Price', 'What would you like to set your hire price to? (Max: ' .. rp.FormatMoney(rp.cfg.MaxHirePrice) .. ')', '', function(a)
		cmd.Run('sethireprice', a)
	end)
end, function()
	return LocalPlayer():GetTeamTable().hirable == true
end)


cat = 'Roleplay'
rp.AddMenuCommand(cat, 'Замаскироваться', function() rp.DisguiseMenu() end, function()
	return LocalPlayer():GetTeamTable().candisguise or LocalPlayer():GetNetVar('CanGenomeDisguise')
end)

rp.AddMenuCommand(cat, 'Снять маскировку', 'undisguise', function()
	return LocalPlayer():IsDisguised()
end)

rp.AddMenuCommand(cat, 'Изменить название работы', function()
	ui.StringRequest('Работа', 'Какое название вы хотели бы для своей работы?', '', function(a)
		cmd.Run('job', a)
	end)
end)
rp.AddMenuCommand(cat, 'Сменить имя', function()
	ui.StringRequest('Имя', 'Какое имя вы хотели бы?', '', function(a)
		cmd.Run('name', a)
	end)
end)
rp.AddMenuCommand(cat, 'Вызвать 911', function()
	ui.StringRequest('911', 'Что произошло? (Вы будете объявлены в розыск и посажены в тюрьму за ложные вызовы)', '', function(a)
		cmd.Run('911', a)
	end)
end)
rp.AddMenuCommand(cat, 'Выбрать случайное имя', 'randomname')
rp.AddMenuCommand(cat, 'Случайное число', 'roll')
rp.AddMenuCommand(cat, 'Бросить кубики', 'dice')
rp.AddMenuCommand(cat, 'Вытянуть карту', 'cards')
rp.AddMenuCommand(cat, 'Бросить монетку', 'coin')

cat = 'Полиция'
rp.AddMenuCommand(cat, 'Объявить в розыск', function()
	ui.PlayerRequest(function(v)
		ui.StringRequest('Объявить в розыск', 'За что вы хотите объявить данного игрока в розыск?', '', function(a)
			if IsValid(v) then
				cmd.Run('want', v:SteamID(), a)
			end
		end)
	end)
end)
rp.AddMenuCommand(cat, 'Убрать из розыска', function()
	local wantedplayers = table.Filter(player.GetAll(), function(v)
		return v:IsWanted()
	end)
	ui.PlayerRequest(wantedplayers, function(v)
		cmd.Run('unwant', v:SteamID())
	end)
end, function() return LocalPlayer():IsChief() or LocalPlayer():IsMayor() end )
rp.AddMenuCommand(cat, 'Ордер на обыск', function()
	ui.PlayerRequest(function(v)
		ui.StringRequest('Ордер на обыск', 'Почему вы хотите запросить ордер на обыск?', '', function(a)
			if IsValid(v) then
				cmd.Run('warrant', v:SteamID(), a)
			end
		end)
	end)
end)


cat = 'Мэр'
rp.AddMenuCommand(cat, 'Начать лотерею', function()
	ui.StringRequest('Колличество', 'На какую сумму вы хотите провести лотерею?', '', function(a)
		cmd.Run('lottery', tostring(a))
	end)
end)
rp.AddMenuCommand(cat, 'Изменить законы', 'laws')


cat = 'Агенда'
rp.AddMenuCommand(cat, 'Изменить Агенду', function() -- TODO MAKE LAWS AND AGENDA EDITOR CONTROLS, CONTROLS CONTROLS CONTROLS THX
	local agenda = (nw.GetGlobal('Agenda;' .. LocalPlayer():Team()) or '')

	local fr = ui.Create('ui_frame', function(self)
		self:SetSize(ScrW() * .2, ScrH() * .3)
		self:Center()
		self:SetTitle('Изменение Поветски Дня')
		self:MakePopup()
	end)

	local x, y = fr:GetDockPos()
	local e = ui.Create('DTextEntry', function(self, p)
		self:SetPos(x, y)
		self:SetSize(p:GetWide() - 10, p:GetTall() - y - 35)
		self:SetMultiline(true)
		self:SetPlaceholderText('Агенда...')
		self:SetValue(agenda)
		self.OnTextChanged = function()
			agenda = self:GetValue()
		end
	end, fr)

	e = ui.Create('DButton', function(self, p)
		x, y = e:GetPos()
		y = y + e:GetTall() + 5
		self:SetPos(x, y)
		self:SetSize(p:GetWide() - 10, 25)
		self:SetText('Подтвердить агенду')
		self.DoClick = function()
			if string.len(agenda) <= 5 then LocalPlayer():ChatPrint('Агенда меньше 5 символов!') return end
			cmd.Run('agenda', agenda)
		end
	end, fr)
end, function()
	return LocalPlayer():IsAgendaManager()
end)


local PANEL = {}

function PANEL:Init()
	self.ShowEmployees = (not LocalPlayer():GetTeamTable().hirable)

	self.Cats = {}
	self.Rows = {}

	self.List1 = ui.Create('ui_listview', self)
	self.List1.Paint = function() end

	if self.ShowEmployees then
		self.List2 = ui.Create('rp_employment_manager', self)
		self.List2.Paint = function() end
	end

	self:AddCat('Деньги', commands['Деньги'])
	self:AddCat('Действия', commands['Действия'])
	self:AddCat('Roleplay', commands['Roleplay'])

	if LocalPlayer():IsMayor() then
		self:AddCat('Мэр', commands['Мэр'])
	end

	if LocalPlayer():IsCP() or LocalPlayer():IsMayor() then
		self:AddCat('Полиция', commands['Полиция'])
	end

	self.Cats['Мэр'] = true
	self.Cats['Полиция'] = true

	for k, v in pairs(commands) do
		self:AddCat(k, v)
	end
end

function PANEL:PerformLayout()
	local w = self.ShowEmployees and ((self:GetWide() * 0.5) - 7.5) or self:GetWide() - 10
	self.List1:SetPos(5, 5)
	self.List1:SetSize(w, self:GetTall() - 10)

	if self.ShowEmployees then
		self.List2:SetPos((self:GetWide() * 0.5) + 2.5, 5)
		self.List2:SetSize(w, self:GetTall() - 10)
	end
end

function PANEL:AddCat(cat, tab)
	tab = table.FilterCopy(tab, function(v) return v.custom() end)

	if (#tab > 0) then
		if (not self.Cats[cat]) then
			local cmdList = self.List1

			cmdList:AddSpacer(cat):SetSize(cmdList:GetWide(), 30)

			for k, v in ipairs(tab) do
				local row = cmdList:AddRow(v.name)
				row:SetSize(cmdList:GetWide(), 30)
				row.DoClick = isstring(v.cback) and function() cmd.Run(v.cback) end or v.cback
				table.insert(self.Rows, row)
			end

			self.Cats[cat] = true
		end
	end
end

vgui.Register('rp_commandlist', PANEL, 'Panel')
