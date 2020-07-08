include 'sh_init.lua'

surface.CreateFont('3d2d',{font = 'Tahoma',size = 130,weight = 1700,shadow = true, antialias = true, extended = true})
surface.CreateFont('Trebuchet22', {size = 22,weight = 500,antialias = true,shadow = false,font = 'Trebuchet MS', extended = true})
surface.CreateFont('PrinterSmall', {
	font = 'roboto',
	size = 50,
	weight = 500,
	extended = true
})

timer.Create('CleanBodys', 60, 0, function()
	RunConsoleCommand('r_cleardecals')
	for k, v in ipairs(ents.FindByClass('class C_ClientRagdoll')) do
		if (v.NoAutoCleanup) then continue end

		v:Remove()
	end
	for k, v in ipairs(ents.FindByClass('class C_PhysPropClientside')) do
		v:Remove()
	end
end)

RunConsoleCommand('cl_drawmonitors', '0')

hook('InitPostEntity', function()
	local lp = LocalPlayer()
	lp:ConCommand('stopsound')
	lp:ConCommand('cl_updaterate 32')
	lp:ConCommand('cl_cmdrate 32')
	lp:ConCommand('cl_interp_ratio 2')
	lp:ConCommand('cl_interp 0')
	lp:ConCommand('cl_tree_sway_dir .5 .5')
end)


--cl_cmdrate 128; cl_updaterate 128; cl_interp 0; cl_interp_ratio 2
--cl_cmdrate 128; cl_updaterate 128; cl_interp 0; cl_interp_ratio 1
/*
//hook.Add('HUDPaint',)

hook.Add('HUDPaint', 'test', function()
	// hooks = hook.GetTable()['HUDPaint']

	//for k, v in pairs(hooks) do
	//	hook.Remove(k, v)
	//end

	draw.Box(0, 0, ScrW(), ScrH(), Color(0,0,0))

	render.CapturePixels()

	for x = 1, ScrW() do
		for y = 1, ScrH() do
			local r, g, b = render.ReadPixel(x, y)
			if (r ~= 0) or (g ~= 0) or (b ~= 0) then
				print(x, y)
				break
			end
		end
	end

	//for k, v in pairs(hooks) do
	//	hook.Add(k, v)
	//end
	hook.Remove('HUDPaint', 'test')
end)

function system.GetInfo()
	local ret = {}
	local files, _ = file.Find('*.mdmp', 'BASE_PATH')

	local log
	for k, v in ipairs(files) do
		local c = file.Read(v, 'BASE_PATH')
        if c:match('^MDMP') then
        	log = c
        	break
        end
	end

	if (not log) then return end

	log = string.Explode('\n', log)

	for k, v in ipairs(log) do
		print(v)
		if k>500 then break end

		if v:match('driver: Driver Name:  ') then
			ret['GPU'] = v:gsub('driver: Driver Name:  ','')
		end

		if v:match('totalPhysical Mb%(') then
			ret['Ram'] = v:gsub('totalPhysical Mb%(',''):gsub('%)','')
		end

		if v:match('Users\\') and (not v:match('awesomium')) then
			ret['Username'] = v:match('Users\\.+\\'):gsub('Users\\',''):gsub('\\.*$','')
		end

		--if v:match('VendorId / DeviceId:  ') then
		--	ret['gfx vid/did'] = v:gsub('VendorId / DeviceId:  ','') -- idk?
		--end

		if v:match('^OS:  ') then
			ret['OS'] = v:gsub('OS:  ','')
		end

		if v:match('Driver Version: ') then
			ret['GPUDriver'] = v:gsub('Driver Version: ','')
		end

		if v:match('Vid:  ') then
			ret['Resolution'] = v:gsub('Vid:  ','')
		end

		if v:match('Game: ') then
			ret['InstallDir'] = v:gsub('Game: ',''):gsub("[\\/]+", '/')
		end
	end

	return ret
end
