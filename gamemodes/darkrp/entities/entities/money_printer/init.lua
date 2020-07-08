AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.SeizeReward = 500
ENT.WantReason = 'Money Printers'
ENT.LazyFreeze = true

function ENT:Initialize()
	self:SetModel('models/sup/printer/printer.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()
	self:SetSequence("Print_One_Bill")

	self.RemoveDelay = math.random(900, 1800)

	self.sound = CreateSound(self, Sound("ambient/levels/labs/equipment_printer_loop1.wav"))
	self.sound:SetSoundLevel(30)

	self:SetMaxInk(5)
	self:SetInk(5)
	self:SetHP(100)
	self:SetLastPrint(CurTime())

	timer.Create(self:EntIndex().. 'Print', rp.cfg.PrintDelay, 0, function()
		if not IsValid(self) then timer.Destroy(self:EntIndex().. 'Print') return end
		self:PrintMoney()
	end)
end

function ENT:Use(pl)
	if (self:GetInk() >= self:GetMaxInk()) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('PrinterIsFull'))
		return
	end

	local cost = ((self:GetMaxInk() - self:GetInk()) * rp.cfg.InkCost)

	if not pl:CanAfford(cost) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
		return
	end

	pl:TakeMoney(cost)
	self:SetInk(self:GetMaxInk())
	rp.Notify(pl, NOTIFY_GREEN, term.Get('PrinterRefilled'), rp.FormatMoney(cost))
end

function ENT:OnRemove()
	self.sound:Stop()
end

function ENT:OnTakeDamage(damageData)
	self:SetHP(self:GetHP() - damageData:GetDamage())

	if (self:GetHP() <= 0) then
		self:Explode()
	end
end

function ENT:Explode()
	timer.Destroy(self:EntIndex().. 'Print')
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect('Explosion', effectdata)
	
	self:Remove()

	if IsValid(self:Getowning_ent()) then
		rp.Notify(self:Getowning_ent(), NOTIFY_ERROR, term.Get('PrinterExploded'))
	end
end

function ENT:PrintMoney()
	if (self:GetInk() <= 0) and (self:GetHP() > 0) then
		self:SetLastPrint(CurTime())
		self:SetHP(math.Clamp(self:GetHP() - 5, 0, 100))
	elseif (self:GetHP() <= 0) then
		self:Explode()
	else
		self:SetLastPrint(CurTime())
		self:SetInk(self:GetInk() - 1)

		self.sound:PlayEx(1, 100)

		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		effectdata:SetRadius(2)
		util.Effect('Sparks', effectdata)
		
		local amount = (hook.Call('calcPrintAmount', GAMEMODE, rp.cfg.PrintAmount) or rp.cfg.PrintAmount)
		local money = rp.SpawnMoney(self:GetPos() + ((self:GetAngles():Up() * 15) + (self:GetAngles():Forward() * 20)), amount)
		if IsValid(money) then
			money.PrinterMoney = true
		end
	end
end