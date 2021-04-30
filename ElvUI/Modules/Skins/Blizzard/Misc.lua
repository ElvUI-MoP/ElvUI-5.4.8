local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs, unpack = pairs, unpack

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.misc then return end

	-- ESC/Menu Buttons
	GameMenuFrame:StripTextures()
	GameMenuFrame:CreateBackdrop("Transparent")

	local BlizzardMenuButtons = {
		GameMenuButtonOptions,
		GameMenuButtonUIOptions,
		GameMenuButtonKeybindings,
		GameMenuButtonMacros,
		GameMenuButtonLogout,
		GameMenuButtonStore,
		GameMenuButtonQuit,
		GameMenuButtonContinue,
		GameMenuButtonHelp,
		GameMenuFrame.ElvUI
	}

	for i = 1, #BlizzardMenuButtons do
		local menuButton = BlizzardMenuButtons[i]
		if menuButton then
			S:HandleButton(menuButton)
		end
	end

	-- Static Popups
	for i = 1, 4 do
		local itemFrame = _G["StaticPopup"..i.."ItemFrame"]
		local itemFrameBox = _G["StaticPopup"..i.."EditBox"]
		local itemFrameTexture = _G["StaticPopup"..i.."ItemFrameIconTexture"]
		local closeButton = _G["StaticPopup"..i.."CloseButton"]

		_G["StaticPopup"..i]:SetTemplate("Transparent")

		S:HandleEditBox(itemFrameBox)
		itemFrameBox.backdrop:Point("TOPLEFT", -2, -4)
		itemFrameBox.backdrop:Point("BOTTOMRIGHT", 2, 4)

		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameGold"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameSilver"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameCopper"])

		closeButton:StripTextures(true)
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

		_G["StaticPopup"..i.."ItemFrameNormalTexture"]:SetAlpha(0)
		_G["StaticPopup"..i.."ItemFrameNameFrame"]:Kill()

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
	if E.locale == "ruRU" then
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

	S:HandleRoleButton(RolePollPopupRoleButtonTank, 60)
	S:HandleRoleButton(RolePollPopupRoleButtonHealer, 60)
	S:HandleRoleButton(RolePollPopupRoleButtonDPS, 60)

	RolePollPopupRoleButtonTank:Point("TOPLEFT", 45, -45)

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

	LevelUpDisplaySpellFrame.rarityMiddleHuge:FontTemplate(nil, 22)

	hooksecurefunc(LevelUpDisplaySpellFrame.rarityValue, "Show", function(self)
		local r, g, b = self:GetTextColor()
		LevelUpDisplaySpellFrame.backdrop:SetBackdropBorderColor(r, g, b)
		LevelUpDisplaySpellFrame.rarityMiddleHuge:SetTextColor(r, g, b)
	end)

	hooksecurefunc(LevelUpDisplaySpellFrame.rarityValue, "Hide", function()
		LevelUpDisplaySpellFrame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end)

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
	ChannelPulloutTabText:Point("LEFT", ChannelPulloutTabLeft, "RIGHT", 0, 4)

	S:HandleCloseButton(ChannelPulloutCloseButton)
	ChannelPulloutCloseButton:Size(32)

	-- Dropdown Menu
	hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
		local listFrameName = _G["DropDownList"..level]:GetName()

		local Backdrop = _G[listFrameName.."Backdrop"]
		if not Backdrop.template then Backdrop:StripTextures() end
		Backdrop:SetTemplate("Transparent")

		local menuBackdrop = _G[listFrameName.."MenuBackdrop"]
		if not menuBackdrop.template then menuBackdrop:StripTextures() end
		menuBackdrop:SetTemplate("Transparent")

		local expandArrow = _G[listFrameName.."Button"..index.."ExpandArrow"]
		if expandArrow then
			expandArrow:Size(16)
			expandArrow:SetNormalTexture(E.Media.Textures.ArrowUp)

			local normal = expandArrow:GetNormalTexture()
			normal:SetRotation(S.ArrowRotation.right)
			normal:SetVertexColor(unpack(E.media.rgbvaluecolor))
		end
	end)

	local function dropDownButtonShow(self)
		self.check.backdrop:SetShown(not self.notCheckable)
	end

	local menuLevel, maxButtons = 0, 0
	local checkBoxSkin = E.private.skins.checkBoxSkin
	local function skinDropdownMenu()
		local updateButtons = maxButtons < UIDROPDOWNMENU_MAXBUTTONS

		if updateButtons or menuLevel < UIDROPDOWNMENU_MAXLEVELS then
			for i = 1, UIDROPDOWNMENU_MAXLEVELS do
				if updateButtons then
					for j = 1, UIDROPDOWNMENU_MAXBUTTONS do
						local button = _G["DropDownList"..i.."Button"..j]

						if not button.isSkinned then
							local r, g, b = unpack(E.media.rgbvaluecolor)
							local highlight = _G["DropDownList"..i.."Button"..j.."Highlight"]
							highlight:SetTexture(E.Media.Textures.Highlight)
							highlight:SetVertexColor(r, g, b, 0.7)
							highlight:SetInside()
							highlight:SetBlendMode("BLEND")
							highlight:SetDrawLayer("BACKGROUND")

							if checkBoxSkin then
								local check = _G["DropDownList"..i.."Button"..j.."Check"]
								check:CreateBackdrop()
								check:SetTexture(E.media.normTex)
								check:SetVertexColor(r, g, b)
								check:Point("LEFT", 1, 0)
								check:Size(E.PixelMode and 12 or 8)

								button.check = check
								hooksecurefunc(button, "Show", dropDownButtonShow)

								_G["DropDownList"..i.."Button"..j.."UnCheck"]:SetTexture()
							end

							S:HandleColorSwatch(_G["DropDownList"..i.."Button"..j.."ColorSwatch"], 12)

							button.isSkinned = true
						end
					end
				end
			end

			menuLevel = UIDROPDOWNMENU_MAXLEVELS
			maxButtons = UIDROPDOWNMENU_MAXBUTTONS
		end
	end

	skinDropdownMenu()
	hooksecurefunc("UIDropDownMenu_InitializeHelper", skinDropdownMenu)

	if checkBoxSkin then
		hooksecurefunc("ToggleDropDownMenu", function(level)
			if not level then level = 1 end

			for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
				_G["DropDownList"..level.."Button"..i.."Check"]:SetTexCoord(0, 1, 0, 1)
			end
		end)
	end

	-- Chat Menu
	for _, frame in pairs({"ChatMenu", "EmoteMenu", "LanguageMenu", "VoiceMacroMenu"}) do
		if _G[frame] == _G["ChatMenu"] then
			_G[frame]:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent")
				self:SetBackdropColor(unpack(E.media.backdropfadecolor))
				self:ClearAllPoints()
				self:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30)
			end)
		else
			_G[frame]:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent")
				self:SetBackdropColor(unpack(E.media.backdropfadecolor))
			end)
		end

		for i = 1, 32 do
			local button = _G[frame.."Button"..i]

			button:SetHighlightTexture(E.Media.Textures.Highlight)

			local highlight = button:GetHighlightTexture()
			local r, g, b = unpack(E.media.rgbvaluecolor)

			highlight:SetVertexColor(r, g, b, 0.5)
			highlight:SetInside()
		end
	end
end

S:AddCallback("SkinMisc", LoadSkin)