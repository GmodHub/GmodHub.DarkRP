/*---------------------------------------------------------
Talking
 ---------------------------------------------------------*/

function GM:PlayerSay(pl, text, teamonly, dead)
	text = string.Trim(text)

	if pl:IsBanned() or (text == '') then return '' end

  chat.Send('Local', pl, text)
  return ''
end

rp.AddCommand('whisper', function(pl, text)
    chat.Send('Whisper', pl, text)
end)
:AddParam(cmd.STRING)
:SetCooldown(1.5)
:SetChatCommand()
:AddAlias('w')

rp.AddCommand('yell', function(pl, text)
  chat.Send('Yell', pl, text)
end)
:AddParam(cmd.STRING)
:SetCooldown(1.5)
:SetChatCommand()
:AddAlias('y')

rp.AddCommand('me', function(pl, text)
  chat.Send('Me', pl, text)
end)
:AddParam(cmd.STRING)
:SetCooldown(1.5)
:SetChatCommand()

rp.AddCommand('/', function(pl, text)
	chat.Send('OOC', pl, text)
end)
:AddParam(cmd.STRING)
:SetCooldown(1.5)
:SetChatCommand()
:AddAlias('ooc')
:AddAlias('occ') -- for dumbass

rp.AddCommand('advert', function(pl, text)
	if pl:CanAfford(rp.cfg.AdvertCost) then
		pl:AddMoney(-rp.cfg.AdvertCost)
		rp.Notify(pl, NOTIFY_GREEN, term.Get('RPItemBought'), 'advertising', rp.FormatMoney(rp.cfg.AdvertCost))
		chat.Send('Ad', pl, text)
	else
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
	end
end)
:AddParam(cmd.STRING)
:SetCooldown(1.5)
:SetChatCommand()
:AddAlias('ad')

rp.AddCommand('org', function(pl, text)
  if pl:GetOrg() then
    chat.Send('Org', pl, pl, text)
  end
end)
:AddParam(cmd.STRING)
:SetCooldown(1.5)
:SetChatCommand()
:AddAlias('o')

rp.AddCommand('broadcast', function(pl, text)
  if pl:IsMayor() then
    chat.Send('Broadcast', pl, text)
  end
end)
:AddParam(cmd.STRING)
:SetCooldown(1.5)
:SetChatCommand()
:AddAlias('b')

rp.AddCommand("channel", function(pl, channel)
	if channel < 0 or channel > 100 then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('ChannelLimit'))
		return
	end
	rp.Notify(pl, NOTIFY_GREEN, term.Get('ChannelSet'), channel)
	pl.RadioChannel = channel
end)
:AddParam(cmd.NUMBER)
:SetCooldown(1.5)

rp.AddCommand("radio", function(pl, text)
	if not pl.RadioChannel then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('ChannelNotSet'))
    return
	end

  chat.Send('Radio', pl.RadioChannel, pl, text)
end)
:AddParam(cmd.STRING)
:SetCooldown(1.5)
:SetChatCommand()
:AddAlias('r')

rp.AddCommand("group", function(pl, text)
  chat.Send('Group', pl, text)
end)
:AddParam(cmd.STRING)
:SetCooldown(1.5)
:SetChatCommand()
:AddAlias('g')
