halo = {
	Add = function() end,
}

hook.Add("PostDrawEffects", "rp.RenderHalos", function()
	hook.Run("PreDrawHalos")
end)