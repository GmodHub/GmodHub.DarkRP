ba.ranks 			= ba.ranks 			or {}
ba.ranks.Stored 	= ba.ranks.Stored 	or {}

local RANK 		= {}
RANK.__index 	= RANK

function ba.ranks.Create(name, id)
	local r = {
		Name 		= name:lower():gsub(' ', ''),
		NiceName	= name,
		ID 			= id,
		Immunity 	= 0,
		Flags 		= {},
		Global 		= false,
		VIP 		= false,
		Admin 		= false,
		SA 			= false,
		GA 			= false,
		Root 		= false
	}
	setmetatable(r, RANK)
	ba.ranks.Stored[r.ID] 		= r --ehhhhh, oh well..
	ba.ranks.Stored[r.Name] 	= r
	ba.ranks.Stored[r.NiceName] = r
	return r
end

function ba.ranks.GetTable()
	return ba.ranks.Stored
end

function ba.ranks.Get(rank)
	return ba.ranks.Stored[isstring(rank) and rank:lower() or rank]
end

function ba.ranks.CanTarget(pl, targ)
	if (not isplayer(pl)) or pl:IsRoot() or ((pl:IsSuperAdmin()) and (not targ:IsRoot())) then return true end
	return (pl:GetImmunity() > targ:GetImmunity())
end

-- Set
function RANK:SetAuthRequired(bool)
	self.RequiresAuth = bool
	return self
end

function RANK:SetImmunity(amt)
	self.Immunity = amt
	return self
end

function RANK:SetGlobal(bool)
	self.Global = bool
	return self
end

function RANK:SetFlags(f)
	for i = 1, #f do
		self.Flags[f[i]] = true
		self.Flags[i] = f[i]
	end
	return self
end

function RANK:SetVIP(bool)
	self.VIP = bool
	return self
end

function RANK:SetAdmin(bool)
	if (bool == true) then
		self:SetVIP(bool)
		self:SetAuthRequired(bool)
	end
	self.Admin = bool
	return self
end

function RANK:SetDA(bool)
	if (bool == true) then
		self:SetAdmin(bool)
	end
	self.DA = bool
	return self
end

function RANK:SetSA(bool)
	if (bool == true) then
		self:SetDA(bool)
	end
	self.SA = bool
	return self
end

function RANK:SetGA(bool)
	if (bool == true) then
		self:SetSA(bool)
	end
	self.GA = bool
	return self
end

function RANK:SetRoot(bool)
	if (bool == true) then
		self:SetGlobal(bool)
		self:SetGA(bool)
	end
	self.Root = bool
	return self
end

-- Get
function RANK:GetAuthRequired()
	return (self.RequiresAuth == true)
end

function RANK:GetID()
	return self.ID
end

function RANK:GetName()
	return self.Name
end

function RANK:GetNiceName()
	return self.NiceName
end

function RANK:GetImmunity()
	return self.Immunity
end

function RANK:IsGlobal()
	return self.Global
end

function RANK:HasFlag(flag)
	return (self.Flags[flag:lower()] or self:IsRoot())
end

function RANK:CanTarget(rank)
	return self:IsRoot() or (self:GetImmunity() > rank:GetImmunity())
end

function RANK:IsVIP()
	return self.VIP
end

function RANK:IsAdmin()
	return self.Admin
end

function RANK:IsDA()
	return self.DA
end

function RANK:IsSA()
	return self.SA
end

function RANK:IsGA()
	return self.GA
end

function RANK:IsRoot()
	return self.Root
end

-- Player
function PLAYER:GetRankTable()
	return ba.ranks.Get(self:GetNetVar('UserGroup') or 1)
end

function PLAYER:GetRank()
	return self:GetRankTable():GetName()
end
PLAYER.GetUserGroup = PLAYER.GetRank

function PLAYER:GetImmunity()
	return self:GetRankTable():GetImmunity()
end

function PLAYER:HasFlag(flag)
	if (hook.Call('PlayerAdminCheck', GAMEMODE, self) == false) then return false end

	return self:GetRankTable():HasFlag(flag)
end
PLAYER.HasAccess = PLAYER.HasFlag

function PLAYER:IsRank(group)
	return (self:GetRank() == group)
end
PLAYER.IsUserGroup = PLAYER.IsRank

function PLAYER:IsVIP()
	return ((hook.Call('PlayerVIPCheck', GAMEMODE, self) == true) or self:GetRankTable():IsVIP())
end

function PLAYER:IsAdmin(forceAuth)
	if (hook.Call('PlayerAdminCheck', GAMEMODE, self) == false) then return false end

	if (SERVER and forceAuth and !ba.IsAuthed(self)) then return false end

	return self:GetRankTable():IsAdmin()
end

function PLAYER:IsDA(forceAuth)
	if (hook.Call('PlayerAdminCheck', GAMEMODE, self) == false) then return false end

	if (SERVER and forceAuth and !ba.IsAuthed(self)) then return false end

	return self:GetRankTable():IsDA()
end

function PLAYER:IsSA(forceAuth)
	if (hook.Call('PlayerAdminCheck', GAMEMODE, self) == false) then return false end

	if (SERVER and forceAuth and !ba.IsAuthed(self)) then return false end

	return self:GetRankTable():IsSA()
end

function PLAYER:IsGA(forceAuth)
	if (hook.Call('PlayerAdminCheck', GAMEMODE, self) == false) then return false end

	if (SERVER and forceAuth and !ba.IsAuthed(self)) then return false end

	return self:GetRankTable():IsGA()
end
PLAYER.IsSuperAdmin = PLAYER.IsGA

function PLAYER:IsRoot(forceAuth)
	return (SERVER and forceAuth) and (ba.IsAuthed(self) and self:GetRankTable():IsRoot()) or self:GetRankTable():IsRoot()
end

nw.Register 'UserGroup'
	:Write(net.WriteUInt, 4)
	:Read(net.ReadUInt, 4)
	:SetPlayer()
