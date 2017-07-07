local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local ipairs, unpack = ipairs, unpack;
local find = string.find;

local UnitIsUnit = UnitIsUnit;
local IsAddOnLoaded = IsAddOnLoaded;
local IsShiftKeyDown = IsShiftKeyDown;
local SquareButton_SetIcon = SquareButton_SetIcon
local UIDROPDOWNMENU_MAXLEVELS = UIDROPDOWNMENU_MAXLEVELS;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true) or (E.private.skins.blizzard.misc ~= true) then return; end

	-- ESC/Menu Buttons
	local BlizzardMenuButtons = {
		"Options",
		"UIOptions",
		"Keybindings",
		"Macros",
		"AddOns",
		"Logout",
		"Store",
		"Quit",
		"Continue",
		"Help"
	};

	for i = 1, #BlizzardMenuButtons do
		local ElvuiMenuButtons = _G["GameMenuButton"..BlizzardMenuButtons[i]];
		if(ElvuiMenuButtons) then
			S:HandleButton(ElvuiMenuButtons);
		end
	end
	
	if(IsAddOnLoaded("OptionHouse")) then
		S:HandleButton(GameMenuButtonOptionHouse);
	end

	-- Static Popups
	for i = 1, 4 do
		local staticPopup = _G["StaticPopup"..i];
		local itemFrame = _G["StaticPopup"..i.."ItemFrame"];
		local itemFrameBox = _G["StaticPopup"..i.."EditBox"];
		local itemFrameTexture = _G["StaticPopup"..i.."ItemFrameIconTexture"];
		local itemFrameNormal = _G["StaticPopup"..i.."ItemFrameNormalTexture"];
		local itemFrameName = _G["StaticPopup"..i.."ItemFrameNameFrame"];
		local closeButton = _G["StaticPopup"..i.."CloseButton"];

		staticPopup:SetTemplate("Transparent");

		S:HandleEditBox(itemFrameBox);
		itemFrameBox.backdrop:Point("TOPLEFT", -2, -4);
		itemFrameBox.backdrop:Point("BOTTOMRIGHT", 2, 4);

		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameGold"]);
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameSilver"]);
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameCopper"]);

		closeButton:StripTextures();
		S:HandleCloseButton(closeButton);

		itemFrame:GetNormalTexture():Kill();
		itemFrame:SetTemplate();
		itemFrame:StyleButton();

		itemFrameTexture:SetTexCoord(unpack(E.TexCoords));
		itemFrameTexture:SetInside();

		itemFrameNormal:SetAlpha(0);

		itemFrameName:Kill();

		for j = 1, 3 do
			S:HandleButton(_G["StaticPopup"..i.."Button"..j]);
		end
	end

	-- Return to Graveyard Button
	do
		S:HandleButton(GhostFrame)
		GhostFrame:SetBackdropColor(0, 0, 0, 0)
		GhostFrame:SetBackdropBorderColor(0, 0, 0, 0)
		GhostFrame:ClearAllPoints()
		GhostFrame:Point("TOP", E.UIParent, "TOP", 0, -270)

		local function forceBackdropColor(self, r, g, b, a)
			if(r ~= 0 or g ~= 0 or b ~= 0 or a ~= 0) then
				self:SetBackdropColor(0, 0, 0, 0)
				self:SetBackdropBorderColor(0, 0, 0, 0)
			end
		end

		hooksecurefunc(GhostFrame, "SetBackdropColor", forceBackdropColor)
		hooksecurefunc(GhostFrame, "SetBackdropBorderColor", forceBackdropColor)

		S:HandleButton(GhostFrameContentsFrame)
		GhostFrameContentsFrameIcon:SetTexture(nil)

		local x = CreateFrame("Frame", nil, GhostFrame)
		x:SetFrameStrata("MEDIUM")
		x:SetTemplate("Default")
		x:SetOutside(GhostFrameContentsFrameIcon)

		local tex = x:CreateTexture(nil, "OVERLAY")
		tex:SetTexture("Interface\\Icons\\spell_holy_guardianspirit")
		tex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		tex:SetInside()
	end

	-- Other Frames
	TicketStatusFrameButton:SetTemplate("Transparent");

	AutoCompleteBox:SetTemplate("Transparent");

	ConsolidatedBuffsTooltip:SetTemplate("Transparent");

	StreamingIcon:ClearAllPoints()
	StreamingIcon:Point("TOP", UIParent, "TOP", 0, -100)

	-- BNToast Frame
	BNToastFrame:SetTemplate("Transparent");

	BNToastFrameCloseButton:Size(32);
	BNToastFrameCloseButton:Point("TOPRIGHT", "BNToastFrame", 4, 4);

	S:HandleCloseButton(BNToastFrameCloseButton);

	-- ReadyCheck Frame
	ReadyCheckFrame:SetTemplate("Transparent");
	ReadyCheckFrame:Size(290, 85);

	S:HandleButton(ReadyCheckFrameYesButton);
	ReadyCheckFrameYesButton:ClearAllPoints();
	ReadyCheckFrameYesButton:Point("LEFT", ReadyCheckFrame, 15, -20);
	ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame);

	S:HandleButton(ReadyCheckFrameNoButton);
	ReadyCheckFrameNoButton:ClearAllPoints();
	ReadyCheckFrameNoButton:Point("RIGHT", ReadyCheckFrame, -15, -20);
	ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame);

	ReadyCheckFrameText:ClearAllPoints();
	ReadyCheckFrameText:Point("TOP", 0, -5);
	ReadyCheckFrameText:SetParent(ReadyCheckFrame);
	ReadyCheckFrameText:SetTextColor(1, 1, 1);

	ReadyCheckListenerFrame:SetAlpha(0);

	ReadyCheckFrame:HookScript("OnShow", function(self) -- bug fix, don't show it if initiator
		if(UnitIsUnit("player", self.initiator)) then
			self:Hide();
		end
	end)

	-- Coin PickUp Frame
	CoinPickupFrame:StripTextures();
	CoinPickupFrame:SetTemplate("Transparent");

	S:HandleButton(CoinPickupOkayButton);
	S:HandleButton(CoinPickupCancelButton);

	-- BattleTag Frame
	BattleTagInviteFrame:StripTextures();
	BattleTagInviteFrame:SetTemplate("Transparent");
	S:HandleEditBox(BattleTagInviteFrameScrollFrame)
	for i = 1, BattleTagInviteFrame:GetNumChildren() do
		local child = select(i, BattleTagInviteFrame:GetChildren());
		if(child:GetObjectType() == "Button") then
			S:HandleButton(child);
		end
	end

	-- Stack Split Frame
	StackSplitFrame:SetTemplate("Transparent");
	StackSplitFrame:GetRegions():Hide();

	S:HandleButton(StackSplitOkayButton);
	S:HandleButton(StackSplitCancelButton);

	-- Opacity Frame
	OpacityFrame:StripTextures();
	OpacityFrame:SetTemplate("Transparent");

	S:HandleSliderFrame(OpacityFrameSlider);

	-- Declension frame
	if(GetLocale() == "ruRU") then
		DeclensionFrame:SetTemplate("Transparent");

		S:HandleNextPrevButton(DeclensionFrameSetPrev);
		S:HandleNextPrevButton(DeclensionFrameSetNext);
		S:HandleButton(DeclensionFrameOkayButton);
		S:HandleButton(DeclensionFrameCancelButton);

		for i = 1, RUSSIAN_DECLENSION_PATTERNS do
			local editBox = _G["DeclensionFrameDeclension"..i.."Edit"];
			if(editBox) then
				editBox:StripTextures();
				S:HandleEditBox(editBox);
			end
		end
	end

	-- PvP Ready Dialog
	PVPReadyDialog:StripTextures();
	PVPReadyDialog:SetTemplate("Transparent");

	PVPReadyDialog.SetBackdrop = E.noop;
	PVPReadyDialog.filigree:SetAlpha(0);
	PVPReadyDialog.bottomArt:SetAlpha(0);

	PVPReadyDialogBackground:Kill();

	S:HandleButton(PVPReadyDialogEnterBattleButton);
	S:HandleButton(PVPReadyDialogLeaveQueueButton);

	S:HandleCloseButton(PVPReadyDialogCloseButton);

	PVPReadyDialogRoleIcon:StripTextures();
	PVPReadyDialogRoleIcon:CreateBackdrop();
	PVPReadyDialogRoleIcon.backdrop:Point("TOPLEFT", 7, -7);
	PVPReadyDialogRoleIcon.backdrop:Point("BOTTOMRIGHT", -7, 7);

	hooksecurefunc("PVPReadyDialog_Display", function(self, _, _, _, queueType, _, role)
		if(role == "DAMAGER") then
			self.roleIcon.texture:SetTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01");
		elseif(role == "TANK") then
			self.roleIcon.texture:SetTexture("Interface\\Icons\\Ability_Defend");
		elseif(role == "HEALER") then
			self.roleIcon.texture:SetTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH");
		end

		self.roleIcon.texture:SetTexCoord(unpack(E.TexCoords));
		self.roleIcon.texture:SetInside(self.roleIcon.backdrop);
		self.roleIcon.texture:SetParent(self.roleIcon.backdrop)

		if(queueType == "ARENA") then
			self:Height(100)
		end
	end)

	-- Role Check Popup
	RolePollPopup:SetTemplate("Transparent")

	S:HandleCloseButton(RolePollPopupCloseButton)

	S:HandleButton(RolePollPopupAcceptButton)

	local roleCheckIcons = {
		"RolePollPopupRoleButtonTank",
		"RolePollPopupRoleButtonHealer",
		"RolePollPopupRoleButtonDPS"
	}

	for i = 1, #roleCheckIcons do
		_G[roleCheckIcons[i]]:StripTextures()
		_G[roleCheckIcons[i]]:CreateBackdrop()
		_G[roleCheckIcons[i]].backdrop:Point("TOPLEFT", 7, -7)
		_G[roleCheckIcons[i]].backdrop:Point("BOTTOMRIGHT", -7, 7)

		_G[roleCheckIcons[i]].icon = _G[roleCheckIcons[i]]:CreateTexture(nil, "ARTWORK")
		_G[roleCheckIcons[i]].icon:SetTexCoord(unpack(E.TexCoords))
		_G[roleCheckIcons[i]].icon:SetInside(_G[roleCheckIcons[i]].backdrop)
	end

	RolePollPopupRoleButtonTank:Point("TOPLEFT", 32, -35)

	RolePollPopupRoleButtonTank.icon:SetTexture("Interface\\Icons\\Ability_Defend")
	RolePollPopupRoleButtonHealer.icon:SetTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")
	RolePollPopupRoleButtonDPS.icon:SetTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")

	hooksecurefunc("RolePollPopup_Show", function(self)
		local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles("player")
		if canBeTank then
			RolePollPopupRoleButtonTank.icon:SetDesaturated(false)
		else
			RolePollPopupRoleButtonTank.icon:SetDesaturated(true)
		end
		if canBeHealer then
			RolePollPopupRoleButtonHealer.icon:SetDesaturated(false)
		else
			RolePollPopupRoleButtonHealer.icon:SetDesaturated(true)
		end
		if canBeDamager then
			RolePollPopupRoleButtonDPS.icon:SetDesaturated(false)
		else
			RolePollPopupRoleButtonDPS.icon:SetDesaturated(true)
		end
	end)

	-- Guild Invitation PopUp Frame
	GuildInviteFrame:SetTemplate("Transparent");
	GuildInviteFrameBg:Kill();
	GuildInviteFrameTopLeftCorner:Kill();
	GuildInviteFrameTopRightCorner:Kill();
	GuildInviteFrameBottomLeftCorner:Kill();
	GuildInviteFrameBottomRightCorner:Kill();
	GuildInviteFrameTopBorder:Kill();
	GuildInviteFrameBottomBorder:Kill();
	GuildInviteFrameLeftBorder:Kill();
	GuildInviteFrameRightBorder:Kill();
	GuildInviteFrameBackground:Kill();
	GuildInviteFrameTabardRing:Kill();
	GuildInviteFrameLevel:StripTextures();

	S:HandleButton(GuildInviteFrameJoinButton);
	S:HandleButton(GuildInviteFrameDeclineButton);

	-- Report Player
	ReportCheatingDialog:StripTextures();
	ReportCheatingDialog:SetTemplate("Transparent");

	ReportCheatingDialogCommentFrame:StripTextures();

	S:HandleEditBox(ReportCheatingDialogCommentFrameEditBox);
	S:HandleButton(ReportCheatingDialogReportButton);
	S:HandleButton(ReportCheatingDialogCancelButton);

	ReportPlayerNameDialog:StripTextures();
	ReportPlayerNameDialog:SetTemplate("Transparent");

	ReportPlayerNameDialogCommentFrame:StripTextures();

	S:HandleEditBox(ReportPlayerNameDialogCommentFrameEditBox);
	S:HandleButton(ReportPlayerNameDialogCancelButton);
	S:HandleButton(ReportPlayerNameDialogReportButton);

	-- Cinematic Popup
	CinematicFrameCloseDialog:StripTextures();
	CinematicFrameCloseDialog:SetTemplate("Transparent");

	CinematicFrameCloseDialog:SetScale(UIParent:GetScale());

	S:HandleButton(CinematicFrameCloseDialogConfirmButton);
	S:HandleButton(CinematicFrameCloseDialogResumeButton);

	-- Movie Frame Popup
	MovieFrame.CloseDialog:StripTextures();
	MovieFrame.CloseDialog:SetTemplate("Transparent");

	MovieFrame.CloseDialog:SetScale(UIParent:GetScale())

	S:HandleButton(MovieFrame.CloseDialog.ConfirmButton)
	S:HandleButton(MovieFrame.CloseDialog.ResumeButton)

	-- Level Up Popup
	LevelUpDisplaySpellFrameIcon:SetTexCoord(unpack(E.TexCoords));
	LevelUpDisplaySpellFrameSubIcon:SetTexCoord(unpack(E.TexCoords));

	-- Channel Pullout Frame
	ChannelPullout:StripTextures()
	ChannelPullout:SetTemplate("Transparent")

	ChannelPulloutBackground:Kill()

	S:HandleTab(ChannelPulloutTab)
	ChannelPulloutTab:Size(107, 26)
	ChannelPulloutTabText:Point("LEFT", ChannelPulloutTabLeft, "RIGHT", 0, 0)

	S:HandleCloseButton(ChannelPulloutCloseButton)

	-- Dropdown Menu
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function()
		for i = 1, UIDROPDOWNMENU_MAXLEVELS do
			_G["DropDownList"..i.."Backdrop"]:SetTemplate("Transparent", true);
			_G["DropDownList"..i.."MenuBackdrop"]:SetTemplate("Transparent", true);
			for j = 1, UIDROPDOWNMENU_MAXBUTTONS do
				_G["DropDownList"..i.."Button"..j.."Highlight"]:SetTexture(1, 1, 1, 0.3);
			end
		end
	end)

	-- Compact Raid Frame Manager
	CompactRaidFrameManager:StripTextures();
	CompactRaidFrameManager:SetTemplate("Transparent");

	CompactRaidFrameManagerDisplayFrame:StripTextures();
	CompactRaidFrameManagerDisplayFrameFilterOptions:StripTextures();

	S:HandleButton(CompactRaidFrameManagerDisplayFrameHiddenModeToggle);
	S:HandleButton(CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll);
	S:HandleButton(CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck);
	S:HandleButton(CompactRaidFrameManagerDisplayFrameLockedModeToggle);
	S:HandleButton(CompactRaidFrameManagerDisplayFrameConvertToRaid);
	S:HandleButton(CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleDamager);
	S:HandleButton(CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleHealer);
	S:HandleButton(CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleTank);
	S:HandleButton(CompactRaidFrameManagerToggleButton)

	S:HandleCheckBox(CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton);

	S:HandleDropDownBox(CompactRaidFrameManagerDisplayFrameProfileSelector);

	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleTankSelectedHighlight:SetTexture(1, 1, 0, 0.3);
	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleHealerSelectedHighlight:SetTexture(1, 1, 0, 0.3);
	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleDamagerSelectedHighlight:SetTexture(1, 1, 0, 0.3);

	for i = 1, 8 do
		S:HandleButton(_G["CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup"..i]);
		_G["CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup"..i.."SelectedHighlight"]:SetTexture(1, 1, 0, 0.3);
	end

	CompactRaidFrameManagerToggleButton:Size(15, 40);
	CompactRaidFrameManagerToggleButton:Point("RIGHT", -3, -15);

	CompactRaidFrameManagerToggleButton.icon = CompactRaidFrameManagerToggleButton:CreateTexture(nil, "ARTWORK");
	CompactRaidFrameManagerToggleButton.icon:Size(14);
	CompactRaidFrameManagerToggleButton.icon:Point("CENTER");
	CompactRaidFrameManagerToggleButton.icon:SetTexture([[Interface\Buttons\SquareButtonTextures]])
	SquareButton_SetIcon(CompactRaidFrameManagerToggleButton, "RIGHT");

	hooksecurefunc("CompactRaidFrameManager_Expand", function()
		SquareButton_SetIcon(CompactRaidFrameManagerToggleButton, "LEFT");
	end)

	hooksecurefunc("CompactRaidFrameManager_Collapse", function()
		SquareButton_SetIcon(CompactRaidFrameManagerToggleButton, "RIGHT");
	end)

	-- Options/Interface Buttons Position
	VideoOptionsFrameCancel:ClearAllPoints();
	VideoOptionsFrameCancel:Point("RIGHT", VideoOptionsFrameApply, "LEFT", -4, 0);

	VideoOptionsFrameOkay:ClearAllPoints();
	VideoOptionsFrameOkay:Point("RIGHT", VideoOptionsFrameCancel, "LEFT", -4, 0);

	InterfaceOptionsFrameOkay:ClearAllPoints();
	InterfaceOptionsFrameOkay:Point("RIGHT", InterfaceOptionsFrameCancel, "LEFT", -4, 0);

	-- Game Menu Options/Frames
	GameMenuFrame:StripTextures();
	GameMenuFrame:CreateBackdrop("Transparent");

	InterfaceOptionsFrame:StripTextures();
	InterfaceOptionsFrame:CreateBackdrop("Transparent");

	S:HandleButton(InterfaceOptionsFrameDefaults);
	S:HandleButton(InterfaceOptionsFrameOkay);
	S:HandleButton(InterfaceOptionsFrameCancel);

	VideoOptionsFrame:StripTextures();
	VideoOptionsFrame:CreateBackdrop("Transparent");

	VideoOptionsFrameCategoryFrame:StripTextures();
	VideoOptionsFrameCategoryFrame:CreateBackdrop("Transparent");

	VideoOptionsFramePanelContainer:StripTextures();
	VideoOptionsFramePanelContainer:CreateBackdrop("Transparent");

	S:HandleButton(VideoOptionsFrameOkay);
	S:HandleButton(VideoOptionsFrameCancel);
	S:HandleButton(VideoOptionsFrameDefaults);
	S:HandleButton(VideoOptionsFrameApply);

	-- Game Menu Options/Graphics
	Graphics_RightQuality:StripTextures();
	S:HandleSliderFrame(Graphics_Quality);

	S:HandleDropDownBox(Graphics_DisplayModeDropDown);
	S:HandleDropDownBox(Graphics_ResolutionDropDown);
	S:HandleDropDownBox(Graphics_RefreshDropDown);
	S:HandleDropDownBox(Graphics_PrimaryMonitorDropDown);
	S:HandleDropDownBox(Graphics_MultiSampleDropDown);
	S:HandleDropDownBox(Graphics_VerticalSyncDropDown);
	S:HandleDropDownBox(Graphics_TextureResolutionDropDown);
	S:HandleDropDownBox(Graphics_FilteringDropDown);
	S:HandleDropDownBox(Graphics_ProjectedTexturesDropDown);
	S:HandleDropDownBox(Graphics_ViewDistanceDropDown);
	S:HandleDropDownBox(Graphics_EnvironmentalDetailDropDown);
	S:HandleDropDownBox(Graphics_GroundClutterDropDown);
	S:HandleDropDownBox(Graphics_ShadowsDropDown);
	S:HandleDropDownBox(Graphics_LiquidDetailDropDown);
	S:HandleDropDownBox(Graphics_SunshaftsDropDown);
	S:HandleDropDownBox(Graphics_ParticleDensityDropDown);
	S:HandleDropDownBox(Graphics_SSAODropDown);

	-- Game Menu Options/Advanced
	S:HandleDropDownBox(Advanced_BufferingDropDown);
	S:HandleDropDownBox(Advanced_LagDropDown);
	S:HandleDropDownBox(Advanced_HardwareCursorDropDown);
	S:HandleDropDownBox(Advanced_GraphicsAPIDropDown);

	S:HandleCheckBox(Advanced_MaxFPSCheckBox);
	S:HandleCheckBox(Advanced_MaxFPSBKCheckBox);
	S:HandleCheckBox(Advanced_UseUIScale);
	S:HandleCheckBox(Advanced_DesktopGamma);

	S:HandleSliderFrame(Advanced_MaxFPSSlider);
	S:HandleSliderFrame(Advanced_UIScaleSlider);
	S:HandleSliderFrame(Advanced_MaxFPSBKSlider);
	S:HandleSliderFrame(Advanced_GammaSlider);

	-- Game Menu Options/Network
	S:HandleCheckBox(NetworkOptionsPanelOptimizeSpeed);
	S:HandleCheckBox(NetworkOptionsPanelUseIPv6);
	S:HandleCheckBox(NetworkOptionsPanelAdvancedCombatLogging);

	-- Game Menu Options/Languages
	S:HandleDropDownBox(InterfaceOptionsLanguagesPanelLocaleDropDown);

	-- Game Menu Options/Sound
	S:HandleCheckBox(AudioOptionsSoundPanelEnableSound);
	S:HandleCheckBox(AudioOptionsSoundPanelSoundEffects);
	S:HandleCheckBox(AudioOptionsSoundPanelErrorSpeech);
	S:HandleCheckBox(AudioOptionsSoundPanelEmoteSounds);
	S:HandleCheckBox(AudioOptionsSoundPanelPetSounds);
	S:HandleCheckBox(AudioOptionsSoundPanelMusic);
	S:HandleCheckBox(AudioOptionsSoundPanelLoopMusic);
	S:HandleCheckBox(AudioOptionsSoundPanelAmbientSounds);
	S:HandleCheckBox(AudioOptionsSoundPanelSoundInBG);
	S:HandleCheckBox(AudioOptionsSoundPanelPetBattleMusic);
	S:HandleCheckBox(AudioOptionsSoundPanelReverb);
	S:HandleCheckBox(AudioOptionsSoundPanelHRTF);
	S:HandleCheckBox(AudioOptionsSoundPanelEnableDSPs);

	S:HandleSliderFrame(AudioOptionsSoundPanelSoundQuality);
	S:HandleSliderFrame(AudioOptionsSoundPanelAmbienceVolume);
	S:HandleSliderFrame(AudioOptionsSoundPanelMusicVolume);
	S:HandleSliderFrame(AudioOptionsSoundPanelSoundVolume);
	S:HandleSliderFrame(AudioOptionsSoundPanelMasterVolume);

	S:HandleDropDownBox(AudioOptionsSoundPanelHardwareDropDown);
	S:HandleDropDownBox(AudioOptionsSoundPanelSoundChannelsDropDown);

	AudioOptionsSoundPanelVolume:StripTextures();
	AudioOptionsSoundPanelVolume:CreateBackdrop("Transparent");

	AudioOptionsSoundPanelHardware:StripTextures();
	AudioOptionsSoundPanelHardware:CreateBackdrop("Transparent");

	AudioOptionsSoundPanelPlayback:StripTextures();
	AudioOptionsSoundPanelPlayback:CreateBackdrop("Transparent");

	-- Game Menu Interface
	InterfaceOptionsFrameCategories:StripTextures();
	InterfaceOptionsFrameCategories:CreateBackdrop("Transparent");

	InterfaceOptionsFramePanelContainer:StripTextures();
	InterfaceOptionsFramePanelContainer:CreateBackdrop("Transparent");

	InterfaceOptionsFrameAddOns:StripTextures();
	InterfaceOptionsFrameAddOns:CreateBackdrop("Transparent");

	InterfaceOptionsFrameCategoriesList:StripTextures();
	S:HandleScrollBar(InterfaceOptionsFrameCategoriesListScrollBar);

	InterfaceOptionsFrameAddOnsList:StripTextures();
	S:HandleScrollBar(InterfaceOptionsFrameAddOnsListScrollBar);

	-- Game Menu Interface/Tabs
	for i = 1, 2 do
		local tab = _G["InterfaceOptionsFrameTab" .. i];

		S:HandleTab(tab);
		tab:StripTextures();
	end

	local maxButtons = (InterfaceOptionsFrameAddOns:GetHeight() - 8) / InterfaceOptionsFrameAddOns.buttonHeight;
	for i = 1, maxButtons do
		local buttonToggle = _G["InterfaceOptionsFrameAddOnsButton" .. i .. "Toggle"];
		buttonToggle:SetNormalTexture("");
		buttonToggle.SetNormalTexture = E.noop;
		buttonToggle:SetPushedTexture("");
		buttonToggle.SetPushedTexture = E.noop;
		buttonToggle:SetHighlightTexture(nil);

		buttonToggle.Text = buttonToggle:CreateFontString(nil, "OVERLAY");
		buttonToggle.Text:FontTemplate(nil, 22);
		buttonToggle.Text:Point("CENTER");
		buttonToggle.Text:SetText("+");

		hooksecurefunc(buttonToggle, "SetNormalTexture", function(self, texture)
			if(find(texture, "MinusButton")) then
				self.Text:SetText("-");
			else
				self.Text:SetText("+");
			end
		end);
	end

	-- Game Menu Interface/Controls
	S:HandleCheckBox(InterfaceOptionsControlsPanelStickyTargeting);
	S:HandleCheckBox(InterfaceOptionsControlsPanelAutoDismount);
	S:HandleCheckBox(InterfaceOptionsControlsPanelAutoClearAFK);
	S:HandleCheckBox(InterfaceOptionsControlsPanelBlockTrades);
	S:HandleCheckBox(InterfaceOptionsControlsPanelBlockGuildInvites);
	S:HandleCheckBox(InterfaceOptionsControlsPanelLootAtMouse);
	S:HandleCheckBox(InterfaceOptionsControlsPanelAutoLootCorpse);
	S:HandleCheckBox(InterfaceOptionsControlsPanelInteractOnLeftClick);
	S:HandleCheckBox(InterfaceOptionsControlsPanelBlockChatChannelInvites)
	S:HandleCheckBox(InterfaceOptionsControlsPanelAutoOpenLootHistory)

	S:HandleDropDownBox(InterfaceOptionsControlsPanelAutoLootKeyDropDown);

	-- Game Menu Interface/Combat
	S:HandleCheckBox(InterfaceOptionsCombatPanelAttackOnAssist);
	S:HandleCheckBox(InterfaceOptionsCombatPanelStopAutoAttack);
	S:HandleCheckBox(InterfaceOptionsCombatPanelTargetOfTarget);
	S:HandleCheckBox(InterfaceOptionsCombatPanelShowSpellAlerts);
	S:HandleCheckBox(InterfaceOptionsCombatPanelReducedLagTolerance);
	S:HandleCheckBox(InterfaceOptionsCombatPanelActionButtonUseKeyDown);
	S:HandleCheckBox(InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait);
	S:HandleCheckBox(InterfaceOptionsCombatPanelEnemyCastBarsOnNameplates);
	S:HandleCheckBox(InterfaceOptionsCombatPanelAutoSelfCast);
	S:HandleCheckBox(InterfaceOptionsCombatPanelEnemyCastBarsOnOnlyTargetNameplates);
	S:HandleCheckBox(InterfaceOptionsCombatPanelEnemyCastBarsNameplateSpellNames);
	S:HandleCheckBox(InterfaceOptionsCombatPanelLossOfControl);

	S:HandleDropDownBox(InterfaceOptionsCombatPanelFocusCastKeyDropDown);
	S:HandleDropDownBox(InterfaceOptionsCombatPanelSelfCastKeyDropDown);

	S:HandleDropDownBox(InterfaceOptionsCombatPanelLossOfControlFullDropDown);
	S:HandleDropDownBox(InterfaceOptionsCombatPanelLossOfControlSilenceDropDown);
	S:HandleDropDownBox(InterfaceOptionsCombatPanelLossOfControlInterruptDropDown);
	S:HandleDropDownBox(InterfaceOptionsCombatPanelLossOfControlDisarmDropDown);
	S:HandleDropDownBox(InterfaceOptionsCombatPanelLossOfControlRootDropDown);

	S:HandleSliderFrame(InterfaceOptionsCombatPanelSpellAlertOpacitySlider);
	S:HandleSliderFrame(InterfaceOptionsCombatPanelMaxSpellStartRecoveryOffset);

	-- Game Menu Interface/Display
	S:HandleCheckBox(InterfaceOptionsDisplayPanelShowCloak);
	S:HandleCheckBox(InterfaceOptionsDisplayPanelShowHelm);
	S:HandleCheckBox(InterfaceOptionsDisplayPanelShowAggroPercentage);
	S:HandleCheckBox(InterfaceOptionsDisplayPanelPlayAggroSounds);
	S:HandleCheckBox(InterfaceOptionsDisplayPanelShowSpellPointsAvg);
	S:HandleCheckBox(InterfaceOptionsDisplayPanelRotateMinimap);
	S:HandleCheckBox(InterfaceOptionsDisplayPanelCinematicSubtitles);
	S:HandleCheckBox(InterfaceOptionsDisplayPanelShowFreeBagSpace);
	S:HandleCheckBox(InterfaceOptionsDisplayPanelShowAccountAchievments)

	-- Game Menu Interface/Objectives
	S:HandleCheckBox(InterfaceOptionsObjectivesPanelAutoQuestTracking);
	S:HandleCheckBox(InterfaceOptionsObjectivesPanelMapQuestDifficulty);
	S:HandleCheckBox(InterfaceOptionsObjectivesPanelWatchFrameWidth);

	-- Game Menu Interface/Social
	S:HandleCheckBox(InterfaceOptionsSocialPanelProfanityFilter);
	S:HandleCheckBox(InterfaceOptionsSocialPanelSpamFilter);
	S:HandleCheckBox(InterfaceOptionsSocialPanelChatBubbles);
	S:HandleCheckBox(InterfaceOptionsSocialPanelPartyChat);
	S:HandleCheckBox(InterfaceOptionsSocialPanelChatHoverDelay);
	S:HandleCheckBox(InterfaceOptionsSocialPanelGuildMemberAlert);
	S:HandleCheckBox(InterfaceOptionsSocialPanelChatMouseScroll);

	S:HandleDropDownBox(InterfaceOptionsSocialPanelWhisperMode);

	-- Game Menu Interface/Action Bars
	S:HandleCheckBox(InterfaceOptionsActionBarsPanelBottomLeft);
	S:HandleCheckBox(InterfaceOptionsActionBarsPanelBottomRight);
	S:HandleCheckBox(InterfaceOptionsActionBarsPanelRight);
	S:HandleCheckBox(InterfaceOptionsActionBarsPanelRightTwo);
	S:HandleCheckBox(InterfaceOptionsActionBarsPanelLockActionBars);
	S:HandleCheckBox(InterfaceOptionsActionBarsPanelAlwaysShowActionBars);
	S:HandleCheckBox(InterfaceOptionsActionBarsPanelSecureAbilityToggle);

	S:HandleDropDownBox(InterfaceOptionsActionBarsPanelPickupActionKeyDropDown);

	-- Game Menu Interface/Names
	S:HandleCheckBox(InterfaceOptionsNamesPanelGuilds);
	S:HandleCheckBox(InterfaceOptionsNamesPanelGuildTitles);
	S:HandleCheckBox(InterfaceOptionsNamesPanelTitles);
	S:HandleCheckBox(InterfaceOptionsNamesPanelNonCombatCreature);
	S:HandleCheckBox(InterfaceOptionsNamesPanelEnemyPlayerNames);
	S:HandleCheckBox(InterfaceOptionsNamesPanelEnemyPets);
	S:HandleCheckBox(InterfaceOptionsNamesPanelEnemyGuardians);
	S:HandleCheckBox(InterfaceOptionsNamesPanelEnemyTotems);
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesEnemies);
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesEnemyPets);
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesEnemyGuardians);
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesEnemyTotems);
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesFriendlyTotems);
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesFriendlyGuardians);
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesFriendlyPets);
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesFriends);
	S:HandleCheckBox(InterfaceOptionsNamesPanelFriendlyTotems);
	S:HandleCheckBox(InterfaceOptionsNamesPanelFriendlyGuardians);
	S:HandleCheckBox(InterfaceOptionsNamesPanelFriendlyPets);
	S:HandleCheckBox(InterfaceOptionsNamesPanelFriendlyPlayerNames);
	S:HandleCheckBox(InterfaceOptionsNamesPanelMyName);
	S:HandleCheckBox(InterfaceOptionsNamesPanelUnitNameplatesNameplateClassColors);

	S:HandleDropDownBox(InterfaceOptionsNamesPanelNPCNamesDropDown);
	S:HandleDropDownBox(InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown);

	-- Game Menu Interface/Floating Combat Text
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelTargetDamage);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelPeriodicDamage);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelPetDamage);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelHealing);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelEnableFCT);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelDodgeParryMiss);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelDamageReduction);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelRepChanges);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelReactiveAbilities);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelFriendlyHealerNames);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelCombatState);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelAuras);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelHonorGains);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelPeriodicEnergyGains);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelEnergyGains);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelLowManaHealth);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelComboPoints);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelOtherTargetEffects);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelTargetEffects);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelHealingAbsorbTarget);
	S:HandleCheckBox(InterfaceOptionsCombatTextPanelHealingAbsorbSelf);

	S:HandleDropDownBox(InterfaceOptionsCombatTextPanelFCTDropDown);

	-- Game Menu Interface/Status Text
	S:HandleCheckBox(InterfaceOptionsStatusTextPanelPlayer);
	S:HandleCheckBox(InterfaceOptionsStatusTextPanelPet);
	S:HandleCheckBox(InterfaceOptionsStatusTextPanelParty);
	S:HandleCheckBox(InterfaceOptionsStatusTextPanelTarget);
	S:HandleCheckBox(InterfaceOptionsStatusTextPanelAlternateResource);
	S:HandleCheckBox(InterfaceOptionsStatusTextPanelXP);

	S:HandleDropDownBox( InterfaceOptionsStatusTextPanelDisplayDropDown)

	-- Game Menu Interface/Unit Frames
	S:HandleCheckBox(InterfaceOptionsUnitFramePanelPartyPets);
	S:HandleCheckBox(InterfaceOptionsUnitFramePanelArenaEnemyFrames);
	S:HandleCheckBox(InterfaceOptionsUnitFramePanelArenaEnemyCastBar);
	S:HandleCheckBox(InterfaceOptionsUnitFramePanelArenaEnemyPets);
	S:HandleCheckBox(InterfaceOptionsUnitFramePanelFullSizeFocusFrame);

	-- Game Menu Interface/Raid Profiles
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameKeepGroupsTogether);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameHorizontalGroups);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameDisplayIncomingHeals);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameDisplayPowerBar);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameDisplayAggroHighlight);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameUseClassColors);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameDisplayPets);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameDisplayMainTankAndAssist);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameDisplayBorder);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameShowDebuffs);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameDisplayOnlyDispellableDebuffs);
	S:HandleCheckBox(CompactUnitFrameProfilesRaidStylePartyFrames);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate2Players);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate3Players);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate5Players);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate10Players);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate15Players);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate25Players);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate40Players);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec1);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec2);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvP);
	S:HandleCheckBox(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvE);

	S:HandleButton(CompactUnitFrameProfilesSaveButton);
	S:HandleButton(CompactUnitFrameProfilesDeleteButton);
	S:HandleButton(CompactUnitFrameProfilesGeneralOptionsFrameResetPositionButton);

	S:HandleSliderFrame(CompactUnitFrameProfilesGeneralOptionsFrameHeightSlider);
	S:HandleSliderFrame(CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider);

	S:HandleDropDownBox(CompactUnitFrameProfilesGeneralOptionsFrameSortByDropdown);
	S:HandleDropDownBox(CompactUnitFrameProfilesProfileSelector);
	S:HandleDropDownBox(CompactUnitFrameProfilesGeneralOptionsFrameHealthTextDropdown);

	-- Game Menu Interface/Buffs and Debuffs
	S:HandleCheckBox(InterfaceOptionsBuffsPanelDispellableDebuffs);
	S:HandleCheckBox(InterfaceOptionsBuffsPanelCastableBuffs);
	S:HandleCheckBox(InterfaceOptionsBuffsPanelConsolidateBuffs);
	S:HandleCheckBox(InterfaceOptionsBuffsPanelShowAllEnemyDebuffs);

	-- Game Menu Interface/Camera
	S:HandleCheckBox(InterfaceOptionsCameraPanelFollowTerrain);
	S:HandleCheckBox(InterfaceOptionsCameraPanelHeadBob);
	S:HandleCheckBox(InterfaceOptionsCameraPanelWaterCollision);
	S:HandleCheckBox(InterfaceOptionsCameraPanelSmartPivot);

	S:HandleSliderFrame(InterfaceOptionsCameraPanelMaxDistanceSlider);
	S:HandleSliderFrame(InterfaceOptionsCameraPanelFollowSpeedSlider);

	S:HandleDropDownBox(InterfaceOptionsCameraPanelStyleDropDown);

	-- Game Menu Interface/Mouse
	S:HandleCheckBox(InterfaceOptionsMousePanelInvertMouse);
	S:HandleCheckBox(InterfaceOptionsMousePanelClickToMove);
	S:HandleCheckBox(InterfaceOptionsMousePanelWoWMouse);

	S:HandleSliderFrame(InterfaceOptionsMousePanelMouseSensitivitySlider);
	S:HandleSliderFrame(InterfaceOptionsMousePanelMouseLookSpeedSlider);

	S:HandleDropDownBox(InterfaceOptionsMousePanelClickMoveStyleDropDown);

	-- Game Menu Interface/Help
	S:HandleCheckBox(InterfaceOptionsHelpPanelShowTutorials);
	S:HandleCheckBox(InterfaceOptionsHelpPanelEnhancedTooltips);
	S:HandleCheckBox(InterfaceOptionsHelpPanelShowLuaErrors);
	S:HandleCheckBox(InterfaceOptionsHelpPanelColorblindMode);
	S:HandleCheckBox(InterfaceOptionsHelpPanelMovePad);

	S:HandleButton(InterfaceOptionsHelpPanelResetTutorials);

	-- Interface Enable Mouse Move
	InterfaceOptionsFrame:SetClampedToScreen(true);
	InterfaceOptionsFrame:SetMovable(true);
	InterfaceOptionsFrame:EnableMouse(true);
	InterfaceOptionsFrame:RegisterForDrag("LeftButton", "RightButton");
	InterfaceOptionsFrame:SetScript("OnDragStart", function(self)
		if(InCombatLockdown()) then return; end

		if(IsShiftKeyDown()) then
			self:StartMoving();
		end
	end);
	InterfaceOptionsFrame:SetScript("OnDragStop", function(self) 
		self:StopMovingOrSizing();
	end);
	InterfaceOptionsFrame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", -1, 4);
		GameTooltip:ClearLines();
		GameTooltip:AddDoubleLine(L["Hold Shift + Drag:"], L["Temporary Move"], 1, 1, 1);

		GameTooltip:Show();
	end);
	InterfaceOptionsFrame:SetScript("OnLeave", function() GameTooltip:Hide(); end);

	-- Chat Menu
	local ChatMenus = {
		"ChatMenu",
		"EmoteMenu",
		"LanguageMenu",
		"VoiceMacroMenu"
	};

	for i = 1, #ChatMenus do
		if(_G[ChatMenus[i]] == _G["ChatMenu"]) then
			_G[ChatMenus[i]]:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent", true);
				self:SetBackdropColor(unpack(E["media"].backdropfadecolor));
				self:ClearAllPoints();
				self:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30);
			end);
		else
			_G[ChatMenus[i]]:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent", true);
				self:SetBackdropColor(unpack(E["media"].backdropfadecolor));
			end);
		end
	end

	for i = 1, 32 do
		_G["ChatMenuButton"..i]:StyleButton();
		_G["EmoteMenuButton"..i]:StyleButton();
		_G["LanguageMenuButton"..i]:StyleButton();
		_G["VoiceMacroMenuButton"..i]:StyleButton();
	end

	-- Chat Config
	ChatConfigFrame:StripTextures();
	ChatConfigFrame:SetTemplate("Transparent");
	ChatConfigCategoryFrame:SetTemplate("Transparent");
	ChatConfigBackgroundFrame:SetTemplate("Transparent");

	ChatConfigChatSettingsClassColorLegend:SetTemplate("Transparent");
	ChatConfigChannelSettingsClassColorLegend:SetTemplate("Transparent");

	ChatConfigCombatSettingsFilters:SetTemplate("Transparent");

	ChatConfigCombatSettingsFiltersScrollFrame:StripTextures();

	S:HandleScrollBar(ChatConfigCombatSettingsFiltersScrollFrameScrollBar);

	S:HandleButton(ChatConfigCombatSettingsFiltersDeleteButton);

	S:HandleButton(ChatConfigCombatSettingsFiltersAddFilterButton);
	ChatConfigCombatSettingsFiltersAddFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0);

	S:HandleButton(ChatConfigCombatSettingsFiltersCopyFilterButton);
	ChatConfigCombatSettingsFiltersCopyFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0);

	S:HandleNextPrevButton(ChatConfigMoveFilterUpButton, true);
	SquareButton_SetIcon(ChatConfigMoveFilterUpButton, "UP");
	ChatConfigMoveFilterUpButton:Size(26);
	ChatConfigMoveFilterUpButton:Point("TOPLEFT", ChatConfigCombatSettingsFilters, "BOTTOMLEFT", 3, -1);

	S:HandleNextPrevButton(ChatConfigMoveFilterDownButton, true);
	ChatConfigMoveFilterDownButton:Size(26);
	ChatConfigMoveFilterDownButton:Point("LEFT", ChatConfigMoveFilterUpButton, "RIGHT", 1, 0);

	CombatConfigColorsHighlighting:StripTextures();
	CombatConfigColorsColorizeUnitName:StripTextures();
	CombatConfigColorsColorizeSpellNames:StripTextures();

	CombatConfigColorsColorizeDamageNumber:StripTextures();
	CombatConfigColorsColorizeDamageSchool:StripTextures();
	CombatConfigColorsColorizeEntireLine:StripTextures();

	S:HandleEditBox(CombatConfigSettingsNameEditBox);

	S:HandleButton(CombatConfigSettingsSaveButton);

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
		local tab = _G["CombatConfigTab"..i];
		tab:StripTextures();

		tab:CreateBackdrop("Default", true);
		tab.backdrop:Point("TOPLEFT", 1, -10);
		tab.backdrop:Point("BOTTOMRIGHT", -1, 2);

		tab:HookScript("OnEnter", S.SetModifiedBackdrop);
		tab:HookScript("OnLeave", S.SetOriginalBackdrop);
	end

	S:HandleButton(ChatConfigFrameDefaultButton);
	S:HandleButton(CombatLogDefaultButton);
	S:HandleButton(ChatConfigFrameCancelButton);
	S:HandleButton(ChatConfigFrameOkayButton);

	S:SecureHook("ChatConfig_CreateCheckboxes", function(frame, checkBoxTable, checkBoxTemplate)
		local checkBoxNameString = frame:GetName().."CheckBox";
		if(checkBoxTemplate == "ChatConfigCheckBoxTemplate") then
			frame:SetTemplate("Transparent");
			for index, value in ipairs(checkBoxTable) do
				local checkBoxName = checkBoxNameString..index;
				local checkbox = _G[checkBoxName];
				if(not checkbox.backdrop) then
					checkbox:StripTextures();
					checkbox:CreateBackdrop();
					checkbox.backdrop:Point("TOPLEFT", 3, -1);
					checkbox.backdrop:Point("BOTTOMRIGHT", -3, 1);
					checkbox.backdrop:SetFrameLevel(checkbox:GetParent():GetFrameLevel() + 1);

					S:HandleCheckBox(_G[checkBoxName.."Check"]);
				end
			end
		elseif(checkBoxTemplate == "ChatConfigCheckBoxWithSwatchTemplate") or (checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate") then
			frame:SetTemplate("Transparent");
			for index, value in ipairs(checkBoxTable) do
				local checkBoxName = checkBoxNameString..index;
				local checkbox = _G[checkBoxName];
				if(not checkbox.backdrop) then
					checkbox:StripTextures();

					checkbox:CreateBackdrop();
					checkbox.backdrop:Point("TOPLEFT", 3, -1);
					checkbox.backdrop:Point("BOTTOMRIGHT", -3, 1);
					checkbox.backdrop:SetFrameLevel(checkbox:GetParent():GetFrameLevel() + 1);

					S:HandleCheckBox(_G[checkBoxName.."Check"]);

					if(checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate") then
						S:HandleCheckBox(_G[checkBoxName.."ColorClasses"]);
					end
				end
			end
		end
	end);

	S:SecureHook("ChatConfig_CreateTieredCheckboxes", function(frame, checkBoxTable)
		local checkBoxNameString = frame:GetName().."CheckBox";
		for index, value in ipairs(checkBoxTable) do
			local checkBoxName = checkBoxNameString..index;
			if(_G[checkBoxName]) then
				S:HandleCheckBox(_G[checkBoxName]);
				if(value.subTypes) then
					local subCheckBoxNameString = checkBoxName.."_";
					for k, v in ipairs(value.subTypes) do
						local subCheckBoxName = subCheckBoxNameString..k;
						if(_G[subCheckBoxName]) then
							S:HandleCheckBox(_G[subCheckBoxNameString..k]);
						end
					end
				end
			end
		end
	end);

	S:SecureHook("ChatConfig_CreateColorSwatches", function(frame, swatchTable)
		frame:SetTemplate("Transparent");
		local nameString = frame:GetName().."Swatch";
		for index, value in ipairs(swatchTable) do
			local swatchName = nameString..index;
			local swatch = _G[swatchName];
			if(not swatch.backdrop) then
				swatch:StripTextures();
				swatch:CreateBackdrop();
				swatch.backdrop:Point("TOPLEFT", 3, -1);
				swatch.backdrop:Point("BOTTOMRIGHT", -3, 1);
				swatch.backdrop:SetFrameLevel(swatch:GetParent():GetFrameLevel() + 1);
			end
		end
	end);
end

S:AddCallback("SkinMisc", LoadSkin)