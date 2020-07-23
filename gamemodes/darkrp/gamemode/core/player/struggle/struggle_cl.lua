rp.struggle = rp.struggle or {
	Active = {}
}

net('rp.struggle.New', function(len)
	local id = net.ReadUInt(2)
	local name = net.ReadString()
	local caption = net.ReadString()
	local max = net.ReadUInt(9)

	rp.struggle.Active[id] = {
		name = name,
		caption = caption,
		max = max,
		progress = 0,
		calcprog = 0
	}
end)

net('rp.struggle.End', function(len)
	local id = net.ReadUInt(2)

	rp.struggle.Active[id] = nil
end)

net('rp.struggle.Progress', function(len)
	local id = net.ReadUInt(2)
	local prog = net.ReadUInt(9)

	if (rp.struggle.Active[id]) then
		rp.struggle.Active[id].progress = prog
	end
end)

hook('HUDPaint', 'rp.struggle.HUDPaint', function()
	for k, v in pairs(rp.struggle.Active) do
		v.calcprog = Lerp(0.05, v.calcprog, math.min(v.progress / v.max, 1))
		rp.ui.DrawCenteredProgress(v.caption, v.calcprog)
	end
end)
