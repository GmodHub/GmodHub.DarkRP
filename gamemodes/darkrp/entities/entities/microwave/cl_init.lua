dash.IncludeSH 'shared.lua'

local LocalPlayer = LocalPlayer
local Color = Color
local cam = cam
local draw = draw
local Angle = Angle
local Vector = Vector
local CurTime = CurTime

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	local inView, dist = self:InDistance(150000)

	if (not inView) then return end

	color_white.a = 255 - (dist/590)
	color_black.a = color_white.a

	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), math.sin(CurTime() * math.pi) * -45)

	cam.Start3D2D(pos, ang, 0.070)
		draw.SimpleTextOutlined(self:GetFoodName(), '3d2d', 0, -450, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		draw.SimpleTextOutlined('Price: $' .. self:Getprice(), '3d2d', 0, -450, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	cam.End3D2D()

	ang:RotateAroundAxis(ang:Right(), 180)

	cam.Start3D2D(pos, ang, 0.070)
		draw.SimpleTextOutlined(self:GetFoodName(), '3d2d', 0, -450, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		draw.SimpleTextOutlined('Price: $' .. self:Getprice(), '3d2d', 0, -450, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	cam.End3D2D()
end

local fr
function ENT:PlayerUse()
	if IsValid(fr) then fr:Close() end

	local ent = self

	if (ent:GetPos():Distance(LocalPlayer():GetPos()) >= 80) then return end

	local w, h = 160, 315
	fr = ui.Create('ui_frame', function(self)
		self:SetTitle('Microwave')
		self:SetSize(w, h)
		self:Center()
		self:MakePopup()
		self.Think = function()
			if (not IsValid(ent)) or (ent:GetPos():Distance(LocalPlayer():GetPos()) >= 80) then
				fr:Close()
			end
		end
	end)

	local cont = ui.Create('ui_panel', function(self, p)
		self:DockToFrame()
		self.Paint = function() end
	end, fr)

	local x, y = 0, 0
	local s = 75
	for k, v in ipairs(rp.Foods) do
		ui.Create('rp_modelicon', function(self)
			self:SetPos(x * s, y * s)
			self:SetSize(s, s)
			self:SetModel(v.model)
			--self:SetLabel(v.Name)
			self.DoClick = function()
				cmd.Run('setfoodtype', k)
				fr:Close()
			end
		end, cont)

		y = (x >= 1) and (y + 1) or y
		x = (x >= 1) and 0 or (x + 1)
	end

	fr:SetTall((y * 75) + 115)
	cont:SetTall(fr:GetTall() - 35)
	fr:SetTall(fr:GetTall() + 50)
	fr:Center()

	ui.Create('rp_entity_priceset', function(self, p)
		self:SetEntity(ent)
		self:SetPos(5, p:GetTall() - 125)
		self:SetWide(w - 10)
	end, fr)


	ui.Create('DButton', function(self, p)
		self:SetPos(5, p:GetTall() - 35)
		self:SetSize(p:GetWide() - 10, 30)
		self:SetText('Buy')
		self.DoClick = function()
			ent:SendPlayerUse()
		end
	end, fr)
end