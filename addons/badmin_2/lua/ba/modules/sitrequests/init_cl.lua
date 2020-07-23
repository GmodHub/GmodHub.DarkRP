cvar.Register 'AdminChatSound'
	:SetDefault(true, true)
	:AddMetadata('Catagory', 'Администрация')
	:AddMetadata('Menu', 'Включить звук админ чата')
	:SetShouldShow(function()
		return LocalPlayer():IsAdmin()
	end)

ba.sits.Pending = ba.sits.Pending or {}
ba.sits.Receiving = ba.sits.Receiving or {}

local sitValid = function(self)
	return (self.Valid and IsValid(self.Player) and (CurTime() - self.Time < 600))
end
net('ba.StaffRequest', function(len)
	local plID = net.ReadUInt(8)
	local text = net.ReadString()
	local time = net.ReadFloat()

	local pl = Entity(plID)

	if (!IsValid(pl)) then
		ba.sits.Receiving[plID] = true
		return
	end

	local sit = {
		ID = plID,
		Player = pl,
		Text = text,
		Time = time,
		Valid = true,
		StillValid = sitValid
	}

	ba.sits.Pending[plID] = sit
	ba.sits.Menu:AddRequest(plID)
end)

net('ba.StaffRequestDelayed', function(len)
	local plID = net.ReadUInt(8)
	ba.sits.Receiving[plID] = true
end)

net('ba.PurgeStaffRequests', function(len)
	local plID = net.ReadUInt(8)

	if (ba.sits.Pending[plID]) then
		ba.sits.Pending[plID].Valid = false
	end

	ba.sits.Pending[plID] = nil
	ba.sits.Receiving[plID] = nil
end)

local color_white = Color(235, 235, 235)
net('ba.AdminChat', function(len)
	local pl = net.ReadPlayer()
	local msg = net.ReadString()

	if (!IsValid(pl)) then return end

	if (IsValid(CHATBOX)) then CHATBOX.DoEmotes = true end

	CHATBOX.ChatResponseCommand = '@'
	chat.AddTabbedText('Staff', Color(255,100,100), '| ', ui.col.SUP, '[STAFF] ', pl, color_white, ': ', msg)
end)

hook('Think', function()
	for k, v in pairs(ba.sits.Receiving) do
		local pl = Entity(k)
		if (IsValid(pl)) then
			net.Start('ba.GetStaffRequest')
				net.WritePlayer(pl)
			net.SendToServer()

			ba.sits.Receiving[k] = nil
		end
	end
end)
