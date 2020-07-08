nw.Register 'EventsRunning'
	:Write(function(v)
		net.WriteUInt(table.Count(v), 8)
		for k, v in pairs(v) do
			net.WriteString(k)
		end
	end)
	:Read(function()
		local ret = {}
		for i = 1, net.ReadUInt(8) do
			ret[net.ReadString()] = true
		end
		return ret
	end)
	:SetGlobal()

function rp.EventIsRunning(name)
	return ((nw.GetGlobal('EventsRunning') or {})[name] == true)
end
