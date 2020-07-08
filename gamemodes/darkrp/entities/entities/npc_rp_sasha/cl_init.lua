dash.IncludeSH 'shared.lua'

ENT.IconMaterial = Material 'sup/entities/npcs/sasha.png'

local fr
function ENT:PlayerUse()
	if IsValid(fr) then fr:Close() end

	local hasLicense = LocalPlayer():HasLicense()

	fr = ui.Create('ui_frame', function(self)
		self:SetTitle('Sasha')
		if hasLicense then
			self:SetSize(450, 500)
		else
			self:SetSize(300, 80)
		end

		self:Center()
		self:MakePopup()
	end)

	local buyPerc = math.Round(100 * (nw.GetGlobal('SashaPrice') or 1))

	ui.Create('DLabel', function(self, p)
		self:SetPos(5, 30)
		self:SetText(hasLicense and ('I buy gun. You got gun?\nI buy for ' .. buyPerc .. '% value right now\nJust gravity gun into me.') or 'You need gun license comrade.\nYou trying to get me sent to gulag?')
		self:SizeToContents()
	end, fr)

	if (not hasLicense) then return end

	ui.Create('DLabel', function(self, p)
		self:SetPos(5, 100)
		self:SetText('Here are price:')
		self:SizeToContents()
	end, fr)

	ui.Create('ui_listview', function(self)
		self:SetPos(5, 125)
		self:SetSize(440, 370)
		self:AddSpacer('Prices:')
		for k, v in ipairs(rp.Weapons) do

			self:AddItem(ui.Create('DButton', function(self)
				self:SetText(v.Name .. ' - ' .. rp.FormatMoney(math.Round(v.BuyPrice * (nw.GetGlobal('SashaPrice') or 1))))
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