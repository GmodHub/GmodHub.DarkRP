function ba.AddCommand(name, callback)
	return cmd(name, callback)
		:SetConCommand 'ba'
end

local COMMAND = FindMetaTable 'Command'

-- Set
function COMMAND:SetAuthRequired(bool)
	self.RequiresAuth = bool
	return self
end

function COMMAND:SetFlag(flag)
	if (self.RequiresAuth == nil) then
		self:SetAuthRequired(true)
	end
	self.Flag = flag
	return self
end

function COMMAND:SetHelp(help)
	self.Help = help
	return self
end

function COMMAND:SetIgnoreImmunity(bool)
	self.IgnoreImmunity = bool
	return self
end

function COMMAND:SetPreventSendArgs(bool)
	self.PreventSendArgs = bool
	return self
end

-- Get
function COMMAND:GetFlag()
	return self.Flag
end

function COMMAND:GetHelp()
	return self.Help
end

function COMMAND:GetAuthRequired()
	return (self.RequiresAuth == true)
end

function COMMAND:GetIgnoreImmunity()
	return self.IgnoreImmunity or false
end

function COMMAND:GetPreventSendArgs()
	return self.PreventSendArgs or false
end

-- parsing
cmd.ERROR_INVALID_GROUP = 100
cmd.ERROR_GROUP_IMMUNITY = 101
cmd.AddParam('RANK', 'Rank', function(caller, cmdobj, arg, args, step)
	local rank = ba.ranks.Get(arg:lower())
	if (not rank) then
		return false, cmd.ERROR_INVALID_GROUP, {arg}
	elseif (caller:IsPlayer() and not caller:GetRankTable():CanTarget(rank)) then -- insufficient immunity
		return false, cmd.ERROR_GROUP_IMMUNITY, {arg}
	end
	return true, arg
end, function(cmdobj, arg, args, step)
	local ret = {}
	for k, v in ipairs(ba.ranks.GetTable()) do
		if (arg ~= nil) and string.find(v:GetName():lower(), arg:lower()) then
			ret[#ret + 1] = v:GetName()
		elseif (arg == nil) then
			ret[#ret + 1] = v:GetName()
		end
	end
	return (#ret == 0) and {'<Rank>'} or ret
end)
