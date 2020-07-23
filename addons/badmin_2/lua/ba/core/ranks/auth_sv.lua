util.AddNetworkString("ba.PasswordRequest")
util.AddNetworkString("ba.PasswordAuth")

local db = ba.data.GetDB()

net.Receive("ba.PasswordAuth", function(len, pl)
    if (pl:GetRank() == "User") then return end
    if not pl.AuthCallback then return end

    local isreset = net.ReadBool()
    local pass = net.ReadString()
    if isreset then
      local hasResetKey = net.ReadBool()
    end

    if utf8.len(pass) < 4 then return end
    if utf8.len(pass) > 50 then return end

    db:Query('SELECT * FROM ba_passcode WHERE steamid = '.. pl:SteamID64() ..';', function(data)
        if data[1] and data[1].passcode != pass then
            pl:Notify(NOTIFY_ERROR, term.Get('AdminPasswordIncorrect'))
            net.Start("ba.PasswordRequest")
                net.WriteBool(false)
            net.Send(pl)
            return
        elseif not data[1] and not isreset then
            pl:Notify(NOTIFY_GENERIC, term.Get('AdminPasswordResetRequest'))
            net.Start("ba.PasswordRequest")
                net.WriteBool(true)
                net.WriteBool(false)
            net.Send(pl)
            return
        elseif not data[1] and isreset and not hasResetKey then
            pl:Notify(NOTIFY_GENERIC, term.Get('AdminPasswordSet'))
            db:Query('INSERT INTO `ba_passcode`(`steamid`, `passcode`) VALUES ('.. pl:SteamID64() ..', ?)', pass)
        end

        pl:SetBVar('Authed', true)

        pl:Notify(NOTIFY_GENERIC, term.Get('AdminNowAuthenticated'))

        if pl.AuthCallback then
            pl.AuthCallback()
        end
    end)
end)

function ba.IsAuthed(pl)

  if (!pl:GetBVar('Authed')) then
    return false
  end

  return true
end

function ba.RequestAuth(pl, callback)
    db:Query('SELECT * FROM ba_passcode WHERE steamid = '.. pl:SteamID64() ..';', function(data)
        if data[1] then
            net.Start("ba.PasswordRequest")
                net.WriteBool(false)
            net.Send(pl)
        else
            net.Start("ba.PasswordRequest")
                net.WriteBool(true)
                net.WriteBool(false)
            net.Send(pl)
        end
    end)

  pl.AuthCallback = callback
end
