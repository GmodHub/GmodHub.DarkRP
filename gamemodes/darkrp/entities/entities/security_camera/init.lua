dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

function ENT:Initialize()
    self:SetModel('models/dav0r/camera.mdl')
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:DrawShadow(false)
    local phys = self:GetPhysicsObject()

    if (phys:IsValid()) then
    	phys:Sleep()
    end
end
