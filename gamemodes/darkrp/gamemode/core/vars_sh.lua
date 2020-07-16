-- Global vars
nw.Register 'TheLaws'
	:Write(net.WriteString)
	:Read(net.ReadString)
	:SetGlobal()

nw.Register 'lockdown'
	:Write(net.WriteUInt, 32)
	:Read(net.ReadUInt, 32)
	:SetGlobal()

nw.Register 'mayorGrace'
	:Write(net.WriteUInt, 32)
	:Read(net.ReadUInt, 32)
	:SetGlobal()

nw.Register 'JeromePrice'
	:Write(net.WriteFloat)
	:Read(net.ReadFloat)
	:SetGlobal()

nw.Register 'SashaPrice'
	:Write(net.WriteFloat)
	:Read(net.ReadFloat)
	:SetGlobal()

-- Player Vars
nw.Register 'HasGunlicense'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetPlayer()

nw.Register 'Name'
	:Write(net.WriteString)
	:Read(net.ReadString)
	:SetPlayer()

nw.Register 'Money'
	:Write(net.WriteInt, 32)
	:Read(net.ReadInt, 32)
	:SetLocalPlayer()

nw.Register 'Karma'
	:Write(net.WriteInt, 32)
	:Read(net.ReadInt, 32)
	:SetLocalPlayer()

nw.Register 'Energy'
	:Write(net.WriteUInt, 32)
	:Read(net.ReadUInt, 32)
	:SetLocalPlayer()

nw.Register 'job'
	:Write(net.WriteString)
	:Read(net.ReadString)
	:SetPlayer()

nw.Register 'Skills'
	:Write(function(v)
		net.WriteUInt(table.Count(v), 4)
		for k, v in pairs(v) do
			net.WriteUInt(k, 4)
			net.WriteUInt(v, 4)
		end
	end)
	:Read(function()
		local tbl 	= {}
		for i = 1, net.ReadUInt(4) do
			tbl[net.ReadUInt(4)] = net.ReadUInt(4)
		end
		return tbl
	end)
	:SetLocalPlayer()
// We don't use them
/*
nw.Register 'ActiveApparel'
	:Write(function(v)
		for i = 1, 4 do
			local isSet = (v[i] ~= nil)
			net.WriteBool(isSet)
			if isSet then
				net.WriteString(v[i])
			end
		end
	end)
	:Read(function()
		local tbl = {}
		for i = 1, 4 do
			if net.ReadBool() then
				tbl[i] = net.ReadString()
			end
		end
		return tbl
	end)
	:SetPlayer()

nw.Register 'OwnedApparel'
	:Write(function(v)
		net.WriteUInt(table.Count(v), 6)
		for k, v in pairs(v) do
			net.WriteString(k)
		end
	end)
	:Read(function()
		local tbl 	= {}
		for i = 1, net.ReadUInt(6) do
			tbl[net.ReadString()] = true
		end
		return tbl
	end)
	:SetLocalPlayer()
*/

nw.Register 'EmployeePrice'
	:Write(net.WriteUInt, 32)
	:Read(net.ReadUInt, 32)
	:SetPlayer()

nw.Register 'Employees'
	:Write(function(v)
		net.WriteUInt(#v, 8)
		for k, v in ipairs(v) do
			net.WritePlayer(v)
		end
	end)
	:Read(function()
		local tbl 	= {}
		for i = 1, net.ReadUInt(8) do
			tbl[#tbl + 1] = net.ReadPlayer()
		end
		return tbl
	end)
	:SetLocalPlayer()

nw.Register 'Employer'
	:Write(net.WritePlayer)
	:Read(net.ReadPlayer)
	:SetPlayer()

nw.Register 'DisguiseTeam'
	:Write(net.WriteUInt, 6)
	:Read(net.ReadUInt, 6)
	:SetPlayer()

nw.Register 'ShareProps'
	:Write(function(tab)
		net.WriteUInt(table.Count(tab), 8)
		for k, v in pairs(tab) do
			net.WriteString(k)
		end
	end)
	:Read(function()
		local tab = {}
		for i = 1, net.ReadUInt(8) do
			tab[net.ReadString()] = true
		end
		return tab
	end)
	:SetLocalPlayer()

nw.Register 'OrgShareProps'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetLocalPlayer()

nw.Register 'IsWanted'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetPlayer()

nw.Register '911CallReason'
	:Write(net.WriteString)
	:Read(net.ReadString)
	:SetPlayer()

nw.Register 'WantedInfo'
	:Write(function(v)
		net.WriteString(v.Reason)
		net.WriteUInt(v.Time, 32)
	end)
	:Read(function()
		return {
			Reason = net.ReadString(),
			Time = net.ReadUInt(32)
		}
	end)
	:SetLocalPlayer()

nw.Register 'ArrestedInfo'
	:Write(function(v)
		net.WriteString(v.Reason)
		net.WriteUInt(v.ReleaseTime, 32)
	end)
	:Read(function()
		return {
			Reason 		= net.ReadString(),
			ReleaseTime = net.ReadUInt(32)
		}
	end)
	:SetLocalPlayer()

nw.Register 'IsArrested'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetPlayer()

nw.Register 'STD'
	:Write(net.WriteString)
	:Read(net.ReadString)
	:SetPlayer()

nw.Register 'Credits'
	:Write(net.WriteInt, 32)
	:Read(net.ReadInt, 32)
	:SetLocalPlayer()

// We don't use them
/*
nw.Register 'Outfits'
	:Write(function(v)
		net.WriteUInt(#v, 8)
		for k, f in ipairs(v) do
			net.WriteUInt(rp.Clothes[f].ID, 8)
		end
	end)
	:Read(function()
		local ret = {}
		for i = 1, net.ReadUInt(8) do
			ret[rp.ClothesMap[net.ReadUInt(8)]] = true
		end
		return ret
	end)
	:SetLocalPlayer()

nw.Register 'Outfit'
	:Write(net.WriteUInt, 6)
	:Read(net.ReadUInt, 6)
	:SetPlayer()
*/

nw.Register 'HasInitSpawn'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetLocalPlayer()

nw.Register 'RespawnTime'
	:Write(net.WriteFloat)
	:Read(net.ReadFloat)
	:SetLocalPlayer()

nw.Register 'DoorID'
	:Write(net.WriteUInt, 32)
	:Read(net.ReadUInt, 32)

nw.Register 'HideNameTag'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetPlayer()

nw.Register 'BloodStacks'
	:Write(net.WriteUInt, 5)
	:Read(net.ReadUInt, 5)
	:SetLocalPlayer()

nw.Register 'BodyGroups'
	:Write(net.WriteUInt, 1)
	:Read(net.ReadUInt, 1)
	:SetPlayer()
	:SetHook('BodyGroupsChanged')
/*
nw.Register 'Ziptied'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetPlayer()
	:SetHook('ZiptieStatusChanged')

nw.Register 'ZiptieCarrying'
	:Write(function(arg)
		net.WriteUInt(arg:EntIndex(), 8)
	end)
	:Read(net.ReadUInt, 8)
	:SetPlayer()

nw.Register 'ZiptieCarrier'
	:Write(function(arg)
		net.WriteUInt(arg:EntIndex(), 8)
	end)
	:Read(net.ReadUInt, 8)
	:SetPlayer()
	:SetHook('ZiptieCarrierChanged')

nw.Register 'ZiptieCutting'
	:Write(net.WriteFloat)
	:Read(net.ReadFloat)
	:SetLocalPlayer()
