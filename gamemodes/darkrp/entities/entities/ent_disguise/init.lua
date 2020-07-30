dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

util.AddNetworkString('rp.disguise.Use')
util.AddNetworkString('rp.disguise.Enable')

ENT.SeizeReward = 250
ENT.WantReason = 'Black Market Item (Disguise)'

function ENT:Initialize()
	self:SetModel('models/props_c17/SuitCase_Passenger_Physics.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)

	self:SetUseType(SIMPLE_USE)

	self:PhysWake()
end

function ENT:CanUse(pl)

	if pl:IsDisguised() then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('AlreadyDisguised'))
		return false
	end

	pl.ValidDisguiseEnt = self

	return true
end

net.Receive('rp.disguise.Use', function(len, pl)
	local ent = net.ReadEntity()
	local t = net.ReadInt(8)

	if ent ~= pl.ValidDisguiseEnt then
		return --You've been naughty
	end

	if (pl:Team() == TEAM_ADMIN) then
		return
	end

	if IsValid(ent) then
		ent:Remove()
		pl:Disguise(t)
		pl.ValidDisguiseEnt = nil
	end
end)

net.Receive('rp.disguise.Enable', function(len, pl)
	local t = net.ReadInt(8)

	if pl.nextDisguise and ( pl.nextDisguise > CurTime()) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('DisguiseLimit'), (pl.nextDisguise - CurTime())/60)
		return
	end

	if pl:GetTeamTable().candisguise or pl:GetNetVar('CanGenomeDisguise') then
		pl:Disguise(t)
	end
end)
