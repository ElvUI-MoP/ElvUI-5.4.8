local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

local CreateFrame = CreateFrame
local GetComboPoints = GetComboPoints
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

function NP:Update_CPoints(frame)
	if frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "FRIENDLY_NPC" or (frame.UnitTrivial and NP.db.trivial) then return end
	if not self.db.units[frame.UnitType].comboPoints.enable then return end

	local numPoints
	if frame.isTarget then
		numPoints = GetComboPoints("player", "target")
	end

	if numPoints and numPoints > 0 then
		frame.CPoints:Show()

		for i = 1, MAX_COMBO_POINTS do
			if NP.db.units[frame.UnitType].comboPoints.hideEmpty then
				frame.CPoints[i]:SetShown(i <= numPoints)
			else
				local r, g, b = unpack(E:GetColorTable(self.db.colors.comboPoints[i]))
				local mult = i <= numPoints and 1 or 0.35

				frame.CPoints[i]:SetStatusBarColor(r * mult, g * mult, b * mult)
				frame.CPoints[i]:Show()
			end
		end
	else
		frame.CPoints:Hide()
	end
end

function NP:Configure_CPointsScale(frame, scale, noPlayAnimation)
	if frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "FRIENDLY_NPC" then return end

	local db = self.db.units[frame.UnitType].comboPoints
	if not db or (db and not db.enable) then return end

	if noPlayAnimation then
		frame.CPoints:SetWidth(((db.width * 5) + (db.spacing * 4)) * scale)
		frame.CPoints:SetHeight(db.height * scale)
	else
		if frame.CPoints.scale:IsPlaying() then
			frame.CPoints.scale:Stop()
		end

		frame.CPoints.scale.width:SetChange(((db.width * 5) + (db.spacing * 4)) * scale)
		frame.CPoints.scale.height:SetChange(db.height * scale)
		frame.CPoints.scale:Play()
	end
end

function NP:Configure_CPoints(frame, configuring)
	if frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "FRIENDLY_NPC" then return end
	local db = self.db.units[frame.UnitType].comboPoints
	if not db.enable then return end

	local comboPoints = frame.CPoints
	local healthShown = self.db.units[frame.UnitType].health.enable or (frame.isTarget and self.db.alwaysShowTargetHealth)

	comboPoints:ClearAllPoints()
	if healthShown then
		comboPoints:Point("CENTER", frame.Health, "BOTTOM", db.xOffset, db.yOffset)
	else
		comboPoints:Point("CENTER", frame, "TOP", db.xOffset, db.yOffset)
	end

	for i = 1, MAX_COMBO_POINTS do
		comboPoints[i]:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
		comboPoints[i]:SetStatusBarColor(unpack(E:GetColorTable(self.db.colors.comboPoints[i])))

		if i == 3 then
			comboPoints[i]:Point("CENTER", comboPoints, "CENTER")
		elseif i == 1 or i == 2 then
			comboPoints[i]:Point("RIGHT", comboPoints[i + 1], "LEFT", -db.spacing, 0)
		else
			comboPoints[i]:Point("LEFT", comboPoints[i - 1], "RIGHT", db.spacing, 0)
		end

		comboPoints[i]:Width(healthShown and db.width * (frame.ThreatScale or 1) * (NP.db.useTargetScale and NP.db.targetScale or 1) or db.width)
		comboPoints[i]:Height(healthShown and db.height * (frame.ThreatScale or 1) * (NP.db.useTargetScale and NP.db.targetScale or 1) or db.height)
	end

	comboPoints.spacing = db.spacing * (MAX_COMBO_POINTS - 1)

	if configuring then
		self:Configure_CPointsScale(frame, frame.currentScale or 1, configuring)
	end
end

local function CPoints_OnSizeChanged(self, width)
	width = width - self.spacing

	for i = 1, MAX_COMBO_POINTS do
		self[i]:SetWidth(width * 0.2)
	end
end

function NP:Construct_CPoints(parent)
	local comboBar = CreateFrame("Frame", "$parentComboPoints", parent)
	comboBar:SetSize(68, 1)
	comboBar:Hide()

	comboBar.scale = CreateAnimationGroup(comboBar)
	comboBar.scale.width = comboBar.scale:CreateAnimation("Width")
	comboBar.scale.width:SetDuration(0.2)
	comboBar.scale.height = comboBar.scale:CreateAnimation("Height")
	comboBar.scale.height:SetDuration(0.2)

	comboBar:SetScript("OnSizeChanged", CPoints_OnSizeChanged)

	for i = 1, MAX_COMBO_POINTS do
		comboBar[i] = CreateFrame("StatusBar", "$parentComboPoint"..i, comboBar)

		self:StyleFrame(comboBar[i])
	end

	return comboBar
end