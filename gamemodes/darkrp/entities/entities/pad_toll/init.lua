dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

function ENT:Initialize()
    self:SetModel("models/maxofs2d/button_04.mdl")
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )
end

function ENT:PlayerUse(pl)
    if(not pl:CanAfford(self:Getprice())) then return end

    if(self:GetOneTimeUse()) then
        if(not self:IsPropsFaded()) then
            self:FadeProps()
            if(self.ItemOwner ~= pl) then
                pl:AddMoney(-self:Getprice())
            end
        end
    else
        self:FadeProps()
        timer.Simple(self:GetHoldLength(), function()
            if(not IsValid(self)) then return end
            self:UnFadeProps()
        end)
        if(self.ItemOwner ~= pl) then
            pl:AddMoney(-self:Getprice())
        end
    end
end

function ENT:CanHack()
	return true
end

function ENT:Hack(ply)
    if(self:GetOneTimeUse()) then
        if(not self:IsPropsFaded()) then
            self:FadeProps()
        end
    else
        self:FadeProps()
        timer.Simple(self:GetHoldLength(), function()
            if(not IsValid(self)) then return end
            self:UnFadeProps()
        end)
    end
end
