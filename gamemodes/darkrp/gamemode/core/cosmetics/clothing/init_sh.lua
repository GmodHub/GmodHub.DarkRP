/*rp.Clothes 		= {}
rp.ClothesMap 	= {}

function rp.AddClothing(name, inf)
	local id = #rp.ClothesMap + 1

	inf.ID = id
	inf.Name = name
	inf.Credits = math.floor(inf.Price/1250)
	rp.Clothes[inf.File] = inf
	rp.ClothesMap[id] = inf.File
	for k, v in ipairs(inf.Teams) do
		rp.teams[v].Outfits[inf.File] = true
	end
end

function ENTITY:GetOutfit() -- entity metatable since we use this on a DModelPanel too
	return self:GetNetVar('Outfit') and rp.ClothesMap[self:GetNetVar('Outfit')]
end

function ENTITY:GetOutfitMaterial()
	return self:GetNetVar('Outfit') and rp.Clothes[rp.ClothesMap[self:GetNetVar('Outfit')]].Material
end

if (SERVER) then
	function PLAYER:HasOutfit(outfit)
		return self:GetVar('Outfits') and (self:GetVar('Outfits')[outfit] or false)
	end
else
	function PLAYER:HasOutfit(outfit)
		return self:GetNetVar('Outfits') and (self:GetNetVar('Outfits')[outfit] or false)
	end
end

function PLAYER:CanUseOutfit(outfit)
	return self:GetTeamTable().Outfits[outfit] or false
end


hook('rp.AddUpgrades', 'rp.Cosmetics.Outfits', function()
	for k, v in pairs(rp.Clothes) do
		local obj = rp.shop.Add(v.Name, 'hat_' .. v.Name)
			obj:SetCat('Outfits')
			obj:SetDesc('Permanently gives you the ' .. v.Name .. ' outfit.')
			obj:SetPrice(v.Credits)
			obj:SetCanBuy(function(self, pl)
				if pl:HasOutfit(v.File) then
					return false, 'You\'ve already purchased this.'
				end
				return true
			end)
			obj:SetOnBuy(function(self, pl)
				rp.data.AddOutfit(pl, v.File, cback)
			end)
			rp.Clothes[k].UpgradeObj = obj
	end
end)
