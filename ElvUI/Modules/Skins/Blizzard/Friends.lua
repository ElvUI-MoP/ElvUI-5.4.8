local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local select, unpack = select, unpack

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetWhoInfo = GetWhoInfo

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.friends then return end

	FriendsListFrame:StripTextures()
	FriendsTabHeader:StripTextures()
	FriendsFrameInset:StripTextures()
	FriendsFrameFriendsScrollFrame:StripTextures()

	for i = 1, FriendsFrame:GetNumRegions() do
		local region = select(i, FriendsFrame:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
			region:SetAlpha(0)
		end
	end

	for i = 1, 3 do
		local headerTab = _G["FriendsTabHeaderTab"..i]
		headerTab:StripTextures()
		headerTab.backdrop = CreateFrame("Frame", nil, headerTab)
		headerTab.backdrop:SetTemplate("Default", true)
		headerTab.backdrop:SetFrameLevel(headerTab:GetFrameLevel() - 1)
		headerTab.backdrop:Point("TOPLEFT", 3, -7)
		headerTab.backdrop:Point("BOTTOMRIGHT", -2, -1)

		headerTab:HookScript("OnEnter", S.SetModifiedBackdrop)
		headerTab:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	for i = 1, FRIENDS_FRIENDS_TO_DISPLAY do
		local button = _G["FriendsFrameFriendsScrollFrameButton"..i]
		local summon = button.summonButton:GetName()

		S:HandleButtonHighlight(button)
		button.handledHighlight:Point("TOPLEFT", 0, -1)
		button.handledHighlight:Point("BOTTOMLEFT", 0, 1)

		button.background:SetInside()

		_G[summon]:StyleButton()
		_G[summon.."Icon"]:SetTexCoord(unpack(E.TexCoords))
		_G[summon.."NormalTexture"]:SetAlpha(0)
		E:RegisterCooldown(_G[summon.."Cooldown"])
	end

	for i = 1, PENDING_INVITES_TO_DISPLAY do
		_G["FriendsFramePendingButton"..i]:StripTextures()
		S:HandleButton(_G["FriendsFramePendingButton"..i.."AcceptButton"])
		S:HandleButton(_G["FriendsFramePendingButton"..i.."DeclineButton"])
	end

	FriendsFrame:SetTemplate("Transparent")

	AddFriendFrame:StripTextures()
	AddFriendFrame:SetTemplate("Transparent")

	FriendsFriendsFrame:StripTextures()
	FriendsFriendsFrame:CreateBackdrop("Transparent")

	FriendsFrameBroadcastInput:CreateBackdrop()

	FriendsFriendsList:StripTextures()
	S:HandleEditBox(FriendsFriendsList)

	FriendsFriendsNoteFrame:StripTextures()
	S:HandleEditBox(FriendsFriendsNoteFrame)

	S:HandleDropDownBox(FriendsFriendsFrameDropDown, 150)

	S:HandleDropDownBox(FriendsFrameStatusDropDown, 70)
	FriendsFrameStatusDropDown:Point("TOPLEFT", 5, -25)

	S:HandleScrollBar(FriendsFrameFriendsScrollFrameScrollBar, 5)
	FriendsFrameFriendsScrollFrameScrollBar:ClearAllPoints()
	FriendsFrameFriendsScrollFrameScrollBar:Point("TOPRIGHT", FriendsFrameFriendsScrollFrame, "TOPRIGHT", 24, -10)
	FriendsFrameFriendsScrollFrameScrollBar:Point("BOTTOMRIGHT", FriendsFrameFriendsScrollFrame, "BOTTOMRIGHT", 0, 12)

	S:HandleScrollBar(FriendsFriendsScrollFrameScrollBar)

	S:HandleCloseButton(FriendsFrameCloseButton,FriendsFrame.backdrop)

	PendingListFrame:StripTextures()
	AddFriendNoteFrame:StripTextures()

	FriendsFrameBroadcastInputLeft:Kill()
	FriendsFrameBroadcastInputRight:Kill()
	FriendsFrameBroadcastInputMiddle:Kill()

	S:HandleButton(FriendsFrameAddFriendButton)
	S:HandleButton(FriendsFrameSendMessageButton)
	S:HandleButton(FriendsFriendsSendRequestButton)
	S:HandleButton(FriendsFriendsCloseButton)
	S:HandleButton(FriendsFrameIgnorePlayerButton)
	S:HandleButton(FriendsFrameUnsquelchButton)
	S:HandleButton(AddFriendEntryFrameAcceptButton)
	S:HandleButton(AddFriendEntryFrameCancelButton)
	S:HandleButton(AddFriendInfoFrameContinueButton)

	S:HandleEditBox(AddFriendNameEditBox)

	-- Who Frame
	WhoFrameListInset:StripTextures()
	WhoFrameEditBoxInset:StripTextures()

	WhoListScrollFrame:StripTextures()

	for i = 1, 4 do
		local header = _G["WhoFrameColumnHeader"..i]

		header:StripTextures()
		header:StyleButton()
		header:ClearAllPoints()
	end

	WhoFrameColumnHeader1:Point("LEFT", WhoFrameColumnHeader4, "RIGHT", -2, 0)
	WhoFrameColumn_SetWidth(WhoFrameColumnHeader1, 105)
	WhoFrameColumnHeader2:Point("LEFT", WhoFrameColumnHeader1, "RIGHT", -5, 0)
	WhoFrameColumnHeader3:Point("TOPLEFT", WhoFrame, "TOPLEFT", 15, -57)
	WhoFrameColumnHeader4:Point("LEFT", WhoFrameColumnHeader3, "RIGHT", -2, 0)
	WhoFrameColumn_SetWidth(WhoFrameColumnHeader4, 48)

	WhoFrameButton1:Point("TOPLEFT", 10, -82)

	S:HandleEditBox(WhoFrameEditBox)
	WhoFrameEditBox:Point("BOTTOM", -1, 29)
	WhoFrameEditBox:Size(326, 18)

	S:HandleButton(WhoFrameWhoButton)
	WhoFrameWhoButton:Point("RIGHT", WhoFrameAddFriendButton, "LEFT", -2, 0)
	WhoFrameWhoButton:Width(84)

	S:HandleButton(WhoFrameAddFriendButton)
	WhoFrameAddFriendButton:Point("RIGHT", WhoFrameGroupInviteButton, "LEFT", -2, 0)

	S:HandleButton(WhoFrameGroupInviteButton)
	WhoFrameGroupInviteButton:Point("BOTTOMRIGHT", -6, 4)

	S:HandleDropDownBox(WhoFrameDropDown)
	WhoFrameDropDown:Point("TOPLEFT", -6, 4)

	S:HandleScrollBar(WhoListScrollFrameScrollBar, 5)
	WhoListScrollFrameScrollBar:ClearAllPoints()
	WhoListScrollFrameScrollBar:Point("TOPRIGHT", WhoListScrollFrame, "TOPRIGHT", 26, -13)
	WhoListScrollFrameScrollBar:Point("BOTTOMRIGHT", WhoListScrollFrame, "BOTTOMRIGHT", 0, 18)

	for i = 1, WHOS_TO_DISPLAY do
		local button = _G["WhoFrameButton"..i]
		local level = _G["WhoFrameButton"..i.."Level"]
		local name = _G["WhoFrameButton"..i.."Name"]

		button.icon = button:CreateTexture("$parentIcon", "ARTWORK")
		button.icon:Point("LEFT", 45, 0)
		button.icon:Size(14)
		button.icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")

		button:CreateBackdrop("Default", true)
		button.backdrop:SetAllPoints(button.icon)

		S:HandleButtonHighlight(button)
		button.handledHighlight:Point("TOPLEFT", 0, -1)
		button.handledHighlight:Point("BOTTOMLEFT", 0, 1)

		button.stripe = button:CreateTexture(nil, "BACKGROUND")
		button.stripe:SetTexture("Interface\\GuildFrame\\GuildFrame")
		button.stripe:SetInside()

		level:ClearAllPoints()
		if i == 1 then
			level:Point("TOPLEFT", 11, -2)
		else
			level:Point("TOPLEFT", 12, -2)
		end

		name:Size(100, 14)
		name:ClearAllPoints()
		name:Point("LEFT", 85, 0)

		_G["WhoFrameButton"..i.."Class"]:Hide()
	end

	hooksecurefunc("WhoList_Update", function()
		local whoOffset = FauxScrollFrame_GetOffset(WhoListScrollFrame)
		local playerZone = GetRealZoneText()
		local playerGuild = GetGuildInfo("player")
		local playerRace = UnitRace("player")

		for i = 1, WHOS_TO_DISPLAY, 1 do
			local index = whoOffset + i
			local button = _G["WhoFrameButton"..i]
			local nameText = _G["WhoFrameButton"..i.."Name"]
			local levelText = _G["WhoFrameButton"..i.."Level"]
			local variableText = _G["WhoFrameButton"..i.."Variable"]

			local _, guild, level, race, _, zone, classFileName = GetWhoInfo(index)

			local classTextColor = E:ClassColor(classFileName)
			local levelTextColor = GetQuestDifficultyColor(level)

			if classFileName then
				button.icon:Show()
				button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]))

				nameText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
				levelText:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b)

				if zone == playerZone then
					zone = "|cff00ff00"..zone
				end
				if guild == playerGuild then
					guild = "|cff00ff00"..guild
				end
				if race == playerRace then
					race = "|cff00ff00"..race
				end

				local columnTable = {zone, guild, race}

				variableText:SetText(columnTable[UIDropDownMenu_GetSelectedID(WhoFrameDropDown)])
			else
				button.icon:Hide()
			end

			if (i + whoOffset) % 2 == 1 then
				button.stripe:SetTexCoord(0.362, 0.381, 0.958, 0.998)
			else
				button.stripe:SetTexCoord(0.516, 0.536, 0.882, 0.921)
			end
		end
	end)

	-- Channel Frame
	ChannelRoster:StripTextures()
	ChannelRosterScrollFrame:StripTextures()
	ChannelFrameLeftInset:StripTextures()
	ChannelFrameRightInset:StripTextures()
	ChannelListScrollFrame:StripTextures()

	ChannelFrameDaughterFrameChannelNameLeft:Kill()
	ChannelFrameDaughterFrameChannelNameRight:Kill()
	ChannelFrameDaughterFrameChannelNameMiddle:Kill()
	ChannelFrameDaughterFrameChannelPasswordLeft:Kill()
	ChannelFrameDaughterFrameChannelPasswordRight:Kill()
	ChannelFrameDaughterFrameChannelPasswordMiddle:Kill()

	ChannelFrameDaughterFrame:StripTextures()
	ChannelFrameDaughterFrame:CreateBackdrop("Transparent")

	ChannelFrameDaughterFrameChannelName:CreateBackdrop()
	ChannelFrameDaughterFrameChannelPassword:CreateBackdrop()

	hooksecurefunc("ChannelList_Update", function()
		for i = 1, MAX_DISPLAY_CHANNEL_BUTTONS do
			local button = _G["ChannelButton"..i]
			if button then
				_G["ChannelButton"..i.."NormalTexture"]:SetAlpha(0)
				_G["ChannelButton"..i.."Text"]:FontTemplate(nil, 12)
				_G["ChannelButton"..i.."Collapsed"]:SetTextColor(1, 1, 1)

				if not button.isSkinned then
					S:HandleButtonHighlight(button)
					button.handledHighlight:SetInside()

					button.isSkinned = true
				end
			end
		end
	end)

	for i = 1, MAX_CHANNEL_MEMBER_BUTTONS do
		S:HandleButtonHighlight(_G["ChannelMemberButton"..i])
	end

	S:HandleButton(ChannelFrameDaughterFrameOkayButton)
	S:HandleButton(ChannelFrameDaughterFrameCancelButton)

	S:HandleButton(ChannelFrameNewButton)
	ChannelFrameNewButton:Point("BOTTOMRIGHT", -255, 30)

	S:HandleScrollBar(ChannelRosterScrollFrameScrollBar, 5)

	S:HandleCloseButton(ChannelFrameDaughterFrameDetailCloseButton,ChannelFrameDaughterFrame)

	-- BN Frame
	BNConversationInviteDialog:StripTextures()
	BNConversationInviteDialog:CreateBackdrop("Transparent")

	BNConversationInviteDialogList:StripTextures()
	BNConversationInviteDialogList:SetTemplate()

	S:HandleButton(BNConversationInviteDialogInviteButton)
	S:HandleButton(BNConversationInviteDialogCancelButton)

	for i = 1, BN_CONVERSATION_INVITE_NUM_DISPLAYED do
		local button = _G["BNConversationInviteDialogListFriend"..i]

		S:HandleCheckBox(button.checkButton)
	end

	-- Ignore List
	IgnoreListFrame:StripTextures()

	FriendsFrameIgnoreButton1:Point("TOPLEFT", 10, -89)
	FriendsFrameUnsquelchButton:Point("RIGHT", -6, 0)
	FriendsFrameUnsquelchButton:Width(131)
	FriendsFrameUnsquelchButton.SetWidth = E.noop

	S:HandleScrollBar(FriendsFrameIgnoreScrollFrameScrollBar)
	FriendsFrameIgnoreScrollFrameScrollBar:ClearAllPoints()
	FriendsFrameIgnoreScrollFrameScrollBar:Point("TOPRIGHT", FriendsFrameIgnoreScrollFrame, "TOPRIGHT", 58, -1)
	FriendsFrameIgnoreScrollFrameScrollBar:Point("BOTTOMRIGHT", FriendsFrameIgnoreScrollFrame, "BOTTOMRIGHT", 0, 29)

	for i = 1, IGNORES_TO_DISPLAY do
		local button = _G["FriendsFrameIgnoreButton"..i]

		button:Width(298)
		S:HandleButtonHighlight(button)

		button.stripe = button:CreateTexture(nil, "OVERLAY")
		button.stripe:SetTexture("Interface\\GuildFrame\\GuildFrame")
		if i % 2 == 1 then
			button.stripe:SetTexCoord(0.362, 0.381, 0.958, 0.998)
		else
			button.stripe:SetTexCoord(0.516, 0.536, 0.882, 0.921)
		end
		button.stripe:SetAllPoints()
	end

	S:HandleScrollBar(FriendsFramePendingScrollFrameScrollBar, 4)

	-- Scroll of Resurrection
	ScrollOfResurrectionFrame:StripTextures()
	ScrollOfResurrectionFrame:SetTemplate("Transparent")

	ScrollOfResurrectionSelectionFrame:StripTextures()
	ScrollOfResurrectionSelectionFrame:SetTemplate("Transparent")

	ScrollOfResurrectionFrameNoteFrame:StripTextures()
	ScrollOfResurrectionFrameNoteFrame:SetTemplate()

	ScrollOfResurrectionSelectionFrameList:StripTextures()
	ScrollOfResurrectionSelectionFrameList:SetTemplate()

	ScrollOfResurrectionFrameTargetEditBox:SetTemplate()
	ScrollOfResurrectionFrameTargetEditBoxLeft:SetTexture(nil)
	ScrollOfResurrectionFrameTargetEditBoxMiddle:SetTexture(nil)
	ScrollOfResurrectionFrameTargetEditBoxRight:SetTexture(nil)

	S:HandleEditBox(ScrollOfResurrectionSelectionFrameTargetEditBox)

	S:HandleButton(ScrollOfResurrectionFrameAcceptButton)
	S:HandleButton(ScrollOfResurrectionFrameCancelButton)

	S:HandleButton(ScrollOfResurrectionSelectionFrameAcceptButton)
	S:HandleButton(ScrollOfResurrectionSelectionFrameCancelButton)

	S:HandleScrollBar(ScrollOfResurrectionSelectionFrameListScrollFrameScrollBar, 4)

	FriendsTabHeaderSoRButton:SetTemplate()
	FriendsTabHeaderSoRButton:StyleButton()
	FriendsTabHeaderSoRButton:Point("TOPRIGHT", FriendsTabHeader, "TOPRIGHT", -6, -50)

	FriendsTabHeaderSoRButtonIcon:ClearAllPoints()
	FriendsTabHeaderSoRButtonIcon:SetInside()
	FriendsTabHeaderSoRButtonIcon:SetTexCoord(unpack(E.TexCoords))
	FriendsTabHeaderSoRButtonIcon:SetDrawLayer("OVERLAY")

	-- Recruit a Friend
	RecruitAFriendFrame:StripTextures()
	RecruitAFriendFrame:SetTemplate("Transparent")

	RecruitAFriendFrame.CharacterInfo:StripTextures()
	RecruitAFriendFrame.CharacterInfo:SetTemplate("Transparent")

	RecruitAFriendSentFrame:StripTextures()
	RecruitAFriendSentFrame:SetTemplate("Transparent")

	S:HandleEditBox(RecruitAFriendNameEditBox)
	S:HandleEditBox(RecruitAFriendNoteFrame)

	S:HandleButton(RecruitAFriendFrame.SendButton)
	S:HandleButton(RecruitAFriendSentFrame.OKButton)

	S:HandleCloseButton(RecruitAFriendFrameCloseButton)
	S:HandleCloseButton(RecruitAFriendSentFrameCloseButton)

	FriendsTabHeaderRecruitAFriendButton:SetTemplate()
	FriendsTabHeaderRecruitAFriendButton:StyleButton()

	FriendsTabHeaderRecruitAFriendButtonIcon:SetInside()
	FriendsTabHeaderRecruitAFriendButtonIcon:SetTexCoord(unpack(E.TexCoords))
	FriendsTabHeaderRecruitAFriendButtonIcon:SetDrawLayer("OVERLAY")

	-- Bottom Tabs
	for i = 1, 4 do
		S:HandleTab(_G["FriendsFrameTab"..i])
	end
end

S:AddCallback("Friends", LoadSkin)