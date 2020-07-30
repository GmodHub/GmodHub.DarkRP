dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

rp.fadingdoor = rp.fadingdoor or {}

function rp.fadingdoor.GetProps(pl)
    return pl.fadingdoor or {}
end

function rp.fadingdoor.ClearProps(pl)
    pl.fadingdoor = {}
end

function rp.fadingdoor.HasProp(pl, prop)
    pl.fadingdoor = pl.fadingdoor or {}
    return pl.fadingdoor[prop:EntIndex()] or false
end

function rp.fadingdoor.RemoveProp(pl, prop)
    pl.fadingdoor[prop:EntIndex()] = true
    pl.fadingdoor[prop:EntIndex()] = nil
    pl:Notify(NOTIFY_GENERIC, "Проп был отключён от fading door.")
end

function rp.fadingdoor.AddProp(pl, prop)
    pl.fadingdoor = pl.fadingdoor or {}
    pl.fadingdoor[prop:EntIndex()] = true
    pl:Notify(NOTIFY_SUCCESS, "Проп был подключён к fading door.")
end

function ENT:Initialize()
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )
end

function ENT:Use(ent, activator, caller, type, value)

end

function ENT:FadeProps()
	self:SetStatus(1)
end

function ENT:UnFadeProps()
	self:SetStatus(0)
end

function ENT:AddProp(prop)
	table.insert(self.Props, prop)
end
