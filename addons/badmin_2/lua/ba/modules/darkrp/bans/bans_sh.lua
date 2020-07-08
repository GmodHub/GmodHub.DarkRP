nw.Register 'IsBanned'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetLocalPlayer()

function PLAYER:IsBanned()
	return (self:GetNetVar('IsBanned') == true)
end
