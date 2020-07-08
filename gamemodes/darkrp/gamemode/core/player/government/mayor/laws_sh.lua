rp.AddCommand('laws', function(pl)
	if (not pl:IsMayor()) then
		return NOTIFY_ERROR, term.Get('MustBeMayorSetLaws')
	end

	if (rp.cfg.MayorMachine and rp.cfg.MayorMachine:GetPos():DistToSqr(pl:GetPos()) > 40000) then
		return NOTIFY_ERROR, term.Get('MustBeNearbyMayorMachine')
	end
end)

:RunOnClient(function()
	if (not LocalPlayer():IsMayor()) then return end
	local e = LocalPlayer():GetEyeTrace().Entity
	if (!IsValid(e) or e:GetClass() != "mayor_machine" or e:GetPos():DistToSqr(LocalPlayer():GetPos()) > 40000) then return end

	local Laws = nw.GetGlobal 'TheLaws' or ''

	local fr = ui.Create('ui_frame', function(self)
		self:SetSize(ScrW() * .2, ScrH() * .3)
		self:Center()
		self:SetTitle('Custom Law Editor')
		self:MakePopup()
	end)

	local x, y = fr:GetDockPos()
	local e = ui.Create('DTextEntry', function(self, p)
		self:SetPos(x, y)
		self:SetSize(p:GetWide() - 10, p:GetTall() - y - 65)
		self:SetMultiline(true)
		self:SetPlaceholderText('Laws...')
		self:SetValue(Laws)
		self.OnTextChanged = function()
			Laws = self:GetValue()
		end
	end, fr)

	e = ui.Create('DButton', function(self, p)
		x, y = e:GetPos()
		y = y + e:GetTall() + 5
		self:SetPos(x, y)
		self:SetSize(p:GetWide() - 10, 25)
		self:SetText('Submit laws')
		self.DoClick = function()
			if string.len(Laws) <= 5 then LocalPlayer():ChatPrint('Laws under 5 Characters!') return end
			if #string.Wrap('HudFont', Laws, 325 - 10) >= 10 then LocalPlayer():ChatPrint('Please limit your laws to under 10 lines.') return end
			net.Start('rp.SendLaws')
				net.WriteString(string.Trim(Laws))
			net.SendToServer()
		end
	end, fr)

	e = ui.Create('DButton', function(self, p)
		x, y = e:GetPos()
		y = y + e:GetTall() + 5
		self:SetPos(x, y)
		self:SetSize(p:GetWide() - 10, 25)
		self:SetText('Reset laws')
		self.DoClick = function()
			cmd.Run('resetlaws')
			p:Close()
		end
	end, fr)
end)

if (CLIENT) then
	rp.locksound = rp.locksound or nil
	net('rp.StartLockdown', function()
		if (IsValid(rp.locksound)) then
			rp.locksound:Stop()
		end
		hook.Remove('Think', 'rp.lockdown.sound')
		RunConsoleCommand 'stopsound'

		timer.Create('rp.StartLockdown', 1, 1, function()
			surface.PlaySound 'npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav'

			timer.Create('rp.StartLockdown', 10, 1, function()
				local sndpath = rp.cfg.LockdownSounds[math.random(#rp.cfg.LockdownSounds)]
				sound.PlayFile(sndpath, '', function(channel, errID, errName)
					if (errID) then
						print("Couldn't play lockdown siren (" .. errID .. "): " .. errName)
						return
					end

					rp.locksound = channel
					rp.locksound:SetVolume(0.3)
					rp.locksound:EnableLooping(true)
					rp.locksound:Play()
				end)

				hook.Add('Think', 'rp.lockdown.sound', function()
					if (!IsValid(rp.locksound)) then return end

					if (system.HasFocus()) then
						rp.locksound:SetVolume(0.25)
					else
						rp.locksound:SetVolume(0)
					end
				end)
			end)
		end)
	end)

	net('rp.EndLockdown', function()
		timer.Destroy 'rp.StartLockdown'
		RunConsoleCommand 'stopsound'
	end)
end
