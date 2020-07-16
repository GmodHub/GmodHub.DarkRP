AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/drover/shield_d.mdl");
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	local phys = self:GetPhysicsObject();
	phys:Wake();
	phys:SetMass(1000)

	self:ResetSequence(self:LookupSequence("deploy"));
end

function ENT:Use(activator, caller)
	if self.ItemOwner == nil then self:Remove(); return end;
	if not IsValid(self.ItemOwner) then self:Remove(); return end;
	if self.ItemOwner != activator then return end;

	activator:Give("weapon_shield");
	self:Remove();
end

function ENT:OnTakeDamage(dmg)
	if not tobool(self.canBeDestroyedByDamage) then return end
  local typ = dmg:GetDamageType();

	if tobool(self.onlyExplosionDamage) and bit.band(typ, DMG_BLAST) ~= DMG_BLAST then return end;
	local damage = dmg:GetDamage();
	self.currentHealth = self.currentHealth - damage;
	if self.currentHealth <= 0 then
		self:Remove();
	end
end

function ENT:Think()
	self:NextThink(CurTime());  return true;
end
