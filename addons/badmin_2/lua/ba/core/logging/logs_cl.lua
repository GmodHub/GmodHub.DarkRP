local os_date = os.date
local os_time = os.time

-- Log Data Panel
local cats = {}
net('ba.logs.RequestCategory', function()
	local hasLogs = net.ReadBool()
	local id = net.ReadUInt(5)

	local cat = cats[id]

	if (not hasLogs) then
		if IsValid(cat) then
			cat.IsLoaded = true
		end
		return
	end

	for entry = 1, net.ReadUInt(7) do
		local termId = net.ReadUInt(8)
		local time = net.ReadUInt(32)

		local vars = {}
		for i = 1, net.ReadUInt(4) do
			vars[i] = net.ReadString()
		end

		if IsValid(cat) then
			local term = ba.logs.GetTerm(termId)

			local clipboard = {}
			for k, copy in pairs(term.Copy) do
				clipboard[copy] = vars[k]
			end

			local c = 0
			local data = term.Message:gsub('#', function()
				c = c + 1
				return vars[c]
			end)

			cat:AddLog(termId, os.date('%I:%M:%S', time), data, clipboard)
		end
	end

	if IsValid(cat) then
		cat.IsLoaded = true
	end
end)

net('ba.logs.Live', function()
	local data = {
		Copy = {}
	}

	local term = ba.logs.GetTerm(net.ReadUInt(8))
	local log = ba.logs.GetByID(net.ReadUInt(5))

	local c = 0
	local next_string
	local message = term.Message:gsub('#', function()
		c = c + 1
		local str
		if next_string then
			str = next_string
			next_string = nil
		elseif (net.ReadBit() == 0) then
			local pl = net.ReadPlayer()
			if IsValid(pl) then
				str = pl:Name()
				next_string = pl:SteamID()
			else
				str = 'Unknown'
			end
		else
			str = net.ReadString()
		end
		if term.Copy[c] then
			data.Copy[term.Copy[c]] = str
		end
		return str
	end)

	local tab = ba.logs.Data[log:GetName()]

	data.Data = message
	data.Time = os.date('%I:%M:%S', os.time())
	table.insert(tab, 1, data)

	if (#tab > ba.logs.MaxEntries) then
		tab[#tab] = nil
	end

	if log:GetColor() then
		MsgC(log:GetColor(), '[' .. log:GetName() .. ' | ' .. os.date('%I:%M:%S', os.time()) .. '] ', ui.col.White, message .. '\n')
	end

	local cat = cats[log:GetID()]
	if IsValid(cat) then
		cat:LiveUpdate(data)
	end
end)

local playerEvents
net('ba.logs.RequestPlayerEvents', function()
	local hasLogs = net.ReadBool()

	if (not hasLogs) then
		if IsValid(playerEvents) then
			playerEvents.IsLoaded = true
		end
		return
	end

	for entry = 1, net.ReadUInt(7) do
		local termId = net.ReadUInt(8)
		local time = net.ReadUInt(32)

		local vars = {}
		for i = 1, net.ReadUInt(4) do
			vars[i] = net.ReadString()
		end

		if IsValid(playerEvents) then
			local term = ba.logs.GetTerm(termId)

			local clipboard = {}
			for k, copy in pairs(term.Copy) do
				clipboard[copy] = vars[k]
			end

			local c = 0
			local data = term.Message:gsub('#', function()
				c = c + 1
				return vars[c]
			end)

			playerEvents:AddLog(termId, os.date('%I:%M:%S', time), data, clipboard)
		end
	end

	if IsValid(playerEvents) then
		playerEvents.IsLoaded = true
	end
end)

local PANEL = {}

function PANEL:Init()
	self.IsLoaded = false

	self.Search = ui.Create('DTextEntry', self)
	self.Search.OnChange = function(s)
		self.List:Search(s:GetValue())
	end
	self.Search:SetPlaceholderText('Поиск...')

	self.Save = ui.Create('DButton', self)
	self.Save:SetText('Save')
	self.Save.DoClick = function()
		local data = {}
		for k, v in ipairs(self.List:GetSearchResults()) do
			data[#data + 1] = v.Data
		end

		local function save()
			ui.StringRequest('Сохранить Логи', 'Как вы хотите назвать это сохранение?', 'Сохранение #' .. (#ba.logs.GetSaves() + 1), function(name)
				ba.logs.SaveLog(name, data)
			end)
		end

		if (#data > 50) then
			ui.BoolRequest('Предупреждение', 'Сохранения с таким большим количеством логов может вызвать лаги при их просмотре. Вы уверены, что хотите продолжить?', function(ans)
				if ans then
					save()
				end
			end)
		else
			save()
		end
	end
	self.Save.Think = function(s)
		s:SetDisabled(#self.List:GetSearchResults() == 0)
	end

	self.List = ui.Create('ui_listview', self)
	self.List:SetNoResultsMessage('Логи не найдены!')
	self.List.PaintOver = function(s, w, h)
		if (#s.Rows == 0) and self.IsLoaded then
			draw.OutlinedBox(0, 0, w, h, ui.col.Background, ui.col.Outline)
			draw.SimpleText('Логи Отсутствуют!', 'ui.24', w * 0.5, h * 0.5, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	self.List.Paint = function(s, w, h)
		draw.OutlinedBox(0, 0, w, h, ui.col.FlatBlack, ui.col.Outline)
	end
end

function PANEL:PerformLayout(w, h)
	self.Search:SetPos(5, 5)
	self.Search:SetSize(w - 65, 25)

	self.Save:SetPos(w - 55, 5)
	self.Save:SetSize(50, 25)

	self.List:SetPos(5, 35)
	self.List:SetSize(w - 10, h - 40)
end

function PANEL:SetCategory(log)
	self.Log = log

	cats[log:GetID()] = self

	if log:GetColor() and ba.logs.Data[log:GetName()] and (#ba.logs.Data[log:GetName()] >= ba.logs.MaxEntries) then
		timer.Simple(0, function() -- wait a frame so you see a spinny while you freeze
			if IsValid(self) then
				for k, v in ipairs(ba.logs.Data[log:GetName()]) do
					self:AddLog(v.Term, v.Time, v.Data, v.Copy)
				end

				self.IsLoaded = true
			end
		end)
		return
	end

	timer.Simple(0.1, function() -- wait until next frame?
		net.Start 'ba.logs.RequestCategory'
			net.WriteUInt(log:GetID(), 5)
		net.SendToServer()
	end)
end

function PANEL:AddLog(termId, time, data, copy)
	local str = '[' .. time .. ']  ' .. data

	local b = self.List:AddRow(str)
	b:SetContentAlignment(4)
	b:SetTextInset(5, 0)
	b:SetFont('ui.20')
	b.Data = {
		Term = termId,
		Time = time,
		Data = data,
		Copy = copy
	}
	b.DoClick = function()
		local m = ui.DermaMenu()

		m:AddOption('Скопировать Линию', function()
			SetClipboardText(str)
			LocalPlayer():ChatPrint('Линия скопирована')
		end)

		for k, v in SortedPairs(copy or {}) do
			m:AddOption('Скопировать ' .. k, function()
				SetClipboardText(v)
				LocalPlayer():ChatPrint('Скопировано ' .. k)
			end)
		end

		m:Open()
	end
end

function PANEL:LiveUpdate(data)
	local lastTxt, lastData = ('[' .. data.Time .. '] ' .. data.Data), data

	for k, v in ipairs(self.List.Rows) do
		if (not IsValid(v)) then continue end

		if (k >= ba.logs.MaxEntries) then
			v:Remove()
		else
			local thisTxt, thisData = v:GetText(), v.Data

			v:SetText(lastTxt)
			v.Data = lastData

			lastTxt, lastData = thisTxt, thisData

		end
	end

	if (#self.List.Rows < ba.logs.MaxEntries) then
		self:AddLog(lastData.Term, lastData.Time, lastData.Data, lastData.Copy)
	end

	self.List:Search(self.Search:GetValue())
end

function PANEL:PaintOver(w, h)
	if (not self.IsLoaded) then
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(0, 0, w, h)
		local t = SysTime() * 5
		draw.NoTexture()
		surface.SetDrawColor(255, 255, 255)
		surface.DrawArc(w*0.5, h*0.5, 20, 25, t*80, t*80+180, 20)
	end
end

vgui.Register('ba_logs_data_panel', PANEL, 'Panel')


-- Log Player Events Panel
local PANEL = {}

function PANEL:Init()
	self.PlayerRequest = ui.Create('ui_playerrequest', self)
	self.PlayerRequest.OnSelection = function(s, row, pl)
		self:Search(pl:SteamID())
	end

	self.ViewMode = ui.Create('DButton', self)
	self.ViewMode:SetText('<<')
	self.ViewMode:Hide()
	self.ViewMode.DoClick = function()
		self:ToggleViewMode(false)
	end

	self.Data = ui.Create('ba_logs_data_panel', self)
	self.Data:Hide()

	playerEvents = self.Data
end

function PANEL:Search(steamid32)
	net.Start 'ba.logs.RequestPlayerEvents'
		net.WriteString(steamid32)
	net.SendToServer()

	self:ToggleViewMode(true)
end

function PANEL:ToggleViewMode(toggle)
	self.IsViewMode = toggle

	self.Data.List.Rows = {}
	self.Data.List.SearchResults = {}
	self.Data.List:Reset()

	if toggle then
		self.PlayerRequest:Hide()
		self.ViewMode:Show()
		self.Data:Show()

		self.Data.IsLoaded = false
	else
		self.PlayerRequest:Show()
		self.ViewMode:Hide()
		self.Data:Hide()

		self.Data.IsLoaded = true
	end

	self:PerformLayout(self:GetWide(), self:GetTall())
end

function PANEL:PerformLayout(w, h)
	self.PlayerRequest:SetPos(5, 5)
	self.PlayerRequest:SetSize(w - 10, h - 10)

	self.ViewMode:SetPos(5, 5)
	self.ViewMode:SetSize(30, h - 10)

	self.Data:SetPos(35, 0)
	self.Data:SetSize(w - 35, h)
end

vgui.Register('ba_logs_playerevents_panel', PANEL, 'Panel')

-- Log Saves Panel
local PANEL = {}

function PANEL:Init()
	self.Saves = ui.Create('ui_listview', self)
	self.Saves.PaintOver = function(s, w, h)
		if (#s.Rows == 0) then
			draw.OutlinedBox(0, 0, w, h, ui.col.Background, ui.col.Outline)
			draw.SimpleText('У вас нет сохранённых логов!', 'ui.24', w * 0.5, h * 0.5, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	self.ViewMode = ui.Create('DButton', self)
	self.ViewMode:SetText('<<')
	self.ViewMode:Hide()
	self.ViewMode.DoClick = function()
		self:ToggleViewMode(false)
	end

	self.Data = ui.Create('ba_logs_data_panel', self)
	self.Data:Hide()

	for k, v in ipairs(ba.logs.GetSaves()) do
		local b = self.Saves:AddRow(v.Date .. v.Name)
		b:SetContentAlignment(4)
		b:SetTextInset(5, 0)
		b.DoClick = function()
			local m = ui.DermaMenu(b)

			m:AddOption('Открыть', function()
				self:ToggleViewMode(true)

				self.Data.List:Reset()

				for k, v in ipairs(ba.logs.OpenSave(v.Name)) do
					self.Data:AddLog(v.Term, v.Time, v.Data, v.Copy)
				end
			end)

			m:AddOption('Удалить', function()
				ui.BoolRequest('Удалить Лог', 'Вы уверены, что хотите удалить лог: ' .. v.Name, function(ans)
					if ans then
						b:Remove()
						ba.logs.DeleteSave(v.Name)
					end
				end)
			end)

			m:Open()
		end
	end
end

function PANEL:ToggleViewMode(toggle)
	self.IsViewMode = toggle

	self.Data.List.Rows = {}
	self.Data.List.SearchResults = {}
	self.Data.List:Reset()

	if toggle then
		self.Saves:Hide()
		self.ViewMode:Show()
		self.Data:Show()

		self.Data.IsLoaded = true
	else
		self.Saves:Show()
		self.ViewMode:Hide()
		self.Data:Hide()

		self.Data.IsLoaded = false
	end

	self:PerformLayout(self:GetWide(), self:GetTall())
end

function PANEL:PerformLayout(w, h)
	self.Saves:SetPos(5, 5)
	self.Saves:SetSize(w - 10, h - 10)

	self.ViewMode:SetPos(5, 5)
	self.ViewMode:SetSize(30, h - 10)

	self.Data:SetPos(35, 0)
	self.Data:SetSize(w - 35, h)
end

vgui.Register('ba_logs_saves_panel', PANEL, 'Panel')

-- Log menu
local PANEL = {}

function PANEL:Init()
	self.LiveMode = ui.Create('ui_checkbox', self)
	self.LiveMode:SetText('Live Обновление')
	self.LiveMode.OnChange = function(s, checked)
		net.Start 'ba.logs.UpdateSubscription'
			net.WriteBit(checked)
		net.SendToServer()
	end

	self.UnlockKeyboard = ui.Create('ui_checkbox', self)
	self.UnlockKeyboard:SetText('Разблокировать Клавиатуру')
	self.UnlockKeyboard.OnChange = function(s, checked)
		self:SetKeyboardInputEnabled(not checked)
	end

	self.Tabs = ui.Create('ui_tablist', self)

	self.Tabs:AddTab('Сохранения', function()
		return ui.Create 'ba_logs_saves_panel'
	end, true)

	self.Tabs:AddTab('Игроки', function()
		return ui.Create 'ba_logs_playerevents_panel'
	end)

	for k, v in pairs(ba.logs.Stored) do
		self.Tabs:AddTab(v:GetName(), function()
			local l = ui.Create 'ba_logs_data_panel'
			l:SetCategory(v)
			return l
		end)
	end

	self:SetTitle("Меню Логирования")
	self:SetSize(ScrW() * 0.75, ScrH() * 0.75)
	self:Center()
	self:MakePopup()
end

function PANEL:SetPlayerEventMode(steamid32)
	self.Tabs:SetActiveTab(2)

	playerEvents:GetParent():Search(steamid32)
end

function PANEL:OnClose()
	net.Start 'ba.logs.UpdateSubscription'
		net.WriteBit(false)
	net.SendToServer()
end

function PANEL:PerformLayout(w, h)
	self.BaseClass.PerformLayout(self, w, h)

	self.UnlockKeyboard:SizeToContents()
	self.UnlockKeyboard:SetPos((w - 5) - self.btnClose:GetWide() - self.UnlockKeyboard:GetWide(), 5)

	self.LiveMode:SizeToContents()
	self.LiveMode:SetPos(self.UnlockKeyboard.x - self.LiveMode:GetWide() - 5, 5)

	self.Tabs:DockToFrame()
end

vgui.Register('ba_logs_menu', PANEL, 'ui_frame')
