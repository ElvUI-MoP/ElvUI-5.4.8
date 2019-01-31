local E, L, V, P, G = unpack(select(2, ...))
local B = E:NewModule("Blizzard", "AceEvent-3.0", "AceHook-3.0")
E.Blizzard = B

function B:Initialize()
	self:EnhanceColorPicker()
	self:KillBlizzard()
	self:AlertMovers()
	self:PositionCaptureBar()
	self:PositionDurabilityFrame()
	self:PositionGMFrames()
	self:SkinBlizzTimers()
	self:PositionVehicleFrame()
	self:MoveWatchFrame()
	self:ErrorFrameSize()
	self:Handle_LevelUpDisplay()

 	if not IsAddOnLoaded("SimplePowerBar") then
 		self:PositionAltPowerBar()
		self:SkinAltPowerBar()
	end

	if GetLocale() == "deDE" then
		DAY_ONELETTER_ABBR = "%d d"
	end

	E:CreateMover(LossOfControlFrame, "LossControlMover", L["Loss Control Icon"])

	CreateFrame("Frame"):SetScript("OnUpdate", function()
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)

	-- MicroButton Talent Alert
	if E.global.general.showMissingTalentAlert then
		TalentMicroButtonAlert:StripTextures(true)
		TalentMicroButtonAlert:SetTemplate("Transparent")
		TalentMicroButtonAlert:ClearAllPoints()
		TalentMicroButtonAlert:SetPoint("CENTER", E.UIParent, "TOP", 0, -75)
		TalentMicroButtonAlert:Width(230)

		TalentMicroButtonAlertArrow:Hide()
		TalentMicroButtonAlert.Arrow:Hide()
		TalentMicroButtonAlert.Text:Point("TOPLEFT", 42, -23)
		TalentMicroButtonAlert.Text:FontTemplate()
		E:GetModule("Skins"):HandleCloseButton(TalentMicroButtonAlert.CloseButton)

		TalentMicroButtonAlert.tex = TalentMicroButtonAlert:CreateTexture(nil, "OVERLAY")
		TalentMicroButtonAlert.tex:Point("LEFT", 5, -4)
		TalentMicroButtonAlert.tex:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
		TalentMicroButtonAlert.tex:SetSize(32, 32)

		TalentMicroButtonAlert.button = CreateFrame("Button", nil, TalentMicroButtonAlert, nil)
		TalentMicroButtonAlert.button:SetAllPoints(TalentMicroButtonAlert)
		TalentMicroButtonAlert.button:HookScript("OnClick", function()
			if not PlayerTalentFrame then
				TalentFrame_LoadUI()
			end
			if not GlyphFrame then
				GlyphFrame_LoadUI()
			end
			if not PlayerTalentFrame:IsShown() then
				ShowUIPanel(PlayerTalentFrame)
			else
				HideUIPanel(PlayerTalentFrame)
			end
		end)
	else
		TalentMicroButtonAlert:Kill() -- Kill it, because then the blizz default will show
	end
end

local function InitializeCallback()
	B:Initialize()
end

E:RegisterModule(B:GetName(), InitializeCallback)