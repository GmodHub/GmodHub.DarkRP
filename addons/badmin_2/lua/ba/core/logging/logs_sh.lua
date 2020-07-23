ba.logs = ba.logs or {
	Stored 			= {},
	Maping 			= {},
	Data 			= {},
	RecallData		= {},
	PlayerEvents 	= {},
	MaxEntries 		= 500
}

ba.log_mt			= ba.log_mt or {}
ba.log_mt.__index 	= ba.log_mt

local log_mt 		= ba.log_mt
local id_cache 		= {}

if (not file.IsDir('badmin/logs', 'data')) then
	file.CreateDir('badmin/logs')
end

local count = 0
function ba.logs.Create(name)
	local id
	if ba.logs.Stored[name] then
		id = ba.logs.Stored[name].ID
	else
		id = count
		count = count + 1
	end

	local l = setmetatable({
		Name  = name,
		ID 	  = count
	}, ba.log_mt)

	ba.logs.Stored[l.Name] 	= l
	ba.logs.Maping[l.ID] 	= l.Name
	ba.logs.Data[l.Name]	= {}
	return l
end

ba.logs.Terms 		= ba.logs.Terms 		or {}
ba.logs.TermsMap 	= ba.logs.TermsMap 		or {}
ba.logs.TermsStore 	= ba.logs.TermsStore 	or {}

local c = 0
hook.Add('BadminPlguinsLoaded', 'ba.logs.terms.BadminPlguinsLoaded', function()
	for k, v in SortedPairsByMemberValue(ba.logs.TermsStore, 'Name', false) do
		ba.logs.TermsMap[v.Name] = c
		ba.logs.Terms[c] = {Message = v.Message, Copy = v.Copy}
		c = c + 1
	end
end)

function ba.logs.AddTerm(name, message, copy)
	local k = ba.logs.TermsMap[name] or (#ba.logs.TermsStore + 1)
	ba.logs.TermsStore[k] = {
		Name = name,
		Message = message,
		Copy = copy
	}
end

function ba.logs.Term(name)
	return ba.logs.TermsMap[name]
end

function ba.logs.GetTerm(id)
	return ba.logs.Terms[id]
end


function ba.logs.GetTable()
	return ba.logs.Stored
end

function ba.logs.Get(name)
	return ba.logs.Stored[name]
end

function ba.logs.GetByID(id)
	return ba.logs.Get(ba.logs.Maping[id])
end

function ba.logs.Encode(data)
	return util.Compress(pon.encode(data))
end

function ba.logs.Decode(data)
	return pon.decode(util.Decompress(data))
end

function ba.logs.GetSaves()
	local files = file.Find('badmin/logs/*.dat', 'DATA', 'datedesc')
	for k, v in ipairs(files) do
		files[k] = {
			Name = string.StripExtension(v),
			Date = os.date('[ %d/%m/%Y - %I:%M:%S] ', file.Time('badmin/logs/' .. v, 'DATA'))
		}
	end
	return files
end

function ba.logs.OpenSave(name)
	return ba.logs.Decode(file.Read('badmin/logs/' .. name .. '.dat', 'DATA'))
end

function ba.logs.DeleteSave(name)
	file.Delete('badmin/logs/' .. name .. '.dat')
end

function ba.logs.SaveExists(name)
	return file.Exists('badmin/logs/' .. string.Trim(name) .. '.dat', 'DATA')
end

function ba.logs.SaveLog(name, tbl)
	file.Write('badmin/logs/' .. string.Trim(name) .. '.dat', ba.logs.Encode(tbl))
end

function log_mt:SetColor(color)
	self.Color = color
	return self
end

function log_mt:Hook(name, callback)
	if (SERVER) then
		hook.Add(name, 'ba.logs.' .. self.Name .. name, function(...)
			callback(self, ...)
		end)
	end
	return self
end

function log_mt:GetName()
	return self.Name
end

function log_mt:GetColor()
	return self.Color
end

function log_mt:GetID()
	return self.ID
end


-- Commands
ba.AddCommand('Logs')
:RunOnClient(function()
	ui.Create 'ba_logs_menu'
end)
:SetFlag 'M'
:SetHelp 'Shows you the logs'

ba.AddCommand('PlayerEvents')
:RunOnClient(function(targ)
	ui.Create('ba_logs_menu', function(self)
		self:SetPlayerEventMode(ba.InfoTo32(targ))
	end)
end)
:AddParam(cmd.PLAYER_STEAMID32)
:SetFlag 'M'
:SetHelp 'Shows you the logs for a specified player'
:AddAlias 'pe'
:SetIgnoreImmunity(true)

ba.AddCommand 'AltSearch'
:RunOnClient(function(targ)
	ba.ui.OpenAuthLink('/admin/altsearch/' .. ba.InfoTo32(targ))
end)
:AddParam(cmd.PLAYER_STEAMID32)
:SetFlag 'S'
:SetHelp 'List\'s a players alt accounts'


-- Defualt logs
local term = ba.logs.Term

ba.logs.AddTerm('Connect', '#(#) connected', {
	'Name',
	'SteamID'
})

ba.logs.AddTerm('Disconnect', '#(#) disconnected', {
	'Name',
	'SteamID'
})

ba.logs.Create 'Подключения'
	:Hook('PlayerInitialSpawn', function(self, pl)
		self:PlayerLog(pl, term('Connect'), pl:Name(), pl:SteamID())
	end)
	:Hook('PlayerDisconnected', function(self, pl)
		self:PlayerLog(pl, term('Disconnect'), pl:Name(), pl:SteamID())
	end)


local concatargs
local function stingify(v)
	if istable(v) then
		return concatargs(v)
	end
	if isplayer(v) and IsValid(v) then
		return v:Name()
	end
	return tostring(v)
end

function concatargs(args)
	local str
	for k, v in pairs(args) do
		str = ((str or '') .. ' ').. stingify(v)
	end
	return str or ''
end

ba.logs.AddTerm('RunCommand', '#(#) ran # #"', {
	'Name',
	'SteamID',
	'Command'
})

ba.logs.Create 'Команды'
	:Hook('cmd.OnCommandRun', function(self, pl, cmdobj, args)
		if isplayer(pl) and (cmdobj:GetConCommand() == 'ba') then
			args = cmdobj:GetPreventSendArgs() and "" or concatargs(args)
			self:PlayerLog(pl, term('RunCommand'), pl:Name(), pl:SteamID(), cmdobj:GetName(), args)
		end
	end)

ba.logs.AddTerm('Chat', '#(#) say "#"', {
	'Name',
	'SteamID'
})

ba.logs.Create 'Чат'
	:Hook('PlayerSay', function(self, pl, text)
		if (text ~= '') and (text[1] ~= '!') and (text[1] ~= '/') then
			self:PlayerLog(pl, term('Chat'), pl:Name(), pl:SteamID(), text)
		end
	end)

ba.logs.AddTerm('SitRequest', '#(#) opened a Staff Request: # (# non-AFK staff)', {
	'Name',
	'SteamID'
})

ba.logs.AddTerm('SitRequestTaken', '#(#) has taken #(#)\'s Staff Request', {
	'Admin Name',
	'Admin SteamID',
	'Name',
	'SteamID'
})

ba.logs.AddTerm('SitRequestClosed', '#(#) has closed #(#)\'s Staff Request', {
	'Admin Name',
	'Admin SteamID',
	'Name',
	'SteamID'
})

ba.logs.Create 'Sit'
	:Hook('PlayerSitRequestOpened', function(self, pl, reason)
		local active = 0

		for k, v in ipairs(player.GetAll()) do
			if (v:IsAdmin() and !v:IsAFK()) then
				active = active + 1
			end
		end

		self:PlayerLog(pl, term('SitRequest'), pl:Name(), pl:SteamID(), reason, active)
	end)
	:Hook('PlayerSitRequestTaken', function(self, pl, admin)
		self:PlayerLog({pl, admin}, term('SitRequestTaken'), admin:Name(), admin:SteamID(), pl:Name(), pl:SteamID())
	end)
	:Hook('PlayerSitRequestClosed', function(self, pl, admin)
		self:PlayerLog({pl, admin}, term('SitRequestClosed'), admin:Name(), admin:SteamID(), pl:Name(), pl:SteamID())
	end)
