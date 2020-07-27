local badhooks = {
	RenderScreenspaceEffects = {
		'RenderBloom',
		'RenderBokeh',
		--'RenderColorModify',
		--'RenderMotionBlur',
		'RenderMaterialOverlay',
		'RenderSharpen',
		'RenderSobel',
		'RenderStereoscopy',
		'RenderSunbeams',
		'RenderTexturize',
		'RenderToyTown',
	},
	PreDrawHalos = {
		'PropertiesHover'
	},
	RenderScene = {
		'RenderSuperDoF',
		'RenderStereoscopy',
	},
	PreRender = {
		'PreRenderFlameBlend',
	},
	PostRender = {
		'RenderFrameBlend',
		'PreRenderFrameBlend',
	},
	PostDrawEffects = {
		'RenderWidgets',
		'RenderHalos',
	},
	GUIMousePressed = {
		'SuperDOFMouseDown',
		'SuperDOFMouseUp'
	},
	Think = {
		'DOFThink',
	},
	PlayerTick = {
		'TickWidgets',
	},
	PlayerBindPress = {
		'PlayerOptionInput'
	},
	NeedsDepthPass = {
		'NeedsDepthPass_Bokeh',
	},
	OnGamemodeLoaded = {
		'CreateMenuBar',
	}
}

local function RemoveHooks()
	for k, v in pairs(badhooks) do
		for _, h in ipairs(v) do
			hook.Remove(k, h)
		end
	end
end

hook('InitPostEntity', 'RemoveHooks', RemoveHooks)
RemoveHooks()

if CLIENT then
	PLAYER._Team = PLAYER._Team or PLAYER.Team

	function PLAYER:Team()
		local t = self:_Team()
		return (t == 0) and 1 or t
	end
end
