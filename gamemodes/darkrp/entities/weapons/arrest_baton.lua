AddCSLuaFile()

DEFINE_BASECLASS('baton_base')

if CLIENT then
	SWEP.PrintName = 'Дубинка Ареста'
	SWEP.Instructions = 'Left click to arrest\nRight click to switch to unarrest'
end

SWEP.Color = Color(255, 0, 0, 255)

function SWEP:PrimaryAttack()
	if not IsValid(self.Owner) then return end

	BaseClass.PrimaryAttack(self)

	if CLIENT then return end

	local ent = self:GetTrace().Entity

	if ent.WantReason and self.Owner:IsCP() then
		local owner = ent.ItemOwner

		if (IsValid(owner)) then
			if (not owner:IsWanted()) and (not owner:IsArrested()) then
				owner:Wanted(self.Owner, ent.WantReason)
			end

			if (owner:IsGov() and !owner.IsBeingDemoted) then
				owner:StartDemotionVote("Нелегальные предметы за полицейского")
			end
		end

		local reward = 0
		local class = ent:GetClass()
		local isShipment = (class == 'spawned_shipment')
		local isLab = (class == 'lab_item') and (ent:Getcount() > 0)

		if isShipment then
			if ent:IsEmpty() then return end
			class = ent:GetShipmentTable().entity
		end

		if isLab then
			class = rp.shipments[ent:GetID()].entity
		end

		local shipmentIndex = rp.ShipmentMap[class]
		if (shipmentIndex ~= nil) then
			local tab = rp.shipments[shipmentIndex]
			reward = tab.price/tab.amount
		end

		local entity = rp.EntityMap[class]
		if (entity ~= nil) then
			reward = entity.price
		end

		reward = math.floor(reward * 0.25)

		if isShipment then
			reward = reward * ent:Getcount()
		end

		if isLab then
			reward = reward * ent:Getcount()
		end

		hook.Call('PlayerArrestedEntity', nil, self.Owner, ent, owner)

		ent:Remove()

		reward = ent.SeizeReward or reward
		local karmaGain = (ent.SeizeGiveKarma == false) and 0 or rp.karma.MoneyToKarma(reward * 4)
		if (karmaGain > 0) then
			self.Owner:AddKarma(karmaGain)
		end
		self.Owner:AddMoney(reward)
		rp.Notify(self.Owner, NOTIFY_SUCCESS, term.Get('ArrestBatonBonus'), rp.FormatMoney(reward), karmaGain)
		return
	end

	if ent:IsPlayer() then
		self:HandleArrest(ent)
	elseif ent:IsVehicle() and IsValid(ent:GetDriver()) then
		self:HandleArrest(ent:GetDriver())
	end
end

function SWEP:HandleArrest(ent)
	if ent:InVehicle() then
		ent:ExitVehicle()
	end

	if ent:IsArrested() then
		local _, pos = hook.Call('PlayerSelectSpawn', GAMEMODE, ent)
		ent:SetPos(pos)
		return
	end

	if (not ent:IsWanted()) then
		return
	end

	if self.Owner:IsDisguised() then
		self.Owner:UnDisguise()
	end

	ent:Arrest(arrestor)

	rp.Notify(ent, NOTIFY_ERROR, term.Get('ArrestBatonArrested'), self.Owner)
	rp.Notify(self.Owner, NOTIFY_SUCCESS, term.Get('ArrestBatonYouArrested'), ent)
end

function SWEP:SecondaryAttack()
	if not IsValid(self.Owner) then return end

	BaseClass.PrimaryAttack(self)

	self:SetNextPrimaryFire(CurTime() + 0.5)
	self:SetNextSecondaryFire(CurTime() + 1)

	if CLIENT then return end

	local targ = self.Owner.QuickwantTarget
	if IsValid(targ) and (self.Owner.QuickwantTargetTime > CurTime()) and (not targ:IsArrested()) then
		targ:Wanted(nil, 'Нападение на Офицера')
		self.Owner:Notify(NOTIFY_SUCCESS, term.Get('YouWanted'), targ)
		self.Owner.QuickwantTarget = nil
		self.Owner.QuickwantTargetTime = nil
		return
	end

	local ent = self:GetTrace().Entity

	if ent:IsPlayer() then

		if ent:IsWanted() then
			if IsValid(ent.WantedBy) and (ent.WantedBy == self.Owner) or self.Owner:IsChief() then
				ent:UnWanted(self.Owner)
				self.Owner:Notify(NOTIFY_GENERIC, term.Get('YouUnwanted'), ent)
			else
				self.Owner:Notify(NOTIFY_ERROR, term.Get('CannotUnwant'))
			end
		else
			if (ent:CallTeamHook('PlayerCanBeWanted', self.Owner) == false) or ent:IsArrested() then
				self.Owner:Notify(NOTIFY_ERROR, term.Get('PlayerCannotBeWanted'), ent)
				return
			end

			if ent:IsGov() then
				self.Owner:Notify(NOTIFY_ERROR, term.Get('PlayerIsPoliceWant'), ent)
				return
			end

			ent:Wanted(self.Owner, 'Нелегальные Предметы')
			self.Owner:Notify(NOTIFY_SUCCESS, term.Get('YouWanted'), ent)
		end
	end

end
