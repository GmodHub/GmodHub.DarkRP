AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString("MicroFoodMenu")

ENT.RemoveOnJobChange = true

ENT.MinPrice = 10
ENT.MaxPrice = 150

function ENT:Initialize()
	self:SetIDI(1)
	self:SetModel("models/props/cs_office/microwave.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	self:PhysWake()

	self.sparking = false
	self.damage = 100
	self:Setprice(self.MinPrice)
end

function ENT:PhysgunPickup(pl)
	return ((pl == self.ItemOwner and self:InSpawn()) or false)
end

function ENT:PhysgunFreeze(pl)
	return self:InSpawn()
end

function ENT:OnTakeDamage(dmg)
	local phys = self:GetPhysicsObject()
	if not phys:IsMoveable() then return end

	self.damage = self.damage - dmg:GetDamage()
	if (self.damage <= 0) then
		self:Destruct()
		self:Remove()
	end
end

function ENT:Destruct()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
end

function ENT:SalePrice(activator)
	local owner = self.ItemOwner
	local discounted = math.ceil(self.MinPrice * 0.82)

	if activator == owner then
		return 25
	else
		return self:Getprice()
	end
end

function ENT:Use(pl)
	if pl:IsBanned() or self.InUse then return end

	if pl:GetCount('Food') >= 15 then
		pl:Notify(NOTIFY_ERROR, term.Get('FoodLimitReached'))
		return
	end

	local owner = self.ItemOwner
	local price = self:Getprice()

	if ((pl ~= owner) and (not pl:CanAfford(price))) or ((pl == owner) and (not pl:CanAfford(self.MinPrice))) then
		pl:Notify(NOTIFY_ERROR, term.Get('CannotAfford'))
	elseif (pl == owner) then
		net.Start("MicroFoodMenu")
		net.WriteEntity(self)
		net.Send(pl)
	else
		local gain = price - self.MinPrice

		if (gain == 0) then
			owner:Notify(NOTIFY_ERROR, term.Get('SoldFoodNoProf'))
			owner:AddKarma(3)
		else
			owner:Notify(NOTIFY_GENERIC, term.Get('SoldFood'), rp.FormatMoney(gain))
			owner:AddMoney(gain)
			owner:AddKarma(1)
		end

		pl:Notify(NOTIFY_GENERIC, term.Get('BoughtFood'), rp.FormatMoney(price))
		pl:TakeMoney(price)
		self.InUse = true
		self.sparking = true

		timer.Simple(1, function() self:CreateFood(pl) end)
	end
end

function ENT:CreateFood(pl)
	local foodPos = self:GetPos()
	local food = ents.Create("spawned_food")
	food:SetModel(self:GetFoodModel())
	food:SetPos(Vector(foodPos.x,foodPos.y,foodPos.z + 23))
	food:Spawn()
	self.InUse = false
	self.sparking = false

	if IsValid(pl) then
		pl:_AddCount('Food', food)
	end
end

local function food(pl, args)
	local tr = util.TraceLine({	
		start = pl:EyePos(),
		endpos = pl:EyePos() + pl:GetAimVector() * 85,
		filter = pl
	})

	if not IsValid(tr.Entity) then rp.Notify(pl, NOTIFY_ERROR, term.Get('LookAtEntity')) return end

	if IsValid(tr.Entity) and tr.Entity.MaxPrice and (tr.Entity.ItemOwner == pl) then
		pl:Notify(NOTIFY_GENERIC,  term.Get('BoughtFoodProduction'), rp.FormatMoney(tr.Entity.MinPrice))
		pl:TakeMoney(tr.Entity.MinPrice)
		tr.Entity.InUse = true
		tr.Entity.sparking = true
		timer.Simple(1, function() tr.Entity:CreateFood(pl) end)
	end

	return 
end
rp.AddCommand("buymicrofood", food)

local function food2(pl, args)
	local tr = util.TraceLine({	
		start = pl:EyePos(),
		endpos = pl:EyePos() + pl:GetAimVector() * 85,
		filter = pl
	})

	if not IsValid(tr.Entity) then rp.Notify(pl, NOTIFY_ERROR, term.Get('LookAtEntity')) return end

	if IsValid(tr.Entity) and tr.Entity.MaxPrice and (tr.Entity.ItemOwner == pl) then
		tr.Entity:SetIDI(args)
	end

	return 
end
rp.AddCommand("setfoodtype", food2)
:AddParam(cmd.STRING)


function ENT:Think()
	if self.sparking then
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		effectdata:SetRadius(2)
		util.Effect("Sparks", effectdata)
	end
end

function ENT:OnRemove()
	timer.Destroy(self:EntIndex())
	local ply = self.ItemOwner
	if not IsValid(ply) then return end
end