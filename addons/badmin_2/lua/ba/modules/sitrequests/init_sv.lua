util.AddNetworkString 'ba.AdminChat'
util.AddNetworkString 'ba.StaffRequestDelayed'
util.AddNetworkString 'ba.StaffRequest'
util.AddNetworkString 'ba.PurgeStaffRequests'
util.AddNetworkString 'ba.GetStaffRequest'

function PLAYER:HasStaffRequest()
    return (self:GetBVar('StaffRequest') and (CurTime() - self:GetBVar('StaffRequestTime') < 600))
end

hook.Add('PlayerSay', 'ba.AdminChat', function(pl, text)
    if (text[1] == '@') then
        if (hook.Call('PlayerCanUseAdminChat', ba, pl) ~= false) then
            text = text:sub(2):Trim()

            for k,v in pairs(ba.sits.BannedReasons) do
                if string.match(text, k) then
                    ba.notify_err(pl, term.Get('StaffReqBadReason'))
                    return ''
                end
            end

            if pl:HasStaffRequest() then
                ba.notify_err(pl, term.Get('StaffReqPend'))
            elseif (not pl:IsAdmin() and text:len() < 10) then
                ba.notify_err(pl, term.Get('StaffReqLonger'))
            else
                net.Start('ba.AdminChat')
                    net.WritePlayer(pl)
                    net.WriteString(text)
                net.Send(player.GetStaff())

                if (not pl:IsAdmin()) then
                    ba.notify(pl, term.Get('StaffReqSent'), text)
                    pl:SetBVar('StaffRequest', true)
                    pl:SetBVar('StaffRequestReason', text)
                    pl:SetBVar('StaffRequestTime', CurTime())

                    net.Start('ba.StaffRequest')
                        net.WriteUInt(pl:EntIndex(), 8)
                        net.WriteString(pl:GetBVar('StaffRequestReason'))
                        net.WriteFloat(pl:GetBVar('StaffRequestTime'))
                    net.Send(player.GetStaff())

                    hook.Call("PlayerSitRequestOpened", GAMEMODE, pl, text)
                end
            end

            return ''
        end
    end
end)

hook.Add('playerRankLoaded', 'ba.NetworkRequests', function(pl)
    if (!pl:IsAdmin()) then return end

    for k, v in ipairs(player.GetAll()) do
        if (v:HasStaffRequest()) then
            net.Start('ba.StaffRequestDelayed')
                net.WriteUInt(v:EntIndex(), 8)
            net.Send(pl)
        end
    end
end)

hook.Add('PlayerDisconnected', 'ba.PurgeStaffRequests', function(pl)
    if (pl:HasStaffRequest()) then
        net.Start('ba.PurgeStaffRequests')
            net.WriteUInt(pl:EntIndex(), 8)
        net.Send(player.GetStaff())
    end
end)

net('ba.GetStaffRequest', function(len, pl)
    local targ = net.ReadPlayer()

    if (!IsValid(targ) or !pl:IsAdmin() or !targ:HasStaffRequest()) then return end

    net.Start('ba.StaffRequest')
        net.WriteUInt(targ:EntIndex(), 8)
        net.WriteString(targ:GetBVar('StaffRequestReason'))
        net.WriteFloat(targ:GetBVar('StaffRequestTime'))
    net.Send(pl)
end)

function ba.sits.Remove(pl)
    pl:SetBVar('StaffRequest', nil)
    pl:SetBVar('StaffRequestReason', nil)
    pl:SetBVar('StaffRequestTime', nil)

    net.Start('ba.PurgeStaffRequests')
        net.WriteUInt(pl:EntIndex(), 8)
    net.Send(player.GetStaff())
end
