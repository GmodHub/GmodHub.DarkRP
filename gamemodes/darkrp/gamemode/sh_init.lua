rp 		= rp or {}
rp.cfg 	= rp.cfg or {}
rp.inv 	= rp.inv or {Data = {}, Wl = {}}

function table.IsEmpty( tab )
	return next( tab ) == nil
end

PLAYER	= FindMetaTable 'Player'
ENTITY	= FindMetaTable 'Entity'
VECTOR	= FindMetaTable 'Vector'


if (SERVER) then
	require 'mysql'
else
	require 'texture'

	texture.SetProxy 'https://gmod-api.superiorservers.co/api/textureproxy/?url=%s&width=%i&height=%i&format=%s'
end

require 'cvar'
require 'hash'
require 'nw'
require 'pon'
require 'term'
require 'cmd'
require 'chat'
require 'medialib.core'
require 'medialib.service.volume3d'

medialib.SOUNDCLOUD_API_KEY = '698c75f053343e3739e5c14820e3fe67'

rp.include = function(f)
	if string.find(f, '_sv.lua') then
		return dash.IncludeSV(f)
	elseif string.find(f, '_cl.lua') then
		return dash.IncludeCL(f)
	else
		return dash.IncludeSH(f)
	end
end
rp.include_dir = function(dir, recursive)
	local fol = dir .. '/'
	local files, folders = file.Find(fol .. '*', 'LUA')
	for _, f in ipairs(files) do
		rp.include(fol .. f)
	end
	if (recursive ~= false) then
		for _, f in ipairs(folders) do
			rp.include_dir(dir .. '/' .. f)
		end
	end
end


GM.Author 	= 'gmodHub Team'
GM.Website 	= 'gmodHub.com'

local loadmsg = {
	[[  _____ _    _ _____    _____  _____  ]],
	[[ / ____| |  | |  __ \  |  __ \|  __ \ ]],
	[[| (___ | |  | | |__) | | |__) | |__) |]],
	[[ \___ \| |  | |  ___/  |  _  /|  ___/ ]],
	[[ ____) | |__| | |      | \ \  | |     ]],
	[[|_____/ \____/|_|      |_|  \_\_|     ]],
	[[--------------------------------------------------------------]],
	[[Credits:]],
	[[--------------------------------------------------------------]],
	[[aStonedPenguin:		A lot of shit]],
	[[KingofBeast:		A lot of shit]],
	[[code_gs: 		SWEPs, Player Models]],
	[[Stiffy360: 		Map]],
	[[Brudr: 			Textures]],
	[[Dustpup: 		Models]],
	[[wyozi:			medialib]],
	[[Original DarkRP Devs: 	Motivation to cure cancer]],
	[[--------------------------------------------------------------]],
}


function rp.Init(name)
	GM.Name = name

	dash.IncludeSH(GM.FolderName .. '/gamemode/cfg/info.lua')

	dash.IncludeSV 'darkrp/gamemode/db.lua'

	dash.IncludeSH 'darkrp/gamemode/cfg/cfg.lua'
	dash.IncludeSH 'darkrp/gamemode/cfg/colors.lua'
	dash.IncludeCL 'darkrp/gamemode/cfg/renderoffsets.lua'

	rp.include_dir 'darkrp/gamemode/util'

	rp.include_dir('darkrp/gamemode/core', false)
	rp.include_dir 'darkrp/gamemode/core/sandbox'
	rp.include_dir('darkrp/gamemode/core/chat', false)
	rp.include_dir 'darkrp/gamemode/core/player'
	rp.include_dir 'darkrp/gamemode/core/credits'
	rp.include_dir('darkrp/gamemode/core/orgs', false)
	rp.include_dir 'darkrp/gamemode/core/ui'
	rp.include_dir('darkrp/gamemode/core/prop_protect', false)
	rp.include_dir 'darkrp/gamemode/core/cosmetics'
	rp.include_dir('darkrp/gamemode/core/makethings', false)
	rp.include_dir 'darkrp/gamemode/core/events'
	rp.include_dir 'darkrp/gamemode/core/cop_stats'
	rp.include_dir('darkrp/gamemode/core/commands', false)
	rp.include_dir('darkrp/gamemode/core/tabletop', false)
	rp.include_dir('darkrp/gamemode/core/smallscripts', false)
	rp.include_dir('darkrp/gamemode/core/hud', false)

	dash.IncludeSH(GM.FolderName .. '/gamemode/cfg/jobs.lua')
	dash.IncludeSH('darkrp/gamemode/cfg/doors/'.. game.GetMap() .. '.lua')
	dash.IncludeSH 'darkrp/gamemode/cfg/entities.lua'

	rp.include_dir('darkrp/gamemode/core/doors', false)

	dash.IncludeSH 'darkrp/gamemode/cfg/drugs.lua'
	dash.IncludeSH 'darkrp/gamemode/cfg/cosmetics.lua'
	dash.IncludeSV 'darkrp/gamemode/cfg/events.lua'
	dash.IncludeSH 'darkrp/gamemode/cfg/skills.lua'
	dash.IncludeSH 'darkrp/gamemode/cfg/upgrades.lua'
	dash.IncludeSH 'darkrp/gamemode/cfg/terms.lua'
	dash.IncludeSV 'darkrp/gamemode/cfg/limits.lua'
	dash.IncludeSV 'darkrp/gamemode/cfg/struggle.lua'

	for _, v in ipairs(loadmsg) do
		MsgC(rp.col.White, v .. '\n')
	end
end

rp.Init 'darkrp'
