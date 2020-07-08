dash.IncludeSH 'shared.lua'

ENT.IconMaterial = Material 'sup/entities/npcs/jerome.png'

local fr
function ENT:PlayerUse()
	if IsValid(fr) then fr:Close() end

	fr = ui.Create('ui_frame', function(self)
		self:SetTitle('Jerome')
		self:SetSize(450, 500)
		self:Center()
		self:MakePopup()
	end)

	local buyPerc = math.Round(100 * (nw.GetGlobal('JeromePrice') or 1))
	local isRich = (buyPerc >= 100)

	ui.Create('DLabel', function(self, p)
		self:SetPos(5, 30)
		self:SetText('Yo yo my man got some dat Sticky Icky?\nMaybe some dat white fluff?\nI\'m buying for ' .. buyPerc .. '% value right now' .. (isRich and ' muh nigga.' or ' young blood.') .. '\nJust gravity gun it into me my man ' .. LocalPlayer():Name() .. '.')
		self:SizeToContents()
	end, fr)

	ui.Create('DLabel', function(self, p)
		self:SetPos(5, 125)
		self:SetText('Here are my prices:')
		self:SizeToContents()
	end, fr)

	ui.Create('ui_listview', function(self)
		self:SetPos(5, 150)
		self:SetSize(440, 345)
		self:AddSpacer('Prices:')
		for k, v in ipairs(rp.Drugs) do

			self:AddItem(ui.Create('DButton', function(self)
				self:SetText(v.Name .. ' - ' .. rp.FormatMoney(math.Round(v.BuyPrice * (nw.GetGlobal('JeromePrice') or 1))))
				self:SetTall(50)

				ui.Create('rp_modelicon', function(self)
					self:SetPos(0, 0)
					self:SetSize(50, 50)
					self:SetModel(v.Model)
					self:SetToolTip(v.Name)
				end, self)
			end, self))
		end
	end, fr)
end