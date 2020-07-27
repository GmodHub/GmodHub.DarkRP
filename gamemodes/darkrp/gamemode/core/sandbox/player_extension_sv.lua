function PLAYER:CheckLimit(str)
	local c = hook.Call("PlayerGetLimit", GAMEMODE, self, str) or rp.GetLimit(str)
	if (c < 0) then return true end
	if (self:GetCount(str) >= c) then
		self:LimitHit(str)
		return false
	end
	return true
end

function PLAYER:GetLimit(name)
	local c = rp.GetLimit(name) or 0
	if (name == "props") then
		c = hook.Call("PlayerGetLimit", GAMEMODE, self, str) or 0
	end
	return c
end

function PLAYER:GetCount(str, minus)
	if (self._Counts and self._Counts[str]) then
		return self._Counts[str] - (minus or 0)
	end
	return 0
end

function PLAYER:AddCount(str, ent)
	if not self._Counts then
		self._Counts = {}
	end

	self._Counts[str] = (self._Counts[str] or 0) + 1

	ent.OnRemoveCount = function() --CallOnRemove is broke
		if IsValid(self) and self._Counts then
			self._Counts[str] = self._Counts[str] - 1
		end
	end
end

function PLAYER:LimitHit(str)
	rp.Notify(self, NOTIFY_ERROR, term.Get('SboxXLimit'), rp.GetLimit(str), str)
end

function PLAYER:AddCleanup(type, ent)
	cleanup.Add(self, type, ent)
end

function PLAYER:GetTool( mode )
	local wep = self:GetWeapon( 'gmod_tool' )
	if (!wep || !wep:IsValid()) then return nil end

	local tool = wep:GetToolObject( mode )
	if (!tool) then return nil end

	return tool
end

hook('EntityRemoved', function(ent)
	if ent.OnRemoveCount then ent.OnRemoveCount() end
end)
