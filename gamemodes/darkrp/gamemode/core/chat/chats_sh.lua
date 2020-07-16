if (CLIENT) then
	cvar.Register 'oocchat_enable'
		:SetDefault(true, true)
		:AddMetadata('Catagory', 'Чат')
		:AddMetadata('Menu', 'Включить OOC чат')

	cvar.Register 'advert_blocker'
		:SetDefault(false, true)
		:AddMetadata('Catagory', 'Чат')
		:AddMetadata('Menu', 'Блокировать объявления в чате')

	cvar.Register 'tts_enable'
		:SetDefault(false, true)
		:AddMetadata('Catagory', 'Чат')
		:AddMetadata('Menu', 'Включить text to speech')

end

hook.Add('PlayerGetChatTag', 'rp.chat.PlayerGetChatTag', function(pl)
	if (not IsValid(pl)) or (not pl:IsVIP()) then return end

	local lastTag
	for k, v in ipairs(rp.cfg.PlayTimeRanks) do
		if (pl:GetPlayTime() > v[2]) then
			if (v[3] ~= nil) then
				lastTag = v[3] .. ' '
			end
		else
			return lastTag
		end
	end

	return lastTag
end)

local function writemsg(pl, v)
	net.WritePlayer(pl)
	net.WriteString(v)
end

local function tts(txt)
	sound.PlayURL('https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=' .. txt ..'&tl=en','2d',function(station)
		if IsValid(station) then
			station:SetVolume(1)
			station:Play()
		end
	end)
end

local function applyMsg(c, p, pl, msg)
	c = c or ''
	p = p or ''
	if IsValid(pl) then
		if (IsValid(CHATBOX)) then CHATBOX.DoEmotes = pl:IsVIP() end

		if cvar.GetValue('tts_enable') and system.HasFocus() then
			tts(msg)
			return c, p, pl:GetJobColor(), pl:Name(), rp.col.White, ': ', msg
		else
			return c, p, pl:GetChatTag(), pl:GetJobColor(), pl:Name(), rp.col.White, ': ', msg
		end
	else
		return c, p, rp.col.Gray, 'Unknown: ', rp.col.White, msg
	end
end

local function readmsg(c, p)
	c = c or ''
	p = p or ''
	local pl = net.ReadPlayer()
	local msg = net.ReadString()
	return applyMsg(c, p, pl, msg)
end

local function readBlockableMessage(c, p)
	c = c or ''
	p = p or ''

	local pl = net.ReadPlayer()
	if (not IsValid(pl)) or pl:IsBlocked() then return end

	local msg = net.ReadString()
	return applyMsg(c, p, pl, msg)
end

local col = rp.col

chat.Register 'Local'
	:Write(writemsg)
	:Read(readmsg)
	:SetLocal(250)

chat.Register 'Whisper'
	:Write(writemsg)
	:Read(function()
		return readmsg(col.Red, '[Whisper] ')
	end)
	:SetLocal(90)

chat.Register 'Yell'
	:Write(writemsg)
	:Read(function()
		return readmsg(col.Red, '[Yell] ')
	end)
	:SetLocal(600)

chat.Register 'Me'
	:Write(writemsg)
	:Read(function()
		local pl = net.ReadPlayer()
		if IsValid(pl) and (not pl:IsBlocked()) then
			return pl:GetJobColor(), pl:Name() .. ' ' .. net.ReadString()
		end
	end)
	:SetLocal(250)

chat.Register 'Ad'
	:Write(writemsg)
	:Read(function()
		if !cvar.GetValue('advert_blocker') then
			return readBlockableMessage(col.Red, '[Advertisement] ')
		end
	end)

chat.Register 'Radio'
	:Write(function(channel, pl, message)
		net.WriteUInt(channel, 8)
		writemsg(pl, message)
	end)
	:Read(function()
		CHATBOX.PendingChatTab = 'Radio'
		return readBlockableMessage(col.Grey, '[Channel ' .. net.ReadUInt(8) .. '] ')
	end)
	:Filter(function(channel, pl, message)
		return table.Filter(player.GetAll(), function(v)
			return v.RadioChannel and (v.RadioChannel == pl.RadioChannel)
		end)
	end)

chat.Register 'Broadcast'
	:Write(writemsg)
	:Read(function()
		return readBlockableMessage(col.Red, '[Broadcast] ')
	end)

local function testGroupChats(t1, t2)
	return rp.groupChats[t1] and rp.groupChats[t1][t2]
end
chat.Register 'Group'
	:Write(writemsg)
	:Read(function()
		local pref = '[Group ]'

		local pl = net.ReadPlayer()
		local msg = net.ReadString()

		if (pl:GetNetVar('Employer') == LocalPlayer() or (LocalPlayer():GetNetVar('Employer') == pl)) then
			pref = '[Employed] '
		elseif (testGroupChats(LocalPlayer():GetJob(), pl:GetJob())) then
			pref = '[' .. rp.groupChats[LocalPlayer():GetJob()].Name .. '] '
		elseif (testGroupChats(LocalPlayer():Team(), pl:Team())) then
			pref = '[' .. rp.groupChats[LocalPlayer():Team()].Name .. '] '
		else
			if (pl == LocalPlayer()) then
				rp.Notify(NOTIFY_ERROR, 'You\'re not currently in a group chat.')
				chat.AddText(col.Orange, '[Note] ', col.White, 'You\'re not currently in a group chat.')
			end
			return
		end

		CHATBOX.PendingChatTab = 'Group'
		return applyMsg(col.Green, pref, pl, msg)
	end)
	:Filter(function(pl)
		return table.Filter(player.GetAll(), function(v)
			if (v == pl) then return true end
			if (v:GetNetVar('Employer') == pl or pl:GetNetVar('Employer') == v) then return true end
			if (testGroupChats(pl:GetJob(), v:GetJob())) then return true end
			if (testGroupChats(pl:GetJob(), v:Team())) then return true end

			return false
		end)
	end)

chat.Register 'OOC'
	:Write(writemsg)
	:Read(function()
		if cvar.GetValue('oocchat_enable') then
			return readBlockableMessage(col.OOC, '[OOC] ')
		end
	end)

chat.Register 'Org'
	:Write(function(pl, ...)
		net.WritePlayer(pl)
		writemsg(...)
	end)
	:Read(function()
		local pl = net.ReadPlayer()
		if IsValid(pl) then
			CHATBOX.PendingChatTab = 'Org'
			return readBlockableMessage(pl:GetOrgColor(), '[ORG] ')
		end
	end)
	:Filter(function(pl, message)
		return rp.orgs.GetOnlineMembers(pl:GetOrg())
	end)

chat.Register '911'
	:Write(writemsg)
	:Read(function()
		CHATBOX.PendingChatTab = '911'
		return readmsg(col.Yellow, '[911] ')
	end)
	:Filter(function(pl, message)
		return table.Filter(player.GetAll(), function(v)
			return v:IsCP() or (v == pl)
		end)
	end)

chat.Register 'Roll'
	:Write(function(pl, num)
		net.WritePlayer(pl)
		net.WriteUInt(num, 8)
	end)
	:Read(function()
		local pl = net.ReadPlayer()
		if IsValid(pl) then
			return col.Red, '[', col.Pink, 'ROLL', col.Red, '] ', pl:GetJobColor(), pl:Name() .. ' ', rp.col.White, 'has rolled ', col.Pink, tostring(net.ReadUInt(8)), col.White, ' out of 100.'
		end
	end)
	:SetLocal(250)

chat.Register 'Dice'
	:Write(function(pl, num1, num2)
		net.WritePlayer(pl)
		net.WriteUInt(num1, 8)
		net.WriteUInt(num2, 8)
	end)
	:Read(function()
		local pl = net.ReadPlayer()
		if IsValid(pl) then
			return col.Red, '[', col.Pink, 'DICE', col.Red, '] ', pl:GetJobColor(), pl:Name() .. ' ', rp.col.White, 'has rolled ', col.Pink, tostring(net.ReadUInt(8)), col.White, ' and ', col.Pink, tostring(net.ReadUInt(8)), '.'
		end
	end)
	:SetLocal(250)

chat.Register 'Cards'
	:Write(function(pl, card)
		net.WritePlayer(pl)
		net.WriteString(card)
	end)
	:Read(function()
		local pl = net.ReadPlayer()
		if IsValid(pl) then
			return col.Red, '[', col.Pink, 'CARDS', col.Red, '] ', pl:GetJobColor(), pl:Name() .. ' ', rp.col.White, 'has flipped ', col.Pink, net.ReadString(), col.White, '.'
		end
	end)
	:SetLocal(250)

chat.Register 'Coin'
	:Write(function(pl, card)
		net.WritePlayer(pl)
		net.WriteString(card)
	end)
	:Read(function()
		local pl = net.ReadPlayer()
		if IsValid(pl) then
			return col.Red, '[', col.Pink, 'COIN', col.Red, '] ', pl:GetJobColor(), pl:Name() .. ' ', rp.col.White, 'has flipped ', col.Pink, net.ReadString(), col.White, '.'
		end
	end)
	:SetLocal(250)
