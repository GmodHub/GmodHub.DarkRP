ENT.Type 		= 'anim'
ENT.Base 		= 'base_rp'
ENT.PrintName 	= 'Microwave'
ENT.Author 		= 'aStonedPenguin'
ENT.Spawnable 	= false
ENT.PressE 		= true

ENT.MinPrice = 10
ENT.MaxPrice = 150

function ENT:SetupDataTables()
	self:NetworkVar('Int', 0, 'price')
	self:NetworkVar('Int', 1, 'ID')
end

function ENT:GetFoodName()
	return rp.Foods[self:GetID()].name
end

function ENT:GetFoodModel()
	return rp.Foods[self:GetID()].model
end
