-- We don't use these so lets reduce the overhead of calling them instead of making them empty!
timer.Simple(0.5, function()
	local GM = GAMEMODE
	/*GM.HUDDrawTargetID 					= nil
	GM.DrawDeathNotice 					= nil
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
	GM.PreDrawOpaqueRenderables 		= nil
	GM.PostDrawOpaqueRenderables 		= nil
	GM.PreDrawTranslucentRenderables 	= nil
	GM.PostDrawTranslucentRenderables 	= nil
	GM.PreDrawViewModel 				= nil
	GM.PostDrawViewModel 				= nil
	GM.HUDPaintBackground 				= nil
	GM.HUDDrawScoreBoard 				= nil
	GM.PostRenderVGUI 					= nil
	GM.PostRender 						= nil*/
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
	["gm_showhelp"] = "ShowHelp",
	["gm_showteam"] = "ShowTeam",
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
		:Download('https://superiorservers.co/static/images/textless_logo.png', function(s, material)
			Material('logos/sup'):SetTexture('$basetexture', material:GetTexture('$basetexture'))
		end)
end)
