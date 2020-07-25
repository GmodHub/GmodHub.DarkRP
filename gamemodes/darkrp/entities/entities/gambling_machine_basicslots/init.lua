dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

function ENT:Play(ply)
	local roll1 = math.random(0, 9)
	local roll2 = math.random(0, 9)
	local roll3 = math.random(0, 9)

	self:SetRoll1(roll1)
	self:SetRoll2(roll2)
	self:SetRoll3(roll3)

	if((roll1 + roll2 + roll3) / 3 == roll1) then
		self:PayOut(ply, self:Getprice() * 10)
		rp.Notify(ply, NOTIFY_SUCCESS, term.Get('BasicSlotsPlayerWin'), rp.FormatMoney(self:Getprice() * 10))
	elseif(roll1 == roll2 or roll1 == roll3 or roll2 == roll3) then
		self:PayOut(ply, self:Getprice() * 4)
		rp.Notify(ply, NOTIFY_SUCCESS, term.Get('BasicSlotsPlayerWin'), rp.FormatMoney(self:Getprice() * 4))
	else
		self:PayOut(ply, -self:Getprice())
		rp.Notify(ply, NOTIFY_ERROR, term.Get('BasicSlotsPlayerLose'), rp.FormatMoney(self:Getprice()))
	end
end
