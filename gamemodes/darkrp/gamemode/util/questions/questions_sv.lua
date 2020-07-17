util.AddNetworkString 'rp.question.Ask'
util.AddNetworkString 'rp.question.Destroy'
util.AddNetworkString 'rp.question.Answer'

function rp.question.Create(question, time, uid, callback, isvote, recipients)

  if rp.question.Queue[uid] then return end

	if(isvote) then
		net.Start('rp.question.Ask')
			net.WriteString(question)
			net.WriteUInt(time, 16)
			net.WriteString(uid)
		net.Send(recipients)

		if isplayer(recipients) then
			recipients = {recipients}
		end

		rp.question.Queue[uid] = {
			Question = question,
			Expire = time + CurTime(),
			Callback = callback,
			IsVote = isvote,
			Recipients = recipients
		}
	else
		net.Start("rp.question.Ask")
			net.WriteString(question)
			net.WriteUInt(time, 16)
			net.WriteString(uid)
		net.Send(recipients)

		if isplayer(recipients) then
			recipients = {recipients}
		end

		rp.question.Queue[uid] = {
			Question = question,
			Expire = time + CurTime(),
			Callback = callback,
			IsVote = isvote,
			Recipients = recipients
		}
	end

	hook('Tick', 'rp.Question', rp.question.Tick)
end

rp.question.Votes = {}

function rp.question.Exists(uid)
	local question = rp.question.Queue[uid]
	if not question then return false end

	return true
end

function rp.question.Destroy(uid)
	local question = rp.question.Queue[uid]
	if not question then return end

	if(question.IsVote) then
		local vote = rp.question.Votes[uid]
		if(vote) then
			if(vote.VoteRes > 0) then
				vote.Func(vote.Ply, vote.VoteRes)
			end
			rp.question.Votes[uid] = nil
		end
	end

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
			question.Callback(pl, answer, uid)
			if #question.Recipients == 0 then
				rp.question.Destroy(uid)
			end
		end
	end

end)
