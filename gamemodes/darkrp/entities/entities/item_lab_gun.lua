AddCSLuaFile()

ENT.Type 		= 'anim'
ENT.Base 		= 'lab_base'
ENT.PrintName 	= 'Мастерская'

ENT.MainModel = "models/props/cs_italy/it_mkt_table3.mdl"

function ENT:GetCraftName()
	local ship = rp.shipments[self:GetCraftID()]
	return ship and ship.name or "N/A"
end

function ENT:GetCraftables()
	return rp.Weapons
end

if (SERVER) then
concommand.Add("gunlabme", function(p)
		if (!p:IsRoot()) then return end

		local pos = p:GetEyeTrace().HitPos
		local e = ents.Create("item_lab_gun")
		e:SetPos(pos)
		e:Spawn()
		e:CPPISetOwner(p)
	end)
	return end

ENT.AccessoryModels = {
	{
		"models/props_lab/powerbox02d.mdl",
		Vector(13.031250, 29.5, 32.875000),
		Angle(-90, 0, 180)
	},
	{
		"models/props_lab/reciever01b.mdl",
		Vector(-16.60000, 25.65, 31.156250),
		Angle(0, 180, 0)
	},
	{
		"models/maxofs2d/motion_sensor.mdl",
		Vector(16, -5, 29.937500),
		Angle(0, 180, 0)
	}
}

ENT.MetalsPositions = {
	{
		Vector(13.375, 16.843, 30.406),
		Angle(356, 318, 180)
	},
	{
		Vector(14.21, 20.442, 33),
		Angle(29.663, 211.465, 3.032)
	},
	{
		Vector(13.53, 14.849, 33),
		Angle(-11.492, 133.824, -11.091)
	}
}

ENT.ProgressModel = {
	"models/props/de_prodigy/ammo_can_02.mdl",
	Vector(0, -5, 28.968750),
	Angle(0, 180, 0)
}
