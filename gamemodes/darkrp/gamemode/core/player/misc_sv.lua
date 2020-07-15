function PLAYER:Welfare()
	if not IsValid(self) then return end

	if self:IsArrested() then
    rp.Notify(self, NOTIFY_ERROR, term.Get('WelfareMissed'))
    return
  end

  if self:GetMoney() > rp.cfg.WelfareCutoff and self:GetVar('PropertyOwned') then
		rp.Notify(self, NOTIFY_ERROR, term.Get('PropertyTax'), 1, 1 )
    return
	end

  if self:GetVar('PropertyOwned') then
    local tax = (self:GetVar('doorCount') or 0) * rp.cfg.PropertyTax
    self:AddMoney(amount - tax)
  else
    rp.Notify(self, NOTIFY_ERROR, term.Get('Welfare'), rp.cfg.WelfareAmount, 1 )
    self:AddMoney(rp.cfg.WelfareAmount)
    self:TakeKarma(1)
  end
end

function PLAYER:KarmaForPlaying()
  if not IsValid(self) then return end

	self:AddKarma(25)
	rp.Notify(self, NOTIFY_SUCCESS, term.Get('GainedKarmaDrop'), 25, 25)
end

function PLAYER:AddHealth(amt)
	self:SetHealth(self:Health() + amt)
end

function PLAYER:TakeHealth(amt)
	if (self:Health() - amt < 0) then self:SetHealth(0) return end
	self:SetHealth(self:Health() - amt)
end

function PLAYER:AddArmor(amt)
	self:SetArmor(self:Armor() + amt)
end

function PLAYER:TakeArmor(amt)
	if (self:Armor() - amt < 0) then self:SetArmor(0) return end
	self:SetArmor(self:Armor() - amt)
end

function PLAYER:GiveAmmos(amount, show)
	for k, v in ipairs(rp.ammoTypes) do
		self:GiveAmmo(amount, v.ammoType, show)
	end
end
/*
hook('InitPostEntity', function()
	timer.Create("KarmaForPlaying", 1500, 0, function()
		for k,v in pairs(player.GetAll()) do
			v:KarmaForPlaying()
		end
	end)

	timer.Create("WelfareTime", 5, 0, function()
		for k,v in pairs(player.GetAll()) do
			v:Welfare()
		end
	end)
end)
