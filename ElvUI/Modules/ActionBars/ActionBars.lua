local E, L, V, P, G = unpack(select(2, ...))
local AB = E:GetModule("ActionBars")

local _G = _G
local pairs, select, unpack = pairs, select, unpack
local ceil = math.ceil
local format, gsub, match, split, strfind = string.format, string.gsub, string.match, string.split, strfind

local CanExitVehicle = CanExitVehicle
local ClearOverrideBindings = ClearOverrideBindings
local CreateFrame = CreateFrame
local GetBindingKey = GetBindingKey
local GetOverrideBarIndex = GetOverrideBarIndex
local GetVehicleBarIndex = GetVehicleBarIndex
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
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

local C_PetBattles_IsInBattle = C_PetBattles.IsInBattle

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
		position = "BOTTOM,ElvUI_Bar1,TOP,0,122"
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
	texture = [[Interface\Icons\Spell_Shadow_SacrificialShield]],
	tooltip = LEAVE_VEHICLE
}

function AB:PositionAndSizeBar(barName)
	local db = AB.db[barName]

	local buttonSpacing = E:Scale(db.buttonSpacing)
	local backdropSpacing = E:Scale(db.backdropSpacing or db.buttonSpacing)
	local buttonsPerRow = db.buttonsPerRow
	local numButtons = db.buttons
	local size = E:Scale(db.buttonSize)
	local point = db.point
	local numColumns = ceil(numButtons / buttonsPerRow)
	local widthMult = db.widthMult
	local heightMult = db.heightMult
	local visibility = db.visibility
	local bar = AB.handledBars[barName]

	bar.db = db
	bar.db.position = nil --Depreciated
	bar.mouseover = db.mouseover

	if visibility and match(visibility, "[\n\r]") then
		visibility = gsub(visibility, "[\n\r]","")
	end

	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons
	end

	if numColumns < 1 then
		numColumns = 1
	end

	if db.backdrop then
		bar.backdrop:Show()
	else
		bar.backdrop:Hide()
		--Set size multipliers to 1 when backdrop is disabled
		widthMult = 1
		heightMult = 1
	end

	local sideSpacing = (db.backdrop == true and (E.Border + backdropSpacing) or E.Spacing)
	--Size of all buttons + Spacing between all buttons + Spacing between additional rows of buttons + Spacing between backdrop and buttons + Spacing on end borders with non-thin borders
	local barWidth = (size * (buttonsPerRow * widthMult)) + ((buttonSpacing * (buttonsPerRow - 1)) * widthMult) + (buttonSpacing * (widthMult - 1)) + (sideSpacing*2)
	local barHeight = (size * (numColumns * heightMult)) + ((buttonSpacing * (numColumns - 1)) * heightMult) + (buttonSpacing * (heightMult - 1)) + (sideSpacing*2)
	bar:SetSize(barWidth, barHeight)

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

	bar:SetParent(db.inheritGlobalFade and AB.fadeParent or E.UIParent)
	bar:EnableMouse(not db.clickThrough)
	bar:SetAlpha(db.mouseover and 0 or db.alpha)
	bar:SetFrameStrata(db.frameStrata or "LOW")
	bar:SetFrameLevel(db.frameLevel)

	local button, lastButton, lastColumnButton
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		button = bar.buttons[i]
		lastButton = bar.buttons[i - 1]
		lastColumnButton = bar.buttons[i-buttonsPerRow]
		button:SetParent(bar)
		button:ClearAllPoints()
		button:SetAttribute("showgrid", 1)
		button:Size(size)
		button:EnableMouse(not db.clickThrough)

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

		AB:StyleButton(button, nil, (MasqueGroup and E.private.actionbar.masque.actionbars) or nil)
	end

	if db.enabled or not bar.initialized then
		if not db.mouseover then
			bar:SetAlpha(db.alpha)
		end

		local page = AB:GetPage(barName, AB.barDefaults[barName].page, AB.barDefaults[barName].conditions)
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

	E:SetMoverSnapOffset("ElvAB_"..bar.id, db.buttonSpacing / 2)

	if MasqueGroup and E.private.actionbar.masque.actionbars then
		MasqueGroup:ReSkin()
	end
end

function AB:CreateBar(id)
	local bar = CreateFrame("Frame", "ElvUI_Bar"..id, E.UIParent, "SecureHandlerStateTemplate")
	local point, anchor, attachTo, x, y = split(",", AB.barDefaults["bar"..id].position)
	bar:Point(point, anchor, attachTo, x, y)
	bar.id = id
	bar:CreateBackdrop(AB.db.transparentBackdrops and "Transparent")

	--Use this method instead of :SetAllPoints, as the size of the mover would otherwise be incorrect
	bar.backdrop:SetPoint("TOPLEFT", bar, "TOPLEFT", E.Spacing, -E.Spacing)
	bar.backdrop:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -E.Spacing, E.Spacing)

	bar.buttons = {}
	bar.bindButtons = AB.barDefaults["bar"..id].bindButtons
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
	AB:UpdateButtonConfig(bar, bar.bindButtons)

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

	AB.handledBars["bar"..id] = bar
	E:CreateMover(bar, "ElvAB_"..id, L["Bar "]..id, nil, nil, nil,"ALL,ACTIONBARS",nil,"actionbar,playerBars,bar"..id)
	AB:PositionAndSizeBar("bar"..id)
	return bar
end

function AB:PLAYER_REGEN_ENABLED()
	if AB.NeedsUpdateButtonSettings then
		AB:UpdateButtonSettings()
		AB.NeedsUpdateButtonSettings = nil
	end
	if AB.NeedsUpdateMicroBarVisibility then
		AB:UpdateMicroBarVisibility()
		AB.NeedsUpdateMicroBarVisibility = nil
	end
	if AB.NeedsAdjustMaxStanceButtons then
		AB:AdjustMaxStanceButtons(AB.NeedsAdjustMaxStanceButtons) --sometimes it holds the event, otherwise true. pass it before we nil it.
		AB.NeedsAdjustMaxStanceButtons = nil
	end
	AB:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

function AB:CreateVehicleLeave()
	local db = E.db.actionbar.vehicleExitButton
	if not db.enable then return end

	local holder = CreateFrame("Frame", "VehicleLeaveButtonHolder", E.UIParent)
	holder:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 300)
	holder:Size(MainMenuBarVehicleLeaveButton:GetSize())
	E:CreateMover(holder, "VehicleLeaveButton", LEAVE_VEHICLE, nil, nil, nil, "ALL,ACTIONBARS", nil, "actionbar,vehicleExitButton")

	MainMenuBarVehicleLeaveButton:ClearAllPoints()
	MainMenuBarVehicleLeaveButton:SetParent(UIParent)
	MainMenuBarVehicleLeaveButton:SetPoint("CENTER", holder, "CENTER")

	MainMenuBarVehicleLeaveButton:HookScript("OnEvent", function(self) self:SetShown(CanExitVehicle()) end)
	MainMenuBarVehicleLeaveButton:RegisterEvent("PLAYER_ENTERING_WORLD")
	MainMenuBarVehicleLeaveButton:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	MainMenuBarVehicleLeaveButton:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
	MainMenuBarVehicleLeaveButton:RegisterEvent("UNIT_ENTERED_VEHICLE")
	MainMenuBarVehicleLeaveButton:RegisterEvent("UNIT_EXITED_VEHICLE")
	MainMenuBarVehicleLeaveButton:RegisterEvent("VEHICLE_UPDATE")

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
	MainMenuBarVehicleLeaveButton:SetFrameStrata(db.frameStrata)
	MainMenuBarVehicleLeaveButton:SetFrameLevel(db.frameLevel)
	VehicleLeaveButtonHolder:Size(db.size)
end

function AB:ReassignBindings(event)
	if event == "UPDATE_BINDINGS" then
		AB:UpdatePetBindings()
		AB:UpdateStanceBindings()
		AB:UpdateExtraBindings()
	end

	AB:UnregisterEvent("PLAYER_REGEN_DISABLED")

	if InCombatLockdown() then return end

	for _, bar in pairs(AB.handledBars) do
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

	for _, bar in pairs(AB.handledBars) do
		if bar then
			ClearOverrideBindings(bar)
		end
	end

	AB:RegisterEvent("PLAYER_REGEN_DISABLED", "ReassignBindings")
end

function AB:UpdateBar1Paging()
	if AB.db.bar6.enabled then
		AB.barDefaults.bar1.conditions = format("[vehicleui] %d; [possessbar] %d; [overridebar] %d; [shapeshift] 13; [form,noform] 0; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;", GetVehicleBarIndex(), GetVehicleBarIndex(), GetOverrideBarIndex())
	else
		AB.barDefaults.bar1.conditions = format("[vehicleui] %d; [possessbar] %d; [overridebar] %d; [shapeshift] 13; [form,noform] 0; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;", GetVehicleBarIndex(), GetVehicleBarIndex(), GetOverrideBarIndex())
	end
end

function AB:UpdateButtonSettingsForBar(barName)
	local bar = AB.handledBars[barName]
	AB:UpdateButtonConfig(bar, bar.bindButtons)
end

function AB:UpdateButtonSettings()
	if not E.private.actionbar.enable then return end

	if InCombatLockdown() then
		AB.NeedsUpdateButtonSettings = true
		AB:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	for button in pairs(AB.handledbuttons) do
		if button then
			AB:StyleButton(button, button.noBackdrop, button.useMasque, button.ignoreNormal)
			AB:StyleFlyout(button)
		else
			AB.handledbuttons[button] = nil
		end
	end

	-- we can safely toggle these events when we arent using the handle overlay
	if AB.db.handleOverlay then
		LAB.eventFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
		LAB.eventFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
	else
		LAB.eventFrame:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
		LAB.eventFrame:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
	end

	AB:UpdatePetBindings()
	AB:UpdateStanceBindings()
	AB:UpdateExtraBindings()
	AB:UpdateFlyoutButtons()

	for barName, bar in pairs(AB.handledBars) do
		if bar then
			AB:UpdateButtonConfig(bar, bar.bindButtons)
			AB:PositionAndSizeBar(barName)
		end
	end

	AB:AdjustMaxStanceButtons()
	AB:PositionAndSizeBarPet()
	AB:PositionAndSizeBarShapeShift()
end

function AB:GetPage(bar, defaultPage, condition)
	local page = AB.db[bar].paging[E.myclass]
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

	local db = button:GetParent().db
	local color = AB.db.fontColor
	local countPosition = AB.db.countTextPosition or "BOTTOMRIGHT"
	local countXOffset = AB.db.countTextXOffset or 0
	local countYOffset = AB.db.countTextYOffset or 2

	button.noBackdrop = noBackdrop
	button.useMasque = useMasque
	button.ignoreNormal = ignoreNormal

	if normal and not ignoreNormal then normal:SetTexture() normal:Hide() normal:SetAlpha(0) end
	if normal2 then normal2:SetTexture() normal2:Hide() normal2:SetAlpha(0) end
	if border and not button.useMasque then border:Kill() end

	if count then
		count:ClearAllPoints()

		if db and db.customCountFont then
			count:Point(db.countTextPosition, db.countTextXOffset, db.countTextYOffset)
			count:FontTemplate(LSM:Fetch("font", db.countFont), db.countFontSize, db.countFontOutline)
		else
			count:Point(countPosition, countXOffset, countYOffset)
			count:FontTemplate(LSM:Fetch("font", AB.db.font), AB.db.fontSize, AB.db.fontOutline)
		end

		local c = db and db.useCountColor and db.countColor or color
		count:SetTextColor(c.r, c.g, c.b)
	end

	if macroText then
		macroText:ClearAllPoints()
		macroText:Point("BOTTOM", 0, 1)
		macroText:FontTemplate(LSM:Fetch("font", AB.db.font), AB.db.fontSize, AB.db.fontOutline)

		local c = db and db.useMacroColor and db.macroColor or color
		macroText:SetTextColor(c.r, c.g, c.b)
	end

	if not button.noBackdrop and not button.backdrop and not button.useMasque then
		button:CreateBackdrop(AB.db.transparentButtons and "Transparent", true)
		button.backdrop:SetAllPoints()
	end

	if flash then
		if AB.db.flashAnimation then
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

	if AB.db.hotkeytext then
		if db and db.customHotkeyFont then
			hotkey:FontTemplate(LSM:Fetch("font", db.hotkeyFont), db.hotkeyFontSize, db.hotkeyFontOutline)
		else
			hotkey:FontTemplate(LSM:Fetch("font", AB.db.font), AB.db.fontSize, AB.db.fontOutline)
		end

		AB:UpdateHotkeyColor(button)
	end

	--Extra Action Button
	if button.style then
		button.style:SetDrawLayer("BACKGROUND", -7)
	end

	button.FlyoutUpdateFunc = AB.StyleFlyout
	AB:FixKeybindText(button)

	if not button.useMasque then
		button:StyleButton()
	else
		button:StyleButton(true, true, true)
	end

	if not AB.handledbuttons[button] then
		button.cooldown.CooldownOverride = "actionbar"

		E:RegisterCooldown(button.cooldown)

		AB.handledbuttons[button] = true
	end
end

function AB:UpdateHotkeyColor(button)
	if button.config and not button.outOfRange then
		local db = button:GetParent().db
		local c = db and db.useHotkeyColor and db.hotkeyColor or AB.db.fontColor
		button.hotkey:SetTextColor(c.r, c.g, c.b)
	end
end

function AB:Bar_OnEnter(bar)
	if bar:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
	end

	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
	end
end

function AB:Bar_OnLeave(bar)
	if bar:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		E:UIFrameFadeOut(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1 - AB.db.globalFadeAlpha)
	end

	if bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
	end
end

function AB:Button_OnEnter(button)
	local bar = button:GetParent()
	if bar:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
	end

	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
	end
end

function AB:Button_OnLeave(button)
	local bar = button:GetParent()
	if bar:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		E:UIFrameFadeOut(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1 - AB.db.globalFadeAlpha)
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
	if (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_HEALTH") and unit ~= "player" then return end

	if (UnitCastingInfo("player") or UnitChannelInfo("player")) or (UnitHealth("player") ~= UnitHealthMax("player")) or (UnitExists("target") or UnitExists("focus")) or UnitAffectingCombat("player") then
		self.mouseLock = true
		E:UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	else
		self.mouseLock = false
		E:UIFrameFadeOut(self, 0.2, self:GetAlpha(), 1 - AB.db.globalFadeAlpha)
	end
end

function AB:IconIntroTracker_Toggle()
	if AB.db.addNewSpells then
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
	AB:IconIntroTracker_Toggle()

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

	AB:SecureHook("BlizzardOptionsPanel_OnEvent")

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end
end

function AB:UpdateButtonConfig(bar, buttonName)
	if InCombatLockdown() then
		AB.NeedsUpdateButtonSettings = true
		AB:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	local barDB = AB.db["bar"..bar.id]
	if not bar.buttonConfig then bar.buttonConfig = {hideElements = {}, colors = {}} end
	bar.buttonConfig.hideElements.macro = not AB.db.macrotext or barDB.hideMacroText
	bar.buttonConfig.hideElements.hotkey = not AB.db.hotkeytext or barDB.hideHotkey
	bar.buttonConfig.showGrid = barDB.showGrid
	bar.buttonConfig.clickOnDown = AB.db.keyDown
	bar.buttonConfig.outOfRangeColoring = (AB.db.useRangeColorText and "hotkey") or "button"
	bar.buttonConfig.colors.range = E:SetColorTable(bar.buttonConfig.colors.range, AB.db.noRangeColor)
	bar.buttonConfig.colors.mana = E:SetColorTable(bar.buttonConfig.colors.mana, AB.db.noPowerColor)
	bar.buttonConfig.colors.usable = E:SetColorTable(bar.buttonConfig.colors.usable, AB.db.usableColor)
	bar.buttonConfig.colors.notUsable = E:SetColorTable(bar.buttonConfig.colors.notUsable, AB.db.notUsableColor)
	bar.buttonConfig.handleOverlay = AB.db.handleOverlay
	SetModifiedClick("PICKUPACTION", AB.db.movementModifier)

	for i, button in pairs(bar.buttons) do
		bar.buttonConfig.keyBoundTarget = format(buttonName.."%d", i)
		button.keyBoundTarget = bar.buttonConfig.keyBoundTarget
		button.postKeybind = AB.FixKeybindText
		button:SetAttribute("buttonlock", AB.db.lockActionBars)
		button:SetAttribute("checkselfcast", true)
		button:SetAttribute("checkfocuscast", true)
		button:SetAttribute("unit2", AB.db.rightClickSelfCast and "player" or "target")

		button:UpdateConfig(bar.buttonConfig)
	end
end

function AB:FixKeybindText(button)
	local hotkey = _G[button:GetName().."HotKey"]
	local text = hotkey:GetText()

	local db = button:GetParent().db
	local hotkeyPosition = db and db.customHotkeyFont and db.hotkeyTextPosition or E.db.actionbar.hotkeyTextPosition or "TOPRIGHT"
	local hotkeyXOffset = db and db.customHotkeyFont and db.hotkeyTextXOffset or E.db.actionbar.hotkeyTextXOffset or 0
	local hotkeyYOffset = db and db.customHotkeyFont and db.hotkeyTextYOffset or E.db.actionbar.hotkeyTextYOffset or -3

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

local function flyoutButtonAnchor(frame)
	local parent = frame:GetParent()
	local _, parentAnchorButton = parent:GetPoint()
	if not AB.handledbuttons[parentAnchorButton] then return end

	return parentAnchorButton:GetParent()
end

function AB:FlyoutButton_OnEnter()
	local anchor = flyoutButtonAnchor(self)
	if anchor then AB:Bar_OnEnter(anchor) end
end

function AB:FlyoutButton_OnLeave()
	local anchor = flyoutButtonAnchor(self)
	if anchor then AB:Bar_OnLeave(anchor) end
end

local function spellFlyoutAnchor(frame)
	local _, anchorButton = frame:GetPoint()
	if not AB.handledbuttons[anchorButton] then return end

	return anchorButton:GetParent()
end

function AB:SpellFlyout_OnEnter()
	local anchor = spellFlyoutAnchor(self)
	if anchor then AB:Bar_OnEnter(anchor) end
end

function AB:SpellFlyout_OnLeave()
	local anchor = spellFlyoutAnchor(self)
	if anchor then AB:Bar_OnLeave(anchor) end
end

function AB:UpdateFlyoutButtons()
	local btn, i = _G["SpellFlyoutButton1"], 1
	while btn do
		AB:SetupFlyoutButton(btn)

		i = i + 1
		btn = _G["SpellFlyoutButton"..i]
	end
end

function AB:SetupFlyoutButton(button)
	if not AB.handledbuttons[button] then
		AB:StyleButton(button, nil, (MasqueGroup and E.private.actionbar.masque.actionbars) or nil)
		button:HookScript("OnEnter", AB.FlyoutButton_OnEnter)
		button:HookScript("OnLeave", AB.FlyoutButton_OnLeave)
	end

	if not InCombatLockdown() then
		button:Size(AB.db.flyoutSize)
	end

	if MasqueGroup and E.private.actionbar.masque.actionbars then
		MasqueGroup:RemoveButton(button) --Remove first to fix issue with backdrops appearing at the wrong flyout menu
		MasqueGroup:AddButton(button)
	end
end

function AB:StyleFlyout(button)
	if not (button.FlyoutBorder and button.FlyoutArrow and button.FlyoutArrow:IsShown() and LAB.buttonRegistry[button]) then return end

	button.FlyoutBorder:SetAlpha(0)
	button.FlyoutBorderShadow:SetAlpha(0)

	SpellFlyoutHorizontalBackground:SetAlpha(0)
	SpellFlyoutVerticalBackground:SetAlpha(0)
	SpellFlyoutBackgroundEnd:SetAlpha(0)

	local actionbar = button:GetParent()
	local parent = actionbar and actionbar:GetParent()
	local parentName = parent and parent:GetName()

	if parentName == "SpellBookSpellIconsFrame" then
		return
	elseif actionbar then
		-- Change arrow direction depending on what bar the button is on
		local arrowDistance = 2
		if SpellFlyout:IsShown() and SpellFlyout:GetParent() == button then
			arrowDistance = 5
		end

		local direction = (actionbar.db and actionbar.db.flyoutDirection) or "AUTOMATIC"
		local point = direction == "AUTOMATIC" and E:GetScreenQuadrant(actionbar)
		if point == "UNKNOWN" then return end

		local noCombat = not InCombatLockdown()
		if direction == "DOWN" or (point and strfind(point, "TOP")) then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point("BOTTOM", button, "BOTTOM", 0, -arrowDistance)
			SetClampedTextureRotation(button.FlyoutArrow, 180)
			if noCombat then button:SetAttribute("flyoutDirection", "DOWN") end
		elseif direction == "LEFT" or point == "RIGHT" then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point("LEFT", button, "LEFT", -arrowDistance, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 270)
			if noCombat then button:SetAttribute("flyoutDirection", "LEFT") end
		elseif direction == "RIGHT" or point == "LEFT" then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point("RIGHT", button, "RIGHT", arrowDistance, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 90)
			if noCombat then button:SetAttribute("flyoutDirection", "RIGHT") end
		elseif direction == "UP" or point == "CENTER" or (point and strfind(point, "BOTTOM")) then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point("TOP", button, "TOP", 0, arrowDistance)
			SetClampedTextureRotation(button.FlyoutArrow, 0)
			if noCombat then button:SetAttribute("flyoutDirection", "UP") end
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
	value = value or AB.db.desaturateOnCooldown

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
	local db = button.db
	local color = db and db.useCountColor and db.countColor or AB.db.fontColor

	button.count:SetTextColor(color.r, color.g, color.b)

	if button.backdrop then
		if AB.db.equippedItem then
			if button:IsEquipped() and AB.db.equippedItemColor then
				local border = AB.db.equippedItemColor
				button.backdrop:SetBackdropBorderColor(border.r, border.g, border.b)
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

function AB:LAB_UpdateRange(button)
	AB:UpdateHotkeyColor(button)
end

function AB:Initialize()
	AB.db = E.db.actionbar

	if not E.private.actionbar.enable then return end
	AB.Initialized = true

	LAB.RegisterCallback(AB, "OnButtonUpdate", AB.LAB_ButtonUpdate)
	LAB.RegisterCallback(AB, "OnUpdateRange", AB.LAB_UpdateRange)
	LAB.RegisterCallback(AB, "OnButtonCreated", AB.LAB_ButtonCreated)

	AB.fadeParent = CreateFrame("Frame", "Elv_ABFade", UIParent)
	AB.fadeParent:SetAlpha(1 - AB.db.globalFadeAlpha)
	AB.fadeParent:RegisterEvent("PLAYER_REGEN_DISABLED")
	AB.fadeParent:RegisterEvent("PLAYER_REGEN_ENABLED")
	AB.fadeParent:RegisterEvent("PLAYER_TARGET_CHANGED")
	AB.fadeParent:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
	AB.fadeParent:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
	AB.fadeParent:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
	AB.fadeParent:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
	AB.fadeParent:RegisterUnitEvent("UNIT_HEALTH", "player")
	AB.fadeParent:RegisterEvent("PLAYER_FOCUS_CHANGED")
	AB.fadeParent:SetScript("OnEvent", AB.FadeParent_OnEvent)

	AB:DisableBlizzard()
	AB:SetupExtraButton()
	AB:SetupMicroBar()
	AB:UpdateBar1Paging()

	for i = 1, 10 do
		AB:CreateBar(i)
	end

	AB:CreateBarPet()
	AB:CreateBarShapeShift()
	AB:CreateVehicleLeave()
	AB:UpdateButtonSettings()
	AB:LoadKeyBinder()

	AB:RegisterEvent("UPDATE_BINDINGS", "ReassignBindings")
	AB:RegisterEvent("PET_BATTLE_CLOSE", "ReassignBindings")
	AB:RegisterEvent("PET_BATTLE_OPENING_DONE", "RemoveBindings")

	if C_PetBattles_IsInBattle() then
		AB:RemoveBindings()
	else
		AB:ReassignBindings()
	end

	-- We handle actionbar lock for regular bars, but the lock on PetBar needs to be handled by WoW so make some necessary updates
	SetCVar("lockActionBars", (AB.db.lockActionBars == true and 1 or 0))
	LOCK_ACTIONBAR = (AB.db.lockActionBars == true and "1" or "0") -- Keep an eye on this, in case it taints

	hooksecurefunc(SpellFlyout, "Show", AB.UpdateFlyoutButtons)
	SpellFlyout:HookScript("OnEnter", AB.SpellFlyout_OnEnter)
	SpellFlyout:HookScript("OnLeave", AB.SpellFlyout_OnLeave)

	AB:ToggleDesaturation()
end

local function InitializeCallback()
	AB:Initialize()
end

E:RegisterModule(AB:GetName(), InitializeCallback)