term.Add('ScreengrabStarted', 'Screengrab started on #, please allow up to 30 seconds for this to finish.')
term.Add('ScreengrabCooldown', '# has an active screengrab uploading please wait!')

local screengrabs = {}
local uniqueid = 0

ba.AddCommand('SG', function(pl, target)
	if target:GetBVar('ScreengrabBusy') then
		ba.notify(pl, term.Get('ScreengrabCooldown'), target)
		return
	end

	target:SetBVar('ScreengrabBusy', true)

	net.Start('ba.cmd.sg.request')
		net.WriteUInt(uniqueid, 16)
		screengrabs[uniqueid] = pl
		uniqueid = (uniqueid + 1) % 0xFFFF
	net.Send(target)

	ba.notify(pl, term.Get('ScreengrabStarted'), target)
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'A'
:SetHelp 'Shows you your target\'s screen'

if (SERVER) then
	util.AddNetworkString 'ba.cmd.sg.request'
	util.AddNetworkString 'ba.cmd.sg.display'
	util.AddNetworkString 'ba.cmd.sg.upload'

	net.Receive('ba.cmd.sg.upload', function(_, pl)
		local txnid = net.ReadUInt(16)
		if not screengrabs[txnid] then return end

		pl:SetBVar('ScreengrabBusy', nil)

		net.ReadStream(pl, function(data)
			net.Start('ba.cmd.sg.display')
				net.WritePlayer(pl)
				net.WriteStream(data, screengrabs[txnid])
			net.Send(screengrabs[txnid])
		end)
	end)
else
	net.Receive('ba.cmd.sg.request', function()
		local txnid = net.ReadUInt(16)

		RunConsoleCommand('con_filter_enable', 1)
		RunConsoleCommand('con_filter_text_out', txnid..'.jpg')

		RunConsoleCommand('__screenshot_internal', tostring(txnid))

		timer.Simple(1, function()
			RunConsoleCommand('con_filter_enable', 0)
			RunConsoleCommand('con_filter_text_out', '')

			net.Start('ba.cmd.sg.upload')
				net.WriteUInt(txnid, 16)
				net.WriteStream(file.Read('screenshots/' .. txnid .. '.jpg','GAME'))
			net.SendToServer()
		end)
	end)

	net.Receive('ba.cmd.sg.display', function()
		local pl = net.ReadPlayer()
		net.ReadStream(function(data)
			local w, h = ScrW() *.95, ScrH() *.95

			local fr = ui.Create('ui_frame', function(self)
				self:SetSize(w, h)
				self:MakePopup()
				self:Center()
				self:SetTitle('Screen Capture: ' .. pl:NameID())
			end)

			ui.Create('DHTML', function(self)
				local x, y = fr:GetDockPos()
				self:SetPos(x, y)
				self:MoveToBack()
				self:SetSize(w - 10, h - y - 5)
				self:SetHTML('<style type="text/css"> body { margin: 0; padding: 0; overflow: hidden; } img { width: 100%; height: 100%; } </style> <img src="data:image/jpg;base64,' .. util.Base64Encode(data) .. '"> ')
			end, fr)
		end)
	end)
end
