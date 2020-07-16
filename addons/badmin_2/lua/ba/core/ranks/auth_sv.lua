util.AddNetworkString("ba.PasswordRequest")
util.AddNetworkString("ba.PasswordAuth")

local db = ba.data.GetDB()

net.Receive("ba.PasswordAuth", function(len, pl)

  if (pl:GetRank() == "User") then
    return
  end

  if not pl.AuthCallback then return end

  local isreset = net.ReadBool()
  local pass = net.ReadString()

  if (pass != "kall") then
    pl:Notify(NOTIFY_ERROR, term.Get('AdminPasswordIncorrect'))
    net.Start("ba.PasswordRequest")
      net.WriteBool(false)
    net.Send(pl)
    return
  end

  pl:SetBVar('Authed', true)

  pl:Notify(NOTIFY_GENERIC, term.Get('AdminNowAuthenticated'))

  if pl.AuthCallback then
    pl.AuthCallback()
  end
end)

function ba.IsAuthed(pl)

  if (!pl:GetBVar('Authed')) then
    return false
  end

  return true
end

function ba.RequestAuth(pl, callback)
  net.Start("ba.PasswordRequest")
    net.WriteBool(false)
  net.Send(pl)

  pl.AuthCallback = callback
end
