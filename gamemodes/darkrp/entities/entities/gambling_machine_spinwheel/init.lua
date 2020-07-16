AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:CanUse(pl)
	if(self.ItemOwner == pl) then
		if(not self.ItemOwner:CanAfford(self:Getprice())) then
			self:SetInService(false)
			return false
		else
			return true
		end
	else
		if(pl:CanAfford(self:Getprice()) and self:GetInService()) then
			if(self.AgreedPlayers[pl:SteamID64()] ~= true) then
				rp.question.Create("Лотерея! Для учасния нужно " .. rp.FormatMoney(self:Getprice()) .. " вы готовы?", 15, tostring(self:GetClass() .. pl:SteamID()), function(pl, answer)
			    if tobool(answer) then
			    	self.AgreedPlayers[pl:SteamID64()] = true
			    end
	    		end, false, pl)
	    	else
	    		self:Play(pl)
			end
		else
			rp.Notify(pl, NOTIFY_ERROR, term.Get('GamblingMachinePlayerCannotAfford'))
		end
		return false
	end
end

--
-- Roll is between 0 and 7
-- 0 -> 5x
-- 1 -> -2x
-- 2 -> 2x
-- 3 -> -3x
-- 4 -> 3x
-- 5 -> -4x
-- 6 -> 4x
-- 7 -> -5x
--
function ENT:Play(ply)
	if(self:GetIsPayingOut()) then return end
	if(not self.ItemOwner:CanAfford(self:Getprice())) then
		rp.Notify(ply, NOTIFY_ERROR, term.Get("GamblingMachineHouseCannotAfford"))
		self:SetInService(false)
	end

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
		rp.Notify(ply, NOTIFY_ERROR, term.Get("SpinWheelPlayerLose"), self.Getprice() * 3)
	elseif(roll == 4) then
		self:PayOut(ply, self:Getprice() * 3)
		rp.Notify(ply, NOTIFY_SUCCESS, term.Get("SpinWheelPlayerWin"), self.Getprice() * 3)
	elseif(roll == 5) then
		self:PayOut(ply, -self:Getprice() * 4)
		rp.Notify(ply, NOTIFY_ERROR, term.Get("SpinWheelPlayerLose"), self.Getprice() * 4)
	elseif(roll == 6) then
		self:PayOut(ply, self:Getprice() * 4)
		rp.Notify(ply, NOTIFY_SUCCESS, term.Get("SpinWheelPlayerWin"), self.Getprice() * 4)
	elseif(roll == 7) then
		self:PayOut(ply, -self:Getprice() * 5)
		rp.Notify(ply, NOTIFY_ERROR, term.Get("SpinWheelPlayerLose"), self.Getprice() * 5)
	end
end
