local TargetVoices = {
	"vo/npc/male01/moan04.wav",
	"vo/npc/male01/moan05.wav"
}

function PLAYER:GiveSTD(std)
	if !IsValid(self) then return end
  self:SetNetVar("STD", std)

	self:Timer("PlayerHasSTD", 1.5, 0, function()
		self:SetHealth(self:Health() - 5)
		self:EmitSound(table.Random(TargetVoices), 500, 100)
		if self:Health() <= 0 then
			self:Kill()
			self:DestroyTimer("PlayerHasSTD")
		end
	end)
end

function PLAYER:CureSTD()
	if !IsValid(self) then return end
	self:DestroyTimer("PlayerHasSTD")
end
