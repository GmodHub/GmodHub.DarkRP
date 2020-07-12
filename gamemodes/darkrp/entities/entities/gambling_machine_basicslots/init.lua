AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.RemoveOnJobChange = true

function ENT:CanUse(pl)
	if(self.ItemOwner == pl) then
		if(not self.ItemOwner:CanAfford(self:Getprice())) then
			self:SetInService(false)
			return false
		else
			return true
		end
	else
		if(pl:CanAfford(self:Getprice())) then
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

function ENT:Initialize()
	self:SetModel("models/props/cs_office/computer.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()

	self:Setprice(500)
end

function ENT:Play(ply)
	if(self:GetIsPayingOut() or not self:GetInService()) then return end
	local roll1 = math.random(0, 9)
	local roll2 = math.random(0, 9)
	local roll3 = math.random(0, 9)

	self:SetRoll1(roll1)
	self:SetRoll2(roll2)
	self:SetRoll3(roll3)

	if((roll1 + roll2 + roll3) / 3 == roll1) then
		self:PayOut(ply, self:Getprice() * 10)
		rp.Notify(ply, NOTIFY_SUCCESS, term.Get('BasicSlotsPlayerWin'), self:Getprice() * 10)
	elseif(roll1 == roll2 or roll1 == roll3 or roll2 == roll3) then
		self:PayOut(ply, self:Getprice() * 4)
		rp.Notify(ply, NOTIFY_SUCCESS, term.Get('BasicSlotsPlayerWin'), self:Getprice() * 4)
	else
		self:PayOut(ply, -self:Getprice())
		rp.Notify(ply, NOTIFY_ERROR, term.Get('BasicSlotsPlayerLose'), self:Getprice())
	end
end