
dash.IncludeSH 'shared.lua'

local color_white = Color(255, 255, 255)
local color_text = Color(255,255,255)
local color_textoutline = Color(0,0,0)

local color_outline = Color(245,245,245)
local color_grey 	= Color(50,50,50)
local color_red 	= Color(255,50,50)
local color_yellow 	= Color(255,255,50)
local color_green 	= Color(50,255,50)

local function barColor(perc)
	return ((perc <= .39) and color_red or ((perc <= .75) and color_yellow or color_green))
end

//ENT.CraftingEffect = Material 'galactic/supcraftingstation/hologram.vmt' -- steal this from cwrp thx
ENT.CraftingEffect = Material("models/shadertest/predator")
ENT.MetalMat = "phoenix_storms/metal_plate"

function ENT:Initialize()
	self.ClientsideModels = {}
	self.Metals = {}

	self:SetupAccessories()
end

function ENT:SetupAccessories()
	for k, v in ipairs(self.ClientsideModels) do if (IsValid(v)) then v:Remove() end end
	for k, v in ipairs(self.Metals) do if (IsValid(v)) then v:Remove() end end
	if (IsValid(self.ProgMdl)) then self.ProgMdl:Remove() end

	self.ClientsideModels = {}
	self.Metals = {}

	for k, v in ipairs(self.AccessoryModels) do
		local mdl = ClientsideModel(v[1])

		if (!IsValid(mdl)) then continue end

		mdl:SetParent(self)
		mdl:SetLocalPos(v[2])
		mdl:SetLocalAngles(v[3])
		mdl:SetNoDraw(true)
		mdl:SetRenderMode(RENDERMODE_TRANSALPHA)
		mdl:SetColor(color_white)

		table.insert(self.ClientsideModels, mdl)
	end

	for k, v in ipairs(self.MetalsPositions) do
		local mdl = ClientsideModel("models/props_junk/garbage_newspaper001a.mdl")

		if (!IsValid(mdl)) then continue end

		mdl:SetParent(self)
		mdl:SetLocalPos(v[1])
		mdl:SetLocalAngles(v[2])
		mdl:SetModelScale(0.35, 0)
		mdl:SetNoDraw(true)
		mdl:SetRenderMode(RENDERMODE_TRANSALPHA)
		mdl:SetMaterial(self.MetalMat)
		mdl:SetColor(color_white)

		table.insert(self.Metals, mdl)
	end
end

function ENT:DrawCrafting()
	if (!self:IsCrafting()) then
		self.StartCrafting = nil
		self.EndCrafting = nil
		return
	end

	if (!self.StartCrafting) then
		self.StartCrafting = RealTime()
		self.EndCrafting = RealTime() + (self:GetCraftTime() - CurTime())
	end

	if (!IsValid(self.ProgMdl)) then
		self.ProgMdl = ClientsideModel(self.ProgressModel[1])

		if (!IsValid(self.ProgMdl)) then return end

		self.ProgMdl:SetParent(self)
		self.ProgMdl:SetLocalPos(self.ProgressModel[2])
		self.ProgMdl:SetLocalAngles(self.ProgressModel[3])
		self.ProgMdl:SetNoDraw(true)
		self.ProgMdl:SetRenderMode(RENDERMODE_TRANSALPHA)
		self.ProgMdl:SetColor(color_white)
	end

	local min, max = self.ProgMdl:OBBMins(), self.ProgMdl:OBBMaxs()
	local perc = (RealTime() - self.StartCrafting) / (self.EndCrafting - self.StartCrafting)
	local normal = -self.ProgMdl:GetUp() + self.ProgMdl:GetRight()
	local pos = self.ProgMdl:LocalToWorld(Vector(0, 0, -23) + Vector(0, 0, 56) * perc)
	local dist = normal:Dot(pos)

	self.ProgMdl:SetModelScale(0.99, 0)
		render.ModelMaterialOverride(self.CraftingEffect)
			self.ProgMdl:DrawModel()
		render.ModelMaterialOverride()
	self.ProgMdl:SetModelScale(1, 0)

	local old = render.EnableClipping(true)
		render.PushCustomClipPlane(normal, dist)
				self.ProgMdl:DrawModel()
		render.PopCustomClipPlane()
	render.EnableClipping(old)
end

function ENT:Get3D2DInfo()
	local pos = self:GetPos()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), -90)
	ang:RotateAroundAxis(ang:Forward(), 90)
	local off = self:IsCrafting() and -16 or -10

	return pos + ang:Right() * -14.5 + ang:Up() * 22.1 + ang:Forward() * off, ang, false
end

function ENT:Draw()
	self:DrawModel()

	for k, v in ipairs(self.ClientsideModels) do
		if (IsValid(v)) then
			v:DrawModel()
		end
	end

	for k, v in ipairs(self.Metals) do
		if (self:GetMetal() < k) then break end

		if (IsValid(v)) then
			v:DrawModel()
		end
	end

	self:DrawCrafting()

	local inView, dist = self:InDistance(150000)

	if (not inView) then return end

	color_text.a = 255 - (dist/590)
	color_textoutline.a = color_text.a

	local p, a, centered = self:Get3D2DInfo()
	cam.Start3D2D(p, a, 0.05)
		draw.SimpleTextOutlined(self.PrintName .. (self:IsCrafting() and (" - " .. self:GetCraftName()) or ""), '3d2d', 0, -400, color_text, centered and TEXT_ALIGN_CENTER or TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_textoutline)
	cam.End3D2D()
end

local fr
local function doclick(ent, index)
	net.Start('rp.ItemLabCraft')
		net.WriteEntity(ent)
		net.WriteUInt(index, 8)
	net.SendToServer()

	fr:Close()
end

function ENT:PlayerUse()
	local ent = self

	if IsValid(fr) then fr:Close() end

	if IsValid(ent) and (ent:IsCrafting()) then return end

	fr = ui.Create('ui_frame', function(self)
		self:SetTitle(ent.PrintName)
		self:SetSize(450, 450)
		self:Center()
		self:MakePopup()
		self.Think = function()
			if (not IsValid(ent)) or (ent:GetPos():Distance(LocalPlayer():GetPos()) >= 80) then
				fr:Close()
			end
		end
	end)

	local btn = ui.Create('DButton', function(self, p)
		local x, y = p:GetDockPos()
		self:SetPos(x, y)
		self:SetSize(p:GetWide() - (x * 2), 30)
		self:SetText("Refill Metal ($" .. rp.cfg.ItemLabMetalPrice .. " each)")
		self.DoClick = function()
			if (LocalPlayer():GetMoney() >= rp.cfg.ItemLabMetalPrice * (rp.cfg.ItemLabMaxMetal - ent:GetMetal())) then
				net.Start("rp.ItemLabRefill")
					net.WriteEntity(ent)
				net.SendToServer()

				self:SetDisabled(true)
			end
		end

		if (ent:GetMetal() == rp.cfg.ItemLabMaxMetal) then
			self:SetDisabled(true)
			self.Disabled = true
		end
	end, fr)

	ui.Create('ui_listview', function(self, p)
		local x, y = btn.x, btn.y + btn:GetTall() + 5

		self:SetPos(x, y)
		self:SetSize(p:GetWide() - (x * 2), p:GetTall() - y - 5)

		for k, v in ipairs(ent:GetCraftables()) do
			local shipID = rp.ShipmentMap[v.Class]
			local ship = rp.shipments[shipID]

			self:AddItem(ui.Create('DButton', function(self)
				self:SetText(ship.name)
				self:SetTall(50)
				self.DoClick = function() doclick(ent, k) end

				ui.Create('rp_modelicon', function(self)
					self:SetPos(0, 0)
					self:SetSize(50, 50)
					self:SetModel(v.Model)
					self:SetToolTip(ship.name)
					self.DoClick = function() doclick(ent, k) end
				end, self)
			end, self))

		end
	end, fr)
end