-- TODO: Dont ever touch this messy pile again
local categories = {
	'Build',
	'Roleplay',
	'BMI',
	'Guns'
}

local weaponMap = {
	weapon_physgun = {
		Name = 'Physgun',
		Slot = 1
	},
	weapon_physcannon = {
		Name = 'Gravgun',
		Slot = 1
	},
	weapon_rpg = {
		Name = 'RPG',
		Slot = 3
	},
	weapon_crossbow = {
		Name = 'Crossbow',
		Slot = 3
	},
	weapon_crowbar = {
		Name = 'Crowbar',
		Slot = 3
	},
	weapon_slam = {
		Name = 'SLAM',
		Slot = 3
	},
	weapon_stunstick = {
		Name = 'Stunstick',
		Slot = 3
	},
	weapon_bugbait = {
		Name = 'Bugbait',
		Slot = 2
	},
	weapon_frag = {
		Name = 'Grenade',
		Slot = 3
	}
}

local function getWeaponCat(wep)
	if (wep.GetSwitcherSlot) then
		wep.Slot = wep:GetSwitcherSlot()
	end

	local map = weaponMap[wep.ClassName or wep:GetClass()]
	return (wep.Slot and math.Clamp(wep.Slot, 1, 4)) or (map and map.Slot) or 2
end

local sorter = function(a, b)
	local aKnife = a.Ent.PrintName == 'Knife' or a.Ent.Base == 'baseknife'
	local bKnife = b.Ent.PrintName == 'Knife' or b.Ent.Base == 'baseknife'

	if (aKnife and !bKnife) then return true end

	return false
end

local wepsCache = {}
local weaponsByCategory = {}
local weaponsByOrder = {}
local weaponsByClass = {}
local selectedWeapon = -1
local lastCache = CurTime()
local function ensureWeapons(force)
	local weps = LocalPlayer():GetWeapons()

	if (lastCache <= CurTime() or force) then
		wepsCache = weps

		table.Empty(weaponsByCategory)
		table.Empty(weaponsByOrder)
		table.Empty(weaponsByClass)
		for k, cat in ipairs(categories) do
			local wepCat = k

			weaponsByCategory[wepCat] = {}
			for _, wep in pairs(weps) do
				if (getWeaponCat(wep) == wepCat) then
					local ind = table.insert(weaponsByCategory[wepCat], {
						Class = wep:GetClass(),
						Name = (weaponMap[wep:GetClass()] and weaponMap[wep:GetClass()].Name) or wep.PrintName or wep:GetClass(),
						Ent = wep
					})

					weaponsByClass[wep:GetClass()] = weaponsByCategory[wepCat][ind]
				end
			end

			table.sort(weaponsByCategory[wepCat], sorter)
		end

		for k, v in ipairs(categories) do
			for _, wep in ipairs(weaponsByCategory[k]) do
				local ind = table.insert(weaponsByOrder, wep)
				wep.ID = ind
			end
		end
	end

	if (selectedWeapon == 0 and IsValid(LocalPlayer():GetActiveWeapon()) and weaponsByClass[LocalPlayer():GetActiveWeapon():GetClass()]) then
		selectedWeapon = weaponsByClass[LocalPlayer():GetActiveWeapon():GetClass()].ID
	end

	lastCache = CurTime() + 0.25
end

local showTime = 0
local fadeTime = 0

local lastWep
local currentWep
local function switchWeapon(wep)
	wep = wep or weaponsByOrder[selectedWeapon]

	showTime = 0

	if not wep then
		return
	end

	lastWep = currentWep
	currentWep = wep

	if not IsValid(LocalPlayer():GetActiveWeapon()) or LocalPlayer():GetActiveWeapon() ~= wep.Ent then
		input.SelectWeapon(wep.Ent)
	else
		return
	end

	surface.PlaySound('buttons/lightswitch2.wav')
	return true
end

local color_white 		= ui.col.White
local color_flatblack 	= ui.col.FlatBlack
local color_background 	= ui.col.Background
local color_highlight 	= ui.col.TransWhite100
local color_sup 		= ui.col.SUP
local color_red 		= ui.col.Red

function GM:DrawWepSwitch()
	local st = SysTime()
	local w, h = 185, 35
	local x, y = (ScrW() - #categories * (w + 3)) * 0.5, 25 + math.sin(Lerp((st - fadeTime) / 0.5, 0, 1) * math.pi / 2) * 10

	if (showTime + 0.25 <= st) then return end
	ensureWeapons()

	if (showTime <= st) then
		surface.SetAlphaMultiplier(Lerp((st - showTime) / 0.2, 1, 0))
	else
		surface.SetAlphaMultiplier(Lerp((st - fadeTime) / 0.2, 0, 1))
	end

	for k, cat in ipairs(categories) do
		local x, y = x + ((k - 1) * (w + 3)), y
		local wepCat = k
		draw.Box(x, y, w, h, color_flatblack)
		draw.SimpleText(wepCat, 'ui.17', x + 3, y + 3, color_sup, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(cat, 'ui.20', x + (w * 0.5), y + (h * 0.5), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		for i, wep in ipairs(weaponsByCategory[wepCat]) do
			local y = y + (i * (h + 3))
			draw.Box(x, y, w, h, color_background)

			if (wep.ID == selectedWeapon) then
				draw.Box(x, y, w, h, color_highlight)
			end

			draw.SimpleText(wep.Name, 'ui.18', x + 5, y + 3, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

			if (not IsValid(wep.Ent)) then continue end

			local clip1, maxClip1 = wep.Ent:Clip1(), wep.Ent:GetMaxClip1()
			local isUnlimited = (maxClip1 < 1) and (clip1 < 1) or (not wep.Ent.DrawAmmo)

			draw.SimpleText(isUnlimited and '∞' or (clip1 .. '/' .. maxClip1) , 'ui.17', (x + w) - 5, (y + h) - 3, ((not isUnlimited) and (clip1 == 0)) and color_red or color_sup, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		end
	end
end

local lastSnd = 0
hook('PlayerBindPress', 'rp.wepswitch.PlayerBindPress', function(pl, bind, pressed)
	if (!pressed) then return end
	if (!LocalPlayer():Alive()) then return end
	if (!IsValid(LocalPlayer():GetActiveWeapon())) then return end
	if (table.Count(LocalPlayer():GetWeapons()) <= 1) then return end

	local wep = pl:GetActiveWeapon()

	if IsValid(wep) and wep.SWBWeapon and wep.dt and (wep.dt.State == SWB_AIMING) and wep.AdjustableZoom then
		return
	end

	if hook.Call('SuppressWeaponSwitcher', nil, pl, bind, pressed) then return end

	if ((bind == 'invprev') or (bind == 'lastinv') or (bind == 'invnext') or (string.sub(bind, 1, 4) == 'slot')) and (not pl:KeyDown(IN_ATTACK)) then
		if (bind == 'lastinv') and lastWep and IsValid(lastWep.Ent) then
			switchWeapon(lastWep)
			selectedWeapon = currentWep.ID
		elseif (string.sub(bind, 1, 3) == 'inv') then
			if (showTime < SysTime()) then
				ensureWeapons(true)
				selectedWeapon = 0
			else
				local scroll = (bind == 'invprev') and -1 or 1

				selectedWeapon = selectedWeapon + scroll
				if (!weaponsByOrder[selectedWeapon]) then
					selectedWeapon = (scroll == 1 and 1) or #weaponsByOrder
				end
			end
		else -- using number keys
			if (showTime < SysTime()) then
				ensureWeapons(true)
				fadeTime = SysTime()
			end

			local slot = tonumber(string.sub(bind, -1))

			if (!categories[slot]) then return end

			if (weaponsByCategory[slot][1]) then
				local found = false
				for k, v in ipairs(weaponsByCategory[slot]) do
					if (v.ID == selectedWeapon) then
						found = true

						if (weaponsByCategory[slot][k + 1]) then
							selectedWeapon = v.ID + 1
						else
							selectedWeapon = weaponsByCategory[slot][1].ID
						end

						break
					end
				end

				if (!found) then
					selectedWeapon = weaponsByCategory[slot][1].ID
				end
			end
		end

		ensureWeapons(true)
		showTime = SysTime() + 2

		if (lastSnd < SysTime() - 0.05) then
			surface.PlaySound('garrysmod/ui_hover.wav')--buttons/blip1.wav')
			lastSnd = SysTime()
		end
	elseif (showTime > SysTime() and bind == '+attack') then
		showTime = 0
		if (IsValid(LocalPlayer():GetActiveWeapon()) and weaponsByOrder[selectedWeapon] and weaponsByClass[LocalPlayer():GetActiveWeapon():GetClass()] and selectedWeapon != weaponsByClass[LocalPlayer():GetActiveWeapon():GetClass()].ID) then
			switchWeapon()
		end
		return true
	elseif (bind == 'phys_swap') then
		showTime = 0
	end
end)

local function openWeaponOrderPreview()
	if (!LocalPlayer():IsGA()) then return end

	local omit = {
		'weapon_base',
		'weapon_rape',
		'basecombatweapon',
		'weapon_rp_base',
		'swb_base',
		'weapon_ziptie_carrying',
		'baseknife',
		'weapon_struggle',
		'weapon_ziptied',
		'weapon_flechettegun'
	}

	ui.Create('ui_frame', function(self)
		local w, h = 185, 35
		local x, y = (ScrW() - #categories * (w + 3)) * 0.5, 35

		self:SetPos(x, y)
		self:SetSize(#categories * (w + 3) + 3, ScrH() - y * 2)
		self:SetTitle('Weapon Order Customization')
		self:SetDraggable(false)

		local weaponCategories = {}
		for k, v in ipairs(categories) do
			weaponCategories[k] = {
				Name = v,
				Weapons = {}
			}
		end

		local weps = weapons.GetList()

		for k, v in ipairs(weps) do
			if (table.HasValue(omit, v.ClassName)) then continue end

			v.Ent = weapons.GetStored(v.ClassName)
			v.Ent.ClassName = v.ClassName
			table.insert(weaponCategories[getWeaponCat(v.Ent)].Weapons, v)
		end

		for k, v in pairs(weaponMap) do
			local i = table.insert(weps, {
				ClassName = k,
				Ent = {
					ClassName = k,
					PrintName = v.Name
				}
			})

			table.insert(weaponCategories[getWeaponCat(weps[i].Ent)].Weapons, weps[i])
		end

		for k, v in ipairs(weaponCategories) do
			table.sort(v.Weapons, sorter)

			ui.Create('ui_scrollpanel', function(scr)
				local x, y = (k - 1) * (w + 3) + 3, 33
				scr:SetPos(x, y)
				scr:SetSize(w, self:GetTall() - y - 5)

				scr:AddItem(ui.Create('Panel', function(pnl)
					pnl:SetSize(w, h)
					pnl.Paint = function(s, w, h)
						draw.Box(0, 0, w, h, color_flatblack)
						draw.SimpleText(k, 'ui.17', 3, 3, color_sup, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
						draw.SimpleText(v.Name, 'ui.20', (w * 0.5), (h * 0.5), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
				end))

				for i, l in ipairs(v.Weapons) do
					scr:AddItem(ui.Create('Panel', function(pnl)
						pnl:SetSize(w, h)
						pnl.Paint = function(s, w, h)
							draw.Box(0, 0, w, h, color_background)
							local name = (weaponMap[l.ClassName] and weaponMap[l.ClassName].Name) or l.PrintName or l.ClassName
							draw.SimpleText(name, 'ui.18', 5, 3, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
						end
					end))
				end
			end, self)

		end


		self:MakePopup()
	end)
end
concommand.Add('openWeaponOrderPreview', openWeaponOrderPreview)
