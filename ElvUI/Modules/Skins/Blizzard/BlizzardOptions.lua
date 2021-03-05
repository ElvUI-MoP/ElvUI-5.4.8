local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local ipairs, pairs = ipairs, pairs
local find = string.find

local InCombatLockdown = InCombatLockdown

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.BlizzardOptions then return end

	-- Interface/Options Frame Enable Mouse Move
	for _, Frame in pairs({InterfaceOptionsFrame, VideoOptionsFrame, ChatConfigFrame}) do
		Frame:StripTextures()
		Frame:CreateBackdrop("Transparent")
		Frame:SetClampedToScreen(true)
		Frame:SetMovable(true)
		Frame:EnableMouse(true)
		Frame:RegisterForDrag("LeftButton", "RightButton")
		Frame:SetScript("OnDragStart", function(self)
			if InCombatLockdown() then return end

			self:StartMoving()
		end)
		Frame:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
		end)
	end

	-- Game Menu Interface/Tabs
	for i = 1, 2 do
		local tab = _G["InterfaceOptionsFrameTab"..i]

		S:HandleTab(tab)
		tab:StripTextures()
	end

	for frame, numItems in pairs({["InterfaceOptionsFrameCategoriesButton"] = 31, ["VideoOptionsFrameCategoryFrameButton"] = 23}) do
		for i = 1, numItems do
			local item = _G[frame..i]

			item:SetHighlightTexture(E.Media.Textures.Highlight)

			local highlight = item:GetHighlightTexture()
			highlight:SetVertexColor(1, 0.82, 0, 0.35)
			highlight:Point("TOPLEFT", 0, 0)
			highlight:Point("BOTTOMRIGHT", 0, 1)
		end
	end

	local maxButtons = (InterfaceOptionsFrameAddOns:GetHeight() - 8) / InterfaceOptionsFrameAddOns.buttonHeight
	for i = 1, maxButtons do
		local button = _G["InterfaceOptionsFrameAddOnsButton"..i]
		local buttonToggle = _G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]

		button:SetHighlightTexture(E.Media.Textures.Highlight)

		local highlight = button:GetHighlightTexture()
		highlight:SetVertexColor(1, 0.82, 0, 0.35)
		highlight:Point("TOPLEFT", 0, 0)
		highlight:Point("BOTTOMRIGHT", 0, 1)

		buttonToggle:SetNormalTexture(E.Media.Textures.Plus)
		buttonToggle.SetNormalTexture = E.noop
		buttonToggle:SetPushedTexture(E.Media.Textures.Plus)
		buttonToggle.SetPushedTexture = E.noop
		buttonToggle:SetHighlightTexture("")

		hooksecurefunc(buttonToggle, "SetNormalTexture", function(self, texture)
			local normal, pushed = self:GetNormalTexture(), self:GetPushedTexture()

			if find(texture, "MinusButton") then
				normal:SetTexture(E.Media.Textures.Minus)
				pushed:SetTexture(E.Media.Textures.Minus)
			else
				normal:SetTexture(E.Media.Textures.Plus)
				pushed:SetTexture(E.Media.Textures.Plus)
			end
		end)
	end

	local Buttons = {
		InterfaceOptionsFrameDefaults,
		InterfaceOptionsFrameOkay,
		InterfaceOptionsFrameCancel,
		VideoOptionsFrameOkay,
		VideoOptionsFrameCancel,
		VideoOptionsFrameDefaults,
		VideoOptionsFrameApply,
		CompactUnitFrameProfilesSaveButton,
		CompactUnitFrameProfilesDeleteButton,
		CompactUnitFrameProfilesGeneralOptionsFrameResetPositionButton,
		InterfaceOptionsHelpPanelResetTutorials,
		ChatConfigCombatSettingsFiltersDeleteButton,
		ChatConfigCombatSettingsFiltersAddFilterButton,
		ChatConfigCombatSettingsFiltersCopyFilterButton,
		CombatConfigSettingsSaveButton,
		ChatConfigFrameDefaultButton,
		CombatLogDefaultButton,
		ChatConfigFrameCancelButton,
		ChatConfigFrameOkayButton
	}

	local DropDowns = {
		Graphics_DisplayModeDropDown,
		Graphics_ResolutionDropDown,
		Graphics_RefreshDropDown,
		Graphics_PrimaryMonitorDropDown,
		Graphics_MultiSampleDropDown,
		Graphics_VerticalSyncDropDown,
		Graphics_TextureResolutionDropDown,
		Graphics_FilteringDropDown,
		Graphics_ProjectedTexturesDropDown,
		Graphics_ViewDistanceDropDown,
		Graphics_EnvironmentalDetailDropDown,
		Graphics_GroundClutterDropDown,
		Graphics_ShadowsDropDown,
		Graphics_LiquidDetailDropDown,
		Graphics_SunshaftsDropDown,
		Graphics_ParticleDensityDropDown,
		Advanced_BufferingDropDown,
		Advanced_LagDropDown,
		Advanced_HardwareCursorDropDown,
		Advanced_GraphicsAPIDropDown,
		InterfaceOptionsLanguagesPanelLocaleDropDown,
		AudioOptionsSoundPanelHardwareDropDown,
		AudioOptionsSoundPanelSoundChannelsDropDown,
		InterfaceOptionsControlsPanelAutoLootKeyDropDown,
		InterfaceOptionsCombatPanelTOTDropDown,
		InterfaceOptionsCombatPanelFocusCastKeyDropDown,
		InterfaceOptionsCombatPanelSelfCastKeyDropDown,
		InterfaceOptionsSocialPanelWhisperMode,
		InterfaceOptionsSocialPanelChatStyle,
		InterfaceOptionsSocialPanelTimestamps,
		InterfaceOptionsDisplayPanelAggroWarningDisplay,
		InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay,
		InterfaceOptionsActionBarsPanelPickupActionKeyDropDown,
		InterfaceOptionsNamesPanelNPCNamesDropDown,
		InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown,
		InterfaceOptionsCombatTextPanelFCTDropDown,
		CompactUnitFrameProfilesGeneralOptionsFrameSortByDropdown,
		CompactUnitFrameProfilesProfileSelector,
		CompactUnitFrameProfilesGeneralOptionsFrameHealthTextDropdown,
		InterfaceOptionsCameraPanelStyleDropDown,
		InterfaceOptionsMousePanelClickMoveStyleDropDown,
		InterfaceOptionsCombatPanelLossOfControlFullDropDown,
		InterfaceOptionsCombatPanelLossOfControlSilenceDropDown,
		InterfaceOptionsCombatPanelLossOfControlInterruptDropDown,
		InterfaceOptionsCombatPanelLossOfControlDisarmDropDown,
		InterfaceOptionsCombatPanelLossOfControlRootDropDown,
		InterfaceOptionsStatusTextPanelDisplayDropDown,
		Graphics_SSAODropDown,
	}

	local CheckBoxes = {
		NetworkOptionsPanelOptimizeSpeed,
		NetworkOptionsPanelUseIPv6,
		Advanced_MaxFPSCheckBox,
		Advanced_MaxFPSBKCheckBox,
		Advanced_UseUIScale,
		Advanced_DesktopGamma,
		AudioOptionsSoundPanelEnableSound,
		AudioOptionsSoundPanelSoundEffects,
		AudioOptionsSoundPanelErrorSpeech,
		AudioOptionsSoundPanelEmoteSounds,
		AudioOptionsSoundPanelPetSounds,
		AudioOptionsSoundPanelMusic,
		AudioOptionsSoundPanelLoopMusic,
		AudioOptionsSoundPanelAmbientSounds,
		AudioOptionsSoundPanelSoundInBG,
		AudioOptionsSoundPanelReverb,
		AudioOptionsSoundPanelHRTF,
		AudioOptionsSoundPanelEnableDSPs,
		AudioOptionsSoundPanelUseHardware,
		InterfaceOptionsControlsPanelStickyTargeting,
		InterfaceOptionsControlsPanelAutoDismount,
		InterfaceOptionsControlsPanelAutoClearAFK,
		InterfaceOptionsControlsPanelBlockTrades,
		InterfaceOptionsControlsPanelBlockGuildInvites,
		InterfaceOptionsControlsPanelLootAtMouse,
		InterfaceOptionsControlsPanelAutoLootCorpse,
		InterfaceOptionsControlsPanelInteractOnLeftClick,
		InterfaceOptionsCombatPanelAttackOnAssist,
		InterfaceOptionsCombatPanelStopAutoAttack,
		InterfaceOptionsCombatPanelNameplateClassColors,
		InterfaceOptionsCombatPanelTargetOfTarget,
		InterfaceOptionsCombatPanelShowSpellAlerts,
		InterfaceOptionsCombatPanelReducedLagTolerance,
		InterfaceOptionsCombatPanelActionButtonUseKeyDown,
		InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait,
		InterfaceOptionsCombatPanelEnemyCastBarsOnNameplates,
		InterfaceOptionsCombatPanelAutoSelfCast,
		InterfaceOptionsDisplayPanelShowCloak,
		InterfaceOptionsDisplayPanelShowHelm,
		InterfaceOptionsDisplayPanelShowAggroPercentage,
		InterfaceOptionsDisplayPanelPlayAggroSounds,
		InterfaceOptionsDisplayPanelDetailedLootInfo,
		InterfaceOptionsDisplayPanelShowSpellPointsAvg,
		InterfaceOptionsDisplayPanelScreenEdgeFlash,
		InterfaceOptionsDisplayPanelRotateMinimap,
		InterfaceOptionsDisplayPanelCinematicSubtitles,
		InterfaceOptionsDisplayPanelShowFreeBagSpace,
		InterfaceOptionsDisplayPanelemphasizeMySpellEffects,
		InterfaceOptionsObjectivesPanelAutoQuestTracking,
		InterfaceOptionsObjectivesPanelAutoQuestProgress,
		InterfaceOptionsObjectivesPanelMapQuestDifficulty,
		InterfaceOptionsObjectivesPanelWatchFrameWidth,
		InterfaceOptionsSocialPanelProfanityFilter,
		InterfaceOptionsSocialPanelSpamFilter,
		InterfaceOptionsSocialPanelChatBubbles,
		InterfaceOptionsSocialPanelPartyChat,
		InterfaceOptionsSocialPanelChatHoverDelay,
		InterfaceOptionsSocialPanelGuildMemberAlert,
		InterfaceOptionsSocialPanelChatMouseScroll,
		InterfaceOptionsSocialPanelWholeChatWindowClickable,
		InterfaceOptionsActionBarsPanelBottomLeft,
		InterfaceOptionsActionBarsPanelBottomRight,
		InterfaceOptionsActionBarsPanelRight,
		InterfaceOptionsActionBarsPanelRightTwo,
		InterfaceOptionsActionBarsPanelLockActionBars,
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars,
		InterfaceOptionsActionBarsPanelSecureAbilityToggle,
		InterfaceOptionsNamesPanelGuilds,
		InterfaceOptionsNamesPanelGuildTitles,
		InterfaceOptionsNamesPanelTitles,
		InterfaceOptionsNamesPanelNonCombatCreature,
		InterfaceOptionsNamesPanelEnemyPlayerNames,
		InterfaceOptionsNamesPanelEnemyPets,
		InterfaceOptionsNamesPanelEnemyGuardians,
		InterfaceOptionsNamesPanelEnemyTotems,
		InterfaceOptionsNamesPanelUnitNameplatesEnemies,
		InterfaceOptionsNamesPanelUnitNameplatesEnemyPets,
		InterfaceOptionsNamesPanelUnitNameplatesEnemyGuardians,
		InterfaceOptionsNamesPanelUnitNameplatesEnemyTotems,
		InterfaceOptionsNamesPanelUnitNameplatesFriendlyTotems,
		InterfaceOptionsNamesPanelUnitNameplatesFriendlyGuardians,
		InterfaceOptionsNamesPanelUnitNameplatesFriendlyPets,
		InterfaceOptionsNamesPanelUnitNameplatesFriends,
		InterfaceOptionsNamesPanelFriendlyTotems,
		InterfaceOptionsNamesPanelFriendlyGuardians,
		InterfaceOptionsNamesPanelFriendlyPets,
		InterfaceOptionsNamesPanelFriendlyPlayerNames,
		InterfaceOptionsNamesPanelMyName,
		InterfaceOptionsCombatTextPanelTargetDamage,
		InterfaceOptionsCombatTextPanelPeriodicDamage,
		InterfaceOptionsCombatTextPanelPetDamage,
		InterfaceOptionsCombatTextPanelHealing,
		InterfaceOptionsCombatTextPanelEnableFCT,
		InterfaceOptionsCombatTextPanelDodgeParryMiss,
		InterfaceOptionsCombatTextPanelDamageReduction,
		InterfaceOptionsCombatTextPanelRepChanges,
		InterfaceOptionsCombatTextPanelReactiveAbilities,
		InterfaceOptionsCombatTextPanelFriendlyHealerNames,
		InterfaceOptionsCombatTextPanelCombatState,
		InterfaceOptionsCombatTextPanelAuras,
		InterfaceOptionsCombatTextPanelHonorGains,
		InterfaceOptionsCombatTextPanelPeriodicEnergyGains,
		InterfaceOptionsCombatTextPanelEnergyGains,
		InterfaceOptionsCombatTextPanelLowManaHealth,
		InterfaceOptionsCombatTextPanelComboPoints,
		InterfaceOptionsCombatTextPanelOtherTargetEffects,
		InterfaceOptionsCombatTextPanelTargetEffects,
		InterfaceOptionsStatusTextPanelPlayer,
		InterfaceOptionsStatusTextPanelPet,
		InterfaceOptionsStatusTextPanelParty,
		InterfaceOptionsStatusTextPanelTarget,
		InterfaceOptionsStatusTextPanelAlternateResource,
		InterfaceOptionsStatusTextPanelPercentages,
		InterfaceOptionsStatusTextPanelXP,
		InterfaceOptionsUnitFramePanelPartyBackground,
		InterfaceOptionsUnitFramePanelPartyPets,
		InterfaceOptionsUnitFramePanelArenaEnemyFrames,
		InterfaceOptionsUnitFramePanelArenaEnemyCastBar,
		InterfaceOptionsUnitFramePanelArenaEnemyPets,
		InterfaceOptionsUnitFramePanelFullSizeFocusFrame,
		CompactUnitFrameProfilesGeneralOptionsFrameKeepGroupsTogether,
		CompactUnitFrameProfilesGeneralOptionsFrameHorizontalGroups,
		CompactUnitFrameProfilesGeneralOptionsFrameDisplayIncomingHeals,
		CompactUnitFrameProfilesGeneralOptionsFrameDisplayPowerBar,
		CompactUnitFrameProfilesGeneralOptionsFrameDisplayAggroHighlight,
		CompactUnitFrameProfilesGeneralOptionsFrameUseClassColors,
		CompactUnitFrameProfilesGeneralOptionsFrameDisplayPets,
		CompactUnitFrameProfilesGeneralOptionsFrameDisplayMainTankAndAssist,
		CompactUnitFrameProfilesGeneralOptionsFrameDisplayBorder,
		CompactUnitFrameProfilesGeneralOptionsFrameShowDebuffs,
		CompactUnitFrameProfilesGeneralOptionsFrameDisplayOnlyDispellableDebuffs,
		CompactUnitFrameProfilesRaidStylePartyFrames,
		CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate2Players,
		CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate3Players,
		CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate5Players,
		CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate10Players,
		CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate15Players,
		CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate25Players,
		CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate40Players,
		CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec1,
		CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec2,
		CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvP,
		CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvE,
		CombatConfigColorsHighlightingLine,
		CombatConfigColorsHighlightingAbility,
		CombatConfigColorsHighlightingDamage,
		CombatConfigColorsHighlightingSchool,
		CombatConfigColorsColorizeUnitNameCheck,
		CombatConfigColorsColorizeSpellNamesCheck,
		CombatConfigColorsColorizeSpellNamesSchoolColoring,
		CombatConfigColorsColorizeDamageNumberCheck,
		CombatConfigColorsColorizeDamageNumberSchoolColoring,
		CombatConfigColorsColorizeDamageSchoolCheck,
		CombatConfigColorsColorizeEntireLineCheck,
		CombatConfigFormattingShowTimeStamp,
		CombatConfigFormattingShowBraces,
		CombatConfigFormattingUnitNames,
		CombatConfigFormattingSpellNames,
		CombatConfigFormattingItemNames,
		CombatConfigFormattingFullText,
		CombatConfigSettingsShowQuickButton,
		CombatConfigSettingsSolo,
		CombatConfigSettingsParty,
		CombatConfigSettingsRaid,
		InterfaceOptionsBuffsPanelBuffDurations,
		InterfaceOptionsBuffsPanelDispellableDebuffs,
		InterfaceOptionsBuffsPanelCastableBuffs,
		InterfaceOptionsBuffsPanelConsolidateBuffs,
		InterfaceOptionsBuffsPanelShowAllEnemyDebuffs,
		InterfaceOptionsCameraPanelFollowTerrain,
		InterfaceOptionsCameraPanelHeadBob,
		InterfaceOptionsCameraPanelWaterCollision,
		InterfaceOptionsCameraPanelSmartPivot,
		InterfaceOptionsMousePanelInvertMouse,
		InterfaceOptionsMousePanelClickToMove,
		InterfaceOptionsMousePanelWoWMouse,
		InterfaceOptionsHelpPanelShowTutorials,
		InterfaceOptionsHelpPanelLoadingScreenTips,
		InterfaceOptionsHelpPanelEnhancedTooltips,
		InterfaceOptionsHelpPanelBeginnerTooltips,
		InterfaceOptionsHelpPanelShowLuaErrors,
		InterfaceOptionsHelpPanelColorblindMode,
		InterfaceOptionsHelpPanelMovePad,
		InterfaceOptionsControlsPanelBlockChatChannelInvites,
		InterfaceOptionsControlsPanelAutoOpenLootHistory,
		InterfaceOptionsCombatPanelEnemyCastBarsOnOnlyTargetNameplates,
		InterfaceOptionsCombatPanelEnemyCastBarsNameplateSpellNames,
		InterfaceOptionsCombatPanelLossOfControl,
		InterfaceOptionsDisplayPanelShowAccountAchievments,
		InterfaceOptionsNamesPanelUnitNameplatesNameplateClassColors,
		InterfaceOptionsCombatTextPanelHealingAbsorbTarget,
		InterfaceOptionsCombatTextPanelHealingAbsorbSelf,
		NetworkOptionsPanelAdvancedCombatLogging,
		AudioOptionsSoundPanelPetBattleMusic,
	}

	local Sliders = {
		Graphics_Quality,
		Advanced_MaxFPSSlider,
		Advanced_UIScaleSlider,
		Advanced_MaxFPSBKSlider,
		Advanced_GammaSlider,
		AudioOptionsSoundPanelSoundQuality,
		AudioOptionsSoundPanelAmbienceVolume,
		AudioOptionsSoundPanelMusicVolume,
		AudioOptionsSoundPanelSoundVolume,
		AudioOptionsSoundPanelMasterVolume,
		InterfaceOptionsCombatPanelSpellAlertOpacitySlider,
		InterfaceOptionsCombatPanelMaxSpellStartRecoveryOffset,
		CompactUnitFrameProfilesGeneralOptionsFrameHeightSlider,
		CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider,
		InterfaceOptionsCameraPanelMaxDistanceSlider,
		InterfaceOptionsCameraPanelFollowSpeedSlider,
		InterfaceOptionsMousePanelMouseSensitivitySlider,
		InterfaceOptionsMousePanelMouseLookSpeedSlider
	}

	local Scrollbars = {
		InterfaceOptionsFrameCategoriesListScrollBar,
		InterfaceOptionsFrameAddOnsListScrollBar,
		ChatConfigCombatSettingsFiltersScrollFrameScrollBar
	}

	local Strip = {
		Graphics_RightQuality,
		InterfaceOptionsFrameCategoriesList,
		InterfaceOptionsFrameAddOnsList,
		ChatConfigCombatSettingsFiltersScrollFrame,
		CombatConfigColorsHighlighting,
		CombatConfigColorsColorizeUnitName,
		CombatConfigColorsColorizeSpellNames,
		CombatConfigColorsColorizeDamageNumber,
		CombatConfigColorsColorizeDamageSchool,
		CombatConfigColorsColorizeEntireLine
	}

	local StripBackdrops = {
		VideoOptionsFrameCategoryFrame,
		VideoOptionsFramePanelContainer,
		AudioOptionsSoundPanelVolume,
		AudioOptionsSoundPanelHardware,
		AudioOptionsSoundPanelPlayback,
		InterfaceOptionsFrameCategories,
		InterfaceOptionsFramePanelContainer,
		InterfaceOptionsFrameAddOns
	}

	for _, Frame in pairs(StripBackdrops) do
		Frame:StripTextures()
		Frame:CreateBackdrop("Transparent")
	end
	for _, Frame in pairs(Strip) do
		Frame:StripTextures()
	end
	for _, Button in pairs(Buttons) do
		S:HandleButton(Button, true)
	end
	for _, DropDown in pairs(DropDowns) do
		S:HandleDropDownBox(DropDown)
	end
	for _, CheckBox in pairs(CheckBoxes) do
		S:HandleCheckBox(CheckBox)
	end
	for _, Slider in pairs(Sliders) do
		S:HandleSliderFrame(Slider)
	end
	for _, Scrollbar in pairs(Scrollbars) do
		S:HandleScrollBar(Scrollbar)
	end

	-- Reposition Buttons
	VideoOptionsFrameCancel:ClearAllPoints()
	VideoOptionsFrameCancel:Point("RIGHT", VideoOptionsFrameApply, "LEFT", -4, 0)

	VideoOptionsFrameOkay:ClearAllPoints()
	VideoOptionsFrameOkay:Point("RIGHT", VideoOptionsFrameCancel, "LEFT", -4, 0)

	InterfaceOptionsFrameOkay:ClearAllPoints()
	InterfaceOptionsFrameOkay:Point("RIGHT", InterfaceOptionsFrameCancel, "LEFT", -4, 0)

	-- Chat Config
	ChatConfigCategoryFrame:SetTemplate("Transparent")
	ChatConfigBackgroundFrame:SetTemplate("Transparent")
	ChatConfigChatSettingsClassColorLegend:SetTemplate("Transparent")
	ChatConfigChannelSettingsClassColorLegend:SetTemplate("Transparent")
	ChatConfigCombatSettingsFilters:SetTemplate("Transparent")

	ChatConfigCombatSettingsFiltersScrollFrameScrollBarBorder:Kill()

	ChatConfigCombatSettingsFiltersDeleteButton:Point("TOPRIGHT", ChatConfigCombatSettingsFilters, "BOTTOMRIGHT", 0, -1)
	ChatConfigCombatSettingsFiltersAddFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)
	ChatConfigCombatSettingsFiltersCopyFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)

	S:HandleNextPrevButton(ChatConfigMoveFilterUpButton)
	ChatConfigMoveFilterUpButton:Size(26)
	ChatConfigMoveFilterUpButton:Point("TOPLEFT", ChatConfigCombatSettingsFilters, "BOTTOMLEFT", 3, -1)
	ChatConfigMoveFilterUpButton:SetHitRectInsets(0, 0, 0, 0)

	S:HandleNextPrevButton(ChatConfigMoveFilterDownButton)
	ChatConfigMoveFilterDownButton:Size(26)
	ChatConfigMoveFilterDownButton:Point("LEFT", ChatConfigMoveFilterUpButton, "RIGHT", 1, 0)
	ChatConfigMoveFilterDownButton:SetHitRectInsets(0, 0, 0, 0)

	S:HandleColorSwatch(CombatConfigColorsColorizeSpellNamesColorSwatch)
	S:HandleColorSwatch(CombatConfigColorsColorizeDamageNumberColorSwatch)

	S:HandleEditBox(CombatConfigSettingsNameEditBox)

	S:HandleRadioButton(CombatConfigColorsColorizeEntireLineBySource)
	S:HandleRadioButton(CombatConfigColorsColorizeEntireLineByTarget)

	for i = 1, 5 do
		local tab = _G["CombatConfigTab"..i]

		tab:StripTextures()
		tab:CreateBackdrop("Default", true)
		tab.backdrop:Point("TOPLEFT", 1, -10)
		tab.backdrop:Point("BOTTOMRIGHT", -1, 2)

		tab:HookScript("OnEnter", S.SetModifiedBackdrop)
		tab:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	ChatConfigFrameDefaultButton:Point("BOTTOMLEFT", 12, 8)
	ChatConfigFrameDefaultButton:Width(125)

	ChatConfigFrameCancelButton:Point("BOTTOMRIGHT", -11, 8)
	ChatConfigFrameOkayButton:Point("RIGHT", ChatConfigFrameCancelButton, "RIGHT", 0, 0)

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
		elseif checkBoxTemplate == "ChatConfigCheckBoxWithSwatchTemplate" or checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate" then
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

					if checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate" then
						S:HandleCheckBox(_G[checkBoxName.."ColorClasses"])
					end

					S:HandleColorSwatch(_G[checkBoxName.."ColorSwatch"])
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

			if not swatch.backdrop then
				swatch:StripTextures()
				swatch:CreateBackdrop()
				swatch.backdrop:Point("TOPLEFT", 3, -1)
				swatch.backdrop:Point("BOTTOMRIGHT", -3, 1)
				swatch.backdrop:SetFrameLevel(swatch:GetParent():GetFrameLevel() + 1)

				S:HandleColorSwatch(_G[swatchName.."ColorSwatch"])
			end
		end
	end)
end

S:AddCallback("SkinBlizzard", LoadSkin)