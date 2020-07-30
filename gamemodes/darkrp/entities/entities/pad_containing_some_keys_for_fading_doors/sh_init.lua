ENT.Type			= "anim"
ENT.Base			= "base_rp"

ENT.PrintName		= "Keys On A Pad"
ENT.Author			= "KingofBeast"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false -- Spawned via STool

ENT.Status_None = 0
ENT.Status_Granted = 1
ENT.Status_Denied = 2

ENT.Command_Enter = 0
ENT.Command_Reset = 1
ENT.Command_Accept = 2

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Status")
	self:NetworkVar("Int", 1, "NumStars")
	self:NetworkVar("Bool", 0, "FaceID")
	self:NetworkVar("Bool", 1, "FaceIDEnabled")
end

function ENT:CanHack()
	return true
end