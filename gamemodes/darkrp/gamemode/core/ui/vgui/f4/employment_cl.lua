local PANEL = {}

function PANEL:Init()
	local function addEmployee(self, pl, txtFunc, tool, doclick)
		self.Count = self.Count + 1

		self:AddItem(ui.Create('ui_imagerow', function(s)
			s:SetPlayer(pl)
			s:SetToolTip(tool)
			s:SetText('')
			s.Paint = function(s, w, h)
				if (not IsValid(s.Player)) then return end

				derma.SkinHook('Paint', 'ImageRow', s, w, h)

				draw.SimpleText(pl:Name(), 'ui.20', 31, h * 0.5, ui.col.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText(txtFunc(pl), 'ui.20', w - 5, h * 0.5, ui.col.White, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			end
			s.DoClick = doclick
			s.Think = function()
				if (not IsValid(s.Player)) then s:Remove() end
			end
		end))
	end

	self.HireablePlayers = ui.Create('ui_listview', self)
	self.HireablePlayers:AddSpacer('Нанять Работника'):SetTall(30)
	self.HireablePlayers.Count = 0
	self.HireablePlayers.AddEmployee = function(s, v)
		addEmployee(s, v, v.GetJobName, 'Нанять', function(s)
			ui.BoolRequest('Нанять Работника', 'Вы уверены, что хотите нанять ' .. v:Name() .. '?', function(ans)
				if ans then
					cmd.Run('hire', v:SteamID(), v:GetHirePrice())
					s:SetDisabled(true)
				end
			end)
		end)
	end
	self.HireablePlayers.PaintOver = function(s, w, h)
		if (s.Count == 0) then
			draw.OutlinedBox(0, 29, w, h - 29, ui.col.Background, ui.col.Outline)
			draw.SimpleText('Нет доступных работников!', 'ui.24', w * 0.5, h * 0.5, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	self.Employees = ui.Create('ui_listview', self)
	self.Employees:AddSpacer('Уволить Работника'):SetTall(30)
	self.Employees.Count = 0
	self.Employees.AddEmployee = function(s, v)
		addEmployee(s, v, v.GetTeamName, 'Уволить', function(s)
			ui.BoolRequest('Уволить Работника', 'Вы уверены, что хотите уволить ' .. v:Name() .. '?', function(ans)
				if ans then
					cmd.Run('fire', v:SteamID())
					s:Remove()
					self.Employees.Count = self.Employees.Count - 1
					self.HireablePlayers:AddEmployee(v)
				end
			end)
		end)
	end
	self.Employees.PaintOver = function(s, w, h)
		if (s.Count == 0) then
			draw.OutlinedBox(0, 29, w, h - 29, ui.col.Background, ui.col.Outline)
			draw.SimpleText('У вас нет работников!', 'ui.24', w * 0.5, h * 0.5, ui.col.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	for k, v in ipairs(player.GetAll()) do
		if v:IsHirable() and (not v:IsHired()) then
			self.HireablePlayers:AddEmployee(v)
		elseif (v:IsHired() and (v:GetNetVar('Employer') == LocalPlayer())) then
			self.Employees:AddEmployee(v)
		end
	end
end

function PANEL:PerformLayout()
	local halfW = (self:GetWide() * 0.5)
	local halfH = (self:GetTall() * 0.5)

	self.HireablePlayers:SetPos(0, 0)
	self.HireablePlayers:SetSize(self:GetWide(), halfH - 2.5)

	self.Employees:SetPos(0, halfH + 5)
	self.Employees:SetSize(self:GetWide(), halfH - 5)
end

vgui.Register('rp_employment_manager', PANEL, 'Panel')
