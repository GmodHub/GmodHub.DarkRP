ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Cheque"
ENT.Author = "Eusion"
ENT.Spawnable = false
ENT.PressE 		= true

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "owning_ent")
	self:NetworkVar("Entity", 1, "recipient")
	self:NetworkVar("Int", 0, "amount")
end