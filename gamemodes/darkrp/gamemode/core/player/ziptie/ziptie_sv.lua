function PLAYER:Ziptie()
    self:Give("weapon_ziptied")
    self:SelectWeapon("weapon_ziptied")
    self.ZiptieTime = CurTime()
    self:SetNetVar('Ziptied', true)
end

function PLAYER:UnZiptie()
    self:SetNetVar('Ziptied', false)
    self:StripWeapon("weapon_ziptied")
end

function PLAYER:StartCarrying(pl)
    //self:SetNetVar('Ziptied', true)
end

function PLAYER:StopCarrying()
    //self:SetNetVar('Ziptied', true)
end

hook('PlayerSwitchWeapon', 'rp.Zipties.PlayerSwitchWeapon', function(pl, oldWep, newWep)
	if pl:IsZiptied() then
		return true
	end
end)

hook( "PlayerDeath", "rp.Zipties.PlayerDeath", function( pl )
    if pl:IsZiptied() then
        pl:UnZiptie()
    end
end)


hook.Add( "KeyPress", "rp.Zipties.Free", function( pl, key )
	if ( key == IN_USE ) then
        local ent = pl:GetEyeTrace().Entity

        if IsValid(ent) and isplayer(ent) and ent:IsZiptied() then
            ent:UnZiptie()
            //if (not pl:GetStruggle("UnZiptie")) then
            //    pl:StartStruggle("UnZiptie")
            //end
        end
	end
end )
