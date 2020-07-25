dash.IncludeCL 'cl_init.lua'
dash.IncludeSH 'shared.lua'

function ENT:Initialize()
	self:SetModel('models/props_lab/bewaredog.mdl')
  	self:SetMaterial('models/debug/debugwhite')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
  	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

  	self:SetText1("GmodHub")
  	self:SetText2("Лучший Сервер")
  	self:SetText3("В Garry's mod")

end
