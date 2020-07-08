dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

util.AddNetworkString("rp.npc.PlayerUse")

function ENT:Use(activator, caller, usetype, value)
	if caller:IsPlayer() and (not caller:IsBanned()) and (not caller:IsJailed()) and ((not caller['NextUse' .. self:GetClass()]) or (caller['NextUse' .. self:GetClass()] <= CurTime())) and self:CanUse(caller) then
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
