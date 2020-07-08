dash.IncludeSH 'shared.lua'

function ENT:Draw()
	self:DrawModel()
end

function ENT:SendPlayerUse(ignoreValidate)
	net.Start 'rp.EntityUse'
		net.WriteEntity(self)
		net.WriteBool(ignoreValidate == true)
	net.SendToServer()
end

function ENT:ReadPlayerUse()

end

function ENT:BasicPriceMenu()
	if IsValid(self.Menu) then self.Menu:Close() end

	local ent = self

	if (ent:GetPos():Distance(LocalPlayer():GetPos()) >= 80) then return end

	local w, h = 160, 160
	self.Menu = ui.Create('ui_frame', function(self)
		self:SetTitle(ent.PrintName)
		self:SetSize(w, h)
		self:Center()
		self:MakePopup()
		self.Think = function()
			if (not IsValid(ent)) or (ent:GetPos():Distance(LocalPlayer():GetPos()) >= 80) then
				ent.Menu:Close()
			end
		end
		self:Center()
	end)

	ui.Create('rp_entity_priceset', function(self, p)
		self:SetEntity(ent)
		self:SetPos(p:GetDockPos())
		self:SetWide(w - 10)
	end, self.Menu)

	ui.Create('DButton', function(self, p)
		self:SetPos(5, h - 35)
		self:SetSize(w - 10, 30)
		self:SetText('Buy')
		self.DoClick = function()
			ent:SendPlayerUse()
		end
	end, self.Menu)
end

net('rp.EntityUse', function()
	local ent = net.ReadEntity()

	if ent.PlayerUse then
		ent:PlayerUse(ent:ReadPlayerUse())
	end
end)


local PANEL = {}

function PANEL:Init()
	self.Label = ui.Create('DLabel', function(self, p)
		self:SetFont('ui.18')
		self:SetColor(ui.col.ButtonText)
		self:SetText('Price: ')
	end, self)

	self.PriceInput = ui.Create('DTextEntry', self)

	self.SetPrice = ui.Create('DButton', self)
	self.SetPrice:SetText('Set Price')
	self.SetPrice.Think = function(s)
		if (not IsValid(self.Entity)) then return end

		local value = tonumber(self.PriceInput:GetValue())
		if (value == nil) then
			s:SetDisabled(true)
			s:SetText('Invalid Price!')
		elseif (value < self.Entity.MinPrice) then
			s:SetDisabled(true)
			s:SetText('Price too low')
		elseif (value > self.Entity.MaxPrice) then
			s:SetDisabled(true)
			s:SetText('Price too high')
		elseif (self.Entity:Getprice() == value) then
			s:SetDisabled(true)
			s:SetText('Choose a new price')
		else
			s:SetDisabled(false)
			s:SetText('Set Price')
		end
	end
	self.SetPrice.DoClick = function()
		cmd.Run('setprice', self.PriceInput:GetValue())
	end

	self:SetTall(85)
end

function PANEL:PerformLayout(w, h)
	self.Label:SetPos(0, 0)
	self.Label:SizeToContents()

	self.PriceInput:SetPos(0, 20)
	self.PriceInput:SetSize(w, 30)

	self.SetPrice:SetPos(0, 55)
	self.SetPrice:SetSize(w, 30)
end

function PANEL:Paint()
end

function PANEL:SetEntity(ent)
	self.Entity = ent
	self.PriceInput:SetText(ent:Getprice())
end

vgui.Register('rp_entity_priceset', PANEL, 'Panel')
