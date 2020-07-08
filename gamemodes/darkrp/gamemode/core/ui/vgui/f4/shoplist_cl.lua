local PANEL = {}

function PANEL:Init()
	self:SetText('')

	self.Model = ui.Create('rp_modelicon', self)
end

function PANEL:PerformLayout()
	self.Model:SetPos(0,0)
	self.Model:SetSize(50,50)
end

function PANEL:PaintOver(w, h)
	draw.SimpleTextOutlined(self.Title, 'ui.22', 60, h * .5, rp.col.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, rp.col.Black)
	draw.SimpleTextOutlined(self.Price, 'ui.22', w - 10, h * .5, rp.col.White, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, rp.col.Black)
end

function PANEL:SetInfo(model, title, price, doclick)
	self.Model:SetModel(model)

	self.Title = title
	self.Price = rp.FormatMoney(price)
	self.DoClick = doclick
	self.Model.DoClick = doclick
end

vgui.Register('rp_shopbutton', PANEL, 'DButton')


PANEL = {}

function PANEL:PerformLayout()
	local c = 0
	local even = false
	for k, v in ipairs(self:GetChildren()) do
		v:SetPos(even and (self:GetWide() * .5) or 0, c * 49)
		v:SetSize(self:GetWide() * .5 + 1, 50)
		if even then
			c = c + 1
		end
		even = (not even)
	end
end

function PANEL:AddItem(model, title, price, doclick)
	local btn = ui.Create('rp_shopbutton', self)
	btn:SetInfo(model, title, price, doclick)
	self:SetTall(math.ceil(#self:GetChildren() * .5) * 49 + 1)
end

vgui.Register('rp_shopcatagory', PANEL, 'Panel')


PANEL = {}

function PANEL:Init()
	local cat

	self.Cats = {}

	self.List = ui.Create('ui_listview', self)
	self.List:SetPadding(0)
	self.List:SetSpacing(-1)
	self.List.Paint = function() end

	self.List:AddSpacer('Ammo'):SetTall(30)
	cat = ui.Create('rp_shopcatagory')
	for k, v in ipairs(rp.ammoTypes) do

		cat:AddItem(v.model, v.amountGiven .. 'x ' .. v.name, v.price, function()
			cmd.Run('buyammo', v.ammoType)
		end)
	end
	self.List:AddItem(cat)

	self.List:AddSpacer('Food'):SetTall(30)
	if (#team.GetPlayers(TEAM_COOK) < 1) or LocalPlayer():GetTeamTable().cook then
		local cat = ui.Create('rp_shopcatagory')
		for k, v in ipairs(rp.Foods) do
			cat:AddItem(v.model, v.name, 50, function()
				cmd.Run('buyfood', v.name)
			end)
		end
		self.List:AddItem(cat)
	else
		local sp = self.List:AddSpacer('Распродано (Найдите повара или микроволновку!)')
		sp:SetTextColor(ui.col.Red)
		sp:SetTall(35)
		sp:SetFont('ui.22')
	end

	for k, v in ipairs(rp.shipments) do
		if (v.allowed[LocalPlayer():Team()] == true) then
			if (not self.Cats['Shipments']) then
				self.List:AddSpacer('Shipments'):SetTall(30)
				self.Cats['Shipments'] = true
				cat = ui.Create('rp_shopcatagory')
			end
			cat:AddItem(v.model, v.name, v.price, function()
				cmd.Run('buyshipment', v.name)
			end)
		end
	end
	self.List:AddItem(cat)

	local enities = {}

	for k, v in ipairs(rp.entities) do
		if (v.allowed[LocalPlayer():Team()] == true) and ((not v.customCheck) or v.customCheck(LocalPlayer())) then
			enities[v.catagory] = enities[v.catagory] or {}
			table.insert(enities[v.catagory], v)
		end
	end

	for name, items in pairs(enities) do
		if (not self.Cats[name]) then
			self.List:AddSpacer(name):SetTall(30)
			self.Cats[name] = true
			cat = ui.Create('rp_shopcatagory')
		end

		for k, v in ipairs(items) do
			cat:AddItem(v.model, v.name, v.pricesep or v.price, function()
				cmd.Run(v.cmd:sub(2))
			end)
		end

		self.List:AddItem(cat)
	end

	self.List:AddItem(cat)
end

function PANEL:PerformLayout()
	self.List:SetPos(5,5)
	self.List:SetSize(self:GetWide() - 10, self:GetTall() - 10)
end

vgui.Register('rp_shoplist', PANEL, 'Panel')
