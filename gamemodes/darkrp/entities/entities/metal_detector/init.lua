AddCSLuaFile 'cl_init.lua'
AddCSLuaFile 'shared.lua'
include 'shared.lua'

util.AddNetworkString('rp_metaldetector_fail')
util.AddNetworkString('rp_metaldetector_pass')

function ENT:Initialize()
	self:SetModel('models/props_wasteland/interior_fence002e.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:PhysWake()
	self:SetMaterial('phoenix_storms/gear')

	self:CPPISetOwner(self.ItemOwner)
end

local vec = Vector(0,0,30)
function ENT:Think()
	local cen = self:OBBCenter()
	local real = self:LocalToWorld(Vector(cen.x, cen.y, self:OBBMins().z)) + vec

	for k, v in ipairs(ents.FindInSphere(self:GetPos(), 35)) do
		if v:IsPlayer() and ((not v.LastChecked) or (v.LastChecked <= CurTime())) and (v:GetPos():Distance(real) < 35) then
			v.LastChecked = CurTime() + 2
			for k, v in ipairs(v:GetWeapons()) do
				if v:IsIllegalWeapon() then
					net.Start('rp_metaldetector_fail')
						net.WriteEntity(self)
					net.Broadcast()
					if not v:IsGov() and not pl:IsSOD() and not pl:HasGunLicense() then
						v:Wanted(nil, "Нелегальное Оружие", 180)
					end
					self:NextThink(CurTime() + 2)
					return
				end
			end
			net.Start('rp_metaldetector_pass')
				net.WriteEntity(self)
			net.Broadcast()
			self:NextThink(CurTime() + 1)
		end
	end
end
