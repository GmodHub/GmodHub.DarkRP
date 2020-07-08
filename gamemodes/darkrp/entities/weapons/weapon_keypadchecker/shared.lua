if SERVER then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_init.lua")

	util.AddNetworkString("DarkRP_keypadData")
end

SWEP.Base = "weapon_base"

SWEP.PrintName = "Admin keypad checker"
SWEP.Instructions = "Left click on a keypad or fading door to check it, right click to clear"
SWEP.Slot = 1
SWEP.DrawAmmo = false
SWEP.ViewModelFlip = false
SWEP.Primary.ClipSize = 0
SWEP.Primary.Ammo = ""

SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.Category = "DarkRP (Utility)"

SWEP.HoldType = "normal"
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"
SWEP.IconLetter = ""

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.UseHands = true

if not SERVER then return end

/*
	Gets which entities are controlled by which keyboard keys
*/
local function getTargets(keypad, keyPass, keyDenied, delayPass, delayDenied)
	local targets = {}
	local Owner = keypad:CPPIGetOwner()

	for k,v in pairs(numpad.OnDownItems or {}) do
		if (!IsValid(v.ent)) then numpad.OnDownItems[k] = nil continue end

		if v.key == keyPass and v.ply == Owner then
			table.insert(targets, {type = "Entering the right password", name = v.name, ent = v.ent, original = keypad})
		end
		if v.key == keyDenied and v.ply == Owner then
			table.insert(targets, {type = "Entering a wrong password", name = v.name, ent = v.ent, original = keypad})
		end
	end

	for k,v in pairs(numpad.OnUpItems or {}) do
		if (!IsValid(v.ent)) then numpad.OnUpItems[k] = nil continue end

		if v.key == keyPass and v.ply == Owner then
			table.insert(targets, {type = "after having entered the right password", name = v.name, delay = math.Round(delayPass, 2), ent = v.ent, original = keypad})
		end
		if v.key == keyDenied and v.ply == Owner then
			table.insert(targets, {type = "after having entered wrong password", name = v.name, delay = math.Round(delayDenied, 2), ent = v.ent, original = keypad})
		end
	end

	return targets
end

local function get_keypad_Info(keypad)
	local keyPass = tonumber(keypad.Data.Granted.Num) or 0
	local keyDenied = tonumber(keypad.Data.Denied.Num) or 0
	local delayPass = tonumber(keypad.Data.Granted.Hold) or 0
	local delayDenied = tonumber(keypad.Data.Denied.Hold) or 0

	return getTargets(keypad, keyPass, keyDenied, delayPass, delayDenied)
end

local function get_button_Info(button)
	local targets = {}
	local key = button:GetKey()
	local entOwner = button:CPPIGetOwner()

	for k,v in pairs(numpad.OnDownItems or {}) do
		if (!IsValid(v.ent)) then numpad.OnDownItems[k] = nil continue end

		if v.key == key and v.ply == entOwner then
			table.insert(targets, {type = "On pressed", ent = v.ent, original = button})
		end
	end

	for k,v in pairs(numpad.OnUpItems or {}) do
		if (!IsValid(v.ent)) then numpad.OnDownItems[k] = nil continue end

		if v.key == key and v.ply == entOwner then
			table.insert(targets, {type = "On released", ent = v.ent, original = button})
		end
	end

	return targets
end


/*---------------------------------------------------------------------------
Get the keypads that trigger this entity
---------------------------------------------------------------------------*/
local function getEntityKeypad(ent)
	local targets = {}
	local doorKey = ""
	local entOwner = ent:CPPIGetOwner()

	if (ent.FadeKey) then
		doorKey = ent.FadeKey
	end

	for k, v in ipairs(ents.FindByClass("pad_containing_some_keys_for_fading_doors")) do
		local vOwner = v:CPPIGetOwner()

		if vOwner == entOwner and v.Data.Granted.Num == doorKey then
			table.insert(targets, {type = "Right password entered", ent = v, original = ent})
		end
		if vOwner == entOwner and v.Data.Denied.Num == doorKey then
			table.insert(targets, {type = "Wrong password entered", ent = v, original = ent})
		end
	end

	for k, v in ipairs(ents.FindByClass("gmod_button")) do
		if (v:CPPIGetOwner() == entOwner and v:GetKey() == doorKey) then
			table.insert(targets, {type = "Buttons", ent = v, original = ent})
		end
	end

	for k, v in ipairs(ents.FindByClass("pad_button")) do
		if (v.FadeUID == ent.FadeUID) then
			table.insert(targets, {type = "Buttons", ent = v, original = ent})
		end
	end

	for k, v in ipairs(ents.FindByClass("pad_biometric")) do
	if (v.FadeUID == ent.FadeUID) then
			table.insert(targets, {type = "Biometrics", ent = v, original = ent})
		end
	end

	for k, v in ipairs(ents.FindByClass("pad_toll")) do
		if (v.FadeUID == ent.FadeUID) then
			table.insert(targets, {type = "Tolls", ent = v, original = ent})
		end
	end

	return targets
end

local function getSimplePad(ent)
	local targets = {}

	for k, v in ipairs(ent:GetProps()) do
		table.insert(targets, {type = "Prop", ent = v, original = ent})
	end

	return targets
end

/*---------------------------------------------------------------------------
Send the info to the client
---------------------------------------------------------------------------*/
function SWEP:PrimaryAttack()
	local trace = self.Owner:GetEyeTrace()
	local ent, class = trace.Entity, trace.Entity:GetClass()
	local data

	if class == "pad_containing_some_keys_for_fading_doors" then
		data = get_keypad_Info(ent)
		rp.Notify(self.Owner, NOTIFY_GENERIC, term.Get('KeypadControlsX'), #data/2)
	elseif class == "gmod_button" then
		data = get_button_Info(ent)
		rp.Notify(self.Owner, NOTIFY_GENERIC, term.Get('ButtonControlsX'), #data/2)
	elseif (ent.Base == 'pad_base') then
		data = getSimplePad(ent)
		rp.Notify(self.Owner, NOTIFY_GENERIC, term.Get('KeypadControlsX'), #data)
	else
		data = getEntityKeypad(ent)
		rp.Notify(self.Owner, NOTIFY_GENERIC, term.Get('EntityControlledByX'), #data)
	end

	net.Start("DarkRP_keypadData")
		net.WriteTable(data)
	net.Send(self.Owner)
end

function SWEP:SecondaryAttack()
end

if not SERVER then return end
numpad.OldOnUp = numpad.OldOnUp or numpad.OnUp
numpad.OldOnDown = numpad.OldOnDown or numpad.OnDown
numpad.OldRemove = numpad.OldRemove or numpad.Remove
numpad.OnUpItems = numpad.OnUpItems or {}
numpad.OnDownItems = numpad.OnDownItems or {}

function numpad.OnUp(ply, key, name, ent, ...)
	local impulse = numpad.OldOnUp(ply, key, name, ent, ...)
	numpad.OnUpItems[impulse] = {ply = ply, key = key, name = name, ent = ent, arg = {...}}

	return impulse
end

function numpad.OnDown(ply, key, name, ent, ...)
	local impulse = numpad.OldOnDown(ply, key, name, ent, ...)
	numpad.OnDownItems[impulse] = {ply = ply, key = key, name = name, ent = ent, arg = {...}}

	return impulse
end

function numpad.Remove(impulse)
	numpad.OnUpItems[impulse] = nil
	numpad.OnDownItems[impulse] = nil

	return numpad.OldRemove(impulse)
end
