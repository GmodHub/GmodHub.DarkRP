local PANEL = {}

function PANEL:Init()
	self.Vertical = true
	self.Button = ui.Create('DButton', self)
	self.Button.OnMousePressed = function(s, mb) if (mb == MOUSE_LEFT) then s:GetParent():StartDrag() end end
	self.Button:SetText('')
	self:SetValue(0.5)
end

function PANEL:PerformLayout()
	self:SetWide(16)
	self.Button:SetSize(16, 16)
	self.Button:SetPos(0, self.Value * (self:GetTall() - 16))
end

function PANEL:Paint(w, h)
	derma.SkinHook('Paint', 'UISlider', self, w, h)
end

function PANEL:Think()
	if (self.Dragging) then
		local mx, my = self:CursorPos()
		my = math.Clamp(my - self.OffY, 0, self:GetTall() - 16)

		if (self.Button.y != my) then
			self:SetValue(my / (self:GetTall() - 16))
			self:OnChange(self.Value)
		end

		if (!input.IsMouseDown(MOUSE_LEFT)) then
			self:EndDrag()
		end
	end
end

function PANEL:StartDrag()
	self.Dragging = true
	_, self.OffY = self.Button:CursorPos()
end

function PANEL:EndDrag()
	self.Dragging = false
end

function PANEL:OnChange(val)
end

function PANEL:SetValue(val)
	self.Value = val
	self.Button:SetPos(val * (self:GetTall() - 16), 0)
end

function PANEL:GetValue()
	return self.Value
end

vgui.Register('ui_slider_vertical', PANEL, 'Panel')