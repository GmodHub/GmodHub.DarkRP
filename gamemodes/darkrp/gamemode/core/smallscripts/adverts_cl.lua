local curStep = 0
timer.Create('rp.Adverts', rp.cfg.AnnouncementDelay, 0, function()
	curStep = curStep + 1
	if (not rp.cfg.Announcements[curStep]) then
		curStep = 1
	end

	local col = rp.cfg.Announcements[curStep][1]
	local msg = rp.cfg.Announcements[curStep][2]

	msg = msg:gsub("{(.+)}", function(s)
		return info[s] or s
	end)

	chat.AddText(col, msg)
end)
