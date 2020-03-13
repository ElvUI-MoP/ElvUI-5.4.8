local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local UnitIsUnit = UnitIsUnit
local IsAddOnLoaded = IsAddOnLoaded

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.misc ~= true then return end

	-- ESC/Menu Buttons
	GameMenuFrame:StripTextures()
	GameMenuFrame:CreateBackdrop("Transparent")

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
	}

	for i = 1, #BlizzardMenuButtons do
		local ElvuiMenuButtons = _G["GameMenuButton"..BlizzardMenuButtons[i]]
		if ElvuiMenuButtons then
			S:HandleButton(ElvuiMenuButtons)
		end
	end

	if IsAddOnLoaded("OptionHouse") then
		S:HandleButton(GameMenuButtonOptionHouse)
	end

	-- Static Popups
	for i = 1, 4 do
		local staticPopup = _G["StaticPopup"..i]
		local itemFrame = _G["StaticPopup"..i.."ItemFrame"]
		local itemFrameBox = _G["StaticPopup"..i.."EditBox"]
		local itemFrameTexture = _G["StaticPopup"..i.."ItemFrameIconTexture"]
		local itemFrameNormal = _G["StaticPopup"..i.."ItemFrameNormalTexture"]
		local itemFrameName = _G["StaticPopup"..i.."ItemFrameNameFrame"]
		local closeButton = _G["StaticPopup"..i.."CloseButton"]

		staticPopup:SetTemplate("Transparent")

		S:HandleEditBox(itemFrameBox)
		itemFrameBox.backdrop:Point("TOPLEFT", -2, -4)
		itemFrameBox.backdrop:Point("BOTTOMRIGHT", 2, 4)

		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameGold"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameSilver"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameCopper"])

		closeButton:StripTextures()
		S:HandleCloseButton(closeButton)

		itemFrame:GetNormalTexture():Kill()
		itemFrame:SetTemplate()
		itemFrame:StyleButton()

		hooksecurefunc("StaticPopup_Show", function(which, _, _, data)
			local info = StaticPopupDialogs[which]
			if not info then return nil end

			if info.hasItemFrame then
				if data and type(data) == "table" then
					itemFrame:SetBackdropBorderColor(unpack(data.color or {1, 1, 1, 1}))
				end
			end
		end)

		itemFrameTexture:SetTexCoord(unpack(E.TexCoords))
		itemFrameTexture:SetInside()

		itemFrameNormal:SetAlpha(0)

		itemFrameName:Kill()

		for j = 1, 3 do
			S:HandleButton(_G["StaticPopup"..i.."Button"..j])
		end
	end

	-- Graveyard Button
	do
		GhostFrame:StripTextures(true)
		GhostFrame:SetTemplate("Transparent")
		GhostFrame:ClearAllPoints()
		GhostFrame:Point("TOP", E.UIParent, "TOP", 0, -150)

		GhostFrame:HookScript("OnEnter", S.SetModifiedBackdrop)
		GhostFrame:HookScript("OnLeave", S.SetOriginalBackdrop)

		GhostFrameContentsFrame:CreateBackdrop()
		GhostFrameContentsFrame.backdrop:SetOutside(GhostFrameContentsFrameIcon)
		GhostFrameContentsFrame.SetPoint = E.noop

		GhostFrameContentsFrameIcon:SetTexCoord(unpack(E.TexCoords))
		GhostFrameContentsFrameIcon:SetParent(GhostFrameContentsFrame.backdrop)
	end

	-- Other Frames
	TicketStatusFrameButton:SetTemplate("Transparent")

	AutoCompleteBox:SetTemplate("Transparent")

	ConsolidatedBuffsTooltip:SetTemplate("Transparent")

	StreamingIcon:ClearAllPoints()
	StreamingIcon:Point("TOP", UIParent, "TOP", 0, -100)

	-- BNToast Frame
	BNToastFrame:SetTemplate("Transparent")

	BNToastFrameCloseButton:Size(32)
	BNToastFrameCloseButton:Point("TOPRIGHT", "BNToastFrame", 4, 4)

	S:HandleCloseButton(BNToastFrameCloseButton)

	-- ReadyCheck Frame
	ReadyCheckFrame:SetTemplate("Transparent")
	ReadyCheckFrame:Size(290, 85)

	S:HandleButton(ReadyCheckFrameYesButton)
	ReadyCheckFrameYesButton:ClearAllPoints()
	ReadyCheckFrameYesButton:Point("LEFT", ReadyCheckFrame, 15, -20)
	ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)

	S:HandleButton(ReadyCheckFrameNoButton)
	ReadyCheckFrameNoButton:ClearAllPoints()
	ReadyCheckFrameNoButton:Point("RIGHT", ReadyCheckFrame, -15, -20)
	ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame)

	ReadyCheckFrameText:ClearAllPoints()
	ReadyCheckFrameText:Point("TOP", 0, -5)
	ReadyCheckFrameText:SetParent(ReadyCheckFrame)
	ReadyCheckFrameText:SetTextColor(1, 1, 1)

	ReadyCheckListenerFrame:SetAlpha(0)

	ReadyCheckFrame:HookScript("OnShow", function(self) -- bug fix, don't show it if initiator
		if UnitIsUnit("player", self.initiator) then
			self:Hide()
		end
	end)

	-- Coin PickUp Frame
	CoinPickupFrame:StripTextures()
	CoinPickupFrame:SetTemplate("Transparent")

	S:HandleButton(CoinPickupOkayButton)
	S:HandleButton(CoinPickupCancelButton)

	-- Stack Split Frame
	StackSplitFrame:SetTemplate("Transparent")
	StackSplitFrame:GetRegions():Hide()
	StackSplitFrame:SetFrameStrata("DIALOG")

	StackSplitFrame.bg1 = CreateFrame("Frame", nil, StackSplitFrame)
	StackSplitFrame.bg1:SetTemplate("Transparent")
	StackSplitFrame.bg1:Point("TOPLEFT", 10, -15)
	StackSplitFrame.bg1:Point("BOTTOMRIGHT", -10, 55)
	StackSplitFrame.bg1:SetFrameLevel(StackSplitFrame.bg1:GetFrameLevel() - 1)

	S:HandleButton(StackSplitOkayButton)
	S:HandleButton(StackSplitCancelButton)

	-- Opacity Frame
	OpacityFrame:StripTextures()
	OpacityFrame:SetTemplate("Transparent")

	S:HandleSliderFrame(OpacityFrameSlider)

	-- BattleTag Frame
	BattleTagInviteFrame:StripTextures()
	BattleTagInviteFrame:SetTemplate("Transparent")

	S:HandleEditBox(BattleTagInviteFrameScrollFrame)

	for i = 1, BattleTagInviteFrame:GetNumChildren() do
		local child = select(i, BattleTagInviteFrame:GetChildren())
		if child:GetObjectType() == "Button" then
			S:HandleButton(child)
		end
	end

	-- Declension frame
	if GetLocale() == "ruRU" then
		DeclensionFrame:SetTemplate("Transparent")

		S:HandleNextPrevButton(DeclensionFrameSetPrev)
		S:HandleNextPrevButton(DeclensionFrameSetNext)
		S:HandleButton(DeclensionFrameOkayButton)
		S:HandleButton(DeclensionFrameCancelButton)

		for i = 1, RUSSIAN_DECLENSION_PATTERNS do
			local editBox = _G["DeclensionFrameDeclension"..i.."Edit"]
			if editBox then
				editBox:StripTextures()
				S:HandleEditBox(editBox)
			end
		end
	end

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

		_G[roleCheckIcons[i]]:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		_G[roleCheckIcons[i]]:GetNormalTexture():SetInside(_G[roleCheckIcons[i]].backdrop)
	end

	RolePollPopupRoleButtonTank:Point("TOPLEFT", 32, -35)

	RolePollPopupRoleButtonTank:SetNormalTexture("Interface\\Icons\\Ability_Defend")
	RolePollPopupRoleButtonHealer:SetNormalTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")
	RolePollPopupRoleButtonDPS:SetNormalTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")

	-- Report Player
	ReportCheatingDialog:StripTextures()
	ReportCheatingDialog:SetTemplate("Transparent")

	ReportCheatingDialogCommentFrame:StripTextures()

	S:HandleEditBox(ReportCheatingDialogCommentFrameEditBox)
	S:HandleButton(ReportCheatingDialogReportButton)
	S:HandleButton(ReportCheatingDialogCancelButton)

	ReportPlayerNameDialog:StripTextures()
	ReportPlayerNameDialog:SetTemplate("Transparent")

	ReportPlayerNameDialogCommentFrame:StripTextures()

	S:HandleEditBox(ReportPlayerNameDialogCommentFrameEditBox)
	S:HandleButton(ReportPlayerNameDialogCancelButton)
	S:HandleButton(ReportPlayerNameDialogReportButton)

	-- Cinematic Popup
	CinematicFrameCloseDialog:StripTextures()
	CinematicFrameCloseDialog:SetTemplate("Transparent")

	CinematicFrameCloseDialog:SetScale(UIParent:GetScale())

	S:HandleButton(CinematicFrameCloseDialogConfirmButton)
	S:HandleButton(CinematicFrameCloseDialogResumeButton)

	-- Movie Frame Popup
	MovieFrame.CloseDialog:StripTextures()
	MovieFrame.CloseDialog:SetTemplate("Transparent")

	MovieFrame.CloseDialog:SetScale(UIParent:GetScale())

	S:HandleButton(MovieFrame.CloseDialog.ConfirmButton)
	S:HandleButton(MovieFrame.CloseDialog.ResumeButton)

	-- Level Up Popup
	LevelUpDisplaySpellFrame:CreateBackdrop()
	LevelUpDisplaySpellFrame.backdrop:SetOutside(LevelUpDisplaySpellFrameIcon)

	LevelUpDisplaySpellFrameIcon:SetTexCoord(unpack(E.TexCoords))
	LevelUpDisplaySpellFrameSubIcon:SetTexCoord(unpack(E.TexCoords))

	LevelUpDisplaySpellFrameIconBorder:SetAlpha(0)

	LevelUpDisplaySide:HookScript("OnShow", function(self)
		for i = 1, #self.unlockList do
			local button = _G["LevelUpDisplaySideUnlockFrame"..i]

			if not button.isSkinned then
				button.icon:SetTexCoord(unpack(E.TexCoords))

				button.isSkinned = true
			end
		end
	end)

	-- Channel Pullout Frame
	ChannelPullout:SetTemplate("Transparent")

	ChannelPulloutBackground:Kill()

	S:HandleTab(ChannelPulloutTab)
	ChannelPulloutTab:Size(107, 26)
	ChannelPulloutTabText:Point("LEFT", ChannelPulloutTabLeft, "RIGHT", 0, 0)

	S:HandleCloseButton(ChannelPulloutCloseButton)
	ChannelPulloutCloseButton:Size(32)

	-- Dropdown Menu
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function()
		for i = 1, UIDROPDOWNMENU_MAXLEVELS do
			local dropBackdrop = _G["DropDownList"..i.."Backdrop"]
			local dropMenuBackdrop = _G["DropDownList"..i.."MenuBackdrop"]

			dropBackdrop:SetTemplate("Transparent")
			dropMenuBackdrop:SetTemplate("Transparent")

			for j = 1, UIDROPDOWNMENU_MAXBUTTONS do
				local highlight = _G["DropDownList"..i.."Button"..j.."Highlight"]
				local colorSwatch = _G["DropDownList"..i.."Button"..j.."ColorSwatch"]

				highlight:SetTexture(1, 1, 1, 0.3)
				S:HandleColorSwatch(colorSwatch, 14)
			end
		end
	end)

	-- Chat Menu
	local ChatMenus = {
		"ChatMenu",
		"EmoteMenu",
		"LanguageMenu",
		"VoiceMacroMenu"
	}

	for i = 1, #ChatMenus do
		if _G[ChatMenus[i]] == _G["ChatMenu"] then
			_G[ChatMenus[i]]:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent", true)
				self:SetBackdropColor(unpack(E.media.backdropfadecolor))
				self:ClearAllPoints()
				self:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30)
			end)
		else
			_G[ChatMenus[i]]:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent", true)
				self:SetBackdropColor(unpack(E.media.backdropfadecolor))
			end)
		end
	end

	for i = 1, 32 do
		_G["ChatMenuButton"..i]:StyleButton()
		_G["EmoteMenuButton"..i]:StyleButton()
		_G["LanguageMenuButton"..i]:StyleButton()
		_G["VoiceMacroMenuButton"..i]:StyleButton()
	end
end

S:AddCallback("SkinMisc", LoadSkin)