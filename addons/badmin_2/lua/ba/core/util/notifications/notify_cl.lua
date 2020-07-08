local notify_types = {
	[0] = Color(255,100,100),
	[1] = Color(255,30,30),
}

net.Receive('ba.NotifyString', function(len)
	if (not IsValid(LocalPlayer())) then return end
	chat.AddText(notify_types[net.ReadBit()], '| ', unpack(ba.ReadMsg()))
end)

net.Receive('ba.NotifyTerm', function(len)
	if (not IsValid(LocalPlayer())) then return end
	chat.AddText(notify_types[net.ReadBit()], '| ', unpack(ba.ReadTerm()))
end)
