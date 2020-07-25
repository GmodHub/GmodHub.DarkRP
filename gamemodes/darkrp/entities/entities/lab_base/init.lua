dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

util.AddNetworkString('rp.ItemLabCraft')
util.AddNetworkString('rp.ItemLabRefill')

ENT.SeizeReward = 500
ENT.WantReason = 'Black Market Item (Drug lab)'
ENT.LazyFreeze = true

ENT.RemoveOnJobChange = true

ENT.MaxHealth = 250
ENT.DamageScale = 0.5
ENT.ExplodeOnRemove = true

local CraftTimeTable = {
	["weapon_c4"] = 320,
	["keypad_cracker"] = 100,
	["lockpick"] = 100,
	["armor_piece_full"] = 60,
	["weapon_crowbar"] = 50,
	["weapon_stunstick"] = 120,
	["unarrest_baton"] = 150,
	["swb_knife"] = 80,
	["weapon_shield"] = 200,
	["ent_licence"] = 70,
	["ent_disguise"] = 120,
	["weapon_taser"] = 120,
	["weapon_ziptie"] = 120,
}

function ENT:Initialize()
	self:SetModel(self.MainModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()

	self:SetMetal(rp.cfg.ItemLabMaxMetal)
end

function ENT:Crafting(class, crafter)
	local time = crafter:CallSkillHook(SKILL_CRAFTING, CraftTimeTable[class.Class] or math.random(15, 60))

	self:SetMetal(self:GetMetal()-1)
	self:SetCraftTime(CurTime() + time)
	self:SetCraftID(rp.ShipmentMap[class.Class])

	timer.Create(self:EntIndex() .. 'Lab', time, 1, function()
		if IsValid(self) then
			local item = ents.Create('spawned_weapon')
			item.weaponclass = class.Class
			item:SetModel(class.Model)
			item:SetPos(self:GetPos() + ((self:GetAngles():Up() * 40) + (self:GetAngles():Forward() * 0)))
			item:Spawn()
			item:Activate()
			self:SetCraftTime(0)
			self:SetCraftID(0)
		end
	end)
end

net.Receive('rp.ItemLabCraft', function(len, pl)
	local ent = net.ReadEntity()
	local class = net.ReadUInt(8) or 0

	if not IsValid(ent) or not scripted_ents.IsBasedOn(ent:GetClass(), "lab_base") or (ply ~= ent.ItemOwner) then return end
	if not ent:GetCraftables()[class] or ent:GetMetal() <= 0 or ent:IsCrafting() then return end
	if ent:GetPos():Distance(pl:GetPos()) >= 80 then return end

	ent:Crafting(ent:GetCraftables()[class], pl)
	rp.Notify(pl, NOTIFY_SUCCESS, term.Get('ItemLabCrafting'), 1, ent:GetCraftName())
end)

net.Receive("rp.ItemLabRefill", function(len, ply)
	local ent = net.ReadEntity()

	if not IsValid(ent) or not scripted_ents.IsBasedOn(ent:GetClass(), "lab_base") or (ply ~= ent.ItemOwner) then return end
	if ent:GetMetal() >= rp.cfg.ItemLabMaxMetal then return end
	if ent:GetPos():Distance(pl:GetPos()) >= 80 then return end

	local cost = rp.cfg.ItemLabMetalPrice * (rp.cfg.ItemLabMaxMetal - ent:GetMetal())
	if not ply:CanAfford(cost) then
		rp.Notify(ent.ItemOwner, NOTIFY_ERROR, term.Get("CannotAfford"))
		return
	end

	ply:AddMoney(-cost)
	ent:SetMetal(rp.cfg.ItemLabMaxMetal - ent:GetMetal())
	rp.Notify(ent.ItemOwner, NOTIFY_SUCCESS, term.Get('ItemLabRefilled'), cost, ent:GetMetal() )
end)
