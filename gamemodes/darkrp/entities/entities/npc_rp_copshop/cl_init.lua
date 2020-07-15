dash.IncludeSH 'shared.lua'

ENT.IconMaterial = Material 'gmh/entities/npcs/copshop.png'

local fr
function ENT:PlayerUse()
	if IsValid(fr) then fr:Close() end

	local isGov = LocalPlayer():IsCP() or LocalPlayer():IsMayor()

	fr = ui.Create('ui_frame', function(self)
		self:SetTitle('Патрик')
		if isGov then
			self:SetSize(ScrW() * .3, ScrH() * .5)
		else
			self:SetSize(300, 55)
		end
		self:Center()
		self:MakePopup()
	end)

	if isGov then
		local list = ui.Create('ui_scrollpanel', function(self, p)
			self:SetSpacing(-1)
			self:DockToFrame()
		end, fr)

		for k, v in pairs(rp.CopItems) do
			list:AddItem(ui.Create('rp_shopbutton', function(self)
				self:SetTall(50)
				self:SetInfo(v.Model, v.Name, v.Price, function()
					cmd.Run('copbuy', v.Name)
				end)
			end))
		end
	else
		ui.Create('DLabel', function(self, p)
			self:SetPos(5, 30)
			self:SetText('Вы не страж порядка!')
			self:SizeToContents()
		end, fr)
	end

end
