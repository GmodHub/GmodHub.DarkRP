AddCSLuaFile()

ENT.Type 		= 'anim'
ENT.Base 		= 'lab_base'
ENT.PrintName 	= 'Нелегальная Мастерская'

ENT.WantReason = 'Black Market Item (BMI Lab)'

ENT.MainModel = "models/props/cs_italy/it_mkt_table1.mdl"

function ENT:GetCraftName()
	local ship = rp.shipments[self:GetCraftID()]
	return ship and ship.name or "N/A"
end

function ENT:GetCraftables()
	return rp.BMILabCraftables
end

if (SERVER) then
concommand.Add("bmilabme", function(p)
		if (!p:IsRoot()) then return end

		local pos = p:GetEyeTrace().HitPos
		local e = ents.Create("item_lab_bmi")
		e:SetPos(pos)
		e:Spawn()
		e:CPPISetOwner(p)
	end)
	return end

ENT.AccessoryModels = {
	{
		"models/props_lab/tpplugholder_single.mdl",
		Vector(5.931250, 47.5, 32.375000),
		Angle(-75, 0, 180)
	},
	{
		"models/maxofs2d/hover_propeller.mdl",
		Vector(0.60000, -29.65, 23.156250),
		Angle(75, 180, 0)
	},
	{
		"models/props/de_nuke/light_red2.mdl",
		Vector(-18, -43, 38.337500),
		Angle(195, 0, 0)
	}
}

ENT.MetalsPositions = {
	{
		Vector(19.875, -40.843, 30.406),
		Angle(356, 138, 180)
	},
	{
		Vector(18.21, -34.442, 31),
		Angle(0.663, 31.465, -8.632)
	},
	{
		Vector(15.53, -37.849, 31.5),
		Angle(-0.492, -80.824, 0.091)
	}
}

ENT.ProgressModel = {
	"models/props/de_prodigy/ammo_can_02.mdl",
	Vector(0, -10, 33.968750),
	Angle(-15, 180, 0)
}

function ENT:Get3D2DInfo()
	local pos = self:GetPos()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 90)

	return pos + ang:Right() * -11.2 + ang:Up() * 26.1, ang, true
end
