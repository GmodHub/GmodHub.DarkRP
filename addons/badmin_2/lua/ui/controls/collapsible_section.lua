local PANEL = {}

function PANEL:Init()
	self.Collapsed = false

	self.Header = ui.Create('DButton', self)
	self.Header:SetDisabled(true)
	self.Header.Paint = function(s, w, h)
		derma.SkinHook("Paint", "Button", s, w, h)

		if s:IsHovered() or self.CollapseBtn:IsHovered() then
			draw.Box(1, 1, w - 2, h - 2, ui.col.Hover)
		end
	end
	self.Header.OnMousePressed = function(s, key)
		if (key == MOUSE_LEFT) then
			self:Collapse(not self:IsCollapsed())
		end
	end


	self.CollapseBtn = ui.Create('DButton', self)
	self.CollapseBtn:SetText('▼')
	self.CollapseBtn:SetToolTip('Collapse')
	self.CollapseBtn:SetTextColor(ui.col.Green)
	self.CollapseBtn.Paint = function() end
	self.CollapseBtn.DoClick = function()
		self:Collapse(not self:IsCollapsed())
	end

	self.Container = ui.Create('DPanel', self)
end

function PANEL:SetTall(h)
	self.OriginalTall = h + 30
	self.BaseClass.SetTall(self, self.OriginalTall)
end

function PANEL:SetText(text)
	self.Header:SetText(text)
end

function PANEL:AddItem(item)
	item:SetParent(self.Container)
end

function PANEL:Collapse(collapsed, noAnim)
	self.Collapsed = collapsed

	local targetH = collapsed and 30 or self.OriginalTall
	if noAnim then
		self.BaseClass.SetTall(self, targetH)
	else
		self.TargetHeight = targetH
	end

	self.CollapseBtn:SetTextColor(collapsed and ui.col.White or ui.col.Green)
	self.CollapseBtn:SetToolTip(collapsed and 'Больше' or 'Меньше')
	self.CollapseBtn:SetText(collapsed and '◀' or '▼')
end

function PANEL:IsCollapsed()
	return self.Collapsed
end

function PANEL:OnCollapsing()

end

function PANEL:Think()
	if self.TargetHeight and (self:GetTall() ~= self.TargetHeight) then
		local tall = self:GetTall()
		local mul = tall > self.TargetHeight and -1 or 1

		tall = tall + FrameTime() * (tall - self.TargetHeight * -mul) * 8 * mul
		if (math.abs(tall - self.TargetHeight) < 1) then
			tall = self.TargetHeight

			self.TargetHeight = nil
		end

		self.BaseClass.SetTall(self, tall)
		self.OnCollapsing(self)
	end
end

function PANEL:PerformLayout(w, h)
	self.Header:SetPos(0, 0)
	self.Header:SetSize(w, 30)

	self.Container:SetPos(0, 29)
	self.Container:SetSize(w, h - 29)

	self.CollapseBtn:SetPos(w - 30, 0)
	self.CollapseBtn:SetSize(30, 30)
end

vgui.Register('ui_collapsible_section', PANEL, 'DPanel')
