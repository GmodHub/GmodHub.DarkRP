AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

util.AddNetworkString('rp.CopshopMenu')

function ENT:Initialize()
	self:SetModel('models/Barney.mdl')

	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:CapabilitiesAdd(CAP_ANIMATEDFACE)
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER )
	self:SetMaxYawSpeed(90)
end

function ENT:AcceptInput(input, activator, caller)
	if (input == 'Use') and activator:IsPlayer() and (activator:IsCP() or activator:IsMayor()) then
		net.Start("rp.npc.PlayerUse")
		net.WriteEntity(self)
		net.Send(caller)
	end
end

hook.Add('InitPostEntity', function()
	local npc = ents.Create('npc_copshop')
	npc:SetPos(rp.cfg.CopShops[game.GetMap()].Pos)
	npc:SetAngles(rp.cfg.CopShops[game.GetMap()].Ang)
	npc:Spawn()
end)
