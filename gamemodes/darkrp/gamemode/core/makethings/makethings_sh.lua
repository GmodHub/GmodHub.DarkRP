local blockTypes = {"Physgun1", "Spawning1", "Toolgun1"}

local checkModel = function(model) return model ~= nil and (CLIENT or util.IsValidModel(model)) end
local requiredTeamItems = {"color", "model", "weapons", "command", "max"}
local validShipment = {model = checkModel, "entity", "price", "amount", "seperate", "allowed"}
local validVehicle = {"name", model = checkModel, "price"}
local validEntity = {"ent", model = checkModel, "price", "max", "cmd", "name"}
local function checkValid(tbl, requiredItems)
	for k, v in pairs(requiredItems) do
		local isFunction = type(v) == "function"

		if (isFunction and not v(tbl[k])) or (not isFunction and tbl[v] == nil) then
			return isFunction and k or v
		end
	end
end

rp.teams = {}
function rp.addTeam(Name, CustomTeam)
	CustomTeam.name = Name
	CustomTeam.Outfits = {}

	local corrupt = checkValid(CustomTeam, requiredTeamItems)
	if corrupt then ErrorNoHalt("Corrupt team \"" ..(CustomTeam.name or "") .. "\": element " .. corrupt .. " is incorrect.\n") end

	table.insert(rp.teams, CustomTeam)
	team.SetUp(#rp.teams, Name, CustomTeam.color)
	local t = #rp.teams
	CustomTeam.team = t

	if SERVER then
		timer.Simple(0, function() GAMEMODE:AddTeamCommands(CustomTeam, CustomTeam.max) end)
	end

	for k, v in pairs(CustomTeam.spawns or {}) do
		rp.cfg.TeamSpawns[k] = rp.cfg.TeamSpawns[k] or {}
		rp.cfg.TeamSpawns[k][t] = v
	end

	// Precache model here. Not right before the job change is done
	if type(CustomTeam.model) == "table" then
		for k,v in pairs(CustomTeam.model) do util.PrecacheModel(v) end
	else
		util.PrecacheModel(CustomTeam.model)
	end
	return t
end

rp.shipments = {}
rp.ShipmentMap = {}
function rp.AddShipment(name, model, entity, price, Amount_of_guns_in_one_shipment, Sold_seperately, price_seperately, noshipment, classes, shipmodel, CustomCheck, index)
	local tableSyntaxUsed = type(model) == "table"

	if (not Sold_seperately) then -- quick fix for bmi lab
		price_seperately = nil
	end

	local AllowedClasses = classes or {}
	if not classes then
		for k,v in ipairs(team.GetAllTeams()) do
			table.insert(AllowedClasses, k)
		end
	end

	local price = tonumber(price)
	local shipmentmodel = shipmodel or "models/Items/item_item_crate.mdl"

	local customShipment = tableSyntaxUsed and model or
		{model = model, entity = entity, price = price, amount = Amount_of_guns_in_one_shipment,
		seperate = Sold_seperately, pricesep = price/Amount_of_guns_in_one_shipment, noship = noshipment, allowed = AllowedClasses,
		shipmodel = shipmentmodel, customCheck = CustomCheck, weight = 5, index = index}

	customShipment.pricesep = (price_seperately or (customShipment.price/customShipment.amount))
	customShipment.seperate = customShipment.separate or customShipment.seperate
	customShipment.name = name
	customShipment.allowed = customShipment.allowed or {}

	local allowed = {}
	for k, v in ipairs(customShipment.allowed) do
		allowed[v] = true
	end
	customShipment.allowed = allowed

	local corrupt = checkValid(customShipment, validShipment)
	if corrupt then ErrorNoHalt("Corrupt shipment \"" .. (name or "") .. "\": element " .. corrupt .. " is corrupt.\n") end

	if SERVER then
		rp.nodamage[customShipment.entity] = true
	end

	local index = customShipment.index
	if (not index) then
		index = 1
		for k, v in ipairs(rp.shipments) do
			index = index + 1
		end
	end

	rp.inv.Wl[customShipment.entity] = name
	rp.ShipmentMap[customShipment.entity] = index
	rp.shipments[index] = customShipment

	util.PrecacheModel(customShipment.model)
end

rp.entities = {}
rp.EntityMap = {}
function rp.AddEntity(name, entity, model, price, max, command, classes, pocket)
	local tableSyntaxUsed = type(entity) == "table"

	local tblEnt = tableSyntaxUsed and entity or
		{ent = entity, model = model, price = price, max = max,
		cmd = command, allowed = classes, pocket = pocket}
	tblEnt.name = name
	tblEnt.allowed = tblEnt.allowed or {}
	tblEnt.catagory = tblEnt.catagory or 'Misc'

	if type(tblEnt.allowed) == "number" then
		tblEnt.allowed = {tblEnt.allowed}
	end

	if #tblEnt.allowed == 0 then
		for k,v in ipairs(team.GetAllTeams()) do
			table.insert(tblEnt.allowed, k)
		end
	end

	local corrupt = checkValid(tblEnt, validEntity)
	if corrupt then ErrorNoHalt("Corrupt Entity \"" .. (name or "") .. "\": element " .. corrupt .. " is corrupt.\n") end

	if SERVER then
		rp.nodamage[entity] = true
	end

	local allowed = {}
	for k, v in ipairs(tblEnt.allowed) do
		allowed[v] = true
	end
	tblEnt.allowed = allowed

	table.insert(rp.entities, tblEnt)
	rp.EntityMap[tblEnt.ent] = tblEnt

	if SERVER then
		timer.Simple(0, function() GAMEMODE:AddEntityCommands(tblEnt) end)
	end

	if (tblEnt.pocket ~= false) then
		rp.inv.Wl[tblEnt.ent] = name
	end

	util.PrecacheModel(tblEnt.model)
end

rp.Foods = {}
function rp.AddFoodItem(name, mdl, amount)
	rp.Foods[name] = { model = mdl, amount = amount } -- to laz
	rp.Foods[#rp.Foods + 1] = {name = name, model = mdl, amount = amount}

	util.PrecacheModel(mdl)
end

rp.CopItems = {}
function rp.AddCopItem(name, price, model, weapon, callback)
	if istable(price) then
		rp.CopItems[name] = {
			Name = name,
			Price = price.Price,
			Model = Model(price.Model),
			Weapon = price.Weapon,
			Callback = price.Callback
		}
	else
		rp.CopItems[name] = {
			Name = name,
			Price = price,
			Model = Model(model),
			Weapon = weapon,
			Callback = callback
		}
	end
end

rp.Drugs = {}
rp.DrugsMap = {}
function rp.AddDrug(inf)
	local class = 'drug_' .. inf.Name:gsub(' ', ''):lower()

	inf.Class = class
	inf.BuyPrice = math.ceil(inf.Price * 0.5)

	local index = #rp.Drugs + 1

	local endhigh = inf.EndHigh
	inf.EndHigh = function(pl, ...)
		if inf.ClientHooks then
			net.Start 'rp.EndHigh'
				net.WriteUInt(index, 6)
			net.Send(pl)
		end
		if endhigh then
			endhigh(pl, ...)
		end
	end

	rp.Drugs[index] = inf
	rp.DrugsMap[class] = inf

	rp.AddShipment(inf.Name, {
		index = inf.Index,
		model = inf.Model,
		entity = class,
		amount = 10,
		price = math.ceil(inf.Price * 10),
		seperate = false,
		allowed = inf.Team
	})

	scripted_ents.Register({
		Name 		= inf.Name,
		PrintName 	= inf.Name,
		Type 		= 'anim',
		Base		= 'drug_base',
		Category 	= 'RP Drugs',
		PressE 		= true,
		Spawnable	= true,
		Model 		= Model(inf.Model),
		Color 		= inf.Color,
		Index 		= index,
	}, class)
end

rp.Weapons = {}
rp.WeaponsMap = {}
function rp.AddWeapon(name, model, entity, price, classes)
	local price_seperately = math.ceil(price/10*1.25)

	local inf = {
		Name = name,
		Class = entity,
		Model = Model(model),
		BuyPrice = math.ceil((price/10) * 0.5)
	}

	rp.Weapons[#rp.Weapons + 1] = inf
	rp.WeaponsMap[entity] = inf

	rp.AddShipment(name, model, entity, price, 10, true, price_seperately, false, classes)
	rp.AddCopItem(name, price_seperately, model, entity)
end

rp.BMILabCraftables = {}
function rp.AddBMI(name, model, entity, price, Amount_of_guns_in_one_shipment, Sold_seperately, price_seperately, noshipment, classes, shipmodel, CustomCheck, index)
	local tableSyntaxUsed = type(model) == "table"
	if (tableSyntaxUsed) then return end

	local price_seperately = price/Amount_of_guns_in_one_shipment*1.25
	rp.BMILabCraftables[#rp.BMILabCraftables + 1] = {
		Class = entity,
		Model = Model(model),
	}
	rp.AddShipment(name, model, entity, price, Amount_of_guns_in_one_shipment, Sold_seperately, price_seperately, noshipment, classes, shipmodel, CustomCheck, index)
end

rp.agendas = {}
function rp.AddAgenda(title, manager, listeners)
	for k, v in ipairs(listeners) do
		rp.agendas[v] = {title = title, manager = manager}
	end
	rp.agendas[manager] = {title = title, manager = manager}

	nw.Register('Agenda;' .. manager)
		:Read(net.ReadString)
		:Write(net.WriteString)
		:SetGlobal()
end

rp.groupChats = {}
function rp.addGroupChat(name, ...)
	local classes = {...}
	table.foreach(classes, function(k, class)
		rp.groupChats[class] = {Name = name}
		table.foreach(classes, function(k, class2)
			rp.groupChats[class][class2] = true
		end)
	end)
end

rp.groupBans = {}
function rp.addGroupBan(...)
	local classes = {...}
	table.foreach(classes, function(k, class)
		rp.groupBans[class] = {}
		table.foreach(classes, function(k, class2)
			if (class == class2) then return end

			rp.groupBans[class][class2] = true
		end)
	end)
end

rp.ammoTypes = {}
function rp.AddAmmoType(ammoType, name, model, price, amountGiven, special, customCheck)
	game.AddAmmoType {
		name = ammoType,
		dmgtype = DMG_BULLET,
	}

	table.insert(rp.ammoTypes, {
		ammoType = ammoType,
		special = special,
		name = name,
		model = model,
		price = price,
		amountGiven = amountGiven,
		customCheck = customCheck
	})
end
