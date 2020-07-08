if (SERVER) then
	util.AddNetworkString('ba.FullServerRedirect')
	
	hook.Add('playerRankLoaded', 'PerformFullServerRedirect', function(pl)
		if (#player.GetAll() >= 108) then
			local target
			if (pl:GetRank() ~= 'vip') and (not pl:IsAdmin()) then
				target = pl
			else
				local afk = table.Filter(player.GetAll(), function(v) return v:IsAFK(1200) end)
				table.SortByMember(afk, 'NotAFK', true)
				target = afk[1]
			end

			if IsValid(target) then
				net.Start('ba.FullServerRedirect')
					net.WriteBool(target == pl)
				net.Send(target)
			end

		end
	end)
	
	return
end

hook.Add('InitPostEntity', 'fullserver.InitPostEntity', function()
	if cvar.GetValue('FullServerRedirect') or cvar.GetValue('AFKRedirect') then
		local fr = ui.Create('ui_frame', function(self)
			self:SetSize(550, 120)
			self:SetTitle('REDIRECTED')
			self:MakePopup()
			self:Center()
		end)

		local reason = ''
		if cvar.GetValue('AFKRedirect') then
			reason = 'You were redirected to our ' .. info.ChatPrefix .. ' server since our ' .. info.AltChatPrefix .. ' server was too full and you were afk.'
		else
			reason = 'You were redirected to our ' .. info.ChatPrefix .. ' server since our ' .. info.AltChatPrefix .. ' server was too full. You can purchase VIP if you\'d like access to 20 reserved slots, type /upgrades.'
		end
		
		local label = ba.ui.Label(reason, fr, {
			 font = 'ba.ui.18'
		})
		label:Dock(TOP)
		label:SetWrap(true)
		label:SetAutoStretchVertical(true)
		label:SetTextColor(color_black)

		ui.Create('DButton', function(self, p)
			self:SetText('Okay!')
			self:SetPos(5, p:GetTall() - 30)
			self:SetSize(p:GetWide() - 10, 25)
			function self:DoClick()
				fr:Close()
			end
		end, fr)
	end

	cvar.SetValue('FullServerRedirect', nil)
	cvar.SetValue('AFKRedirect', nil)
end)


net.Receive('ba.FullServerRedirect', function()	
	if net.ReadBool() then
		cvar.SetValue('AFKRedirect', true)
	else
		cvar.SetValue('FullServerRedirect', true)
	end
	rp.RunCommand(info.AltChatPrefix)
end)