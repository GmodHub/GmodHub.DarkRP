AddCSLuaFile 'shared.lua'
AddCSLuaFile 'cl_init.lua'
include 'shared.lua'

util.AddNetworkString 'rp.MediaMenu'

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)

	self:SetUseType(SIMPLE_USE)
	
	if IsValid(self.ItemOwner) then
		self:CPPISetOwner(self.ItemOwner)
	end
end

function ENT:PlayerUse(pl)
	net.Start 'rp.MediaMenu'
		net.WriteEntity(self)
	net.Send(pl)
end

rp.AddCommand('playsong', function(pl, text, args)
	if (!args[2] or !args[1] or tostring(tonumber(args[1])) != args[1]) then return end
	
	local ent = Entity(tonumber(args[1]))
	local url = args[2]

	if (not IsValid(ent)) or (not ent:CanUse(pl)) or (not url) or (pl:GetPos():Distance(ent:GetPos()) > 100) then return end

	if (url == '') then
		ent:SetURL('')
	else
		local service = medialib.load('media').guessService(url)

		if (not service) then
			pl:Notify(NOTIFY_ERROR, rp.Term('InvalidURL'))
		else
			service:query(url, function(err, data)
				if err then
					pl:Notify(NOTIFY_ERROR, rp.Term('VideoFailed'), err)
				else
					ent:SetURL(url)
					ent:SetTitle(data.title)
					ent:SetTime(data.duration or 0)
					ent:SetStart(CurTime())
				end
			end)
		end
	end
end)