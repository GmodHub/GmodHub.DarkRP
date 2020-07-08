rp.question = rp.question or {
	Queue = {}
}

function rp.question.Exists(uid)
	return (rp.question.Queue[uid] ~= nil)
end