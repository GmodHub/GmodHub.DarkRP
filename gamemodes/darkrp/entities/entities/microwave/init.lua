dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

ENT.RemoveOnJobChange = true

ENT.MaxHealth = 150
ENT.DamageScale = 0.4
ENT.ExplodeOnRemove = true

ENT.CanTool = {
	remover = true,
	material = true,
	colour = true,
	submaterial = true,
}

function ENT:Initialize()
	self:SetID(1)
	self:SetModel("models/props/cs_office/microwave.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()

	self:Setprice(self.MinPrice)
end

function ENT:CanNetworkUse(pl)
	return self.ItemOwner == pl
end

function ENT:PlayerUse(pl)
	if pl:IsBanned() or self.InUse then return end

	if pl:GetCount('Food') >= 15 then
		pl:Notify(NOTIFY_ERROR, term.Get('FoodLimitReached'))
		return
	end

	local owner = self.ItemOwner
	local price = self:Getprice()

	if not pl:CanAfford(price) and (owner ~= pl) then
		pl:Notify(NOTIFY_ERROR, term.Get('CannotAfford'))
		return
	end

	pl:Notify(NOTIFY_GENERIC, term.Get('BoughtFood'), rp.FormatMoney(price))

	if (owner ~= pl) then
		pl:TakeMoney(price)
		owner:Notify(NOTIFY_GENERIC, term.Get('SoldFood'), rp.FormatMoney(price))
		owner:AddMoney(price)
	end

	self.InUse = true
	self:Spark()
	timer.Simple(1, function() if IsValid(self) then self:CreateFood(pl) end end)
end

function ENT:CreateFood(pl)
	local foodPos = self:GetPos()
	local food = ents.Create("spawned_food")
	food:SetModel(self:GetFoodModel())
	food:SetPos(Vector(foodPos.x,foodPos.y,foodPos.z + 23))
	food:Spawn()
	self.InUse = false

	if IsValid(pl) then
		pl:_AddCount('Food', food)
	end
end

rp.AddCommand("setfoodtype", function(pl, food)
	local ent = pl:GetEyeTrace().Entity
	if not IsValid(ent) then rp.Notify(pl, NOTIFY_ERROR, term.Get('LookAtEntity')) return end

	if IsValid(ent) and ent:GetClass() == "microwave" and (ent.ItemOwner == pl) then
		tr.Entity:SetID(food)
	end
end)
:AddParam(cmd.NUMBER)

function ENT:Spark()
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetMagnitude(1)
	effectdata:SetScale(1)
	effectdata:SetRadius(2)
	util.Effect("Sparks", effectdata)
end
