local PANEL = {}

function PANEL:SetText(txt)
	self.Label = self.Label or ui.Create('DLabel', self)

	self.Label:SetFont('ui.18')
	self.Label:SetText(txt)
end

function PANEL:PerformLayout() end

function PANEL:SetConVar(var)
	self.Button.DoClick = function()
		self.Button:Toggle()
		cvar.SetValue(var, not cvar.GetValue(var))
	end
	self.Label:SetMouseInputEnabled(true)
	self.Label.OnMousePressed = self.Button.DoClick
	self:SetValue(cvar.GetValue(var) and 1 or 0)
	self:SetTextColor(ui.col.White)
end

function PANEL:SizeToContents()
	local w, h = 40, 20

	self.Button:SetSize(w, h)

	if self.Label then
		self.Label:SizeToContents()

		h = math.max(h, self.Label:GetTall())

		self.Label:SetPos(w + 5, (h - self.Label:GetTall()) * 0.5 - 1)

		w = w + 10 + self.Label:GetWide()
	end

	self:SetSize(w, h)
end

vgui.Register('ui_checkbox', PANEL, 'DCheckBoxLabel')