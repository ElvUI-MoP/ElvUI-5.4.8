local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local _G = _G;
local pairs, unpack = pairs, unpack;
local format, len, upper, gsub = string.format, string.len, string.upper, string.gsub;

local hooksecurefunc = hooksecurefunc;
local GetWhoInfo = GetWhoInfo;
local MAX_DISPLAY_CHANNEL_BUTTONS = MAX_DISPLAY_CHANNEL_BUTTONS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS;

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.friends ~= true then return end

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

		headerTab:HookScript("OnEnter", S.SetModifiedBackdrop);
		headerTab:HookScript("OnLeave", S.SetOriginalBackdrop);
	end

	for i = 1, 11 do
		_G["FriendsFrameFriendsScrollFrameButton"..i.."SummonButtonIcon"]:SetTexCoord(unpack(E.TexCoords))
		_G["FriendsFrameFriendsScrollFrameButton"..i.."SummonButtonNormalTexture"]:SetAlpha(0)
		_G["FriendsFrameFriendsScrollFrameButton"..i.."SummonButton"]:StyleButton()
		_G["FriendsFrameFriendsScrollFrameButton"..i]:StyleButton()
	end

	for i = 1, 4 do
		_G["FriendsFramePendingButton"..i]:StripTextures()
		S:HandleButton(_G["FriendsFramePendingButton"..i.."AcceptButton"])
		S:HandleButton(_G["FriendsFramePendingButton"..i.."DeclineButton"])
	end

	FriendsFrame:SetTemplate("Transparent")

	AddFriendFrame:StripTextures()
	AddFriendFrame:SetTemplate("Transparent")

	FriendsFriendsFrame:StripTextures()
	FriendsFriendsFrame:CreateBackdrop("Transparent")

	FriendsFrameBroadcastInput:CreateBackdrop("Default")

	FriendsFriendsList:StripTextures()
	S:HandleEditBox(FriendsFriendsList)

	FriendsFriendsNoteFrame:StripTextures()
	S:HandleEditBox(FriendsFriendsNoteFrame)

	S:HandleDropDownBox(FriendsFriendsFrameDropDown, 150)

	S:HandleDropDownBox(FriendsFrameStatusDropDown, 70)
	FriendsFrameStatusDropDown:Point("TOPLEFT", 5, -25);

	S:HandleScrollBar(FriendsFrameFriendsScrollFrameScrollBar, 5)
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

	--Who Frame
	WhoFrameListInset:StripTextures()
	WhoFrameEditBoxInset:StripTextures()

	local function UpdateWhoSkins()
		WhoListScrollFrame:StripTextures()
	end
	WhoFrame:HookScript("OnShow", UpdateWhoSkins)
	hooksecurefunc("FriendsFrame_OnEvent", UpdateWhoSkins)

	for i = 1, 4 do
		_G["WhoFrameColumnHeader"..i]:StripTextures()
		_G["WhoFrameColumnHeader"..i]:StyleButton()
		_G["WhoFrameColumnHeader"..i]:ClearAllPoints()
	end

	WhoFrameColumnHeader1:Point("LEFT", WhoFrameColumnHeader4, "RIGHT", -2, 0);
	WhoFrameColumn_SetWidth(WhoFrameColumnHeader1, 105);
	WhoFrameColumnHeader2:Point("LEFT", WhoFrameColumnHeader1, "RIGHT", -5, 0);
	WhoFrameColumnHeader3:Point("TOPLEFT", WhoFrame, "TOPLEFT", 15, -57);
	WhoFrameColumnHeader4:Point("LEFT", WhoFrameColumnHeader3, "RIGHT", -2, 0);
	WhoFrameColumn_SetWidth(WhoFrameColumnHeader4, 48);

	WhoFrameButton1:Point("TOPLEFT", 10, -82)

	WhoFrameEditBox:Point("BOTTOM", -3, 20)

	S:HandleButton(WhoFrameWhoButton)
	S:HandleButton(WhoFrameAddFriendButton)
	S:HandleButton(WhoFrameGroupInviteButton)

	S:HandleDropDownBox(WhoFrameDropDown, 150)

	S:HandleScrollBar(WhoListScrollFrameScrollBar, 5)

	for i = 1, 17 do
		local button = _G["WhoFrameButton"..i];
		local level = _G["WhoFrameButton" .. i .. "Level"]
		local name = _G["WhoFrameButton" .. i .. "Name"]

		button.icon = button:CreateTexture("$parentIcon", "ARTWORK");
		button.icon:Point("LEFT", 45, 0);
		button.icon:Size(17);
		button.icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes");

		button:CreateBackdrop("Default", true)
		button.backdrop:SetInside(button.icon)
		button:StyleButton()

		button.stripe = button:CreateTexture(nil, "BACKGROUND");
		button.stripe:SetTexture("Interface\\GuildFrame\\GuildFrame");
		if(i % 2 == 1) then
			button.stripe:SetTexCoord(0.362, 0.381, 0.958, 0.998);
		else
			button.stripe:SetTexCoord(0.516, 0.536, 0.882, 0.921);
		end
		button.stripe:SetInside()

		level:ClearAllPoints();
		if(i == 1) then
			level:Point("TOPLEFT", 11, -2);
		else
			level:Point("TOPLEFT", 12, -2);
		end

		name:Size(100, 14);
		name:ClearAllPoints();
		name:Point("LEFT", 85, 0);

		_G["WhoFrameButton" .. i .. "Class"]:Hide();
	end

	hooksecurefunc("WhoList_Update", function()
		local whoOffset = FauxScrollFrame_GetOffset(WhoListScrollFrame);

		local playerZone = GetRealZoneText();
		local playerGuild = GetGuildInfo("player");
		local playerRace = UnitRace("player");

		for i = 1, WHOS_TO_DISPLAY, 1 do
			local index = whoOffset + i;
			local button = _G["WhoFrameButton"..i];
			local nameText = _G["WhoFrameButton"..i.."Name"];
			local levelText = _G["WhoFrameButton"..i.."Level"];
			local classText = _G["WhoFrameButton"..i.."Class"];
			local variableText = _G["WhoFrameButton"..i.."Variable"];

			local _, guild, level, race, _, zone, classFileName = GetWhoInfo(index);

			local classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classFileName] or RAID_CLASS_COLORS[classFileName];
			local levelTextColor = GetQuestDifficultyColor(level);

			if(classFileName) then
				button.icon:Show();
				button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]));

				nameText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
				levelText:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b);

				if(zone == playerZone) then
					zone = "|cff00ff00"..zone;
				end
				if(guild == playerGuild) then
					guild = "|cff00ff00"..guild;
				end
				if(race == playerRace) then
					race = "|cff00ff00"..race;
				end

				local columnTable = {zone, guild, race};

				variableText:SetText(columnTable[UIDropDownMenu_GetSelectedID(WhoFrameDropDown)]);
			else
				button.icon:Hide();
			end
		end
	end);

	--Channel Frame
	ChannelRoster:StripTextures()
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

	ChannelFrameDaughterFrameChannelName:CreateBackdrop("Default")
	ChannelFrameDaughterFrameChannelPassword:CreateBackdrop("Default")

	local function UpdateChannel()
		ChannelRosterScrollFrame:StripTextures()
	end
	ChannelFrame:HookScript("OnShow", UpdateChannel)
	hooksecurefunc("FriendsFrame_OnEvent", UpdateChannel)

	local function Channel()
		for i = 1, MAX_DISPLAY_CHANNEL_BUTTONS do
			local button = _G["ChannelButton"..i]
			if button then
				_G["ChannelButton"..i.."NormalTexture"]:SetAlpha(0)
				_G["ChannelButton"..i.."Text"]:FontTemplate(nil, 12)
				_G["ChannelButton"..i.."Collapsed"]:SetTextColor(1, 1, 1);
				_G["ChannelButton"..i]:StyleButton();
			end
		end
	end
	hooksecurefunc("ChannelList_Update", Channel)

	for i = 1, 22 do
		_G["ChannelMemberButton"..i]:StyleButton()
	end

	S:HandleButton(ChannelFrameDaughterFrameOkayButton)
	S:HandleButton(ChannelFrameDaughterFrameCancelButton)

	S:HandleButton(ChannelFrameNewButton)
	ChannelFrameNewButton:Point("BOTTOMRIGHT", -255, 30)

	S:HandleScrollBar(ChannelRosterScrollFrameScrollBar, 5)

	S:HandleCloseButton(ChannelFrameDaughterFrameDetailCloseButton,ChannelFrameDaughterFrame)

	--BN Frame
	BNConversationInviteDialog:StripTextures()
	BNConversationInviteDialog:CreateBackdrop("Transparent")

	BNConversationInviteDialogList:StripTextures()
	BNConversationInviteDialogList:SetTemplate("Default")

	S:HandleButton(BNConversationInviteDialogInviteButton)
	S:HandleButton(BNConversationInviteDialogCancelButton)

	for i = 1, BN_CONVERSATION_INVITE_NUM_DISPLAYED do
		S:HandleCheckBox(_G["BNConversationInviteDialogListFriend"..i].checkButton)
	end

	--Ignore List
	IgnoreListFrame:StripTextures()

	FriendsFrameIgnoreButton1:Point("TOPLEFT", 10, -89)
	FriendsFrameUnsquelchButton:Point("RIGHT", -23, 0)

	S:HandleScrollBar(FriendsFrameIgnoreScrollFrameScrollBar)
	FriendsFrameIgnoreScrollFrameScrollBar:Point("TOPLEFT", FriendsFrameIgnoreScrollFrame, "TOPRIGHT", 45, 0)

	for i = 1, 19 do
		local button = _G["FriendsFrameIgnoreButton"..i]

		button.stripe = button:CreateTexture(nil, "OVERLAY");
		button.stripe:SetTexture("Interface\\GuildFrame\\GuildFrame");
		if(i % 2 == 1) then
			button.stripe:SetTexCoord(0.362, 0.381, 0.958, 0.998);
		else
			button.stripe:SetTexCoord(0.516, 0.536, 0.882, 0.921);
		end
		button.stripe:SetAllPoints()

		button:StyleButton()
		button:SetWidth(310)
	end

	S:HandleScrollBar(FriendsFramePendingScrollFrameScrollBar, 4)

	--Scroll of Resurrection
	ScrollOfResurrectionFrame:StripTextures()
	ScrollOfResurrectionFrame:SetTemplate("Transparent")

	ScrollOfResurrectionSelectionFrame:StripTextures()
	ScrollOfResurrectionSelectionFrame:SetTemplate("Transparent")

	ScrollOfResurrectionFrameNoteFrame:StripTextures()
	ScrollOfResurrectionFrameNoteFrame:SetTemplate("Default")

	ScrollOfResurrectionSelectionFrameList:StripTextures()
	ScrollOfResurrectionSelectionFrameList:SetTemplate("Default")

	ScrollOfResurrectionFrameTargetEditBox:SetTemplate("Default")
	ScrollOfResurrectionFrameTargetEditBoxLeft:SetTexture(nil)
	ScrollOfResurrectionFrameTargetEditBoxMiddle:SetTexture(nil)
	ScrollOfResurrectionFrameTargetEditBoxRight:SetTexture(nil)

	S:HandleEditBox(ScrollOfResurrectionSelectionFrameTargetEditBox)

	S:HandleButton(ScrollOfResurrectionFrameAcceptButton)
	S:HandleButton(ScrollOfResurrectionFrameCancelButton)

	S:HandleButton(ScrollOfResurrectionSelectionFrameAcceptButton)
	S:HandleButton(ScrollOfResurrectionSelectionFrameCancelButton)

	S:HandleScrollBar(ScrollOfResurrectionSelectionFrameListScrollFrameScrollBar, 4)

	FriendsTabHeaderSoRButton:SetTemplate("Default")
	FriendsTabHeaderSoRButton:StyleButton()
	FriendsTabHeaderSoRButton:Point("TOPRIGHT", FriendsTabHeader, "TOPRIGHT", -8, -56)

	FriendsTabHeaderSoRButtonIcon:ClearAllPoints()
	FriendsTabHeaderSoRButtonIcon:SetInside()
	FriendsTabHeaderSoRButtonIcon:SetTexCoord(unpack(E.TexCoords))
	FriendsTabHeaderSoRButtonIcon:SetDrawLayer("OVERLAY")

	-- Raid Info Frame
	for i = 1, 7 do
		_G["RaidInfoScrollFrameButton"..i]:StyleButton()
	end

	LFRQueueFrameListInset:StripTextures()
	LFRQueueFrameRoleInset:StripTextures()
	LFRQueueFrameCommentInset:StripTextures()

	RaidInfoFrame:StripTextures(true);
	RaidInfoFrame:SetTemplate("Transparent");

	RaidInfoFrame:ClearAllPoints()
	RaidInfoFrame:Point("TOPLEFT", RaidFrame, "TOPRIGHT", 1, 0)

	RaidInfoInstanceLabel:StripTextures();
	RaidInfoIDLabel:StripTextures();

	S:HandleCloseButton(RaidInfoCloseButton);
	RaidInfoCloseButton:Point("TOPRIGHT", 2, 0)

	S:HandleScrollBar(RaidInfoScrollFrameScrollBar);

	S:HandleButton(RaidInfoExtendButton);
	S:HandleButton(RaidInfoCancelButton);
	S:HandleButton(RaidFrameRaidInfoButton);

	--Bottom Tabs
	for i = 1, 4 do
		S:HandleTab(_G["FriendsFrameTab"..i])
	end

	--Friend List Class Colors
	local cc = {
		["HUNTER"] = "ABD473",
		["WARLOCK"] = "9482C9",
		["PRIEST"] = "FFFFFF",
		["PALADIN"] = "F58CBA",
		["MAGE"] = "69CCF0",
		["ROGUE"] = "FFF569",
		["DRUID"] = "FF7D0A",
		["SHAMAN"] = "1783D1",
		["WARRIOR"] = "C79C6E",
		["DEATHKNIGHT"] = "C41F3B",
		["MONK"] = "00FF96"
	}

	local locclasses = {}
	for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do locclasses[v] = k end
	for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do locclasses[v] = k end

	local updFunc = function()
	if(GetNumFriends() < 1) then return end
		local off, name, level, class, _, connected, _, _, tmp, tmpcol = FauxScrollFrame_GetOffset(FriendsFrameFriendsScrollFrame)
		for i = 1, GetNumFriends() do
			name, level, class, _, connected = GetFriendInfo(i)
			if(connected) then
				local friend = _G["FriendsFrameFriendsScrollFrameButton"..(i-off)]
				if(friend and friend.buttonType == FRIENDS_BUTTON_TYPE_WOW) then
					tmpcol = cc[(locclasses[class] or ""):gsub(" ",""):upper()]
					if((tmpcol or ""):len() > 0) then
						tmp = format("|cff%s%s%s, ", tmpcol, name, FONT_COLOR_CODE_CLOSE)
						tmp = tmp..format("|cff%s%s%d%s ", tmpcol, LEVEL.." ", level, FONT_COLOR_CODE_CLOSE)
						tmp = tmp..format("|cff%s%s%s ", tmpcol, class, FONT_COLOR_CODE_CLOSE)
						friend.name:SetText(tmp)
					end
				end
			end
		end
	end

	FriendsFrameFriendsScrollFrameScrollBar:HookScript("OnValueChanged", updFunc)

	for k,v in pairs({"FriendsList_Update", "FriendsFrame_UpdateFriends", "FriendsFramePendingScrollFrame_AdjustScroll"}) do
		hooksecurefunc(v, updFunc)
	end
end

S:AddCallback("Friends", LoadSkin);