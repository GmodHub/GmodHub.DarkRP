rp.bodygroups = {}
rp.bodygroups.Presets = {
	--["models/mark2580/borderlands2/maya_siren_player.mdl"] = {

	--},
	["models/auditor/com/honoka/honoka.mdl"] = { -- Smashy, AI Org (id 2588)
		CheckBodyGroupCountOn = 2,
		Presets = {
			[0] = {
				Name = 'default',
				BodyGroups = {
					[2] = 0
				}
			},
			[1] = {
				Name = 'bikini',
				BodyGroups = {
					[2] = 1
				}
			}
		},
	}
}

rp.AddCommand('bg', function(pl, grp)
	local split = string.Explode(' ', grp)

	local grp = split[1]:lower()
	local targName = split[2] and table.concat(split, ' ', 2)

	local targ = (targName and player.Find(targName)) or (!targName and pl)
	if (!IsValid(targ)) then
		if (targName) then
			return NOTIFY_ERROR, term.Get(cmd.ERROR_INVALID_PLAYER), targName
		else
			return NOTIFY_ERROR, term.Get('UnknownError')
		end
	end

	local inf = rp.bodygroups.Presets[targ:GetModel()]
	if (!inf) then
		return NOTIFY_ERROR, term.Get('ModelNoBodyGroups')
	end

	if (!pl:IsRoot()) then
		return NOTIFY_ERROR, term.Get('BodyGroupPermission')
	end

	grp = string.lower(grp)
	local grpSet
	for k, v in pairs(inf.Presets) do
		if (v.Name == grp) then
			grpSet = k
			break
		end
	end

	if (!grpSet) then
		return NOTIFY_ERROR, term.Get('BodyGroupNotFound'), grp
	end

	targ:SetNetVar('BodyGroups', grpSet)
	return NOTIFY_GENERIC, term.Get('BodyGroupSet'), grp
end)
:AddParam(cmd.STRING)

if (SERVER) then
	hook('OnPlayerChangedTeam', function(pl, curTeam, newTeam)
		if (pl:GetNetVar('BodyGroups') ~= nil) then
			pl:SetNetVar('BodyGroups', nil)
		end
	end)
else
	local function renderBodyGroup(pl, bgrp)
		if (not IsValid(pl)) then return end

		bgrp = bgrp or pl:GetNetVar('BodyGroups') or 0

		local inf = rp.bodygroups.Presets[pl:GetModel()]
		if (not inf) or (not inf.Presets[bgrp]) then return end

		if (inf.CheckBodyGroupCountOn) then
			if (pl:GetBodygroupCount(inf.CheckBodyGroupCountOn) <= 1) then
				return
			end
		end

		for k, v in pairs(inf.Presets[bgrp].BodyGroups) do
			if (pl:GetBodygroup(k) ~= v) then
				pl:SetBodygroup(k, v)
			end
		end
	end

	hook('PrePlayerDraw', renderBodyGroup)
	--hook('BodyGroupsChanged', renderBodyGroup)
	hook('PreRender', function()
		renderBodyGroup(LocalPlayer())
	end)
end
