ba.sits = ba.sits or {}
ba.sits.BannedReasons = {
	['админ тп ко мне'] = true,
	['помогите'] = true,
	['админ'] = true,
	['хуй'] = true,
	['тп'] = true,
	['тп ко мне'] = true,
}

term.Add('StaffReqSent', 'Жалоба отправлена: #')
term.Add('StaffReqPend', 'У вас уже есть открытая жалоба!')
term.Add('StaffReqLonger', 'Пожалуйста будьте более детальны (<10+ символов)!')
term.Add('StaffReqBadReason', 'Пожалуйста, опишите вашу проблему нормальным языком!')
term.Add('AdminTookPlayersRequest', '# начала рассмотрение жалобы #.')
term.Add('AdminTookYourRequest', '# принял вашу жалобу, он свяжется с вами скоро.')
term.Add('AdminClosedPlayersRequest', '# закрыл жалобу #.')
term.Add('AdminClosedYourRequest', '# закрыл вашу жалобу.')

ba.AddCommand('Treq', function(pl, targ)
	if targ:HasStaffRequest() then
		//if (info.ChatPrefix) then
		//	ba.sits.LogTakenSit:Run(info.ChatPrefix, pl:SteamID64(), targ:SteamID64(), targ:GetBVar('StaffRequestReason'))
		//end

		ba.notify_staff(term.Get('AdminTookPlayersRequest'), pl, targ)
		ba.notify(targ, term.Get('AdminTookYourRequest'), pl)

		hook.Call("PlayerSitRequestTaken", GAMEMODE, targ, pl)
	end

	ba.sits.Remove(targ)
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'M'
:SetHelp 'Takes an admin request'
:SetAuthRequired(false)


ba.AddCommand('Rreq', function(pl, targ)
	if targ:HasStaffRequest() then

		ba.notify_staff(term.Get('AdminClosedPlayersRequest'), pl, targ)
		ba.notify(targ, term.Get('AdminClosedYourRequest'), pl)

		hook.Call("PlayerSitRequestClosed", GAMEMODE, targ, pl)
	end

	ba.sits.Remove(targ)
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'M'
:SetHelp 'Removes an admin request'
:SetAuthRequired(false)
