AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

ENT.RemoveOnJobChange = true

ENT.SeizeReward = 350
ENT.WantReason = 'Black Market Item (Ammo lab)'

ENT.MinPrice = 50
ENT.MaxPrice = 500

function ENT:Initialize()
	self.LastFired = 0
	self.Delay = 2

	self:SetModel('models/items/ammocrate_ar2.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	self:PhysWake()

	self:Setprice(self.MinPrice)

	self.damage = 150
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
		self:Remove()
	end
end

function ENT:Destruct()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect('Explosion', effectdata)
end

function ENT:Use(activator, caller)
	local owner = self.ItemOwner

	if self.LastFired <= CurTime() then
		self.LastFired = CurTime() + self.Delay


		self:ResetSequence(self:LookupSequence("close"))
		self:SetPlaybackRate(0.1)
		self:EmitSound("items/ammocrate_open.wav")

		timer.Simple(0.5, function()
			if caller:IsPlayer() and caller:Alive() then
				wep = caller:GetActiveWeapon()

				if IsValid(wep) then
					am = wep:GetPrimaryAmmoType()

					if am ~= -1 then

						amc = caller:GetAmmoCount(am)

						if wep.Primary and wep.Primary.ClipSize then
							if not caller:CanAfford(50) then 
								rp.Notify(caller, NOTIFY_ERROR, term.Get('CannotAfford'))
								return
							end
							mag = wep:Clip1()

							if math.Round(wep.Primary.ClipSize * 12 * (wep.MaxAmmoMod and wep.MaxAmmoMod or 1)) + math.Clamp(wep.Primary.ClipSize - mag, 0, wep.Primary.ClipSize) > amc then
								if not caller == owner then
									owner:AddMoney(50)
									rp.Notify(owner, NOTIFY_GREEN, term.Get('AmmoLabProfit'), 50)

									caller:AddMoney(-50)
									rp.Notify(caller, NOTIFY_GREEN, term.Get('BoughtAmmo'), 50)
								caller:EmitSound("items/ammo_pickup.wav", 60, 100)
								ammo = math.Clamp(amc + (wep.Primary.ClipSize > 50 and wep.Primary.ClipSize / 2 or wep.Primary.ClipSize) * (wep.GiveAmmoMod and wep.GiveAmmoMod or 1), 0, math.Round(wep.Primary.ClipSize * 12 * (wep.MaxAmmoMod and wep.MaxAmmoMod or 1)) + math.Clamp(wep.Primary.ClipSize - mag, 0, wep.Primary.ClipSize))
								caller:SetAmmo(ammo, am)
							else
								caller:EmitSound("items/ammo_pickup.wav", 60, 100)
								ammo = math.Clamp(amc + (wep.Primary.ClipSize > 50 and wep.Primary.ClipSize / 2 or wep.Primary.ClipSize) * (wep.GiveAmmoMod and wep.GiveAmmoMod or 1), 0, math.Round(wep.Primary.ClipSize * 12 * (wep.MaxAmmoMod and wep.MaxAmmoMod or 1)) + math.Clamp(wep.Primary.ClipSize - mag, 0, wep.Primary.ClipSize))
								caller:SetAmmo(ammo, am)
							end
							end
						end
					end

					cl = wep:GetClass()

					for k2, v2 in ipairs(caller:GetWeapons()) do
						am = v2:GetPrimaryAmmoType()
						amc = caller:GetAmmoCount(am)

						if amc == 0 and v2:Clip1() == 0 and cl ~= v2:GetClass() then
							if v2.Primary and v2.Primary.ClipSize then
								if not caller == owner then
									if not caller:CanAfford(50) then 
										rp.Notify(caller, NOTIFY_ERROR, term.Get('CannotAfford'))
										return
									end
										owner:AddMoney(50)
										rp.Notify(owner, NOTIFY_GREEN, term.Get('AmmoLabProfit'), 50)

										caller:AddMoney(-50)
										rp.Notify(caller, NOTIFY_GREEN, term.Get('BoughtAmmo'), 50)
									caller:SetAmmo(v2.Primary.ClipSize * 0.5, am)
								else
									caller:SetAmmo(v2.Primary.ClipSize * 0.5, am)
								end
							else
								if not caller == owner then
									if not caller:CanAfford(50) then 
										rp.Notify(caller, NOTIFY_ERROR, term.Get('CannotAfford'))
										return
									end
										owner:AddMoney(50)
										rp.Notify(owner, NOTIFY_GREEN, term.Get('AmmoLabProfit'), 50)

										caller:AddMoney(-50)
										rp.Notify(caller, NOTIFY_GREEN, term.Get('BoughtAmmo'), 50)
									caller:SetAmmo(15, am)
								else
									caller:SetAmmo(15, am)
								end
							end
						end
					end

					if wep.Secondary and wep.Secondary.Ammo ~= "none" and caller:GetAmmoCount(wep.Secondary.Ammo) < 12 then
					if not caller == owner then
								if not caller:CanAfford(50) then 
									rp.Notify(caller, NOTIFY_ERROR, term.Get('CannotAfford'))
									return
								end
									owner:AddMoney(50)
									rp.Notify(owner, NOTIFY_GREEN, term.Get('AmmoLabProfit'), 50)

									caller:AddMoney(-50)
									rp.Notify(caller, NOTIFY_GREEN, term.Get('BoughtAmmo'), 50)
									caller:GiveAmmo(1, wep.Secondary.Ammo)
					else
									caller:GiveAmmo(1, wep.Secondary.Ammo)
					end
					end
				else
					SafeRemoveEntity(self)
				end
			end
		end)

		timer.Simple(1, function()
			self:EmitSound("items/ammocrate_close.wav")
			self:ResetSequence(self:LookupSequence("open"))
		end)
	end
end

function ENT:OnRemove()
	self:Destruct()
	rp.Notify(self.ItemOwner, NOTIFY_ERROR, term.Get('AmmoLabExploded'))
end