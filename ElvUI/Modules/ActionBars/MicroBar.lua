local E, L, V, P, G = unpack(select(2, ...))
local AB = E:GetModule("ActionBars")

local _G = _G

local CreateFrame = CreateFrame
local UpdateMicroButtonsParent = UpdateMicroButtonsParent
local RegisterStateDriver = RegisterStateDriver
local InCombatLockdown = InCombatLockdown
local C_StorePublic_IsEnabled = C_StorePublic.IsEnabled

local MICRO_BUTTONS = MICRO_BUTTONS

local __buttonIndex = {
	[9] = "CompanionsMicroButton",
	[10] = "EJMicroButton",
	[11] = not C_StorePublic_IsEnabled() and "HelpMicroButton" or "StoreMicroButton",
	[12] = "MainMenuMicroButton"
}

local function onEnter(button)
	if AB.db.microbar.mouseover then
		E:UIFrameFadeIn(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), AB.db.microbar.alpha)
	end

	if button and button ~= ElvUI_MicroBar and button.backdrop then
		button.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	end
end

local function onLeave(button)
	if AB.db.microbar.mouseover then
		E:UIFrameFadeOut(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), 0)
	end

	if button and button ~= ElvUI_MicroBar and button.backdrop then
		button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

function AB:HandleMicroButton(button)
	local pushed = button:GetPushedTexture()
	local normal = button:GetNormalTexture()
	local disabled = button:GetDisabledTexture()

	local f = CreateFrame("Frame", nil, button)
	f:SetFrameLevel(button:GetFrameLevel() - 1)
	f:SetTemplate("Default", true)
	f:SetOutside(button)
	button.backdrop = f

	button:SetParent(ElvUI_MicroBar)
	button:GetHighlightTexture():Kill()
	button:HookScript("OnEnter", onEnter)
	button:HookScript("OnLeave", onLeave)
	button:SetHitRectInsets(0, 0, 0, 0)

	if button.Flash then
		button.Flash:SetInside()
		button.Flash:SetTexture(nil)
	end

	pushed:SetTexCoord(0.17, 0.87, 0.5, 0.908)
	pushed:SetInside(f)

	normal:SetTexCoord(0.17, 0.87, 0.5, 0.908)
	normal:SetInside(f)

	if disabled then
		disabled:SetTexCoord(0.17, 0.87, 0.5, 0.908)
		disabled:SetInside(f)
	end
end

function AB:UpdateMicroButtonsParent()
	if CharacterMicroButton:GetParent() == ElvUI_MicroBar then return end

	for i = 1, #MICRO_BUTTONS do
		_G[MICRO_BUTTONS[i]]:SetParent(ElvUI_MicroBar)
	end

	AB:UpdateMicroPositionDimensions()
end

function AB:UpdateMicroBarVisibility()
	if InCombatLockdown() then
		AB.NeedsUpdateMicroBarVisibility = true
		AB:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	local visibility = AB.db.microbar.visibility
	if visibility and visibility:match("[\n\r]") then
		visibility = visibility:gsub("[\n\r]","")
	end

	RegisterStateDriver(ElvUI_MicroBar.visibility, "visibility", (AB.db.microbar.enabled and visibility) or "hide")
end

function AB:UpdateMicroPositionDimensions()
	if not ElvUI_MicroBar then return end

	local numRows = 1
	local prevButton = ElvUI_MicroBar
	local offset = E:Scale(E.PixelMode and 1 or 3)
	local buttonSpacing = E:Scale(offset + AB.db.microbar.buttonSpacing)
	local buttonsPerRow = AB.db.microbar.buttonsPerRow
	local showBackdrop = AB.db.microbar.backdrop
	local backdropSpacing = showBackdrop and AB.db.microbar.backdropSpacing + E.Border or 0

	for i = 1, #MICRO_BUTTONS - 1 do
		local button = _G[__buttonIndex[i]] or _G[MICRO_BUTTONS[i]]
		local lastColumnButton = i - buttonsPerRow
		lastColumnButton = _G[__buttonIndex[lastColumnButton]] or _G[MICRO_BUTTONS[lastColumnButton]]

		button:Size(AB.db.microbar.buttonSize, AB.db.microbar.buttonSize * 1.4)
		button:ClearAllPoints()

		if prevButton == ElvUI_MicroBar then
			button:Point("TOPLEFT", prevButton, "TOPLEFT", offset + backdropSpacing, -offset - backdropSpacing)
		elseif (i - 1) % buttonsPerRow == 0 then
			button:Point("TOP", lastColumnButton, "BOTTOM", 0, -buttonSpacing)
			numRows = numRows + 1
		else
			button:Point("LEFT", prevButton, "RIGHT", buttonSpacing, 0)
		end

		prevButton = button
	end

	ElvUI_MicroBar:SetAlpha((AB.db.microbar.mouseover and not ElvUI_MicroBar:IsMouseOver() and 0) or AB.db.microbar.alpha)

	ElvUI_MicroBar.backdrop:SetTemplate(AB.db.microbar.transparentBackdrop and "Transparent" or "Default")
	ElvUI_MicroBar.backdrop:SetShown(showBackdrop)

	local width = (((_G["CharacterMicroButton"]:GetWidth() + buttonSpacing) * buttonsPerRow) - buttonSpacing) + (offset * 2) + (backdropSpacing * 2)
	local height = (((_G["CharacterMicroButton"]:GetHeight() + buttonSpacing) * numRows) - buttonSpacing) + (offset * 2) + (backdropSpacing * 2)
	ElvUI_MicroBar:Size(width, height)

	if ElvUI_MicroBar.mover then
		local microMoverName = ElvUI_MicroBar.mover:GetName()
		if AB.db.microbar.enabled then
			E:EnableMover(microMoverName)
		else
			E:DisableMover(microMoverName)
		end
	end

	AB:UpdateMicroBarVisibility()
end

function AB:UpdateMicroButtons()
	-- Guild Button
	GuildMicroButtonTabard:SetInside(GuildMicroButton)

	GuildMicroButtonTabard.background:SetInside(GuildMicroButton)
	GuildMicroButtonTabard.background:SetTexCoord(0.17, 0.87, 0.5, 0.908)

	GuildMicroButtonTabard.emblem:ClearAllPoints()
	GuildMicroButtonTabard.emblem:Point("TOPLEFT", GuildMicroButton, 4, -4)
	GuildMicroButtonTabard.emblem:Point("BOTTOMRIGHT", GuildMicroButton, -4, 8)

	-- PvP Micro Button
	local desaturate = (E.mylevel < PVPMicroButton.minLevel and true) or false
	PVPMicroButtonTexture:SetDesaturated(desaturate)

	AB:UpdateMicroPositionDimensions()
end

function AB:SetupMicroBar()
	local microBar = CreateFrame("Frame", "ElvUI_MicroBar", E.UIParent)
	microBar:CreateBackdrop()
	microBar.backdrop:SetAllPoints()
	microBar:Point("TOPLEFT", E.UIParent, "TOPLEFT", 4, -48)
	microBar:EnableMouse(false)
	microBar:SetScript("OnEnter", onEnter)
	microBar:SetScript("OnLeave", onLeave)

	microBar.visibility = CreateFrame("Frame", nil, E.UIParent, "SecureHandlerStateTemplate")
	microBar.visibility:SetScript("OnShow", function() microBar:Show() end)
	microBar.visibility:SetScript("OnHide", function() microBar:Hide() end)

	for i = 1, #MICRO_BUTTONS do
		AB:HandleMicroButton(_G[MICRO_BUTTONS[i]])
	end

	MicroButtonPortrait:SetInside(CharacterMicroButton.backdrop)

	PVPMicroButtonTexture:Point("TOPLEFT", PVPMicroButton, -3, 3)
	PVPMicroButtonTexture:Point("BOTTOMRIGHT", PVPMicroButton, 2, -3)
	PVPMicroButtonTexture:SetTexture([[Interface\PVPFrame\PVP-Conquest-Misc]])

	if E.myfaction == "Alliance" then
		PVPMicroButtonTexture:SetTexCoord(0.694, 0.748, 0.603, 0.728)
	else
		PVPMicroButtonTexture:SetTexCoord(0.638, 0.692, 0.603, 0.732)
	end

	AB:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateMicroButtonsParent")

	AB:SecureHook("UpdateMicroButtonsParent")
	AB:SecureHook("MoveMicroButtons", "UpdateMicroPositionDimensions")
	AB:SecureHook("UpdateMicroButtons")

	UpdateMicroButtonsParent(microBar)
	AB:UpdateMicroPositionDimensions()
	MainMenuBarPerformanceBar:Kill()

	E:CreateMover(microBar, "MicrobarMover", L["Micro Bar"], nil, nil, nil, "ALL,ACTIONBARS", nil, "actionbar,microbar")
end