dash.IncludeSH 'shared.lua'

ENT.IconMaterial = Material 'gmh/entities/npcs/sasha.png'

local fr
function ENT:PlayerUse()
	if IsValid(fr) then fr:Close() end

	local hasLicense = LocalPlayer():HasLicense()

	fr = ui.Create('ui_frame', function(self)
		self:SetTitle('Саша')
		if hasLicense then
			self:SetSize(450, 500)
		else
			self:SetSize(390, 80)
		end

		self:Center()
		self:MakePopup()
	end)

	local buyPerc = math.Round(100 * (nw.GetGlobal('SashaPrice') or 1))

	ui.Create('DLabel', function(self, p)
		self:SetPos(5, 30)
		self:SetText(hasLicense and ('Я покупаю пушки. У тебя есть что-то для меня?\nЯ покупаю за ' .. buyPerc .. '% от цены прямо сейчас\nПросто поднеси товар ко мне.') or 'Тебе нужна лицензия на оружие, парнишка.\nТы пытаешься сослать меня в гулаг?')
		self:SizeToContents()
	end, fr)

	if (not hasLicense) then return end

	ui.Create('DLabel', function(self, p)
		self:SetPos(5, 100)
		self:SetText('Вот мои расценки:')
		self:SizeToContents()
	end, fr)

	ui.Create('ui_listview', function(self)
		self:SetPos(5, 125)
		self:SetSize(440, 370)
		self:AddSpacer('Цены:')
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
