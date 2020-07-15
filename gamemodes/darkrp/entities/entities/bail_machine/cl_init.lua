dash.IncludeSH 'shared.lua'

local color_white = ui.col.White:Copy()
local color_black = ui.col.Black:Copy()

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	local inView, dist = self:InDistance(125000)

	if (not inView) then return end

	color_white.a = 255 - (dist/500)
	color_black.a = color_white.a

	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), -90)

	cam.Start3D2D((self:GetPos() + self:GetUp() * self:OBBMaxs().z) + Vector(0, 0, 5), ang, 0.15)
		draw.SimpleTextOutlined('Внести Залог', '3d2d', 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
	cam.End3D2D()
end

net.Receive('rp.OpenBail', function()
	local fr = ui.Create('ui_frame', function(self)
		self:SetSize(500, 400)
		self:SetTitle('Залог')
		self:Center()
		self:MakePopup()
	end)

	local list = ui.Create('ui_listview', function(self, p)
		local x, y = p:GetDockPos()
		self:SetPos(x, y)
		self:SetSize(p:GetWide() - 10, p:GetTall() - y - 35)
	end, fr)

	local tbl 	= {}
	local count = net.ReadUInt(8)

	for i= 1, count do
		local pl = net.ReadPlayer()
		if IsValid(pl) then
			list:AddPlayer(pl).Info = {Name = pl:Name(), ReleaseTime = net.ReadUInt(32), SteamID = pl:SteamID()}
		end
	end

	if (count == 0) then
		list:AddSpacer('Нет Заключённых!')
	end

	local btn = ui.Create('DButton', function(self, p)
		self:SetText('Внести Залог')
		self:SetPos(5, p:GetTall() - 30)
		self:SetSize(p:GetWide() - 10, 25)

		function self:Think()
			local selected = list:GetSelected()

			if IsValid(selected) then
				local name 	= selected.Info.Name

				local price = LocalPlayer():IsMayor() and 0 or math.ceil((selected.Info.ReleaseTime - CurTime())/60) * rp.cfg.BailCostPerMin

				if LocalPlayer():IsMayor() or (LocalPlayer():GetMoney() >= price) then
					self:SetText('Внести залог ' .. rp.FormatMoney(price) .. '')
					self:SetDisabled(false)
				else
					self:SetText('Недостаточно Средств!')
					self:SetDisabled(true)
				end
			else
				self:SetText('Заключённый Не Выбран')
				self:SetDisabled(true)
			end
		end

		function self:DoClick()
			cmd.Run('bail', list:GetSelected().Info.SteamID)
			list:GetSelected():Remove()
		end
	end, fr)
end)
