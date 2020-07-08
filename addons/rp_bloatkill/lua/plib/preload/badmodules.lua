plib.BadModules = {
	ai_schedule = true,
	ai_task 	= true,
	widget 		= true,
	construct 	= true,
	widget 		= true,
	saverestore	= true,
	menubar		= true,
	halo 		= true, 
	notification = true
}

local function noop() end

saverestore = {
	AddSaveHook 	= noop,
	AddRestoreHook 	= noop,
}

halo = {
	Add = noop,
}