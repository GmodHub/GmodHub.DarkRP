AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props/cs_office/computer.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()

	self:SetUseType(SIMPLE_USE)
end

hook.Add("InitPostEntity", "rp.MayorMachine", function()
	for k, v in ipairs(rp.cfg.MayorMachines[game.GetMap()]) do
		local machine = ents.Create('mayor_machine')
		machine:SetPos(v.Pos)
		machine:SetAngles(v.Ang)
		machine:Spawn()
		machine:Activate()
		machine:GetPhysicsObject():EnableMotion(false)
	end
end)