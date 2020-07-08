local function makeTab(tabs)
	local tab = ui.Create('ui_panel')
	tab:SetSize(tabs:GetParent():GetWide() - 165, tabs:GetParent():GetTall() - 35)

	local w, h = (tab:GetWide() * 0.5) - 7.5, ((tab:GetTall() - 115) * 0.5)

	ui.Create('DButton', function(self, p)
		self:SetPos(5, 5)
		self:SetSize(w, 30)
		self:SetText('Цвет Игрока')
		self:SetDisabled(true)
	end, tab)

	ui.Create('DColorMixer', function(self, p)
		self:SetAlphaBar(false)
		self:SetSize(w, h)
		self:SetPos(5, 40)
		self:SetVector(Vector(GetConVarString('cl_playercolor')))
		self.ValueChanged = function()
			local vec = self:GetVector()
			local vecstr = tostring(vec)
			timer.Create('rp.PlayerColor', 0.25, 1, function()
				RunConsoleCommand('cl_playercolor', vecstr)
				cmd.Run('playercolor', vec.x, vec.y, vec.z)
			end)
		end
	end, tab)

	ui.Create('DButton', function(self, p)
		self:SetPos(5, h + 45)
		self:SetSize(w, 30)
		self:SetText('Цвет Физгана')
		self:SetDisabled(true)
	end, tab)

	ui.Create('DColorMixer', function(self, p)
		self:SetAlphaBar(false)
		self:SetSize(w, h)
		self:SetPos(5, h + 80)
		self:SetVector(Vector(GetConVarString('cl_weaponcolor')))
		self.ValueChanged = function()
			local vec = self:GetVector()
			local vecstr = tostring(vec)
			timer.Create('rp.WeaponnColor', 0.25, 1, function()
				RunConsoleCommand('cl_weaponcolor', vecstr)
				cmd.Run('physcolor', vec.x, vec.y, vec.z)
			end)
		end
	end, tab)

	ui.Create('DButton', function(self, p)
		self:SetSize(w, 30)
		self:SetPos(5, p:GetTall() - 30)
		self:SetText('Выбрать Сумасшедший Цвет Физгана')
		self.DoClick = function()
			local min = math.Rand(10,100000000)
			local max = math.Rand(10,100000000)
			local a = math.Rand(-min, max)
			min = math.Rand(10,100000000)
			max = math.Rand(10,100000000)
			local b = math.Rand(-min, max)
			min = math.Rand(10,100000000)
			max = math.Rand(10,100000000)
			local c = math.Rand(-min, max)

			local vec = Vector(a,b,c)
			RunConsoleCommand('cl_weaponcolor', tostring(vec))
			cmd.Run('physcolor', vec.x, vec.y, vec.z)
		end
	end, tab)

	ui.Create('DButton', function(self, p)
		self:SetPos(w + 15, 5)
		self:SetSize(w, 30)
		self:SetText('Материалы Оружия')
		self:SetDisabled(true)
	end, tab)

	local listView = ui.Create('ui_listview', function(self, p)
		self:SetPadding(0)
		self:SetPos(w + 15, 40)
		self:SetSize(w, p:GetTall() - 75)
		self.Paint = function() end
	end, tab)

	local selectedMaterial
	local s = listView:GetWide() * .25

	local pnl
	local c = 0
	for k, v in pairs(rp.WeaponMaterials) do
		if (c == 0) then
			pnl = ui.Create('DPanel', function(self)
				self:SetSize(s * 4, s)
			end)

			listView:AddItem(pnl)
		end

		ui.Create('DImageButton', function(self)
			self.Material = k
			self.Price = rp.FormatMoney(v)
			self:SetOnViewMaterial(k, "models/wireframe" )
			self:SetSize(s, s)
			self:SetPos(c * s, 0)
			self:SetText('')
			self.PaintOver = function(self, w, h)
				surface.SetDrawColor((selectedMaterial == self) and ui.col.White or ui.col.Outline)
				surface.DrawOutlinedRect(0, 0, w, h)
			end
			self.DoClick = function()
				selectedMaterial = self
			end
			c = (c == 4) and 0 or (c + 1)
		end, pnl)
	end

	ui.Create('DButton', function(self, p)
		self:SetSize(w, 30)
		self:SetPos(w + 15, p:GetTall() - 30)
		self:SetText('Выбрать Материал')
		self.DoClick = function()
			cmd.Run('weaponmaterial', selectedMaterial.Material)
		end
		self.Think = function()
			local wep = LocalPlayer():GetActiveWeapon()
			if (not IsValid(wep)) or (string.sub(wep:GetClass(), 0, 3) ~= 'swb') then
				self:SetDisabled(true)
				self:SetText('Вы не можете сменить материал текущего оружия!')
			elseif IsValid(selectedMaterial) then
				self:SetDisabled(false)
				self:SetText('Купить Материал (' .. selectedMaterial.Price .. ')')
			else
				self:SetDisabled(true)
				self:SetText('Выбрать Материал')
			end
		end
	end, tab)

	return tab
end

hook('PopulateF4Tabs', 'rp.cosmetrics.Tabs', function(tabs)
	tabs:AddTab('Косметика', function(self)
		return makeTab(tabs)
	end):SetIcon 'sup/gui/f4/f4_cosmetics.png'
end)
