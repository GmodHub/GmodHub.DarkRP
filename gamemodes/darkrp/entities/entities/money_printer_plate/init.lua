AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	self:SetModel('models/d3vine/money_plate/money_plate.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysWake()

	self:SetTrigger(true)
end

function ENT:StartTouch(ent)
	if (not self.Used) and IsValid(ent) and (ent:GetClass() == 'money_printer') then
		self.Used = true
		self:Remove()
		ent:PrintMoney()
		ent:EmitSound('ambient/energy/weld2.wav')
	end
end

hook.Add("InitPostEntity", "rp.MoneyPrinterPlate", function()
	for k, v in pairs(rp.cfg.PrinterPlates[game.GetMap()]) do
		local machine = ents.Create('money_printer_plate')
		machine:SetPos(v.Pos)
		machine:SetAngles(v.Ang)
		machine:Spawn()
		machine:Activate()
		machine:GetPhysicsObject():EnableMotion(false)
	end
end)
