dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

function ENT:PlayerUse(pl)
	if(not self.ItemOwner) then return end
	if(not IsValid(self)) then return end

	if not pl:CanAfford(self:Getprice() * 5) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('GamblingMachinePlayerCannotAfford'), self.PrintName)
		return
	end

	if not self.ItemOwner:CanAfford(self:Getprice() * 5) then
		rp.Notify(self.ItemOwner, NOTIFY_ERROR, term.Get('GamblingMachineHouseCannotAfford'), self.PrintName)
		rp.Notify(pl, NOTIFY_ERROR, term.Get('GamblingMachineOwnerCannotAfford'), self.PrintName)
		self:SetInService(false)
		return
	end

	if(self.AgreedPlayers[pl:SteamID64()] ~= true) then
		rp.question.Create("Вы желаете сыграть в казино ".. self.PrintName .." за " .. rp.FormatMoney(self:Getprice()) .. "?", 15, tostring(self:GetClass() .. pl:SteamID()), function(pl, answer)
		    if tobool(answer) then
		    	self.AgreedPlayers[pl:SteamID64()] = true
		    end
		end, false, pl)
	else
		self:Play(pl)
	end
end

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
