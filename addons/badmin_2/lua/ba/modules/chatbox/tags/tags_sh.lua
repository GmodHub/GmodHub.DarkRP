function PLAYER:GetChatTag()
	return hook.Call('PlayerGetChatTag', nil, self) or ''
end
