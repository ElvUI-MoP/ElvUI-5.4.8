local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local hooksecurefunc = hooksecurefunc
local TIMEMANAGER_TITLE = TIMEMANAGER_TITLE

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.timemanager then return end

	TimeManagerFrame:Size(190, 240)
	TimeManagerFrame:StripTextures()
	TimeManagerFrame:SetTemplate("Transparent")

	TimeManagerFrameInset:Kill()

	E:CreateMover(TimeManagerFrame, "TimeManagerFrameMover", TIMEMANAGER_TITLE)
	TimeManagerFrame.mover:SetFrameLevel(TimeManagerFrame:GetFrameLevel() + 4)

	select(7, TimeManagerFrame:GetRegions()):Point("TOP", 0, -5)

	S:HandleCloseButton(TimeManagerFrameCloseButton)
	TimeManagerFrameCloseButton:Point("TOPRIGHT", 4, 5)

	TimeManagerStopwatchFrame:Point("TOPRIGHT", 10, -12)

	TimeManagerStopwatchCheck:SetTemplate()
	TimeManagerStopwatchCheck:StyleButton(nil, true)

	TimeManagerStopwatchCheck:GetNormalTexture():SetInside()
	TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))

	TimeManagerAlarmTimeFrame:Point("TOPLEFT", 12, -65)

	S:HandleDropDownBox(TimeManagerAlarmHourDropDown, 80)
	S:HandleDropDownBox(TimeManagerAlarmMinuteDropDown, 80)
	S:HandleDropDownBox(TimeManagerAlarmAMPMDropDown, 80)

	S:HandleEditBox(TimeManagerAlarmMessageEditBox)

	S:HandleCheckBox(TimeManagerAlarmEnabledButton)
	TimeManagerAlarmEnabledButton:Point("LEFT", 16, -45)

	TimeManagerMilitaryTimeCheck:Point("TOPLEFT", 155, -190)
	S:HandleCheckBox(TimeManagerMilitaryTimeCheck)
	S:HandleCheckBox(TimeManagerLocalTimeCheck)

	-- StopWatch
	StopwatchFrame:StripTextures()
	StopwatchFrame:CreateBackdrop("Transparent")
	StopwatchFrame.backdrop:Point("TOPLEFT", 3, -15)
	StopwatchFrame.backdrop:Point("BOTTOMRIGHT", -1, 5)

	StopwatchTabFrame:StripTextures()
	StopwatchTabFrame:CreateBackdrop("Default", true)
	StopwatchTabFrame:Point("TOP", 1, 3)

	S:HandleCloseButton(StopwatchCloseButton)
	StopwatchCloseButton:Size(32)
	StopwatchCloseButton:Point("TOPRIGHT", StopwatchTabFrame.backdrop, 6, 7)

	StopwatchPlayPauseButton:CreateBackdrop("Default", true)
	StopwatchPlayPauseButton:Size(12)
	StopwatchPlayPauseButton:SetNormalTexture(E.Media.Textures.Play)
	StopwatchPlayPauseButton:SetHighlightTexture("")
	StopwatchPlayPauseButton.backdrop:SetOutside(StopwatchPlayPauseButton, 2, 2)
	StopwatchPlayPauseButton:HookScript("OnEnter", S.SetModifiedBackdrop)
	StopwatchPlayPauseButton:HookScript("OnLeave", S.SetOriginalBackdrop)
	StopwatchPlayPauseButton:Point("RIGHT", StopwatchResetButton, "LEFT", -4, 0)
	S:HandleButton(StopwatchResetButton)
	StopwatchResetButton:Size(16)
	StopwatchResetButton:SetNormalTexture(E.Media.Textures.Reset)
	StopwatchResetButton:Point("BOTTOMRIGHT", StopwatchFrame, "BOTTOMRIGHT", -4, 9)

	local function SetPlayTexture()
		StopwatchPlayPauseButton:SetNormalTexture(E.Media.Textures.Play)
	end
	local function SetPauseTexture()
		StopwatchPlayPauseButton:SetNormalTexture(E.Media.Textures.Pause)
	end
	hooksecurefunc("Stopwatch_Play", SetPauseTexture)
	hooksecurefunc("Stopwatch_Pause", SetPlayTexture)
	hooksecurefunc("Stopwatch_Clear", SetPlayTexture)
end

S:AddCallbackForAddon("Blizzard_TimeManager", "TimeManager", LoadSkin)