local function submitPermaWeaponChoices()
	local choices = cvar.GetValue('perma_weapon_choices')

	net.Start('rp.PermaWeaponSettings')
		-- Weps
		net.WriteUInt(table.Count(choices[1]), 8)
		for k, v in pairs(choices[1]) do
			net.WriteUInt(k, 8)
			net.WriteBool(v == true)
		end

		-- Knives, the != 0 shit is backwards compat because I'm retarded
		if (choices[2] != nil and choices[2] != 0) then
			net.WriteBool(true)
			net.WriteUInt(choices[2], 8)
		else
			net.WriteBool(false)
		end

		-- Vapes
		if (choices[3] != nil and choices[3] != 0) then
			net.WriteBool(true)
			net.WriteUInt(choices[3], 8)
		else
			net.WriteBool(false)
		end
	net.SendToServer()
end

cvar.Register 'perma_weapon_choices'
	:SetDefault({{},nil,nil}, true)
	:SetEncrypted()
	:AddInitCallback(submitPermaWeaponChoices)


local upgradeCats 		= {}
local upgradeCatOrder 	= {}
function rp.shop.AddCategory(name, callback)
	upgradeCats[name] = callback
	upgradeCatOrder[#upgradeCatOrder + 1] = name
end

rp.shop.AddCategory('General', function(upgrade, parent)
	local text = string.Wrap('ui.22', upgrade:GetDesc(), parent:GetWide() - 10)

	local y = (parent:GetTall() - (#text * 22)) * 0.5
	for k, v in ipairs(text) do
		ui.Create('DLabel', function(self)
			self:SetText(v)
			self:SizeToContents()
			self:CenterHorizontal()
			self:SetPos(self.x, y)

			y = y + 22
		end, parent)
	end
end)

rp.shop.AddCategory('Ranks', upgradeCats['General'])
rp.shop.AddCategory('Cash Packs', upgradeCats['General'])
rp.shop.AddCategory('Karma Packs', upgradeCats['General'])
rp.shop.AddCategory('Permanent Weapons', function(upgrade, parent)
	local rad
	if parent.HasPurchased then
		local choices = cvar.GetValue('perma_weapon_choices')
		rad = parent:Add("ui_checkbox")
		rad:SetText('Enable')
		rad:SetPos(5, 5)
		rad:SizeToContents()

		rad.OnChange = function(self, bool)
			choices[1][upgrade:GetID()] = bool

			cvar.SetValue('perma_weapon_choices', choices)

			submitPermaWeaponChoices()
		end

		if (choices[1][upgrade:GetID()] == nil or choices[1][upgrade:GetID()] == true) then
			rad:SetChecked(true)
		end
	end

		if (not upgrade:GetIcon()) then
			upgradeCats["General"](upgrade, parent)
			return
		end

		local mdlpnl = ui.Create("DModelPanel", function(self)
			self:SetSize(parent:GetSize())
			self:Center()

			local nm = upgrade:GetName()

			function self:LayoutEntity(ent)
				if (nm == "Crowbar" or nm == "Stunstick") then
					ent:SetAngles(Angle(45, 0, 0))
				end

				return false
			end

			self:SetModel(upgrade:GetIcon())

			if (nm == '.357 Magnum') then
				self:SetFOV(25)
				self:SetCamPos(Vector(10, -60, 15))
				self:SetLookAt(Vector(0, 45, -8))
			elseif (nm == "Default Knife") then
				self:SetFOV(50)
				self:SetCamPos(Vector(0, 25, 10))
				self:SetLookAt(Vector(0, 0, 9))
			elseif (nm == "Stunstick" or nm == "Crowbar") then
				self:SetFOV(85)
				self:SetCamPos(Vector(0, 25, 10))
				self:SetLookAt(Vector(0, 0, 0))
			else
				self:SetFOV(40)
				self:SetCamPos(Vector(0, 25, 10))
				self:SetLookAt(Vector(0, 0, -2))
			end
		end, parent)

	if rad then
		rad:MoveToFront()
	end
end)
rp.shop.AddCategory('Permanent Knives', function(upgrade, parent)
	local rad
	if parent.HasPurchased then
		local choices = cvar.GetValue('perma_weapon_choices')
		rad = parent:Add("ui_checkbox")
		rad:SetText('Enable')
		rad:SetPos(5, 5)
		rad:SizeToContents()

		rad.OnChange = function(self, bool)
			choices[2] = bool and upgrade:GetID() or nil
			cvar.SetValue('perma_weapon_choices', choices)

			submitPermaWeaponChoices()
		end

		rad:SetChecked(choices[2] and choices[2] == upgrade:GetID())
	end

	if (not upgrade:GetIcon()) then
		upgradeCats["General"](upgrade, parent)

		return
	end

	local mdlpnl = ui.Create("DModelPanel", function(self)
		self:SetSize(parent:GetSize())
		self:Center()

		local nm = upgrade:GetName()

		function self:LayoutEntity(ent)
			if (upgrade:GetIcon() == "models/weapons/w_csgo_push.mdl") then
				ent:SetAngles(Angle(-45, 90, 0))
			elseif (upgrade:GetIcon() == "models/weapons/w_csgo_karambit.mdl") then
				ent:SetAngles(Angle(180, 0, 0))
			end

			if (upgrade.Skin) then ent:SetMaterial(upgrade.Skin) end

			return false
		end

		self:SetModel(upgrade:GetIcon())

		if (nm == "Basic Knife") then
			self:SetFOV(50)
			self:SetCamPos(Vector(0, 25, 10))
			self:SetLookAt(Vector(0, 0, 9))
		elseif (upgrade:GetIcon() == "models/weapons/w_csgo_push.mdl") then
			self:SetFOV(25)
			self:SetCamPos(Vector(0, 25, 5))
			self:SetLookAt(Vector(0, 0, -1))
		elseif (upgrade:GetIcon() == "models/weapons/w_csgo_karambit.mdl") then
			self:SetFOV(50)
			self:SetCamPos(Vector(0, 20, 10))
			self:SetLookAt(Vector(-1, 10, 8.5))
		else
			self:SetFOV(40)
			self:SetCamPos(Vector(0, 25, 10))
			self:SetLookAt(Vector(5, -5, 0))
		end
	end, parent)

	if rad then
		rad:MoveToFront()
	end
end)
rp.shop.AddCategory('Permanent Vapes', function(upgrade, parent)
	local rad
	if parent.HasPurchased then
		local choices = cvar.GetValue('perma_weapon_choices')
		rad = parent:Add("ui_checkbox")
		rad:SetText('Enable')
		rad:SetPos(5, 5)
		rad:SizeToContents()

		rad.OnChange = function(self, bool)
			choices[3] = bool and upgrade:GetID() or nil

			cvar.SetValue('perma_weapon_choices', choices)

			submitPermaWeaponChoices()
		end

		rad:SetChecked(choices[3] and choices[3] == upgrade:GetID())
	end

	local mats = {Material(Format("particle/smokesprites_00%02d",math.random(7, 16))), Material(Format("particle/smokesprites_00%02d",math.random(7, 16))), Material(Format("particle/smokesprites_00%02d",math.random(7, 16)))}
	local col = upgrade.Color or rp.col.White

	local matShower = ui.Create('Panel', function(self)
		self:Dock(FILL)
		self.Paint = function(self, w, h)
			local x = w * 0.5
			local y = h * 0.5
			local w = w * 0.25
			local h = w

			surface.SetMaterial(mats[1])
			surface.SetDrawColor(isfunction(col) and col() or col)
			surface.DrawTexturedRect(x - w * 0.5 + math.cos(SysTime() / 10 - 2) * 8, y - h * 0.5 + math.sin(SysTime() / 4 + 5) * 4, w, h)

			surface.SetMaterial(mats[2])
			surface.SetDrawColor(isfunction(col) and col() or col)
			surface.DrawTexturedRect(x - w * 0.75 + math.cos(SysTime() / 2) * 8, y - h * 0.75 + math.sin(SysTime() / 4) * 5, w, h)

			surface.SetMaterial(mats[3])
			surface.SetDrawColor(isfunction(col) and col() or col)
			surface.DrawTexturedRect(x - w * 0.2 + math.sin(SysTime() / 2 - 25) * 7, y - h * 0.25 + math.cos(SysTime() / 4) * 10, w, h)

			draw.NoTexture()
		end
	end, parent)

	if rad then
		rad:MoveToFront()
	end
end)
rp.shop.AddCategory('Events', upgradeCats['General'])
rp.shop.AddCategory('Purchased', function(upgrade, parent)
	upgradeCats[upgrade:GetCat()](upgrade, parent)
end)

local PANEL = {}

local fr
function PANEL:Init()
	fr = self
	self.IsLoaded = false

	net.Ping 'rp.shop.Menu'

	self.List = ui.Create('ui_listview', self)
	self.List:SetPadding(-1)
	self.List.Paint = function() end

	self.Name = ui.Create('DButton', self)
	self.Name:SetDisabled(true)
	self.Name:SetText('← Выберите предмет')

	self.Price = ui.Create('DLabel', self)
	self.Price:SetTextColor(ui.col.DarkGreen)
	self.Price:Hide()

	self.Error = ui.Create('DLabel', self)
	self.Error:Hide()

	self.Info = ui.Create('DPanel', self)
	self.Info.Paint = function(s, w, h)
		draw.SimpleText('Добро пожаловать в GmodHub Donate!', 'ui.22', w * 0.5, 10, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		draw.SimpleText('Выберите предмет для просмотра подробной информации о нём.', 'ui.22', w * 0.5, 30, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		draw.SimpleText('Ваши пожертвования очень значимы для нас!', 'ui.22', w * 0.5, 50, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	-- TODO: Make earn rewards work

	--self.EarnRewards = ui.Create('ui_reward_panel', self.Info)

	self.Container = ui.Create('DPanel', self)
	self.Container.Paint = function() end

	self.Purchase = ui.Create('DButton', self)
	self.Purchase:SetText('Приобрести')
	self.Purchase:Hide()
	self.Purchase.BackgroundColor = ui.col.DarkGreen
	self.Purchase.OutlineColor = ui.col.OffWhite
	self.Purchase.Think = function(s)
		if s.Confirmed and (s.ResetConfirm <= CurTime()) then
			s.Confirmed = nil
			s:SetText('Приобрести')
		end
	end
	self.Purchase.DoClick = function(s)
		if (not LocalPlayer():CanAffordCredits(self.Upgrade.Price)) then
			ui.BoolRequest('Недостаточно Средств', 'Вам необходимо больше кредитов для приобретения этого. Желаете пополнить баланс?', function(ans)
				if (ans == true) then
					gui.OpenURL(rp.cfg.CreditsURL .. LocalPlayer():SteamID() .. '/' .. self.Upgrade.Price)
				end
			end)
			return
		end

		if (not s.Confirmed) then
			s.ResetConfirm = CurTime() + 3
			s:SetText('Нажмите ещё раз для подтверждения')

			s.Confirmed = true
			return
		end

		s.Confirmed = nil
		s:SetText('Обработка...')
		s:SetDisabled(true)
		rp.ToggleF4Menu()

		cmd.Run('buyupgrade', tostring(self.Upgrade:GetID()))
	end
end

function PANEL:ApplySchemeSettings()
	self.Price:SetFont('ui.22')

	self.Error:SetFont('ui.22')
	self.Error:SetTextColor(ui.col.Red)
end

function PANEL:PerformLayout(w, h)
	self.List:SetPos(5, 5)
	self.List:SetSize((w * 0.5) - 7.5, h - 10)

	local leftX, leftW = (w * 0.5) + 2.5, (w * 0.5) - 7.5

	self.Name:SetPos(leftX, 5)
	self.Name:SetSize(leftW, 30)

	self.Price:SizeToContents()
	self.Price:SetPos((w * 0.75) - (self.Price:GetWide() * 0.5), 40)

	self.Error:SizeToContents()
	self.Error:SetPos((w * 0.75) - (self.Error:GetWide() * 0.5), 60)

	self.Container:SetPos(leftX, 34)
	self.Container:SetSize(leftW, h - 74)

	self.Info:SetPos(leftX, 34)
	self.Info:SetSize(leftW, h - 74)

	--self.EarnRewards:SetSize(self.Info:GetWide(), (4 * 49) + 2)
	--self.EarnRewards:SetPos(0, 80)

	self.Purchase:SetPos(leftX, h - 35)
	self.Purchase:SetSize(leftW, 30)


end

function PANEL:PaintOver(w, h)
	if (not self.IsLoaded) then
		local t = SysTime() * 5
		draw.NoTexture()
		surface.SetDrawColor(255, 255, 255)
		surface.DrawArc(w * 0.5, h * 0.5, 41, 46, t * 80, t * 80 + 180, 20)
	end
end

function PANEL:AddControls(f4)
	if IsValid(self.BuyCredits) and IsValid(self.UsePromo) then
		self.BuyCredits:Show()
	elseif IsValid(f4) then
		self.BuyCredits = ui.Create('DButton', f4)
		self.BuyCredits:SetText('Пополнить баланс' .. rp.cfg.CreditSale)
		self.BuyCredits.BackgroundColor = ui.col.DarkGreen
		self.BuyCredits:SizeToContents()
		self.BuyCredits:SetSize(self.BuyCredits:GetWide() + 10, f4.btnClose:GetTall())
		self.BuyCredits:SetPos(f4.btnClose.x - self.BuyCredits:GetWide() + 1, 0)
		self.BuyCredits.DoClick = function(s)
			gui.OpenURL(rp.cfg.CreditsURL .. LocalPlayer():SteamID())
		end

		self.UsePromo = ui.Create('DButton', f4)
		self.UsePromo:SetText('Промокод')
		self.UsePromo.BackgroundColor = ui.col.DarkGreen
		self.UsePromo:SizeToContents()
		self.UsePromo:SetSize(self.UsePromo:GetWide() + 10, f4.btnClose:GetTall())
		self.UsePromo:SetPos(self.BuyCredits.x - self.UsePromo:GetWide() + 1, 0)
		self.UsePromo.DoClick = function(s)
			ui.StringRequest('Использовать Промокод', 'Введите промокод', '', function(resp)
				cmd.Run('promocode', resp)
			end)
		end
	end

	if IsValid(self.CreditsBalance) then
		self.CreditsBalance:Show()
	elseif IsValid(f4) then
		self.CreditsBalance = ui.Create('DButton', f4)
		self.CreditsBalance:SetDisabled(true)
		self.CreditsBalance.TextColor = rp.col.Yellow
		self.CreditsBalance:SetText(string.Comma(LocalPlayer():GetCredits()) .. ' Cr')
		self.CreditsBalance:SizeToContents()
		self.CreditsBalance:SetSize(self.CreditsBalance:GetWide() + 10, f4.btnClose:GetTall())
		self.CreditsBalance:SetPos(self.UsePromo.x - self.CreditsBalance:GetWide() + 1, 0)
	end
end

function PANEL:HideControls()
	if IsValid(self.BuyCredits) then
		self.BuyCredits:Hide()
	end

	if IsValid(self.UsePromo) then
		self.UsePromo:Hide()
	end

	if IsValid(self.CreditsBalance) then
		self.CreditsBalance:Hide()
	end
end

function PANEL:AddUpgrades(upgrades)
	local sortedUpgrades = {
		Purchased = {}
	}

	for k, v in ipairs(upgradeCatOrder) do
		sortedUpgrades[v] = {}
	end

	for k, v in ipairs(upgrades) do
		local category = v.Upgrade:GetCat()

		if (not upgradeCats[category]) then
			--print('Unsuppored category: ' .. category)
			continue
		end

		if v.HasPurchased then
			table.insert(sortedUpgrades['Purchased'], v)
		else
			table.insert(sortedUpgrades[category], v)
		end

		-- TODO: sort more here - canAfford, cannotAfford, purchased
	end

	for id, cat in pairs(upgradeCatOrder) do
		local upgrades = sortedUpgrades[cat] or {}

		local size = (self.List:GetWide() * 0.20) + 1
		local parent = ui.Create('ui_collapsible_section', function(s)
			s:SetText(cat)
			s.OnCollapsing = function()
				self.List:InvalidateLayout()
			end
		end)
		self.List:AddItem(parent)

		local i, y = 0, 0
		for k, v in ipairs(upgrades) do
			if (i == 5) then
				i = 0
				y = y + (size - 1)
			end

			parent:AddItem(ui.Create('rp_creditshop_item', function(s)
				s.CanBuy 		= v.CanBuy
				s.CanBuyReason	= v.CanBuyReason
				s.HasPurchased	= v.HasPurchased
				s.Price 		= v.Price

				s:SetUpgrade(v.Upgrade)

				s:SetSize(size, size)
				s:SetPos((i * size) - i, y)
			end))

			i = i + 1
		end

		parent:SetTall(y + (size - 1))
	end
end

function PANEL:DoClick(itemPnl, upgrade)
	self.Upgrade = upgrade

	self.Info:Hide()

	self.Price:Show()
	self.Purchase:Show()
	self.Purchase:SetDisabled(false)

	if itemPnl.CanBuyReason then
		self.Error:Show()

		self.Error:SetText(itemPnl.CanBuyReason)
		self.Error:SizeToContents()
		self.Error:SetPos((self:GetWide() * 0.75) - (self.Error:GetWide() * 0.5), 60)

		if (not itemPnl.CanBuyReason:StartWith('Вы не можете себе это позволить')) then
			self.Purchase:SetDisabled(true)
		end
	else
		self.Error:Hide()
	end

	self.Name:SetText(upgrade:GetName())

	self.Price:SetText(string.Comma(itemPnl.Price) .. ' Cr')
	self.Price:SizeToContents()
	self.Price:SetPos((self:GetWide() * 0.75) - (self.Price:GetWide() * 0.5), 40)

	for k, v in ipairs(self.Container:GetChildren()) do
		v:Remove()
	end

	self.Container.HasPurchased = itemPnl.HasPurchased
	upgradeCats[upgrade:GetCat()](upgrade, self.Container)
end

vgui.Register('rp_creditshop_panel', PANEL, 'Panel')

local PANEL = {}

function PANEL:Init()
	self:SetText('')
end

function PANEL:DoClick()
	fr:DoClick(self, self.Upgrade)

	fr.Selected = self
end

function PANEL:PerformLayout(w, h)
	if self.SpawnIcon then
		self.SpawnIcon:SetPos(10, 10)
		self.SpawnIcon:SetSize(w - 20, h - 20)
	end

	self.BaseClass.PerformLayout(self, w, h)
end

local color_bar_buyable = ui.col.SUP:Copy()
color_bar_buyable.a = 50

local color_bar_canbuy = ui.col.Red:Copy()
color_bar_canbuy.a = 50

local color_bar_purchased = ui.col.FlatBlack:Copy()
--color_bar_purchased.a = 50

function PANEL:Paint(w, h)
	draw.Outline(0, 0, w, h, ui.col.Outline)

	if (fr.Selected == self) then
		draw.Box(1, 20, w - 2, h - 40, ui.col.Hover)
	end

	if self.Upgrade:GetImage() then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(self.Upgrade:GetImage())
		surface.DrawTexturedRect(25, 25, w - 50, w - 50)
	end

	local color_bar = color_bar_buyable

	local canAfford = LocalPlayer():CanAffordCredits(self.Price)
	if (not self.CanBuy) then
		color_bar = color_bar_canbuy
	end

	if self.HasPurchased and (not self.Upgrade:IsStackable()) then
		color_bar = color_bar_purchased
	end

	-- TODO: support already purchased/errors here

	draw.Box(1, 1, w - 2, 20, color_bar)
	draw.SimpleText(self.Upgrade:GetName():MaxCharacters(19, true), 'ui.17', w * 0.5, 11, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- TODO: Better solution for long names

	draw.Box(1, h - 21, w - 2, 20, color_bar)
	draw.SimpleText(string.Comma(self.Price) .. ' Cr', 'ui.17', w * 0.5, h - 11, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if (fr.Selected == self) then
		draw.Outline(1, 1, w - 2, h - 2, ui.col.White)
	end
end

function PANEL:SetUpgrade(upgrade)
	self.Upgrade = upgrade

	if upgrade:GetIcon() then
		self.SpawnIcon = ui.Create('SpawnIcon', self)
		self.SpawnIcon:SetSize(self:GetWide() - 30, self:GetTall() - 30)
		self.SpawnIcon:SetModel(upgrade:GetIcon(), upgrade.SkinIndex)
		self.SpawnIcon.DoClick = function() self.DoClick(self) end
		self.SpawnIcon.Paint = function() end
		self.SpawnIcon.PaintOver = function() end
		self.SpawnIcon:SetToolTip(nil)
	end
end

vgui.Register('rp_creditshop_item', PANEL, 'DButton')

net('rp.shop.Menu', function()
	local ret = {}
	for i = 1, net.ReadUInt(9) do
		ret[i] = {}
		ret[i].ID = net.ReadUInt(9)
		ret[i].CanBuy = net.ReadBool()
		if (not ret[i].CanBuy) then
			ret[i].CanBuyReason = net.ReadString()
		end
		ret[i].HasPurchased = net.ReadBool()
		ret[i].Price = net.ReadUInt(32)
		ret[i].Upgrade = rp.shop.GetTable()[ret[i].ID]
	end

	table.sort(ret, function(a, b)
		return a.Price < b.Price
	end)

	if LocalPlayer():IsAdmin() and (upgradeCatOrder[2] == 'Ranks') then
		local ranks = table.remove(upgradeCatOrder, 2)
		table.insert(upgradeCatOrder, 7, ranks)
	end

	if IsValid(fr) then
		fr:AddUpgrades(ret)

		fr.IsLoaded = true
	else
		rp.ToggleF4Menu(true)
	end
end)
