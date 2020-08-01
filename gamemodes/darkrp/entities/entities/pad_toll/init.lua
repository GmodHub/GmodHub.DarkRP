dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

ENT.PayedPlayer = {}

function ENT:Initialize()
    self:SetModel("models/maxofs2d/button_04.mdl")
    self:SetUseType( SIMPLE_USE )

    self.BaseClass.Initialize(self)
end

function ENT:PlayerUse(pl)
    if self:CPPIGetOwner() ~= pl and not pl:CanAfford(self:Getprice()) then
        pl:Notify(NOTIFY_ERROR, term.Get('CannotAfford'))
        self:InValidUse()
        return true
    end

    if (self.ItemOwner ~= pl) then
        if not self:GetOneTimeUse() and not table.HasValue(self.PayedPlayer, pl) then
            rp.question.Create('Желаете использовать этот toll за ' .. self:Getprice() .. '?', 15, ent:EntIndex() .. "" .. pl:SteamID64(), function(pl, answer)
                if (answer) then
                    pl:TakeMoney(self:Getprice())
                    self.ItemOwner:AddMoney(self:Getprice() * 0.9)
                    self.ItemOwner:Notify(NOTIFY_SUCCESS, term.Get('TollMadeProfit'), self:Getprice() * 0.9, self:Getprice() * 0.1)
                end
	        end, nil, pl)

            table.insert(self.PayedPlayer, pl)
        elseif self:GetOneTimeUse() then
            rp.question.Create('Желаете использовать этот toll за ' .. self:Getprice() .. '?', 15, ent:EntIndex() .. "" .. pl:SteamID64(), function(pl, answer)
                if (answer) then
                    pl:TakeMoney(self:Getprice())
                    self.ItemOwner:AddMoney(self:Getprice() * 0.9)
                    self.ItemOwner:Notify(NOTIFY_SUCCESS, term.Get('TollMadeProfit'), self:Getprice() * 0.9, self:Getprice() * 0.1)
                end
	        end, nil, pl)

        end
    end

    self:ValidUse()
end

function ENT:CanHack()
	return true
end

function ENT:Hack(ply)
    self:ValidUse()
end
