local E, L, V, P, G = unpack(select(2, ...))
local AB = E:GetModule("ActionBars")

local _G = _G

local CreateFrame = CreateFrame
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

local function Button_OnEnter()
	if AB.db.microbar.mouseover then
		E:UIFrameFadeIn(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), AB.db.microbar.alpha)
	end
end

local function Button_OnLeave()
	if AB.db.microbar.mouseover then
		E:UIFrameFadeOut(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), 0)
	end
end

function AB:HandleMicroButton(button)
	local pushed = button:GetPushedTexture()
	local normal = button:GetNormalTexture()
	local disabled = button:GetDisabledTexture()

	button:SetParent(ElvUI_MicroBar)

	button.Flash:SetTexture(nil)
	button:GetHighlightTexture():Kill()
	button:HookScript("OnEnter", Button_OnEnter)
	button:HookScript("OnLeave", Button_OnLeave)

	local f = CreateFrame("Frame", nil, button)
	f:SetFrameLevel(1)
	f:SetFrameStrata("BACKGROUND")
	f:Point("BOTTOMLEFT", button, "BOTTOMLEFT", 2, 0)
	f:Point("TOPRIGHT", button, "TOPRIGHT", -2, -28)
	f:SetTemplate("Default", true)
	button.backdrop = f

	pushed:SetTexCoord(0.17, 0.87, 0.5, 0.908)
	pushed:SetInside(f)

	normal:SetTexCoord(0.17, 0.87, 0.5, 0.908)
	normal:SetInside(f)

	if disabled then
		disabled:SetTexCoord(0.17, 0.87, 0.5, 0.908)
		disabled:SetInside(f)
	end
end

function AB:MainMenuMicroButton_SetNormal()
	MainMenuBarPerformanceBar:Point("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 9, -36)
end

function AB:MainMenuMicroButton_SetPushed()
	MainMenuBarPerformanceBar:Point("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 8, -37)
end

function AB:UpdateMicroButtonsParent(parent)
	if CharacterMicroButton:GetParent() == ElvUI_MicroBar then return end

	for i = 1, #MICRO_BUTTONS do
		_G[MICRO_BUTTONS[i]]:SetParent(ElvUI_MicroBar)
	end

	AB:UpdateMicroPositionDimensions()
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
	for i = 1, #MICRO_BUTTONS do
		local button = _G[MICRO_BUTTONS[i]]
		local prevButton = _G[MICRO_BUTTONS[i-1]] or ElvUI_MicroBar
		local lastColumnButton = _G[MICRO_BUTTONS[i-self.db.microbar.buttonsPerRow]]

		button:ClearAllPoints()

		if prevButton == ElvUI_MicroBar then
			button:Point("TOPLEFT", prevButton, "TOPLEFT", -2 + E.Border, 28 - E.Border)
		elseif (i - 1) % self.db.microbar.buttonsPerRow == 0 then
			button:Point("TOP", lastColumnButton, "BOTTOM", 0, 28 - self.db.microbar.yOffset)
			numRows = numRows + 1
		else
			button:Point("LEFT", prevButton, "RIGHT", - 4 + self.db.microbar.xOffset, 0)
		end
	end

	if AB.db.microbar.mouseover then
		ElvUI_MicroBar:SetAlpha(0)
	else
		ElvUI_MicroBar:SetAlpha(self.db.microbar.alpha)
	end

	AB.MicroWidth = ((_G["CharacterMicroButton"]:GetWidth() - 4) * self.db.microbar.buttonsPerRow) + (self.db.microbar.xOffset * (self.db.microbar.buttonsPerRow - 1)) + E.Border * 2
	AB.MicroHeight = ((_G["CharacterMicroButton"]:GetHeight() - 28) * numRows) + (self.db.microbar.yOffset * (numRows - 1)) + E.Border * 2
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
	GuildMicroButtonTabard:ClearAllPoints()
	GuildMicroButtonTabard:Point("TOP", GuildMicroButton.backdrop, "TOP", 0, 25)
	self:UpdateMicroPositionDimensions()
end

function AB:SetupMicroBar()
	local microBar = CreateFrame("Frame", "ElvUI_MicroBar", E.UIParent)
	microBar:Point("TOPLEFT", E.UIParent, "TOPLEFT", 4, -48)

	microBar.visibility = CreateFrame("Frame", nil, E.UIParent, "SecureHandlerStateTemplate")
	microBar.visibility:SetScript("OnShow", function() microBar:Show() end)
	microBar.visibility:SetScript("OnHide", function() microBar:Hide() end)

	E.FrameLocks["ElvUI_MicroBar"] = true

	for i = 1, #MICRO_BUTTONS do
		self:HandleMicroButton(_G[MICRO_BUTTONS[i]])
	end

	MicroButtonPortrait:SetInside(CharacterMicroButton.backdrop)

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateMicroButtonsParent")

	self:SecureHook("MainMenuMicroButton_SetPushed")
	self:SecureHook("MainMenuMicroButton_SetNormal")
	self:SecureHook("UpdateMicroButtonsParent")
	self:SecureHook("MoveMicroButtons", "UpdateMicroPositionDimensions")
	self:SecureHook("UpdateMicroButtons")

	UpdateMicroButtonsParent(microBar)
	self:MainMenuMicroButton_SetNormal()
	self:UpdateMicroPositionDimensions()
	MainMenuBarPerformanceBar:Kill()

	E:CreateMover(microBar, "MicrobarMover", L["Micro Bar"], nil, nil, nil, "ALL, ACTIONBARS")
end