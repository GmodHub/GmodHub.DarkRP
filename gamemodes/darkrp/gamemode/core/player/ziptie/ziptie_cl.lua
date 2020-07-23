rp.ziptie = rp.ziptie or {}
rp.ziptie.Ents = rp.ziptie.Ents or {}

local DefaultRope = Material("cable/rope")
local w = rp.col.Black
local rsm = render.SetMaterial
local rdb = render.DrawBeam
local off = Vector(0, 0, 6)
hook('PostPlayerDraw', 'rp.Zipties.PostPlayerDraw', function(pl)
	if (pl:IsZiptied() and pl:Alive()) then
		local b1 = pl:LookupBone("ValveBiped.Bip01_R_Hand")
		if (!b1) then return end

		local b2 = pl:LookupBone("ValveBiped.Bip01_L_Hand")
		local b3 = pl:LookupBone("ValveBiped.Bip01_R_Foot")
		local b4 = pl:LookupBone("ValveBiped.Bip01_L_Foot")
		local b5 = pl:LookupBone("ValveBiped.Bip01_Neck1")
		local pos1 = pl:GetBonePosition(b1)
		local pos2 = pl:GetBonePosition(b2)
		local pos3 = pl:GetBonePosition(b3)
		local pos4 = pl:GetBonePosition(b4)
		local pos5 = pl:GetBonePosition(b5)

		rsm( DefaultRope )
		rdb( pos1, pos2, 0.7, 0, 5, w )
		rdb( pos2, pos4, -0.7, 0, 5, w )
		rdb( pos1, pos3, -0.7, 0, 5, w )
		rdb( pos4, pos3, -0.7, 0, 5, w )
		rdb( pos1, pos4, -0.7, 0, 5, w )
		rdb( pos2, pos3, -0.7, 0, 5, w )
		rdb( pos1, pos5, -0.7, 0, 5, w )
		rdb( pos2, pos5, -0.7, 0, 5, w )
	end

	if pl:IsCarrying() then
		local carried = pl:GetCarried()

		if (not IsValid(pl.Ragdoll)) and IsValid(carried) then
			pl.Ragdoll = ClientsideModel(carried:GetModel(), RENDERGROUP_BOTH)

			local ent = pl.Ragdoll

			if (not IsValid(ent)) then return end

			ent.Carrier = pl
			ent.Carried = carried

			rp.ziptie.Ents[ent] = true

			ent:SetSequence(ent:LookupSequence('sit'))
		end

		local b1 = pl:LookupBone("ValveBiped.Bip01_R_Hand") or pl:LookupBone("ValveBiped.Bip01_L_Hand") or pl:LookupBone("ValveBiped.Bip01_Neck1")

		if (not b1) or (not IsValid(pl.Ragdoll)) then return end

		local pos, ang = pl:GetBonePosition(b1)
		local ang = pl:EyeAngles()

		ang.pitch = 90
		ang.roll = 180
		pos.z = pos.z + 15

		pl.Ragdoll:SetPos(pos)
		pl.Ragdoll:SetAngles(ang)

		pl.Ragdoll:SetRenderOrigin(pos)
		pl.Ragdoll:SetRenderAngles(ang)
		pl.Ragdoll:SetupBones()
		pl.Ragdoll:DrawModel()

		pl.Ragdoll:SetRenderOrigin()
		pl.Ragdoll:SetRenderAngles()
	elseif IsValid(pl.Ragdoll) then
		pl.Ragdoll:Remove()
		pl.Ragdoll = nil
	end

	if (IsValid(pl:GetActiveWeapon()) and pl:GetActiveWeapon():GetClass() == "weapon_ziptie") then
		local b1 = pl:LookupBone("ValveBiped.Bip01_R_Hand")
		if (!b1) then return end

		local b2 = pl:LookupBone("ValveBiped.Bip01_L_Hand")
		local pos1 = pl:GetBonePosition(b1) + pl:EyeAngles():Forward() * 4
		local pos2 = pl:GetBonePosition(b2) + pl:EyeAngles():Forward() * 4

		rsm( DefaultRope )
		rdb( pos1, pos2, 0.7, 0, 5, w )
		rdb( pos1, pos1 - off, -0.7, 0, 5, w )
		rdb( pos2, pos2 - off, -0.7, 0, 5, w)
	end

	for k, v in pairs(rp.ziptie.Ents) do
		if (!IsValid(k) or !IsValid(k.Carrier) or !IsValid(k.Carried) or !k.Carried:IsBeingCarried()) then
			rp.ziptie.Ents[k] = nil
			SafeRemoveEntity(k)
		end
	end
end)

hook('PrePlayerDraw', 'rp.Zipties.PrePlayerDraw', function(pl)
	if (pl:IsBeingCarried() and IsValid(pl:GetCarrier()) and pl:GetCarrier() == LocalPlayer() and !rp.thirdPerson.isEnabled()) then
		return true
	end
end)

hook('ZiptieStatusChanged', 'rp.Zipties.ZiptieStatusChanges', function(pl, ziptied)
	pl.Interactions = ziptied and {{Key="G",Text="Обрезать Стяжки"}} or nil
end)
