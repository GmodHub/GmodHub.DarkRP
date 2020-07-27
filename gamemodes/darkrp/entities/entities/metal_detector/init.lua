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
	self:SetTrigger(true)

	self:CPPISetOwner(self.ItemOwner)
end

function ENT:StartTouch(pl)
    if not IsValid(pl) or not isplayer(pl) then return end -- dumbest line of the code
	if not self:GetPhysicsObject():IsAsleep() then return end
	if (not pl.LastChecked) or (pl.LastChecked <= CurTime()) then
		pl.LastChecked = CurTime() + 2
		for k, v in ipairs(pl:GetWeapons()) do
			if v:IsIllegalWeapon() then
				net.Start('rp_metaldetector_fail')
					net.WriteEntity(self)
				net.Broadcast()
				if not pl:IsGov() and not pl:IsWanted() and not pl:IsSOD() and not pl:HasLicense() then
					pl:Wanted(nil, "Нелегальное Оружие", 180)
				end
				return
			end
		end
		net.Start('rp_metaldetector_pass')
			net.WriteEntity(self)
		net.Broadcast()
	end
end
