ba.svar = ba.svar or {
	stored = {}
}

if (CLIENT) then
	function ba.svar.Get(name)
		return nw.GetGlobal('ba.ServerVars') and nw.GetGlobal('ba.ServerVars')[name]
	end
end

nw.Register 'ba.ServerVars'
	:Write(function(v)
		net.WriteUInt(#v,4)
		for k, v in ipairs(v) do
			net.WriteString(v.Name)
			net.WriteString(v.Value)
		end
	end)
	:Read(function()
		local ret = {}
		for i = 1, net.ReadUInt(4) do
			ret[net.ReadString()] = net.ReadString()
		end
		return ret
	end)
	:SetGlobal()
