ENT.Type 		= 'anim'
ENT.PrintName	= 'C4'
ENT.Author		= 'aStonedPenguin'
ENT.Spawnable 	= false

game.AddParticles 'particles/vman_explosion.pcf'

function ENT:Initialize()
	self:EmitSound('C4.Plant')
end
