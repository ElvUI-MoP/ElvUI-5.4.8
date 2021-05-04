local E, L, V, P, G = unpack(select(2, ...))
local AB = E:GetModule("ActionBars")

local _G = _G
local ceil = math.ceil
local gsub, format, find, match = string.gsub, string.format, string.find, string.match

local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local GetShapeshiftForm = GetShapeshiftForm
local GetNumShapeshiftForms = GetNumShapeshiftForms
local GetShapeshiftFormCooldown = GetShapeshiftFormCooldown
local GetShapeshiftFormInfo = GetShapeshiftFormInfo
local CooldownFrame_SetTimer = CooldownFrame_SetTimer
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local GetBindingKey = GetBindingKey
local NUM_STANCE_SLOTS = NUM_STANCE_SLOTS

local Masque = E.Libs.Masque
local MasqueGroup = Masque and Masque:Group("ElvUI", "Stance Bar")

local bar = CreateFrame("Frame", "ElvUI_StanceBar", E.UIParent, "SecureHandlerStateTemplate")

function AB:UPDATE_SHAPESHIFT_COOLDOWN()
	local numForms = GetNumShapeshiftForms()
	local start, duration, enable, cooldown
	for i = 1, NUM_STANCE_SLOTS do
		if i <= numForms then
			cooldown = _G["ElvUI_StanceBarButton"..i.."Cooldown"]
			start, duration, enable = GetShapeshiftFormCooldown(i)
			CooldownFrame_SetTimer(cooldown, start, duration, enable)
		end
	end

	self:StyleShapeShift("UPDATE_SHAPESHIFT_COOLDOWN")
end

function AB:StyleShapeShift()
	local numForms = GetNumShapeshiftForms()
	local texture, name, isActive, isCastable, _
	local buttonName, button, icon, cooldown
	local stance = GetShapeshiftForm()

	for i = 1, NUM_STANCE_SLOTS do
		buttonName = "ElvUI_StanceBarButton"..i
		button = _G[buttonName]
		icon = _G[buttonName.."Icon"]
		cooldown = _G[buttonName.."Cooldown"]

		if i <= numForms then
			texture, name, isActive, isCastable = GetShapeshiftFormInfo(i)

			if self.db.stanceBar.style == "darkenInactive" then
				if name then
					_, _, texture = GetSpellInfo(name)
				end
			end

			if not texture then
				texture = "Interface\\Icons\\Spell_Nature_WispSplode"
			end

			if not button.useMasque then
				if texture then
					cooldown:SetAlpha(1)
				else
					cooldown:SetAlpha(0)
				end

				if isActive then
					StanceBarFrame.lastSelected = button:GetID()
					if numForms == 1 then
						button.checked:SetTexture(1, 1, 1, 0.5)
						button:SetChecked(true)
					else
						button.checked:SetTexture(1, 1, 1, 0.5)
						button:SetChecked(self.db.stanceBar.style ~= "darkenInactive")
					end
				else
					if numForms == 1 or stance == 0 then
						button:SetChecked(false)
					else
						button:SetChecked(self.db.stanceBar.style == "darkenInactive")
						button.checked:SetAlpha(1)
						if self.db.stanceBar.style == "darkenInactive" then
							button.checked:SetTexture(0, 0, 0, 0.5)
						else
							button.checked:SetTexture(1, 1, 1, 0.5)
						end
					end
				end
			else
				if isActive then
					button:SetChecked(true)
				else
					button:SetChecked(false)
				end
			end

			icon:SetTexture(texture)

			if isCastable then
				icon:SetVertexColor(1.0, 1.0, 1.0)
			else
				icon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end
	end
end

function AB:PositionAndSizeBarShapeShift()
	local buttonSpacing = E:Scale(self.db.stanceBar.buttonSpacing)
	local backdropSpacing = E:Scale((self.db.stanceBar.backdropSpacing or self.db.stanceBar.buttonSpacing))
	local buttonsPerRow = self.db.stanceBar.buttonsPerRow
	local numButtons = self.db.stanceBar.buttons
	local size = E:Scale(self.db.stanceBar.buttonSize)
	local point = self.db.stanceBar.point
	local widthMult = self.db.stanceBar.widthMult
	local heightMult = self.db.stanceBar.heightMult

	--Convert "TOP" or "BOTTOM" to anchor points we can use
	local position = E:GetScreenQuadrant(bar)
	if find(position, "LEFT") or position == "TOP" or position == "BOTTOM" then
		if point == "TOP" then
			point = "TOPLEFT"
		elseif point == "BOTTOM" then
			point = "BOTTOMLEFT"
		end
	elseif point == "TOP" then
		point = "TOPRIGHT"
	elseif point == "BOTTOM" then
		point = "BOTTOMRIGHT"
	end

	bar.db = self.db.stanceBar
	bar.mouseover = self.db.stanceBar.mouseover

	if bar.LastButton and numButtons > bar.LastButton then
		numButtons = bar.LastButton
	end

	if bar.LastButton and buttonsPerRow > bar.LastButton then
		buttonsPerRow = bar.LastButton
	end

	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons
	end

	local numColumns = ceil(numButtons / buttonsPerRow)
	if numColumns < 1 then
		numColumns = 1
	end

	if self.db.stanceBar.backdrop == true then
		bar.backdrop:Show()
	else
		bar.backdrop:Hide()
		--Set size multipliers to 1 when backdrop is disabled
		widthMult = 1
		heightMult = 1
	end

	local barWidth = (size * (buttonsPerRow * widthMult)) + ((buttonSpacing * (buttonsPerRow - 1)) * widthMult) + (buttonSpacing * (widthMult - 1)) + ((self.db.stanceBar.backdrop and (E.Border + backdropSpacing) or E.Spacing)*2)
	local barHeight = (size * (numColumns * heightMult)) + ((buttonSpacing * (numColumns - 1)) * heightMult) + (buttonSpacing * (heightMult - 1)) + ((self.db.stanceBar.backdrop and (E.Border + backdropSpacing) or E.Spacing)*2)
	bar:Width(barWidth)
	bar:Height(barHeight)

	local horizontalGrowth, verticalGrowth
	if point == "TOPLEFT" or point == "TOPRIGHT" then
		verticalGrowth = "DOWN"
	else
		verticalGrowth = "UP"
	end

	if point == "BOTTOMLEFT" or point == "TOPLEFT" then
		horizontalGrowth = "RIGHT"
	else
		horizontalGrowth = "LEFT"
	end

	bar:SetParent(bar.db.inheritGlobalFade and self.fadeParent or E.UIParent)
	bar:EnableMouse(not self.db.stanceBar.clickThrough)
	bar:SetAlpha(bar.db.mouseover and 0 or bar.db.alpha)
	bar:SetFrameStrata(bar.db.frameStrata or "LOW")
	bar:SetFrameLevel(bar.db.frameLevel)

	local button, lastButton, lastColumnButton
	local firstButtonSpacing = (self.db.stanceBar.backdrop and (E.Border + backdropSpacing) or E.Spacing)

	for i = 1, NUM_STANCE_SLOTS do
		button = _G["ElvUI_StanceBarButton"..i]
		lastButton = _G["ElvUI_StanceBarButton"..i - 1]
		lastColumnButton = _G["ElvUI_StanceBarButton"..i - buttonsPerRow]

		button:SetParent(bar)
		button:ClearAllPoints()
		button:Size(size)
		button:EnableMouse(not self.db.stanceBar.clickThrough)

		if i == 1 then
			local x, y
			if point == "BOTTOMLEFT" then
				x, y = firstButtonSpacing, firstButtonSpacing
			elseif point == "TOPRIGHT" then
				x, y = -firstButtonSpacing, -firstButtonSpacing
			elseif point == "TOPLEFT" then
				x, y = firstButtonSpacing, -firstButtonSpacing
			else
				x, y = -firstButtonSpacing, firstButtonSpacing
			end

			button:Point(point, bar, point, x, y)
		elseif (i - 1) % buttonsPerRow == 0 then
			local x = 0
			local y = -buttonSpacing
			local buttonPoint, anchorPoint = "TOP", "BOTTOM"
			if verticalGrowth == "UP" then
				y = buttonSpacing
				buttonPoint = "BOTTOM"
				anchorPoint = "TOP"
			end
			button:Point(buttonPoint, lastColumnButton, anchorPoint, x, y)
		else
			local x = buttonSpacing
			local y = 0
			local buttonPoint, anchorPoint = "LEFT", "RIGHT"
			if horizontalGrowth == "LEFT" then
				x = -buttonSpacing
				buttonPoint = "RIGHT"
				anchorPoint = "LEFT"
			end

			button:Point(buttonPoint, lastButton, anchorPoint, x, y)
		end

		if i > numButtons then
			button:SetAlpha(0)
		else
			button:SetAlpha(bar.db.alpha)
		end

		if not button.FlyoutUpdateFunc then
			self:StyleButton(button, nil, MasqueGroup and E.private.actionbar.masque.stanceBar and true or nil)
		end
	end

	if MasqueGroup and E.private.actionbar.masque.stanceBar then
		MasqueGroup:ReSkin()
	end

	if self.db.stanceBar.enabled then
		local visibility = self.db.stanceBar.visibility
		if visibility and match(visibility, "[\n\r]") then
			visibility = gsub(visibility, "[\n\r]", "")
		end

		RegisterStateDriver(bar, "visibility", (GetNumShapeshiftForms() == 0 and "hide") or visibility)
		E:EnableMover(bar.mover:GetName())
	else
		RegisterStateDriver(bar, "visibility", "hide")
		E:DisableMover(bar.mover:GetName())
	end
end

function AB:AdjustMaxStanceButtons(event)
	if InCombatLockdown() then
		AB.NeedsAdjustMaxStanceButtons = event or true
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	for i = 1, #bar.buttons do
		bar.buttons[i]:Hide()
	end

	local numButtons = GetNumShapeshiftForms()
	for i = 1, NUM_STANCE_SLOTS do
		if not bar.buttons[i] then
			bar.buttons[i] = CreateFrame("CheckButton", format(bar:GetName().."Button%d", i), bar, "StanceButtonTemplate")
			bar.buttons[i]:SetID(i)
			if MasqueGroup and E.private.actionbar.masque.stanceBar then
				MasqueGroup:AddButton(bar.buttons[i])
			end
			self:HookScript(bar.buttons[i], "OnEnter", "Button_OnEnter")
			self:HookScript(bar.buttons[i], "OnLeave", "Button_OnLeave")
		end

		if i <= numButtons then
			bar.buttons[i]:Show()
			bar.LastButton = i
		else
			bar.buttons[i]:Hide()
		end
	end

	self:PositionAndSizeBarShapeShift()

	-- sometimes after combat lock down `event` may be true because of passing it back with `AB.NeedsAdjustMaxStanceButtons`
	if event == "UPDATE_SHAPESHIFT_FORMS" then
		self:StyleShapeShift()
	end
end

function AB:UpdateStanceBindings()
	for i = 1, NUM_STANCE_SLOTS do
		local button = _G["ElvUI_StanceBarButton"..i]
		local hotKey = _G["ElvUI_StanceBarButton"..i.."HotKey"]

		if AB.db.hotkeytext and not AB.db.stanceBar.hideHotkey then
			local key = GetBindingKey("SHAPESHIFTBUTTON"..i)
			local color = AB.db.fontColor

			hotKey:Show()
			hotKey:SetText(key)
			hotKey:SetTextColor(color.r, color.g, color.b)
			AB:FixKeybindText(button)
		else
			hotKey:Hide()
		end
	end
end

function AB:CreateBarShapeShift()
	bar:CreateBackdrop(self.db.transparentBackdrops and "Transparent")
	bar.backdrop:SetAllPoints()
	bar:Point("TOPLEFT", E.UIParent, "TOPLEFT", 4, -4)
	bar.buttons = {}

	self:HookScript(bar, "OnEnter", "Bar_OnEnter")
	self:HookScript(bar, "OnLeave", "Bar_OnLeave")

	self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", "AdjustMaxStanceButtons")
	self:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
	self:RegisterEvent("UPDATE_SHAPESHIFT_USABLE", "StyleShapeShift")
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "StyleShapeShift")
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED", "StyleShapeShift")

	E:CreateMover(bar, "ShiftAB", L["Stance Bar"], nil, -3, nil, "ALL, ACTIONBARS", nil, "actionbar,stanceBar", true)

	self:AdjustMaxStanceButtons()
	self:PositionAndSizeBarShapeShift()
	self:StyleShapeShift()
	self:UpdateStanceBindings()
end