local PANEL = {}

function PANEL:Init()
	self.tabList = ui.Create('ui_scrollpanel', function(list)
		list:SetSize(160, 0)
		list:Dock(LEFT)
		list:SetPadding(-1)
	end, self)

	self.Buttons = {}
end

function PANEL:GetButtons()
	return self.Buttons
end

function PANEL:SetActiveTab(num)
	self.ActiveTabID = num

	for k, v in ipairs(self.Buttons) do
		v.Active = (num == k)

		if IsValid(v.Tab) and v.Tab:IsVisible() then
			v.Tab:Dock(NODOCK)
			v.Tab:SetVisible(false)
		end

		if (num == k) then
			if (not v.FinishedLayout) then
				v:LayoutTab()
			end

			v.Tab:SetVisible(true)
			v.Tab:DockMargin(0, 0, 0, 0)
			v.Tab:Dock(FILL)

			self:TabChanged(v.Tab)
		end
	end
end

function PANEL:TabChanged(tab)

end

function PANEL:GetActiveTab()
	for k, v in ipairs(self.Buttons) do
		if (v.Active) then
			return v.Tab
		end
	end
end

function PANEL:GetActiveTabID()
	return self.ActiveTabID
end

local function newbtn(title, tab, func)
	local button = ui.Create('DButton', function(btn)
		btn:SetSize(0, 38)
		btn:SetText(title)
		btn:SetFont('ui.24')
		btn:SetTextColor(ui.col.White)

		btn.DoClick = function(self)
			func(self)
		end

		btn.Paint = function(btn, w, h)
			derma.SkinHook('Paint', 'TabButton', btn, w, h)
		end
	end)

	function button:PerformLayout()
		if IsValid(self.m_Image) then
			self:SetContentAlignment(4)
			self.m_Image:SetPos(1, 1)
			self.m_Image:SetSize(36, 36)
			self:SetTextInset(self.m_Image:GetWide() + 5, 0)
		end
		DLabel.PerformLayout(self)
	end

	return button
end

function PANEL:AddTab(title, callback, active)
	local button = newbtn(title, tab, function(s)
		if (not s.FinishedLayout) then
			s:LayoutTab()
		end

		self:SetActiveTab(s.ID)
	end)

	function button.LayoutTab(s)
		local tab = isfunction(callback) and callback(self) or callback

		tab.Paint = function(tab, w, h) end
		tab:SetSize(self:GetWide() - 160, self:GetTall())
		tab:SetVisible(false)
		tab:SetParent(self)
		tab:SetSkin(self:GetSkin().PrintName)

		s.Tab = tab
		s.FinishedLayout = true
	end

	if (not isfunction(callback)) then
		button:LayoutTab()
	end

	button.ID = table.insert(self.Buttons, button)
	self.tabList:AddItem(button)

	if active then
		self:SetActiveTab(button.ID)
	end

	return button
end

local fr
function PANEL:AddButton(title, func)
	local button = newbtn(title, tab, func)

	self.tabList:AddItem(button)
	table.insert(self.Buttons, btn)

	fr = self
	return button
end

function PANEL:DockToFrame()
	local p = self:GetParent()
	local x, y = p:GetDockPos()
	y = y - 6
	self:SetPos(0, y)
	self:SetSize(p:GetWide(), p:GetTall() - y)
end

function PANEL:Paint(w, h)
	derma.SkinHook('Paint', 'TabListPanel', self, w, h)
end

vgui.Register('ui_tablist', PANEL, 'Panel')