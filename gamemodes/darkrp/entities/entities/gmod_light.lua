
AddCSLuaFile()
DEFINE_BASECLASS("base_anim")

ENT.Spawnable			= false
ENT.RenderGroup 		= RENDERGROUP_BOTH

local matLight 		= Material("sprites/light_ignorez")

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "On")
	self:NetworkVar("Bool", 1, "Toggle")
end

function ENT:Initialize()
	if (CLIENT) then
		self.PixVis = util.GetPixelVisibleHandle()
	end

	if (SERVER) then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:DrawShadow(false)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:EnableMotion(false)
		end
	end
end

function ENT:Think()
	if (CLIENT) then
		if (not self:GetOn()) or (not self:InView()) then return end

		local dlight = DynamicLight(self:EntIndex())

		if (dlight) then
			local c = self:GetColor()

			dlight.Pos = self:GetPos()
			dlight.r = c.r
			dlight.g = c.g
			dlight.b = c.b
			dlight.Brightness = 1
			dlight.Decay = 5
			dlight.Size = 325
			dlight.DieTime = CurTime() + 0.1
		end
	end
end

function ENT:Toggle()
	self:SetOn(not self:GetOn())
end