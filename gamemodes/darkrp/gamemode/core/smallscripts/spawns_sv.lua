//-----------------------------------------------------------------------------
// Old timer system was replaced by trigger ent
//-----------------------------------------------------------------------------

local spawns = rp.cfg.Spawns[game.GetMap()][1]

hook("InitPostEntity", "rp.SpawnProtection", function()

  for _,v in next, ents.FindByClass("base_brush") do if IsValid(v) and v.SpawnTrigger then v:Remove() end end -- There can only be one.

  local trigger = ents.Create("base_brush")
  trigger.Type = "brush"
  trigger.SpawnTrigger = true

  function trigger:Initialize()
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionBoundsWS(spawns[1], spawns[2])
  end

  function trigger:StartTouch(ent)
    if rp.cfg.SpawnDisallow[ent:GetClass()] then
      rp.Notify(ent.ItemOwner or ent:CPPIGetOwner(), NOTIFY_ERROR, term.Get("NotAllowedInSpawn"), ent:GetClass())
      ent:Remove()
    end
  end

  trigger:SetTrigger(true)

  trigger:Spawn()
  trigger:Activate()

end)

hook("PlayerSpawn", "rp.BabyGod", function(pl)
  pl.Babygod = true
  pl:GodEnable()

  timer.Create(pl:EntIndex() .. "babygod", 5, 1, function()
    pl.Babygod = nil
    pl:GodDisable()
  end)
end)
