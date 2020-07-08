require 'nw'
require 'pon'
require 'term'
require 'cmd'
require 'netstream'

if (CLIENT) then
	require 'texture'
	require 'cvar'
else
	require 'mysql'
	require 'redis'
	require 'hash'
end

-- UI
if (SERVER) then
	resource.AddDir 'sound/ui/'
end

ui = ui or {}
dash.IncludeSH 'ui/colors.lua'
dash.IncludeCL 'ui/util.lua'
dash.IncludeCL 'ui/theme.lua'

local files, _ = file.Find('ui/controls/*.lua', 'LUA')
for k, v in ipairs(files) do
	dash.IncludeCL('ui/controls/' .. v)
end

-- Badmin
ba = ba or {}
PLAYER = FindMetaTable 'Player'

ba.include = function(f)
	if string.find(f, '_sv.lua') then
		dash.IncludeSV(f)
	elseif string.find(f, '_cl.lua') then
		dash.IncludeCL(f)
	else
		dash.IncludeSH(f)
	end
end
ba.include_dir = function(dir)
	local fol = 'ba/' .. dir .. '/'
	local files, folders = file.Find(fol .. '*', 'LUA')
	for _, f in ipairs(files) do
		ba.include(fol .. f)
	end
	for _, f in ipairs(folders) do
		ba.include_dir(dir .. '/' .. f)
	end
end

function ba.print(...)
	return MsgC(Color(0,255,0), '[bAdmin] ', Color(255,255,255), ... .. '\n')
end

dash.IncludeSH 'ba/core/core_init.lua'

local msg = {
	'\n',
	[[   __  _                _           _        __   ]],
	[[  / / | |      /\      | |         (_)       \ \  ]],
	[[ | |  | |__   /  \   __| |_ __ ___  _ _ __    | | ]],
	[[/ /   | '_ \ / /\ \ / _` | '_ ` _ \| | '_ \    \ \]],
	[[\ \   | |_) / ____ \ (_| | | | | | | | | | |   / /]],
	[[ | |  |_.__/_/    \_\__,_|_| |_| |_|_|_| |_|  | | ]],
	[[  \_\                                        /_/  ]],
	'\n',
}

for _, l in ipairs(msg) do
	MsgC(color_white, l .. '\n')
end
hook.Call('bAdmin_Loaded', ba)
