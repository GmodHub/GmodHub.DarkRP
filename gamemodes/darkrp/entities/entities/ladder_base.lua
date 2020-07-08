if (SERVER) then
	AddCSLuaFile()
end

DEFINE_BASECLASS('base_entity')

ENT.PrintName 		= 'Ladder'
ENT.Spawnable		= false
ENT.Model			= Model('models/props_c17/metalladder001.mdl')
ENT.RenderGroup 	= RENDERGROUP_BOTH

if (SERVER) then

	function ENT:Initialize()
		self:SetModel(self.Model)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end

	local ang_spawn = Angle(0, 0, 0)
	function ENT:CreateLadder()
		local oldAngs = self:GetAngles()

		self:SetAngles(ang_spawn)

		local pos = self:GetPos()
		local dist = self:OBBMaxs().x + 17
		local dismountDist = self:OBBMaxs().x + 49
		local bottom = self:LocalToWorld(Vector(0, 0, self:OBBMins().z))
		local top = self:LocalToWorld(Vector(0, 0, self:OBBMaxs().z))

		self.ladder = ents.Create('func_useableladder')
		self.ladder:SetPos(pos + self:GetForward() * dist)
		self.ladder:SetKeyValue('point0', tostring(bottom + self:GetForward() * dist))
		self.ladder:SetKeyValue('point1', tostring(top + self:GetForward() * dist))
		self.ladder:SetKeyValue('targetname', 'zladder_' .. self:EntIndex())
		self.ladder:SetParent(self)
		self.ladder:Spawn()

		/*
		self.bottomDismount = ents.Create('info_ladder_dismount')
		self.bottomDismount:SetPos(bottom + self:GetForward() * dismountDist)
		self.bottomDismount:SetKeyValue('laddername', 'zladder_' .. self:EntIndex())
		self.bottomDismount:SetParent(self)
		self.bottomDismount:Spawn()

		self.topDismount = ents.Create('info_ladder_dismount')
		self.topDismount:SetPos(top - self:GetForward() * dist)
		self.topDismount:SetKeyValue('laddername', 'zladder_' .. self:EntIndex())
		self.topDismount:SetParent(self)
		self.topDismount:Spawn()
		*/

		self.ladder:Activate()

		self:SetAngles(oldAngs)
	end
else
	function ENT:Initialize()
		self:SetSolid(SOLID_VPHYSICS)
	end

	function ENT:Draw()
		self:DrawModel()
	end
end