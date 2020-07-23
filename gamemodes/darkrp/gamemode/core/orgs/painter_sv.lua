util.AddNetworkString('rp.SetOrgBanner')
util.AddNetworkString('rp.OrgBannerRaw')
util.AddNetworkString('rp.OrgBannerReceived')
util.AddNetworkString('rp.OrgBannerInvalidate')

local db = rp._Stats

net('rp.OrgBannerRaw', function(len, pl)
    if not pl:GetOrg() or not pl:HasOrgPerm('Banner') then return end
    if (not pl:IsOrgUpg()) then
        net.Start('rp.OrgBannerRaw')
          net.WriteBool(false)
        net.Send(pl)
        return
    end

    db:Query('SELECT * FROM orgs WHERE UID = ?;', pl:GetOrgUID(), function(data)
        if data[1] and data[1].BannerData != '' then
          local banner = util.JSONToTable(data[1].BannerData)

          net.Start('rp.OrgBannerRaw')
            net.WriteBool(true)
            net.WriteUInt(#banner, 7)
        		for i=0,#banner do
        			for k=0,#banner do
        				net.WriteBool(banner[i][k].trans)
        				if (!banner[i][k].trans) then
                  local col = Color(banner[i][k].col.r, banner[i][k].col.g, banner[i][k].col.b, banner[i][k].col.a)
        					net.WriteUInt(col:ToEncodedRGB(), 24)
        				end
        			end
        		end
          net.Send(pl)
        else
          net.Start('rp.OrgBannerRaw')
            net.WriteBool(false)
          net.Send(pl)
        end
    end)
end)

net('rp.SetOrgBanner', function(len, pl)
    if not pl:GetOrg() or not pl:HasOrgPerm('Banner') then return end
	if (!pl:IsOrgUpg()) then return end

	local data = {}
	local dim = net.ReadUInt(7)

	for i=0, dim do
		data[i] = {}

		for k=0, dim do
			local px = net.ReadBool() and -1 or nil
			if (!px) then
				px = net.ReadUInt(24)
			end

			data[i][k] = px
		end

	end

	for k = 0, 63 do
		for i = 0, 63 do
			if (data[k][i] == -1) then -- trans
				data[k][i] = {trans = true}
			else
				local col = Color()
				col:SetEncodedRGBA(data[k][i])

				data[k][i] = {col = col}
			end
		end
	end

	local dataJson = util.TableToJSON(data)
	net.Start('rp.OrgBannerReceived')
	net.Send(pl)

	rp.Notify(pl, NOTIFY_GREEN, term.Get('OrgBannerUpdated'))

	net.Start('rp.OrgBannerRaw')
		net.WriteBool(true)
		net.WriteUInt(#data, 7)
		for i=0,#data do
			for k=0,#data do
				net.WriteBool(data[i][k].trans)
				if (!data[i][k].trans) then
					net.WriteUInt(data[i][k].col:ToEncodedRGB(), 24)
				end
			end
		end
	net.Send(pl)

	db:Query('UPDATE orgs SET BannerData=? WHERE UID=?;', dataJson, pl:GetOrgUID(), function()

		net.Start('rp.OrgBannerInvalidate')
			net.WriteString(pl:GetOrg())
		net.Broadcast()
        rp.orgs.Log(pl:GetOrgUID(), "изменил логотип банды", pl)

	end)
end)
