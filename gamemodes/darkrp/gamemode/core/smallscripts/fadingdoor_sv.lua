local ent = FindMetaTable("Entity")
rp.fadingdoor = rp.fadingdoor or {}

function rp.fadingdoor.GetProps(pl)
    return pl.fadingdoor or {}
end

function rp.fadingdoor.ClearProps(pl)
    if pl.fadingdoor then
        for k,v in pairs(pl.fadingdoor) do
            if IsValid(v) then
                v:SetMaterial('')
                v:SetColor(color_white)
            end
        end
    end
    pl.fadingdoor = {}
end

function rp.fadingdoor.HasProp(pl, prop)
    pl.fadingdoor = pl.fadingdoor or {}
    return pl.fadingdoor[prop] or false
end

function rp.fadingdoor.RemoveProp(pl, prop)
    pl.fadingdoor[prop] = nil
    prop:SetMaterial('')
    prop:SetColor(color_white)

    pl:Notify(NOTIFY_GENERIC, term.Get('FadingDoorRemoved'))
end

function rp.fadingdoor.AddProp(pl, prop)
    pl.fadingdoor = pl.fadingdoor or {}
    table.insert(pl.fadingdoor, prop)
    prop:SetMaterial('models/debug/debugwhite')
    prop:SetColor(rp.col.Violet)

    pl:Notify(NOTIFY_SUCCESS, term.Get('FadingDoorAdded'))
end

function ent:IsFaded()
	return self.Faded
end

function ent:Fade()
	self.Faded = true
	self.FadedMaterial = self:GetMaterial()
	self.fCollision = self:GetCollisionGroup()
	
	
	self:SetMaterial("sprites/heatwave")
	self:DrawShadow(false)
	self:SetNotSolid(true)
	
	local obj = self:GetPhysicsObject()
	if (IsValid(obj)) then
		self.FadedMotion = obj:IsMoveable()
		obj:EnableMotion(false)
	end
end

function ent:UnFade()
	if (!self:IsValid()) then return end
	self.Faded = nil
	
	self:SetMaterial(self.FadedMaterial or "")
	self:DrawShadow(true)
	self:SetNotSolid(false)
	
	local obj = self:GetPhysicsObject()
	if (IsValid(obj)) then
		obj:EnableMotion(self.FadedMotion or false)
	end
end