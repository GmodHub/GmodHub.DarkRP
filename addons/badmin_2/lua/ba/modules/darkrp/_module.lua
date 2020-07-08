ba.Module 'DarkRP'
	:Author 'aStonedPenguin'
	:CustomCheck(function()
		return (rp ~= nil)
	end)
	:Include {
		'commands_sh.lua',

		'misc_sv.lua',
		'misc_sh.lua',

		'sod/sod_sv.lua',
		'sod/sod_sh.lua',

		'loghooks_sh.lua',

		'bans/bans_sh.lua',
		'bans/bans_sv.lua',

		'jails/jails_sh.lua',
		'jails/jails_sv.lua',
	}
