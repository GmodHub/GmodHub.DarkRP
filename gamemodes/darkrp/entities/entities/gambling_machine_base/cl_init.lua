dash.IncludeSH 'shared.lua'

local color_red = ui.col.Red
local color_green = ui.col.Green
function ENT:Draw(callback) -- We're using the same model for all machines right now, save some lines
	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	if (not self:InDistance(150000)) then return end

	local inService = self:GetInService()
	local isPayingOut = self:GetIsPayingOut()

	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 90)

	cam.Start3D2D(self:GetPos() - (self:GetForward() * -0.3), ang, 0.013)
		if (not inService) then
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(-840, -1900, 1600, 1225)

			draw.SimpleText('Out of service...', '3d2d', 0, -1400, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		else
			if self.BackgroundMaterial then
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(self.BackgroundMaterial)
				surface.DrawTexturedRect(-840, -1900, 1600, 1225)
			end

			self:DrawScreen()
		end

		if isPayingOut then
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(-840, -1900, 1600, 300)

			local t = SysTime() * 5
			draw.NoTexture()
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawArc(-20, -1800, 41, 46, t * 180, t * 180 + 180, 5)
			draw.SimpleText('Transferring funds...', '3d2d', 0, -1750, color_green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end

	cam.End3D2D()
end

function ENT:DrawScreen()

end

local fr
function ENT:PlayerUse()
	if IsValid(fr) then fr:Close() end

	local ent = self

	if (ent:GetPos():Distance(LocalPlayer():GetPos()) >= 80) then return end

	local w, h = 160, 160
	fr = ui.Create('ui_frame', function(self)
		self:SetTitle(ent.PrintName)
		self:SetSize(w, h)
		self:Center()
		self:MakePopup()
		self.Think = function()
			if (not IsValid(ent)) or (ent:GetPos():Distance(LocalPlayer():GetPos()) >= 80) then
				fr:Close()
			end
		end
	end)

	local x, y = fr:GetDockPos()

	ui.Create('rp_entity_priceset', function(self, p)
		self:SetEntity(ent)
		self:SetPos(p:GetDockPos())
		self:SetWide(w - 10)
	end, fr)

	local btnDisable = ui.Create('DButton', function(self, p)
		self:SetPos(x, y + 89)
		self:SetSize(w - 10, 30)
		self.Think = function()
			if (not IsValid(ent)) then return end

			if (ent:GetInService()) then
				self:SetText('Disable Service')
			else
				self:SetText('Enable Service')
			end
		end
		self.DoClick = function()
			cmd.Run('setmachineservice')
		end
	end, fr)
end