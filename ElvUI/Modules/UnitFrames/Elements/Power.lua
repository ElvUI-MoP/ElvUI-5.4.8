local E, L, V, P, G = unpack(select(2, ...))
local UF = E:GetModule("UnitFrames")

local random = random

local CreateFrame = CreateFrame
local UnitPowerType = UnitPowerType

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

function UF:Construct_PowerBar(frame, bg, text, textPos)
	local power = CreateFrame("StatusBar", "$parent_PowerBar", frame)
	UF.statusbars[power] = true

	power.RaisedElementParent = CreateFrame("Frame", nil, power)
	power.RaisedElementParent:SetFrameLevel(power:GetFrameLevel() + 100)
	power.RaisedElementParent:SetAllPoints()

	power.PostUpdate = self.PostUpdatePower
	power.PostUpdateColor = self.PostUpdatePowerColor

	if bg then
		power.BG = power:CreateTexture(nil, "BORDER")
		power.BG:SetAllPoints()
		power.BG:SetTexture(E.media.blankTex)
	end

	if text then
		power.value = frame.RaisedElementParent:CreateFontString(nil, "OVERLAY")
		UF:Configure_FontString(power.value)

		local x = -2
		if textPos == "LEFT" then
			x = 2
		end

		power.value:Point(textPos, frame.Health, textPos, x, 0)
	end

	power.colorDisconnected = false
	power.colorTapping = false
	power:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	local clipFrame = CreateFrame("Frame", nil, power)
	clipFrame:SetAllPoints()
	clipFrame:EnableMouse(false)
	clipFrame.__frame = frame
	power.ClipFrame = clipFrame

	return power
end

function UF:Configure_Power(frame, noTemplateChange)
	if not frame.VARIABLES_SET then return end
	local db = frame.db
	local power = frame.Power
	power.origParent = frame

	if frame.USE_POWERBAR then
		if not frame:IsElementEnabled("Power") then
			frame:EnableElement("Power")
			power:Show()
		end
		E:SetSmoothing(power, self.db.smoothbars)

		frame:SetPowerUpdateMethod(E.global.unitframe.effectivePower)
		frame:SetPowerUpdateSpeed(E.global.unitframe.effectivePowerSpeed)

		--Text
		local attachPoint = UF:GetObjectAnchorPoint(frame, db.power.attachTextTo)
		power.value:ClearAllPoints()
		power.value:Point(db.power.position, attachPoint, db.power.position, db.power.xOffset, db.power.yOffset)
		power.value:SetParent(db.power.attachTextTo == "Power" and power.RaisedElementParent or frame.RaisedElementParent)
		frame:Tag(power.value, db.power.text_format)

		power:SetReverseFill(db.power.reverseFill)

		--Colors
		power.colorClass = nil
		power.colorReaction = nil
		power.colorPower = nil

		if self.db.colors.powerclass then
			power.colorClass = true
			power.colorReaction = true
		else
			power.colorPower = true
		end

		--Fix height in case it is lower than the theme allows
		local heightChanged = false
		if not UF.thinBorders and frame.POWERBAR_HEIGHT < 7 then --A height of 7 means 6px for borders and just 1px for the actual power statusbar
			frame.POWERBAR_HEIGHT = 7
			db.power.height = 7
			heightChanged = true
		elseif UF.thinBorders and frame.POWERBAR_HEIGHT < 3 then --A height of 3 means 2px for borders and just 1px for the actual power statusbar
			frame.POWERBAR_HEIGHT = 3
			db.power.height = 3
			heightChanged = true
		end
		if heightChanged then
			--Update health size
			frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)
			UF:Configure_HealthBar(frame)
		end

		--Position
		power:ClearAllPoints()
		if frame.POWERBAR_DETACHED then
			power:Width(frame.POWERBAR_WIDTH - ((UF.BORDER + UF.SPACING) * 2))
			power:Height(frame.POWERBAR_HEIGHT - ((UF.BORDER + UF.SPACING) * 2))
			if not power.Holder or (power.Holder and not power.Holder.mover) then
				power.Holder = CreateFrame("Frame", nil, power)
				power.Holder:Size(frame.POWERBAR_WIDTH, frame.POWERBAR_HEIGHT)
				power.Holder:Point("BOTTOM", frame, "BOTTOM", 0, -20)
				power:ClearAllPoints()
				power:Point("BOTTOMLEFT", power.Holder, "BOTTOMLEFT", UF.BORDER + UF.SPACING, UF.BORDER + UF.SPACING)

				if frame.unitframeType then
					local key = frame.unitframeType:gsub("t(arget)", "T%1"):gsub("p(layer)", "P%1"):gsub("f(ocus)", "F%1"):gsub("p(et)", "P%1")
					E:CreateMover(power.Holder, key.."PowerBarMover", L[key.." Powerbar"], nil, nil, nil, "ALL,SOLO", nil, "unitframe,individualUnits,"..frame.unitframeType..",power")
				end
			else
				power.Holder:Size(frame.POWERBAR_WIDTH, frame.POWERBAR_HEIGHT)
				power:ClearAllPoints()
				power:Point("BOTTOMLEFT", power.Holder, "BOTTOMLEFT", UF.BORDER + UF.SPACING, UF.BORDER + UF.SPACING)
				power.Holder.mover:SetScale(1)
				power.Holder.mover:SetAlpha(1)
			end

			power:SetFrameLevel(50) --RaisedElementParent uses 100, we want lower value to allow certain icons and texts to appear above power
		elseif frame.USE_POWERBAR_OFFSET then
			if frame.ORIENTATION == "LEFT" then
				power:Point("TOPRIGHT", frame.Health, "TOPRIGHT", frame.POWERBAR_OFFSET + (frame.PVPINFO_WIDTH or 0) + (frame.STAGGER_WIDTH or 0), -frame.POWERBAR_OFFSET)
				power:Point("BOTTOMLEFT", frame.Health, "BOTTOMLEFT", frame.POWERBAR_OFFSET, -frame.POWERBAR_OFFSET)
			elseif frame.ORIENTATION == "MIDDLE" then
				power:Point("TOPLEFT", frame, "TOPLEFT", UF.BORDER + UF.SPACING, -frame.POWERBAR_OFFSET - frame.CLASSBAR_YOFFSET)
				power:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -UF.BORDER - UF.SPACING, UF.BORDER)
			else
				power:Point("TOPLEFT", frame.Health, "TOPLEFT", -frame.POWERBAR_OFFSET - (frame.PVPINFO_WIDTH or 0) - (frame.STAGGER_WIDTH or 0), -frame.POWERBAR_OFFSET)
				power:Point("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -frame.POWERBAR_OFFSET, -frame.POWERBAR_OFFSET)
			end
			power:SetFrameLevel(frame.Health:GetFrameLevel() - 5) --Health uses 10
		elseif frame.USE_INSET_POWERBAR then
			power:Height(frame.POWERBAR_HEIGHT - ((UF.BORDER + UF.SPACING) * 2))
			power:Point("BOTTOMLEFT", frame.Health, "BOTTOMLEFT", UF.BORDER + (UF.BORDER * 2), UF.BORDER + (UF.BORDER * 2))
			power:Point("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -(UF.BORDER + (UF.BORDER * 2)), UF.BORDER + (UF.BORDER * 2))
			power:SetFrameLevel(50)
		elseif frame.USE_MINI_POWERBAR then
			power:Height(frame.POWERBAR_HEIGHT - ((UF.BORDER + UF.SPACING) * 2))

			if frame.ORIENTATION == "LEFT" then
				power:Width(frame.POWERBAR_WIDTH - UF.BORDER * 2)
				power:Point("RIGHT", frame, "BOTTOMRIGHT", -(UF.BORDER * 2 + 4) - (frame.PVPINFO_WIDTH or 0) - (frame.STAGGER_WIDTH or 0), ((frame.POWERBAR_HEIGHT - UF.BORDER) / 2))
			elseif frame.ORIENTATION == "RIGHT" then
				power:Width(frame.POWERBAR_WIDTH - UF.BORDER * 2)
				power:Point("LEFT", frame, "BOTTOMLEFT", (UF.BORDER * 2 + 4) + (frame.PVPINFO_WIDTH or 0) + (frame.STAGGER_WIDTH or 0), ((frame.POWERBAR_HEIGHT - UF.BORDER) / 2))
			else
				power:Point("LEFT", frame, "BOTTOMLEFT", (UF.BORDER * 2 + 4), ((frame.POWERBAR_HEIGHT - UF.BORDER) / 2))
				power:Point("RIGHT", frame, "BOTTOMRIGHT", -(UF.BORDER * 2 + 4) - (frame.STAGGER_WIDTH or 0), ((frame.POWERBAR_HEIGHT - UF.BORDER) / 2))
			end

			power:SetFrameLevel(50)
		else
			power:Point("TOPRIGHT", frame.Health.backdrop, "BOTTOMRIGHT", -UF.BORDER, -UF.SPACING * 3)
			power:Point("TOPLEFT", frame.Health.backdrop, "BOTTOMLEFT", UF.BORDER, -UF.SPACING * 3)
			power:Height(frame.POWERBAR_HEIGHT - ((UF.BORDER + UF.SPACING) * 2))

			power:SetFrameLevel(frame.Health:GetFrameLevel() + 5) --Health uses 10
		end

		--Hide mover until we detach again
		if not frame.POWERBAR_DETACHED then
			if power.Holder and power.Holder.mover then
				power.Holder.mover:SetScale(0.0001)
				power.Holder.mover:SetAlpha(0)
			end
		end

		if db.power.strataAndLevel and db.power.strataAndLevel.useCustomStrata then
			power:SetFrameStrata(db.power.strataAndLevel.frameStrata)
		else
			power:SetFrameStrata("LOW")
		end
		if db.power.strataAndLevel and db.power.strataAndLevel.useCustomLevel then
			power:SetFrameLevel(db.power.strataAndLevel.frameLevel)
		end

		power.backdrop:SetFrameLevel(power:GetFrameLevel() - 1)

		if frame.POWERBAR_DETACHED and db.power.parent == "UIPARENT" then
			E.FrameLocks[power] = true
			power:SetParent(E.UIParent)
		else
			E.FrameLocks[power] = nil
			power:SetParent(frame)
		end
	elseif frame:IsElementEnabled("Power") then
		frame:DisableElement("Power")
		power:Hide()
		frame:Tag(power.value, "")
	end

	power.custom_backdrop = UF.db.colors.custompowerbackdrop and UF.db.colors.power_backdrop

	--Transparency Settings
	UF:ToggleTransparentStatusBar(UF.db.colors.transparentPower, power, power.BG, nil, UF.db.colors.invertPower, db.power.reverseFill, noTemplateChange)
end

local tokens = {[0] = "MANA", "RAGE", "FOCUS", "ENERGY", "RUNIC_POWER"}
function UF:PostUpdatePowerColor()
	local parent = self.origParent or self:GetParent()
	if parent.isForced and not self.colorClass then
		local color = ElvUF.colors.power[tokens[random(0, 4)]]
		self:SetStatusBarColor(color[1], color[2], color[3])

		if self.BG then
			UF:UpdateBackdropTextureColor(self.BG, color[1], color[2], color[3])
		end
	end
end

local powerTypesFull = {MANA = true, FOCUS = true, ENERGY = true}
local powerTypesEmpty = {RAGE = true, RUNIC_POWER = true}

function UF:PostUpdatePower(unit)
	local parent = self.origParent or self:GetParent()
	if parent.isForced then
		self.cur = random(1, 100)
		self.max = 100
		self:SetMinMaxValues(0, self.max)
		self:SetValue(self.cur)
	end

	local db = parent.db and parent.db.power
	if not db then return end

	if (unit == "player" or unit == "target") and db.autoHide and parent.POWERBAR_DETACHED then
		local _, powerType = UnitPowerType(unit)
		if ((powerTypesFull[powerType] and self.cur == self.max) or self.cur == self.min) or (powerTypesEmpty[powerType] and self.cur == 0) then
			self:Hide()
		else
			self:Show()
		end
	elseif not self:IsShown() then
		self:Show()
	end

	if db.hideonnpc then
		UF:PostNamePosition(parent, unit)
	end

	--Force update to AdditionalPower in order to reposition text if necessary
	if parent:IsElementEnabled("AdditionalPower") then
		E:Delay(0.01, parent.AdditionalPower.ForceUpdate, parent.AdditionalPower) --Delay it slightly so Power text has a chance to clear itself first
	end
end