local PANEL = {}

Derma_Hook(PANEL, 'Paint', 'Paint', 'UIListView')

function PANEL:Init()
	self.Rows = {}
	self.SearchResults = {}
	self.HideInvisible = true
	self.RowHeight = 25
	self:SetPadding(-1)
end

function PANEL:SetRowHeight(height)
	self.RowHeight = height
end

function PANEL:AddCustomRow(row, disabled)
	self:AddItem(row)

	self.Rows[#self.Rows + 1] = row
	self.SearchResults[#self.SearchResults + 1] = row

	return row
end

function PANEL:AddRow(value, disabled)
	local row = ui.Create('DButton', function(s)
		s:SetText(tostring(value))
		s:SetTall(self.RowHeight)
		if (disabled == true) then
			s:SetDisabled(true)
		end
	end)

	self:AddItem(row)

	self.Rows[#self.Rows + 1] = row
	self.SearchResults[#self.SearchResults + 1] = row

	row.DoClick = function()
		if IsValid(self.Selected) then
			self.Selected.Active = false
		end

		row.Active = true
		self.Selected = row
	end

	return row
end

function PANEL:AddImageRow()
	local btn = ui.Create('ui_imagerow')

	self.Rows[#self.Rows + 1] = btn

	btn.DoClick = function()
		if IsValid(self.Selected) then
			self.Selected.Active = false
		end

		btn.Active = true
		self.Selected = btn
	end

	self:AddItem(btn)
	return btn
end

function PANEL:AddPlayer(pl, steamid64)
	local btn = self:AddImageRow()
	btn:SetPlayer(pl, steamid64)

	return btn
end

function PANEL:AddSpacer(value)
	return self:AddRow(value, true)
end

function PANEL:GetSelected()
	return self.Selected
end

function PANEL:Search(value)
	self.SearchResults = {}

	if (not value) or (value == '') then
		for k, v in ipairs(self.Rows) do
			if IsValid(v) then
				v:SetVisible(true)

				self.SearchResults[#self.SearchResults + 1] = v
			end
		end

		if IsValid(self.NoResultsSpacer) then
			self.NoResultsSpacer:Remove()
		end

		self:PerformLayout()
	else
		local c = 0
		for k, v in ipairs(self.Rows) do
			if (not IsValid(v)) then continue end

			if self:FilterSearchResult(v, value) then
				c = c + 1
				v:SetVisible(true)

				self.SearchResults[#self.SearchResults + 1] = v
			else
				v:SetVisible(false)
			end
		end

		if (c == 0) then
			if IsValid(self.NoResultsSpacer) then
				self.NoResultsSpacer:SetVisible(true)
			else
				self.NoResultsSpacer = self:AddSpacer(self.NoResultsMessage or 'Результатов не найдено!')
			end

		elseif IsValid(self.NoResultsSpacer) then
			self.NoResultsSpacer:SetVisible(false)
		end

		self:PerformLayout()
	end
end

function PANEL:SetNoResultsMessage(msg)
	self.NoResultsMessage = msg
end

function PANEL:GetSearchResults()
	return self.SearchResults
end

function PANEL:FilterSearchResult(row, value)
	return (string.find(row:GetText():lower(), value:lower(), 1, true) ~= nil)
end

vgui.Register('ui_listview', PANEL, 'ui_scrollpanel')