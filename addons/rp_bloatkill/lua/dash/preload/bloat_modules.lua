
for k, v in pairs{
	ai_schedule = true,
	ai_task 	= true,
	widget 		= true,
	saverestore	= true,
	menubar		= true,
	notification = true,
	properties = true
} do

	dash.BadModules[k] = v
end

local function noop() end

properties = {
	Add = noop,
	List = {}
}

saverestore = {
	AddSaveHook 	= noop,
	AddRestoreHook 	= noop,
}