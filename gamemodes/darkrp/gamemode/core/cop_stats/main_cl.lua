
local quickSets = {
	{
		Name = "Джаггернаут",
		Defense = 20,
		Attack = 5,
		Speed = 5,
		Fill = "Attack"
	},
	{
		Name = "Скаут",
		Defense = 5,
		Attack = 5,
		Speed = 20,
		Fill = "Attack"
	},
	{
		Name = "Элита",
		Defense = 5,
		Attack = 20,
		Speed = 5,
		Fill = "Speed"
	},
	{
		Name = "Шпион",
		Defense = 0,
		Attack = 0,
		Speed = 10
	},
	{
		Name = "Снайпер",
		Defense = 0,
		Attack = 0,
		Speed = 0
	}
}

local function scaleColor(tCol, val)
	local perc = val / 100;
	local mod = (perc * 2) * 255;

	if (perc < 0) then
		tCol.r = 255;
		tCol.g = 255 + mod;
		tCol.b = 255 + mod;
	else
		tCol.r = 255 - mod;
		tCol.g = 255;
		tCol.b = 255 - mod;
	end
end

function rp.OpenGenomeEditor(maxPoints, points, customModel)
	LocalPlayer().SelectingGenome = true

	local fr = ui.Create('ui_frame', function(self)
		self:SetSize(800, 600)
		self:Center()
		self:SetTitle('Измените свой геном')
		self:MakePopup()
	end)

	local darkener = ui.Create('Panel', function(self)
		self:SetPos(0, fr.btnClose:GetTall() + 1)
		self:SetSize(fr:GetWide(), fr:GetTall() - fr.btnClose:GetTall())
		self.Paint = function(self, w, h)
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawRect(0, 0, w, h)
		end
	end, fr)

	local const

	if (customModel) then
		local modelPan = ui.Create('DModelPanel', function(self)
			self:SetSize(fr:GetWide() * 0.5, fr:GetTall())
			self:SetPos(fr:GetWide() * 0.63, 0)

			local updateInfo = function()
				local distPoints = const:GetPoints()

				local n, m = rp.GetGenomeSpecialName(distPoints.Defense.Value, distPoints.Speed.Value, distPoints.Attack.Value)

				self:SetModel(m)
				self:SetFOV(60)
			end

			self.ot = self.Think or function() end
			self.Think = function(s) updateInfo() s:ot() end
			self:SetMouseInputEnabled(false)
		end, fr)
	end

	local tCol = Color(255, 255, 255)
	local statChanges = ui.Create('Panel', function(self)
		self:SetPos(0, 24)
		self:SetWide(fr:GetWide() * 0.4)
		self.Paint = function(self, w, h)
			local distPoints, totalPoints, remPoints = const:GetPoints();
			local y = 5
			local LO = rp.GetGenomeLoadout(distPoints.Defense.Value, distPoints.Speed.Value, distPoints.Attack.Value)

			surface.SetFont('ui.22')
			surface.SetTextColor(200, 200, 200)
			local _, th = surface.GetTextSize('Характеристики')
			surface.SetTextPos(5, y)
			surface.DrawText('Характеристики')

			y = y + th - 3

			tCol.r = 255 tCol.g = 255 tCol.b = 255

			surface.SetFont('ui.20')
			local val = (distPoints.Defense.Value - 10) * 2.5
			local line = (val < 0 and "" or "+") .. val .. "% Сопротивления Урону"
			_, th = surface.GetTextSize(line)
			scaleColor(tCol, val)
			surface.SetTextColor(tCol)
			surface.SetTextPos(15, y)
			surface.DrawText(line)

			y = y + th - 3

			val = (distPoints.Attack.Value - 10) * 2.5
			line = 100 + val .. "% Нанесения Урона"
			scaleColor(tCol, val)
			surface.SetTextColor(tCol)
			surface.SetTextPos(15, y)
			surface.DrawText(line)

			y = y + th - 3

			val = (distPoints.Speed.Value - 10) * 2.5

			if (val > 0) then
				val = val * 0.6
			end
			line = 100 + math.floor(val) .. "% Скорость"
			scaleColor(tCol, val)
			surface.SetTextColor(tCol)
			surface.SetTextPos(15, y)
			surface.DrawText(line)

			y = y + th

			surface.SetFont('ui.22')
			surface.SetTextColor(200, 200, 200)
			_, th = surface.GetTextSize('Снаряжение')
			surface.SetTextPos(5, y)
			surface.DrawText('Снаряжение')

			y = y + th - 3

			surface.SetFont('ui.20')
			for k, v in pairs(LO) do
				if (k == 6) then
					surface.SetTextColor(50, 50, 255, 255)
				elseif (k == 7) then
					surface.SetTextColor(255, 0, 0, 255)
				elseif (k == 8) then
					surface.SetTextColor(0, 255, 0, 255)
				elseif (k >= 9) then
					if (distPoints.Attack.Value == 20) then
						surface.SetTextColor(255, 0, 0, 255)
					else
						surface.SetTextColor(150, 150, 150, 255)
					end
				else
					surface.SetTextColor(255, 255, 255, 255)
				end

				local twLine, thLine = surface.GetTextSize(v);
				surface.SetTextPos(15, y);
				surface.DrawText(v);

				y = y + thLine - 2
			end

			self:SetTall(y)
		end

		self:SetMouseInputEnabled(false)
	end, fr)

	const = ui.Create('rp_constellation', function(self)
		self:SetSize(fr:GetWide(), fr:GetTall() * 0.75)
		self:SetPoints(maxPoints, 20, points)

		self:Center()
	end, fr)

	local remPoints = ui.Create('Panel', function(self)
		self:SetSize(fr:GetWide(), 35)
		self:SetPos(0, 24)
		self.Paint = function(self, w, h)
			surface.SetFont('ui.22')
			surface.SetTextColor(ui.col.White)
			local distPoints, totalPoints, remPoints = const:GetPoints()
			local str = remPoints .. ' очков осталось'
			local tw, th = surface.GetTextSize(str)
			surface.SetTextPos((w - tw) * 0.5, 5)
			surface.DrawText(str)
		end
		self:SetMouseInputEnabled(false)
	end, fr)

	-- Quickset Buttons
	local quickSetWidth = (fr:GetWide() - (#quickSets + 1) * 5) / #quickSets
	local quickSetHeight = 30
	for k, v in ipairs(quickSets) do
		local btn = ui.Create('DButton', function(self)
			self:SetText(v.Name)
			self:SetSize(quickSetWidth, quickSetHeight)
			self:SetPos(5 + (k - 1) * (5 + quickSetWidth), fr:GetTall() - 5 - quickSetHeight)

			self.DoClick = function()
				const:UpdateStat("Defense", v.Defense, true)
				const:UpdateStat("Attack", v.Attack, true)
				const:UpdateStat("Speed", v.Speed, true)

				if (v.Defense + v.Attack + v.Speed < maxPoints and v.Fill != nil) then
					const:UpdateStat(v.Fill, maxPoints - (v.Fill != "Attack" and v.Attack or 0) - (v.Fill != "Defense" and v.Defense or 0) - (v.Fill != "Speed" and v.Speed or 0), true)
				end
			end
		end, fr)
	end

	local confirm = ui.Create('DButton', function(self)
		self:SetText('Готово')
		self:SetSize(80, fr.btnClose:GetTall())
		self:SetPos(fr:GetWide() - 80, 0)
		self.Active = true
		self:SetBackgroundColor(Color(0, 200, 0, 100))
		self.DoClick = function(self)
			LocalPlayer().SelectingGenome = nil
			local points = const:GetPoints()

			net.Start('rp.ApplyGenome')
				net.WriteUInt(points.Defense.Value, 5)
				net.WriteUInt(points.Speed.Value, 5)
				net.WriteUInt(points.Attack.Value, 5)
			net.SendToServer()
			fr:Close()
		end
	end, fr)

	fr.btnClose:SetVisible(false)
end

net.Receive('rp.ApplyGenome', function(len)
	local max = net.ReadUInt(6)
	local customModel = net.ReadBool()

	local points = {}

	if (net.ReadBool()) then -- uses existing points
		points.Defense = net.ReadFloat()
		points.Speed = net.ReadFloat()
		points.Attack = net.ReadFloat()
	else
		points.Defense = 10
		points.Speed = 10
		points.Attack = 10
	end

	rp.OpenGenomeEditor(max, points, customModel)
end)
