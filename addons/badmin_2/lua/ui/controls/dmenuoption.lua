timer.Simple(0, function()
	local PANEL = vgui.GetControlTable 'DMenuOption'

	PANEL._PerformLayout = PANEL._PerformLayout or PANEL.PerformLayout
	PANEL.PerformLayout = function(self, w, h)
		self._PerformLayout(self, w, h)

		if self:GetSkin() and (self:GetSkin().Name == 'SUP') then
			self:SetTall(25)

			self:SetContentAlignment(5)
		end
	end
end)