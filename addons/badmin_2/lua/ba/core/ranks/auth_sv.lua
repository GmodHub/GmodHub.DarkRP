util.AddNetworkString("ba.PasswordRequest")
util.AddNetworkString("ba.PasswordAuth")

local db = ba.data.GetDB()

net.Receive("ba.PasswordAuth", function(len, pl)

  if (pl:GetRank() == "User") then
    return
  end

  local pass = net.ReadString()

  pl:SetBVar('Authed', true)
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
end
