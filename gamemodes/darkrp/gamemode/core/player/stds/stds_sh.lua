function PLAYER:GetSTD()
	return self:GetNetVar('STD')
end

function PLAYER:HasSTD()
	return (self:GetSTD() ~= nil)
end