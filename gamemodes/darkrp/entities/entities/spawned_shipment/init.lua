dash.IncludeCL('cl_init.lua')
dash.IncludeSH('shared.lua')
dash.IncludeSV('commands.lua')

ENT.LazyFreeze 		= true
ENT.AllLazyFreeze 	= true

function ENT:Initialize()
	self.Destructed = false

	self:SetModel('models/gmh/shipment/shimpmentcrate.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self.locked = false
	self.MaxHealth = 100
	
	self:PhysWake()

	self:SetTrigger(true)
end

function ENT:OnTakeDamage(dmg)
	self.MaxHealth = self.MaxHealth - dmg:GetDamage()
	if (self.MaxHealth <= 0) then
		self:Destruct()
	end
end

function ENT:SetContents(s, c)
	self:Setcontents(s)
	self:Setcount(c)
end

function ENT:Use(pl)
	if pl:IsBanned() or (not hook.Call('PlayerCanPickupWeapon', GAMEMODE, pl)) then
		return
	end

	if (self:Getcount() < 1) then 
		pl:Notify(NOTIFY_ERROR, term.Get('EmptyShipment')) 
		return 
	end

	self:SpawnItem()
end

function ENT:SpawnItem()
	if (not IsValid(self)) then return end

	local count = self:Getcount()

	if (count <= 1) then 
		self:Remove() 
	end

	local contents = self:Getcontents()

	if (not rp.shipments[contents]) then
		self:Remove()
		return
	end

	local weapon = ents.Create('spawned_weapon')

	local weaponAng = self:GetAngles()
	local weaponPos = self:GetAngles():Up() * 40 + weaponAng:Up() * (math.sin(CurTime() * 3) * 8)
	weaponAng:RotateAroundAxis(weaponAng:Up(), (CurTime() * 180) % 360)

	local class = rp.shipments[contents].entity
	local model = rp.shipments[contents].model

	weapon.weaponclass = class
	weapon.lastbox = self:EntIndex()
	weapon:SetModel(model)
	weapon.ammoadd = self.ammoadd or (weapons.Get(class) and weapons.Get(class).Primary.DefaultClip)
	weapon.clip1 = self.clip1
	weapon.clip2 = self.clip2
	weapon:SetPos(self:GetPos() + weaponPos)
	weapon:SetAngles(weaponAng)
	weapon:Spawn()

	self:Setcount(count - 1)
	self.locked = false
end

function ENT:Destruct()
	if self.Destructed then return end
	self.Destructed = true
	local vPoint = self:GetPos()
	local contents = self:Getcontents()
	
	if (not rp.shipments[contents]) then
		self:Remove()
		return
	end
	
	local class = rp.shipments[contents].entity
	local model = rp.shipments[contents].model
	
	for i = 1, self:Getcount() do
		local weapon = ents.Create('spawned_weapon')
		weapon:SetModel(model)
		weapon.weaponclass = class
		weapon:SetPos(Vector(vPoint.x, vPoint.y, vPoint.z + (i*5)))
		weapon:Spawn()
	end
	self:Remove()
end

function ENT:StartTouch(ent)
	if self.LastTouch and self.LastTouch >= CurTime() then return end
	self.LastTouch = CurTime() + 1 
	
	if(ent:GetClass() ~= "spawned_weapon" or (ent.lastbox or 0) == self:EntIndex()) then return end

	local count = self:Getcount()

	if count >= 10 then return end
	
	local contents = self:Getcontents()

	if count < 1 then
		self:Setcontents(rp.ShipmentMap[ent.weaponclass])
		self:Setcount(1)
	else
		if rp.shipments[contents].entity ~= ent.weaponclass then return end
		self:Setcount(count + 1)
	end
	
	ent:Remove()
end
	
function ENT:Touch(ent)
	if (ent:GetClass() ~= 'spawned_shipment') or (self:Getcontents() ~= ent:Getcontents()) or self.locked or ent.locked or self.hasMerged or ent.hasMerged then return end
	
	ent.hasMerged = true
	local selfCount, entCount = self:Getcount(), ent:Getcount()
	local count = selfCount + entCount

	if (count >= 10) then return end

	self:Setcount(count)
	-- Merge ammo information (avoid ammo exploits)
	if self.clip1 or ent.clip1 then -- If neither have a clip, use default clip, otherwise merge the two
		self.clip1 = math.floor(((ent.clip1 or 0) * entCount + (self.clip1 or 0) * selfCount) / count)
	end
	if self.clip2 or ent.clip2 then
		self.clip2 = math.floor(((ent.clip2 or 0) * entCount + (self.clip2 or 0) * selfCount) / count)
	end
	if self.ammoadd or ent.ammoadd then
		self.ammoadd = math.floor(((ent.ammoadd or 0) * entCount + (self.ammoadd or 0) * selfCount) / count)
	end
	ent:Remove()
end