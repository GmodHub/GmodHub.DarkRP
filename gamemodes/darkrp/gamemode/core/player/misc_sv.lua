local CurTime 		= CurTime
local math_abs		= math.abs
local math_clamp	= math.Clamp
local math_max 		= math.max

function PLAYER:NewData()
	if not IsValid(self) then return end

	self:SetTeam(1)

	self:GetTable().LastVoteCop = CurTime() - 61
end

function PLAYER:Welfare()
	if not IsValid(self) then return end

		if self:IsArrested() then
	    rp.Notify(self, NOTIFY_ERROR, term.Get('WelfareMissed'))
	    return
  	end

  	if self:GetMoney() > rp.cfg.WelfareCutoff then
		if self:GetVar('PropertyOwned') then
			local tax = (ents.GetByIndex(self:GetVar('PropertyOwned')):GetPropertyInfo().DoorCount or 0) * self:Wealth(rp.cfg.DoorTaxMin, rp.cfg.DoorTaxMax)
			self:TakeMoney(tax)
			self:AddKarma(1)
			rp.Notify(self, NOTIFY_SUCCESS, term.Get('PropertyTax'), rp.FormatMoney(tax), 1 )
		end
    	return
	end

	if self:GetVar('PropertyOwned') then
		local tax = (self:GetVar('PropertyOwned') and ents.GetByIndex(self:GetVar('PropertyOwned')):GetPropertyInfo().DoorCount or 0) * self:Wealth(rp.cfg.DoorTaxMin, rp.cfg.DoorTaxMax)
		self:TakeMoney(tax)
		self:TakeKarma(1)
		self:AddMoney(rp.cfg.WelfareAmount)
		rp.Notify(self, NOTIFY_SUCCESS, term.Get('WelfareTaxed'), rp.cfg.WelfareAmount, tax, 1 )
	else
		self:TakeKarma(1)
		self:AddMoney(rp.cfg.WelfareAmount)
		rp.Notify(self, NOTIFY_SUCCESS, term.Get('Welfare'), rp.cfg.WelfareAmount, 1 )
	end
end

function PLAYER:AddHealth(amt)
	self:SetHealth(self:Health() + amt)
end

function PLAYER:TakeHealth(amt)
	if (self:Health() - amt < 0) then self:SetHealth(0) return end
	self:SetHealth(self:Health() - amt)
end

function PLAYER:SetHunger(amount, noclamp)
	local max = self:CallSkillHook(SKILL_HUNGER)
	if noclamp then
		amount = math_max(0, (amount/100 * rp.cfg.HungerRate))
	else
		amount = math_clamp((amount/100 * rp.cfg.HungerRate ), 0, (max/100 * rp.cfg.HungerRate ))
	end
	self:SetNetVar('Energy', CurTime() + amount)
end

function PLAYER:AddHunger(amount)
	self:SetHunger(self:GetHunger() + amount)
end

function PLAYER:TakeHunger(amount)
	self:AddHunger(-math_abs(amount))
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

hook("PlayerDataLoaded", "RP:RestorePlayerData", function(pl, data)
	pl:NewData()
end)


hook('InitPostEntity', function()
	timer.Create("KarmaForPlaying", 1500, 0, function()
		for k,v in pairs(player.GetAll()) do
			v:AddKarma(25)
			rp.Notify(v, NOTIFY_SUCCESS, term.Get('GainedKarmaDrop'), 25, 25)
		end
	end)

	timer.Create("WelfareTime", 300, 0, function()
		for k,v in pairs(player.GetAll()) do
			v:Welfare()
		end
	end)
end)
