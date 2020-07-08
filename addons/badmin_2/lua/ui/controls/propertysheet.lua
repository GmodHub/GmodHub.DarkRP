local PANEL = {}

function PANEL:Paint(w, h)
	derma.SkinHook('Paint', 'PropertySheet', self, w, h)
end

function PANEL:DockToFrame()
	local p = self:GetParent()
	local x, y = p:GetDockPos()
	self:SetPos(x, y -5)
	self:SetSize(p:GetWide() - 10, p:GetTall() - y)
end

vgui.Register('ui_propertysheet', PANEL, 'DPropertySheet')
