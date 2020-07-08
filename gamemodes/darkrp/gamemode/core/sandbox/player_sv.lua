-- Accumulate limits
function GM:PlayerSpawnedRagdoll( pl, model, ent )
	pl:AddCount( "ragdolls", ent )
end

function GM:PlayerSpawnedProp( pl, model, ent )
	pl:AddCount( "props", ent )
	rp.Notify(pl, NOTIFY_GENERIC, term.Get("SboxSpawned"), pl:GetCount("props"), hook.Call("PlayerGetLimit",GAMEMODE, pl, "props"), "Props")
end

function GM:PlayerSpawnedEffect( pl, model, ent )
	pl:AddCount( "effects", ent )
end

function GM:PlayerSpawnedVehicle( pl, ent )
	pl:AddCount( "vehicles", ent )
end

function GM:PlayerSpawnedNPC( pl, ent )
	pl:AddCount( "npcs", ent )
end

function GM:PlayerSpawnedSENT( pl, ent )
	pl:AddCount( "sents", ent )
end

function GM:PlayerSpawnedSWEP( pl, ent )
	pl:AddCount( "sents", ent )
end

-- Numpad buttons
function GM:PlayerButtonDown( pl, btn )
	numpad.Activate( pl, btn )
end

function GM:PlayerButtonUp( pl, btn )
	numpad.Deactivate( pl, btn )
end
