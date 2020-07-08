/*util.AddNetworkString('rp.InvalidateOutfit')

function PLAYER:SetOutfit(name)
	self:SetNetVar('Outfit', (rp.Clothes[name] or rp.Clothes['Winter Coat']).ID)
end

rp.AddCommand('setoutfit', function(pl, text, args)
	if (!pl:IsRoot()) then return end
	
	pl:SetOutfit(text)
end)

hook('PlayerSpawn', 'rp.cosmetics.clothing.InvalidateOutfit', function(pl)
	net.Start('rp.InvalidateOutfit')
		net.WriteEntity(pl)
	net.Broadcast()
end)