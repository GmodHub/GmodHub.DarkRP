dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

function ENT:Play(ply)
	local roll = math.random(0, 7)
	self:SetRoll(roll)

	if(roll == 0) then
		self:PayOut(ply, self:Getprice() * 5)
		rp.Notify(ply, NOTIFY_ERROR, term.Get("SpinWheelPlayerWin"), self:Getprice() * 5)
	elseif(roll == 1) then
		self:PayOut(ply, -self:Getprice() * 2)
		rp.Notify(ply, NOTIFY_ERROR, term.Get("SpinWheelPlayerLose"), self:Getprice() * 2)
	elseif(roll == 2) then
		self:PayOut(ply, self:Getprice() * 2)
		rp.Notify(ply, NOTIFY_SUCCESS, term.Get("SpinWheelPlayerWin"), self:Getprice() * 2)
	elseif(roll == 3) then
		self:PayOut(ply, -self:Getprice() * 3)
		rp.Notify(ply, NOTIFY_ERROR, term.Get("SpinWheelPlayerLose"), self:Getprice() * 3)
	elseif(roll == 4) then
		self:PayOut(ply, self:Getprice() * 3)
		rp.Notify(ply, NOTIFY_SUCCESS, term.Get("SpinWheelPlayerWin"), self:Getprice() * 3)
	elseif(roll == 5) then
		self:PayOut(ply, -self:Getprice() * 4)
		rp.Notify(ply, NOTIFY_ERROR, term.Get("SpinWheelPlayerLose"), self:Getprice() * 4)
	elseif(roll == 6) then
		self:PayOut(ply, self:Getprice() * 4)
		rp.Notify(ply, NOTIFY_SUCCESS, term.Get("SpinWheelPlayerWin"), self:Getprice() * 4)
	elseif(roll == 7) then
		self:PayOut(ply, -self:Getprice() * 5)
		rp.Notify(ply, NOTIFY_ERROR, term.Get("SpinWheelPlayerLose"), self:Getprice() * 5)
	end
end
