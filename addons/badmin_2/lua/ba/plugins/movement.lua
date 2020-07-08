term.Add('AdminGoneTo', '# has gone to #.')
term.Add('AdminRoomUnset', 'The adminroom is not set!')
term.Add('AdminGoneToAdminRoom', '# has gone to the admin room.')
term.Add('AdminRoomSet', 'The adminroom has been set to your current position.')
term.Add('AdminReturnedSelf', '# has returned themself to spawn.')

-------------------------------------------------
-- Tele
-------------------------------------------------
ba.AddCommand('Tele', function(pl, targets)
	for k, v in ipairs(targets) do
		if (not v:Alive()) then
			v:Spawn()
		end

		if v:InVehicle() then
			v:ExitVehicle()
		end

		v:SetBVar('ReturnPos', v:GetPos())

		v:SetPos(util.FindEmptyPos(pl:GetEyeTrace().HitPos))

	end

	ba.notify_staff('# has teleported ' .. ('# '):rep(#targets) .. '.', pl, unpack(targets))
end)
:AddParam(cmd.PLAYER_ENTITY_MULTI)
:SetFlag 'M'
:SetHelp 'Teleports your target/s where you are looking'
:AddAlias 'tp'

-------------------------------------------------
-- Goto
-------------------------------------------------
ba.AddCommand('Goto', function(pl, target)
	if not pl:Alive() then
		pl:Spawn()
	end

	if pl:InVehicle() then
		pl:ExitVehicle()
	end

	pl:SetBVar('ReturnPos', pl:GetPos())

	local pos = util.FindEmptyPos(target:GetPos())

	pl:SetPos(pos)

	ba.notify_staff(term.Get('AdminGoneTo'), pl, target)
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'M'
:SetHelp 'Brings you to your target'

-------------------------------------------------
-- Sit
-------------------------------------------------
if (SERVER) then
	ba.adminRoom = ba.svar.Get('adminroom') and pon.decode(ba.svar.Get('adminroom'))[1]
	ba.svar.Create('adminroom', nil, false, function(svar, old_value, new_value)
		ba.adminRoom = pon.decode(new_value)[1]
	end)
end

ba.AddCommand('Sit', function(pl)
	if not ba.svar.Get('adminroom') then
		ba.notify_err(pl, term.Get('AdminRoomUnset'))
		return
	end

	if (not pl:Alive()) then
		pl:Spawn()
	end

	if pl:InVehicle() then
		pl:ExitVehicle()
	end

	pl:SetBVar('ReturnPos', pl:GetPos())

	local pos = util.FindEmptyPos(ba.adminRoom)

	pl:SetPos(pos)

	ba.notify_staff(term.Get('AdminGoneToAdminRoom'), pl)
end)
:SetFlag 'M'
:SetHelp 'Takes you to the admin room if one exists'

-------------------------------------------------
-- Set Admin Room
-------------------------------------------------
ba.AddCommand('SetAdminRoom', function(pl)
	ba.svar.Set('adminroom', pon.encode({pl:GetPos()}))
	ba.notify(pl, term.Get('AdminRoomSet'))
end)
:SetFlag '*'
:SetHelp 'Sets the adminroom to your current position'

-------------------------------------------------
-- Return
-------------------------------------------------
ba.AddCommand('return', function(pl, targets)
	if (targets == nil) then
		if (not pl:Alive()) then
			pl:Spawn()
		end

		if pl:InVehicle() then
			pl:ExitVehicle()
		end

		local _, pos = hook.Run('PlayerSelectSpawn', pl)
		pl:SetPos(pos)

		return ba.NOTIFY_STAFF, term.Get('AdminReturnedSelf'), pl
	end

	for k, v in ipairs(targets) do
		if (not v:Alive()) then
			v:Spawn()
		end

		if v:InVehicle() then
			v:ExitVehicle()
		end

		local _, pos = hook.Run('PlayerSelectSpawn', v)
		v:SetPos(pos)
	end

	ba.notify_staff('# has returned ' .. ('# '):rep(#targets) .. 'to spawn.', pl, unpack(targets))
end)
:AddParam(cmd.PLAYER_ENTITY_MULTI, cmd.OPT_OPTIONAL)
:SetFlag 'M'
:SetHelp 'Returns you or your tragets to spawn'

-------------------------------------------------
-- Freeze
-------------------------------------------------
term.Add('AdminFrozePlayer', '# has froze #.')
term.Add('AdminUnfrozePlayer', '# has unfroze #.')
term.Add('PlayerIsFrozen', '# is already frozen!')
term.Add('PlayerIsNotFrozen', '# is not frozen!')

if (SERVER) then
	function PLAYER:IsAdminFrozen() -- only use where it matters if an admin did it
		return (self:GetBVar('IsAdminFrozen') == true) and self:IsFrozen()
	end

	PLAYER._Freeze = PLAYER._Freeze or PLAYER.Freeze
	function PLAYER:Freeze(frozen)
		if (not frozen) then
			if self:GetBVar('PreFrozenMoveType') then
				self:SetMoveType(self:GetBVar('PreFrozenMoveType'))
				self:SetBVar('PreFrozenMoveType', nil)
			end

			if self:GetBVar('IsAdminFrozen') then
				self:SetBVar('IsAdminFrozen', nil)
			end
		end

		return self:_Freeze(frozen)
	end

	function PLAYER:AdminFreeze(pl)
		if (not self:Alive()) then
			self:Spawn()
		end

		if self:InVehicle() then
			self:ExitVehicle()
		end

		if (not self:IsFrozen()) then
			self:SetBVar('PreFrozenMoveType', self:GetMoveType())

			self:Freeze(true)
			self:SetMoveType(MOVETYPE_NOCLIP)
			self:SetBVar('IsAdminFrozen', true)

			ba.notify_staff(term.Get('AdminFrozePlayer'), pl, self)
		else
			ba.notify_err(pl, term.Get('PlayerIsFrozen'), self)
		end
	end

	function PLAYER:AdminUnFreeze(pl)
		if (not self:Alive()) then
			self:Spawn()
		end

		if self:IsFrozen() then
			self:Freeze(false)

			ba.notify_staff(term.Get('AdminUnfrozePlayer'), pl, self)
		else
			ba.notify_err(pl, term.Get('PlayerIsNotFrozen'), self)
		end
	end

	hook.Add('PhysgunPickup', 'ba.PhysgunPickup.PlayerPhysgun', function(pl, ent)
		if isplayer(ent) and pl:HasAccess('a') and ba.ranks.CanTarget(pl, ent) and ba.canAdmin(pl) then
			pl:SetBVar('HoldingPlayer', ent)

			if (not ent:IsAdminFrozen()) then
				ent:SetMoveType(MOVETYPE_NOCLIP)
				ent:Freeze(true)
			end

			return true
		end
	end)

	hook.Add('PhysgunDrop', 'ba.PhysgunDrop.PlayerPhysgun', function(pl, ent)
		if isplayer(ent) then
			if (not ent:IsAdminFrozen()) then
				ent:SetMoveType(MOVETYPE_WALK)
				ent:Freeze(false)
			end

			local hookId = 'ba.KeyRelease.PlayerPhysgun' .. pl:SteamID() .. ent:SteamID()
			hook.Add('KeyRelease', hookId, function(pl2, key)
				local holdingPlayer = pl:GetBVar('HoldingPlayer')

				if (pl == pl2) and (key == IN_ATTACK2) and IsValid(holdingPlayer) and IsValid(ent) and (holdingPlayer == ent) then
					if ent:IsAdminFrozen() then
						ent:AdminUnFreeze(pl)
					else
						ent:AdminFreeze(pl)
					end

					hook.Remove('KeyRelease', hookId)
				end
			end)

			timer.Simple(1, function()
				hook.Remove('KeyRelease', hookId)
			end)
		end
	end)
end

ba.AddCommand('Freeze', function(pl, targ)
	targ:AdminFreeze(pl)
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'M'
:SetHelp 'Freezes your target'

ba.AddCommand('UnFreeze', function(pl, targ)
	targ:AdminUnFreeze(pl)
end)
:AddParam(cmd.PLAYER_ENTITY)
:SetFlag 'M'
:SetHelp 'Unfreezes your target'


-------------------------------------------------
-- Noclip
-------------------------------------------------
hook.Add('PlayerNoClip', 'ba.PlayerNoClip', function(pl)
	if (SERVER) and pl:HasAccess('a') then
		return (ba.canAdmin(pl) and (pl:GetBVar('CanNoclip') ~= false) or false)
	elseif (CLIENT) then
		return false
	end
end)
