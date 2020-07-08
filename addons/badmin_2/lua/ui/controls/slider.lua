local PANEL = {}

function PANEL:Init()
	self.ButtonContainer = ui.Create('Panel', self)
	self.ButtonContainer.Paint = function() end

	self.Button = ui.Create('DButton', self.ButtonContainer)
	self.Button.OnMousePressed = function(s, mb) if (mb == MOUSE_LEFT) then self:StartDrag() end end
	self.Button:SetText('')
	self.Button.Paint = function(self, w, h)
		derma.SkinHook('Paint', 'SliderButton', self, w, h)
	end

	self:SetValue(0.5)
end

function PANEL:PerformLayout()
	self:SetTall(20)

	self.ButtonContainer:SetPos(40, 0)
	self.ButtonContainer:SetSize(self:GetWide() - 40, self:GetTall())

	self.Button:SetSize(20, 20)
	self.Button:SetPos(self.Value * (self.ButtonContainer:GetWide() - 20), 0)
end

function PANEL:Paint(w, h)
	derma.SkinHook('Paint', 'UISlider', self, w, h)
end

function PANEL:Think()

	if (self.Dragging) then
		local mx, my = self:CursorPos()
		mx = mx - 40
		mx = math.Clamp(mx - self.OffX, 0, self.ButtonContainer:GetWide() - 20)

		if (self.Button.x != mx) then
			self:SetValue(mx / (self.ButtonContainer:GetWide() - 20))
			self:OnChange(self.Value)
		end

		if (!input.IsMouseDown(MOUSE_LEFT)) then
			self:EndDrag()
		end
	end
end

function PANEL:StartDrag()
	self.Dragging = true
	self.OffX = self.Button:CursorPos()
end

function PANEL:EndDrag()
	self.Dragging = false
	self:OnMouseReleased(self.Value)
end

function PANEL:OnMouseReleased(val)
end

function PANEL:OnChange(val)
end

function PANEL:SetValue(val)
	self.Value = val
	self.Button:SetPos(val * (self.ButtonContainer:GetWide() - 20), 0)
end

function PANEL:GetValue()
	return self.Value
end

vgui.Register('ui_slider', PANEL, 'Panel')