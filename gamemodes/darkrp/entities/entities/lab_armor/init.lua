AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

ENT.RemoveOnJobChange = true

ENT.SeizeReward = 350
ENT.WantReason = 'Black Market Item (Armor lab)'

ENT.MinPrice = 1
ENT.MaxPrice = 5

function ENT:Initialize()
	self:SetModel('models/props_combine/suit_charger001.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	self:PhysWake()

	self:Setprice(self.MinPrice)
end

function ENT:Use(pl)
	if pl:IsBanned() then return end

	local owner = self.ItemOwner
	if pl:Armor() < 100 then
		local Cost = ((100 - pl:Armor()) * self:Getprice())

		if not pl:CanAfford(Cost) then 
			rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
			return
		end
		
		if pl ~= owner then
			owner:AddMoney(Cost)
			rp.Notify(owner, NOTIFY_GREEN, term.Get('ArmorLabProfit'), Cost)

			pl:AddMoney(-Cost)
			rp.Notify(pl, NOTIFY_GREEN, term.Get('BoughtArmor'), Cost)
		end

		pl:SetArmor(100)
		self:EmitSound('items/suitchargeok1.wav')
	end
end