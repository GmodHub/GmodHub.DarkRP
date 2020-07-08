if IsValid(rp.Scoreboard) then rp.Scoreboard:Remove() end

require 'geoip'

local function geoipcback(dat)
	net.Start 'rp.ScoreboardStats'
		net.WriteString((dat and dat.countryCode) or 'US')
		local o
		if system.IsWindows() then
			o = 1
		elseif system.IsOSX() then
			o = 2
		else
			o = 3
		end
		net.WriteUInt(o, 2)
	net.SendToServer()
end

net('rp.ScoreboardStats', function()
	geoip.Get(net.ReadString(), geoipcback, geoipcback)
end)

function GM:ScoreboardShow()
	if (not IsValid(rp.Scoreboard)) then
		rp.Scoreboard = ui.Create 'rp_scoreboard'
	end

	rp.Scoreboard:Open()
	rp.Scoreboard:MakePopup()
end

function GM:ScoreboardHide()
	if IsValid(rp.Scoreboard) then
		rp.Scoreboard:Close()
	end
end
