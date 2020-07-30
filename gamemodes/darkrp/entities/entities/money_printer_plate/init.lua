AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.MaxHealth = 150
ENT.DamageScale = 1
ENT.ExplodeOnRemove = false

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
		if ent.ItemOwner and ent.ItemOwner:IsGov() then
			ent.ItemOwner:StartDemotionVote("Фальшивомонетничество")
			ent.ItemOwner:Wanted(nil, "Фальшивомонетничество", 180)
		end
		ent:PrintMoney()
		ent:SetInk(ent:GetInk() + 1)
		ent:EmitSound('ambient/energy/weld2.wav')
	end
end

function ENT:GravGunPickupAllowed(pl)
	return not pl:IsGov()
end

hook.Add("InitPostEntity", "rp.MoneyPrinterPlate", function()
	timer.Create("rp.PrinterPlates", math.random(900, 3600), 0, function()
		for k, v in pairs(rp.cfg.PrinterPlates[game.GetMap()]) do
			local machine = ents.Create('money_printer_plate')
			machine:SetPos(v.Pos)
			machine:SetAngles(v.Ang)
			machine:Spawn()
			machine:Activate()
		end
	end)
end)
