local E, L, V, P, G = unpack(select(2, ...))
local UF = E:GetModule("UnitFrames")

local unpack = unpack

local CreateFrame = CreateFrame
local GetComboPoints = GetComboPoints
local GetShapeshiftFormID = GetShapeshiftFormID
local UnitHasVehicleUI = UnitHasVehicleUI
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

function UF:Construct_Combobar(frame)
	local ComboPoints = CreateFrame("Frame", nil, frame)
	ComboPoints:CreateBackdrop("Default", nil, nil, UF.thinBorders, true)
	ComboPoints.backdrop:Hide()

	for i = 1, MAX_COMBO_POINTS do
		ComboPoints[i] = CreateFrame("StatusBar", frame:GetName().."ComboBarButton"..i, ComboPoints)
		ComboPoints[i]:SetStatusBarTexture(E.media.blankTex)
		UF.statusbars[ComboPoints[i]] = true

		ComboPoints[i]:CreateBackdrop("Default", nil, nil, UF.thinBorders, true)
		ComboPoints[i].backdrop:SetParent(ComboPoints)

		ComboPoints[i].bg = ComboPoints[i]:CreateTexture(nil, "BORDER")
		ComboPoints[i].bg:SetAllPoints()
		ComboPoints[i].bg:SetTexture(E.media.blankTex)
		ComboPoints[i].bg:SetParent(ComboPoints[i].backdrop)
	end

	if E.myclass == "DRUID" then
		frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM", UF.UpdateComboDisplay)
	end

	ComboPoints.Override = UF.UpdateComboDisplay

	ComboPoints:SetScript("OnShow", UF.ToggleResourceBar)
	ComboPoints:SetScript("OnHide", UF.ToggleResourceBar)

	return ComboPoints
end

function UF:Configure_ComboPoints(frame)
	if not frame.VARIABLES_SET then return end
	local ComboPoints = frame.ComboPoints
	if not ComboPoints then return end

	local db = frame.db
	ComboPoints.Holder = frame.ComboPointsHolder
	ComboPoints.origParent = frame

	--Fix height in case it is lower than the theme allows, or in case it's higher than 30px when not detached
	if not UF.thinBorders and (frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 7) then --A height of 7 means 6px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 7
		if db.combobar then db.combobar.height = 7 end
		UF.ToggleResourceBar(ComboPoints) --Trigger update to health if needed
	elseif UF.thinBorders and (frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 3) then --A height of 3 means 2px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 3
		if db.combobar then db.combobar.height = 3 end
		UF.ToggleResourceBar(ComboPoints) --Trigger update to health if needed
	elseif not frame.CLASSBAR_DETACHED and frame.CLASSBAR_HEIGHT > 30 then
		frame.CLASSBAR_HEIGHT = 10
		if db.combobar then db.combobar.height = 10 end
		UF.ToggleResourceBar(ComboPoints) --Trigger update to health if needed
	end

	--We don't want to modify the original frame.CLASSBAR_WIDTH value, as it bugs out when the classbar gains more buttons
	local CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		CLASSBAR_WIDTH = CLASSBAR_WIDTH * (frame.MAX_CLASS_BAR - 1) / frame.MAX_CLASS_BAR
	elseif frame.CLASSBAR_DETACHED then
		CLASSBAR_WIDTH = db.combobar.detachedWidth - ((UF.BORDER + UF.SPACING) * 2)
	end

	local color = E.db.unitframe.colors.borderColor

	ComboPoints:Width(CLASSBAR_WIDTH)
	ComboPoints:Height(frame.CLASSBAR_HEIGHT - ((UF.BORDER + UF.SPACING) * 2))
	if not ComboPoints.backdrop.ignoreBorderColors then
		ComboPoints.backdrop:SetBackdropColor(color.r, color.g, color.b)
	end
	ComboPoints.backdrop:SetShown(not frame.USE_MINI_CLASSBAR)

	for i = 1, frame.MAX_CLASS_BAR do
		ComboPoints[i]:Hide()
		ComboPoints[i]:SetStatusBarColor(unpack(ElvUF.colors.ComboPoints[i]))
		if not ComboPoints[i].backdrop.ignoreBorderColors then
			ComboPoints[i].backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		end
		ComboPoints[i]:Height(ComboPoints:GetHeight())

		if frame.USE_MINI_CLASSBAR then
			if frame.CLASSBAR_DETACHED and db.combobar.orientation == "VERTICAL" then
				ComboPoints[i]:Width(CLASSBAR_WIDTH)
			else
				ComboPoints[i]:Width((CLASSBAR_WIDTH - ((5 + (UF.BORDER * 2 + UF.SPACING * 2)) * (frame.MAX_CLASS_BAR - 1))) / frame.MAX_CLASS_BAR) --Width accounts for 5px spacing between each button, excluding borders
			end
		elseif i ~= MAX_COMBO_POINTS then
			ComboPoints[i]:Width((CLASSBAR_WIDTH - ((frame.MAX_CLASS_BAR - 1) * (UF.BORDER + UF.SPACING * 3))) / frame.MAX_CLASS_BAR) --combobar width minus total width of dividers between each button, divided by number of buttons
		end

		ComboPoints[i]:GetStatusBarTexture():SetHorizTile(false)
		ComboPoints[i]:SetOrientation("HORIZONTAL")
		ComboPoints[i]:ClearAllPoints()

		if i == 1 then
			ComboPoints[i]:Point("LEFT", ComboPoints)
		else
			if frame.USE_MINI_CLASSBAR then
				if frame.CLASSBAR_DETACHED and db.combobar.orientation == "VERTICAL" then
					ComboPoints[i]:Point("BOTTOM", ComboPoints[i - 1], "TOP", 0, (db.combobar.spacing + UF.BORDER * 2 + UF.SPACING * 2))
				elseif frame.CLASSBAR_DETACHED and db.combobar.orientation == "HORIZONTAL" then
					ComboPoints[i]:Point("LEFT", ComboPoints[i - 1], "RIGHT", (db.combobar.spacing + UF.BORDER * 2 + UF.SPACING * 2), 0) --5px spacing between borders of each button(replaced with Detached Spacing option)
				else
					ComboPoints[i]:Point("LEFT", ComboPoints[i - 1], "RIGHT", (5 + UF.BORDER * 2 + UF.SPACING * 2), 0) --5px spacing between borders of each button
				end
			else
				if i == frame.MAX_CLASS_BAR then
					ComboPoints[i]:Point("LEFT", ComboPoints[i - 1], "RIGHT", UF.BORDER + UF.SPACING * 3, 0)
					ComboPoints[i]:Point("RIGHT", ComboPoints)
				else
					ComboPoints[i]:Point("LEFT", ComboPoints[i - 1], "RIGHT", UF.BORDER + UF.SPACING * 3, 0)
				end
			end
		end

		ComboPoints[i]:Show()
	end

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		ComboPoints:ClearAllPoints()
		ComboPoints:Point("CENTER", frame.Health.backdrop, "TOP", 0, 0)

		ComboPoints:SetParent(frame)
		ComboPoints:SetFrameLevel(50) --RaisedElementParent uses 100, we want it lower than this

		if ComboPoints.Holder and ComboPoints.Holder.mover then
			E:DisableMover(ComboPoints.Holder.mover:GetName())
		end
	elseif frame.CLASSBAR_DETACHED then
		if frame.USE_MINI_CLASSBAR then
			if db.combobar.orientation == "HORIZONTAL" then
				ComboPoints.Holder:Size(db.combobar.detachedWidth + (db.combobar.spacing * 4) - 20, db.combobar.height)
			else
				ComboPoints.Holder:Size(db.combobar.detachedWidth, (db.combobar.height * 5) + (db.combobar.spacing * 4))
			end
		else
			ComboPoints.Holder:Size(db.combobar.detachedWidth, db.combobar.height)
		end

		ComboPoints:ClearAllPoints()
		ComboPoints:Point("BOTTOMLEFT", ComboPoints.Holder, "BOTTOMLEFT", UF.BORDER + UF.SPACING, UF.BORDER + UF.SPACING)

		if not ComboPoints.Holder.mover then
			E:CreateMover(ComboPoints.Holder, "ComboBarMover", L["Combobar"], nil, nil, nil, "ALL,SOLO", nil, "unitframe,individualUnits,target,combobar")
		else
			E:EnableMover(ComboPoints.Holder.mover:GetName())
		end

		ComboPoints:SetParent(db.combobar.parent == "UIPARENT" and E.UIParent or frame)
		ComboPoints:SetFrameStrata(db.combobar.strataAndLevel.useCustomStrata and db.combobar.strataAndLevel.frameStrata or "LOW")
		ComboPoints:SetFrameLevel(db.combobar.strataAndLevel.useCustomLevel and db.combobar.strataAndLevel.frameLevel or frame:GetFrameLevel() + 10) --Health uses 10, Power uses (Health + 5) when attached
	else
		ComboPoints:ClearAllPoints()

		if frame.ORIENTATION == "RIGHT" then
			ComboPoints:Point("BOTTOMRIGHT", frame.Health.backdrop, "TOPRIGHT", -UF.BORDER, UF.SPACING * 3)
		else
			ComboPoints:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", UF.BORDER, UF.SPACING * 3)
		end

		ComboPoints:SetParent(frame)
		ComboPoints:SetFrameStrata("LOW")
		ComboPoints:SetFrameLevel(frame:GetFrameLevel() + 10) --Health uses 10, Power uses (Health + 5) when attached

		if ComboPoints.Holder and ComboPoints.Holder.mover then
			E:DisableMover(ComboPoints.Holder.mover:GetName())
		end
	end

	if frame.CLASSBAR_DETACHED and db.combobar.parent == "UIPARENT" then
		E.FrameLocks[ComboPoints] = true
	else
		E.FrameLocks[ComboPoints] = nil
	end

	if frame.USE_CLASSBAR and not frame:IsElementEnabled("ComboPoints") then
		frame:EnableElement("ComboPoints")
		ComboPoints:Show()
	elseif not frame.USE_CLASSBAR and frame:IsElementEnabled("ComboPoints") then
		frame:DisableElement("ComboPoints")
		ComboPoints:Hide()
	end

	if not frame:IsShown() then
		ComboPoints:ForceUpdate()
	end
end

function UF:UpdateComboDisplay(event, unit)
	if unit == "pet" then return end
	if unit ~= "player" and (event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITING_VEHICLE") then return end

	local db = self.db
	if not db then return end

	local element = self.ComboPoints

	if db.combobar.enable then
		local inVehicle = UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")

		if not inVehicle and E.myclass ~= "ROGUE" and (E.myclass ~= "DRUID" or (E.myclass == "DRUID" and GetShapeshiftFormID() ~= CAT_FORM)) then
			element:Hide()
			UF.ToggleResourceBar(element)
		else
			local cp = GetComboPoints(inVehicle and "vehicle" or "player", "target")
			local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop

			if cp == 0 and db.combobar.autoHide then
				element:Hide()
				UF.ToggleResourceBar(element)
			else
				element:Show()

				for i = 1, MAX_COMBO_POINTS do
					element[i]:SetShown(i <= cp)

					if custom_backdrop then
						element[i].bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
					else
						local r, g, b = element[i]:GetStatusBarColor()
						element[i].bg:SetVertexColor(r * 0.35, g * 0.35, b * 0.35)
					end
				end
				UF.ToggleResourceBar(element)
			end
		end
	else
		element:Hide()
		UF.ToggleResourceBar(element)
	end
end