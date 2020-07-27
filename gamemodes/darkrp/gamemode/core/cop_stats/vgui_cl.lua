local PANEL = {}
local MatCircle = Material('materials/gmh/gui/circle.png', 'smooth')

function PANEL:Init()
	self.Points = {}

	self.PointsOffset = 3

	self:SetOffsetTarget(0)
end

function PANEL:Paint(w, h)
	surface.SetFont('ui.22')

	surface.SetTextColor(255, 255, 255)
	surface.SetDrawColor(200, 200, 200)

	surface.SetMaterial(MatCircle)
	surface.DrawTexturedRect(self.CenterX - self.Radius - 5, self.CenterY - self.Radius - 5, self.Radius * 2 + 10, self.Radius * 2 + 10) -- Draw circle slightly larger because overlap

	local individualPolies = {}
	local pointsPoly = {}
	local lastPointPos

	for k, v in pairs(self.Points) do
		if (self.Points[k+1]) then	-- Draw line to next point
			surface.DrawLine(self.CenterX + v.PosX, self.CenterY + v.PosY, self.CenterX + self.Points[k+1].PosX, self.CenterY + self.Points[k+1].PosY)
		else						-- Draw line to first point
			surface.DrawLine(self.CenterX + v.PosX, self.CenterY + v.PosY, self.CenterX + self.Points[1].PosX, self.CenterY + self.Points[1].PosY)
		end

		-- Draw line from center to edge
		if (v.Hovered and !v.Selected) then
			surface.SetDrawColor(50, 155, 50)
				surface.DrawLine(self.CenterX, self.CenterY, self.CenterX + v.PosX, self.CenterY + v.PosY)
				surface.DrawLine(self.CenterX - 1, self.CenterY - 1, self.CenterX + v.PosX - 1, self.CenterY + v.PosY - 1)
				surface.DrawLine(self.CenterX + 1, self.CenterY + 1, self.CenterX + v.PosX + 1, self.CenterY + v.PosY + 1)
			surface.SetDrawColor(200, 200, 200)
		else
			surface.DrawLine(self.CenterX, self.CenterY, self.CenterX + v.PosX, self.CenterY + v.PosY)
		end

		-- point's actual location
		local pointPos = {x = self.CenterX + (v.Multiplier * v.RatioX * self.Radius), y = self.CenterY + (v.Multiplier * v.RatioY * self.Radius)}
		table.insert(pointsPoly, pointPos)

		-- insert small poly here
		local individualPoly = {
			{x = self.CenterX, y = self.CenterY},
			lastPointPos or nil,
			pointPos
		}
		table.insert(individualPolies, individualPoly)

		lastPointPos = pointPos

		local tw, th = surface.GetTextSize(v.Name)
		local addToX = ((tw / 2) + 10) * v.RatioX
		local addToY = ((th / 2) + 10) * v.RatioY

		surface.SetTextPos((self.CenterX + v.PosX) - (tw / 2) + addToX, self.CenterY + v.PosY - (th / 2) + addToY)
		surface.DrawText(v.Name)
	end

	-- patch first individual poly
	individualPolies[1][2] = (individualPolies[#individualPolies][3] or {x = self.CenterX, y = self.CenterY})

	-- draw inner poly
	surface.SetDrawColor(100, 100, 255, 50)
	draw.NoTexture()
	for k, v in pairs(individualPolies) do
		surface.DrawPoly(v)
	end

	surface.SetDrawColor(100, 100, 255, 225)
	for k, v in pairs(pointsPoly) do
		if (pointsPoly[k+1]) then
			surface.DrawLine(v.x, v.y, pointsPoly[k+1].x, pointsPoly[k+1].y)
		else
			surface.DrawLine(v.x, v.y, pointsPoly[1].x, pointsPoly[1].y)
		end
	end

	if (self.PointsOffset == self.PointsOffsetTarget) then -- Draw the neato slider (but only if it's not moving)
		local stat = self.SelectedStat

		self.BoxDim = self.BoxDim or {}
		self.BoxDim.x = self.CenterX + (stat.Multiplier * self.Radius) - 4
		self.BoxDim.y = self.CenterY - 11

		local mx, my = self:CursorPos()

		if (mx >= self.BoxDim.x and mx <= self.BoxDim.x + 8 and my >= self.BoxDim.y and my <= self.BoxDim.y + 20) then
			surface.SetDrawColor(100, 100, 100, 150)
			surface.DrawRect(self.BoxDim.x, self.BoxDim.y, 8, 20)
		end

		if (stat.Dragging) then surface.SetDrawColor(50, 255, 50)
		else surface.SetDrawColor(100, 100, 100, 50) end
			surface.DrawRect(self.BoxDim.x, self.BoxDim.y, 8, 20)
		surface.SetDrawColor(255, 255, 255)
			surface.DrawOutlinedRect(self.BoxDim.x, self.BoxDim.y, 8, 20)
	end
end

function PANEL:Think()
	self:HandleMouseMovement()

	if (self.PointsOffset != self.PointsOffsetTarget) then
		local diff = self.PointsOffsetTarget - self.LastPointsOffset
		local diffTime = math.Clamp(SysTime() - self.LastPointsOffsetTime, 0, 0.5)

		if (diffTime >= 0.5) then -- Force the values
			self.PointsOffset = self.PointsOffsetTarget
		else
			self.PointsOffset = self.LastPointsOffset + math.sin(diffTime * math.pi) * diff
		end

		self:BuildPoints(self.PointsOffset)
	end
end

function PANEL:OnMousePressed(mb)
	if (!self.BoxDim) then return end

	for k, v in pairs(self.Points) do
		if (v.Hovered) then
			if (v.Selected) then
				local minX = self.BoxDim.x
				local minY = self.BoxDim.y
				local maxX = minX + 8
				local maxY = minY + 20

				local mx, my = self:CursorPos()
				-- Check if they're on slider
				if (mx >= minX - 5 and mx <= maxX + 5 and my >= minY - 5 and my <= maxY + 5) then
					v.Dragging = true
				end
			else
				self:SelectStat(v)
			end
		else
			self:DeSelectStat(v)
		end
	end
end

function PANEL:OnMouseReleased(mb)
	for k, v in pairs(self.Points) do
		v.Dragging = false
	end
end

function PANEL:SelectStat(stat)
	self.SelectedStat = stat

	stat.Selected = true

	self:SetOffsetTarget(-stat.Offset)
end

function PANEL:DeSelectStat(stat)
	stat.Selected = false
end

function PANEL:SetOffsetTarget(val)
	local change = val - self.PointsOffset
	local rem = change % (math.pi * 2)

	-- Update the value to reflect a change relative to half of itself. That way the circle doesn't make a 360 when it could just make a 10.
	if (rem > math.pi) then
		val = self.PointsOffset - ((math.pi * 2) - rem)
	else
		val = self.PointsOffset + rem
	end

	self.LastPointsOffset = self.PointsOffset
	self.LastPointsOffsetTime = SysTime()
	self.PointsOffsetTarget = val
end

function PANEL:HandleMouseMovement()
	-- mouse input
	local mx, my = self:CursorPos()
	mx = mx - self.CenterX
	my = my - self.CenterY

	local selected = 0
	local dist = math.huge

	if (Vector(mx, my, 0):Distance(Vector(0, 0, 0)) < self.Radius) then
		local mNormal = Vector(mx, my, 0):GetNormal()
		local mMax = Vector(self.CenterX + (mNormal.x * self.Radius), self.CenterY + (mNormal.y * self.Radius), 0)

		for k, v in pairs(self.Points) do
			local vMax = Vector(self.CenterX + v.PosX, self.CenterY + v.PosY)

			local dist = vMax:Distance(mMax)
			if (dist < 100) then
				selected = k
				distance = dist
			end
		end
	end

	for k, v in pairs(self.Points) do
		if (selected == k or (selected == 0 and v.Hovered)) then
			v.Hovered = true
		else
			v.Hovered = false
		end
	end

	local stat = self.SelectedStat
	if (stat.Dragging) then
		local newVal = math.Round(math.Clamp(mx, 0, self.Radius) / (self.Radius / self.MaxPerPoint))

		self:UpdateStat(stat, newVal)
	end
end

function PANEL:BuildPoints(offset)
	local w = self:GetWide()
	local h = self:GetTall()

	offset = (offset or 0)

	local numPoints = #self.Points

	local radius = (h * 0.8) / 2

	for k, v in pairs(self.Points) do
		local actualPos = 2 * math.pi * (k - 0) / numPoints

		local xCos = math.cos(actualPos + offset)
		local ySin = math.sin(actualPos + offset)

		local xVal = ((radius * xCos) - 1)
		local yVal = ((radius * ySin) - 1)
		v.Offset = (2 * math.pi) / #self.Points * k -- The point needs to be 0 to aim right
		v.xCos = xCos
		v.ySin = ySin
		v.PosX = xVal
		v.PosY = yVal
		v.RatioX = xVal / radius
		v.RatioY = yVal / radius
	end

	self.CenterX = w / 2
	self.CenterY = h / 2
	self.Radius = radius
end

function PANEL:UpdateStat(stat, points, ignoreLimit)
	if (isstring(stat)) then
		for k, v in ipairs(self.Points) do
			if (v.Name == stat) then
				stat = v
				break
			end
		end

		if (isstring(stat)) then return end
	end

	local top = self.MaxPerPoint
	local rem = self.RemainingPoints + (stat.Value or 0)
	if (!ignoreLimit and points <= top and rem - points < 0) then
		top = rem
	end
	points = math.Clamp(points, 0, top)
	self.RemainingPoints = rem - points

	stat.Value = points
	stat.Multiplier = (1 / self.MaxPerPoint) + (points / (self.MaxPerPoint + 1))
end

function PANEL:SetPoints(numPoints, maxPerPoint, points)
	self.RebuildOnRebuild = true

	self.TotalPoints = numPoints
	self.RemainingPoints = numPoints
	self.Points = {}
	self.MaxPerPoint = maxPerPoint

	for k, v in pairs(points) do
		local newPoint = {}
			newPoint.Name = k

		self:UpdateStat(newPoint, v)

		table.insert(self.Points, newPoint)
	end

	self:BuildPoints()

	self:SelectStat(self.Points[1])
end

function PANEL:GetPoints()
	local ret = {}
	local maxPoints = self.TotalPoints
	local remPoints = self.RemainingPoints

	for k, v in pairs(self.Points) do
		ret[v.Name] = {
			Value = v.Value,
			Percent = v.Multiplier
		}
	end

	return ret, maxPoints, remPoints
end

function PANEL:PerformLayout()
	if (self.RebuildOnRebuild) then
		self:BuildPoints()
	end
end

vgui.Register('rp_constellation', PANEL, 'Panel')
