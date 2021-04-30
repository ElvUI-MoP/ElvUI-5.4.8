local E, L, V, P, G = unpack(select(2, ...))
local B = E:GetModule("Blizzard")
local Skins = E:GetModule("Skins")

local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local UnitIsUnit = UnitIsUnit

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
	self:Handle_LevelUpDisplay()

	if not IsAddOnLoaded("SimplePowerBar") then
		self:PositionAltPowerBar()
		self:SkinAltPowerBar()
	end

	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", SetMapToCurrentZone)

	if GetLocale() == "deDE" then
		DAY_ONELETTER_ABBR = "%d d"
	end

	E:CreateMover(LossOfControlFrame, "LossControlMover", L["Loss Control Icon"])

	CreateFrame("Frame"):SetScript("OnUpdate", function()
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)

	QuestLogFrame:HookScript("OnShow", function()
		local questFrame = QuestLogFrame:GetFrameLevel()
		if questFrame >= QuestLogControlPanel:GetFrameLevel() then
			QuestLogControlPanel:SetFrameLevel(questFrame + 1)
		end
		if questFrame >= QuestLogDetailScrollFrame:GetFrameLevel() then
			QuestLogDetailScrollFrame:SetFrameLevel(questFrame + 1)
		end
	end)

	ReadyCheckFrame:HookScript("OnShow", function(self)
		if UnitIsUnit("player", self.initiator) then
			self:Hide()
		end
	end)

	-- MicroButton Talent Alert
	if E.global.general.showMissingTalentAlert then
		TalentMicroButtonAlert:StripTextures(true)
		TalentMicroButtonAlert:SetTemplate("Transparent")
		TalentMicroButtonAlert:ClearAllPoints()
		TalentMicroButtonAlert:Point("CENTER", E.UIParent, "TOP", 0, -75)
		TalentMicroButtonAlert:Width(230)

		TalentMicroButtonAlertArrow:Hide()
		TalentMicroButtonAlert.Arrow:Hide()
		TalentMicroButtonAlert.Text:Point("TOPLEFT", 42, -23)
		TalentMicroButtonAlert.Text:FontTemplate()
		Skins:HandleCloseButton(TalentMicroButtonAlert.CloseButton)

		TalentMicroButtonAlert.tex = TalentMicroButtonAlert:CreateTexture(nil, "OVERLAY")
		TalentMicroButtonAlert.tex:Point("LEFT", 5, -4)
		TalentMicroButtonAlert.tex:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
		TalentMicroButtonAlert.tex:Size(32)

		TalentMicroButtonAlert.button = CreateFrame("Button", nil, TalentMicroButtonAlert, nil)
		TalentMicroButtonAlert.button:SetAllPoints(TalentMicroButtonAlert)
		TalentMicroButtonAlert.button:HookScript("OnClick", function()
			if not PlayerTalentFrame then TalentFrame_LoadUI() end
			if not GlyphFrame then GlyphFrame_LoadUI() end
			if not PlayerTalentFrame:IsShown() then
				ShowUIPanel(PlayerTalentFrame)
			else
				HideUIPanel(PlayerTalentFrame)
			end
		end)
	else
		TalentMicroButtonAlert:Kill() -- Kill it, because then the blizz default will show
	end

	self.Initialized = true
end

local function InitializeCallback()
	B:Initialize()
end

E:RegisterModule(B:GetName(), InitializeCallback)