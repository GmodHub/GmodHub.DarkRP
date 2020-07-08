rp.hats = rp.hats or {}
rp.hats.List = {}

local c = 0
function rp.hats.Add(data)
	c = c + 1
	data.model = string.lower(data.model or "")
	data.model = string.Replace(data.model, "\\", "/")
	data.model = string.gsub(data.model, "[\\/]+", "/")

	if (CLIENT) then
		util.PrecacheModel(data.model)
	end

	local dbuid = util.CRC(data.model .. (data.skin or ''))

	data.type = data.type or 1

	if (not data.slots) then
		if (data.type == 1) then 		-- Hats
			data.slots = {
				[1] = true,
				[2] = true,
			}
		elseif (data.type == 2) then 	-- Masks
			data.slots = {
				[1] = true,
				[2] = true,
				[3] = true
			}
		elseif (data.type == 3) then 	-- Glasses
			data.slots = {
				[2] = true,
				[3] = true
			}
		elseif (data.type == 4) then  	-- Scarves
			data.slots = {
				[4] = true
			}
		end

	end

	rp.hats.List[dbuid] = {
		name 		= data.name or 'unkown',
		model 		= data.model,
		skin 		= data.skin,
		category 	= data.category or 'Misc',
		type 		= data.type,
		slots 		= data.slots,
		price 		= data.price,
		credits 	= math.max(250, math.floor(data.price/8000)) ,
		scale 		= data.scale or 1,
		offpos 		= data.offpos or Vector(0,0,0),
		offang 		= data.offang or Angle(0,0,0),
		usebounds	= (data.infooffset == nil),
		infooffset 	= data.infooffset or 5,
		UID 		= dbuid,
		ShouldRender = (data.game and IsMounted(data.game)) or file.Exists(data.model, 'GAME') or file.Exists(data.model, 'WORKSHOP')
	}

	--print(rp.hats.List[dbuid].ShouldRender, IsMounted(data.game))
end


function PLAYER:GetHat()
	return self:GetNetVar('Hat') and rp.hats.List[self:GetNetVar('Hat')]
end

local empty = {}
function PLAYER:GetApparel()
	return self:GetNetVar('ActiveApparel')
end

function PLAYER:HasApparel(uid)
	local ownedApparel = self:GetNetVar('OwnedApparel')
	return ownedApparel and (ownedApparel[uid] ~= nil)
end

hook('rp.AddUpgrades', 'rp.Cosmetics.Hats', function()
	for k, v in SortedPairsByMemberValue(rp.hats.List, 'price', false) do
		local obj = rp.shop.Add(v.name, 'hat_' .. v.name)
			obj:SetCat('Hats')
			obj:SetDesc('Permanently gives you the ' .. v.name .. ' hat.')
			obj:SetPrice(v.credits)
			obj:SetCanBuy(function(self, pl)
				if (pl:HasUpgrade(pl, 'hat_' .. v.name)) or pl:HasApparel(v.UID) then
					return false, 'You\'ve already purchased this.'
				end
				return true
			end)
			obj:SetOnBuy(function(self, pl)
				rp.data.AddApparel(pl, v.UID, function()
					if IsValid(pl) then
						pl:AddOwnedApparel(v.UID)
						pl:AddApparel(v)
					end
				end)
			end)
			rp.hats.List[k].upgradeobj = obj
	end
end)
