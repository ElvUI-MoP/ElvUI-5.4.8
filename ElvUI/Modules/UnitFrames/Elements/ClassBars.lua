local E, L, V, P, G = unpack(select(2, ...))
local UF = E:GetModule("UnitFrames")

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

local unpack = unpack
local max = max

local CreateFrame = CreateFrame

function UF:Configure_ClassBar(frame)
	if not frame.VARIABLES_SET then return end
	local bars = frame[frame.ClassBar]
	if not bars then return end

	local db = frame.db
	bars.Holder = frame.ClassBarHolder
	bars.origParent = frame

	--Fix height in case it is lower than the theme allows, or in case it's higher than 30px when not detached
	if not UF.thinBorders and (frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 7) then --A height of 7 means 6px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 7
		if db.classbar then db.classbar.height = 7 end
		UF.ToggleResourceBar(bars) --Trigger update to health if needed
	elseif UF.thinBorders and (frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 3) then --A height of 3 means 2px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 3
		if db.classbar then db.classbar.height = 3 end
		UF.ToggleResourceBar(bars) --Trigger update to health if needed
	elseif not frame.CLASSBAR_DETACHED and frame.CLASSBAR_HEIGHT > 30 then
		frame.CLASSBAR_HEIGHT = 10
		if db.classbar then db.classbar.height = 10 end
		--Override visibility if Classbar is Additional Power in order to fix a bug when Auto Hide is enabled, height is higher than 30 and it goes from detached to not detached
		UF.ToggleResourceBar(bars, frame.ClassBar == "AdditionalPower") --Trigger update to health if needed
	end

	--We don't want to modify the original frame.CLASSBAR_WIDTH value, as it bugs out when the classbar gains more buttons
	local CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		if frame.MAX_CLASS_BAR == 1 or frame.ClassBar == "EclipseBar" or frame.ClassBar == "AdditionalPower" or frame.ClassBar == "AlternativePower" or frame.ClassBar == "DemonicFury" then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * 2 / 3
		else
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * (frame.MAX_CLASS_BAR - 1) / frame.MAX_CLASS_BAR
		end
	elseif frame.CLASSBAR_DETACHED then
		CLASSBAR_WIDTH = db.classbar.detachedWidth - ((UF.BORDER + UF.SPACING) * 2)
	end

	bars:Width(CLASSBAR_WIDTH)
	bars:Height(frame.CLASSBAR_HEIGHT - ((UF.BORDER + UF.SPACING) * 2))

	local color = E.db.unitframe.colors.borderColor
	if not bars.backdrop.ignoreBorderColors then
		bars.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
	end

	local vertical = frame.CLASSBAR_DETACHED and db.classbar.verticalOrientation

	if frame.ClassBar == "ClassPower" or frame.ClassBar == "SpecPower" or frame.ClassBar == "Runes" or frame.ClassBar == "BurningEmbers" or frame.ClassBar == "SoulShards" then
		bars.backdrop:SetShown(not frame.USE_MINI_CLASSBAR and frame.USE_CLASSBAR)

		local maxClassBarButtons = max(UF.classMaxResourceBar[E.myclass] or 0)
		for i = 1, maxClassBarButtons do
			bars[i]:Hide()

			if i <= frame.MAX_CLASS_BAR then
				if not bars[i].backdrop.ignoreBorderColors then
					bars[i].backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
				end
				bars[i]:Height(bars:GetHeight())

				if frame.MAX_CLASS_BAR == 1 then
					bars[i]:Width(CLASSBAR_WIDTH)
				elseif frame.USE_MINI_CLASSBAR then
					if frame.CLASSBAR_DETACHED and db.classbar.orientation == "VERTICAL" then
						bars[i]:Width(CLASSBAR_WIDTH)
					else
						bars[i]:Width((CLASSBAR_WIDTH - ((5 + (UF.BORDER * 2 + UF.SPACING * 2)) * (frame.MAX_CLASS_BAR - 1))) / frame.MAX_CLASS_BAR) --Width accounts for 5px spacing between each button, excluding borders
					end
				elseif i ~= frame.MAX_CLASS_BAR then
					bars[i]:Width((CLASSBAR_WIDTH - ((frame.MAX_CLASS_BAR - 1) * (UF.BORDER + UF.SPACING * 3))) / frame.MAX_CLASS_BAR) --classbar width minus total width of dividers between each button, divided by number of buttons
				end

				bars[i]:GetStatusBarTexture():SetHorizTile(false)
				bars[i]:SetOrientation(vertical and "VERTICAL" or "HORIZONTAL")
				bars[i]:ClearAllPoints()

				if i == 1 then
					bars[i]:Point("LEFT", bars)
				else
					if frame.USE_MINI_CLASSBAR then
						if frame.CLASSBAR_DETACHED and db.classbar.orientation == "VERTICAL" then
							bars[i]:Point("BOTTOM", bars[i - 1], "TOP", 0, (db.classbar.spacing + UF.BORDER * 2 + UF.SPACING * 2))
						elseif frame.CLASSBAR_DETACHED and db.classbar.orientation == "HORIZONTAL" then
							bars[i]:Point("LEFT", bars[i - 1], "RIGHT", (db.classbar.spacing + UF.BORDER * 2 + UF.SPACING * 2), 0) --5px spacing between borders of each button(replaced with Detached Spacing option)
						else
							bars[i]:Point("LEFT", bars[i - 1], "RIGHT", (5 + UF.BORDER * 2 + UF.SPACING * 2), 0) --5px spacing between borders of each button
						end
					elseif i == frame.MAX_CLASS_BAR then
						bars[i]:Point("LEFT", bars[i - 1], "RIGHT", UF.BORDER + UF.SPACING * 3, 0)
						bars[i]:Point("RIGHT", bars)
					else
						bars[i]:Point("LEFT", bars[i - 1], "RIGHT", UF.BORDER + UF.SPACING * 3, 0)
					end
				end

				if E.myclass == "MONK" or E.myclass == "ROGUE" then
					bars[i]:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass][i]))
				elseif E.myclass == "PALADIN" or E.myclass == "PRIEST" or E.myclass == "MAGE" then
					bars[i]:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass]))
				elseif E.myclass == "WARLOCK" then
					if frame.ClassBar == "SoulShards" then
						bars[i]:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass][1]))
					elseif frame.ClassBar == "BurningEmbers" then
						bars[i]:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass][3]))
					end
				end

				bars[i]:Show()
			end
		end
	elseif frame.ClassBar == "EclipseBar" then
		local lunarTex = bars.LunarBar:GetStatusBarTexture()

		bars.LunarBar:SetMinMaxValues(0, 0)
		bars.LunarBar:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass][1]))
		bars.LunarBar:Size(CLASSBAR_WIDTH, frame.CLASSBAR_HEIGHT - ((UF.BORDER + UF.SPACING) * 2))
		bars.LunarBar:SetOrientation(vertical and "VERTICAL" or "HORIZONTAL")
		E:SetSmoothing(bars.LunarBar, UF.db.smoothbars)

		bars.SolarBar:SetMinMaxValues(0, 0)
		bars.SolarBar:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass][2]))
		bars.SolarBar:Size(CLASSBAR_WIDTH, frame.CLASSBAR_HEIGHT - ((UF.BORDER + UF.SPACING) * 2))
		bars.SolarBar:SetOrientation(vertical and "VERTICAL" or "HORIZONTAL")
		bars.SolarBar:ClearAllPoints()
		bars.SolarBar:Point(vertical and "BOTTOM" or "LEFT", lunarTex, vertical and "TOP" or "RIGHT")
		E:SetSmoothing(bars.SolarBar, UF.db.smoothbars)

		bars.Arrow:ClearAllPoints()
		bars.Arrow:Point("CENTER", lunarTex, vertical and "TOP" or "RIGHT", 0, vertical and -4 or 0)
	elseif frame.ClassBar == "AdditionalPower" or frame.ClassBar == "AlternativePower" or frame.ClassBar == "DemonicFury" then
		bars:SetOrientation(vertical and "VERTICAL" or "HORIZONTAL")

		if frame.ClassBar == "DemonicFury" then
			bars:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass][2]))
		end
	end

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		bars:ClearAllPoints()
		bars:Point("CENTER", frame.Health.backdrop, "TOP", 0, 0)

		bars:SetParent(frame)
		bars:SetFrameLevel(50) --RaisedElementParent uses 100, we want it lower than this

		if bars.Holder and bars.Holder.mover then
			E:DisableMover(bars.Holder.mover:GetName())
		end
	elseif frame.CLASSBAR_DETACHED then
		if frame.USE_MINI_CLASSBAR and not (frame.MAX_CLASS_BAR == 1 or frame.ClassBar == "AdditionalPower" or frame.ClassBar == "EclipseBar") then
			local widthMult = UF.classMaxResourceBar[E.myclass] - 1
			if db.classbar.orientation == "HORIZONTAL" then
				bars.Holder:Size(db.classbar.detachedWidth + (db.classbar.spacing * widthMult) - (widthMult * 5), db.classbar.height)
			else
				bars.Holder:Size(db.classbar.detachedWidth, (db.classbar.height * UF.classMaxResourceBar[E.myclass]) + (db.classbar.spacing * widthMult))
			end
		else
			bars.Holder:Size(db.classbar.detachedWidth, db.classbar.height)
		end

		bars:ClearAllPoints()
		bars:Point("BOTTOMLEFT", bars.Holder, "BOTTOMLEFT", UF.BORDER + UF.SPACING, UF.BORDER + UF.SPACING)

		if not bars.Holder.mover then
			E:CreateMover(bars.Holder, "ClassBarMover", L["Classbar"], nil, nil, nil, "ALL,SOLO", nil, "unitframe,individualUnits,player,classbar")
		else
			E:EnableMover(bars.Holder.mover:GetName())
		end

		bars:SetParent(db.classbar.parent == "UIPARENT" and E.UIParent or frame)
		bars:SetFrameStrata(db.classbar.strataAndLevel.useCustomStrata and "LOW" or db.classbar.strataAndLevel.frameStrata)
		bars:SetFrameLevel(db.classbar.strataAndLevel.useCustomLevel and db.classbar.strataAndLevel.frameLevel or frame.Health:GetFrameLevel() + 10) --Health uses 10, Power uses (Health + 5) when attached
	else
		bars:ClearAllPoints()

		if frame.ORIENTATION == "RIGHT" then
			bars:Point("BOTTOMRIGHT", frame.Health.backdrop, "TOPRIGHT", -UF.BORDER, UF.SPACING * 3)
		else
			bars:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", UF.BORDER, UF.SPACING * 3)
		end

		bars:SetParent(frame)
		bars:SetFrameStrata("LOW")
		bars:SetFrameLevel(frame.Health:GetFrameLevel() + 10) --Health uses 10, Power uses (Health + 5) when attached

		if bars.Holder and bars.Holder.mover then
			E:DisableMover(bars.Holder.mover:GetName())
		end
	end

	if frame.CLASSBAR_DETACHED and db.classbar.parent == "UIPARENT" then
		E.FrameLocks[bars] = true
	else
		E.FrameLocks[bars] = nil
	end

	if frame.USE_CLASSBAR then
		if frame.ClassPower and not frame:IsElementEnabled("ClassPower") then
			frame:EnableElement("ClassPower")
		end
		if frame.SpecPower and not frame:IsElementEnabled("SpecPower") then
			frame:EnableElement("SpecPower")
		end
		if frame.Runes and not frame:IsElementEnabled("Runes") then
			frame:EnableElement("Runes")
		end
		if frame.EclipseBar and not frame:IsElementEnabled("EclipseBar") then
			frame:EnableElement("EclipseBar")
		end
		if frame.AdditionalPower and not frame:IsElementEnabled("AdditionalPower") then
			frame:EnableElement("AdditionalPower")
		end
		if frame.DemonicFury and not frame:IsElementEnabled("DemonicFury") then
			frame:EnableElement("DemonicFury")
		end
		if frame.BurningEmbers and not frame:IsElementEnabled("BurningEmbers") then
			frame:EnableElement("BurningEmbers")
		end
		if frame.SoulShards and not frame:IsElementEnabled("SoulShards") then
			frame:EnableElement("SoulShards")
		end
		if frame.AlternativePower and not frame:IsElementEnabled("AlternativePower") then
			frame:EnableElement("AlternativePower")
		end
	else
		if frame.ClassPower and frame:IsElementEnabled("ClassPower") then
			frame:DisableElement("ClassPower")
		end
		if frame.SpecPower and frame:IsElementEnabled("SpecPower") then
			frame:DisableElement("SpecPower")
		end
		if frame.Runes and frame:IsElementEnabled("Runes") then
			frame:DisableElement("Runes")
		end
		if frame.EclipseBar and frame:IsElementEnabled("EclipseBar") then
			frame:DisableElement("EclipseBar")
		end
		if frame.AdditionalPower and frame:IsElementEnabled("AdditionalPower") then
			frame:DisableElement("AdditionalPower")
		end
		if frame.DemonicFury and frame:IsElementEnabled("DemonicFury") then
			frame:DisableElement("DemonicFury")
		end
		if frame.BurningEmbers and frame:IsElementEnabled("BurningEmbers") then
			frame:DisableElement("BurningEmbers")
		end
		if frame.SoulShards and frame:IsElementEnabled("SoulShards") then
			frame:DisableElement("SoulShards")
		end
		if frame.AlternativePower and frame:IsElementEnabled("AlternativePower") then
			frame:DisableElement("AlternativePower")
		end
	end
end

local function ToggleResourceBar(bars, overrideVisibility)
	local frame = bars.origParent or bars:GetParent()
	local db = frame.db
	if not db then return end

	frame.CLASSBAR_SHOWN = (not not overrideVisibility) or bars:IsShown()

	local height = (db.classbar and db.classbar.height) or (db.combobar and db.combobar.height)
	frame.CLASSBAR_HEIGHT = (frame.USE_CLASSBAR and (frame.CLASSBAR_SHOWN and height) or 0)
	frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and ((UF.SPACING + (frame.CLASSBAR_HEIGHT / 2))) or (frame.CLASSBAR_HEIGHT - (UF.BORDER - UF.SPACING)))

	UF:Configure_CustomTexts(frame)
	UF:Configure_HealthBar(frame, true)
	UF:Configure_Portrait(frame, true)
end
UF.ToggleResourceBar = ToggleResourceBar

function UF:PostVisibility_ClassBars(frame, stateChanged)
	if not (frame and frame.db) then return end

	if stateChanged then
		ToggleResourceBar(frame[frame.ClassBar])
		UF:Configure_ClassBar(frame)
		UF:Configure_Power(frame, true)
		UF:Configure_InfoPanel(frame, true)
	end
end

-------------------------------------------------------------
-- PALADIN, MONK, PRIEST
-------------------------------------------------------------
function UF:Construct_ClassBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	local maxBars = max(UF.classMaxResourceBar[E.myclass] or 0)
	for i = 1, maxBars do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassIconButton"..i, bars)
		bars[i]:SetStatusBarTexture(E.media.blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF.statusbars[bars[i]] = true

		bars[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		bars[i].backdrop:SetParent(bars)

		bars[i].bg = bars:CreateTexture(nil, "BORDER")
		bars[i].bg:SetAllPoints(bars[i])
		bars[i].bg:SetTexture(E.media.blankTex)
		bars[i].bg:SetParent(bars[i].backdrop)
	end

	bars.PostUpdate = UF.UpdateClassBar
	bars.UpdateColor = E.noop --We handle colors on our own in Configure_ClassBar
	bars.UpdateTexture = E.noop --We don't use textures but statusbars, so prevent errors

	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

function UF:UpdateClassBar(current, maxBars, hasMaxChanged)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return end

	local isShown = self:IsShown()
	local stateChanged

	if not frame.USE_CLASSBAR or (current == 0 and db.classbar.autoHide) or maxBars == nil then
		self:Hide()
		if isShown then
			stateChanged = true
		end
	else
		self:Show()
		if not isShown then
			stateChanged = true
		end
	end

	if hasMaxChanged then
		frame.MAX_CLASS_BAR = maxBars
		UF:Configure_ClassBar(frame, current)
	elseif stateChanged then
		UF:Configure_ClassBar(frame, current)
	end

	local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
	for i = 1, #self do
		if custom_backdrop then
			self[i].bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
		else
			local r, g, b = self[i]:GetStatusBarColor()
			self[i].bg:SetVertexColor(r * 0.35, g * 0.35, b * 0.35)
		end

		self[i].bg:SetShown(maxBars and (i <= maxBars))
	end
end

-------------------------------------------------------------
-- MAGE, ROGUE
-------------------------------------------------------------
function UF:Construct_SpecPower(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	for i = 1, UF.classMaxResourceBar[E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
		bars[i]:SetStatusBarTexture(E.media.blankTex)
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF.statusbars[bars[i]] = true

		bars[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		bars[i].backdrop:SetParent(bars)

		bars[i].bg = bars:CreateTexture(nil, "BORDER")
		bars[i].bg:SetAllPoints(bars[i])
		bars[i].bg:SetTexture(E.media.blankTex)
		bars[i].bg:SetParent(bars[i].backdrop)
	end

	bars.PostUpdate = UF.UpdateSpecPower

	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

function UF:UpdateSpecPower(_, charges, maxCharges)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return end

	if frame.USE_CLASSBAR and (IsSpellKnown(114664) or IsSpellKnown(114015)) then
		if charges == 0 then
			for i = 1, maxCharges do
				self[i]:SetValue(0)
				self[i]:SetScript("OnUpdate", nil)
			end

			self:SetShown(not db.classbar.autoHide)
		end
	else
		self:Hide()
	end

	local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
	for i = 1, #self do
		if custom_backdrop then
			self[i].bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
		else
			local r, g, b = self[i]:GetStatusBarColor()
			self[i].bg:SetVertexColor(r * 0.35, g * 0.35, b * 0.35)
		end

		self[i].bg:SetShown(maxCharges and (i <= maxCharges))
	end
end

-------------------------------------------------------------
-- WARLOCK
-------------------------------------------------------------
function UF:Construct_DemonicFuryBar(frame)
	local demonicFury = CreateFrame("StatusBar", "DemonicFuryBar", frame)
	demonicFury:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
	demonicFury:SetStatusBarTexture(E.media.blankTex)
	UF.statusbars[demonicFury] = true

	demonicFury.RaisedElementParent = CreateFrame("Frame", nil, demonicFury)
	demonicFury.RaisedElementParent:SetFrameLevel(demonicFury:GetFrameLevel() + 100)
	demonicFury.RaisedElementParent:SetAllPoints()

	demonicFury.bg = demonicFury:CreateTexture(nil, "BORDER")
	demonicFury.bg:SetAllPoints(demonicFury)
	demonicFury.bg:SetTexture(E.media.blankTex)

	demonicFury.PostUpdate = UF.UpdateDemonicFury
	demonicFury.PostUpdateVisibility = UF.VisibilityUpdateDemonicFury

	demonicFury:SetScript("OnShow", ToggleResourceBar)
	demonicFury:SetScript("OnHide", ToggleResourceBar)

	return demonicFury
end

function UF:UpdateDemonicFury()
	local frame = self.origParent or self:GetParent()
	local db = frame.db

	local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
	if custom_backdrop then
		self.bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
	else
		local r, g, b = self:GetStatusBarColor()
		self.bg:SetVertexColor(r * 0.35, g * 0.35, b * 0.35)
	end
end

function UF:VisibilityUpdateDemonicFury(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	if enabled then
		frame.ClassBar = "DemonicFury"
	end

	UF:PostVisibility_ClassBars(frame, stateChanged)
end

function UF:Construct_BurningEmbersBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	for i = 1, UF.classMaxResourceBar[E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassIconButton"..i, bars)
		bars[i]:SetStatusBarTexture(E.media.blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF.statusbars[bars[i]] = true

		bars[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		bars[i].backdrop:SetParent(bars)

		bars[i].bg = bars:CreateTexture(nil, "BORDER")
		bars[i].bg:SetAllPoints(bars[i])
		bars[i].bg:SetTexture(E.media.blankTex)
		bars[i].bg:SetParent(bars[i].backdrop)
	end

	bars.PostUpdate = UF.UpdateBurningEmbers
	bars.PostUpdateVisibility = UF.VisibilityUpdateBurningEmbers

	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

function UF:UpdateBurningEmbers(_, _, max)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return end

	local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
	for i = 1, #self do
		if custom_backdrop then
			self[i].bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
		else
			local r, g, b = self[i]:GetStatusBarColor()
			self[i].bg:SetVertexColor(r * 0.35, g * 0.35, b * 0.35)
		end

		self[i].bg:SetShown(max and (i <= max))
	end
end

function UF:VisibilityUpdateBurningEmbers(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	if enabled then
		frame.ClassBar = "BurningEmbers"
	end

	UF:PostVisibility_ClassBars(frame, stateChanged)
end

function UF:Construct_SoulShardsBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	for i = 1, UF.classMaxResourceBar[E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassIconButton"..i, bars)
		bars[i]:SetStatusBarTexture(E.media.blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF.statusbars[bars[i]] = true

		bars[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		bars[i].backdrop:SetParent(bars)

		bars[i].BG = bars:CreateTexture(nil, "BORDER")
		bars[i].BG:SetAllPoints(bars[i])
		bars[i].BG:SetTexture(E.media.blankTex)
		bars[i].BG:SetParent(bars[i].backdrop)
	end

	bars.PostUpdate = UF.UpdateSoulShards
	bars.PostUpdateVisibility = UF.VisibilityUpdateSoulShards

	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

function UF:UpdateSoulShards(_, _, max)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return end

	local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
	for i = 1, #self do
		if custom_backdrop then
			self[i].BG:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
		else
			local r, g, b = self[i]:GetStatusBarColor()
			self[i].BG:SetVertexColor(r * 0.35, g * 0.35, b * 0.35)
		end

		self[i].BG:SetShown(max and (i <= max))
	end
end

function UF:VisibilityUpdateSoulShards(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	if enabled then
		frame.ClassBar = "SoulShards"
	end

	UF:PostVisibility_ClassBars(frame, stateChanged)
end

-------------------------------------------------------------
-- DEATHKNIGHT
-------------------------------------------------------------
function UF:Construct_DeathKnightResourceBar(frame)
	local runes = CreateFrame("Frame", nil, frame)
	runes:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
	runes.backdrop:Hide()

	for i = 1, UF.classMaxResourceBar[E.myclass] do
		runes[i] = CreateFrame("StatusBar", frame:GetName().."RuneButton"..i, runes)
		runes[i]:SetStatusBarTexture(E.media.blankTex)
		runes[i]:GetStatusBarTexture():SetHorizTile(false)
		UF.statusbars[runes[i]] = true

		runes[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		runes[i].backdrop:SetParent(runes)
		runes[i].backdrop:SetFrameLevel(runes[i]:GetFrameLevel() - 1)

		runes[i].bg = runes[i]:CreateTexture(nil, "BORDER")
		runes[i].bg:SetAllPoints()
		runes[i].bg:SetTexture(E.media.blankTex)
		runes[i].bg:SetParent(runes[i].backdrop)
		runes[i].bg.multiplier = 0.35
	end

	runes.PostUpdateType = UF.PostUpdateRuneType
	runes.PostUpdateVisibility = UF.PostVisibilityRunes

	runes:SetScript("OnShow", ToggleResourceBar)
	runes:SetScript("OnHide", ToggleResourceBar)

	return runes
end

function UF:PostUpdateRuneType(rune)
	local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop

	if custom_backdrop then
		rune.bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
	end
end

function UF:PostVisibilityRunes(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	if enabled then
		frame.MAX_CLASS_BAR = #self
	end

	UF:PostVisibility_ClassBars(frame, stateChanged)
end

-------------------------------------------------------------
-- DRUID
-------------------------------------------------------------
function UF:Construct_DruidEclipseBar(frame)
	local eclipseBar = CreateFrame("Frame", "$parent_EclipsePowerBar", frame)
	eclipseBar:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	eclipseBar.LunarBar = CreateFrame("StatusBar", "LunarBar", eclipseBar)
	eclipseBar.LunarBar:Point("LEFT", eclipseBar)
	eclipseBar.LunarBar:SetStatusBarTexture(E.media.blankTex)
	UF.statusbars[eclipseBar.LunarBar] = true

	eclipseBar.SolarBar = CreateFrame("StatusBar", "SolarBar", eclipseBar)
	eclipseBar.SolarBar:SetStatusBarTexture(E.media.blankTex)
	UF.statusbars[eclipseBar.SolarBar] = true

	eclipseBar.RaisedElementParent = CreateFrame("Frame", nil, eclipseBar)
	eclipseBar.RaisedElementParent:SetFrameLevel(eclipseBar:GetFrameLevel() + 100)
	eclipseBar.RaisedElementParent:SetAllPoints()

	eclipseBar.Arrow = eclipseBar.LunarBar:CreateTexture(nil, "OVERLAY")
	eclipseBar.Arrow:SetTexture(E.Media.Textures.ArrowUp)
	eclipseBar.Arrow:SetPoint("CENTER")

	eclipseBar.PostDirectionChange = UF.EclipsePostDirectionChange
	eclipseBar.PostUpdateVisibility = UF.EclipsePostUpdateVisibility

	eclipseBar:SetScript("OnShow", ToggleResourceBar)
	eclipseBar:SetScript("OnHide", ToggleResourceBar)

	return eclipseBar
end

function UF:EclipsePostDirectionChange(direction)
	local frame = self.origParent or self:GetParent()
	local vertical = frame.CLASSBAR_DETACHED and frame.db.classbar.verticalOrientation

	self.Arrow:SetRotation(direction == "sun" and (vertical and 0 or -1.57) or (vertical and 3.14 or 1.57))
	self.Arrow:SetVertexColor(unpack(ElvUF.colors.ClassBars[E.myclass][direction == "sun" and 1 or 2]))
	self.Arrow:SetShown(direction == "sun" or direction == "moon")
end

function UF:EclipsePostUpdateVisibility(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	frame.ClassBar = enabled and "EclipseBar" or "AdditionalPower"

	UF:PostVisibility_ClassBars(frame, stateChanged)
end

function UF:Construct_AdditionalPowerBar(frame)
	local additionalPower = CreateFrame("StatusBar", "$parent_AdditionalPowerBar", frame)
	additionalPower:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
	additionalPower:SetStatusBarTexture(E.media.blankTex)
	UF.statusbars[additionalPower] = true

	additionalPower.RaisedElementParent = CreateFrame("Frame", nil, additionalPower)
	additionalPower.RaisedElementParent:SetFrameLevel(additionalPower:GetFrameLevel() + 100)
	additionalPower.RaisedElementParent:SetAllPoints()

	additionalPower.BG = additionalPower:CreateTexture(nil, "BORDER")
	additionalPower.BG:SetAllPoints(additionalPower)
	additionalPower.BG:SetTexture(E.media.blankTex)

	additionalPower.colorPower = true
	additionalPower.frequentUpdates = true

	additionalPower.PostUpdate = UF.PostUpdateAdditionalPower
	additionalPower.PostUpdateColor = UF.PostColorAdditionalPower
	additionalPower.PostUpdateVisibility = UF.PostVisibilityAdditionalPower

	additionalPower:SetScript("OnShow", ToggleResourceBar)
	additionalPower:SetScript("OnHide", ToggleResourceBar)

	return additionalPower
end

function UF:PostUpdateAdditionalPower(MIN, MAX, event)
	local frame = self.origParent or self:GetParent()

	self:SetShown(frame.USE_CLASSBAR and ((MIN ~= MAX or (not frame.db.classbar.autoHide)) and (event ~= "ElementDisable")))
end

function UF:PostColorAdditionalPower()
	local frame = self.origParent or self:GetParent()

	if frame.USE_CLASSBAR then
		local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
		if custom_backdrop then
			self.BG:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
		else
			local r, g, b = self:GetStatusBarColor()
			self.BG:SetVertexColor(r * 0.35, g * 0.35, b * 0.35)
		end
	end
end

function UF:PostVisibilityAdditionalPower(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	frame.ClassBar = enabled and "AdditionalPower" or "EclipseBar"

	UF:PostVisibility_ClassBars(frame, stateChanged)
end