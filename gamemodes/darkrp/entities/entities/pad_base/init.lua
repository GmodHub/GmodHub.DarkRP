AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.Props = {}

------------
-- Fading --
------------
local config = {
	material = 'sprites/heatwave';
	mintime  = false;
}

local function IsFading(ent)
	return IsValid(ent) and ent.isFadingDoor;
end

local function Fade(ent)
	--[[if (not IsFading(ent) or ent._fade.active) then
		print("We are bailing for some reason")
		return
	end]]
	ent._fade.active = true;
	ent._fade.material = ent:GetMaterial();
	ent._fade.fadeTime = CurTime();

	ent:SetMaterial(config.material);
	ent:DrawShadow(false);
	ent:SetNotSolid(true);

	local phys = ent:GetPhysicsObject();
	if (not IsValid(phys)) then
		return;
	end
	ent._fade.unfrozen = phys:IsMoveable();
	ent._fade.velocity = phys:GetVelocity();
	ent._fade.angvel   = phys:GetAngleVelocity();
	phys:EnableMotion(false);
end

local function Unfade(ent)
	if (config.mintime and ent._fade.fadeTime) then
		local t = ent._fade.fadeTime + config.mintime;
		local c = CurTime();
		if (t > c) then
			ent._fade.mintimeTimer = true;
			timer.Simple(t - c, function() mintimeTimer(ent); end);
			return;
		end
	end

	ent._fade.active = false;
	ent:SetMaterial(ent._fade.material);
	ent:DrawShadow(true);
	ent:SetNotSolid(false);

	local phys = ent:GetPhysicsObject();
	if (not IsValid(phys)) then
		return;
	end
	phys:EnableMotion(ent._fade.unfrozen)
	if (not ent._fade.unfrozen) then
		return;
	end
	phys:Wake();
	phys:SetVelocityInstantaneous(ent._fade.velocity or vector_origin);
	phys:AddAngleVelocity(ent._fade.angvel or vector_origin);
end

local function Toggle(ent)
	if (not IsFading(ent)) then return; end
	if (ent._fade.active) then
		Unfade(ent);
	else
		Fade(ent);
	end
end

function CreateDoorFunctions(ent)
	if (not IsValid(ent)) then return; end
	--[[ Legacy (no more required)
	ent.isFadingDoor     = true;
	ent.fadeActivate     = Fade;
	ent.fadeDeactivate   = Unfade;
	ent.fadeToggleActive = Toggle;
	ent.fadeInputOn      = InputOn;
	ent.fadeInputOff     = InputOff;]]
	-- Unlegacy
	ent._fade = {};
	ent:CallOnRemove("Fading Doors", onRemove);
	local pfuncs = {};
	ent._fade.pfuncs = pfuncs;
	do
		local TriggerInput = ent.TriggerInput;
		pfuncs.TriggerInput = TriggerInput or false; -- For cleanup
		function ent.TriggerInput(...)
			if (not wireTriggerInput(...) and TriggerInput) then
				TriggerInput(...)
			end
		end
	end
	do
		local PreEntityCopy = ent.PreEntityCopy;
		pfuncs.PreEntityCopy = PreEntityCopy or false;
		function ent.PreEntityCopy(ent)
			wirePreEntityCopy(ent);
			if (PreEntityCopy) then
				PreEntityCopy(ent);
			end
		end
	end
	do
		local PostEntityPaste = ent.PostEntityPaste;
		pfuncs.PostEntityPaste = PostEntityPaste or false;
		function ent.PostEntityPaste(...)
			if (PostEntityPaste) then
				PostEntityPaste(...);
			end
		end
	end
end

function RemoveDoor(ent)
	print("RemoveDoor", ent, IsValid(ent), IsFading(ent));
	if (not IsFading(ent)) then return; end
	onRemove(ent);
	Unfade(ent);
	ent.isFadingDoor     = nil;
	ent.fadeActivate     = nil;
	ent.fadeDeactivate   = nil;
	ent.fadeToggleActive = nil;
	ent.fadeInputOn      = nil;
	ent.fadeInputOff     = nil;
	if (ent._fade.pfuncs) then
		for key, func in pairs(ent._fade.pfuncs) do
			if (not func) then
				func = nil;
			end
			ent[key] = func;
		end
	end
	ent._fade = nil;
	duplicator.ClearEntityModifier(ent, "Fading Door");
	return true;
end

function SetupDoor(owner, ent, data)
	if (not (IsValid(owner) and IsValid(ent))) then return end
	if (IsFading(ent)) then
		Unfade(ent);
		onRemove(ent); -- Kill the old numpad func
	else
		CreateDoorFunctions(ent);
	end
	ent._fade.toggle   = data.toggle;
	if (data.reversed) then
		Fade(ent);
	end
	duplicator.StoreEntityModifier(ent, "Fading Door", data);
end

rp.fadingdoor = {}
local fadingDoors = {}

function rp.fadingdoor.AddProp(ply, prop)
	local steamID64 = ply:SteamID64()
	if(not fadingDoors[steamID64]) then fadingDoors[steamID64] = {} end
	SetupDoor(ply, prop, {
		key = nil,
		toggle = false,
		reversed = false
	})
	print(prop)
	table.insert(fadingDoors[steamID64], prop)
end

function rp.fadingdoor.RemoveProp(ply, prop)
	table.RemoveByValue(fadingDoors[ply:SteamID64()], prop)
end

function rp.fadingdoor.HasProp(ply, prop)
	table.HasValue(fadingDoors[ply:SteamID64()] or {}, prop)
end

function rp.fadingdoor.GetProps(ply)
	return fadingDoors[ply:SteamID64()] or {}
end

function rp.fadingdoor.ClearProps(ply)
	fadingDoors[ply:SteamID64()] = {}
end

----------------------
-- Entity functions --
----------------------
function ENT:Initialize()
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )
end

function ENT:FadeProps()
    if(self.Props == {}) then return end
	for k, v in pairs(self.Props) do
		Fade(v)
	end
	self:SetStatus(1)
end

function ENT:UnFadeProps()
    if(self.Props == {}) then return end
	for k, v in pairs(self.Props) do
		Unfade(v)
	end
	self:SetStatus(0)
end

function ENT:AddProp(prop)
	table.insert(self.Props, prop)
end