local CurTime 						= CurTime
local IsValid 						= IsValid
local ipairs 						= ipairs
local Color 						= Color
local DrawColorModify 				= DrawColorModify

local nw_GetGlobal 					= nw.GetGlobal
local cvar_Get 						= cvar.GetValue
local table_Filter 					= table.Filter
local player_GetAll 				= player.GetAll
local hook_Call 					= hook.Call

local rp_FormatMoney 				= rp.FormatMoney

local math_ceil 					= math.ceil
local math_sin 						= math.sin
local math_max						= math.max

local draw_SimpleText 				= draw.SimpleText
local draw_SimpleTextOutlined 		= draw.SimpleTextOutlined
local draw_OutlinedBox 				= draw.OutlinedBox
local draw_Box 						= draw.Box
local draw_BlurBox 					= draw.BlurBox

local surface_SetDrawColor 			= surface.SetDrawColor
local surface_DrawLine				= surface.DrawLine
local surface_DrawTexturedRect 		= surface.DrawTexturedRect
local surface_GetTextSize 			= surface.GetTextSize
local surface_SetFont 				= surface.SetFont
local surface_SetMaterial 			= surface.SetMaterial
local surface_DrawOutlinedRect 		= surface.DrawOutlinedRect
local surface_SetTextPos			= surface.SetTextPos
local surface_SetTextColor 			= surface.SetTextColor
local surface_DrawText 				= surface.DrawText
local surface_DrawRect 				= surface.DrawRect

local cam_Start3D2D 				= cam.Start3D2D
local cam_End3D2D 					= cam.End3D2D

local color_white					= rp.col.White
local color_black 					= rp.col.Black
local color_red 					= ui.col.Red
local color_orange 					= ui.col.Orange
local color_blue 					= rp.col.SUP
local color_darkred					= Color(100, 0, 0)
local color_15k 					= Color(240,191,0)

local color_gradient 				= Color(50, 50, 50)
local color_bg 						= ui.col.Header
local color_outline	 				= ui.col.Outline:Copy()

local color_armor = Color(18, 76, 94, 60)
local color_money = Color(135, 135, 31, 60)
local color_time = Color(31, 59, 137, 60)
local color_karma = Color(81, 31, 104, 60)
local color_food = Color(107, 73, 31, 60)
local color_health = Color(59, 109, 45, 60)
local color_job = Color(35, 31, 32, 60)
local color_event = Color(71, 61, 11, 60)
local color_grace = Color(76, 24, 84, 60)
local color_sup = Color(27, 82, 102, 60)

local color_agenda = Color(33, 92, 132, 60)
local color_laws = Color(135, 33, 33, 60)
local color_arrest_warrants = Color(211, 36, 36, 60)
local color_hits = Color(40, 40, 40, 60)

local function mat(texture)
	return Material(texture, 'smooth')
end

-- Bar
local material_grad		= mat 'gui/gradient_down'
local material_job		= mat 'gmh/hud/job.png'
local material_health 	= mat 'gmh/hud/health.png'
local material_armor	= mat 'gmh/hud/armor.png'
local material_hunger 	= mat 'gmh/hud/food.png'
local material_karma	= mat 'gmh/hud/karma.png'
local material_money 	= mat 'gmh/hud/money.png'
local material_events	= mat 'gmh/hud/event.png'
local material_employee = mat 'gmh/hud/employee.png'
local material_employed = mat 'gmh/hud/employer.png'
local material_grace 	= mat 'gmh/hud/mayorgrace.png'
local material_licence_hud 	= mat 'gmh/hud/gunlicense_hud.png'
local material_lockdown	= mat 'gmh/hud/lockdown'

-- player
local material_licence 	= mat 'gmh/hud/gunlicense.png'
local material_mic 		= mat 'gmh/hud/istalking'
local material_typing 	= mat 'gmh/hud/istyping'
local material_presse 	= mat 'gmh/hud/button.png'

local mat_bullet 		= mat 'gmh/hud/bullet.png'
local mat_911			= mat 'gmh/hud/911.png'
local mat_aids_right 	= mat 'gmh/hud/aids_right.png'
local mat_aids_left 	= mat 'gmh/hud/aids_left.png'
local mat_cuffs			= mat 'gmh/hud/cuffs.png'
local mat_bloodstacks	= mat 'gmh/hud/bloodstacks.png'

local mat_agenda 		= mat 'gmh/hud/agenda.png'
local mat_laws 			= mat 'gmh/hud/laws.png'
local mat_warrents	 	= mat 'gmh/hud/warrents.png'
local mat_hits 			= mat 'gmh/hud/hits.png'

local mat_death 		= mat 'gmh/hud/death_screen.png'
local mats_death = {
	mat 'gmh/hud/death_frame-1.png',
	mat 'gmh/hud/death_frame-2.png',
	mat 'gmh/hud/death_frame-3.png',
	mat 'gmh/hud/death_frame-4.png',
}

local sw, sh = ScrW(), ScrH()
local players = {}

cvar.Register 'enable_lawshud'
	:SetDefault(true, true)
	:AddMetadata('Catagory', 'HUD')
	:AddMetadata('Menu', 'Включить HUD законов')

cvar.Register 'enable_agendahud'
	:SetDefault(true, true)
	:AddMetadata('Catagory', 'HUD')
	:AddMetadata('Menu', 'Выключить HUD задач')

cvar.Register 'disable_niceinfomath'
	:SetDefault(false, true)
	:AddMetadata('Catagory', 'HUD')
	:AddMetadata('Menu', 'Использовать упрощённую математику (увеличивает FPS, выглядит хуже)')

cvar.Register 'enable_localplayerinfotag'
	:SetDefault(false, true)
	:AddMetadata('Catagory', 'HUD')
	:AddMetadata('Menu', 'Отображать информацию о себе в режиме от третьего лица')

cvar.Register 'disable_playerinfoorgbanner'
	:SetDefault(false, true)
	:AddMetadata('Catagory', 'HUD')
	:AddMetadata('Menu', 'Выключить баннеры банд над головами игроков')

surface.CreateFont('HudFont', {
	font = 'Prototype [RUS by Daymarius]',
	size = 20,
	weight = 500,
	extended = true
})

surface.CreateFont('HudFontLaws', {
	font = 'Prototype [RUS by Daymarius]',
	extended = true,
	size = 19,
	weight = 350
})

surface.CreateFont('HudFont2', {
	font = 'Helvetica',
	extended = true,
	size = 24,
	weight = 700
})

surface.CreateFont('HudFont3', {
	font = 'Helvetica',
	extended = true,
	size = 30,
	weight = 700
})

surface.CreateFont('BannedInfo', { -- Coolvetica does not mean you're cool
	font = 'Helvetica',
	extended = true,
	size = 42,
	weight = 700
})

surface.CreateFont('PlayerInfo', {
	font = 'Tahoma',
	extended = true,
	outline = true,
	shadow = true,
	size = 128,
	weight = 750
})


surface.CreateFont('rp.hud.DeathScreenTitle', {
	font = 'Prototype [RUS by Daymarius]',
	extended = true,
	size = 100,
	weight = 550
})

surface.CreateFont('rp.hud.DeathScreenText', {
	font = 'Prototype [RUS by Daymarius]',
	extended = true,
	size = 50,
	weight = 550
})


local talkingplayers = {}
hook('PlayerStartVoice', 'rp.hud.PlayerStartVoice', function(pl)
	talkingplayers[pl] = true
end)

hook('PlayerEndVoice', 'rp.hud.PlayerEndVoice', function(pl)
	talkingplayers[pl] = nil
end)

timer.Simple(1, function()
	Material('voice/icntlk_pl'):SetFloat('$alpha', 0) -- hacky voice bubble fix
end)


-- utils
local ColValues = {}
local function varcol(name, val)
	if ColValues[name] == nil then
		ColValues[name] = {}
		ColValues[name].Old = val
		ColValues[name].Flash = SysTime()
		return color_white
	end

	if ColValues[name].Old != val then
		ColValues[name].Flash = SysTime() + 0.2
		ColValues[name].Old = val
		return color_blue
	end

	if ColValues[name].Flash > SysTime() then
		return color_blue
	end
	return color_white
end

local function formatTime(t)
	if not t then return 'N/A' end

	local minutes = math.floor((t % 3600) / 60)
	local seconds = math.floor(t - (minutes * 60))

	if (minutes < 10) then minutes = '0' .. minutes end
	if (seconds < 10) then seconds = '0' .. seconds end

	return (minutes .. ':' .. seconds)
end

-- Draw utils
local height 	= 30
local left_x 	= 0
local right_x	= ScrW() - 3

local function drawLeftTextIcon(icon, text, color_text, color_background)
	local w = surface_GetTextSize(text)

	surface_SetMaterial(icon)
	surface_SetDrawColor(255, 255, 255)
	surface_DrawTexturedRect(left_x + 1, 1, 28, 28)

	surface_SetDrawColor(color_outline.r, color_outline.g, color_outline.b, color_outline.a)
	surface_DrawOutlinedRect(left_x, 0, 30, 30)

	left_x = left_x + 30

	draw_Box(left_x, 1, w + 8, 28, color_background)

	left_x = left_x + 3

	surface_SetTextPos(left_x, 4)
	surface_SetTextColor(color_text.r, color_text.g, color_text.b, color_text.a)
	surface_DrawText(text)

	left_x = left_x + (w + 3)

	surface_SetDrawColor(color_outline.r, color_outline.g, color_outline.b, color_outline.a)
	surface_DrawLine(left_x, 0, left_x, height - 1)
end

local function drawRightText(text, color_background)
	local w = surface_GetTextSize(text)

	right_x = right_x - (w + 3)

	surface_SetTextPos(right_x, 4)
	surface_SetTextColor(color_white.r, color_white.g, color_white.b, color_white.a)
	surface_DrawText(text)

	right_x = right_x - 5

	draw_Box(right_x, 1, w + 8, 28, color_background)

	surface_SetDrawColor(color_outline.r, color_outline.g, color_outline.b, color_outline.a)
	surface_DrawLine(right_x, 0, right_x, height - 1)
end

local function drawRightIcon(icon)
	surface_SetDrawColor(color_outline.r, color_outline.g, color_outline.b, color_outline.a)
	surface_DrawLine(right_x, 0, right_x, height - 1)

	right_x = right_x - 29

	surface_SetMaterial(icon)
	surface_SetDrawColor(255, 255, 255)
	surface_DrawTexturedRect(right_x + 1, 1, 28, 28)

	surface_SetDrawColor(color_outline.r, color_outline.g, color_outline.b, color_outline.a)
	surface_DrawOutlinedRect(right_x, 0, 30, 30)
end

-- Info bar
local function InfoBar()
	left_x 	= 0
	right_x	= ScrW()

	surface_SetFont('HudFont')

	draw_OutlinedBox(0, 0, ScrW(), height, color_bg, color_outline)

	surface_SetMaterial(material_grad)
	surface_SetDrawColor(color_gradient.r, color_gradient.g, color_gradient.b, color_gradient.a)
	surface_DrawTexturedRect(1, 1, ScrW() - 2, height * .5)

	local org = LocalPlayer():GetOrg()
	if (org ~= nil) then
		local banner = rp.orgs.GetBanner(org)
		if banner then
			local color = LocalPlayer():GetOrgColor()
			color.a = 60
			drawLeftTextIcon(banner, org, color_white, color)
		end
	end

	local job = LocalPlayer():GetJobName()
	drawLeftTextIcon(material_job, job, varcol('job', job), color_job)

	local health = LocalPlayer():Health()
	drawLeftTextIcon(material_health, health, varcol('hp', health), color_health)

	if (LocalPlayer():Armor() > 0) then
		local armor = LocalPlayer():Armor()
		drawLeftTextIcon(material_armor, armor, varcol('armor', armor), color_armor)
	end

	local hunger = LocalPlayer():GetHunger()
	drawLeftTextIcon(material_hunger, hunger, varcol('hunger', hunger), color_food)

	local money = string.Comma(LocalPlayer():GetMoney())
	drawLeftTextIcon(material_money, money, varcol('money', money), color_money)

	local karma = string.Comma(LocalPlayer():GetKarma())
	drawLeftTextIcon(material_karma, karma, varcol('karma', karma), color_karma)

	right_x = right_x - 3
	surface_SetDrawColor(color_outline.r, color_outline.g, color_outline.b, color_outline.a)

	local alpha = (math_sin(CurTime()) + 1) / 0.5 * 255
	local w = surface_GetTextSize('GmodHub.com')
	right_x = right_x - w

	draw_Box(right_x - 3, 1, w + 6, 28, color_sup)

	surface_SetTextPos(right_x, 4)
	surface_SetTextColor(color_blue.r, color_blue.g, color_blue.b, alpha)
	surface_DrawText('Gmod')

	surface_SetTextPos(right_x, 4)
	surface_SetTextColor(color_white.r, color_white.g, color_white.b, 255 - alpha)
	surface_DrawText('Gmod')

	surface_SetTextColor(color_white.r, color_white.g, color_white.b, color_white.a)
	surface_DrawText('Hub.com')

	right_x = right_x - 4
	//drawRightIcon(material_sup)

	local events = nw_GetGlobal('EventsRunning')
	if events then
		local c = 0
		local str = ''
		for k, v in pairs(events) do
			c = c + 1
			str = str .. ((c == 1) and '' or ', ') .. k
		end

		if (c > 0) then
			drawRightText(str .. ((c > 1) and ' Ивенты' or ' Ивент'), color_event)
			drawRightIcon(material_events)
		end
	end

	if nw_GetGlobal('mayorGrace') and (nw_GetGlobal('mayorGrace') > CurTime()) then
		drawRightText('Неприкосновенность мера: ' .. ba.str.FormatTime(math_ceil(nw_GetGlobal('mayorGrace') - CurTime())), color_grace)
		drawRightIcon(material_grace)
	end


	if LocalPlayer():HasLicense() then
		drawRightIcon(material_licence_hud)
	end

	if IsValid(LocalPlayer():GetNetVar('Employer')) then
		drawRightIcon(material_employed)
	end

	if (LocalPlayer():GetNetVar('Employees') ~= nil) then
		drawRightIcon(material_employee)
	end
end

function GM:DrawBannedHUD()
	local w, h = draw_SimpleText('Вы были забанены на сервере!', 'BannedInfo', ScrW() * 0.5, ScrH() * 0.1, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw_SimpleText('Разбан @ GmodHub.com', 'BannedInfo', ScrW() * 0.5, ScrH() * 0.1 + h, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Agenda
function GM:DrawAgenda()
	local agenda = rp.agendas[LocalPlayer():Team()]

	if (not agenda) then return end

	local w 	= (ScrW() * .175)
	local agendaText = nw_GetGlobal('Agenda;' .. agenda.manager) or 'Повестка дня отсутствует!'
	local text 	= string.Wrap('HudFontLaws', agendaText, w - 6)

	local h 	= (#text * 15) + 33

	local x, y	= 5, height + 5

	draw_OutlinedBox(x, y, w, h, color_bg, color_outline)

	surface.DrawOutlinedRect(x, y, 30, 30)
	surface.DrawOutlinedRect(x + 29, y, w - 29, 30)

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(mat_agenda)
	surface.DrawTexturedRect(x + 1, y + 1, 28, 28)

	surface.SetDrawColor(color_agenda.r, color_agenda.g, color_agenda.b, color_agenda.a)
	surface.DrawRect(x + 30, y + 1, w - 31, 28)

	local color = varcol('Agenda', agendaText)
	surface.SetFont('HudFont')
	surface.SetTextColor(color.r, color.g, color.b, color.a)

	surface.SetTextPos(x + 34, y + 4)
	surface.DrawText('Агенда')

	y = y + 29
	surface.SetFont('HudFontLaws')
	local textX, textY = (x + 3), y

	for k, v in ipairs(text) do
		surface.SetTextPos(textX, y)
		surface.DrawText(v)

		y = y + 15
	end

	return x, y + 3, w
end

function GM:DrawBloodStacks()
	if (LocalPlayer():Team() == TEAM_METHHEAD) then

		local bs = LocalPlayer():GetNetVar('BloodStacks') or 0
		if (bs <= 0) then return end

		surface.SetDrawColor(color_white)
		surface.SetMaterial(mat_bloodstacks)

		local scale = (ScrH() / 2160) * 10

		local size = 64 + scale * bs
		local hSize = size * 0.5

		local x = ScrW() * 0.5 - hSize
		local y = ScrH() * 0.5 - size - ((bs - 1) / 19) * (ScrW() * 0.15)

		surface.DrawTexturedRect(x, y, size, size)
	end
end

-- Laws
function GM:DrawLaws()
	local w 	= (ScrW() * .175)
	local text 	= string.Wrap('HudFontLaws', rp.cfg.DefaultLaws .. (nw_GetGlobal('TheLaws') or ''), w - 6)
	local h 	= (#text * 15) + 33

	local x, y	= ((ScrW() - w) - 5), height + 5

	draw_OutlinedBox(x, y, w, h, color_bg, color_outline)

	surface.DrawOutlinedRect(x, y, 30, 30)
	surface.DrawOutlinedRect(x + 29, y, w - 29, 30)

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(mat_laws)
	surface.DrawTexturedRect(x + 1, y + 1, 28, 28)

	surface.SetDrawColor(color_laws.r, color_laws.g, color_laws.b, color_laws.a)
	surface.DrawRect(x + 30, y + 1, w - 31, 28)

	local color = varcol('TheLaws', nw_GetGlobal('TheLaws'))
	surface.SetFont('HudFont')
	surface.SetTextColor(color.r, color.g, color.b, color.a)

	surface.SetTextPos(x + 34, y + 4)
	surface.DrawText('Законы')

	y = y + 29
	surface.SetFont('HudFontLaws')
	local textX, textY = (x + 3), y
	for k, v in ipairs(text) do
		surface.SetTextPos(textX, textY + ((k - 1) * 15))
		surface.DrawText(v)
	end
end


-- Hits
function GM:DrawHitlist()
	if LocalPlayer():IsHitman() then
		local x, y	= 5, height + 5
		local w = math.max((ScrW() * .175), 200)

		local hits = table_Filter(player_GetAll(), function(pl)
			return pl:HasHit() and (pl ~= LocalPlayer()) and pl:Alive()
		end)
		local h = (math.Clamp(#hits, 1, vgui.CursorVisible() and (#hits + 1) or 6) * 15) + 33
		draw_OutlinedBox(x, y, w, h, color_bg, color_outline)

		surface.DrawOutlinedRect(x, y, 30, 30)
		surface.DrawOutlinedRect(x + 29, y, w - 29, 30)

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(mat_hits)
		surface.DrawTexturedRect(x + 1, y + 1, 28, 28)

		surface.SetDrawColor(color_hits.r, color_hits.g, color_hits.b, color_hits.a)
		surface.DrawRect(x + 30, y + 1, w - 31, 28)

		surface.SetFont('HudFont')
		surface.SetTextColor(color_white.r, color_white.g, color_white.b, color_white.a)

		surface.SetTextPos(x + 34, y + 4)
		surface.DrawText('Hits')

		y = y + 29
		surface.SetFont('HudFontLaws')
		local textX, textY = (x + 3), y

		if (#hits > 0) then
			for k, v in ipairs(hits) do
				if (k == 6) and (not vgui.CursorVisible()) then
					surface.SetTextColor(255, 255, 255)
					surface.SetTextPos(textX, y)
					surface.DrawText('And ' ..  #hits - 6 .. ' more!')
					break
				end

				local jobcol = v:GetJobColor()
				surface.SetTextColor(jobcol.r, jobcol.g, jobcol.b)
				surface.SetTextPos(textX, y)
				surface.DrawText(v:Name() .. ': ' .. rp_FormatMoney(v:GetHitPrice()))
				y = y + 15
			end
		else
			surface.SetTextPos(textX, y)
			surface.DrawText('No Hits!')
		end
	end
end


-- Arrest warrants
function GM:DrawWantedList(x, y, w, rightAlign)
	if LocalPlayer():IsCP() then
		local w = math.max(w * 0.5, 200)

		local wants = table_Filter(player_GetAll(), function(pl)
			return pl:IsWanted() and (pl ~= LocalPlayer()) and IsValid(pl)
		end)

		local h = (math.Clamp(#wants, 1, vgui.CursorVisible() and (#wants + 1) or 6) * 15) + 33

		local x, y	= 5, y + 5
		if (rightAlign) then
			x = ScrW() - w - 5
		end

		draw_OutlinedBox(x, y, w, h, color_bg, color_outline)

		surface.DrawOutlinedRect(x, y, 30, 30)
		surface.DrawOutlinedRect(x + 29, y, w - 29, 30)

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(mat_warrents)
		surface.DrawTexturedRect(x + 1, y + 1, 28, 28)

		surface.SetDrawColor(color_arrest_warrants.r, color_arrest_warrants.g, color_arrest_warrants.b, color_arrest_warrants.a)
		surface.DrawRect(x + 30, y + 1, w - 31, 28)

		surface.SetFont('HudFont')
		surface.SetTextColor(color_white.r, color_white.g, color_white.b, color_white.a)

		surface.SetTextPos(x + 34, y + 4)
		surface.DrawText('Ордеры на арест')

		y = y + 29
		surface.SetFont('HudFontLaws')
		local textX, textY = (x + 3), y

		if (#wants > 0) then
			for k, v in ipairs(wants) do
				if (k == 6) and (not vgui.CursorVisible()) then
					surface.SetTextColor(255, 255, 255)
					surface.SetTextPos(textX, y)
					surface.DrawText('И ещё ' ..  #wants - 6 .. '!')
					break
				end

				local jobcol = v:GetJobColor()
				surface.SetTextColor(jobcol.r, jobcol.g, jobcol.b)
				surface.SetTextPos(textX, y)
				surface.DrawText(v:Name())
				y = y + 15
			end
		else
			surface.SetTextPos(textX, y)
			surface.DrawText('Нет ордеров на арест!')
		end
	end

	return y
end

-- Gambling
local gamblingProfit, gamblingLoss = 0, 0
net('rp.gambling.Profit', function()
	gamblingProfit = gamblingProfit + net.ReadUInt(32)
end)

net('rp.gambling.Loss', function()
	gamblingLoss = gamblingLoss + net.ReadUInt(32)
end)

function GM:DrawGambling()
	if (LocalPlayer():Team() == TEAM_CASINOOWNER) then
		local x, y	= 5, height + 5
		local w = math.max((ScrW() * .1), 240)

		local h = 45 + 33
		draw_OutlinedBox(x, y, w, h, color_bg, color_outline)

		surface.DrawOutlinedRect(x, y, 30, 30)
		surface.DrawOutlinedRect(x + 29, y, w - 29, 30)

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(material_money)
		surface.DrawTexturedRect(x + 1, y + 1, 28, 28)

		surface.SetDrawColor(color_money.r, color_money.g, color_money.b, color_money.a)
		surface.DrawRect(x + 30, y + 1, w - 31, 28)

		surface.SetFont('HudFont')
		surface.SetTextColor(color_white.r, color_white.g, color_white.b, color_white.a)

		surface.SetTextPos(x + 34, y + 4)
		surface.DrawText('Игровой Доход/Убыток')

		y = y + 29
		surface.SetFont('HudFontLaws')
		local textX, textY = (x + 3), y

		surface.SetTextPos(textX, y)
		surface.SetTextColor(varcol('gambleprofit', gamblingProfit))
		surface.DrawText('Доход: ' .. rp.FormatMoney(gamblingProfit))
		y = y + 15

		surface.SetTextPos(textX, y)
		surface.SetTextColor(varcol('gambleloss', gamblingLoss))
		surface.DrawText('Убыток: ' .. rp.FormatMoney(gamblingLoss))
		y = y + 15

		local totalProfit = gamblingProfit - gamblingLoss
		surface.SetTextPos(textX, y)
		surface.SetTextColor(varcol('gambletotalprofit', totalProfit))
		surface.DrawText('Прибыль: ' .. rp.FormatMoney(totalProfit))
		y = y + 15

	else
		gamblingProfit = 0
		gamblingLoss = 0
	end
end


-- Lockdown
rp.LockdownText = 'Объявлен комендантский час, оставайтесь дома!'
function GM:DrawLockdown()
	local timeLeft = formatTime(math_max(math_ceil(nw_GetGlobal('lockdown') - CurTime()), 0))

	surface_SetFont('HudFont')
	local w = (surface_GetTextSize('(99:99) Объявлен комендантский час, оставайтесь дома!') + 50)
	local x, y = ScrW() * .5 - w * .5, (height - 1)

	local height = height - 4

	draw_BlurBox(x, y, w, height)
	draw_OutlinedBox(x, y, w, height, color_bg, color_outline)

	surface_SetMaterial(material_lockdown)
	surface_SetDrawColor(color_outline.r, color_outline.g, color_outline.b, color_outline.a)
	surface_DrawTexturedRect(x - 42, y - 26, 64, 64)

	surface_SetMaterial(material_lockdown)
	surface_SetDrawColor(color_outline.r, color_outline.g, color_outline.b, color_outline.a)
	surface_DrawTexturedRect(x + (w - 22), y - 26, 64, 64)

	draw_SimpleText('(' .. timeLeft .. ') ' .. rp.LockdownText, 'HudFont', ScrW() * .5, y + 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

-- Arrested
function GM:DrawArrested()
	if LocalPlayer():IsArrested() then
		local info = LocalPlayer():GetArrestInfo()

		surface.SetFont("HudFont3")
		local tw1 = surface.GetTextSize("Вы арестованы!")

		surface.SetFont("HudFont2")
		local _tw, th = surface.GetTextSize(info.Reason)
		local tw = math.min(_tw + 10, ScrW() * 0.25)

		local rem = math_ceil(info.ReleaseTime - CurTime())
		rem = "Выход через " .. (rem > 0 and ba.str.FormatTime(rem) or "")
		local tw3 = surface.GetTextSize(rem)

		local tw2 = surface.GetTextSize(info.Reason)

		local x = (ScrW() * 0.5) - tw * 0.5 - 48
		local w = math.max(tw1, tw2, tw3) + 96 + 15
		local h = 86
		local y = sh - h

		draw_BlurBox(x, y, w, h)
		draw_OutlinedBox(x, y, w, h, color_bg, color_outline)

		draw_Box(x+1, y+1, 96, h-2, color_darkred)

		surface.SetMaterial(mat_cuffs)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect(x, y - 5, 96, 96)

		surface.SetTextColor(color_white)

		surface.SetFont("HudFont3")
		surface.SetTextPos(x + ((w - 96) - tw1) * 0.5 + 96, y + 5)
		surface.DrawText("Вы арестованы!")

		surface.SetFont("HudFont2")
		surface.SetTextPos(x + ((w - 96) - tw2) * 0.5 + 96, y + 10 + th)
		surface.DrawText(info.Reason)

		surface.SetTextPos(x + ((w - 96) - tw3) * 0.5 + 96, sh - th - 3)
		surface.DrawText(rem)

	end
end

function GM:DrawWanted()
	if LocalPlayer():IsWanted() then
		local info = LocalPlayer():GetWantedInfo()
		draw_SimpleTextOutlined('Вы разыскиваетесь за: ' .. info.Reason, 'HudFont2', ScrW()/2, sh - 50, color_white, 1, 1, 1, color_black)
		draw_SimpleTextOutlined('Осталось: ' .. math_ceil(info.Time - CurTime()) .. ' секунд.', 'HudFont2', ScrW()/2, sh - 20, color_white, 1, 1, 1, color_black)
	end
end

local ztcStart
local ztcEnd
function GM:DrawZiptieCutting()
	local pl = LocalPlayer()
	local endTime = pl:GetNetVar('ZiptieCutting')

	if (endTime != nil) then
		//surface.SetFont('ziptiestruggle')
		ztcStart = ztcStart or RealTime()
		ztcEnd = ztcEnd or RealTime() + (endTime - CurTime())

		//local str = pl:IsZiptied() and "Being freed.." or "Freeing.."
		local perc = math.min((RealTime() - ztcStart) / (ztcEnd - ztcStart), 1)

		/*local w, h = surface.GetTextSize(str)
		w = w + 16
		local x = (ScrW() - w) * 0.5
		local y = ScrH() * 0.15

		surface.SetDrawColor(rp.col.Outline)
		surface.DrawOutlinedRect(x, y, w, h)

		surface.SetDrawColor(rp.col.Background)
		surface.DrawRect(x, y, w, h)

		surface.SetTextPos(x + 8, y)
		surface.SetTextColor(200, 50, 50, math.abs(math.sin(RealTime() * 2)) * 255)
		surface.DrawText(str)

		surface.SetDrawColor(rp.col.Green)
		surface.DrawRect(x + perc * w, y, 5, h)*/

		rp.ui.DrawCenteredProgress(pl:IsZiptied() and "Being freed.." or "Freeing..", perc)
	else
		if (ztcStart) then ztcStart = nil ztcEnd = nil end
	end
end

function GM:DrawEntityDisplay(sw, sh)
	local ent = LocalPlayer():GetEyeTrace().Entity
	if IsValid(ent) and (LocalPlayer():GetPos():Distance(ent:GetPos()) < 115) then
		if (ent.Interactions and istable(ent.Interactions)) then
			local y = ScrH() * 0.65 + 16
			for k, v in pairs(ent.Interactions) do
				local w, _ = draw_SimpleTextOutlined(v.Text or 'Чтобы использовать', 'ui.22', (ScrW() * 0.5) + 37, y, color_white, 1, 1, 1, color_black)
				surface.SetDrawColor(255,255,255)
				surface.SetMaterial(material_presse)
				surface.DrawTexturedRect((ScrW() * 0.5) - (w * 0.5), y - 16, 32, 32)

				draw_SimpleText(v.Key, 'ui.24', (ScrW() * 0.5) - (w * 0.5) + 16, y, color_black, 1, 1)

				y = y + 36
			end
		else
			if ent.PressKey or ent.PressKeyText or ent.PressE then
				local w, _ = draw_SimpleTextOutlined(ent.PressKeyText or 'Чтобы использовать', 'ui.22', (ScrW() * 0.5) + 37, ScrH() * 0.65 + 16, color_white, 1, 1, 1, color_black)
				surface.SetDrawColor(255,255,255)
				surface.SetMaterial(material_presse)
				surface.DrawTexturedRect((ScrW() * 0.5) - (w * 0.5), ScrH() * 0.65, 32, 32)

				draw_SimpleText(ent.PressKey or 'E', 'ui.24', (ScrW() * 0.5) - (w * 0.5) + 16, ScrH() * 0.65 + 16, color_black, 1, 1)
			end
		end

		if (ent.TraceInfo ~= nil) then
			draw_SimpleTextOutlined(ent.TraceInfo, 'HudFont2', ScrW() * 0.5, ScrH() * 0.5 + 50, color_white, 1, 1, 1, color_black)
		end
	end
end



local deathanim = true
local diedWhen = math.huge
local deathType = 1
local deathKiller
local deathfr
local function DeathScreen()
	if (IsValid(deathfr)) then return end
	if (LocalPlayer().SelectingGenome) then return end
	if (not LocalPlayer():GetNetVar('HasInitSpawn')) then return end

	deathfr = ui.Create("Panel", function(fr)
		fr.timeleft = math.huge
		fr.killertext = ""
		fr:Dock(FILL)
		fr:SetVisible(true)
		fr:SetMouseInputEnabled(false)
		fr:SetKeyboardInputEnabled(false)
		fr.Paint = function(fr, w, h)
			if (not fr.TotalTime) and LocalPlayer():GetNetVar('RespawnTime') then
				fr.TotalTime = math.ceil(LocalPlayer():GetNetVar('RespawnTime') - CurTime())
			end

			local respawnTime = LocalPlayer():GetNetVar('RespawnTime') or CurTime()
			local deathtime = math.max(respawnTime - CurTime(), 0)

			surface_SetDrawColor(0, 0, 0)
			surface_DrawRect(0, 0, ScrW(), ScrH())

			local x, y = ScrW() * 0.5 - 256, ScrH() * 0.5 - 256

			surface_SetDrawColor(255, 255, 255)
			surface_SetMaterial(mat_death)
			surface_DrawTexturedRect(x, y, 512, 512)

			surface_SetDrawColor(color_red.r, color_red.g, color_red.b)
			fr.timeleft = math_ceil(deathtime)

			if fr.TotalTime then
				for i = 1, math.Clamp(math.floor((1 - (fr.timeleft/fr.TotalTime)) * 4), 1, 4) do
					surface_SetMaterial(mats_death[i])
					surface_DrawTexturedRect(x, y, 512, 512)
				end
			end

			draw_SimpleText(rp.cfg.DeathTypeStrings[deathType or 1], 'rp.hud.DeathScreenTitle', ScrW() * 0.5, ScrH() * 0.25 - 128, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw_SimpleText('Нажмите на любую кнопку для возрождения ' .. ((fr.timeleft <= 0) and 'сейчас' or ('через ' .. fr.timeleft .. ' секунд')), 'rp.hud.DeathScreenText', ScrW() * 0.5, ScrH() * 0.75 + 128, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			draw_SimpleText(fr.killertext, 'rp.hud.DeathScreenText', ScrW() * 0.5, ScrH() * 0.75 + 133, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end

		fr.Think = function(fr)
			fr:MoveToBack()

			if (IsValid(deathKiller)) then
				fr.killertext = "Вы убиты " .. deathKiller:Name()
			elseif (fr.AskKiller != nil and !IsValid(fr.AskKiller)) then
				fr.killertext = "Ваш убийца вышел"
			end

			if (fr.timeleft <= 0) then
				fr.killertext = ""
			end

			if (LocalPlayer():Alive() or LocalPlayer().SelectingGenome) then
				fr:Remove()
				deathKiller = nil
				return
			end
		end
	end)
end
net.Receive('rp.DeathInfo', function(len)
	deathType = net.ReadUInt(5)

	local hasKiller = net.ReadBool()
	if (hasKiller) then
		deathKiller = net.ReadPlayer()
	end

	diedWhen = CurTime()
end)

local quickWantPlater
local quickwantTarget
local quickwantTargetTime
local stunstick = Material('gmh/hud/stunstick_silhouette.png', 'smooth')
function GM:DrawQuickwantTarget()
	local diff = math.max(math.Round(quickwantTargetTime - SysTime(), 2), 0)

	if (diff == 0) or (not IsValid(quickWantPlater)) or quickWantPlater:IsArrested() then
		quickwantTarget = nil
		quickwantTargetTime = nil
		quickWantPlater = nil
		return
	end

	local diffstr = tostring(diff)
	if (#diffstr == 3) then
		diffstr = diffstr .. '0'
	elseif (#diffstr == 1) then
		diffstr = diffstr .. '.00'
	end

	local f1 = 'ui.60'
	local f2 = 'ui.35'
	local f3 = 'ui.24'
	local sub = 8
	local add = 3

	surface.SetFont(f1)
	local tw, th = surface.GetTextSize(diffstr)
	surface.SetFont(f2)
	local tw2, th2 = surface.GetTextSize(quickwantTarget)
	surface.SetFont(f3)
	local tw3, th3 = surface.GetTextSize("Right click your baton to catch this criminal!")

	local width = math.max(tw, tw2, tw3) + 16
	local y = height + 5
	local gbVal = 130 + math.sin(SysTime() * 10) * 125


	draw.BlurBox((ScrW() - width) * 0.5, y, width, th + th2 + th3 - sub + add)
	surface.SetDrawColor(ui.col.Background)
	surface.DrawRect((ScrW() - width) * 0.5, y, width, th + th2 + th3 - sub + add)
	surface.SetDrawColor(ui.col.Outline)
	surface.DrawOutlinedRect((ScrW() - width) * 0.5, y, width, th + th2 + th3 - sub + add)

	surface.SetMaterial(stunstick)
	surface.SetDrawColor(100, 100, 100)
	surface.DrawTexturedRect((ScrW() - width) * 0.5, y - 15, 102, 115)
	surface.DrawTexturedRectUV((ScrW() + width) * 0.5 - 102, y - 15, 102, 115, 1, 0, 0, 1)

	surface.SetFont(f1)
	surface.SetTextPos((ScrW() - tw) * 0.5, y)
	surface.SetTextColor(255, gbVal, gbVal)
	surface.DrawText(diffstr)

	y = y + th - sub

	surface.SetFont(f2)
	surface.SetTextPos((ScrW() - tw2) * 0.5, y)
	surface.SetTextColor(ui.col.White)
	surface.DrawText(quickwantTarget)

	y = y + th2

	surface.SetFont(f3)
	surface.SetTextPos((ScrW() - tw3) * 0.5, y)
	surface.DrawText("Right click your baton to catch this criminal!")
end
net.Receive('rp.QuickwantTarget', function(len)
	local pl = net.ReadPlayer()
	if (!IsValid(pl)) then return end

	quickWantPlater = pl
	quickwantTarget = "Attacked!" --pl:Name()
	quickwantTargetTime = (net.ReadFloat() - CurTime()) + SysTime()
end)


local blacklist = {
	weapon_physcannon = true,
	weapon_bugbait = true
}

local color_crosshair = ui.col.SUP:Copy()
color_crosshair.a = 150
function GM:DrawAmmo()
	local wep = LocalPlayer():GetActiveWeapon()


	if IsValid(wep) then
		if wep.DrawCrosshair or (not wep.BaseClass) then
			local centerX, centerY = (sw * 0.5), (sh * 0.5)

			draw.Box(centerX - 8, centerY - 1, 16, 2, color_crosshair)

			draw.Box(centerX - 1, centerY - 8, 2, 16, color_crosshair)

			surface.DrawCircle(centerX, centerY, 5, color_crosshair)
		end

		if (not blacklist[wep:GetClass()]) and (wep.DrawAmmo ~= false) then
			if (wep.SimpleAmmoCount) then
				local w, h = 7 + 5, 41
				local x, y = ScrW() - w - 10, ScrH() - h - 10
				draw_SimpleText(LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType()), 'HudFont', ScrW() - 12, y - 10, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
			else
				local count = wep:Clip1()
				local max = wep:GetMaxClip1()
				local extra = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())

				if (count > -1) then
					local w, h = max * 7 + 5, 41
					local x, y = ScrW() - w - 10, ScrH() - h - 10

					if wep.FireModeDisplay then
						draw_SimpleText(wep.FireModeDisplay, 'HudFont', ScrW() - 12, y - 28, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
					end

					draw_SimpleText(count .. '/' .. max .. ' - ' .. extra, 'HudFont', ScrW() - 12, y - 10, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

					surface_SetMaterial(mat_bullet)
					for i = 1, max do
						local c = (max - i < count) and 255 or 150
						surface_SetDrawColor(c, c, c)
						surface_DrawTexturedRect(x - 12 + (i * 7), y + h - 26, 24, 24)
					end
				end
			end
		end

	end
end

function GM:Draw911Hud()
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(mat_911)
	for k, v in ipairs(player.GetAll()) do
		local reason = v:GetNetVar('911CallReason')
		if (v ~= LocalPlayer()) and reason then
			local pos = v:EyePos()
			pos = pos:ToScreen()
			pos.y = pos.y + 100
			surface.DrawTexturedRect(pos.x- 15, pos.y - 40, 32, 32)
			draw.SimpleTextOutlined('Запрос 911:', 'HudFont', pos.x, pos.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
			draw.SimpleTextOutlined(reason .. '..', 'HudFont', pos.x, pos.y + 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		end
	end
end

function GM:DrawSTD()
	surface.SetDrawColor(255, 255, 255)

	draw.BlurBox(0, 0, ScrW(), ScrH())

	local scale = ScrH()/1080
	local w, h = 500 * scale, 1080 * scale

	surface.SetMaterial(mat_aids_left)
	surface.DrawTexturedRect(0, 0, w, h)

	surface.SetMaterial(mat_aids_right)
	surface.DrawTexturedRect(ScrW() - w, 0, w, h)

	draw_SimpleText('У вас ' .. LocalPlayer():GetSTD() .. ' - Примите Биницилин', 'HudFont', ScrW() * 0.5, ScrH() - 100, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end


local nodraw = {
	CHudHealth 			= true,
	CHudBattery 		= true,
	CHudSuitPower		= true,
	CHudAmmo 			= true,
	CHudSecondaryAmmo 	= true,
	CHudWeaponSelection = true,
	CHudCrosshair 		= true
}
function GM:HUDShouldDraw(name)
	if nodraw[name] or ((name == 'CHudDamageIndicator') and (not LocalPlayer():Alive())) then
		return false
	end

	-- TODO Make this more elegant
	local wep = IsValid(LocalPlayer()) and LocalPlayer():GetActiveWeapon()
	if (IsValid(wep) and wep:GetClass() == 'gmod_camera') then return (name == 'CHudGMod') end

	return true
end

function GM:HUDPaint()
	sw, sh = ScrW(), ScrH()

	draw.BlurResample()

	if (not LocalPlayer():Alive()) then
		DeathScreen()
	elseif LocalPlayer():IsBanned() then
		self:DrawBannedHUD()
	else
		if (hook.Call('HUDShouldDraw', GAMEMODE, 'SUPHUD') != false) then
			if LocalPlayer():HasSTD() then
				self:DrawSTD()
			end

			self:DrawEntityDisplay(sw, sh)

			if cvar_Get('enable_agendahud') then
				local x, y, w = self:DrawAgenda()

				self:DrawWantedList(x, y, w)
			end

			if cvar_Get('enable_lawshud') then
				self:DrawLaws()
			end

			self:DrawBloodStacks()
			self:DrawHitlist()
			self:DrawGambling()
			self:DrawArrested()
			self:DrawWanted()
			self:DrawZiptieCutting()
			InfoBar()
			if nw_GetGlobal('lockdown') then
				self:DrawLockdown()
			end
			if (quickwantTarget) then
				self:DrawQuickwantTarget()
			end
			self:DrawAmmo()

			if LocalPlayer():IsCP() or LocalPlayer():GetTeamTable().medic then
				self:Draw911Hud()
			end
		end

		self:DrawWepSwitch()

		deathtime = 30
		deathanim = true

		if (deathType and CurTime() > diedWhen + 10) then
			deathType = 1
			diedWhen = math.huge
		end
	end
end


-- Player info
timer.Create('rp.hud.DrawCache', 0.5, 0, function()
	local LP = LocalPlayer()
	players = table.Filter(player.GetAll(), function(pl)
		if IsValid(pl) then
			local insight = pl:Alive() and (pl == LP) or (pl:InSight() and pl:InTrace())
			pl.IsCurrentlyVisible = insight
			return (pl ~= LP or (cvar_Get('enable_localplayerinfotag') and rp.thirdPerson.isEnabled())) and insight and (hook_Call('HUDShouldDraw', nil, 'PlayerDisplay', pl) ~= false)
		end
	end)
end)

local infoy = 0
local function drawinfo(text, color)
	local w, h = surface_GetTextSize(text)

	surface_SetTextColor(color.r, color.g, color.b, color.a)
	local x = -(w * 0.5)
	local y = infoy
	surface_SetTextPos(x, infoy)
	surface_DrawText(text)

	infoy = infoy - (h - 20)

	return x, y, w, h, infoy
end

local simpleMathVecOffset = Vector(0, 0, -0)
local pang = Angle(0,90,90)
local disableBannerOverhead = false
function GM:DrawPlayerInfo(pl, simpleMath)
	if (not pl:Alive()) then return end
	if (pl:CallTeamHook('ShouldHidePlayerInfo', pl)) then return end

	local pos
	if (simpleMath) then
		pos = pl:EyePos() + simpleMathVecOffset
	else
		local bone = pl:LookupBone('ValveBiped.Bip01_Head1')
		if (not bone) then return end

		pos, _ = pl:GetBonePosition(bone)
	end

	if (not pos) then return end

	infoy = 0
	if pl.InfoOffset then
		pos.z = pos.z + pl.InfoOffset + 7.5
	else
		pos.z = pos.z + 12.5
	end

	pang.y = (LocalPlayer():EyeAngles().y - 90)

	cam_Start3D2D(pos, pang, 0.03)
		local x, y, w, h, y2
		local org = pl:GetOrg()
		if (org ~= nil) then
			x, y, w, h, y2 = drawinfo(org, pl:GetOrgColor())
		end

		x, y, w, h, y2 = drawinfo(pl:Name(), pl:GetPlayTime() > 54000000 and color_15k or color_white)

		if pl:HasLicense() then
			surface_SetMaterial(material_licence)
			surface_SetDrawColor(color_white.r, color_white.g, color_white.b)
			surface_DrawTexturedRect(x + w + 10, y2 + 118, 128, 128)
		end

		if pl:IsWanted() then
			x, y, w, h, y2 = drawinfo('Fugitive', color_red)

			surface_SetMaterial(material_lockdown)
			surface_SetDrawColor(color_white.r, color_white.g, color_white.b)
			surface_DrawTexturedRect(x + w + 10, y2 + 118, 128, 128)
			surface_DrawTexturedRect(x - 138, y2 + 118, 128, 128)
		elseif pl:IsArrested() then
			x, y, w, h, y2 = drawinfo('Заключённый', color_orange)

			surface_SetMaterial(mat_cuffs)
			surface_SetDrawColor(color_orange.r, color_orange.g, color_orange.b)
			surface_DrawTexturedRect(x + w + 10, y2 + 118, 128, 128)
			surface_DrawTexturedRect(x - 138, y2 + 118, 128, 128)
		else
			x, y, w, h, y2 = drawinfo(pl:GetJobName(), pl:GetJobColor())
		end

		local isadmin = (LocalPlayer():Team() == TEAM_ADMIN)
		if (LocalPlayer():IsHitman() or isadmin) and pl:HasHit() and (pl ~= LocalPlayer()) then
			x, y, w, h, y2 = drawinfo('Заказ ' .. rp_FormatMoney(pl:GetHitPrice()), color_red)
		end

		if pl:IsDisguised() and (isadmin or (LocalPlayer():IsGov() and pl:IsGov())) then
			x, y, w, h, y2 = drawinfo('Замаскирован ' .. pl:GetTeamName(), pl:GetTeamColor())
		end

		local teamtbl = LocalPlayer():GetTeamTable()
		if teamtbl.medic or isadmin then
			x, y, w, h, y2 = drawinfo(pl:Health() .. ' HP', color_red)
		end

		if (teamtbl.bmidealer or isadmin) and (pl:Armor() > 0) then
			x, y, w, h, y2 = drawinfo(pl:Armor() .. ' Брони', color_blue)
		end

		if talkingplayers[pl] then
			surface_SetMaterial(material_mic)
			surface_SetDrawColor(color_white.r, color_white.g, color_white.b)
			surface_DrawTexturedRect(-128, y2 - 138, 256, 256)
		elseif pl:IsTyping() then
			surface_SetMaterial(material_typing)
			surface_SetDrawColor(color_white.r, color_white.g, color_white.b)
			surface_DrawTexturedRect(-128, y2 - 64, 256, 256)
		elseif (org ~= nil and !disableBannerOverhead) then
			local banner = rp.orgs.GetBanner(org)
			if banner then
				surface_SetMaterial(banner)
				surface_SetDrawColor(color_white.r, color_white.g, color_white.b)
				surface_DrawTexturedRect(-64, y2 - 32, 128, 128)
			end
		end

	cam_End3D2D()
end

function GM:PostDrawTranslucentRenderables()
	if (not IsValid(LocalPlayer())) then return end
	local LP = LocalPlayer()
	local simpleMath = cvar_Get('disable_niceinfomath') == true
	disableBannerOverhead = cvar_Get('disable_playerinfoorgbanner') == true

	surface_SetFont('PlayerInfo')
	for k, v in ipairs(players) do
		if IsValid(v) then
			self:DrawPlayerInfo(v, simpleMath)
		end
	end
end

-- Low health tint
local modify = {
	['$pp_colour_addr'] = 0,
	['$pp_colour_addg'] = 0,
	['$pp_colour_addb'] = 0,
	['$pp_colour_brightness'] = 0,
	['$pp_colour_contrast' ] = 1,
	['$pp_colour_colour'] = 0,
	['$pp_colour_mulr'] = 0.05,
	['$pp_colour_mulg'] = 0.05,
	['$pp_colour_mulb'] = 0.05
}

function GM:RenderScreenspaceEffects()
	if (LocalPlayer():Health() <= 15) and LocalPlayer():GetNetVar('HasInitSpawn') then
		DrawColorModify(modify)
	end
end
