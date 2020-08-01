local CVAR = FindMetaTable 'Cvar'

function CVAR:ShouldShow()
	return true
end

function CVAR:SetShouldShow(func)
	self.ShouldShow = func
	return self
end

function CVAR:SetCustomElement(elementName)
	self:AddMetadata('Type', 'Custom')
	self.CustomElementName = elementName
	return self
end

function CVAR:GetCustomElement()
	return self.CustomElementName
end

local PANEL = {}

Derma_Hook(PANEL, 'Paint', 'Paint', 'Panel')

function PANEL:Populate(sortOrder)
	local tbl = {}
	for k, v in ipairs(cvar.GetOrderedTable()) do
		if v:GetMetadata('Menu') or v:GetCustomElement() then
			local cat = v:GetMetadata('Category') or v:GetMetadata('Catagory') or 'Другое'
			if (not tbl[cat]) then
				tbl[cat] = {}
			end
			tbl[cat][#tbl[cat] + 1] = v
		end
	end

	local function doCategory(k, v)
		self:SetSpacing(5)

		self:AddSpacer(k)
		for k, v in ipairs(v) do
			if v:ShouldShow() then
				local typ = v:GetMetadata('Type') or 'bool'
				if (typ == 'bool') then
					self:AddItem(ui.Create('DPanel', function(self, p)
						self:SetTall(20)
						self.Paint = function() end
						ui.Create('ui_checkbox', function(self, p)
							self:SetPos(5, 0)
							self:SetText(v:GetMetadata('Menu'))
							self:SetConVar(v:GetName())
							self:SizeToContents()
						end, self)
					end))
				elseif (typ == 'number') then
					self:AddItem(ui.Create('DPanel', function(self, p)
						self:SetTall(40)
						self.Paint = function() end

						ui.Create('DLabel', function(self, p)
							self:SetFont('ui.18')
							self:SetColor(ui.col.ButtonText)
							self:SetText(v:GetMetadata('Menu'))
							self:SizeToContents()
							self:SetTall(14)
							self:SetPos(5, 0)
						end, self)

						ui.Create('ui_slider', function(self, p)
							self:SetValue(v:GetValue())
							self.OnChange = function(s, val) v:SetValue(val) end
							self:SetWide(200)
							self:SetPos(5, 18)
						end, self)
					end))
				elseif (typ == 'Custom') then
					self:AddItem(ui.Create(v:GetCustomElement(), function(self)
						self:SetCvar(v)
					end))
				end
			end
		end
	end

	if (sortOrder) then
		for k, v in ipairs(sortOrder) do
			if (tbl[v]) then
				doCategory(v, tbl[v])
				tbl[v] = nil
			end
		end
	end

	for k, v in pairs(tbl) do
		doCategory(k, v)
	end

	hook.Call('ba.LayoutSettingsPanel', nil, self)
end

function PANEL:DockToFrame()
	local p = self:GetParent()
	local x, y = p:GetDockPos()
	self:SetPos(x, y)
	self:SetSize(p:GetWide() - 10, p:GetTall() - (y + 5))
end

vgui.Register('ui_settingspanel', PANEL, 'ui_listview')