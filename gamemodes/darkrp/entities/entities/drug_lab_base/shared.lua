ENT.Type 		= 'anim'
ENT.Base 		= 'base_rp'
ENT.PrintName 	= 'drug_lab_base'
ENT.Author 		= 'GmodHub'
ENT.Spawnable 	= false
ENT.Category 	= 'RP'
ENT.PressE 		= true

ENT.NetworkPlayerUse = true

ENT.LabType = 'UNKNOWN'
ENT.Model = 'models/props_c17/furniturewashingmachine001a.mdl' // logical

function ENT:SetupDataTables()
	self:NetworkVar('Int', 0, 'CraftTime')
	self:NetworkVar('Int', 1, 'CraftRate')
end

function ENT:GetPerc()
	local p = self:GetCraftTime() or CurTime()
	local r = self:GetCraftRate() or 60

	return math.Clamp(1 - (p - CurTime())/r, 0, 1)
end
