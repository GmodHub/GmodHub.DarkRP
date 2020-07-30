rp.Events = rp.Events or {}
rp.EventsRunning = rp.EventsRunning or {}

function rp.RegisterEvent(name, tab)
	name = name:lower()

	local OnStart = tab.OnStart or function() end
	tab.OnStart = function(...)
		for k, v in pairs(tab.Hooks or {}) do
			hook(k, 'event.' .. name, v)
		end

		local events = nw.GetGlobal('EventsRunning') or {}
		events[tab.NiceName] = true
		nw.SetGlobal('EventsRunning', events)

		OnStart(...)
	end

	local OnEnd = tab.OnEnd or function() end
	tab.OnEnd = function(...)
		for k, v in pairs(tab.Hooks or {}) do
			hook.Remove(k, 'event.' .. name)
		end

		local events = nw.GetGlobal('EventsRunning') or {}
		events[tab.NiceName] = nil
		nw.SetGlobal('EventsRunning', events)

		rp.EventsRunning[tab.NiceName] = nil
		OnEnd(...)
	end

	if (not tab.Think) then
		tab.Think = function() end
	end

	rp.Events[name] = tab
end

local count = 0
function rp.StartEvent(name, seconds)
	local event = rp.Events[name]
	rp.EventsRunning[event.NiceName] = event
	rp.EventsRunning[event.NiceName].EndTime = CurTime() + seconds
	event.OnStart()
	count = table.Count(rp.EventsRunning)
end

timer.Create('rp.EventsThink', 1, 0, function()
	rp.HostName = rp.HostName or GetHostName()
	local name = rp.HostName
	local c = 0

	for k, v in pairs(rp.EventsRunning) do
		c = c + 1
		v.Think()
		if (v.EndTime <= CurTime()) then
			rp.NotifyAll(NOTIFY_ERROR, term.Get('EventEnded'), v.NiceName)
			v.OnEnd()
			count = table.Count(rp.EventsRunning)
		end
		name = name .. ((c == 1) and ' | ' or ', ') ..  v.NiceName

	end
	RunConsoleCommand('hostname', name .. ((count >= 1) and '' or ''))
end)
