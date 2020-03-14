local E, L, V, P, G = unpack(select(2, ...))
local AB = E:GetModule("ActionBars")

local _G = _G
local pairs, select, unpack = pairs, select, unpack
local ceil = math.ceil
local format, gsub, match, split, strfind = string.format, string.gsub, string.match, string.split, strfind

local CanExitVehicle = CanExitVehicle
local ClearOverrideBindings = ClearOverrideBindings
local CreateFrame = CreateFrame
local C_PetBattlesIsInBattle = C_PetBattles.IsInBattle
local GameTooltip_Hide = GameTooltip_Hide
local GetBindingKey = GetBindingKey
local GetFlyoutID = GetFlyoutID
local GetMouseFocus = GetMouseFocus
local GetNumFlyouts, GetFlyoutInfo = GetNumFlyouts, GetFlyoutInfo
local GetOverrideBarIndex = GetOverrideBarIndex
local GetVehicleBarIndex = GetVehicleBarIndex
local HasOverrideActionBar, HasVehicleActionBar = HasOverrideActionBar, HasVehicleActionBar
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local MainMenuBarVehicleLeaveButton_OnEnter = MainMenuBarVehicleLeaveButton_OnEnter
local PetDismiss = PetDismiss
local RegisterStateDriver = RegisterStateDriver
local SetClampedTextureRotation = SetClampedTextureRotation
local SetCVar = SetCVar
local SetModifiedClick = SetModifiedClick
local SetOverrideBindingClick = SetOverrideBindingClick
local UnitAffectingCombat = UnitAffectingCombat
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitExists = UnitExists
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnregisterStateDriver = UnregisterStateDriver
local VehicleExit = VehicleExit
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local LEAVE_VEHICLE = LEAVE_VEHICLE

local LAB = E.Libs.LAB
local LSM = E.Libs.LSM
local Masque = E.Libs.Masque
local MasqueGroup = Masque and Masque:Group("ElvUI", "ActionBars")

local UIHider

AB.handledBars = {} --List of all bars
AB.handledbuttons = {} --List of all buttons that have been modified.
AB.barDefaults = {
	bar1 = {
		page = 1,
		bindButtons = "ACTIONBUTTON",
		conditions = format("[vehicleui] %d; [possessbar] %d; [overridebar] %d; [shapeshift] 13; [form,noform] 0; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;", GetVehicleBarIndex(), GetVehicleBarIndex(), GetOverrideBarIndex()),
		position = "BOTTOM,ElvUIParent,BOTTOM,0,4"
	},
	bar2 = {
		page = 5,
		bindButtons = "MULTIACTIONBAR2BUTTON",
		conditions = "",
		position = "BOTTOM,ElvUI_Bar1,TOP,0,2"
	},
	bar3 = {
		page = 6,
		bindButtons = "MULTIACTIONBAR1BUTTON",
		conditions = "",
		position = "LEFT,ElvUI_Bar1,RIGHT,4,0"
	},
	bar4 = {
		page = 4,
		bindButtons = "MULTIACTIONBAR4BUTTON",
		conditions = "",
		position = "RIGHT,ElvUIParent,RIGHT,-4,0"
	},
	bar5 = {
		page = 3,
		bindButtons = "MULTIACTIONBAR3BUTTON",
		conditions = "",
		position = "RIGHT,ElvUI_Bar1,LEFT,-4,0"
	},
	bar6 = {
		page = 2,
		bindButtons = "ELVUIBAR6BUTTON",
		conditions = "",
		position = "BOTTOM,ElvUI_Bar2,TOP,0,2"
	},
	bar7 = {
		page = 7,
		bindButtons = "EXTRABAR7BUTTON",
		conditions = "",
		position = "BOTTOM,ElvUI_Bar1,TOP,0,82"
	},
	bar8 = {
		page = 8,
		bindButtons = "EXTRABAR8BUTTON",
		conditions = "",
		position = "BOTTOM,ElvUI_Bar1,TOP,0,122'"
	},
	bar9 = {
		page = 9,
		bindButtons = "EXTRABAR9BUTTON",
		conditions = "",
		position = "BOTTOM,ElvUI_Bar1,TOP,0,162"
	},
	bar10 = {
		page = 10,
		bindButtons = "EXTRABAR10BUTTON",
		conditions = "",
		position = "BOTTOM,ElvUI_Bar1,TOP,0,202"
	}
}

AB.customExitButton = {
	func = function()
		if UnitExists("vehicle") then
			VehicleExit()
		else
			PetDismiss()
		end
	end,
	texture = "Interface\\Icons\\Spell_Shadow_SacrificialShield",
	tooltip = LEAVE_VEHICLE
}

function AB:PositionAndSizeBar(barName)
	local buttonSpacing = E:Scale(self.db[barName].buttonspacing)
	local backdropSpacing = E:Scale((self.db[barName].backdropSpacing or self.db[barName].buttonspacing))
	local buttonsPerRow = self.db[barName].buttonsPerRow
	local numButtons = self.db[barName].buttons
	local size = E:Scale(self.db[barName].buttonsize)
	local point = self.db[barName].point
	local numColumns = ceil(numButtons / buttonsPerRow)
	local widthMult = self.db[barName].widthMult
	local heightMult = self.db[barName].heightMult
	local visibility = self.db[barName].visibility
	local bar = self.handledBars[barName]

	bar.db = self.db[barName]
	bar.db.position = nil --Depreciated

	if visibility and match(visibility, "[\n\r]") then
		visibility = gsub(visibility, "[\n\r]","")
	end

	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons
	end

	if numColumns < 1 then
		numColumns = 1
	end

	if bar.db.backdrop then
		bar.backdrop:Show()
	else
		bar.backdrop:Hide()
		--Set size multipliers to 1 when backdrop is disabled
		widthMult = 1
		heightMult = 1
	end

	local sideSpacing = (bar.db.backdrop == true and (E.Border + backdropSpacing) or E.Spacing)
	--Size of all buttons + Spacing between all buttons + Spacing between additional rows of buttons + Spacing between backdrop and buttons + Spacing on end borders with non-thin borders
	local barWidth = (size * (buttonsPerRow * widthMult)) + ((buttonSpacing * (buttonsPerRow - 1)) * widthMult) + (buttonSpacing * (widthMult - 1)) + (sideSpacing*2)
	local barHeight = (size * (numColumns * heightMult)) + ((buttonSpacing * (numColumns - 1)) * heightMult) + (buttonSpacing * (heightMult - 1)) + (sideSpacing*2)
	bar:Width(barWidth)
	bar:Height(barHeight)

	bar.mouseover = bar.db.mouseover

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

	if bar.db.mouseover then
		bar:SetAlpha(0)
	else
		bar:SetAlpha(bar.db.alpha)
	end

	if bar.db.inheritGlobalFade then
		bar:SetParent(self.fadeParent)
	else
		bar:SetParent(E.UIParent)
	end

	bar:EnableMouse(not bar.db.clickThrough)

	local button, lastButton, lastColumnButton
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		button = bar.buttons[i]
		lastButton = bar.buttons[i - 1]
		lastColumnButton = bar.buttons[i-buttonsPerRow]
		button:SetParent(bar)
		button:ClearAllPoints()
		button:SetAttribute("showgrid", 1)
		button:Size(size)
		button:EnableMouse(not bar.db.clickThrough)

		if i == 1 then
			local x, y
			if point == "BOTTOMLEFT" then
				x, y = sideSpacing, sideSpacing
			elseif point == "TOPRIGHT" then
				x, y = -sideSpacing, -sideSpacing
			elseif point == "TOPLEFT" then
				x, y = sideSpacing, -sideSpacing
			else
				x, y = -sideSpacing, sideSpacing
			end

			button:Point(point, bar, point, x, y)
		elseif (i - 1) % buttonsPerRow == 0 then
			local y = -buttonSpacing
			local buttonPoint, anchorPoint = "TOP", "BOTTOM"
			if verticalGrowth == "UP" then
				y = buttonSpacing
				buttonPoint = "BOTTOM"
				anchorPoint = "TOP"
			end
			button:Point(buttonPoint, lastColumnButton, anchorPoint, 0, y)
		else
			local x = buttonSpacing
			local buttonPoint, anchorPoint = "LEFT", "RIGHT"
			if horizontalGrowth == "LEFT" then
				x = -buttonSpacing
				buttonPoint = "RIGHT"
				anchorPoint = "LEFT"
			end

			button:Point(buttonPoint, lastButton, anchorPoint, x, 0)
		end

		if i > numButtons then
			button:Hide()
		else
			button:Show()
		end

		self:StyleButton(button, nil, (MasqueGroup and E.private.actionbar.masque.actionbars) or nil)
	end

	if bar.db.enabled or not bar.initialized then
		if not bar.db.mouseover then
			bar:SetAlpha(bar.db.alpha)
		end

		local page = self:GetPage(barName, self.barDefaults[barName].page, self.barDefaults[barName].conditions)
		if AB.barDefaults["bar"..bar.id].conditions:find("[form,noform]") then
			bar:SetAttribute("hasTempBar", true)

			local newCondition = gsub(AB.barDefaults["bar"..bar.id].conditions, " %[form,noform%] 0; ", "")
			bar:SetAttribute("newCondition", newCondition)
		else
			bar:SetAttribute("hasTempBar", false)
		end

		bar:Show()
		RegisterStateDriver(bar, "visibility", visibility)
		RegisterStateDriver(bar, "page", page)
		bar:SetAttribute("page", page)

		if not bar.initialized then
			bar.initialized = true
			AB:PositionAndSizeBar(barName)
			return
		end
		E:EnableMover(bar.mover:GetName())
	else
		E:DisableMover(bar.mover:GetName())
		bar:Hide()
		UnregisterStateDriver(bar, "visibility")
	end

	E:SetMoverSnapOffset("ElvAB_"..bar.id, bar.db.buttonspacing / 2)

	if MasqueGroup and E.private.actionbar.masque.actionbars then
		MasqueGroup:ReSkin()
	end
end

function AB:CreateBar(id)
	local bar = CreateFrame("Frame", "ElvUI_Bar"..id, E.UIParent, "SecureHandlerStateTemplate")
	local point, anchor, attachTo, x, y = split(",", self.barDefaults["bar"..id].position)
	bar:Point(point, anchor, attachTo, x, y)
	bar.id = id
	bar:CreateBackdrop(self.db.transparentBackdrops and "Transparent")
	bar:SetFrameStrata("LOW")

	--Use this method instead of :SetAllPoints, as the size of the mover would otherwise be incorrect
	bar.backdrop:SetPoint("TOPLEFT", bar, "TOPLEFT", E.Spacing, -E.Spacing)
	bar.backdrop:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -E.Spacing, E.Spacing)

	bar.buttons = {}
	bar.bindButtons = self.barDefaults["bar"..id].bindButtons
	self:HookScript(bar, "OnEnter", "Bar_OnEnter")
	self:HookScript(bar, "OnLeave", "Bar_OnLeave")

	for i = 1, 12 do
		bar.buttons[i] = LAB:CreateButton(i, format(bar:GetName().."Button%d", i), bar, nil)
		bar.buttons[i]:SetState(0, "action", i)
		for k = 1, 14 do
			bar.buttons[i]:SetState(k, "action", (k - 1) * 12 + i)
		end

		if i == 12 then
			bar.buttons[i]:SetState(11, "custom", AB.customExitButton)
		end

		if MasqueGroup and E.private.actionbar.masque.actionbars then
			bar.buttons[i]:AddToMasque(MasqueGroup)
		end

		self:HookScript(bar.buttons[i], "OnEnter", "Button_OnEnter")
		self:HookScript(bar.buttons[i], "OnLeave", "Button_OnLeave")
	end
	self:UpdateButtonConfig(bar, bar.bindButtons)

	bar:SetAttribute("_onstate-page", [[
		if HasTempShapeshiftActionBar() and self:GetAttribute("hasTempBar") then
			newstate = GetTempShapeshiftBarIndex() or newstate
		end

		if newstate ~= 0 then
			self:SetAttribute("state", newstate)
			control:ChildUpdate("state", newstate)
		else
			local newCondition = self:GetAttribute("newCondition")
			if newCondition then
				newstate = SecureCmdOptionParse(newCondition)
				self:SetAttribute("state", newstate)
				control:ChildUpdate("state", newstate)
			end
		end
	]])

	self.handledBars["bar"..id] = bar
	E:CreateMover(bar, "ElvAB_"..id, L["Bar "]..id, nil, nil, nil,"ALL,ACTIONBARS",nil,"actionbar,playerBars,bar"..id)
	self:PositionAndSizeBar("bar"..id)
	return bar
end

function AB:PLAYER_REGEN_ENABLED()
	if AB.NeedsUpdateButtonSettings then
		self:UpdateButtonSettings()
		AB.NeedsUpdateButtonSettings = nil
	end
	if AB.NeedsUpdateMicroBarVisibility then
		self:UpdateMicroBarVisibility()
		AB.NeedsUpdateMicroBarVisibility = nil
	end
	if AB.NeedsAdjustMaxStanceButtons then
		AB:AdjustMaxStanceButtons(AB.NeedsAdjustMaxStanceButtons) --sometimes it holds the event, otherwise true. pass it before we nil it.
		AB.NeedsAdjustMaxStanceButtons = nil
	end
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

function AB:CreateVehicleLeave()
	local db = E.db.actionbar.vehicleExitButton
	if db.enable ~= true then return end

	local holder = CreateFrame("Frame", "VehicleLeaveButtonHolder", E.UIParent)
	holder:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 300)
	holder:Size(MainMenuBarVehicleLeaveButton:GetSize())
	E:CreateMover(holder, "VehicleLeaveButton", LEAVE_VEHICLE, nil, nil, nil, "ALL,ACTIONBARS", nil, "actionbar,vehicleExitButton")

	MainMenuBarVehicleLeaveButton:ClearAllPoints()
	MainMenuBarVehicleLeaveButton:SetParent(UIParent)
	MainMenuBarVehicleLeaveButton:SetPoint("CENTER", holder, "CENTER")

	RegisterStateDriver(MainMenuBarVehicleLeaveButton, "visibility", "[vehicleui] show;hide")

	if MasqueGroup and E.private.actionbar.masque.actionbars then
		MainMenuBarVehicleLeaveButton:StyleButton(true, true, true)
	else
		MainMenuBarVehicleLeaveButton:CreateBackdrop(nil, true)
		MainMenuBarVehicleLeaveButton:GetNormalTexture():SetTexCoord(0.220625, 0.799375, 0.220625, 0.779375)
		MainMenuBarVehicleLeaveButton:GetPushedTexture():SetTexCoord(0.190625, 0.819375, 0.190625, 0.809375)
		MainMenuBarVehicleLeaveButton:StyleButton(nil, true, true)
		MainMenuBarVehicleLeaveButton.hover:SetAllPoints()
	end

	hooksecurefunc(MainMenuBarVehicleLeaveButton, "SetPoint", function(_, _, parent)
		if parent ~= holder then
			MainMenuBarVehicleLeaveButton:ClearAllPoints()
			MainMenuBarVehicleLeaveButton:SetParent(UIParent)
			MainMenuBarVehicleLeaveButton:SetPoint("CENTER", holder, "CENTER")
		end
	end)

	hooksecurefunc(MainMenuBarVehicleLeaveButton, "SetHighlightTexture", function(btn, tex)
		if tex ~= btn.hover then
			MainMenuBarVehicleLeaveButton:SetHighlightTexture(btn.hover)
		end
	end)

	AB:UpdateVehicleLeave()
end

function AB:UpdateVehicleLeave()
	local db = E.db.actionbar.vehicleExitButton

	MainMenuBarVehicleLeaveButton:Size(db.size)
	MainMenuBarVehicleLeaveButton:SetFrameStrata(db.strata)
	MainMenuBarVehicleLeaveButton:SetFrameLevel(db.level)
	VehicleLeaveButtonHolder:Size(db.size)
end

function AB:ReassignBindings(event)
	if event == "UPDATE_BINDINGS" then
		self:UpdatePetBindings()
		self:UpdateStanceBindings()
	end

	self:UnregisterEvent("PLAYER_REGEN_DISABLED")

	if InCombatLockdown() then return end

	for _, bar in pairs(self.handledBars) do
		if bar then
			ClearOverrideBindings(bar)
			for i = 1, #bar.buttons do
				local button = format(bar.bindButtons.."%d", i)
				local real_button = format(bar:GetName().."Button%d", i)
				for k = 1, select("#", GetBindingKey(button)) do
					local key = select(k, GetBindingKey(button))
					if key and key ~= "" then
						SetOverrideBindingClick(bar, false, key, real_button)
					end
				end
			end
		end
	end
end

function AB:RemoveBindings()
	if InCombatLockdown() then return end

	for _, bar in pairs(self.handledBars) do
		if bar then
			ClearOverrideBindings(bar)
		end
	end

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "ReassignBindings")
end

function AB:UpdateBar1Paging()
	if self.db.bar6.enabled then
		AB.barDefaults.bar1.conditions = format("[vehicleui] %d; [possessbar] %d; [overridebar] %d; [shapeshift] 13; [form,noform] 0; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;", GetVehicleBarIndex(), GetVehicleBarIndex(), GetOverrideBarIndex())
	else
		AB.barDefaults.bar1.conditions = format("[vehicleui] %d; [possessbar] %d; [overridebar] %d; [shapeshift] 13; [form,noform] 0; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;", GetVehicleBarIndex(), GetVehicleBarIndex(), GetOverrideBarIndex())
	end

	if (E.private.actionbar.enable ~= true or InCombatLockdown()) or not self.isInitialized then return end
	local bar2Option = InterfaceOptionsActionBarsPanelBottomRight
	local bar3Option = InterfaceOptionsActionBarsPanelBottomLeft
	local bar4Option = InterfaceOptionsActionBarsPanelRightTwo
	local bar5Option = InterfaceOptionsActionBarsPanelRight

	if (self.db.bar2.enabled and not bar2Option:GetChecked()) or (not self.db.bar2.enabled and bar2Option:GetChecked()) then
		bar2Option:Click()
	end

	if (self.db.bar3.enabled and not bar3Option:GetChecked()) or (not self.db.bar3.enabled and bar3Option:GetChecked()) then
		bar3Option:Click()
	end

	if not self.db.bar5.enabled and not self.db.bar4.enabled then
		if bar4Option:GetChecked() then
			bar4Option:Click()
		end

		if bar5Option:GetChecked() then
			bar5Option:Click()
		end
	elseif not self.db.bar5.enabled then
		if not bar5Option:GetChecked() then
			bar5Option:Click()
		end

		if not bar4Option:GetChecked() then
			bar4Option:Click()
		end
	elseif (self.db.bar4.enabled and not bar4Option:GetChecked()) or (not self.db.bar4.enabled and bar4Option:GetChecked()) then
		bar4Option:Click()
	elseif (self.db.bar5.enabled and not bar5Option:GetChecked()) or (not self.db.bar5.enabled and bar5Option:GetChecked()) then
		bar5Option:Click()
	end
end

function AB:UpdateButtonSettingsForBar(barName)
	local bar = self.handledBars[barName]
	self:UpdateButtonConfig(bar, bar.bindButtons)
end

function AB:UpdateButtonSettings()
	if E.private.actionbar.enable ~= true then return end

	if InCombatLockdown() then
		AB.NeedsUpdateButtonSettings = true
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	for button in pairs(self.handledbuttons) do
		if button then
			self:StyleButton(button, button.noBackdrop, button.useMasque, button.ignoreNormal)
			self:StyleFlyout(button)
		else
			self.handledbuttons[button] = nil
		end
	end

	self:UpdatePetBindings()
	self:UpdateStanceBindings()

	for barName, bar in pairs(self.handledBars) do
		if bar then
			self:UpdateButtonConfig(bar, bar.bindButtons)
			self:PositionAndSizeBar(barName)
		end
	end

	self:AdjustMaxStanceButtons()
	self:PositionAndSizeBarPet()
	self:PositionAndSizeBarShapeShift()
end

function AB:GetPage(bar, defaultPage, condition)
	local page = self.db[bar].paging[E.myclass]
	if not condition then condition = "" end
	if not page then
		page = ""
	elseif page:match("[\n\r]") then
		page = page:gsub("[\n\r]","")
	end

	if page then
		condition = condition.." "..page
	end
	condition = condition.." "..defaultPage

	return condition
end

function AB:StyleButton(button, noBackdrop, useMasque, ignoreNormal)
	local name = button:GetName()
	local macroText = _G[name.."Name"]
	local icon = _G[name.."Icon"]
	local shine = _G[name.."Shine"]
	local count = _G[name.."Count"]
	local flash = _G[name.."Flash"]
	local hotkey = _G[name.."HotKey"]
	local border = _G[name.."Border"]
	local normal = _G[name.."NormalTexture"]
	local normal2 = button:GetNormalTexture()

	local color = self.db.fontColor

	local countPosition = self.db.countTextPosition or "BOTTOMRIGHT"
	local countXOffset = self.db.countTextXOffset or 0
	local countYOffset = self.db.countTextYOffset or 2

	button.noBackdrop = noBackdrop
	button.useMasque = useMasque
	button.ignoreNormal = ignoreNormal

	if normal and not ignoreNormal then normal:SetTexture() normal:Hide() normal:SetAlpha(0) end
	if normal2 then normal2:SetTexture() normal2:Hide() normal2:SetAlpha(0) end
	if border and not button.useMasque then border:Kill() end

	if count then
		count:ClearAllPoints()
		count:Point(countPosition, countXOffset, countYOffset)
		count:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
		count:SetTextColor(color.r, color.g, color.b)
	end

	if macroText then
		macroText:ClearAllPoints()
		macroText:Point("BOTTOM", 0, 1)
		macroText:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
		macroText:SetTextColor(color.r, color.g, color.b)
	end

	if not button.noBackdrop and not button.backdrop and not button.useMasque then
		button:CreateBackdrop(self.db.transparentButtons and "Transparent", true)
		button.backdrop:SetAllPoints()
	end

	if flash then
		if self.db.flashAnimation then
			flash:SetTexture(1.0, 0.2, 0.2, 0.45)
			flash:ClearAllPoints()
			flash:SetOutside(icon, 2, 2)
			flash:SetDrawLayer("BACKGROUND", -1)
		else
			flash:SetTexture()
		end
	end

	if icon then
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
	end

	if shine then
		shine:SetAllPoints()
	end

	if self.db.hotkeytext or self.db.useRangeColorText then
		hotkey:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
		if button.config and (button.config.outOfRangeColoring ~= "hotkey") then
			button.hotkey:SetTextColor(color.r, color.g, color.b)
		end
	end

	--Extra Action Button
	if button.style then
		button.style:SetDrawLayer("BACKGROUND", -7)
	end

	button.FlyoutUpdateFunc = AB.StyleFlyout
	self:FixKeybindText(button)

	if not button.useMasque then
		button:StyleButton()
	else
		button:StyleButton(true, true, true)
	end

	if not self.handledbuttons[button] then
		button.cooldown.CooldownOverride = "actionbar"

		E:RegisterCooldown(button.cooldown)

		self.handledbuttons[button] = true
	end
end

function AB:Bar_OnEnter(bar)
	if bar:GetParent() == self.fadeParent then
		if not self.fadeParent.mouseLock then
			E:UIFrameFadeIn(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1)
		end
	end

	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
	end
end

function AB:Bar_OnLeave(bar)
	if bar:GetParent() == self.fadeParent then
		if not self.fadeParent.mouseLock then
			E:UIFrameFadeOut(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1 - self.db.globalFadeAlpha)
		end
	end

	if bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
	end
end

function AB:Button_OnEnter(button)
	local bar = button:GetParent()
	if bar:GetParent() == self.fadeParent then
		if not self.fadeParent.mouseLock then
			E:UIFrameFadeIn(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1)
		end
	end

	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
	end
end

function AB:Button_OnLeave(button)
	local bar = button:GetParent()
	if bar:GetParent() == self.fadeParent then
		if not self.fadeParent.mouseLock then
			E:UIFrameFadeOut(self.fadeParent, 0.2, self.fadeParent:GetAlpha(), 1 - self.db.globalFadeAlpha)
		end
	end

	if bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
	end
end

function AB:BlizzardOptionsPanel_OnEvent()
	InterfaceOptionsActionBarsPanelBottomRightText:SetFormattedText(L["Remove Bar %d Action Page"], 2)
	InterfaceOptionsActionBarsPanelBottomLeftText:SetFormattedText(L["Remove Bar %d Action Page"], 3)
	InterfaceOptionsActionBarsPanelRightTwoText:SetFormattedText(L["Remove Bar %d Action Page"], 4)
	InterfaceOptionsActionBarsPanelRightText:SetFormattedText(L["Remove Bar %d Action Page"], 5)

	InterfaceOptionsActionBarsPanelBottomRight:SetScript("OnEnter", nil)
	InterfaceOptionsActionBarsPanelBottomLeft:SetScript("OnEnter", nil)
	InterfaceOptionsActionBarsPanelRightTwo:SetScript("OnEnter", nil)
	InterfaceOptionsActionBarsPanelRight:SetScript("OnEnter", nil)
end

function AB:FadeParent_OnEvent(event, unit)
	if (event == "UNIT_SPELLCAST_START"
	or event == "UNIT_SPELLCAST_STOP"
	or event == "UNIT_SPELLCAST_CHANNEL_START"
	or event == "UNIT_SPELLCAST_CHANNEL_STOP"
	or event == "UNIT_HEALTH") and unit ~= "player" then return end

	local cur, max = UnitHealth("player"), UnitHealthMax("player")
	local cast, channel = UnitCastingInfo("player"), UnitChannelInfo("player")
	local target, focus = UnitExists("target"), UnitExists("focus")
	local combat = UnitAffectingCombat("player")
	if (cast or channel) or (cur ~= max) or (target or focus) or combat then
		self.mouseLock = true
		E:UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	else
		self.mouseLock = false
		E:UIFrameFadeOut(self, 0.2, self:GetAlpha(), 1 - AB.db.globalFadeAlpha)
	end
end

function AB:IconIntroTracker_Toggle()
	if self.db.addNewSpells then
		IconIntroTracker:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR")
		IconIntroTracker:Show()
		IconIntroTracker:SetParent(UIParent)
	else
		IconIntroTracker:UnregisterAllEvents()
		IconIntroTracker:Hide()
		IconIntroTracker:SetParent(UIHider)
	end
end

function AB:DisableBlizzard()
	-- Hidden parent frame
	UIHider = CreateFrame("Frame")
	UIHider:Hide()

	MultiBarBottomLeft:SetParent(UIHider)
	MultiBarBottomRight:SetParent(UIHider)
	MultiBarLeft:SetParent(UIHider)
	MultiBarRight:SetParent(UIHider)

	-- Hide MultiBar Buttons, but keep the bars alive
	for i = 1, 12 do
		_G["ActionButton"..i]:Hide()
		_G["ActionButton"..i]:UnregisterAllEvents()
		_G["ActionButton"..i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomLeftButton"..i]:Hide()
		_G["MultiBarBottomLeftButton"..i]:UnregisterAllEvents()
		_G["MultiBarBottomLeftButton"..i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomRightButton"..i]:Hide()
		_G["MultiBarBottomRightButton"..i]:UnregisterAllEvents()
		_G["MultiBarBottomRightButton"..i]:SetAttribute("statehidden", true)

		_G["MultiBarRightButton"..i]:Hide()
		_G["MultiBarRightButton"..i]:UnregisterAllEvents()
		_G["MultiBarRightButton"..i]:SetAttribute("statehidden", true)

		_G["MultiBarLeftButton"..i]:Hide()
		_G["MultiBarLeftButton"..i]:UnregisterAllEvents()
		_G["MultiBarLeftButton"..i]:SetAttribute("statehidden", true)

		if _G["VehicleMenuBarActionButton"..i] then
			_G["VehicleMenuBarActionButton"..i]:Hide()
			_G["VehicleMenuBarActionButton"..i]:UnregisterAllEvents()
			_G["VehicleMenuBarActionButton"..i]:SetAttribute("statehidden", true)
 		end

		if _G["OverrideActionBarButton"..i] then
			_G["OverrideActionBarButton"..i]:Hide()
			_G["OverrideActionBarButton"..i]:UnregisterAllEvents()
			_G["OverrideActionBarButton"..i]:SetAttribute("statehidden", true)
		end

		_G["MultiCastActionButton"..i]:Hide()
		_G["MultiCastActionButton"..i]:UnregisterAllEvents()
		_G["MultiCastActionButton"..i]:SetAttribute("statehidden", true)
	end

	ActionBarController:UnregisterAllEvents()
	ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")

	MainMenuBar:EnableMouse(false)
	MainMenuBar:SetAlpha(0)

	MainMenuExpBar:UnregisterAllEvents()
	MainMenuExpBar:Hide()
	MainMenuExpBar:SetParent(UIHider)

	for i = 1, MainMenuBar:GetNumChildren() do
		local child = select(i, MainMenuBar:GetChildren())
		if child then
			child:UnregisterAllEvents()
			child:Hide()
			child:SetParent(UIHider)
		end
	end

	ReputationWatchBar:UnregisterAllEvents()
	ReputationWatchBar:Hide()
	ReputationWatchBar:SetParent(UIHider)

	MainMenuBarArtFrame:UnregisterEvent("ACTIONBAR_PAGE_CHANGED")
	MainMenuBarArtFrame:UnregisterEvent("ADDON_LOADED")
	MainMenuBarArtFrame:Hide()
	MainMenuBarArtFrame:SetParent(UIHider)

	StanceBarFrame:UnregisterAllEvents()
	StanceBarFrame:Hide()
	StanceBarFrame:SetParent(UIHider)

	OverrideActionBar:UnregisterAllEvents()
	OverrideActionBar:Hide()
	OverrideActionBar:SetParent(UIHider)

	PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:Hide()
	PossessBarFrame:SetParent(UIHider)

	PetActionBarFrame:UnregisterAllEvents()
	PetActionBarFrame:Hide()
	PetActionBarFrame:SetParent(UIHider)

	MultiCastActionBarFrame:UnregisterAllEvents()
	MultiCastActionBarFrame:Hide()
	MultiCastActionBarFrame:SetParent(UIHider)

	--Enable/disable functionality to automatically put spells on the actionbar.
	self:IconIntroTracker_Toggle()

	InterfaceOptionsCombatPanelActionButtonUseKeyDown:SetScale(0.0001)
	InterfaceOptionsCombatPanelActionButtonUseKeyDown:SetAlpha(0)

	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:EnableMouse(false)
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetAlpha(0)

	InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetScale(0.0001)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetAlpha(0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetScale(0.0001)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetAlpha(0)

	InterfaceOptionsActionBarsPanelLockActionBars:SetScale(0.0001)
	InterfaceOptionsActionBarsPanelLockActionBars:SetAlpha(0)

	InterfaceOptionsStatusTextPanelXP:SetAlpha(0)
	InterfaceOptionsStatusTextPanelXP:SetScale(0.0001)

	self:SecureHook("BlizzardOptionsPanel_OnEvent")

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end
end

function AB:UpdateButtonConfig(bar, buttonName)
	if InCombatLockdown() then
		AB.NeedsUpdateButtonSettings = true
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	if not bar.buttonConfig then bar.buttonConfig = {hideElements = {}, colors = {}} end
	bar.buttonConfig.hideElements.macro = not self.db.macrotext
	bar.buttonConfig.hideElements.hotkey = not self.db.hotkeytext
	bar.buttonConfig.showGrid = self.db["bar"..bar.id].showGrid
	bar.buttonConfig.clickOnDown = self.db.keyDown
	bar.buttonConfig.outOfRangeColoring = (self.db.useRangeColorText and "hotkey") or "button"
	SetModifiedClick("PICKUPACTION", self.db.movementModifier)
	bar.buttonConfig.colors.range = E:SetColorTable(bar.buttonConfig.colors.range, self.db.noRangeColor)
	bar.buttonConfig.colors.mana = E:SetColorTable(bar.buttonConfig.colors.mana, self.db.noPowerColor)
	bar.buttonConfig.colors.usable = E:SetColorTable(bar.buttonConfig.colors.usable, self.db.usableColor)
	bar.buttonConfig.colors.notUsable = E:SetColorTable(bar.buttonConfig.colors.notUsable, self.db.notUsableColor)

	for i, button in pairs(bar.buttons) do
		bar.buttonConfig.keyBoundTarget = format(buttonName.."%d", i)
		button.keyBoundTarget = bar.buttonConfig.keyBoundTarget
		button.postKeybind = AB.FixKeybindText
		button:SetAttribute("buttonlock", self.db.lockActionBars)
		button:SetAttribute("checkselfcast", true)
		button:SetAttribute("checkfocuscast", true)
		if self.db.rightClickSelfCast then
			button:SetAttribute("unit2", "player")
		else
			button:SetAttribute("unit2", "target")
		end

		button:UpdateConfig(bar.buttonConfig)
	end
end

function AB:FixKeybindText(button)
	local hotkey = _G[button:GetName().."HotKey"]
	local text = hotkey:GetText()

	local hotkeyPosition = E.db.actionbar.hotkeyTextPosition or "TOPRIGHT"
	local hotkeyXOffset = E.db.actionbar.hotkeyTextXOffset or 0
	local hotkeyYOffset = E.db.actionbar.hotkeyTextYOffset or -3

	local justify = "RIGHT"
	if hotkeyPosition == "TOPLEFT" or hotkeyPosition == "BOTTOMLEFT" then
		justify = "LEFT"
	elseif hotkeyPosition == "TOP" or hotkeyPosition == "BOTTOM" then
		justify = "CENTER"
	end

	if text then
		text = gsub(text, "SHIFT%-", L["KEY_SHIFT"])
		text = gsub(text, "ALT%-", L["KEY_ALT"])
		text = gsub(text, "CTRL%-", L["KEY_CTRL"])
		text = gsub(text, "BUTTON", L["KEY_MOUSEBUTTON"])
		text = gsub(text, "MOUSEWHEELUP", L["KEY_MOUSEWHEELUP"])
		text = gsub(text, "MOUSEWHEELDOWN", L["KEY_MOUSEWHEELDOWN"])
		text = gsub(text, "NUMPAD", L["KEY_NUMPAD"])
		text = gsub(text, "PAGEUP", L["KEY_PAGEUP"])
		text = gsub(text, "PAGEDOWN", L["KEY_PAGEDOWN"])
		text = gsub(text, "SPACE", L["KEY_SPACE"])
		text = gsub(text, "INSERT", L["KEY_INSERT"])
		text = gsub(text, "HOME", L["KEY_HOME"])
		text = gsub(text, "DELETE", L["KEY_DELETE"])
		text = gsub(text, "NMULTIPLY", "*")
		text = gsub(text, "NMINUS", "N-")
		text = gsub(text, "NPLUS", "N+")

		hotkey:SetText(text)
		hotkey:SetJustifyH(justify)
	end

	if not button.useMasque then
		hotkey:ClearAllPoints()
		hotkey:Point(hotkeyPosition, hotkeyXOffset, hotkeyYOffset)
	end
end

AB.FlyoutButtons = 0
function AB:SetupFlyoutButton()
	for i = 1, AB.FlyoutButtons do
		local Button = _G["SpellFlyoutButton"..i]

		--prevent error if you don't have max amount of buttons
		if Button then
			AB:StyleButton(Button, nil, MasqueGroup and E.private.actionbar.masque.actionbars or nil)

			if not InCombatLockdown() then -- Taint
				Button:Size(Button:GetParent():GetParent():GetSize())
			end

			Button:HookScript("OnEnter", function(btn)
				local parent = btn:GetParent()
				local parentAnchorButton = select(2, parent:GetPoint())
				if not AB.handledbuttons[parentAnchorButton] then return end

				local parentAnchorBar = parentAnchorButton:GetParent()
				AB:Bar_OnEnter(parentAnchorBar)
			end)

			Button:HookScript("OnLeave", function(btn)
				local parent = btn:GetParent()
				local parentAnchorButton = select(2, parent:GetPoint())
				if not AB.handledbuttons[parentAnchorButton] then return end

				local parentAnchorBar = parentAnchorButton:GetParent()
				AB:Bar_OnLeave(parentAnchorBar)
			end)

			if MasqueGroup and E.private.actionbar.masque.actionbars then
				MasqueGroup:RemoveButton(Button) --Remove first to fix issue with backdrops appearing at the wrong flyout menu
				MasqueGroup:AddButton(Button)
			end
		end
	end

	SpellFlyout:HookScript("OnEnter", function(btn)
		local anchorButton = select(2, btn:GetPoint())
		if not AB.handledbuttons[anchorButton] then return end

		local parentAnchorBar = anchorButton:GetParent()
		AB:Bar_OnEnter(parentAnchorBar)
	end)

	SpellFlyout:HookScript("OnLeave", function(btn)
		local anchorButton = select(2, btn:GetPoint())
		if not AB.handledbuttons[anchorButton] then return end

		local parentAnchorBar = anchorButton:GetParent()
		AB:Bar_OnLeave(parentAnchorBar)
	end)
end

function AB:StyleFlyout(button)
	if not (LAB.buttonRegistry[button] and button.FlyoutArrow and button.FlyoutBorder) then return end

	button.FlyoutBorder:SetAlpha(0)
	button.FlyoutBorderShadow:SetAlpha(0)

	SpellFlyoutHorizontalBackground:SetAlpha(0)
	SpellFlyoutVerticalBackground:SetAlpha(0)
	SpellFlyoutBackgroundEnd:SetAlpha(0)

	for i = 1, GetNumFlyouts() do
		local _, _, numSlots, isKnown = GetFlyoutInfo(GetFlyoutID(i))
		if numSlots and isKnown and (numSlots > AB.FlyoutButtons) then
			AB.FlyoutButtons = numSlots
		end
	end

	local actionbar = button:GetParent()
	local parent = actionbar and actionbar:GetParent()
	local parentName = parent and parent:GetName()
	if parentName == "SpellBookSpellIconsFrame" then return end

	--Change arrow direction depending on what bar the button is on
	local arrowDistance = 2
	if (SpellFlyout:IsShown() and SpellFlyout:GetParent() == button) or GetMouseFocus() == button then
		arrowDistance = 5
	end

	if actionbar then
		local direction = actionbar.db and actionbar.db.flyoutDirection or "AUTOMATIC"
		local combat = InCombatLockdown()
		local point = E:GetScreenQuadrant(actionbar)
		if point == "UNKNOWN" then return end

		if (direction == "AUTOMATIC" and strfind(point, "TOP")) or direction == "DOWN" then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point("BOTTOM", button, "BOTTOM", 0, -arrowDistance)
			SetClampedTextureRotation(button.FlyoutArrow, 180)
			if not combat then button:SetAttribute("flyoutDirection", "DOWN") end
		elseif (direction == "AUTOMATIC" and point == "RIGHT") or direction == "LEFT" then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point("LEFT", button, "LEFT", -arrowDistance, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 270)
			if not combat then button:SetAttribute("flyoutDirection", "LEFT") end
		elseif (direction == "AUTOMATIC" and point == "LEFT") or direction == "RIGHT" then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point("RIGHT", button, "RIGHT", arrowDistance, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 90)
			if not combat then button:SetAttribute("flyoutDirection", "RIGHT") end
		elseif (direction == "AUTOMATIC" and (point == "CENTER" or strfind(point, "BOTTOM"))) or direction == "UP" then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point("TOP", button, "TOP", 0, arrowDistance)
			SetClampedTextureRotation(button.FlyoutArrow, 0)
			if not combat then button:SetAttribute("flyoutDirection", "UP") end
		end
	end
end

local function OnCooldownUpdate(_, button, start, duration)
	if not button._state_type == "action" then return end

	if duration and duration > 1.5 then
		button.saturationLocked = true --Lock any new actions that are created after we activated desaturation option

		button.icon:SetDesaturated(true)

		if (E.db.cooldown.enable and AB.db.cooldown.reverse) or (not E.db.cooldown.enable and not AB.db.cooldown.reverse) then
			if not button.onCooldownDoneHooked then
				AB:HookScript(button.cooldown, "OnHide", function()
					button.icon:SetDesaturated(false)
				end)

				button.onCooldownDoneHooked = true
			end
		else
			if not button.onCooldownTimerDoneHooked then
				if button.cooldown.timer then
					AB:HookScript(button.cooldown.timer, "OnHide", function()
						if (E.db.cooldown.enable and AB.db.cooldown.reverse) or (not E.db.cooldown.enable and not AB.db.cooldown.reverse) then return end

						button.icon:SetDesaturated(false)
					end)

					button.onCooldownTimerDoneHooked = true
				end
			end
		end
	end
end

function AB:ToggleDesaturation(value)
	value = value or self.db.desaturateOnCooldown

	if value then
		LAB.RegisterCallback(AB, "OnCooldownUpdate", OnCooldownUpdate)
		local start, duration
		for button in pairs(LAB.actionButtons) do
			button.saturationLocked = true
			start, duration = button:GetCooldown()
			OnCooldownUpdate(nil, button, start, duration)
		end
	else
		LAB.UnregisterCallback(AB, "OnCooldownUpdate")
		for button in pairs(LAB.actionButtons) do
			button.saturationLocked = nil
			button.icon:SetDesaturated(false)
			if (E.db.cooldown.enable and AB.db.cooldown.reverse) or (not E.db.cooldown.enable and not AB.db.cooldown.reverse) then
				if button.onCooldownDoneHooked then
					AB:Unhook(button.cooldown, "OnHide")
					button.onCooldownDoneHooked = nil
				end
			else
				if button.onCooldownTimerDoneHooked then
					if button.cooldown.timer then
						if (E.db.cooldown.enable and AB.db.cooldown.reverse) or (not E.db.cooldown.enable and not AB.db.cooldown.reverse) then return end

						AB:Unhook(button.cooldown.timer, "OnHide")

						button.onCooldownTimerDoneHooked = nil
					end
				end
			end
		end
	end
end

function AB:LAB_MouseUp()
	if self.config.clickOnDown then
		self:GetPushedTexture():SetAlpha(0)
	end
end

function AB:LAB_MouseDown()
	if self.config.clickOnDown then
		self:GetPushedTexture():SetAlpha(1)
	end
end

function AB:LAB_ButtonCreated(button)
	-- this fixes Key Down getting the pushed texture stuck
	button:HookScript("OnMouseUp", AB.LAB_MouseUp)
	button:HookScript("OnMouseDown", AB.LAB_MouseDown)
end

function AB:LAB_ButtonUpdate(button)
	local color = AB.db.fontColor
	button.count:SetTextColor(color.r, color.g, color.b)
	if button.config and (button.config.outOfRangeColoring ~= "hotkey") then
		button.hotkey:SetTextColor(color.r, color.g, color.b)
	end

	if button.backdrop then
		if AB.db.equippedItem then
			if button:IsEquipped() and AB.db.equippedItemColor then
				color = AB.db.equippedItemColor
				button.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
				button.backdrop.isColored = true
			elseif button.backdrop.isColored then
				button.backdrop.isColored = nil
				button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		elseif button.backdrop.isColored then
			button.backdrop.isColored = nil
			button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end
end

function AB:Initialize()
	self.db = E.db.actionbar
	if E.private.actionbar.enable ~= true then return end
	self.Initialized = true

	LAB.RegisterCallback(AB, "OnButtonUpdate", AB.LAB_ButtonUpdate)
	LAB.RegisterCallback(AB, "OnButtonCreated", AB.LAB_ButtonCreated)

	self.fadeParent = CreateFrame("Frame", "Elv_ABFade", UIParent)
	self.fadeParent:SetAlpha(1 - self.db.globalFadeAlpha)
	self.fadeParent:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.fadeParent:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.fadeParent:RegisterEvent("PLAYER_TARGET_CHANGED")
	self.fadeParent:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
	self.fadeParent:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
	self.fadeParent:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
	self.fadeParent:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
	self.fadeParent:RegisterUnitEvent("UNIT_HEALTH", "player")
	self.fadeParent:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self.fadeParent:SetScript("OnEvent", self.FadeParent_OnEvent)

	self:DisableBlizzard()

	self:SetupExtraButton()
	self:SetupMicroBar()
	self:UpdateBar1Paging()

	for i = 1, 10 do
		self:CreateBar(i)
	end
	self:CreateBarPet()
	self:CreateBarShapeShift()
	self:CreateVehicleLeave()

	self:UpdateButtonSettings()
	self:LoadKeyBinder()
	self:RegisterEvent("UPDATE_BINDINGS", "ReassignBindings")
	self:RegisterEvent("PET_BATTLE_CLOSE", "ReassignBindings")
	self:RegisterEvent("PET_BATTLE_OPENING_DONE", "RemoveBindings")

	if C_PetBattlesIsInBattle() then
		self:RemoveBindings()
	else
		self:ReassignBindings()
	end

	--We handle actionbar lock for regular bars, but the lock on PetBar needs to be handled by WoW so make some necessary updates
	SetCVar("lockActionBars", (self.db.lockActionBars == true and 1 or 0))
	LOCK_ACTIONBAR = (self.db.lockActionBars == true and "1" or "0") --Keep an eye on this, in case it taints

	SpellFlyout:HookScript("OnShow", AB.SetupFlyoutButton)

	self:ToggleDesaturation()
end

local function InitializeCallback()
	AB:Initialize()
end

E:RegisterModule(AB:GetName(), InitializeCallback)