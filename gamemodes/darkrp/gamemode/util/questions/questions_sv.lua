util.AddNetworkString 'rp.question.Ask'
util.AddNetworkString 'rp.question.Destroy'
util.AddNetworkString 'rp.question.Answer'

function rp.question.Create(question, time, uid, callback, hz, recipients)

  if rp.question.Queue[uid] then return end

  net.Start('rp.question.Ask')
    net.WriteString(question)
    net.WriteUInt(time, 16)
    net.WriteString(uid)
  net.Send(recipients)

  rp.question.Queue[uid] = {
    Question = question,
    Expire = time + CurTime(),
    Callback = callback,
    Recipients = recipients
  }

  hook('Tick', 'rp.Question', rp.question.Tick)
end

function rp.question.Destroy(uid)

  local question = rp.question.Queue[uid]
  if not question then return end

  net.Start('rp.question.Destroy')
    net.WriteString(uid)
  net.Send(question.Recipients)


  rp.question.Queue[uid] = nil
end

function rp.question.Tick()
  local count = 0

  for k, v in pairs(rp.question.Queue) do
    local shouldFinish = CurTime() > v.Expire

    if (shouldFinish) then
      rp.question.Destroy(k)
      return
    end

    count = count + 1
  end

  if (count == 0) then
    hook.Remove('Tick', 'rp.Question')
    return
  end
end

net('rp.question.Answer', function(len, pl)
  local uid = net.ReadString()
  local answer = net.ReadBool()

  if (not uid or not isbool(answer)) then return end

  local question = rp.question.Queue[uid]

  if (not question) then return end

  for k, v in ipairs(question.Recipients) do
    if (IsValid(v) and v == pl) then
      table.remove(question.Recipients, k)

      question.Callback(pl, answer)

      if #question.Recipients == 0 then
        rp.question.Destroy(uid)
      end
    end
  end

end)
/*
rp.question.Create('Do you want to participate in an event?', 30, 'event', function(pl, answer)
  if (answer) then
    pl:SetPos(util.FindEmptyPos(Vector(-4065, 1555, -1024)))
  end
end, nil, table.Filter(player.GetAll(), function(v) return !v:IsArrested() and !v:IsJailed() and v != pl end))
