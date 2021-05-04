local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

local unpack = unpack
local abs = math.abs

local CreateFrame = CreateFrame

local function resetAttributes(frame)
	frame.casting = nil
	frame.channeling = nil
	frame.notInterruptible = nil
	frame.spellName = nil
end

function NP:Update_CastBarOnValueChanged(value)
	local frame = self:GetParent():GetParent().UnitFrame
	if not frame.UnitType then return end
	if not NP.db.units[frame.UnitType].castbar.enable then return end
	if not NP.db.units[frame.UnitType].health.enable and not (frame.isTarget and NP.db.alwaysShowTargetHealth) then return end

	local castBar = frame.CastBar

	local min, max = self:GetMinMaxValues()
	local cur = castBar:GetValue()

	castBar.spellName = self.Name:GetText()
	castBar.casting = value > cur
	castBar.channeling = value < cur
	castBar.notInterruptible = frame.oldCastBar.Shield:IsShown()

	castBar:SetMinMaxValues(min, max)
	castBar:SetValue(value)

	if castBar.channeling then
		if castBar.channelTimeFormat == "CURRENT" then
			castBar.Time:SetFormattedText("%.1f", abs(value - max))
		elseif castBar.channelTimeFormat == "CURRENTMAX" then
			castBar.Time:SetFormattedText("%.1f / %.2f", abs(value - max), max)
		elseif castBar.channelTimeFormat == "REMAINING" then
			castBar.Time:SetFormattedText("%.1f", value)
		elseif castBar.channelTimeFormat == "REMAININGMAX" then
			castBar.Time:SetFormattedText("%.1f / %.2f", value, max)
		end
	else
		if castBar.castTimeFormat == "CURRENT" then
			castBar.Time:SetFormattedText("%.1f", value)
		elseif castBar.castTimeFormat == "CURRENTMAX" then
			castBar.Time:SetFormattedText("%.1f / %.2f", value, max)
		elseif castBar.castTimeFormat == "REMAINING" then
			castBar.Time:SetFormattedText("%.1f", abs(value - max))
		elseif castBar.castTimeFormat == "REMAININGMAX" then
			castBar.Time:SetFormattedText("%.1f / %.2f", abs(value - max), max)
		end
	end

	if castBar.Spark then
		local sparkPosition = (value / max) * castBar:GetWidth()

		castBar.Spark:SetPoint("CENTER", castBar, "LEFT", sparkPosition, 0)
	end

	if castBar.notInterruptible then
		castBar:SetStatusBarColor(NP.db.colors.castNoInterruptColor.r, NP.db.colors.castNoInterruptColor.g, NP.db.colors.castNoInterruptColor.b)

		if NP.db.colors.castbarDesaturate then
			castBar.Icon.texture:SetDesaturated(true)
		end
	else
		castBar:SetStatusBarColor(NP.db.colors.castColor.r, NP.db.colors.castColor.g, NP.db.colors.castColor.b)
		castBar.Icon.texture:SetDesaturated(false)
	end

	castBar.Name:SetText(castBar.spellName)
	castBar.Icon.texture:SetTexture(self.Icon:GetTexture())

	NP:StyleFilterUpdate(frame, "FAKE_Casting")
end

function NP:Update_CastBarOnShow()
	local frame = self:GetParent():GetParent().UnitFrame
	local db = NP.db.units[frame.UnitType]

	local healthShown = db.health.enable or (frame.isTarget and NP.db.alwaysShowTargetHealth)
	local noFilter = frame.NameOnlyChanged == nil and frame.IconOnlyChanged == nil
	local noTrivial = not (frame.UnitTrivial and NP.db.trivial)

	if db.castbar.enable and healthShown and noFilter and noTrivial then
		resetAttributes(frame.CastBar)
		frame.CastBar:Show()

		NP:StyleFilterUpdate(frame, "FAKE_Casting")
	end
end

function NP:Update_CastBarOnHide()
	local frame = self:GetParent():GetParent().UnitFrame

	resetAttributes(frame.CastBar)
	frame.CastBar:Hide()

	NP:StyleFilterUpdate(frame, "FAKE_Casting")
end

function NP:Configure_CastBarScale(frame, scale, noPlayAnimation)
	if frame.currentScale == scale then return end

	local db = self.db.units[frame.UnitType].castbar
	if not db or (db and not db.enable) then return end

	local castBar = frame.CastBar

	if noPlayAnimation then
		castBar:SetSize(db.width * scale, db.height * scale)
		castBar.Icon:SetSize(db.iconSize * scale, db.iconSize * scale)
	else
		if castBar.scale:IsPlaying() or castBar.Icon.scale:IsPlaying() then
			castBar.scale:Stop()
			castBar.Icon.scale:Stop()
		end

		castBar.scale.width:SetChange(db.width * scale)
		castBar.scale.height:SetChange(db.height * scale)
		castBar.scale:Play()

		castBar.Icon.scale.width:SetChange(db.iconSize * scale)
		castBar.Icon.scale.height:SetChange(db.iconSize * scale)
		castBar.Icon.scale:Play()
	end
end

function NP:Configure_CastBar(frame, configuring)
	local db = self.db.units[frame.UnitType].castbar
	local castBar = frame.CastBar

	castBar:SetPoint("TOP", frame.Health, "BOTTOM", db.xOffset, db.yOffset)

	if db.showIcon then
		castBar.Icon:ClearAllPoints()
		castBar.Icon:SetPoint(db.iconPosition == "RIGHT" and "BOTTOMLEFT" or "BOTTOMRIGHT", castBar, db.iconPosition == "RIGHT" and "BOTTOMRIGHT" or "BOTTOMLEFT", db.iconOffsetX, db.iconOffsetY)
		castBar.Icon:Show()
	else
		castBar.Icon:Hide()
	end

	castBar.Time:ClearAllPoints()
	castBar.Name:ClearAllPoints()

	castBar.Spark:SetPoint("CENTER", castBar:GetStatusBarTexture(), "RIGHT", 0, 0)
	castBar.Spark:SetHeight(db.height * 2)

	if db.textPosition == "BELOW" then
		castBar.Time:SetPoint("TOPRIGHT", castBar, "BOTTOMRIGHT")
		castBar.Name:SetPoint("TOPLEFT", castBar, "BOTTOMLEFT")
	elseif db.textPosition == "ABOVE" then
		castBar.Time:SetPoint("BOTTOMRIGHT", castBar, "TOPRIGHT")
		castBar.Name:SetPoint("BOTTOMLEFT", castBar, "TOPLEFT")
	else
		castBar.Time:SetPoint("RIGHT", castBar, "RIGHT", -4, 0)
		castBar.Name:SetPoint("LEFT", castBar, "LEFT", 4, 0)
	end

	if configuring then
		self:Configure_CastBarScale(frame, frame.currentScale or 1, configuring)
	end

	castBar.Name:FontTemplate(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
	castBar.Time:FontTemplate(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)

	castBar.Name:SetShown(not db.hideSpellName)
	castBar.Time:SetShown(not db.hideTime)

	castBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))

	castBar.castTimeFormat = db.castTimeFormat
	castBar.channelTimeFormat = db.channelTimeFormat
end

function NP:Construct_CastBar(parent)
	local frame = CreateFrame("StatusBar", "$parentCastBar", parent)
	NP:StyleFrame(frame)

	frame.Icon = CreateFrame("Frame", nil, frame)
	frame.Icon.texture = frame.Icon:CreateTexture(nil, "BORDER")
	frame.Icon.texture:SetAllPoints()
	frame.Icon.texture:SetTexCoord(unpack(E.TexCoords))
	NP:StyleFrame(frame.Icon)

	frame.Time = frame:CreateFontString(nil, "OVERLAY")
	frame.Time:SetJustifyH("RIGHT")
	frame.Time:SetWordWrap(false)

	frame.Name = frame:CreateFontString(nil, "OVERLAY")
	frame.Name:SetJustifyH("LEFT")
	frame.Name:SetWordWrap(false)

	frame.Spark = frame:CreateTexture(nil, "OVERLAY")
	frame.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	frame.Spark:SetBlendMode("ADD")
	frame.Spark:SetSize(15, 15)

	frame.scale = CreateAnimationGroup(frame)
	frame.scale.width = frame.scale:CreateAnimation("Width")
	frame.scale.width:SetDuration(0.2)
	frame.scale.height = frame.scale:CreateAnimation("Height")
	frame.scale.height:SetDuration(0.2)

	frame.Icon.scale = CreateAnimationGroup(frame.Icon)
	frame.Icon.scale.width = frame.Icon.scale:CreateAnimation("Width")
	frame.Icon.scale.width:SetDuration(0.2)
	frame.Icon.scale.height = frame.Icon.scale:CreateAnimation("Height")
	frame.Icon.scale.height:SetDuration(0.2)

	frame:Hide()

	return frame
end