-- We don't use these so lets reduce the overhead of calling them instead of making them empty!
timer.Simple(0.5, function()
	local GM = GAMEMODE
	GM.HUDDrawTargetID 					= nil
	GM.DrawDeathNotice 					= nil
	GM.HUDDrawPickupHistory 		= nil
	GM.GUIMouseDoublePressed 		= nil
	GM.PostProcessPermitted			= nil
	GM.ForceDermaSkin						= nil
	GM.OnAchievementAchieved		= nil
	GM.PreventScreenClicks			= nil
	GM.GetMotionBlurValues 			= nil
	GM.PreRender 						= nil
	GM.RenderScene 						= nil
	GM.PostDrawHUD 						= nil
	GM.DrawOverlay 						= nil
	GM.PreDrawHUD 						= nil
	GM.DrawMonitors 					= nil
	GM.PreDrawEffects 					= nil
	GM.PostDrawEffects 					= nil
	GM.PreDrawHalos 					= nil
	GM.CloseDermaMenus 					= nil
	GM.PostDraw2DSkyBox 				= nil
	//GM.PreDrawOpaqueRenderables 		= nil
	//GM.PostDrawOpaqueRenderables 		= nil
	//GM.PreDrawTranslucentRenderables 	= nil
	//GM.PostDrawTranslucentRenderables 	= nil
	GM.HUDPaintBackground 				= nil
	GM.HUDDrawScoreBoard 				= nil
	GM.PostRenderVGUI 					= nil
	GM.PostRender 						= nil
end)

timer.Simple(1, function()
	local fn = function() return false end

	render.SupportsHDR = fn
	render.SupportsPixelShaders_2_0 = fn
	render.SupportsPixelShaders_1_4 = fn
	render.SupportsVertexShaders_2_0 = fn

	function render.GetDXLevel()
			return 75
	end
end)

timer.Create('Tweaks_Calc', 2.5, 0, function()
		range = player.GetCount() > 80 and 4000000 or 9000000
		local ratio = 2
		local lerp = 60
		local online = #player.GetAll()

		if online > 90 then
				lerp = math.Clamp(online * ratio, 60, 250)
		end

		RunConsoleCommand("cl_interp", lerp / 1000)
end)

-- Voice
hook('PlayerStartVoice', 'rp.voice.PlayerStartVoice', function(pl)
	if (pl == LocalPlayer()) then
		net.Ping 'rp.StartVoice'
	end
end)

hook('PlayerEndVoice', 'rp.voice.PlayerEndVoice', function(pl)
	if (pl == LocalPlayer()) then
		net.Ping 'rp.EndVoice'
	end
end)


local GUIToggled = false
local mouseX, mouseY = ScrW() / 2, ScrH() / 2
function GM:ShowSpare1()
	if LocalPlayer():IsBanned() then return end
	GUIToggled = not GUIToggled

	if GUIToggled then
		gui.SetMousePos(mouseX, mouseY)
	else
		mouseX, mouseY = gui.MousePos()
	end
	gui.EnableScreenClicker(GUIToggled)
end

local FKeyBinds = {
	["gm_showteam"] = "ShowHelp",
	["gm_showspare1"] = "ShowSpare1",
	["gm_showspare2"] = "ShowSpare2"
}

function GM:PlayerBindPress(ply, bind, pressed)
	if LocalPlayer():IsBanned() then return end

	local bnd = string.match(string.lower(bind), "gm_[a-z]+[12]?")
	if bnd and FKeyBinds[bnd] and GAMEMODE[FKeyBinds[bnd]] then
		GAMEMODE[FKeyBinds[bnd]](GAMEMODE)
	end
	return
end

hook('PlayerCloseLoadInScreen', 'rp.spawn.PlayerCloseLoadInScreen', function()
	cmd.Run('spawn')
end)

hook('InitPostEntity', function()
	texture.Create('SUP')
		:EnableProxy(false)
		:Download('https://gmodhub.com/static/images/favicon.png', function(s, material)
			Material('logos/sup'):SetTexture('$basetexture', material:GetTexture('$basetexture'))
		end)
end)
