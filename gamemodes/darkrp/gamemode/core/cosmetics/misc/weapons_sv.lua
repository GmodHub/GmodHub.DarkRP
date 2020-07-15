rp.AddCommand('weaponmaterial', function(pl, material)
  local wep = pl:GetActiveWeapon()
  if (not IsValid(wep)) or (string.sub(wep:GetClass(), 0, 3) ~= 'swb') then return end
	if not rp.WeaponMaterials[material] then
    rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotMaterialThisWeapon'))
    return
  end

	if not pl:CanAfford(rp.WeaponMaterials[material]) then
		rp.Notify(pl, NOTIFY_ERROR, term.Get('CannotAfford'))
		return
	end
  
  pl:TakeMoney(rp.WeaponMaterials[material])
  rp.Notify(pl, NOTIFY_SUCCESS, term.Get("SetWepMaterial"))

  net.Start("rp.cosmetrics.WeaponSkin")
    net.WriteEntity(wep)
    net.WriteString(material)
  net.Send(pl)
end)
:AddParam(cmd.STRING)
