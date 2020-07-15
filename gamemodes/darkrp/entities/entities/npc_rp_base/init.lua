dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

util.AddNetworkString("rp.npc.PlayerUse")

function ENT:Initialize()
	self:SetModel(self.NPCModel or "models/Humans/Group03/male_02.mdl")

	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:CapabilitiesAdd(CAP_ANIMATEDFACE)
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER )
	self:SetMaxYawSpeed(90)

	self:SetTrigger(true)
end

function ENT:Use(activator, caller, usetype, value)
	if isplayer(caller) and (not caller:IsBanned()) and (not caller:IsJailed()) and ((not caller['NextUse' .. self:GetClass()]) or (caller['NextUse' .. self:GetClass()] <= CurTime())) and self:CanUse(caller) then
		self:PlayerUse(caller)
	end
 end

function ENT:PlayerUse(pl)
	net.Start("rp.npc.PlayerUse")
		net.WriteEntity(self)
	net.Send(pl)
end

function ENT:CanUse(pl)
	return true
end

function ENT:NextUse(pl, time)
	pl['NextUse' .. self:GetClass()] = (CurTime() + time)
end
