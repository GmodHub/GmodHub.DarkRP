ENT.Type 		= 'anim'
ENT.Base 		= 'base_rp'
ENT.PrintName 	= 'Item Lab Base'
ENT.Author 		= 'KingofBeast'
ENT.Spawnable 	= false
ENT.Category 	= 'RP'
ENT.PressE 		= true
ENT.IsItemLab	= true

ENT.NetworkPlayerUse = true

ENT.MainModel = "models/props/cs_italy/it_mkt_table3.mdl"

function ENT:SetupDataTables()
	self:NetworkVar('Float', 0, 'CraftTime')
	self:NetworkVar("Int", 0, "Metal")
	self:NetworkVar("Int", 1, "CraftID")
end

function ENT:IsCrafting()
	return self:GetCraftTime() != 0
end

function ENT:GetCraftName()
	return "N/A"
end

function ENT:GetCraftables()
	return {}
end