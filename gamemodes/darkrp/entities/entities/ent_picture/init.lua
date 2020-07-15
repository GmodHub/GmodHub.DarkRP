AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString('rp.OpenImageWindow')

function ENT:Initialize()
	self:SetModel('models/props/cs_office/offcertificatea.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetModelScale(4)
	self:PhysWake()

	self:SetURL('https://gmodhub.com/static/images/favicon.png')

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

rp.AddCommand('setimage', function(pl, url)
	local ent = pl:GetEyeTrace().Entity

	if (not url) or (not IsValidURL(url)) then
		pl:Notify(NOTIFY_ERROR, term.Get('InvalidURL'))
	elseif IsValid(ent) and (ent:GetClass() == "ent_picture") and (not IsValid(ent.ItemOwner) or ent.ItemOwner == pl) then
		ent:SetURL(EscapeURL(url))
	end
end)
:AddParam(cmd.STRING)

rp.AddCommand('setimageavatar', function(pl)
	local ent = pl:GetEyeTrace().Entity

	if IsValid(ent) and (ent:GetClass() == "ent_picture") and (not IsValid(ent.ItemOwner) or ent.ItemOwner == pl) then
		ent:SetURL('https://gmod-api.superiorservers.co/api/avatar/' .. pl:SteamID64() )
	end
end)

rp.AddCommand('setimageorg', function(pl)
	local ent = pl:GetEyeTrace().Entity

	if IsValid(ent) and (ent:GetClass() == "ent_picture") and (not IsValid(ent.ItemOwner) or ent.ItemOwner == pl) and pl:GetOrg() then
		ent:SetURL('ORG:' .. pl:GetOrg())
	end
end)
