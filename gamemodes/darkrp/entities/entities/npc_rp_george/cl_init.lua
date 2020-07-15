dash.IncludeSH 'shared.lua'

ENT.IconMaterial = Material 'gmh/entities/npcs/george.png'

local fr
function ENT:PlayerUse()
	if IsValid(fr) then fr:Close() end

	fr = ui.Create('ui_frame', function(self)
		self:SetTitle('Отец Григорий')
		self:SetSize(315, 170)

		self:Center()
		self:MakePopup()
	end)

	local lbl = ui.Create('DLabel', function(self, p)
		self:SetPos(5, 30)
		self:SetText('Освободи себя от тьмы.\nЗамоли грехи своими деньгами.\nПожертвование увеличит карму.')
		self:SizeToContents()
	end, fr)

	local txt = ui.Create('DTextEntry', function(self, p)
		self:SetPos(5, lbl.y + lbl:GetTall() + 5)
		self:SetSize(p:GetWide() - 10, 30)
		self:SetValue('1000')
	end, fr)

	ui.Create('DButton', function(self, p)
		self:SetPos(5, txt.y + txt:GetTall() + 5)
		self:SetSize(p:GetWide() - 10, 30)
		self:SetText('Приобрести Карму')
		self.Think = function(s)
			local value = tonumber(txt:GetValue())
			if (value == nil) or (value < 0) then
				self:SetDisabled(true)
				self:SetText('Недействительная сумма!')
			elseif (value < rp.cfg.MoneyPerKarma) then
				self:SetDisabled(true)
				self:SetText('Сумма слишком мала!')
			elseif (value > LocalPlayer():GetMoney()) then
				self:SetDisabled(true)
				self:SetText('Недостаточно средств!')
			else
				self:SetDisabled(false)
				self:SetText('Купить ' .. string.Comma(math.floor(value/rp.cfg.MoneyPerKarma)) .. ' Кармы')
			end
		end
		self.DoClick = function()
			cmd.Run('buykarma', math.floor(tonumber(txt:GetValue())/rp.cfg.MoneyPerKarma))
		end
	end, fr)

end
