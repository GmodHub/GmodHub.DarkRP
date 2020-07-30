AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

PrecacheParticleSystem( "dusty_explosion_rockets" )

function ENT:Initialize()
	self:SetModel("models/weapons/2_c4_planted.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)

	local i = 0
	timer.Create(self:EntIndex() .. 'explode', 1, 5, function()
		if not IsValid(self) then return end
		i = i + 1
		self:EmitSound("C4.PlantSound")
		if (i == 5) then
			self:Explosion()
		end
	end)
end

local badprops = {
	['models/props_interiors/vendingmachinesoda01a.mdl'] = true,
	['models/props_interiors/vendingmachinesoda01a_door.mdl'] = true,
}

function ENT:Explosion()
	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetRadius(1000)
		effectdata:SetMagnitude(1000)
	util.Effect("HelicopterMegaBomb", effectdata)

	local exploeffect = EffectData()
		exploeffect:SetOrigin(self:GetPos())
		exploeffect:SetStart(self:GetPos())
	util.Effect("Explosion", exploeffect, true, true)

	local shake = ents.Create("env_shake")
		shake:SetOwner(self.ItemOwner)
		shake:SetPos(self:GetPos())
		shake:SetKeyValue("amplitude", "500")	// Power of the shake
		shake:SetKeyValue("radius", "500")		// Radius of the shake
		shake:SetKeyValue("duration", "2.5")	// Time of shake
		shake:SetKeyValue("frequency", "255")	// How far should the screenshake be
		shake:SetKeyValue("spawnflags", "4")	// Spawnflags(In Air)
		shake:Spawn()
		shake:Activate()
		shake:Fire("StartShake", "", 0)

	local push = ents.Create("env_physexplosion")
		push:SetOwner(self.ItemOwner)
		push:SetPos(self:GetPos())
		push:SetKeyValue("magnitude", 100)
		push:SetKeyValue("radius", 500)
		push:SetKeyValue("spawnflags", 2+16)
		push:Spawn()
		push:Activate()
		push:Fire("Explode", "", 0)
		push:Fire("Kill", "", .25)

	ParticleEffect("dusty_explosion_rockets", self:GetPos(), Angle(0, 0, 0)) // cool boom effect
	self:EmitSound(Sound("C4.Explode"))

	util.BlastDamage(self, self.ItemOwner, self:GetPos(), 250, 200)

	local props = ents.FindInSphere(self:GetPos(), 125)

	for k, v in ipairs(props) do
		if IsValid(v) then
			local class = v:GetClass()
			if (class == 'prop_physics') then
				if(badprops[v:GetModel()] or not util.IsInWorld(v:GetPos())) then
					v:Remove()
				else
					constraint.RemoveAll(v)
					local phys = v:GetPhysicsObject()
					if IsValid(phys) then
						phys:EnableMotion(true)
					end
				end
			elseif v:IsDoor() and v:GetPropertyNetworkID() ~= nil then
				v:DoorLock(false)
				v.KeysCooldown = CurTime() + 60

				-- Break the door
				hook.Call('PlayerBreakDownDoor', nil, self.ItemOwner, v)

				v:Fire("unlock", "", .5)
				v:Fire("open", "", .6)
				v:Fire("setanimation", "open", .6)
				v:EmitSound("physics/wood/wood_crate_break" .. math.random(5) .. ".wav")

				local pos = v:GetPos()
				local ang = v:GetAngles()
				local model = v:GetModel()
				local skin = v:GetSkin()

				v:SetNotSolid(true)
				v:SetNoDraw(true)

				local norm = -(pos - self:GetPos()):GetNormal()
				local push = 10000 * norm
				local ent = ents.Create("prop_physics")

				ent:SetPos(pos)
				ent:SetAngles(ang)
				ent:SetModel(model)

				if (skin) then
					ent:SetSkin(skin)
				end

				ent:Spawn()
				ent.ShareGravgun = true

				timer.Simple(0.01, function()
					if IsValid(ent) then
						ent:SetVelocity(push)
						ent:GetPhysicsObject():ApplyForceCenter(push)
					end
				end)
				timer.Simple(25, function()
					v:SetNotSolid(false)
					v:SetNoDraw(false)
					v.FistHits = nil

					if (IsValid(ent)) then
						ent:Remove()
					end
				end)
			elseif(IsEntity(v) and v.ItemOwner and not v.ItemOwner:IsWorld() and IsValid(v:GetPhysicsObject()) and not v:GetPhysicsObject():IsMotionEnabled() and class ~= "ent_c4") then
				v:Remove()
			end
		end
	end

	self:Remove()
end
