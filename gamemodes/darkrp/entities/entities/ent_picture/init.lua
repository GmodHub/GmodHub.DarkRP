AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString('rp.OpenImageWindow')

function ENT:Initialize()
	self:SetModel('models/props/cs_office/offinspg.mdl')
	self:SetMaterial('models/debug/debugwhite')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	self:PhysWake()

	self:SetURL('http://portal.superiorservers.co/static/images/favicon.png')

	timer.Simple(0, function() self:CPPISetOwner(self.ItemOwner) end)
end

function ENT:Use(pl)
	if (not IsValid(self.ItemOwner) or (self.ItemOwner == pl)) and ((not pl.LastImageUSe) or (pl.LastImageUSe <= CurTime())) and (self:GetPos():Distance(pl:GetPos()) < 110) then
		net.Start('rp.OpenImageWindow')
		net.Send(pl)
		pl.LastImageUSe = CurTime() + 2
	end
end

local all_patterns = {
	"^https?://.*%.jpg",
	"^https?://.*%.png",
}

local function IsValidURL(url)
	for _, pattern in ipairs(all_patterns) do
		if string.match(url, pattern) then
			return true
		end
	end
end

local bad_chars = {
	'"',
	"'",
	']',
	'[',
	'\\'
}

local function EscapeURL(url)
	for k, v in ipairs(bad_chars) do
		url = string.Replace(url, v, '')
	end
	return url
end

rp.AddCommand('setimage', function(pl, text, args)
	local ent = pl:GetEyeTrace().Entity

	if (not args[1]) or (not IsValidURL(args[1])) then
		pl:Notify(NOTIFY_ERROR, rp.Term('InvalidURL'))
	elseif IsValid(ent) and (not IsValid(ent.ItemOwner) or ent.ItemOwner == pl) then
		ent:SetURL(EscapeURL(args[1]))
	end
end)

rp.AddCommand('setimageavatar', function(pl, text, args)
	local ent = pl:GetEyeTrace().Entity

	if IsValid(ent) and (not IsValid(ent.ItemOwner) or ent.ItemOwner == pl) then
		ent:SetURL('http://portal.superiorservers.co/cache/avatars/' .. pl:SteamID64() .. '.jpg')
	end
end)

rp.AddCommand('setimageorg', function(pl, text, args)
	local ent = pl:GetEyeTrace().Entity

	if IsValid(ent) and (not IsValid(ent.ItemOwner) or ent.ItemOwner == pl) and pl:GetOrg() then
		ent:SetURL('ORG:' .. pl:GetOrg())
	end
end)