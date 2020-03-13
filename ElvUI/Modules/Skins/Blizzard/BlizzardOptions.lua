local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local ipairs = ipairs
local find = string.find

local InCombatLockdown = InCombatLockdown
local IsShiftKeyDown = IsShiftKeyDown

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.BlizzardOptions ~= true then return end

	-- Interface Enable Mouse Move
	InterfaceOptionsFrame:SetClampedToScreen(true)
	InterfaceOptionsFrame:SetMovable(true)
	InterfaceOptionsFrame:EnableMouse(true)
	InterfaceOptionsFrame:RegisterForDrag("LeftButton", "RightButton")
	InterfaceOptionsFrame:SetScript("OnDragStart", function(self)
		if InCombatLockdown() then return end

		if IsShiftKeyDown() then
			self:StartMoving()
		end
	end)
	InterfaceOptionsFrame:SetScript("OnDragStop", function(self) 
		self:StopMovingOrSizing()
	end)
	InterfaceOptionsFrame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", -1, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L["Hold Shift + Drag:"], L["Temporary Move"], 1, 1, 1)

		GameTooltip:Show()
	end)
	InterfaceOptionsFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)

	-- Game Menu Interface/Tabs
	for i = 1, 2 do
		local tab = _G["InterfaceOptionsFrameTab"..i]

		S:HandleTab(tab)
		tab:StripTextures()
	end

	local maxButtons = (InterfaceOptionsFrameAddOns:GetHeight() - 8) / InterfaceOptionsFrameAddOns.buttonHeight
	for i = 1, maxButtons do
		local buttonToggle = _G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]

		buttonToggle:SetNormalTexture([[Interface\AddOns\ElvUI\media\textures\PlusMinusButton]])
		buttonToggle.SetNormalTexture = E.noop
		buttonToggle:SetPushedTexture([[Interface\AddOns\ElvUI\media\textures\PlusMinusButton]])
		buttonToggle.SetPushedTexture = E.noop
		buttonToggle:SetHighlightTexture("")

		hooksecurefunc(buttonToggle, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self:GetNormalTexture():SetTexCoord(0.540, 0.965, 0.085, 0.920)
				self:GetPushedTexture():SetTexCoord(0.540, 0.965, 0.085, 0.920)
			else
				self:GetNormalTexture():SetTexCoord(0.040, 0.465, 0.085, 0.920)
				self:GetPushedTexture():SetTexCoord(0.040, 0.465, 0.085, 0.920)
			end
		end)
	end

	-- Options/Interface Buttons Position
	VideoOptionsFrameCancel:ClearAllPoints()
	VideoOptionsFrameCancel:Point("RIGHT", VideoOptionsFrameApply, "LEFT", -4, 0)

	VideoOptionsFrameOkay:ClearAllPoints()
	VideoOptionsFrameOkay:Point("RIGHT", VideoOptionsFrameCancel, "LEFT", -4, 0)

	InterfaceOptionsFrameOkay:ClearAllPoints()
	InterfaceOptionsFrameOkay:Point("RIGHT", InterfaceOptionsFrameCancel, "LEFT", -4, 0)

	-- Game Menu Options/Frames
	InterfaceOptionsFrame:StripTextures()
	InterfaceOptionsFrame:CreateBackdrop("Transparent")

	S:HandleButton(InterfaceOptionsFrameDefaults)
	S:HandleButton(InterfaceOptionsFrameOkay)
	S:HandleButton(InterfaceOptionsFrameCancel)

	VideoOptionsFrame:StripTextures()
	VideoOptionsFrame:CreateBackdrop("Transparent")

	VideoOptionsFrameCategoryFrame:StripTextures()
	VideoOptionsFrameCategoryFrame:CreateBackdrop("Transparent")

	VideoOptionsFramePanelContainer:StripTextures()
	VideoOptionsFramePanelContainer:CreateBackdrop("Transparent")

	S:HandleButton(VideoOptionsFrameOkay)
	S:HandleButton(VideoOptionsFrameCancel)
	S:HandleButton(VideoOptionsFrameDefaults)
	S:HandleButton(VideoOptionsFrameApply)

	-- Game Menu Options/Graphics
	Graphics_RightQuality:StripTextures()
	S:HandleSliderFrame(Graphics_Quality)

	S:HandleDropDownBox(Graphics_DisplayModeDropDown)
	S:HandleDropDownBox(Graphics_ResolutionDropDown)
	S:HandleDropDownBox(Graphics_RefreshDropDown)
	S:HandleDropDownBox(Graphics_PrimaryMonitorDropDown)
	S:HandleDropDownBox(Graphics_MultiSampleDropDown)
	S:HandleDropDownBox(Graphics_VerticalSyncDropDown)
	S:HandleDropDownBox(Graphics_TextureResolutionDropDown)
	S:HandleDropDownBox(Graphics_FilteringDropDown)
	S:HandleDropDownBox(Graphics_ProjectedTexturesDropDown)
	S:HandleDropDownBox(Graphics_ViewDistanceDropDown)
	S:HandleDropDownBox(Graphics_EnvironmentalDetailDropDown)
	S:HandleDropDownBox(Graphics_GroundClutterDropDown)
	S:HandleDropDownBox(Graphics_ShadowsDropDown)
	S:HandleDropDownBox(Graphics_LiquidDetailDropDown)
	S:HandleDropDownBox(Graphics_SunshaftsDropDown)
	S:HandleDropDownBox(Graphics_ParticleDensityDropDown)
	S:HandleDropDownBox(Graphics_SSAODropDown)

	-- Game Menu Options/Advanced
	S:HandleDropDownBox(Advanced_BufferingDropDown)
	S:HandleDropDownBox(Advanced_LagDropDown)
	S:HandleDropDownBox(Advanced_HardwareCursorDropDown)
	S:HandleDropDownBox(Advanced_GraphicsAPIDropDown)

	S:HandleCheckBox(Advanced_MaxFPSCheckBox)
	S:HandleCheckBox(Advanced_MaxFPSBKCheckBox)
	S:HandleCheckBox(Advanced_UseUIScale)
	S:HandleCheckBox(Advanced_DesktopGamma)

	S:HandleSliderFrame(Advanced_MaxFPSSlider)
	S:HandleSliderFrame(Advanced_UIScaleSlider)
	S:HandleSliderFrame(Advanced_MaxFPSBKSlider)
	S:HandleSliderFrame(Advanced_GammaSlider)

	-- Game Menu Options/Network
	S:HandleCheckBox(NetworkOptionsPanelOptimizeSpeed)
	S:HandleCheckBox(NetworkOptionsPanelUseIPv6)
	S:HandleCheckBox(NetworkOptionsPanelAdvancedCombatLogging)

	-- Game Menu Options/Languages
	S:HandleDropDownBox(InterfaceOptionsLanguagesPanelLocaleDropDown)

	-- Game Menu Options/Sound
	S:HandleCheckBox(AudioOptionsSoundPanelEnableSound)
	S:HandleCheckBox(AudioOptionsSoundPanelSoundEffects)
	S:HandleCheckBox(AudioOptionsSoundPanelErrorSpeech)
	S:HandleCheckBox(AudioOptionsSoundPanelEmoteSounds)
	S:HandleCheckBox(AudioOptionsSoundPanelPetSounds)
	S:HandleCheckBox(AudioOptionsSoundPanelMusic)
	S:HandleCheckBox(AudioOptionsSoundPanelLoopMusic)
	S:HandleCheckBox(AudioOptionsSoundPanelAmbientSounds)
	S:HandleCheckBox(AudioOptionsSoundPanelSoundInBG)
	S:HandleCheckBox(AudioOptionsSoundPanelPetBattleMusic)
	S:HandleCheckBox(AudioOptionsSoundPanelReverb)
	S:HandleCheckBox(AudioOptionsSoundPanelHRTF)
	S:HandleCheckBox(AudioOptionsSoundPanelEnableDSPs)

	S:HandleSliderFrame(AudioOptionsSoundPanelSoundQuality)
	S:HandleSliderFrame(AudioOptionsSoundPanelAmbienceVolume)
	S:HandleSliderFrame(AudioOptionsSoundPanelMusicVolume)
	S:HandleSliderFrame(AudioOptionsSoundPanelSoundVolume)
	S:HandleSliderFrame(AudioOptionsSoundPanelMasterVolume)

	S:HandleDropDownBox(AudioOptionsSoundPanelHardwareDropDown)
	S:HandleDropDownBox(AudioOptionsSoundPanelSoundChannelsDropDown)

	AudioOptionsSoundPanelVolume:StripTextures()
	AudioOptionsSoundPanelVolume:CreateBackdrop("Transparent")

	AudioOptionsSoundPanelHardware:StripTextures()
	AudioOptionsSoundPanelHardware:CreateBackdrop("Transparent")

	AudioOptionsSoundPanelPlayback:StripTextures()
	AudioOptionsSoundPanelPlayback:CreateBackdrop("Transparent")

	-- Game Menu Interface
	InterfaceOptionsFrameCategories:StripTextures()
	InterfaceOptionsFrameCategories:CreateBackdrop("Transparent")

	InterfaceOptionsFramePanelContainer:StripTextures()
	InterfaceOptionsFramePanelContainer:CreateBackdrop("Transparent")

	InterfaceOptionsFrameAddOns:StripTextures()
	InterfaceOptionsFrameAddOns:CreateBackdrop("Transparent")

	InterfaceOptionsFrameCategoriesList:StripTextures()
	S:HandleScrollBar(InterfaceOptionsFrameCategoriesListScrollBar)

	InterfaceOptionsFrameAddOnsList:StripTextures()
	S:HandleScrollBar(InterfaceOptionsFrameAddOnsListScrollBar)

	-- Game Menu Interface/Controls
	S:HandleCheckBox(InterfaceOptionsControlsPanelStickyTargeting)
	S:HandleCheckBox(InterfaceOptionsControlsPanelAutoDismount)
	S:HandleCheckBox(InterfaceOptionsControlsPanelAutoClearAFK)
	S:HandleCheckBox(InterfaceOptionsControlsPanelBlockTrades)
	S:HandleCheckBox(InterfaceOptionsControlsPanelBlockGuildInvites)
	S:HandleCheckBox(InterfaceOptionsControlsPanelLootAtMouse)
	S:HandleCheckBox(InterfaceOptionsControlsPanelAutoLootCorpse)
	S:HandleCheckBox(InterfaceOptionsControlsPanelInteractOnLeftClick)
	S:HandleCheckBox(InterfaceOptionsControlsPanelBlockChatChannelInvites)
	S:HandleCheckBox(InterfaceOptionsControlsPanelAutoOpenLootHistory)

	S:HandleDropDownBox(InterfaceOptionsControlsPanelAutoLootKeyDropDown)

	-- Game Menu Interface/Combat
	S:HandleCheckBox(InterfaceOptionsCombatPanelAttackOnAssist)
	S:HandleCheckBox(InterfaceOptionsCombatPanelStopAutoAttack)
	S:HandleCheckBox(InterfaceOptionsCombatPanelTargetOfTarget)
	S:HandleCheckBox(InterfaceOptionsCombatPanelShowSpellAlerts)
	S:HandleCheckBox(InterfaceOptionsCombatPanelReducedLagTolerance)
	S:HandleCheckBox(InterfaceOptionsCombatPanelActionButtonUseKeyDown)
	S:HandleCheckBox(InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait)
	S:HandleCheckBox(InterfaceOptionsCombatPanelEnemyCastBarsOnNameplates)
	S:HandleCheckBox(InterfaceOptionsCombatPanelAutoSelfCast)
	S:HandleCheckBox(InterfaceOptionsCombatPanelEnemyCastBarsOnOnlyTargetNameplates)
	S:HandleCheckBox(InterfaceOptionsCombatPanelEnemyCastBarsNameplateSpellNames)
	S:HandleCheckBox(InterfaceOptionsCombatPanelLossOfControl)

	S:HandleDropDownBox(InterfaceOptionsCombatPanelFocusCastKeyDropDown)
	S:HandleDropDownBox(InterfaceOptionsCombatPanelSelfCastKeyDropDown)

	S:HandleDropDownBox(InterfaceOptionsCombatPanelLossOfControlFullDropDown)
	S:HandleDropDownBox(InterfaceOptionsCombatPanelLossOfControlSilenceDropDown)
	S:HandleDropDownBox(InterfaceOptionsCombatPanelLossOfControlInterruptDropDown)
	S:HandleDropDownBox(InterfaceOptionsCombatPanelLossOfControlDisarmDropDown)
	S:HandleDropDownBox(InterfaceOptionsCombatPanelLossOfControlRootDropDown)

	S:HandleSliderFrame(InterfaceOptionsCombatPanelSpellAlertOpacitySlider)
	S:HandleSliderFrame(InterfaceOptionsCombatPanelMaxSpellStartRecoveryOffset)

	-- Game Menu Interface/Display
	S:HandleCheckBox(InterfaceOptionsDisplayPanelShowCloak)
	S:HandleCheckBox(InterfaceOptionsDisplayPanelShowHelm)
	S:HandleCheckBox(InterfaceOptionsDisplayPanelShowAggroPercentage)
	S:HandleCheckBox(InterfaceOptionsDisplayPanelPlayAggroSounds)
	S:HandleCheckBox(InterfaceOptionsDisplayPanelShowSpellPointsAvg)
	S:HandleCheckBox(InterfaceOptionsDisplayPanelRotateMinimap)
	S:HandleCheckBox(InterfaceOptionsDisplayPanelCinematicSubtitles)
	S:HandleCheckBox(InterfaceOptionsDisplayPanelShowFreeBagSpace)
	S:HandleCheckBox(InterfaceOptionsDisplayPanelShowAccountAchievments)

	-- Game Menu Interface/Objectives
	S:HandleCheckBox(InterfaceOptionsObjectivesPanelAutoQuestTracking)
	S:HandleCheckBox(InterfaceOptionsObjectivesPanelMapQuestDifficulty)
	S:HandleCheckBox(InterfaceOptionsObjectivesPanelWatchFrameWidth)

	-- Game Menu Interface/Social
	S:HandleCheckBox(InterfaceOptionsSocialPanelProfanityFilter)
	S:HandleCheckBox(InterfaceOptionsSocialPanelSpamFilter)
	S:HandleCheckBox(InterfaceOptionsSocialPanelChatBubbles)
	S:HandleCheckBox(InterfaceOptionsSocialPanelPartyChat)
	S:HandleCheckBox(InterfaceOptionsSocialPanelChatHoverDelay)
	S:HandleCheckBox(InterfaceOptionsSocialPanelGuildMemberAlert)
	S:HandleCheckBox(InterfaceOptionsSocialPanelChatMouseScroll)

	S:HandleDropDownBox(InterfaceOptionsSocialPanelWhisperMode)

	-- Game Menu Interface/Action Bars
	S:HandleCheckBox(InterfaceOptionsActionBarsPanelBottomLeft)
	S:HandleCheckBox(InterfaceOptionsActionBarsPanelBottomRight)
	S:HandleCheckBox(InterfaceOptionsActionBarsPanelRight)
	S:HandleCheckBox(InterfaceOptionsActionBarsPanelRightTwo)
	S:HandleCheckBox(InterfaceOptionsActionBarsPanelLockActionBars)
	S:HandleCheckBox(InterfaceOptionsActionBarsPanelAlwaysShowActionBars)
	S:HandleCheckBox(InterfaceOptionsActionBarsPanelSecureAbilityToggle)

	S:HandleDropDownBox(InterfaceOptionsActionBarsPanelPickupActionKeyDropDown)

	-- Game Menu Interface/Names
	S:HandleCheckBox(InterfaceOptionsNamesPanelGuilds)
	S:HandleCheckBox(InterfaceOptionsNamesPanelGuildTitles)
	S:HandleCheckBox(InterfaceOptionsNamesPanelTitles)
	S:HandleCheckBox(InterfaceOptionsNamesPanelNonCombatCreature)
	S:HandleCheckBox(InterfaceOptionsNamesPanelEnemyPlayerNames)
	S:HandleCheckBox(InterfaceOptionsNamesPanelEnemyPets)
	S:HandleCheckBox(InterfaceOptionsNamesPanelEnemyGuardians)
	S:HandleCheckBox(InterfaceOptionsNamesPanelEnemyTotems)
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesEnemies)
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesEnemyPets)
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesEnemyGuardians)
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesEnemyTotems)
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesFriendlyTotems)
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesFriendlyGuardians)
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesFriendlyPets)
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesFriends)
	S:HandleCheckBox(InterfaceOptionsNamesPanelFriendlyTotems)
	S:HandleCheckBox(InterfaceOptionsNamesPanelFriendlyGuardians)
	S:HandleCheckBox(InterfaceOptionsNamesPanelFriendlyPets)
	S:HandleCheckBox(InterfaceOptionsNamesPanelFriendlyPlayerNames)
	S:HandleCheckBox(InterfaceOptionsNamesPanelMyName)
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesNameplateClassColors)

	S:HandleDropDownBox(InterfaceOptionsNamesPanelNPCNamesDropDown)
	S:HandleDropDownBox(InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown)

	-- Game Menu Interface/Floating Combat Text
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelTargetDamage)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelPeriodicDamage)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelPetDamage)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelHealing)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelEnableFCT)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelDodgeParryMiss)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelDamageReduction)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelRepChanges)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelReactiveAbilities)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelFriendlyHealerNames)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelCombatState)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelAuras)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelHonorGains)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelPeriodicEnergyGains)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelEnergyGains)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelLowManaHealth)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelComboPoints)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelOtherTargetEffects)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelTargetEffects)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelHealingAbsorbTarget)
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelHealingAbsorbSelf)

	S:HandleDropDownBox(InterfaceOptionsCombatTextPanelFCTDropDown)

	-- Game Menu Interface/Status Text
	S:HandleCheckBox(InterfaceOptionsStatusTextPanelPlayer)
	S:HandleCheckBox(InterfaceOptionsStatusTextPanelPet)
	S:HandleCheckBox(InterfaceOptionsStatusTextPanelParty)
	S:HandleCheckBox(InterfaceOptionsStatusTextPanelTarget)
	S:HandleCheckBox(InterfaceOptionsStatusTextPanelAlternateResource)
	S:HandleCheckBox(InterfaceOptionsStatusTextPanelXP)

	S:HandleDropDownBox( InterfaceOptionsStatusTextPanelDisplayDropDown)

	-- Game Menu Interface/Unit Frames
	S:HandleCheckBox(InterfaceOptionsUnitFramePanelPartyPets)
	S:HandleCheckBox(InterfaceOptionsUnitFramePanelArenaEnemyFrames)
	S:HandleCheckBox(InterfaceOptionsUnitFramePanelArenaEnemyCastBar)
	S:HandleCheckBox(InterfaceOptionsUnitFramePanelArenaEnemyPets)
	S:HandleCheckBox(InterfaceOptionsUnitFramePanelFullSizeFocusFrame)

	-- Game Menu Interface/Raid Profiles
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameKeepGroupsTogether)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameHorizontalGroups)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameDisplayIncomingHeals)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameDisplayPowerBar)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameDisplayAggroHighlight)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameUseClassColors)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameDisplayPets)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameDisplayMainTankAndAssist)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameDisplayBorder)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameShowDebuffs)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameDisplayOnlyDispellableDebuffs)
	S:HandleCheckBox(CompactUnitFrameProfilesRaidStylePartyFrames)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate2Players)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate3Players)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate5Players)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate10Players)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate15Players)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate25Players)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate40Players)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec1)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec2)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvP)
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvE)

	S:HandleButton(CompactUnitFrameProfilesSaveButton)
	S:HandleButton(CompactUnitFrameProfilesDeleteButton)
	S:HandleButton(CompactUnitFrameProfilesGeneralOptionsFrameResetPositionButton)

	S:HandleSliderFrame(CompactUnitFrameProfilesGeneralOptionsFrameHeightSlider)
	S:HandleSliderFrame(CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider)

	S:HandleDropDownBox(CompactUnitFrameProfilesGeneralOptionsFrameSortByDropdown)
	S:HandleDropDownBox(CompactUnitFrameProfilesProfileSelector)
	S:HandleDropDownBox(CompactUnitFrameProfilesGeneralOptionsFrameHealthTextDropdown)

	-- Game Menu Interface/Buffs and Debuffs
	S:HandleCheckBox(InterfaceOptionsBuffsPanelDispellableDebuffs)
	S:HandleCheckBox(InterfaceOptionsBuffsPanelCastableBuffs)
	S:HandleCheckBox(InterfaceOptionsBuffsPanelConsolidateBuffs)
	S:HandleCheckBox(InterfaceOptionsBuffsPanelShowAllEnemyDebuffs)

	-- Game Menu Interface/Camera
	S:HandleCheckBox(InterfaceOptionsCameraPanelFollowTerrain)
	S:HandleCheckBox(InterfaceOptionsCameraPanelHeadBob)
	S:HandleCheckBox(InterfaceOptionsCameraPanelWaterCollision)
	S:HandleCheckBox(InterfaceOptionsCameraPanelSmartPivot)

	S:HandleSliderFrame(InterfaceOptionsCameraPanelMaxDistanceSlider)
	S:HandleSliderFrame(InterfaceOptionsCameraPanelFollowSpeedSlider)

	S:HandleDropDownBox(InterfaceOptionsCameraPanelStyleDropDown)

	-- Game Menu Interface/Mouse
	S:HandleCheckBox(InterfaceOptionsMousePanelInvertMouse)
	S:HandleCheckBox(InterfaceOptionsMousePanelClickToMove)
	S:HandleCheckBox(InterfaceOptionsMousePanelWoWMouse)

	S:HandleSliderFrame(InterfaceOptionsMousePanelMouseSensitivitySlider)
	S:HandleSliderFrame(InterfaceOptionsMousePanelMouseLookSpeedSlider)

	S:HandleDropDownBox(InterfaceOptionsMousePanelClickMoveStyleDropDown)

	-- Game Menu Interface/Help
	S:HandleCheckBox(InterfaceOptionsHelpPanelShowTutorials)
	S:HandleCheckBox(InterfaceOptionsHelpPanelEnhancedTooltips)
	S:HandleCheckBox(InterfaceOptionsHelpPanelShowLuaErrors)
	S:HandleCheckBox(InterfaceOptionsHelpPanelColorblindMode)
	S:HandleCheckBox(InterfaceOptionsHelpPanelMovePad)

	S:HandleButton(InterfaceOptionsHelpPanelResetTutorials)

	-- Chat Config
	ChatConfigFrame:StripTextures()
	ChatConfigFrame:SetTemplate("Transparent")
	ChatConfigCategoryFrame:SetTemplate("Transparent")
	ChatConfigBackgroundFrame:SetTemplate("Transparent")

	ChatConfigChatSettingsClassColorLegend:SetTemplate("Transparent")
	ChatConfigChannelSettingsClassColorLegend:SetTemplate("Transparent")

	ChatConfigCombatSettingsFilters:SetTemplate("Transparent")

	ChatConfigCombatSettingsFiltersScrollFrame:StripTextures()

	S:HandleScrollBar(ChatConfigCombatSettingsFiltersScrollFrameScrollBar)

	S:HandleButton(ChatConfigCombatSettingsFiltersDeleteButton)
	ChatConfigCombatSettingsFiltersDeleteButton:Point("TOPRIGHT", ChatConfigCombatSettingsFilters, "BOTTOMRIGHT", 0, -1)

	S:HandleButton(ChatConfigCombatSettingsFiltersAddFilterButton)
	ChatConfigCombatSettingsFiltersAddFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)

	S:HandleButton(ChatConfigCombatSettingsFiltersCopyFilterButton)
	ChatConfigCombatSettingsFiltersCopyFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)

	S:HandleNextPrevButton(ChatConfigMoveFilterUpButton, true)
	SquareButton_SetIcon(ChatConfigMoveFilterUpButton, "UP")
	ChatConfigMoveFilterUpButton:Size(26)
	ChatConfigMoveFilterUpButton:Point("TOPLEFT", ChatConfigCombatSettingsFilters, "BOTTOMLEFT", 3, -1)
	ChatConfigMoveFilterUpButton:SetHitRectInsets(0, 0, 0, 0)

	S:HandleNextPrevButton(ChatConfigMoveFilterDownButton, true)
	ChatConfigMoveFilterDownButton:Size(26)
	ChatConfigMoveFilterDownButton:Point("LEFT", ChatConfigMoveFilterUpButton, "RIGHT", 1, 0)
	ChatConfigMoveFilterDownButton:SetHitRectInsets(0, 0, 0, 0)

	CombatConfigColorsHighlighting:StripTextures()
	CombatConfigColorsColorizeUnitName:StripTextures()
	CombatConfigColorsColorizeSpellNames:StripTextures()

	CombatConfigColorsColorizeDamageNumber:StripTextures()
	CombatConfigColorsColorizeDamageSchool:StripTextures()
	CombatConfigColorsColorizeEntireLine:StripTextures()

	S:HandleColorSwatch(CombatConfigColorsColorizeSpellNamesColorSwatch)
	S:HandleColorSwatch(CombatConfigColorsColorizeDamageNumberColorSwatch)

	S:HandleEditBox(CombatConfigSettingsNameEditBox)

	S:HandleButton(CombatConfigSettingsSaveButton)

	S:HandleCheckBox(CombatConfigColorsHighlightingLine)
	S:HandleCheckBox(CombatConfigColorsHighlightingAbility)
	S:HandleCheckBox(CombatConfigColorsHighlightingDamage)
	S:HandleCheckBox(CombatConfigColorsHighlightingSchool)
	S:HandleCheckBox(CombatConfigColorsColorizeUnitNameCheck)
	S:HandleCheckBox(CombatConfigColorsColorizeSpellNamesCheck)
	S:HandleCheckBox(CombatConfigColorsColorizeSpellNamesSchoolColoring)
	S:HandleCheckBox(CombatConfigColorsColorizeDamageNumberCheck)
	S:HandleCheckBox(CombatConfigColorsColorizeDamageNumberSchoolColoring)
	S:HandleCheckBox(CombatConfigColorsColorizeDamageSchoolCheck)
	S:HandleCheckBox(CombatConfigColorsColorizeEntireLineCheck)
	S:HandleCheckBox(CombatConfigFormattingShowTimeStamp)
	S:HandleCheckBox(CombatConfigFormattingShowBraces)
	S:HandleCheckBox(CombatConfigFormattingUnitNames)
	S:HandleCheckBox(CombatConfigFormattingSpellNames)
	S:HandleCheckBox(CombatConfigFormattingItemNames)
	S:HandleCheckBox(CombatConfigFormattingFullText)
	S:HandleCheckBox(CombatConfigSettingsShowQuickButton)
	S:HandleCheckBox(CombatConfigSettingsSolo)
	S:HandleCheckBox(CombatConfigSettingsParty)
	S:HandleCheckBox(CombatConfigSettingsRaid)

	for i = 1, 5 do
		local tab = _G["CombatConfigTab"..i]
		tab:StripTextures()

		tab:CreateBackdrop("Default", true)
		tab.backdrop:Point("TOPLEFT", 1, -10)
		tab.backdrop:Point("BOTTOMRIGHT", -1, 2)

		tab:HookScript("OnEnter", S.SetModifiedBackdrop)
		tab:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	S:HandleButton(ChatConfigFrameDefaultButton)
	ChatConfigFrameDefaultButton:Point("BOTTOMLEFT", 12, 8)
	ChatConfigFrameDefaultButton:Width(125)

	S:HandleButton(CombatLogDefaultButton)

	S:HandleButton(ChatConfigFrameCancelButton)
	ChatConfigFrameCancelButton:Point("BOTTOMRIGHT", -11, 8)

	S:HandleButton(ChatConfigFrameOkayButton)

	S:SecureHook("ChatConfig_CreateCheckboxes", function(frame, checkBoxTable, checkBoxTemplate)
		local checkBoxNameString = frame:GetName().."CheckBox"

		if checkBoxTemplate == "ChatConfigCheckBoxTemplate" then
			frame:SetTemplate("Transparent")
			for index in ipairs(checkBoxTable) do
				local checkBoxName = checkBoxNameString..index
				local checkbox = _G[checkBoxName]
				if not checkbox.backdrop then
					checkbox:StripTextures()
					checkbox:CreateBackdrop()
					checkbox.backdrop:Point("TOPLEFT", 3, -1)
					checkbox.backdrop:Point("BOTTOMRIGHT", -3, 1)
					checkbox.backdrop:SetFrameLevel(checkbox:GetParent():GetFrameLevel() + 1)

					S:HandleCheckBox(_G[checkBoxName.."Check"])
				end
			end
		elseif (checkBoxTemplate == "ChatConfigCheckBoxWithSwatchTemplate") or (checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate") then
			frame:SetTemplate("Transparent")
			for index in ipairs(checkBoxTable) do
				local checkBoxName = checkBoxNameString..index
				local checkbox = _G[checkBoxName]
				local colorSwatch = _G[checkBoxName.."ColorSwatch"]

				if not checkbox.backdrop then
					checkbox:StripTextures()

					checkbox:CreateBackdrop()
					checkbox.backdrop:Point("TOPLEFT", 3, -1)
					checkbox.backdrop:Point("BOTTOMRIGHT", -3, 1)
					checkbox.backdrop:SetFrameLevel(checkbox:GetParent():GetFrameLevel() + 1)

					S:HandleCheckBox(_G[checkBoxName.."Check"])

					if checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate" then
						S:HandleCheckBox(_G[checkBoxName.."ColorClasses"])
					end

					S:HandleColorSwatch(colorSwatch)
				end
			end
		end
	end)

	S:SecureHook("ChatConfig_CreateTieredCheckboxes", function(frame, checkBoxTable)
		local checkBoxNameString = frame:GetName().."CheckBox"
		for index, value in ipairs(checkBoxTable) do
			local checkBoxName = checkBoxNameString..index

			if _G[checkBoxName] then
				S:HandleCheckBox(_G[checkBoxName])
				if value.subTypes then
					local subCheckBoxNameString = checkBoxName.."_"
					for k in ipairs(value.subTypes) do
						local subCheckBoxName = subCheckBoxNameString..k
						if _G[subCheckBoxName] then
							S:HandleCheckBox(_G[subCheckBoxNameString..k])
						end
					end
				end
			end
		end
	end)

	S:SecureHook("ChatConfig_CreateColorSwatches", function(frame, swatchTable)
		frame:SetTemplate("Transparent")
		local nameString = frame:GetName().."Swatch"

		for index in ipairs(swatchTable) do
			local swatchName = nameString..index
			local swatch = _G[swatchName]
			local colorSwatch = _G[swatchName.."ColorSwatch"]

			if not swatch.backdrop then
				swatch:StripTextures()
				swatch:CreateBackdrop()
				swatch.backdrop:Point("TOPLEFT", 3, -1)
				swatch.backdrop:Point("BOTTOMRIGHT", -3, 1)
				swatch.backdrop:SetFrameLevel(swatch:GetParent():GetFrameLevel() + 1)

				S:HandleColorSwatch(colorSwatch)
			end
		end
	end)
end

S:AddCallback("SkinBlizzard", LoadSkin)