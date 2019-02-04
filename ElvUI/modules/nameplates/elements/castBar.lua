local E, L, V, P, G = unpack(select(2, ...))
local mod = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

local unpack = unpack

local CreateFrame = CreateFrame

function mod:UpdateElement_CastBarOnValueChanged(value)
	local frame = self:GetParent():GetParent().UnitFrame
	if not frame.UnitType then return end
	if mod.db.units[frame.UnitType].castbar.enable ~= true then return end
	if mod.db.units[frame.UnitType].healthbar.enable ~= true and not (frame.isTarget and mod.db.alwaysShowTargetHealth) then return end

	local frame = self:GetParent():GetParent().UnitFrame
	local min, max = self:GetMinMaxValues()
	local isChannel = value < frame.CastBar:GetValue()
	frame.CastBar:SetMinMaxValues(min, max)
	frame.CastBar:SetValue(value)

	if isChannel then
		if frame.CastBar.channelTimeFormat == "CURRENT" then
			frame.CastBar.Time:SetFormattedText("%.1f", (max - value))
		elseif frame.CastBar.channelTimeFormat == "CURRENT_MAX" then
			frame.CastBar.Time:SetFormattedText("%.1f / %.1f", (max - value), max)
		else
			frame.CastBar.Time:SetFormattedText("%.1f", value)
		end
	else
		if frame.CastBar.castTimeFormat == "CURRENT" then
			frame.CastBar.Time:SetFormattedText("%.1f", value)
		elseif frame.CastBar.castTimeFormat == "CURRENT_MAX" then
			frame.CastBar.Time:SetFormattedText("%.1f / %.1f", value, max)
		else
			frame.CastBar.Time:SetFormattedText("%.1f", (max - value))
		end
	end

	if frame.CastBar.Spark then
		local sparkPosition = (value / max) * frame.CastBar:GetWidth()
		frame.CastBar.Spark:SetPoint("CENTER", frame.CastBar, "LEFT", sparkPosition, 0)
	end

	if self.Shield:IsShown() then
		frame.CastBar:SetStatusBarColor(mod.db.castNoInterruptColor.r, mod.db.castNoInterruptColor.g, mod.db.castNoInterruptColor.b)
	else
		frame.CastBar:SetStatusBarColor(mod.db.castColor.r, mod.db.castColor.g, mod.db.castColor.b)
	end

	frame.CastBar.Name:SetText(self.Name:GetText())
	frame.CastBar.Icon.texture:SetTexture(self.Icon:GetTexture())
end

function mod:UpdateElement_CastBarOnShow()
	local frame = self:GetParent():GetParent().UnitFrame
	if not frame.UnitType then return end
	if mod.db.units[frame.UnitType].castbar.enable ~= true then return end
	if mod.db.units[frame.UnitType].healthbar.enable ~= true and not (frame.isTarget and mod.db.alwaysShowTargetHealth) then return end

	self:GetParent():GetParent().UnitFrame.CastBar:Show()
end

function mod:UpdateElement_CastBarOnHide()
	local frame = self:GetParent():GetParent().UnitFrame
	if not frame.UnitType then return end
	if mod.db.units[frame.UnitType].castbar.enable ~= true then return end
	if mod.db.units[frame.UnitType].healthbar.enable ~= true and not (frame.isTarget and mod.db.alwaysShowTargetHealth) then return end

	self:GetParent():GetParent().UnitFrame.CastBar:Hide()
end

function mod:ConfigureElement_CastBar(frame)
	if not frame.UnitType then return end

	local castBar = frame.CastBar

	castBar:ClearAllPoints()
	castBar:SetPoint("TOPLEFT", frame.HealthBar, "BOTTOMLEFT", 0, -self.db.units[frame.UnitType].castbar.offset)
	castBar:SetPoint("TOPRIGHT", frame.HealthBar, "BOTTOMRIGHT", 0, -self.db.units[frame.UnitType].castbar.offset)
	castBar:SetHeight(self.db.units[frame.UnitType].castbar.height)

	castBar.Icon:ClearAllPoints()
	if self.db.units[frame.UnitType].castbar.iconPosition == "RIGHT" then
		castBar.Icon:SetPoint("TOPLEFT", frame.HealthBar, "TOPRIGHT", self.db.units[frame.UnitType].castbar.offset, 0)
		castBar.Icon:SetPoint("BOTTOMLEFT", castBar, "BOTTOMRIGHT", self.db.units[frame.UnitType].castbar.offset, 0)
	elseif self.db.units[frame.UnitType].castbar.iconPosition == "LEFT" then
		castBar.Icon:SetPoint("TOPRIGHT", frame.HealthBar, "TOPLEFT", -self.db.units[frame.UnitType].castbar.offset, 0)
		castBar.Icon:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMLEFT", -self.db.units[frame.UnitType].castbar.offset, 0)
	end
	castBar.Icon:SetWidth(self.db.units[frame.UnitType].castbar.height + self.db.units[frame.UnitType].healthbar.height + self.db.units[frame.UnitType].castbar.offset)
	castBar.Icon.texture:SetTexCoord(unpack(E.TexCoords))

	castBar.Time:SetPoint("TOPRIGHT", castBar, "BOTTOMRIGHT", 0, -E.Border*3)
	castBar.Name:SetPoint("TOPLEFT", castBar, "BOTTOMLEFT", 0, -E.Border*3)
	castBar.Name:SetPoint("TOPRIGHT", castBar.Time, "TOPLEFT")
	castBar.Name:SetJustifyH("LEFT")
	castBar.Name:SetJustifyV("TOP")
	castBar.Name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	castBar.Time:SetJustifyH("RIGHT")
	castBar.Time:SetJustifyV("TOP")
	castBar.Time:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)

	if self.db.units[frame.UnitType].castbar.hideSpellName then
		castBar.Name:Hide()
	else
		castBar.Name:Show()
	end
	if self.db.units[frame.UnitType].castbar.hideTime then
		castBar.Time:Hide()
	else
		castBar.Time:Show()
	end

	castBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))

	castBar.castTimeFormat = self.db.units[frame.UnitType].castbar.castTimeFormat
	castBar.channelTimeFormat = self.db.units[frame.UnitType].castbar.channelTimeFormat
end

function mod:ConstructElement_CastBar(parent)
	local function updateGlowPosition()
		if not parent then return end

		mod:UpdatePosition_Glow(parent)
	end

	local frame = CreateFrame("StatusBar", "$parentCastBar", parent)
	self:StyleFrame(frame)
	frame:SetScript("OnShow", updateGlowPosition)
	frame:SetScript("OnHide", updateGlowPosition)

	frame.Icon = CreateFrame("Frame", nil, frame)
	frame.Icon.texture = frame.Icon:CreateTexture(nil, "BORDER")
	frame.Icon.texture:SetAllPoints()
	self:StyleFrame(frame.Icon)

	frame.Name = frame:CreateFontString(nil, "OVERLAY")
	frame.Name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	frame.Name:SetWordWrap(false)

	frame.Time = frame:CreateFontString(nil, "OVERLAY")
	frame.Time:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	frame.Time:SetWordWrap(false)

	frame.Spark = frame:CreateTexture(nil, "OVERLAY")
	frame.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	frame.Spark:SetBlendMode("ADD")
	frame.Spark:SetSize(15, 15)

	frame:Hide()

	return frame
end