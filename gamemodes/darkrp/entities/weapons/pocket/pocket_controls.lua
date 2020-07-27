local pocketBits = 8

function rp.inv.Add(ID, Title, SubTitle, Model)
	for k, v in ipairs(rp.inv.Data) do
		if (v.ID == ID) then
			v.Title = Title
			v.SubTitle = SubTitle
			v.Model = Model

			return
		end
	end

	table.insert(rp.inv.Data, {
		ID = ID,
		Title = Title,
		SubTitle = SubTitle,
		Model = Model
	});
end

function rp.inv.Remove(ID)
	if (!ID) then return; end

	if isnumber(ID) then
		for k, v in pairs(rp.inv.Data) do
			if (v.ID == ID) then
				table.remove(rp.inv.Data, k);
				return;
			end
		end
	end
end

function rp.inv.EnableMenu(pl, contents)
	if (rp.inv.UI and rp.inv.UI:IsValid()) then return; end

	rp.inv.UI = vgui.Create("Pocket");

	if (contents) then
		rp.inv.UI:InitInspect(pl, contents)
	else
		rp.inv.UI:InitLocal()
	end
end

function rp.inv.DisableMenu()
  if (!rp.inv.UI or !rp.inv.UI:IsValid()) then return; end
	rp.inv.UI:Close();
end

function rp.inv.Inspect(pl, contents, nKeys)
	for k, v in pairs(contents) do
		v.ID = k
		v.Class = nKeys[v.Class]
		v.Model = nKeys[v.Model]

		if (v.contents and v.contents != 0) then
			v.Title = rp.shipments[v.contents].name
			v.SubTitle = 'Количество: ' .. v.count
		elseif (v.contents and v.contents == 0) then
			v.Title = 'Empty Shipment'
			v.SubTitle = 'Количество: 0'
		else
			v.Title = rp.inv.Wl[v.Class]
			v.SubTitle = ''
		end
	end

	rp.inv.EnableMenu(pl, contents)
end

net.Receive("Pocket.Load", function(len)
	local dat = {}

	for i=1, net.ReadUInt(pocketBits) do
		local id = net.ReadUInt(pocketBits)

		dat[id] = {
			Class = net.ReadUInt(pocketBits+1),
			Model = net.ReadUInt(pocketBits+1)
		}

		local isShip = net.ReadBit() == 1
		if (isShip) then
			dat[id].contents = net.ReadUInt(7)
			dat[id].count = net.ReadUInt(5)
		end
	end

	local nKeys = {}
	for i=1, net.ReadUInt(pocketBits+1) do
		nKeys[i] = net.ReadString()
	end

	local inspecting = net.ReadBit() == 1
	if (inspecting) then
		rp.inv.Inspect(net.ReadPlayer(), dat, nKeys)
	else
		for k, v in pairs(dat) do
			v.Class = nKeys[v.Class]
			v.Model = nKeys[v.Model]
			if v.contents and (v.contents ~= 0) then
				rp.inv.Add(k, rp.shipments[v.contents].name, 'Количество: ' .. v.count, v.Model)
			elseif v.contents and (v.contents == 0) then
				rp.inv.Add(k, 'Empty Shipment', 'Количество: 0', v.Model)
			else
				rp.inv.Add(k, rp.inv.Wl[v.Class], "", v.Model)
			end
		end
	end
end)

net.Receive("Pocket.AddItem", function()
	LocalPlayer():AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
	rp.inv.Add(net.ReadUInt(pocketBits), net.ReadString(), net.ReadString(), net.ReadString())
	rp.inv.DisableMenu()
end)

net.Receive("Pocket.RemoveItem", function()
	LocalPlayer():AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
	rp.inv.Remove(net.ReadUInt(pocketBits))
	rp.inv.DisableMenu()
end)
