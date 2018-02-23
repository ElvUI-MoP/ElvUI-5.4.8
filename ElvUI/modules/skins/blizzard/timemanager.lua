local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.timemanager ~= true then return end

	local TimeManagerFrame = _G["TimeManagerFrame"]
	TimeManagerFrame:Size(190, 240)
	TimeManagerFrame:StripTextures()
	TimeManagerFrame:SetTemplate("Transparent")

	TimeManagerFrameInset:Kill()

	S:HandleCloseButton(TimeManagerFrameCloseButton)

	E:CreateMover(TimeManagerFrame, "TimeManagerFrameMover", TIMEMANAGER_TITLE)
	TimeManagerFrame.mover:SetFrameLevel(TimeManagerFrame:GetFrameLevel() + 4)

	select(7, TimeManagerFrame:GetRegions()):Point("TOP", 0, -5)

	TimeManagerStopwatchFrame:Point("TOPRIGHT", 10, -12)

	TimeManagerStopwatchCheck:SetTemplate("Default")
	TimeManagerStopwatchCheck:StyleButton(nil, true)

	TimeManagerStopwatchCheck:GetNormalTexture():SetInside()
	TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))

	TimeManagerAlarmTimeFrame:Point("TOPLEFT", 12, -65)

	S:HandleDropDownBox(TimeManagerAlarmHourDropDown, 80)
	S:HandleDropDownBox(TimeManagerAlarmMinuteDropDown, 80)
	S:HandleDropDownBox(TimeManagerAlarmAMPMDropDown, 80)

	S:HandleEditBox(TimeManagerAlarmMessageEditBox)

	TimeManagerAlarmEnabledButton:Point("LEFT", 16, -45)
	TimeManagerAlarmEnabledButton:SetNormalTexture(nil)
	TimeManagerAlarmEnabledButton.SetNormalTexture = E.noop
	TimeManagerAlarmEnabledButton:SetPushedTexture(nil)
	TimeManagerAlarmEnabledButton.SetPushedTexture = E.noop
	S:HandleButton(TimeManagerAlarmEnabledButton)

	TimeManagerMilitaryTimeCheck:Point("TOPLEFT", 155, -190)
	S:HandleCheckBox(TimeManagerMilitaryTimeCheck)
	S:HandleCheckBox(TimeManagerLocalTimeCheck)

	StopwatchFrame:CreateBackdrop("Transparent")
	StopwatchFrame.backdrop:Point("TOPLEFT", 0, -16)
	StopwatchFrame.backdrop:Point("BOTTOMRIGHT", 0, 2)

	StopwatchFrame:StripTextures()

	StopwatchTabFrame:StripTextures()

	S:HandleCloseButton(StopwatchCloseButton)

	StopwatchPlayPauseButton:CreateBackdrop("Default", true)
	StopwatchPlayPauseButton:Size(12)
	StopwatchPlayPauseButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\play")
	StopwatchPlayPauseButton:SetHighlightTexture("")
	StopwatchPlayPauseButton.backdrop:SetOutside(StopwatchPlayPauseButton, 2, 2)
	StopwatchPlayPauseButton:HookScript("OnEnter", S.SetModifiedBackdrop)
	StopwatchPlayPauseButton:HookScript("OnLeave", S.SetOriginalBackdrop)
	StopwatchPlayPauseButton:Point("RIGHT", StopwatchResetButton, "LEFT", -4, 0)
	S:HandleButton(StopwatchResetButton)
	StopwatchResetButton:Size(16)
	StopwatchResetButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\reset")
	StopwatchResetButton:Point("BOTTOMRIGHT", StopwatchFrame, "BOTTOMRIGHT", -4, 6)

	local function SetPlayTexture()
		StopwatchPlayPauseButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\play")
	end
	local function SetPauseTexture()
		StopwatchPlayPauseButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\pause")
	end
	hooksecurefunc("Stopwatch_Play", SetPauseTexture)
	hooksecurefunc("Stopwatch_Pause", SetPlayTexture)
	hooksecurefunc("Stopwatch_Clear", SetPlayTexture)
end

S:AddCallbackForAddon("Blizzard_TimeManager", "TimeManager", LoadSkin)