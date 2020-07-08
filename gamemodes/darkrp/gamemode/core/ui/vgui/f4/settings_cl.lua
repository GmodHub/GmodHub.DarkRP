local defaultBinds = {
	{
		Key = KEY_H,
		Cmd = '/yell У вас есть 10 секунд чтобы покинуть эту территорию или вы будете убиты!',
		Type = 'Чат'
	},
	{
		Key = KEY_O,
		Cmd = 'net_graph 0',
			Type = 'Другое'
	},
	{
		Key = KEY_P,
		Cmd = 'net_graph 1',
		Type = 'Другое'
	}
}

cvar.Register 'custom_binds'
	:SetDefault {
		Profile = 'Default',
		Default = defaultBinds
	}
	:SetEncrypted()
	:AddInitCallback(function(self) -- merge old binds
		local binds = self:GetValue()

		if (not binds.Profile) then
			binds.Profile = 'Default'
		end

		binds.Default = binds.Default or {}
		for k, v in ipairs(binds) do
			binds[k] = nil
			binds.Default[#binds.Default + 1] = v
		end

		self:SetValue(binds)
	end)

local function saveBind(key, cmd, type)
	local binds = cvar.GetValue 'custom_binds'
	local profile = binds[binds.Profile]

	local index = #profile + 1

	for k, v in ipairs(profile) do
		if (v.Key == key) then
			index = k
			break
		end
	end

	profile[index] = {
		Key 	= key,
		Cmd 	= cmd or '',
		Type 	= type or 'Другое'
	}

	cvar.SetValue('custom_binds', binds)
end

local function removeBind(key)
	local binds = cvar.GetValue 'custom_binds'
	local profile = binds[binds.Profile]

	for k, v in ipairs(profile) do
		if (v.Key == key) then
			table.remove(profile, k)
			break
		end
	end

	cvar.SetValue('custom_binds', binds)
end

local PANEL = {}

function PANEL:Init()
	self:SetTall(65)

	self.Binder = ui.Create('DButton', self)
	self.Binder:SetText '...'
	self.Binder.DoClick = function(s)
		input.StartKeyTrapping()
		s.Trapping = true
		s:SetText '...'
	end
	self.Binder.Think = function(s)
		if input.IsKeyTrapping() and s.Trapping then
			local key = input.CheckKeyTrapping()
			if key then
				removeBind(self.Key)

				s:SetText(input.GetKeyName(key):upper())
				s.Trapping = false

				self.Key = key
				saveBind(key, self.Cmd, self.Type)
			end
		end
	end

	self.Setting = ui.Create('DComboBox', self)
	self.Setting:AddChoice('Чат')
	self.Setting:AddChoice('Команда')
	self.Setting:AddChoice('Другое')
	self.Setting.OnSelect = function(s, inx, type)
		self.Type = type
		saveBind(self.Key, self.Cmd, self.Type)
	end

	self.Custom = ui.Create('DTextEntry', self)
	self.Custom:SetPlaceholderText('Command...')
	self.Custom.OnChange = function(s)
		self.Cmd = s:GetValue()
		saveBind(self.Key, self.Cmd, self.Type)
	end

	self.Unbind = ui.Create('DButton', self)
	self.Unbind:SetText ''
	self.Unbind.DoClick = function(s)
		removeBind(self.Key)
		self:Remove()
	end
	self.Unbind.Paint = function(s, w, h)
		derma.SkinHook('Paint', 'WindowCloseButton', s, w, h)
	end
end

function PANEL:PerformLayout()
	self.Binder:SetPos(5, 5)
	self.Binder:SetSize(55, 55)

	self.Setting:SetPos(65, 5)
	self.Setting:SetSize(self:GetWide() * 0.5, 25)

	self.Custom:SetPos(65, 35)
	self.Custom:SetSize(self:GetWide() - 70, 25)

	self.Unbind:SetSize(25, 25)
	self.Unbind:SetPos(self:GetWide() - 30, 5)
end

function PANEL:SetBind(inf)
	self.Key = inf.Key
	self.Cmd = inf.Cmd
	self.Type = inf.Type

	self.Binder:SetText(input.GetKeyName(self.Key):upper())
	self.Setting:SetText(self.Type)
	self.Custom:SetValue(self.Cmd)
end
vgui.Register('rp_keybinder', PANEL, 'ui_panel')


local PANEL = {}

function PANEL:Init()
	self.Settings = ui.Create('ui_settingspanel', self)
	self.Settings.Paint = function(s, w, h)
		--draw.Outline(0, 0, w, h, ui.col.Outline)
	end

	self.Settings:Populate({'Медиа', 'Чат', 'HUD', 'Staff', 'Другое'})

	local binds = cvar.GetValue 'custom_binds'

	self.Profile = ui.Create('DComboBox', self)
	self.Profile.OnSelect = function(s, inx, value)
		local binds = cvar.GetValue 'custom_binds'
		binds.Profile = value
		cvar.SetValue('custom_binds', binds)

		self.KeyBinds:Reset()

		for k, v in ipairs(binds[binds.Profile]) do
			self.KeyBinds:AddItem(ui.Create('rp_keybinder', function(self)
				self:SetBind(v)
			end))
		end
	end


	self.RemoveProfile = ui.Create('DButton', self)
	self.RemoveProfile:SetText('-')
	self.RemoveProfile.Think = function(s)
		s:SetDisabled(cvar.GetValue('custom_binds').Profile == 'Default')
	end
	self.RemoveProfile.DoClick = function(s)
		ui.BoolRequest('Remove Profile', 'Are you sure you want to remove this keybind profile?', function(ans)
			if ans then
				local binds = cvar.GetValue 'custom_binds'
				binds.Profile = 'Default'
				binds[self.Profile:GetValue()] = nil
				cvar.SetValue('custom_binds', binds)

				self.Profile:Clear()

				for k, v in pairs(binds) do
					if istable(v) then
						self.Profile:AddChoice(k)
					end
				end

				self.Profile:ChooseOption('Default')
			end
		end)
	end

	self.AddProfile = ui.Create('DButton', self)
	self.AddProfile:SetText('+')
	self.AddProfile.DoClick = function(s)
		ui.StringRequest('Add Profile', 'What would you like to name this keybind profile?', '', function(value)
			local binds = cvar.GetValue 'custom_binds'
			binds.Profile = value
			binds[value] = defaultBinds

			self.Profile:AddChoice(value)
			self.Profile:ChooseOption(value)
		end)
	end

	self.KeyBinds = ui.Create('ui_listview', self)
	self.KeyBinds:SetPadding(-1)
	self.KeyBinds.Paint = function(s, w, h)
		draw.Outline(0, 0, w, h, ui.col.Outline)
	end

	for k, v in pairs(binds) do
		if istable(v) then
			self.Profile:AddChoice(k)
		end
	end

	self.Profile:ChooseOption(binds.Profile)

	self.AddBinding = ui.Create('DButton', self)
	self.AddBinding:SetText('Добавить бинд')

	self.AddBinding.DoClick = function(s)
		self.KeyBinds:AddItem(ui.Create 'rp_keybinder')
	end
end

function PANEL:PerformLayout(w, h)
	self.Settings:SetPos(5, 5)
	self.Settings:SetSize(self:GetWide() * 0.5 - 7.5, self:GetTall() - 10)

	self.Profile:SetPos((w * 0.5) + 5, 5)
	self.Profile:SetSize((w - (w * 0.5) - 70), 25)

	self.RemoveProfile:SetPos(self.Profile.x + self.Profile:GetWide() + 5, self.Profile.y)
	self.RemoveProfile:SetSize(25, 25)

	self.AddProfile:SetPos(self.RemoveProfile.x + self.RemoveProfile:GetWide() + 5, self.Profile.y)
	self.AddProfile:SetSize(25, 25)

	self.KeyBinds:SetPos((w * 0.5), 35)
	self.KeyBinds:SetSize(w - (w * 0.5), h - 70)

	self.AddBinding:SetPos(w * 0.5 + 5, h - 30)
	self.AddBinding:SetSize(w - (w * 0.5) - 10, 25)
end
vgui.Register('rp_settings', PANEL, 'Panel')


local lastkey = 0
local nextcall = 0
hook('Think', 'rp.KeyBinds.Think', function()
	local a, b = gui.MousePos()
	local binds = cvar.GetValue 'custom_binds'

	if (a == 0) and (b == 0) and binds then
		local profile = binds[binds.Profile]
		if profile then
			for k, v in ipairs(profile) do
				if v.Key and v.Cmd and v.Type and input.IsKeyDown(v.Key) then
					if (lastkey ~= v.Key) and (nextcall < CurTime()) then
						if (v.Type == 'Chat') then
							LocalPlayer():ConCommand('say ' .. v.Cmd)
						elseif (v.Type == 'Command') then
							LocalPlayer():ConCommand('rp ' .. v.Cmd)
						elseif (v.Type == 'Другое') then
							LocalPlayer():ConCommand(v.Cmd)
						end
						nextcall = CurTime() + 0.33
						continue
					end
					nextcall = CurTime() + 0.33
				end
			end
		end
	end
end)
