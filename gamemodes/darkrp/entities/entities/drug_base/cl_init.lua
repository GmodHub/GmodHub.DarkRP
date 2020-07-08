dash.IncludeSH 'shared.lua'

function ENT:Draw()
	self:DrawModel()
end

local movecommands = {
	'left',
	'right',
	'moveleft',
	'moveright',
	'attack'
}

net('rp.StartHigh', function()
	local inf = rp.Drugs[net.ReadUInt(6)]
	if inf.Movement then
		for k, v in ipairs(movecommands) do
			timer.Simple(k, function()
				local cmd = movecommands[math.random(1, #movecommands)]

				LocalPlayer():ConCommand('+' .. cmd)

				timer.Simple(1, function()
					LocalPlayer():ConCommand('-' .. cmd)
				end)
			end)
		end

	end

	if inf.Sayings then
		LocalPlayer():ConCommand('say ' .. inf.Sayings[math.random(1, #inf.Sayings)])
	end

	if inf.ClientHooks then
		for k, v in pairs(inf.ClientHooks) do
			hook.Add(k, 'rp.DrugHook.' .. k .. inf.Name, function(...)
				v(inf, ...)
			end)
		end
	end
end)

net('rp.EndHigh', function()
	local inf = rp.Drugs[net.ReadUInt(6)]
	if inf.ClientHooks then
		for k, v in pairs(inf.ClientHooks) do
			hook.Remove(k, 'rp.DrugHook.' .. k .. inf.Name, v)
		end
	end
end)
