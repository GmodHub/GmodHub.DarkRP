dash.IncludeSH 'shared.lua'

function ENT:Draw()
	self:DrawModel()
end

local fr
local function doclick(ent, index)
	net.Start('rp.DrugLabCreate')
		net.WriteEntity(ent)
		net.WriteUInt(index, 8)
	net.SendToServer()

	fr:Close()
end

function ENT:PlayerUse()
	local ent = self

	if IsValid(fr) then fr:Close() end

	if IsValid(ent) and (ent:GetPerc() < 1) then return end

	fr = ui.Create('ui_frame', function(self)
		self:SetTitle(ent.LabType)
		self:SetSize(450, 450)
		self:Center()
		self:MakePopup()
		self.Think = function()
			if (not IsValid(ent)) or (ent:GetPos():Distance(LocalPlayer():GetPos()) >= 80) then
				fr:Close()
			end
		end
	end)

	ui.Create('ui_listview', function(self, p)
		local x, y = p:GetDockPos()

		self:SetPos(x, y)
		self:SetSize(p:GetWide() - (x * 2), p:GetTall() - y - 5)

		for k, v in ipairs(rp.Drugs) do
			if (v.Team and (not table.HasValue(v.Team, LocalPlayer():Team()))) then continue end

			self:AddItem(ui.Create('DButton', function(self)
				self:SetText(v.Name)
				self:SetTall(50)
				self.DoClick = function() doclick(ent, k) end

				ui.Create('rp_modelicon', function(self)
					self:SetPos(0, 0)
					self:SetSize(50, 50)
					self:SetModel(v.Model)
					self:SetToolTip(v.Name)
					self.DoClick = function() doclick(ent, k) end
				end, self)
			end, self))

		end
	end, fr)
end
