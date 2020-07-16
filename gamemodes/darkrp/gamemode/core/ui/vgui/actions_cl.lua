local actionsMenus = {
	{
		Name 	= 'Жесты',
		DoClick = function(p)
			local m = ui.DermaMenu(p)
			for k, v in pairs(rp.PlayerActs) do
				local name = k[1]:upper() .. k:sub(2)
				m:AddOption(name, function()
					cmd.Run('act', k)
				end)
			end
			m:Open()
		end,
	},
	{
		Name 	= 'Насрать',
		DoClick = function(p)
			cmd.Run('poop')
		end,
	},
	{
		Name 	= 'Нассать',
		DoClick = function(p)
			cmd.Run('piss')
		end,
	},
	{
		Name 	= 'Умереть',
		DoClick = function(p)
			RunConsoleCommand('kill')
		end,
	},

}

local unilitiesMenus = {
	{
		Name = 'Доступ Пропов',
		DoClick = function(p)
			rp.pp.SharePropMenu()
		end
	}
}

local function makeMenus(x, y, name, menus, cont)
	local fr = ui.Create('ui_frame', function(self, p)
		self:SetPos(x, y)
		self:ShowCloseButton(false)
		self:SetTitle(name)
	end, cont)

	local x, y = fr:GetDockPos()
	local c = 0
	for k, v in ipairs(menus) do
		fr:SetSize(125, ((c + 1) * 29) + y + 6)
		ui.Create('DButton', function(self)
			self:SetSize(125 - 10, 30)
			self:SetPos(x, (c * (self:GetTall() - 1)) + y)
			self:SetText(v.Name)
			self.DoClick = v.DoClick
		end, fr)
		c = c + 1
	end

	return fr
end

hook('ContextMenuCreated', function(cont)
	local actions = makeMenus(10, ScrH()/2 - (#actionsMenus * 30), 'Действия', actionsMenus, cont)

	local x, y = actions:GetPos()
	makeMenus(x, y + actions:GetTall() + 5, 'Утилиты', unilitiesMenus, cont)
end)
