local E, L, V, P, G = unpack(select(2, ...))
local UF = E:GetModule("UnitFrames")

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

local select, unpack = select, unpack
local floor, max = math.floor, math.max
local find, sub, gsub = string.find, string.sub, string.gsub

local CreateFrame = CreateFrame
local IsSpellKnown = IsSpellKnown

function UF:Configure_ClassBar(frame)
	if not frame.VARIABLES_SET then return end
	local bars = frame[frame.ClassBar]
	if not bars then return end

	local db = frame.db
	bars.Holder = frame.ClassBarHolder
	bars.origParent = frame

	--Fix height in case it is lower than the theme allows, or in case it's higher than 30px when not detached
	if (not self.thinBorders and not E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 7 then --A height of 7 means 6px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 7
		if db.classbar then db.classbar.height = 7 end
		UF.ToggleResourceBar(bars) --Trigger update to health if needed
	elseif (self.thinBorders or E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 3 then --A height of 3 means 2px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 3
		if db.classbar then db.classbar.height = 3 end
		UF.ToggleResourceBar(bars)  --Trigger update to health if needed
	elseif (not frame.CLASSBAR_DETACHED and frame.CLASSBAR_HEIGHT > 30) then
		frame.CLASSBAR_HEIGHT = 10
		if db.classbar then db.classbar.height = 10 end
		--Override visibility if Classbar is Additional Power in order to fix a bug when Auto Hide is enabled, height is higher than 30 and it goes from detached to not detached
		local overrideVisibility = frame.ClassBar == "AdditionalPower"
		UF.ToggleResourceBar(bars, overrideVisibility)  --Trigger update to health if needed
	end

	--We don't want to modify the original frame.CLASSBAR_WIDTH value, as it bugs out when the classbar gains more buttons
	local CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH

	local color = E.db.unitframe.colors.borderColor
	bars.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

	color = self.db.colors.classResources.bgColor
	bars.backdrop.backdropTexture:SetVertexColor(color.r, color.g, color.b)

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		bars:ClearAllPoints()
		bars:Point("CENTER", frame.Health.backdrop, "TOP", 0, 0)

		if frame.ClassBar == "EclipseBar" or frame.ClassBar == "AdditionalPower" or frame.ClassBar == "DemonicFury" then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * 2/3
		else
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * (frame.MAX_CLASS_BAR - 1) / frame.MAX_CLASS_BAR
		end

		bars:SetParent(frame)
		bars:SetFrameLevel(50) --RaisedElementParent uses 100, we want it lower than this

		if bars.Holder and bars.Holder.mover then
			bars.Holder.mover:SetScale(0.0001)
			bars.Holder.mover:SetAlpha(0)
		end
	elseif not frame.CLASSBAR_DETACHED then
		bars:ClearAllPoints()

		if frame.ORIENTATION == "RIGHT" then
			bars:Point("BOTTOMRIGHT", frame.Health.backdrop, "TOPRIGHT", -frame.BORDER, frame.SPACING*3)
		else
			bars:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", frame.BORDER, frame.SPACING*3)
		end

		bars:SetParent(frame)
		bars:SetFrameLevel(frame:GetFrameLevel() + 5)

		if bars.Holder and bars.Holder.mover then
			bars.Holder.mover:SetScale(0.0001)
			bars.Holder.mover:SetAlpha(0)
		end
	else --Detached
		CLASSBAR_WIDTH = db.classbar.detachedWidth - ((frame.BORDER + frame.SPACING)*2)
		bars.Holder:Size(db.classbar.detachedWidth, db.classbar.height)

		if not bars.Holder.mover then
			bars:Width(CLASSBAR_WIDTH)
			bars:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER+frame.SPACING)*2))
			bars:ClearAllPoints()
			bars:Point("BOTTOMLEFT", bars.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			E:CreateMover(bars.Holder, "ClassBarMover", L["Classbar"], nil, nil, nil, "ALL,SOLO", nil, "unitframe,player,classbar")
		else
			bars:ClearAllPoints()
			bars:Point("BOTTOMLEFT", bars.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			bars.Holder.mover:SetScale(1)
			bars.Holder.mover:SetAlpha(1)
		end

		if db.classbar.parent == "UIPARENT" then
			bars:SetParent(E.UIParent)
		else
			bars:SetParent(frame)
		end

		if not db.classbar.strataAndLevel.useCustomStrata then
			bars:SetFrameStrata("LOW")
		else
			bars:SetFrameStrata(db.classbar.strataAndLevel.frameStrata)
		end

		if not db.classbar.strataAndLevel.useCustomLevel then
			bars:SetFrameLevel(frame:GetFrameLevel() + 5)
		else
			bars:SetFrameLevel(db.classbar.strataAndLevel.frameLevel)
		end
	end

	bars:Width(CLASSBAR_WIDTH)
	bars:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))

	if frame.ClassBar == "ClassPower" or frame.ClassBar == "ArcaneChargeBar" or frame.ClassBar == "Anticipation" or frame.ClassBar == "Runes" or frame.ClassBar == "BurningEmbers" or frame.ClassBar == "SoulShards" then
		local maxClassBarButtons = max(UF.classMaxResourceBar[E.myclass] or 0)
		for i = 1, maxClassBarButtons do
			bars[i]:Hide()
			bars[i].backdrop:Hide()

			if i <= frame.MAX_CLASS_BAR then
				color = E.db.unitframe.colors.borderColor
				bars[i].backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

				color = self.db.colors.classResources.bgColor
				bars[i].backdrop.backdropTexture:SetVertexColor(color.r, color.g, color.b)

				bars[i]:Height(bars:GetHeight())
				if frame.MAX_CLASS_BAR == 1 then
					bars[i]:SetWidth(CLASSBAR_WIDTH)
				elseif frame.USE_MINI_CLASSBAR then
					if frame.CLASSBAR_DETACHED and db.classbar.orientation == "VERTICAL" then
						bars[i]:SetWidth(CLASSBAR_WIDTH)
						bars.Holder:SetHeight(((frame.CLASSBAR_HEIGHT + db.classbar.spacing)* frame.MAX_CLASS_BAR) - db.classbar.spacing) -- fix the holder height
				elseif frame.CLASSBAR_DETACHED and db.classbar.orientation == "HORIZONTAL" then
						bars[i]:SetWidth((CLASSBAR_WIDTH - ((db.classbar.spacing + (frame.BORDER*2 + frame.SPACING*2))*(frame.MAX_CLASS_BAR - 1)))/frame.MAX_CLASS_BAR)
						bars.Holder:SetHeight(frame.CLASSBAR_HEIGHT)
					else
						bars[i]:SetWidth((CLASSBAR_WIDTH - ((5 + (frame.BORDER*2 + frame.SPACING*2))*(frame.MAX_CLASS_BAR - 1)))/frame.MAX_CLASS_BAR) --Width accounts for 5px spacing between each button, excluding borders
						bars.Holder:SetHeight(frame.CLASSBAR_HEIGHT) -- set the holder height to default
					end
				elseif i ~= frame.MAX_CLASS_BAR then
					bars[i]:Width((CLASSBAR_WIDTH - ((frame.MAX_CLASS_BAR - 1)*(frame.BORDER-frame.SPACING))) / frame.MAX_CLASS_BAR) --classbar width minus total width of dividers between each button, divided by number of buttons
				end

				bars[i]:GetStatusBarTexture():SetHorizTile(false)
				bars[i]:ClearAllPoints()
				if i == 1 then
					bars[i]:Point("LEFT", bars)
				else
					if frame.USE_MINI_CLASSBAR then
						if frame.CLASSBAR_DETACHED and db.classbar.orientation == "VERTICAL" then
							bars[i]:Point("BOTTOM", bars[i - 1], "TOP", 0, (db.classbar.spacing + frame.BORDER*2 + frame.SPACING*2))
						elseif frame.CLASSBAR_DETACHED and db.classbar.orientation == "HORIZONTAL" then
							bars[i]:Point("LEFT", bars[i - 1], "RIGHT", (db.classbar.spacing + frame.BORDER*2 + frame.SPACING*2), 0) --5px spacing between borders of each button(replaced with Detached Spacing option)
						else
							bars[i]:Point("LEFT", bars[i - 1], "RIGHT", (5 + frame.BORDER*2 + frame.SPACING*2), 0) --5px spacing between borders of each button
						end
					elseif i == frame.MAX_CLASS_BAR then
						bars[i]:Point("LEFT", bars[i - 1], "RIGHT", frame.BORDER-frame.SPACING, 0)
						bars[i]:Point("RIGHT", bars)
					else
						bars[i]:Point("LEFT", bars[i - 1], "RIGHT", frame.BORDER-frame.SPACING, 0)
					end
				end

				if not frame.USE_MINI_CLASSBAR then
					bars[i].backdrop:Hide()
				else
					bars[i].backdrop:Show()
				end

				if E.myclass == "MONK" or E.myclass == "ROGUE" then
					bars[i]:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass][i]))

					if E.myclass == "ROGUE" then
						if bars[i].bg then
							bars[i].bg:SetTexture(unpack(ElvUF.colors.ClassBars[E.myclass][i]))
						end
					end
				elseif E.myclass == "PALADIN" or E.myclass == "PRIEST" or E.myclass == "MAGE" then
					bars[i]:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass]))

					if E.myclass == "MAGE" then
						if bars[i].bg then
							bars[i].bg:SetTexture(unpack(ElvUF.colors.ClassBars[E.myclass]))
						end
					end
				elseif E.myclass == "WARLOCK" then
					if frame.ClassBar == "SoulShards" then
						bars[i]:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass][1]))

						if bars[i].bg then
							bars[i].bg:SetTexture(unpack(ElvUF.colors.ClassBars[E.myclass][1]))
						end
					elseif frame.ClassBar == "BurningEmbers" then
						bars[i]:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass][3]))

						if bars[i].bg then
							bars[i].bg:SetTexture(unpack(ElvUF.colors.ClassBars[E.myclass][3]))
						end
					end
				end

				if frame.CLASSBAR_DETACHED and db.classbar.verticalOrientation then
					bars[i]:SetOrientation("VERTICAL")
				else
					bars[i]:SetOrientation("HORIZONTAL")
				end

				--Fix missing backdrop colors on Combo Points when using Spaced style
				if frame.ClassBar == "ClassPower" or frame.ClassBar == "BurningEmbers" then
					if frame.USE_MINI_CLASSBAR then
						bars[i].bg:SetParent(bars[i].backdrop)
					else
						bars[i].bg:SetParent(bars)
					end
				end

				bars[i]:Show()
			end
		end

		if not frame.USE_MINI_CLASSBAR then
			bars.backdrop:Show()
		else
			bars.backdrop:Hide()
		end
	elseif frame.ClassBar == "EclipseBar" then
		bars.LunarBar:SetMinMaxValues(0, 0)
		bars.LunarBar:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass][1]))
		bars.LunarBar:Size(CLASSBAR_WIDTH, frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))

		bars.SolarBar:SetMinMaxValues(0, 0)
		bars.SolarBar:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass][2]))
		bars.SolarBar:Size(CLASSBAR_WIDTH, frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))

		bars.SolarBar:ClearAllPoints()
		bars.Text:ClearAllPoints()

		if frame.CLASSBAR_DETACHED and db.classbar.verticalOrientation then
			bars.LunarBar:SetOrientation("VERTICAL")

			bars.SolarBar:SetOrientation("VERTICAL")
			bars.SolarBar:Point("BOTTOM", bars.LunarBar:GetStatusBarTexture(), "TOP")

			bars.Text:Point("CENTER", bars.LunarBar:GetStatusBarTexture(), "TOP", 0, -4)
		else
			bars.LunarBar:SetOrientation("HORIZONTAL")

			bars.SolarBar:SetOrientation("HORIZONTAL")
			bars.SolarBar:Point("LEFT", bars.LunarBar:GetStatusBarTexture(), "RIGHT")

			bars.Text:Point("CENTER", bars.LunarBar:GetStatusBarTexture(), "RIGHT")
		end
	elseif frame.ClassBar == "AdditionalPower" or frame.ClassBar == "DemonicFury" then
		if frame.CLASSBAR_DETACHED and db.classbar.verticalOrientation then
			bars:SetOrientation("VERTICAL")
		else
			bars:SetOrientation("HORIZONTAL")
		end

		if E.myclass == "WARLOCK" then
			bars:SetStatusBarColor(unpack(ElvUF.colors.ClassBars[E.myclass][2]))
			if bars.bg then
				bars.bg:SetTexture(unpack(ElvUF.colors.ClassBars[E.myclass][2]))
			end
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
		if frame.ArcaneChargeBar and not frame:IsElementEnabled("ArcaneChargeBar") then
			frame:EnableElement("ArcaneChargeBar")
		end
		if frame.Anticipation and not frame:IsElementEnabled("Anticipation") then
			frame:EnableElement("Anticipation")
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
	else
		if frame.ClassPower and frame:IsElementEnabled("ClassPower") then
			frame:DisableElement("ClassPower")
		end
		if frame.ArcaneChargeBar and frame:IsElementEnabled("ArcaneChargeBar") then
			frame:DisableElement("ArcaneChargeBar")
		end
		if frame.Anticipation and frame:IsElementEnabled("Anticipation") then
			frame:DisableElement("Anticipation")
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
	end
end

local function ToggleResourceBar(bars, overrideVisibility)
	local frame = bars.origParent or bars:GetParent()
	local db = frame.db
	if not db then return end

	frame.CLASSBAR_SHOWN = (not not overrideVisibility) or bars:IsShown()

	local height
	if db.classbar then
		height = db.classbar.height
	elseif db.combobar then
		height = db.combobar.height
	elseif frame.AlternativePower then
		height = db.power.height
	end

	if bars.text then
		if frame.CLASSBAR_SHOWN then
			bars.text:SetAlpha(1)
		else
			bars.text:SetAlpha(0)
		end
	end

	frame.CLASSBAR_HEIGHT = (frame.USE_CLASSBAR and (frame.CLASSBAR_SHOWN and height) or 0)
	frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and ((frame.SPACING+(frame.CLASSBAR_HEIGHT/2))) or (frame.CLASSBAR_HEIGHT - (frame.BORDER-frame.SPACING)))

	if not frame.CLASSBAR_DETACHED then
		UF:Configure_HealthBar(frame)
		UF:Configure_Portrait(frame, true)
		UF:Configure_Threat(frame)
	end
end
UF.ToggleResourceBar = ToggleResourceBar

-------------------------------------------------------------
-- PALADIN, MONK, PRIEST
-------------------------------------------------------------
function UF:Construct_ClassBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	local maxBars = max(UF["classMaxResourceBar"][E.myclass] or 0)
	for i = 1, maxBars do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassIconButton"..i, bars)
		bars[i]:SetStatusBarTexture(E.media.blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF.statusbars[bars[i]] = true

		bars[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		bars[i].backdrop:SetParent(bars)

		bars[i].bg = bars:CreateTexture(nil, "OVERLAY")
		bars[i].bg:SetAllPoints(bars[i])
		bars[i].bg:SetTexture(E.media.blankTex)
	end

	bars.PostUpdate = UF.UpdateClassBar
	bars.UpdateColor = E.noop --We handle colors on our own in Configure_ClassBar
	bars.UpdateTexture = E.noop --We don't use textures but statusbars, so prevent errors

	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

function UF:UpdateClassBar(cur, max, hasMaxChanged)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return end

	local isShown = self:IsShown()
	local stateChanged

	if not frame.USE_CLASSBAR or (cur == 0 and db.classbar.autoHide) or max == nil then
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
		frame.MAX_CLASS_BAR = max
		UF:Configure_ClassBar(frame, cur)
	elseif stateChanged then
		UF:Configure_ClassBar(frame, cur)
	end

	local r, g, b
	for i = 1, #self do
		r, g, b = self[i]:GetStatusBarColor()
		self[i].bg:SetVertexColor(r, g, b, 0.15)
		if(max and (i <= max)) then
			self[i].bg:Show()
		else
			self[i].bg:Hide()
		end
	end
end

-------------------------------------------------------------
-- MAGE
-------------------------------------------------------------
function UF:Construct_MageResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	for i = 1, UF.classMaxResourceBar[E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
		bars[i]:SetStatusBarTexture(E.media.blankTex)
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF.statusbars[bars[i]] = true

		bars[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		bars[i].backdrop:SetParent(bars)

		bars[i].bg = bars[i]:CreateTexture(nil, "BORDER")
		bars[i].bg:SetAllPoints()
		bars[i].bg:SetTexture(E.media.blankTex)
		bars[i].bg.multiplier = 0.3
	end

	bars.PostUpdate = UF.UpdateArcaneCharges
	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

function UF:UpdateArcaneCharges(event, arcaneCharges, maxCharges)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return end

	if(E.myspec == 1 and arcaneCharges == 0) then
		if db.classbar.autoHide then
			self:Hide()
		else
			for i = 1, maxCharges do
				self[i]:SetValue(0)
				self[i]:SetScript("OnUpdate", nil)
			end

			self:Show()
		end
	end
end

-------------------------------------------------------------
-- ROGUE
-------------------------------------------------------------
function UF:Construct_RogueResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	for i = 1, UF.classMaxResourceBar[E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
		bars[i]:SetStatusBarTexture(E.media.blankTex)
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF.statusbars[bars[i]] = true

		bars[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		bars[i].backdrop:SetParent(bars)

		bars[i].bg = bars[i]:CreateTexture(nil, "BORDER")
		bars[i].bg:SetAllPoints()
		bars[i].bg:SetTexture(E.media.blankTex)
		bars[i].bg.multiplier = 0.3
	end

	bars.PostUpdate = UF.UpdateAnticipation
	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

function UF:UpdateAnticipation(event, charges, maxCharges)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return; end

	if(IsSpellKnown(114015) and charges == 0) then
		if db.classbar.autoHide then
			self:Hide()
		else
			for i = 1, maxCharges do
				self[i]:SetValue(0)
				self[i]:SetScript("OnUpdate", nil)
			end

			self:Show()
		end
	end
end

-------------------------------------------------------------
-- WARLOCK
-------------------------------------------------------------
function UF:Construct_DemonicFuryBar(frame)
	local demonicFury = CreateFrame("StatusBar", "DemonicFuryBar", frame)
	demonicFury:SetFrameLevel(demonicFury:GetFrameLevel() + 1)
	demonicFury.PostUpdateVisibility = UF.VisibilityUpdateDemonicFury
	demonicFury:CreateBackdrop("Default")
	UF.statusbars[demonicFury] = true
	demonicFury:SetStatusBarTexture(E.media.blankTex)

	demonicFury.bg = demonicFury:CreateTexture(nil, "BORDER")
	demonicFury.bg:SetAllPoints(demonicFury)
	demonicFury.bg:SetTexture(E.media.blankTex)
	demonicFury.bg.multiplier = 0.3

	demonicFury:SetScript("OnShow", ToggleResourceBar)
	demonicFury:SetScript("OnHide", ToggleResourceBar)

	return demonicFury
end

function UF:VisibilityUpdateDemonicFury(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	if enabled then
		frame.ClassBar = "DemonicFury"
	end

	if stateChanged then
		ToggleResourceBar(frame[frame.ClassBar])
		UF:Configure_ClassBar(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame)
		UF:Configure_InfoPanel(frame, true) --2nd argument is to prevent it from setting template, which removes threat border
	end
end

function UF:Construct_BurningEmbersBar(frame)
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

		bars[i].bg = bars:CreateTexture(nil, "OVERLAY")
		bars[i].bg:SetAllPoints(bars[i])
		bars[i].bg:SetTexture(E.media.blankTex)
		bars[i].bg.multiplier = 0.3
	end

	bars.PostUpdateVisibility = UF.VisibilityUpdateBurningEmbers

	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

function UF:VisibilityUpdateBurningEmbers(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	if enabled then
		frame.ClassBar = "BurningEmbers"
	end

	if stateChanged then
		ToggleResourceBar(frame[frame.ClassBar])
		UF:Configure_ClassBar(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame)
		UF:Configure_InfoPanel(frame, true) --2nd argument is to prevent it from setting template, which removes threat border
	end
end

function UF:Construct_SoulShardsBar(frame)
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

		bars[i].bg = bars[i]:CreateTexture(nil, "OVERLAY")
		bars[i].bg:SetAllPoints(bars[i])
		bars[i].bg:SetTexture(E.media.blankTex)
		bars[i].bg.multiplier = 0.3
	end

	bars.PostUpdateVisibility = UF.VisibilityUpdateSoulShards

	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

function UF:VisibilityUpdateSoulShards(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	if enabled then
		frame.ClassBar = "SoulShards"
	end

	if stateChanged then
		ToggleResourceBar(frame[frame.ClassBar])
		UF:Configure_ClassBar(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame)
		UF:Configure_InfoPanel(frame, true) --2nd argument is to prevent it from setting template, which removes threat border
	end
end

-------------------------------------------------------------
-- DEATHKNIGHT
-------------------------------------------------------------
function UF:Construct_DeathKnightResourceBar(frame)
	local runes = CreateFrame("Frame", nil, frame)
	runes:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	for i = 1, UF.classMaxResourceBar[E.myclass] do
		runes[i] = CreateFrame("StatusBar", frame:GetName().."RuneButton"..i, runes)
		UF.statusbars[runes[i]] = true
		runes[i]:SetStatusBarTexture(E.media.blankTex)
		runes[i]:GetStatusBarTexture():SetHorizTile(false)

		runes[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		runes[i].backdrop:SetParent(runes)

		runes[i].bg = runes[i]:CreateTexture(nil, "BORDER")
		runes[i].bg:SetAllPoints()
		runes[i].bg:SetTexture(E.media.blankTex)
		runes[i].bg.multiplier = 0.2
	end

	runes.PostUpdateVisibility = UF.PostVisibilityRunes
	runes.UpdateColor = E.noop --We handle colors on our own in Configure_ClassBar

	runes:SetScript("OnShow", ToggleResourceBar)
	runes:SetScript("OnHide", ToggleResourceBar)

	return runes
end

function UF:PostVisibilityRunes(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	if enabled then
		frame.MAX_CLASS_BAR = #self
	end

	if stateChanged then
		ToggleResourceBar(frame[frame.ClassBar])
		UF:Configure_ClassBar(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame)
		UF:Configure_InfoPanel(frame, true) --2nd argument is to prevent it from setting template, which removes threat border
	end
end

-------------------------------------------------------------
-- DRUID
-------------------------------------------------------------
function UF:Construct_DruidEclipseBar(frame)
	local eclipseBar = CreateFrame("Frame", nil, frame)
	eclipseBar:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
	eclipseBar.PostDirectionChange = UF.EclipsePostDirectionChange
	eclipseBar.PostUpdateVisibility = UF.EclipsePostUpdateVisibility

	eclipseBar.LunarBar = CreateFrame("StatusBar", "LunarBar", eclipseBar)
	eclipseBar.LunarBar:Point("LEFT", eclipseBar)
	eclipseBar.LunarBar:SetStatusBarTexture(E.media.blankTex)
	UF.statusbars[eclipseBar.LunarBar] = true

	eclipseBar.SolarBar = CreateFrame("StatusBar", "SolarBar", eclipseBar)
	eclipseBar.SolarBar:SetStatusBarTexture(E.media.blankTex)
	UF.statusbars[eclipseBar.SolarBar] = true

	eclipseBar.Text = eclipseBar.LunarBar:CreateFontString(nil, "OVERLAY")
	eclipseBar.Text:FontTemplate(nil, 20)

	return eclipseBar
end

function UF:EclipsePostDirectionChange(direction)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return end

	if direction == "sun" then
		if frame.CLASSBAR_DETACHED and db.classbar.verticalOrientation then
			self.Text:SetText("^")
		else
			self.Text:SetText(">")
		end
		self.Text:SetTextColor(.2, .2, 1, 1)
	elseif direction == "moon" then
		if frame.CLASSBAR_DETACHED and db.classbar.verticalOrientation then
			self.Text:SetText("v")
		else
			self.Text:SetText("<")
		end
		self.Text:SetTextColor(1, 1, .3, 1)
	else
		self.Text:SetText("")
	end
end

function UF:EclipsePostUpdateVisibility(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	if stateChanged then
		ToggleResourceBar(frame[frame.ClassBar])
		UF:Configure_ClassBar(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame)
		UF:Configure_InfoPanel(frame, true) --2nd argument is to prevent it from setting template, which removes threat border
	end
end

function UF:Construct_AdditionalPowerBar(frame)
	local additionalPower = CreateFrame("StatusBar", "AdditionalPowerBar", frame)
	additionalPower:SetFrameLevel(additionalPower:GetFrameLevel() + 1)
	additionalPower.colorPower = true
	additionalPower.PostUpdate = UF.PostUpdateAdditionalPower
	additionalPower.PostUpdateVisibility = UF.PostVisibilityAdditionalPower
	additionalPower:CreateBackdrop("Default")
	UF.statusbars[additionalPower] = true
	additionalPower:SetStatusBarTexture(E.media.blankTex)

	additionalPower.bg = additionalPower:CreateTexture(nil, "BORDER")
	additionalPower.bg:SetAllPoints(additionalPower)
	additionalPower.bg:SetTexture(E.media.blankTex)
	additionalPower.bg.multiplier = 0.3

	additionalPower.Text = additionalPower:CreateFontString(nil, "OVERLAY")
	UF:Configure_FontString(additionalPower.Text)

	additionalPower:SetScript("OnShow", ToggleResourceBar)
	additionalPower:SetScript("OnHide", ToggleResourceBar)

	return additionalPower
end

function UF:PostUpdateAdditionalPower(_, min, max, event)
	local frame = self.origParent or self:GetParent()
	local db = frame.db

	if frame.USE_CLASSBAR and ((min ~= max or (not db.classbar.autoHide)) and (event ~= "ElementDisable")) then
		if db.classbar.additionalPowerText then
			local powerValue = frame.Power.value
			local powerValueText = powerValue:GetText()
			local powerValueParent = powerValue:GetParent()
			local powerTextPosition = db.power.position
			local color = ElvUF.colors.power.MANA
			color = E:RGBToHex(color[1], color[2], color[3])

			--Attempt to remove |cFFXXXXXX color codes in order to determine if power text is really empty
			if powerValueText then
				local _, endIndex = find(powerValueText, "|cff")
				if endIndex then
					endIndex = endIndex + 7 --Add hex code
					powerValueText = sub(powerValueText, endIndex)
					powerValueText = gsub(powerValueText, "%s+", "")
				end
			end

			self.Text:ClearAllPoints()
			if not frame.CLASSBAR_DETACHED then
				self.Text:SetParent(powerValueParent)
				if (powerValueText and (powerValueText ~= "" and powerValueText ~= " ")) then
					if find(powerTextPosition, "RIGHT") then
						self.Text:Point("RIGHT", powerValue, "LEFT", 3, 0)
						self.Text:SetFormattedText(color.."%d%%|r |cffD7BEA5- |r", floor(min / max * 100))
					elseif find(powerTextPosition, "LEFT") then
						self.Text:Point("LEFT", powerValue, "RIGHT", -3, 0)
						self.Text:SetFormattedText("|cffD7BEA5 -|r"..color.." %d%%|r", floor(min / max * 100))
					else
						if select(4, powerValue:GetPoint()) <= 0 then
							self.Text:Point("LEFT", powerValue, "RIGHT", -3, 0)
							self.Text:SetFormattedText(" |cffD7BEA5-|r"..color.." %d%%|r", floor(min / max * 100))
						else
							self.Text:Point("RIGHT", powerValue, "LEFT", 3, 0)
							self.Text:SetFormattedText(color.."%d%%|r |cffD7BEA5- |r", floor(min / max * 100))
						end
					end
				else
					self.Text:Point(powerValue:GetPoint())
					self.Text:SetFormattedText(color.."%d%%|r", floor(min / max * 100))
				end
			else
				self.Text:SetParent(self)
				self.Text:Point("CENTER", self)
				self.Text:SetFormattedText(color.."%d%%|r", floor(min / max * 100))
			end
		else --Text disabled
			self.Text:SetText()
		end
	else --Bar disabled
		self.Text:SetText()
		self:Hide()
	end
end

function UF:PostVisibilityAdditionalPower(enabled, stateChanged)
	local frame = self.origParent or self:GetParent()

	if enabled then
		frame.ClassBar = "AdditionalPower"
	else
		frame.ClassBar = "EclipseBar"
	end

	if stateChanged then
		ToggleResourceBar(frame[frame.ClassBar])
		UF:Configure_ClassBar(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame)
		UF:Configure_InfoPanel(frame, true) --2nd argument is to prevent it from setting template, which removes threat border
	end
end