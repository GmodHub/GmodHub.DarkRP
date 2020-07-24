term.Add('CannotAlterGenome', 'Вы не можете изменить ваш геном в данный момент.')
term.Add('GenomeAltered', 'Вы выбрали: ##% Сопротивления Урону, #% Скорости, and #% Атаки.')
term.Add('GenomeOverflowed', 'Геном переполнен! Все характеристики сброшены.')

nw.Register('CanGenomeDisguise')
	:Read(net.ReadBool)
	:Write(net.WriteBool)
	:SetLocalPlayer()

-- TODO replace
local conversionTable = {
	['Glock'] = 'swb_glock18',
	['Палка Ареста'] = 'arrest_baton',
	['Оглушающая Палка'] = 'stun_baton',
	['Таран'] = 'door_ram',
	['Возможность Замаскироваться'] = '\0',
	['Дробовик'] = 'swb_m3super90',
	['Тазер'] = 'weapon_taser',
	['TMP'] = 'swb_tmp',
	['UMP-45'] = 'swb_ump',
	['P90'] = 'swb_p90',
	['M4A1'] = 'swb_m4a1',
	['Famas'] = 'swb_famas',
	['Щит'] = 'weapon_shield',
	['Автоматический Дробовик'] = 'swb_xm1014',
	['AWP'] = 'swb_awp',
	['MP5'] = 'swb_mp5',
	['M249'] = 'swb_m249',
	['Aug'] = 'swb_aug'
}

local function convertlo(LO)
	if (SERVER) then
		for k, v in pairs(LO) do
			if (conversionTable[v]) then
				LO[k] = conversionTable[v]
				--print(" - converted to " .. conversionTable[v])
			end
		end
	end
end


function rp.GetGenomeSpecialName(D, S, A)
	local n = 'Полицейский'
	local m = 'models/player/Police.mdl'

	if (D == 20) then
		n = 'Джаггернаут'
		m = 'models/player/Combine_Soldier.mdl'
	elseif (S == 20) then
		n = 'Скаут'
		m = 'models/player/riot.mdl'
	elseif (A == 20) then
		n = 'Элита'
		m = 'models/player/Combine_Super_Soldier.mdl'
	else
		if (S == 10 and D == 0 and A == 0) then
			n = 'Шпион'
			m = 'models/player/gasmask.mdl'
		elseif (D > 10 and S > 10) then
			n = 'Разведчик'
			m = 'models/player/swat.mdl'
		elseif (D > 10 and A > 10) then
			n = 'ОМОН'
			m = 'models/player/Combine_Soldier_PrisonGuard.mdl'
		elseif (S > 10 and A > 10) then
			n = 'Штурмовик'
			m = 'models/player/urban.mdl'
		elseif (D == 0 and S == 0 and A == 0) then
			n = 'Снайпер'
			m = 'models/player/swat.mdl'
		end
	end

	return n, m
end

function rp.GetGenomeLoadout(D, S, A)
	local LO = {}
	LO[1] = 'Glock'
	LO[2] = 'Палка Ареста'
	LO[3] = 'Оглушающая Палка'
	LO[4] = 'Таран'

	if (S == 10) and (A == 0) and (D == 0) then
		LO[6] = 'Возможность Замаскироваться'
		convertlo(LO)
		return LO
	elseif (D == 0 and S == 0 and A == 0) then
		LO[7] = 'AWP'
	elseif (S < 12) and (A < 12) and (D < 12) then
		LO[9] = 'Дробовик'
		LO[10] = 'Тазер'
		convertlo(LO)
		return LO
	end

	if (S >= 12) then
		LO[6] = 'TMP'
		if (S >= 16) then
			LO[6] = 'Тазер'
			if (S >= 20) then
				LO[6] = 'UMP-45'
			end
		end
	end

	if (A >= 12) then
		LO[7] = 'Дробовик'
		if (A >= 16) then
			LO[7] = 'P90'
			if (A >= 20) then
				LO[7] = 'M4A1'
			end
		end
	end

	if (D >= 12) then
		LO[8] = 'Famas'
		if (D >= 16) then
			LO[8] = 'Щит'
			if (D >= 20) then
				LO[8] = 'Автоматический Дробовик'
			end
		end
	end

	if (D == 20 and S == 0 and A == 0) then LO[8] = 'M249' end
	if (D == 0 and S == 20 and A == 0) then LO[5] = 'MP5' end
	if (D == 0 and S == 0 and A == 20) then LO[9] = 'Aug' end

	convertlo(LO)

	return LO
end
