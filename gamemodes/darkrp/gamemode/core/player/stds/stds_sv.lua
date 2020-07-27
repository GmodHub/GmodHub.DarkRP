local TargetVoices = {
	"vo/npc/male01/moan04.wav",
	"vo/npc/male01/moan05.wav"
}

function PLAYER:GiveSTD(std)
	if !IsValid(self) then return end
  	self:SetNetVar("STD", std)

	self:Timer("PlayerHasSTD", 1.5, 0, function()
		self:SetHealth(self:Health() - 2)
		self:EmitSound(table.Random(TargetVoices), 300, 80)
		if self:Health() <= 0 then
			self:Kill()
			self.CurrentDeathReason = 'STD'
			self:DestroyTimer("PlayerHasSTD")
		end
	end)
end

function PLAYER:CureSTD()
	if !IsValid(self) then return end
	self:SetNetVar("STD", nil)
	self:DestroyTimer("PlayerHasSTD")
end
