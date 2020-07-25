dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

util.AddNetworkString("rp.EntityUse")

net.Receive("rp.EntityUse", function(len, pl)
	local ent = net.ReadEntity()
	if not ent or pl.NetworkUse != ent or not scripted_ents.IsBasedOn(ent:GetClass(), "base_rp") then return end
	pl.NetworkUse = nil
	ent:PlayerUse(pl)
end)

function ENT:Use(activator, caller, usetype, value)
	if caller:IsPlayer() and (not caller:IsBanned()) and (not caller:IsJailed()) and ((not caller['NextUse' .. self:GetClass()]) or (caller['NextUse' .. self:GetClass()] <= CurTime())) and self:CanUse(caller) then
		if self.NetworkPlayerUse or self:CanNetworkUse(caller) then
			net.Start("rp.EntityUse")
				net.WriteEntity(self)
			net.Send(caller)
			caller.NetworkUse = self
		else
			self:PlayerUse(caller)
		end
	end
 end

function ENT:PlayerUse(pl)

end

function ENT:CanNetworkUse(pl)
	return false
end

function ENT:CanUse(pl)
	return true
end

function ENT:NextUse(pl, time)
	pl['NextUse' .. self:GetClass()] = (CurTime() + time)
end

function ENT:OnTakeDamage(dmg)
	if self.MaxHealth then
		self.MaxHealth = self.MaxHealth - (dmg:GetDamage() * self.DamageScale)
		if (self.MaxHealth <= 0) then
			if self.ExplodeOnRemove then
				self:Explode()
			else
				self:Remove()
			end
			if IsValid(self.ItemOwner) then
				self:OnExplode()
			end
		end
	end
end

function ENT:OnExplode()
	self.ItemOwner:Notify(NOTIFY_ERROR, term.Get('YourEntDestroyed'), self.PrintName)
	return true
end

function ENT:Explode()
	local pos = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(pos)
	effectdata:SetOrigin(pos)
	effectdata:SetScale(1)
	util.Effect('Explosion', effectdata)
	self:Remove()
end

rp.AddCommand("price", function(pl, amount)

	local ent = pl:GetEyeTrace().Entity
	if not IsValid(ent) then rp.Notify(pl, NOTIFY_ERROR, term.Get('LookAtEntity')) return end

	if IsValid(ent) and ent.MaxPrice and (ent.ItemOwner == pl) then
		ent:Setprice(math.Clamp(amount, ent.MinPrice, ent.MaxPrice))
	else
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotSetPrice'))
	end

	return
end)
:AddParam(cmd.NUMBER)
:AddAlias("setprice")
