if (SERVER) then
	util.AddNetworkString('_AntiCrash')

	timer.Create('AntiCrash', 5, 0, function()
		net.Start('_AntiCrash')
		net.Broadcast()
	end)
elseif (CLIENT) then
	surface.CreateFont ('AntiCrash.Font', {
		font = 'Prototype [RUS by Daymarius]',
		size = 50,
		weight = 300,
		extended = true
	})

	local NextReTry = false
	local IsCrashed = false
	local ReconnectTime = 0
	local ReconnectTrys = 0
	local Crash_Frame

	local function StartAutoconect()
		ReconnectTime = CurTime() + 25 + math.random(0, 20)

		if IsValid(Crash_Frame) then Crash_Frame:Remove() end

		Crash_Frame = ui.Create('DFrame')
		Crash_Frame:SetSize(475, 125)
		Crash_Frame:SetPos(ScrW(), 0)
		Crash_Frame:MoveTo(ScrW() - 475, 0, 0.3, 0, 1)
		Crash_Frame:SetTitle('')
		Crash_Frame:ShowCloseButton(false)
		Crash_Frame.btnMinim:SetVisible(false)
		Crash_Frame.btnMaxim:SetVisible(false)
		function Crash_Frame:Paint(w, h)
			local delta = math.Clamp(ReconnectTime - CurTime(), 1, 40)
			draw.OutlinedBox(0, 0,w, h , ui.col.Black, (delta % 1 < 0.2 and ui.col.Red or ui.col.Outline))
			draw.SimpleText('Переподключение:', 'AntiCrash.Font', w/2, 10, ui.col.White, TEXT_ALIGN_CENTER)
			draw.SimpleText(math.ceil(delta), 'AntiCrash.Font', w*0.5, 75, delta % 1 < 0.2 and ui.col.Red or ui.col.White, TEXT_ALIGN_CENTER)
		end
	end

	local function statuserror()
		LocalPlayer():ChatPrint('ОШИБКА ПЕРЕПОДКЛЮЧЕНИЯ: НЕ УДАЛОСЬ ПРОВЕРИТЬ СТАТУС СЕРВЕРА. ВЫ БУДЕТЕ ПЕРЕПОДКЛЮЧЕНЫ КАК ТОЛЬКО СЕРВЕР БУДЕТ ОНЛАЙН!')
	end

	local function connect(ip)
		LocalPlayer():ConCommand('connect ' .. ip)
	end

	local function CheckStatus()
		ReconnectTime = CurTime() + 15
		http.Fetch('https://gmodhub.com/api/anticrash.php', function(body)
			body = string.Trim(body):lower()

			print(body)

			if (body:len() > 30) then
				statuserror()
				return
			end

			if (body ~= info.ServerIP:lower()) then
				ReconnectTime = CurTime() + 15
				ReconnectTrys = ReconnectTrys + 1
				function Crash_Frame:Paint(w, h)
					local delta = math.Clamp(ReconnectTime - CurTime(), 1, 45)
					draw.OutlinedBox(0, 0,w, h , ui.col.Black, (delta % 1 < 0.2 and ui.col.Red or ui.col.Outline))
					draw.SimpleText('Попытка Переподключения:', 'AntiCrash.Font', w/2, 10, ui.col.White, TEXT_ALIGN_CENTER)
					draw.SimpleText('#' .. ReconnectTrys, 'AntiCrash.Font', w*0.5, 75, delta % 1 < 0.2 and ui.col.Red or ui.col.White, TEXT_ALIGN_CENTER)
				end
			else
				connect(info.ServerIP)
			end
		end, statuserror)
	end

	hook.Add('Think', 'AntiCrash.Think', function()
		if NextReTry and (not IsCrashed) and (NextReTry < CurTime()) then
			IsCrashed = true
			StartAutoconect()
		elseif IsCrashed and (ReconnectTime <= CurTime()) then
			if info and info.ServerIP and info.AltServerIP and (ReconnectTrys < 10) then
				CheckStatus()
			elseif info and info.ServerIP and info.AltServerIP and (ReconnectTrys >= 10) then
				connect(info.AltServerIP)
			else
				connect(info.ServerIP)
			end
		end
	end)

	local function reset()
		ReconnectTrys = 0
		NextReTry = CurTime() + 10
		IsCrashed = false
		if IsValid(Crash_Frame) then
			Crash_Frame:Remove()
		end
	end
	net.Receive('_AntiCrash', reset)
	hook.Add('IncomingNetMessage', reset)

	hook.Add('InitPostEntity', 'AntiCrash.InitPostEntity', function()
		RunConsoleCommand('cl_timeout', '9999999999999')
	end)
end
