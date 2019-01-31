local E, L, V, P, G = unpack(select(2, ...))
local AB = E:GetModule("ActionBars")

local _G = _G

local CreateFrame = CreateFrame
local UnitLevel = UnitLevel
local UpdateMicroButtonsParent = UpdateMicroButtonsParent
local RegisterStateDriver = RegisterStateDriver
local InCombatLockdown = InCombatLockdown

local MICRO_BUTTONS = {
	"CharacterMicroButton",
	"SpellbookMicroButton",
	"TalentMicroButton",
	"AchievementMicroButton",
	"QuestLogMicroButton",
	"GuildMicroButton",
	"PVPMicroButton",
	"LFDMicroButton",
	"EJMicroButton",
	"CompanionsMicroButton",
	"StoreMicroButton",
	"MainMenuMicroButton"
}

local function onEnterBar()
	if AB.db.microbar.mouseover then
		E:UIFrameFadeIn(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), AB.db.microbar.alpha)
	end
end

local function onLeaveBar()
	if AB.db.microbar.mouseover then
		E:UIFrameFadeOut(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), 0)
	end
end

local function onEnterButton(button)
	if AB.db.microbar.mouseover then
		E:UIFrameFadeIn(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), AB.db.microbar.alpha)
	end

	if button.backdrop then
		button.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	end
end

local function onLeaveButton(button)
	if AB.db.microbar.mouseover then
		E:UIFrameFadeOut(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), 0)
	end

	if button.backdrop then
		button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

function AB:HandleMicroButton(button)
	assert(button, "Invalid micro button name.")

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
	button:HookScript("OnEnter", onEnterButton)
	button:HookScript("OnLeave", onLeaveButton)
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
	for i = 1, #MICRO_BUTTONS do
		_G[MICRO_BUTTONS[i]]:SetParent(ElvUI_MicroBar)
	end
end

function AB:UpdateMicroBarVisibility()
	if InCombatLockdown() then
		AB.NeedsUpdateMicroBarVisibility = true
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	local visibility = self.db.microbar.visibility
	if visibility and visibility:match("[\n\r]") then
		visibility = visibility:gsub("[\n\r]","")
	end

	RegisterStateDriver(ElvUI_MicroBar.visibility, "visibility", (self.db.microbar.enabled and visibility) or "hide")
end

function AB:UpdateMicroPositionDimensions()
	if not ElvUI_MicroBar then return end

	local numRows = 1
	local prevButton = ElvUI_MicroBar
	local offset = E:Scale(E.PixelMode and 1 or 3)
	local spacing = E:Scale(offset + self.db.microbar.buttonSpacing)

	for i = 1, #MICRO_BUTTONS do
		local button = _G[MICRO_BUTTONS[i]]
		local lastColumnButton = i - self.db.microbar.buttonsPerRow
		lastColumnButton = _G[MICRO_BUTTONS[lastColumnButton]]

		button:Size(self.db.microbar.buttonSize, self.db.microbar.buttonSize * 1.4)
		button:ClearAllPoints()

		if prevButton == ElvUI_MicroBar then
			button:Point("TOPLEFT", prevButton, "TOPLEFT", offset, -offset)
		elseif (i - 1) % self.db.microbar.buttonsPerRow == 0 then
			button:Point("TOP", lastColumnButton, "BOTTOM", 0, -spacing)
			numRows = numRows + 1
		else
			button:Point("LEFT", prevButton, "RIGHT", spacing, 0)
		end

		prevButton = button
	end

	if AB.db.microbar.mouseover and not ElvUI_MicroBar:IsMouseOver() then
		ElvUI_MicroBar:SetAlpha(0)
	else
		ElvUI_MicroBar:SetAlpha(self.db.microbar.alpha)
	end

	AB.MicroWidth = (((_G["CharacterMicroButton"]:GetWidth() + spacing) * self.db.microbar.buttonsPerRow) - spacing) + (offset * 2)
	AB.MicroHeight = (((_G["CharacterMicroButton"]:GetHeight() + spacing) * numRows) - spacing) + (offset * 2)
 	ElvUI_MicroBar:Size(AB.MicroWidth, AB.MicroHeight)

	if ElvUI_MicroBar.mover then
		if self.db.microbar.enabled then
			E:EnableMover(ElvUI_MicroBar.mover:GetName())
		else
			E:DisableMover(ElvUI_MicroBar.mover:GetName())
		end
	end

	self:UpdateMicroBarVisibility()
end

function AB:UpdateMicroButtons()
	-- Guild Button
	GuildMicroButtonTabard:SetInside(GuildMicroButton)

	GuildMicroButtonTabard.background:SetInside(GuildMicroButton)
	GuildMicroButtonTabard.background:SetTexCoord(0.17, 0.87, 0.5, 0.908)

	GuildMicroButtonTabard.emblem:ClearAllPoints()
	GuildMicroButtonTabard.emblem:Point("TOPLEFT", GuildMicroButton, "TOPLEFT", 4, -4)
	GuildMicroButtonTabard.emblem:Point("BOTTOMRIGHT", GuildMicroButton, "BOTTOMRIGHT", -4, 8)

	-- PvP Micro Button
	PVPMicroButtonTexture:Point("TOPLEFT", PVPMicroButton, "TOPLEFT", -3, 3)
	PVPMicroButtonTexture:Point("BOTTOMRIGHT", PVPMicroButton, "BOTTOMRIGHT", 2, -3)
	PVPMicroButtonTexture:SetTexture("Interface\\PVPFrame\\PVP-Conquest-Misc")

	if UnitLevel("player") < PVPMicroButton.minLevel then
		PVPMicroButtonTexture:SetDesaturated(true)
	else
		PVPMicroButtonTexture:SetDesaturated(false)
	end

	self:UpdateMicroPositionDimensions()
end

function AB:SetupMicroBar()
	local microBar = CreateFrame("Frame", "ElvUI_MicroBar", E.UIParent)
	microBar:Point("TOPLEFT", E.UIParent, "TOPLEFT", 4, -48)
	microBar:EnableMouse(false)
	microBar:SetScript("OnEnter", onEnterBar)
	microBar:SetScript("OnLeave", onLeaveBar)

	microBar.visibility = CreateFrame("Frame", nil, E.UIParent, "SecureHandlerStateTemplate")
	microBar.visibility:SetScript("OnShow", function() microBar:Show() end)
	microBar.visibility:SetScript("OnHide", function() microBar:Hide() end)

	E.FrameLocks.ElvUI_MicroBar = true

	for i = 1, #MICRO_BUTTONS do
		self:HandleMicroButton(_G[MICRO_BUTTONS[i]])
	end

	MicroButtonPortrait:SetInside(CharacterMicroButton.backdrop)

	if E.myfaction == "Alliance"  then
		PVPMicroButtonTexture:SetTexCoord(0.694, 0.748, 0.603, 0.728)
	else
		PVPMicroButtonTexture:SetTexCoord(0.638, 0.692, 0.603, 0.732)
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateMicroButtonsParent")

	--self:SecureHook("VehicleMenuBar_MoveMicroButtons", "UpdateMicroButtonsParent")
	self:SecureHook("UpdateMicroButtonsParent")
	self:SecureHook("MoveMicroButtons", "UpdateMicroPositionDimensions")
	self:SecureHook("UpdateMicroButtons")

	UpdateMicroButtonsParent(microBar)
	self:UpdateMicroPositionDimensions()
	MainMenuBarPerformanceBar:Kill()

	E:CreateMover(microBar, "MicrobarMover", L["Micro Bar"], nil, nil, nil, "ALL, ACTIONBARS", nil, "actionbar,microbar")
end