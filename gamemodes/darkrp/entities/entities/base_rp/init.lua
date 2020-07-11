dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

util.AddNetworkString("rp.EntityUse")

function ENT:Use(activator, caller, usetype, value)
	if caller:IsPlayer() and (not caller:IsBanned()) and (not caller:IsJailed()) and ((not caller['NextUse' .. self:GetClass()]) or (caller['NextUse' .. self:GetClass()] <= CurTime())) and self:CanUse(caller) then
		self:PlayerUse(caller)
	end
 end

function ENT:PlayerUse(pl)

	if self.NetworkPlayerUse then
		net.Start("rp.EntityUse")
			net.WriteEntity(self)
		net.Send(pl)
	else
		self:CustomUse(pl)
	end

end

function ENT:CustomUse(pl)
	return true
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
			local owner = self.ItemOwner
			if IsValid(owner) then
				owner:Notify(NOTIFY_ERROR, rp.Term('YourEntDestroyed'), self.PrintName)
			end
		end
	end
end

function ENT:Explode()
	local pos = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(pos)
	effectdata:SetOrigin(pos)
	effectdata:SetScale(1)
	util.Effect('Explosion', effectdata)
end

rp.AddCommand("price", function(pl, amount)

	local tr = util.TraceLine({
		start = pl:EyePos(),
		endpos = pl:EyePos() + pl:GetAimVector() * 85,
		filter = pl
	})

	if not IsValid(tr.Entity) then rp.Notify(pl, NOTIFY_ERROR, term.Get('LookAtEntity')) return end

	if IsValid(tr.Entity) and tr.Entity.MaxPrice and (tr.Entity.ItemOwner == pl) then
		tr.Entity:Setprice(math.Clamp(amount, tr.Entity.MinPrice, tr.Entity.MaxPrice))
	else
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotSetPrice'))
	end

	return
end)
:AddParam(cmd.NUMBER)
:AddAlias("setprice")
