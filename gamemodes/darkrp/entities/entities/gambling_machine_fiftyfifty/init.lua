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
				rp.question.Create("Лотерея! Для учасния нужно " .. rp.FormatMoney(self:Getprice()) .. " вы готовы?", 15, tostring(self:GetClass() + pl:SteamID()), function(pl, answer)
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

function ENT:Play(ply)
	if(self:GetIsPayingOut()) then return end
	if(not self.ItemOwner:CanAfford(self:Getprice())) then
		rp.Notify(ply, NOTIFY_ERROR, term.Get("GamblingMachineHouseCannotAfford"))
		self:SetInService(false)
	end

	self:SetPlayerRoll(math.random(0, 100))
	self:SetHouseRoll(math.random(0, 100))

	if(self:GetPlayerRoll() < self:GetHouseRoll()) then
		self:PayOut(ply, -self:Getprice())
		rp.Notify(ply, NOTIFY_ERROR, term.Get("5050PlayerLose"), self:Getprice())
	elseif(self:GetPlayerRoll() > self:GetHouseRoll()) then
		self:PayOut(ply, self:Getprice())
		rp.Notify(ply, NOTIFY_SUCCESS, term.Get("5050PlayerWin"), self:Getprice())
	elseif(self:GetPlayerRoll() == self:GetHouseRoll()) then
		rp.Notify(ply, NOTIFY_SUCCESS, term.Get("5050Tie"), self:Getprice())
	end
end