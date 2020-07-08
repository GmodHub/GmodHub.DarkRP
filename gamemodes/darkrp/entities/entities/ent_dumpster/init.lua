AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--[[------------------------------------------------------------------------------------

	THINGS YOU CAN EDIT

--]]------------------------------------------------------------------------------------
local recharge_time = 180 //Time between each recharge after using the dumpster
local prop_delete_time = 10 //Time of how long the props that shoot out will last
local minimum_amount_items = 1 //Least amount of items that can come from dumpster
local maximum_amount_items = 4 //Max amount of items that can come from dumpster
local open_sound = "physics/metal/metal_solid_strain5.wav" //Sound played when the dumpster is used

--Keep all of these numbers whole numbers between 1-100
local prop_percentage = 100 //When set to 100, if no entities or weapons were created, then a prop will be
local ent_percentage = 15
local weapon_percentage = 5
--Keep all of these numbers whole numbers between 1-100

local Dumpster_Items = {
	Props = { --Add/Change models of props
		"models/props_c17/FurnitureShelf001b.mdl",
		"models/props_c17/FurnitureDrawer001a_Chunk02.mdl",
		"models/props_interiors/refrigeratorDoor02a.mdl",
		"models/props_lab/lockerdoorleft.mdl",
		"models/props_wasteland/prison_lamp001c.mdl",
		"models/props_wasteland/prison_shelf002a.mdl",
		"models/props_vehicles/tire001c_car.mdl",
		"models/props_trainstation/traincar_rack001.mdl",
		"models/props_interiors/SinkKitchen01a.mdl",
		"models/props_c17/lampShade001a.mdl",
		"models/props_junk/PlasticCrate01a.mdl",
		"models/props_c17/metalladder002b.mdl",
		"models/Gibs/HGIBS.mdl",
		"models/props_c17/metalPot001a.mdl",
		"models/props_c17/streetsign002b.mdl",
		"models/props_c17/pottery06a.mdl",
		"models/props_combine/breenbust.mdl",
		"models/props_lab/partsbin01.mdl",
		"models/props_trainstation/payphone_reciever001a.mdl",
		"models/props_vehicles/carparts_door01a.mdl",
		"models/props_vehicles/carparts_axel01a.mdl"
	},

	Ents =  { --Change these to entites you want
		"armor_piece_full",
		"durgz_alcohol",
		"durgz_aspirin",
		"durgz_cigarette",
		"durgz_cocaine",
		"durgz_heroine",
		"durgz_lsd",
		"durgz_weed",
		"durgz_mushroom",
		"durgz_water",
		--"spawned_food"
	},

	Weapons = { --Change these to weapons that you want
		"swb_357",
		"swb_ak47",
		"swb_awp",
		"swb_deagle",
		"swb_famas",
		"swb_fiveseven",
		"swb_p90",
		"swb_g3sg1",
		"swb_glock18",
		"swb_mp5",
		"swb_ump",
		"swb_galil",
		"swb_knife",
		"swb_m249",
		"swb_m3super90",
		"swb_sg550",
		"swb_sg552",
		"swb_aug",
		"swb_tmp",
		"swb_xm1014",
		"swb_usp"
	}
}


--[[------------------------------------------------------------------------------------

	THINGS YOU CAN EDIT

--]]------------------------------------------------------------------------------------

function ENT:Initialize()
	self:SetModel("models/props_junk/TrashDumpster01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
end

function ENT:OnTakeDamage(dmginfo)
	return
end

function ENT:EmitItems(searcher)
	self:EmitSound(open_sound, 300, 100)
	local pos = self:GetPos() + ((self:GetAngles():Up() * 15) + (self:GetAngles():Forward() * 20))

	for i = 1, math.random(minimum_amount_items,maximum_amount_items) do
		if math.random(1, 100) <= weapon_percentage then
			local ent = ents.Create(table.Random(Dumpster_Items["Weapons"]))
			ent:SetPos(pos)
			ent:Spawn()
		elseif math.random(1, 100) <= ent_percentage then
			local ent = ents.Create(table.Random(Dumpster_Items["Ents"]))
			ent:SetPos(pos)
			ent:Spawn()
		elseif math.random(1, 100) <= prop_percentage then
			local prop = ents.Create("prop_physics_multiplayer")
			prop:SetModel(table.Random(Dumpster_Items["Props"]))
			prop:SetPos(pos)
			prop:Spawn()

			timer.Simple(prop_delete_time, function() -- Remove the prop after x seconds
				if prop:IsValid() then
					prop:Remove()
				end
			end)
		end
	end
end

function ENT:Use(activator)
	if self:GetDTInt(0) > CurTime() then return end

	if not rp.teams[activator:Team()].hobo then
		rp.Notify(activator, NOTIFY_ERROR, term.Get('MustBeHobo') )
		return
	end

	self:SetDTInt(0, CurTime() + recharge_time)
	self:EmitItems(activator)
end

hook.Add("InitPostEntity", "SpawnDumpsters", function()
	timer.Simple(2, function()
		for k,v in pairs(rp.cfg.Dumpsters[game.GetMap()] or {}) do
			local dump = ents.Create("ent_dumpster")
			dump:SetPos(v[1])
			dump:SetAngles(v[2])
			dump:Spawn()
		end
	end)
end)
