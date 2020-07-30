hook.Add("InitPostEntity", "rp.MapProps", function()
	for k, v in pairs(rp.cfg.Props[game.GetMap()]) do
		local prop = ents.Create('prop_physics')
		prop:SetPos(v.Pos)
		prop:SetAngles(v.Ang)
		prop:Spawn()
		prop:Activate()
		prop:SetModel(v.Model)
        prop:GetPhysicsObject():EnableMotion(false)
	end
end)
