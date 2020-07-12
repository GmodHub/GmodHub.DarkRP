rp.shop = rp.shop or {
	Stored = {},
	Weapons = {},
	Mapping = {}
}

local upgrade_mt = {}
upgrade_mt.__index = upgrade_mt

local count = 1
function rp.shop.Add(name, uid)
	local t = {
		Name 	= name,
		UID 	= uid:lower(),
		ID 		= count,
		Stackable = true
	}
	setmetatable(t, upgrade_mt)
	rp.shop.Stored[t.ID] = t
	rp.shop.Mapping[t.UID] = t
	count = count + 1
	return t
end

function rp.shop.Get(id)
	return rp.shop.Stored[id]
end

function rp.shop.GetByUID(uid)
	return rp.shop.Mapping[uid]
end

function rp.shop.GetTable()
	return rp.shop.Stored
end


-- Set
function upgrade_mt:SetStackable(stackable)
	self.Stackable = stackable
	return self
end

function upgrade_mt:SetCat(cat)
	self.Cat = cat
	return self
end

function upgrade_mt:SetDesc(desc)
	self.Desc = desc
	return self
end

function upgrade_mt:SetIcon(icon)
	self.Icon = icon
	return self
end

function upgrade_mt:SetImage(image)
	if CLIENT then
		texture.Create(image)
			:EnableProxy(false)
			:Download('https://cdn.superiorservers.co/rp/credit_shop/' .. image, function(s, material)
				self.ImageMaterial = material
			end)
	end
	return self
end

function upgrade_mt:SetPrice(price)
	self.Price = price
	return self
end

function upgrade_mt:SetGetPrice(func)
	self._GetPrice = func
	return self
end

function upgrade_mt:SetCanBuy(func)
	self._CanBuy = func
	return self
end

function upgrade_mt:SetOnBuy(func)
	self._OnBuy = func
	return self
end

function upgrade_mt:SetGetCustomPurchaseNote(func)
	self._GetCustomPurchaseNote = func
	return self
end

function upgrade_mt:SetWeapon(wep) -- We don't need 20 PlayerLoadout hooks
	rp.shop.Weapons[self:GetUID()] = wep
	self.Weapon = wep
	self:SetDesc('Вы будете всегда спавниться с ' .. self:GetName() .. '.')
	self:SetStackable(false)
	self:SetOnBuy(function(self, pl)
		local weps = pl:GetVar('PermaWeapons')
		weps[#weps + 1] = wep
		pl:SetVar('PermaWeapons', weps)
	end)
	return self
end

function upgrade_mt:AddHook(name, func)
	local uid = self:GetUID()
	hook(name, 'rp.upgrade.' .. name, function(pl, ...)
		if pl:HasUpgrade(uid) then
			func(pl, ...)
		end
	end)
	return self
end

function upgrade_mt:SetNetworked(networked)
	self.Networked = networked

	nw.Register('Upgrade_' .. self:GetUID())
		:Write(net.WriteInt, 32)
		:Read(net.ReadInt, 32)
		:SetLocalPlayer()

	return self
end

function upgrade_mt:SetTimeStamps(ts1, ts2)
	self.TimeStamps = {ts1, ts2}
	return self
end

function upgrade_mt:SetHidden(hidden)
	self.Hidden = hidden
	return self
end


-- Get
function upgrade_mt:GetName()
	return self.Name
end

function upgrade_mt:GetCat()
	return self.Cat
end

function upgrade_mt:GetDesc()
	return self.Desc
end

function upgrade_mt:GetIcon()
	return self.Icon
end

function upgrade_mt:GetImage()
	return self.ImageMaterial
end

function upgrade_mt:GetUID()
	return self.UID
end

function upgrade_mt:GetID()
	return self.ID
end

function upgrade_mt:GetWeapon()
	return self.Weapon
end

function upgrade_mt:GetPrice(pl)
	if self._GetPrice then
		return self:_GetPrice(pl)
	end
	return self.Price
end

function upgrade_mt:IsStackable()
	return (self.Stackable == true)
end

function upgrade_mt:IsNetworked()
	return (self.Networked == true)
end

function upgrade_mt:IsHidden()
	return (self.Hidden == true)
end

function upgrade_mt:IsInTimeLimit()
	if (self.TimeStamps) then
		local ostime = os.time()

		return (ostime >= self.TimeStamps[1] and ostime <= self.TimeStamps[2])
	end

	return true
end

function upgrade_mt:CanSee(pl)
	if (self:IsHidden() or !self:IsInTimeLimit()) then
		return false
	end

	return true
end

function upgrade_mt:CanBuy(pl)
	local canBuy, reason = true, nil

	if self._CanBuy then
		canBuy, reason = self:_CanBuy(pl)
	end

	if (not self:CanSee(pl)) then
		return false, 'Как вы вообще это видите?'
	elseif (not canBuy) then
		return canBuy, reason
	elseif (not self:IsStackable()) and pl:HasUpgrade(self:GetUID()) then
		return false, 'У вас уже куплено это улучшение!'
	elseif (not pl:CanAffordCredits(self:GetPrice(pl))) then
		return false, 'Вы не можете себе это позволить (' .. string.Comma(self:GetPrice(pl)) .. ' Кредитов)'
	end

	return true
end

function upgrade_mt:OnBuy(pl)
	if self._OnBuy then
		self:_OnBuy(pl)
	end
	if self:IsNetworked() then
		pl:SetNetVar('Upgrade_' .. self:GetUID(), pl:GetUpgradeCount(self:GetUID()))
	end
	if (self:GetWeapon() ~= nil) then
		pl:Give(self:GetWeapon())
	end
end

function upgrade_mt:GetCustomPurchaseNote(pl)
	if (self._GetCustomPurchaseNote) then
		return (' ' .. self:_GetCustomPurchaseNote(pl))
	end

	return ''
end


-- Player
function PLAYER:GetCredits()
	return self:GetNetVar('Credits') or 0
end

function PLAYER:CanAffordCredits(amount)
	if SERVER and (not rp.data.IsLoaded(self)) then return false end

	return (self:GetCredits() >= amount)
end

if (CLIENT) then
	function PLAYER:HasUpgrade(uid)
		return (self:GetNetVar('Upgrade_' .. uid) ~= nil)
	end

	function PLAYER:GetUpgradeCount(uid)
		return (self:GetNetVar('Upgrade_' .. uid) or 0)
	end
end
