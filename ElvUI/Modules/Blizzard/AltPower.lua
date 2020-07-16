local E, L, V, P, G = unpack(select(2, ...))
local B = E:GetModule("Blizzard")
local LSM = E.Libs.LSM

local floor = math.floor
local format = string.format

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local UnitAlternatePowerInfo = UnitAlternatePowerInfo
local UnitPowerMax = UnitPowerMax
local UnitPower = UnitPower

local function updateTooltip(self)
	if self.powerName and self.powerTooltip then
		GameTooltip:SetText(self.powerName, 1, 1, 1)
		GameTooltip:AddLine(self.powerTooltip, nil, nil, nil, 1)
		GameTooltip:Show()
	end
end

local function onEnter(self)
	if not self:IsVisible() then return end

	GameTooltip:ClearAllPoints()
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	updateTooltip(self)
end

local function onLeave()
	GameTooltip:Hide()
end

function B:SetAltPowerBarText(text, name, value, max, percent)
	local textFormat = E.db.general.altPowerBar.textFormat

	if textFormat == "NONE" or not textFormat then
		text:SetText("")
	elseif textFormat == "NAME" then
		text:SetText(format("%s", name))
	elseif textFormat == "NAMEPERC" then
		text:SetText(format("%s: %s%%", name, percent))
	elseif textFormat == "NAMECURMAX" then
		text:SetText(format("%s: %s / %s", name, value, max))
	elseif textFormat == "NAMECURMAXPERC" then
		text:SetText(format("%s: %s / %s - %s%%", name, value, max, percent))
	elseif textFormat == "PERCENT" then
		text:SetText(format("%s%%", percent))
	elseif textFormat == "CURMAX" then
		text:SetText(format("%s / %s", value, max))
	elseif textFormat == "CURMAXPERC" then
		text:SetText(format("%s / %s - %s%%", value, max, percent))
	end
end

function B:PositionAltPower()
	self:Point("CENTER", AltPowerBarHolder, "CENTER")
end

function B:PositionAltPowerBar()
	local holder = CreateFrame("Frame", "AltPowerBarHolder", E.UIParent)
	holder:Point("TOP", E.UIParent, "TOP", 0, -18)
	holder:Size(128, 50)

	PlayerPowerBarAlt:ClearAllPoints()
	PlayerPowerBarAlt:Point("CENTER", holder, "CENTER")
	PlayerPowerBarAlt:SetParent(holder)
	PlayerPowerBarAlt.ignoreFramePositionManager = true

	--The Blizzard function FramePositionDelegate:UIParentManageFramePositions()
	--calls :ClearAllPoints on PlayerPowerBarAlt under certain conditions.
	--Doing '.ClearAllPoints = E.noop' causes error when you enter combat.
	hooksecurefunc(PlayerPowerBarAlt, "ClearAllPoints", B.PositionAltPower)

	E:CreateMover(holder, "AltPowerBarMover", L["Alternative Power"], nil, nil, nil, nil, nil, "general,alternativePowerGroup")
end

function B:UpdateAltPowerBarColors()
	local bar = ElvUI_AltPowerBar

	if E.db.general.altPowerBar.statusBarColorGradient then
		if bar.colorGradientR and bar.colorGradientG and bar.colorGradientB then
			bar:SetStatusBarColor(bar.colorGradientR, bar.colorGradientG, bar.colorGradientB)
		elseif bar.powerValue then
			local power, maxPower = bar.powerValue or 0, bar.powerMaxValue or 0
			local value = (maxPower > 0 and power / maxPower) or 0
			bar.colorGradientValue = value

			local r, g, b = E:ColorGradient(value, 0.8,0,0, 0.8,0.8,0, 0,0.8,0)
			bar.colorGradientR, bar.colorGradientG, bar.colorGradientB = r, g, b

			bar:SetStatusBarColor(r, g, b)
		else
			bar:SetStatusBarColor(0.6, 0.6, 0.6)
		end
	else
		local color = E.db.general.altPowerBar.statusBarColor
		bar:SetStatusBarColor(color.r, color.g, color.b)
	end
end

function B:UpdateAltPowerBarSettings()
	local bar = ElvUI_AltPowerBar
	local db = E.db.general.altPowerBar

	bar:Size(db.width or 250, db.height or 20)
	bar:SetStatusBarTexture(LSM:Fetch("statusbar", db.statusBar))
	bar.text:FontTemplate(LSM:Fetch("font", db.font), db.fontSize or 12, db.fontOutline or "OUTLINE")
	AltPowerBarHolder:Size(bar.backdrop:GetSize())

	E:SetSmoothing(bar, db.smoothbars)

	B:SetAltPowerBarText(bar.text, bar.powerName or "", bar.powerValue or 0, bar.powerMaxValue or 0, bar.powerPercent or 0)
end

function B:UpdateAltPowerBar()
	PlayerPowerBarAlt:UnregisterAllEvents()
	PlayerPowerBarAlt:Hide()

	local barInfo, minPower, _, _, _, _, _, _, _, powerName, powerTooltip = UnitAlternatePowerInfo("player")

	if barInfo then
		local power = UnitPower("player", ALTERNATE_POWER_INDEX)
		local maxPower = UnitPowerMax("player", ALTERNATE_POWER_INDEX) or 0
		local perc = (maxPower > 0 and floor(power / maxPower * 100)) or 0

		self.powerMaxValue = maxPower
		self.powerName = powerName
		self.powerPercent = perc
		self.powerTooltip = powerTooltip
		self.powerValue = power

		self:Show()
		self:SetMinMaxValues(minPower, maxPower)
		self:SetValue(power)

		if E.db.general.altPowerBar.statusBarColorGradient then
			local value = (maxPower > 0 and power / maxPower) or 0
			self.colorGradientValue = value

			local r, g, b = E:ColorGradient(value, 0.8,0,0, 0.8,0.8,0, 0,0.8,0)
			self.colorGradientR, self.colorGradientG, self.colorGradientB = r, g, b

			self:SetStatusBarColor(r, g, b)
		end

		B:SetAltPowerBarText(self.text, powerName or "", power or 0, maxPower, perc)
	else
		self.powerMaxValue = nil
		self.powerName = nil
		self.powerPercent = nil
		self.powerTooltip = nil
		self.powerValue = nil

		self:Hide()
	end
end

function B:SkinAltPowerBar()
	if not E.db.general.altPowerBar.enable then return end

	local powerbar = CreateFrame("StatusBar", "ElvUI_AltPowerBar", E.UIParent)
	powerbar:CreateBackdrop(nil, true)
	powerbar:SetMinMaxValues(0, 200)
	powerbar:Point("CENTER", AltPowerBarHolder)
	powerbar:Hide()

	powerbar:SetScript("OnEnter", onEnter)
	powerbar:SetScript("OnLeave", onLeave)

	powerbar.text = powerbar:CreateFontString(nil, "OVERLAY")
	powerbar.text:Point("CENTER", powerbar, "CENTER")
	powerbar.text:SetJustifyH("CENTER")

	B:UpdateAltPowerBarSettings()
	B:UpdateAltPowerBarColors()

	--Event handling
	powerbar:RegisterEvent("UNIT_POWER_FREQUENT")
	powerbar:RegisterEvent("UNIT_POWER_BAR_SHOW")
	powerbar:RegisterEvent("UNIT_POWER_BAR_HIDE")
	powerbar:RegisterEvent("PLAYER_ENTERING_WORLD")

	powerbar:SetScript("OnEvent", B.UpdateAltPowerBar)
end