-- Modified notification.AddLegacy
cvar.Register 'notification_sound'
	:SetDefault(true, true)
	:AddMetadata('Menu', 'Включить звук "капли" для уведомлений')

notification = {}

local function m(m)
	return Material(m, 'smooth')
end

local notifyTypes 	= {
	[NOTIFY_GENERIC]	= {
		Color = Color(51,128,255),
		Icon = m 'gmh/ui/notifications/info.png'
	},
	[NOTIFY_ERROR]	= {
		Color = Color(225,0,0),
		Icon = m 'gmh/ui/notifications/error.png'
	},
	[NOTIFY_UNDO]	= {
		Color = Color(255, 140, 0),
		Icon = m 'gmh/ui/notifications/undo.png',
	},
	[NOTIFY_SUCCESS]	= {
		Color = Color(0,180,50),
		Icon = m 'gmh/ui/notifications/info.png'
	},
	[NOTIFY_HINT]	= {
		Color = Color(51,128,255),
		Icon = m 'gmh/ui/notifications/hint.png'
	}
}

for k, v in pairs(notifyTypes) do
	v.BarColor = v.Color:Copy()
	v.BarColor.a = 25
end

local Notices = {}

function notification.AddProgress(uid, text) end

function notification.Kill(uid)
	if IsValid(Notices[uid]) then
		Notices[uid].StartTime 	= SysTime()
		Notices[uid].Length 	= 0.8
	end
end

function notification.AddLegacy(text, type, length)
	type = math.Clamp(type or 0, 0, 4)
	text = tostring(text):Trim()
	if (text:sub(1,1) == '#') then
		text = language.GetPhrase(text)
	end

	local parent
	if GetOverlayPanel then parent = GetOverlayPanel() end

	table.insert(Notices, ui.Create('NoticePanel', function(self, p)
		self.NotifyType 	= type
		self.StartTime 	= SysTime()
		self.Length 		= length
		self.VelX			= 0
		self.VelY			= 0
		self.fx 			= ScrW() + 200
		self.fy 			= ScrH()
		self:SetText(text)
		self:SetPos(self.fx, self.fy)
		self:SetMouseInputEnabled(false)
	end, parent))

	MsgC(ui.col.White, '[', notifyTypes[type].Color, 'Notification', ui.col.White, '] ', ui.col.White, text .. '\n')

	if (cvar.GetValue("notification_sound")) then
		surface.PlaySound('ambient/water/drip4.wav')
	end
end

-- This is ugly because it's ripped straight from the old notice system
local function UpdateNotice(number, panel, count)
	local x = panel.fx
	local y = panel.fy

	local w = panel:GetWide() + 16
	local h = panel:GetTall() + 16

	local ideal_y = ScrH() - (count - number) * (h - 12) - 150
	local ideal_x = ScrW() - w - 20

	local timeleft = panel.StartTime - (SysTime() - panel.Length)

	if (timeleft < 0.2) then
		ideal_x = ideal_x + w * 2
	end

	local spd = FrameTime() * 15

	y = y + panel.VelY * spd
	x = x + panel.VelX * spd

	local dist = ideal_y - y
	panel.VelY = panel.VelY + dist * spd * 1
	if (math.abs(dist) < 2 && math.abs(panel.VelY) < 0.1) then panel.VelY = 0 end
	local dist = ideal_x - x
	panel.VelX = panel.VelX + dist * spd * 1
	if (math.abs(dist) < 2 && math.abs(panel.VelX) < 0.1) then panel.VelX = 0 end


	panel.VelX = panel.VelX * (0.9 - FrameTime() * 8)
	panel.VelY = panel.VelY * (0.9 - FrameTime() * 8)

	panel.fx = x
	panel.fy = y
	panel:SetPos(panel.fx, panel.fy)
end

hook.Add('Think', 'NotificationThink', function()
	for k, v in ipairs(Notices) do
		UpdateNotice(k, v, #Notices)
		if IsValid(v) and v:KillSelf() then
			table.remove(Notices, k)
		end
	end
end)


local PANEL = {}

function PANEL:Init()
	self.NotifyType = NOTIFY_GENERIC

	self.Label = ui.Create('DLabel', self)
	self.Label:SetFont('ui.22')
	self.Label:SetTextColor(ui.col.White)
	self.Label:SetPos(34, 4)
end

function PANEL:SetText(txt)
	self.Label:SetText(txt)
	self:SizeToContents()
end

function PANEL:SizeToContents()
	self.Label:SizeToContents()

	self:SetWidth(self.Label:GetWide() + 42)
	self:SetHeight(30)
	self:InvalidateLayout()
end

function PANEL:KillSelf()
	if (self.StartTime + self.Length < SysTime()) then
		self:Remove()
		return true
	end
	return false
end

function PANEL:Paint(w, h)
	if (hook.Call('HUDShouldDraw', GAMEMODE, 'Notifications') == false) then return end

	local timeleft = self.StartTime - (SysTime() - self.Length)

	local inf = notifyTypes[self.NotifyType]

	draw.BlurPanel(self)
	draw.OutlinedBox(0, 0, w, h, ui.col.Background, ui.col.Outline)
	draw.OutlinedBox(0, 0, h, h, inf.Color, ui.col.Outline)

	draw.Box(30, 0, (w - 30) * (timeleft/self.Length), h, inf.BarColor)

	surface.SetMaterial(inf.Icon)
	surface.SetDrawColor(255, 255, 255)
	surface.DrawTexturedRect(4, 4, 22, 22)
end
vgui.Register('NoticePanel', PANEL, 'ui_panel')

concommand.Add('ntest', function()
	for i = 0, 4 do
		notification.AddLegacy(('This is a test notification.'):rep(math.random(1,3)), i, 5)
	end
end)
