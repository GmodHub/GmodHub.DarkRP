ba.svar 		= ba.svar 			or {}
ba.svar.stored 	= ba.svar.stored 	or {}
ba.svar.encoded = ba.svar.encoded 	or '{}'
local db 		= ba.data.GetDB()

local function encodeSvars()
	local tbl = {}
	for k, v in pairs(ba.svar.stored) do
		if v.network then
			table.insert(tbl, { Name = k, Value = v.value })
		end
	end
	ba.svar.encoded = tbl
end
hook.Add('bAdmin_Loaded', 'bAdmin_Loaded.svars', encodeSvars)

local function saveSvars()
	for k, v in pairs(ba.svar.stored) do
		if (v.value ~= nil) then
			db:Query('REPLACE INTO ba_server_vars(sv_uid, var, data) VALUES(?,?,?);', ba.data.GetUID(), k, v.value)
		end
	end

	encodeSvars()
	nw.SetGlobal('ba.ServerVars', ba.svar.encoded)
end

local function loadSvars()
	local data = db:QuerySync('SELECT * FROM ba_server_vars WHERE sv_uid = ?;', ba.data.GetUID())

	for k, v in pairs(data) do
		ba.svar.stored[v.var] 		= ba.svar.stored[v.var] or {}
		ba.svar.stored[v.var].value = v.data
	end

	encodeSvars()
	nw.SetGlobal('ba.ServerVars', ba.svar.encoded)
end
hook.Add('InitPostEntity', 'bAdmin.load.svard', loadSvars)

function ba.svar.Create(name, default, network, callback)
	ba.svar.stored[name]			= ba.svar.stored[name]		 	or {}
	ba.svar.stored[name].value 		= ba.svar.stored[name].value 	or default
	ba.svar.stored[name].network 	= ba.svar.stored[name].network 	or network
	ba.svar.stored[name].cback 		= ba.svar.stored[name].cback 	or callback
end

function ba.svar.Set(name, value)
	ba.svar.stored[name]			= ba.svar.stored[name]		 	or {}
	if (ba.svar.stored[name].cback ~= nil) then
		ba.svar.stored[name].cback(name, ba.svar.stored[name].value, value)
	end
	ba.svar.stored[name].value = value
	saveSvars()
end

function ba.svar.Get(name)
	return (ba.svar.stored[name] and ba.svar.stored[name].value or nil)
end
