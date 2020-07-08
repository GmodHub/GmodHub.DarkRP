util.AddNetworkString 'ba.NotifyString'
util.AddNetworkString 'ba.NotifyTerm'

function ba.notify(recipients, msg, ...)
	if isstring(msg) then
		net.Start('ba.NotifyString')
			net.WriteBit(0)
			ba.WriteMsg(msg, ...)
		net.Send(recipients)
	else
		net.Start('ba.NotifyTerm')
			net.WriteBit(0)
			net.WriteTerm(msg, ...)
		net.Send(recipients)
	end
end

function ba.notify_err(recipients, msg, ...)
	if isstring(msg) then
		net.Start('ba.NotifyString')
			net.WriteBit(1)
			ba.WriteMsg(msg, ...)
		net.Send(recipients)
	else
		net.Start('ba.NotifyTerm')
			net.WriteBit(1)
			net.WriteTerm(msg, ...)
		net.Send(recipients)
	end
end

function ba.notify_all(msg, ...)
	if isstring(msg) then
		net.Start('ba.NotifyString')
			net.WriteBit(0)
			ba.WriteMsg(msg, ...)
		net.Broadcast()
	else
		net.Start('ba.NotifyTerm')
			net.WriteBit(0)
			net.WriteTerm(msg, ...)
		net.Broadcast()
	end
end

function ba.notify_staff(msg, ...)
	if isstring(msg) then
		net.Start('ba.NotifyString')
			net.WriteBit(0)
			ba.WriteMsg(msg, ...)
		net.Send(player.GetStaff())
	else
		net.Start('ba.NotifyTerm')
			net.WriteBit(0)
			net.WriteTerm(msg, ...)
		net.Send(player.GetStaff())
	end
	return true
end
ba.NOTIFY_STAFF = ba.notify_staff
