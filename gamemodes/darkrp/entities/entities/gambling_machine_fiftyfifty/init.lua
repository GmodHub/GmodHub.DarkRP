dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

function ENT:Play(ply)
	self:SetPlayerRoll(math.random(0, 100))
	self:SetHouseRoll(math.random(0, 100))

	if(self:GetPlayerRoll() < self:GetHouseRoll()) then
		self:PayOut(ply, -self:Getprice())
		rp.Notify(ply, NOTIFY_ERROR, term.Get("5050PlayerLose"), rp.FormatMoney(self:Getprice()))
	elseif(self:GetPlayerRoll() > self:GetHouseRoll()) then
		self:PayOut(ply, self:Getprice())
		rp.Notify(ply, NOTIFY_SUCCESS, term.Get("5050PlayerWin"), rp.FormatMoney(self:Getprice()))
	elseif(self:GetPlayerRoll() == self:GetHouseRoll()) then
		rp.Notify(ply, NOTIFY_SUCCESS, term.Get("5050Tie"), rp.FormatMoney(self:Getprice()))
	end
end
