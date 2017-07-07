local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local _G = _G;
local ipairs, pairs, unpack, select = ipairs, pairs, unpack, select;

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.guild ~= true then return end

	GuildFrame:StripTextures(true)
	GuildFrame:SetTemplate("Transparent")

	GuildFrameInset:StripTextures()
	GuildFrameBottomInset:StripTextures()

	GuildLevelFrame:Kill()

	S:HandleCloseButton(GuildFrameCloseButton)

	--Bottom Tabs
	for i = 1, 5 do
		S:HandleTab(_G["GuildFrameTab"..i])
	end

	--XP Bar
	GuildXPFrame:ClearAllPoints()
	GuildXPFrame:Point("TOP", GuildFrame, "TOP", 0, -40)

	GuildXPBarLeft:Kill()
	GuildXPBarRight:Kill()
	GuildXPBarMiddle:Kill()
	GuildXPBarBG:Kill()
	GuildXPBarShadow:Kill()
	GuildXPBarCap:Kill()
	GuildXPBarCapMarker:Kill()

	for i = 1, 4 do
		_G["GuildXPBarDivider"..i]:Kill()
	end

	GuildXPBar:CreateBackdrop("Default")
	GuildXPBar.backdrop:Point("TOPLEFT", GuildXPBar, "TOPLEFT", 0, -3)
	GuildXPBar.backdrop:Point("BOTTOMRIGHT", GuildXPBar, "BOTTOMRIGHT", -1, 1)
	GuildXPBar.progress:SetTexture(E["media"].normTex)

	--Faction Bar
	GuildFactionFrame:SetTemplate("Default")

	GuildFactionBar:StripTextures()
	GuildFactionBar:SetAllPoints(GuildFactionFrame)
	GuildFactionBar.progress:SetTexture(E["media"].normTex)

	--Guild Latest/Next Perks/Updates
	GuildNewPerksFrame:StripTextures()
	GuildAllPerksFrame:StripTextures()

	GuildPerksToggleButton:StripTextures()
	S:HandleButton(GuildPerksToggleButton)

	S:HandleScrollBar(GuildPerksContainerScrollBar, 4)

	if(GuildLatestPerkButton) then
		GuildLatestPerkButton:StripTextures()
		GuildLatestPerkButton:CreateBackdrop("Default")
		GuildLatestPerkButton.backdrop:SetOutside(GuildLatestPerkButtonIconTexture)
		GuildLatestPerkButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
		GuildLatestPerkButtonIconTexture:Point("TOPLEFT", 2, -2)
	end

	if(GuildNextPerkButton) then
		GuildNextPerkButton:StripTextures()
		GuildNextPerkButton:CreateBackdrop("Default")
		GuildNextPerkButton.backdrop:SetOutside(GuildNextPerkButtonIconTexture)
		GuildNextPerkButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
		GuildNextPerkButtonIconTexture:Point("TOPLEFT", 2, -3)
	end

	for i = 1, 7 do
		_G["GuildUpdatesButton"..i]:StyleButton()
	end

	--Perks/Rewards
	GuildRewardsFrame:StripTextures()

	GuildRewardsFrameVisitText:ClearAllPoints()
	GuildRewardsFrameVisitText:Point("TOP", GuildRewardsFrame, "TOP", 0, 30)

	S:HandleScrollBar(GuildRewardsContainerScrollBar, 5)

	for i = 1, 8 do
		local Rewards = _G["GuildRewardsContainerButton"..i];
		local Perks =  _G["GuildPerksContainerButton"..i];

		Perks.icon:Size(E.PixelMode and 40 or 38);
		Rewards.icon:Size(E.PixelMode and 43 or 40);
	end

	for _, Object in pairs({"Rewards", "Perks"}) do
		for i = 1, 8 do
			local Button = _G["Guild"..Object.."ContainerButton"..i];
			local Name = _G["Guild"..Object.."ContainerButton"..i.."Name"];
			local SubText = _G["Guild"..Object.."ContainerButton"..i.."SubText"];

			Button:StripTextures();
			Button:CreateBackdrop("Default");
			Button.backdrop:SetOutside(Button.icon);

			Button:StyleButton(nil, true);

			Button.icon:SetTexCoord(unpack(E.TexCoords));
			Button.icon:Point("TOPLEFT", 2, -2);
			Button.icon:SetParent(Button.backdrop);

			if(Object == "Rewards") then
				SubText:SetTextColor(1, 0.80, 0.10);
				Button.backdrop:HookScript("OnUpdate", function(self)
					local _, itemID = GetGuildRewardInfo(Button.index);
					if(itemID) then
						local quality = select(3, GetItemInfo(itemID));
						if(quality and quality > 1) then
							self:SetBackdropBorderColor(GetItemQualityColor(quality));
							Name:SetTextColor(GetItemQualityColor(quality));
						else
							self:SetBackdropBorderColor(unpack(E["media"].bordercolor));
							Name:SetTextColor(1, 1, 1);
						end
					end
				end);
			end
		end
	end

	--Roster
	for i = 1, 15 do
		local button = _G["GuildRosterContainerButton"..i];
		local icon = _G["GuildRosterContainerButton"..i.."Icon"];

		button:CreateBackdrop("Default", true);
		button.backdrop:SetAllPoints(icon);
		button:StyleButton();

		icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes");
		icon:SetParent(button.backdrop);
		icon:Size(18);

		_G["GuildRosterContainerButton"..i.."BarTexture"]:SetTexture(E["media"].normTex);
		S:HandleButton(_G["GuildRosterContainerButton"..i.."HeaderButton"], true);
	end

	local VIEW;
	local function viewChanged(view)
		VIEW = view;
	end
	hooksecurefunc("GuildRoster_SetView", viewChanged)

	local function update()
		VIEW = VIEW or GetCVar("guildRosterView");
		local playerArea = GetRealZoneText();
		local buttons = GuildRosterContainer.buttons;

		for i, button in ipairs(buttons) do
			if(button:IsShown() and button.online and button.guildIndex) then
				if(VIEW == "tradeskill") then
					local _, _, _, headerName, _, _, _, playerName, _, _, zone = GetGuildTradeSkillInfo(button.guildIndex);
					if(not headerName and playerName) then
						if(zone == playerArea) then
							button.string2:SetText("|cff00ff00"..zone);
						end
					end
				else
					local _, _, _, level, _, zone = GetGuildRosterInfo(button.guildIndex);
					local levelTextColor = GetQuestDifficultyColor(level);

					if(VIEW == "playerStatus") then
						button.string1:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b);
						if(zone == playerArea) then
							button.string3:SetText("|cff00ff00"..zone);
						end
					elseif(VIEW == "achievement") then
						button.string1:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b);
					elseif(VIEW == "weeklyxp" or VIEW == "totalxp") then
						button.string1:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b);
					end
				end
			end
		end

		for i = 1, 15 do
			local icon = _G["GuildRosterContainerButton"..i.."Icon"];
			local backdrop = _G["GuildRosterContainerButton"..i].backdrop;

			if(icon:IsShown()) then
				backdrop:Show();
			else
				backdrop:Hide();
			end
		end
	end
	hooksecurefunc("GuildRoster_Update", update)
	hooksecurefunc(GuildRosterContainer, "update", update)

	for i = 1, 4 do
		_G["GuildRosterColumnButton"..i]:StripTextures(true)
		_G["GuildRosterColumnButton"..i]:StyleButton()
	end

	S:HandleDropDownBox(GuildRosterViewDropdown, 200)

	S:HandleScrollBar(GuildRosterContainerScrollBar, 5)

	S:HandleCheckBox(GuildRosterShowOfflineButton)

	--Guild Member
	GuildMemberNoteBackground:StripTextures()
	GuildMemberNoteBackground:SetTemplate("Transparent")

	GuildMemberOfficerNoteBackground:StripTextures()
	GuildMemberOfficerNoteBackground:SetTemplate("Transparent")

	GuildMemberRankDropdown:SetFrameLevel(GuildMemberRankDropdown:GetFrameLevel() + 5)
	GuildMemberRankDropdown:ClearAllPoints()
	GuildMemberRankDropdown:Point("CENTER", GuildMemberDetailFrame, "CENTER", 8, 42)

	S:HandleButton(GuildMemberGroupInviteButton)

	S:HandleButton(GuildMemberRemoveButton)
	GuildMemberRemoveButton:Point("BOTTOMLEFT", 9, 4)

	S:HandleDropDownBox(GuildMemberRankDropdown, 175)

	--Guild Member Detail
	GuildMemberDetailFrame:StripTextures()
	GuildMemberDetailFrame:SetTemplate("Transparent")
	GuildMemberDetailFrame:Point("TOPLEFT", GuildFrame, "TOPRIGHT", 1, 0)

	S:HandleCloseButton(GuildMemberDetailCloseButton)
	GuildMemberDetailCloseButton:Point("TOPRIGHT", 2, 2)

	--Guild News
	GuildNewsFrame:StripTextures()

	GuildNewsContainer:SetTemplate("Transparent")

	GuildNewsBossModel:StripTextures()
	GuildNewsBossModel:CreateBackdrop("Transparent")
	GuildNewsBossModel:Point("TOPLEFT", GuildFrame, "TOPRIGHT", 4, -43)

	GuildNewsBossModelTextFrame:StripTextures()
	GuildNewsBossModelTextFrame:CreateBackdrop("Default")
	GuildNewsBossModelTextFrame.backdrop:Point("TOPLEFT", GuildNewsBossModel.backdrop, "BOTTOMLEFT", 0, -1)

	for i = 1, 17 do
		if _G["GuildNewsContainerButton"..i] then
			_G["GuildNewsContainerButton"..i].header:Kill()
			_G["GuildNewsContainerButton"..i]:StyleButton()
		end
	end

	S:HandleScrollBar(GuildNewsContainerScrollBar, 4)

	--Guild News Filter
	GuildNewsFiltersFrame:StripTextures()
	GuildNewsFiltersFrame:SetTemplate("Transparent")
	GuildNewsFiltersFrame:Point("TOPLEFT", GuildFrame, "TOPRIGHT", 1, 0)

	for i = 1, 7 do
		S:HandleCheckBox(_G["GuildNewsFilterButton"..i])
	end

	GuildGMImpeachButton:StyleButton()

	S:HandleCloseButton(GuildNewsFiltersFrameCloseButton)
	GuildNewsFiltersFrameCloseButton:Point("TOPRIGHT", 2, 2)

	--Guild Info
	GuildInfoFrameInfo:StripTextures()
	GuildInfoFrameApplicants:StripTextures()
	GuildInfoFrameApplicantsContainer:StripTextures()

	S:HandleScrollBar(GuildInfoDetailsFrameScrollBar, 4)
	S:HandleScrollBar(GuildInfoFrameApplicantsContainerScrollBar)

	S:HandleButton(GuildViewLogButton)
	S:HandleButton(GuildControlButton)
	S:HandleButton(GuildAddMemberButton)

	for _, button in next, GuildInfoFrameApplicantsContainer.buttons do
		button:SetBackdrop(nil);
		button:GetHighlightTexture():Kill();

		button:StripTextures();
		button:CreateBackdrop("Transparent");
		button.backdrop:SetAllPoints();
		button:StyleButton();

		button.bg = CreateFrame("Frame", nil, button);
		button.bg:SetTemplate("Default", true);
		button.bg:Point("TOPLEFT", button.class, 1, -1);
		button.bg:Point("BOTTOMRIGHT", button.class, -1, 1);

		button.class:SetTexture("Interface\\WorldStateFrame\\Icons-Classes");
		button.class:SetParent(button.bg);

		button.selectedTex:SetTexture(1, 1, 1, 0.3);
		button.selectedTex:SetInside();

		button.name:Point("TOPLEFT", 75, -10);
		button.name:SetParent(button.backdrop);

		button.level:Point("TOPLEFT", 58, -10);
		button.level:SetParent(button.backdrop);

		button.timeLeft:Point("LEFT", button.name, "RIGHT", -50, 0);
		button.timeLeft:SetParent(button.backdrop);

		button.comment:SetParent(button.backdrop);
		button.comment:Point("BOTTOMRIGHT", 0, 0)

		button.fullComment:SetParent(button.backdrop);

		button.tankTex:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\tank.tga");
		button.tankTex:SetTexCoord(unpack(E.TexCoords));
		button.tankTex:Size(20);
		button.tankTex:SetParent(button.backdrop);

		button.healerTex:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\healer.tga");
		button.healerTex:SetTexCoord(unpack(E.TexCoords));
		button.healerTex:Size(18);
		button.healerTex:SetParent(button.backdrop);

		button.damageTex:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\dps.tga");
		button.damageTex:SetTexCoord(unpack(E.TexCoords));
		button.damageTex:Size(16);
		button.damageTex:SetParent(button.backdrop);
	end

	--[[hooksecurefunc("GuildInfoFrameApplicants_Update", function()
		local scrollFrame = GuildInfoFrameApplicantsContainer;
		local offset = HybridScrollFrame_GetOffset(scrollFrame);
		local buttons = scrollFrame.buttons;
		local numButtons = #buttons;
		local button, index;

		for i = 1, numButtons do
			button = buttons[i];
			index = offset + i;
			local name, level, class = GetGuildApplicantInfo(index);
			if(name) then
				local classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class];
				local levelTextColor = GetQuestDifficultyColor(level);

				button.name:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
				button.level:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b);
			end
		end
	end)]]

	GuildInfoFrameTab1:Point("TOPLEFT", 55, 33)

	for i = 1, 3 do
		local headerTab = _G["GuildInfoFrameTab"..i]
		headerTab:StripTextures()
		headerTab.backdrop = CreateFrame("Frame", nil, headerTab)
		headerTab.backdrop:SetTemplate("Default", true)
		headerTab.backdrop:Point("TOPLEFT", 3, -7)
		headerTab.backdrop:Point("BOTTOMRIGHT", -2, -1)
		headerTab.backdrop:SetFrameLevel(headerTab:GetFrameLevel() - 1)

		headerTab:HookScript("OnEnter", S.SetModifiedBackdrop);
		headerTab:HookScript("OnLeave", S.SetOriginalBackdrop);
	end

	local backdrop1 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	backdrop1:SetTemplate("Default")
	backdrop1:Point("TOPLEFT", 2, -25)
	backdrop1:Point("BOTTOMRIGHT", 0, 200)
	backdrop1:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)

	local backdrop2 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	backdrop2:SetTemplate("Default")
	backdrop2:Point("TOPLEFT", 2, -161)
	backdrop2:Point("BOTTOMRIGHT", 0, 118)
	backdrop2:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)

	local backdrop3 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	backdrop3:SetTemplate("Default")
	backdrop3:Point("TOPLEFT", 2, -237)
	backdrop3:Point("BOTTOMRIGHT", 0, 3)
	backdrop3:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)

	--Text Edit Frame
	GuildTextEditFrame:StripTextures()
	GuildTextEditFrame:SetTemplate("Transparent")

	GuildTextEditContainer:StripTextures()
	GuildTextEditContainer:SetTemplate("Transparent")

	S:HandleButton(GuildTextEditFrameAcceptButton)

	S:HandleScrollBar(GuildTextEditScrollFrameScrollBar, 5)

	for i = 1, GuildTextEditFrame:GetNumChildren() do
		local child = select(i, GuildTextEditFrame:GetChildren())
		if(child:GetName() == "GuildTextEditFrameCloseButton" and child:GetWidth() < 33) then
			S:HandleCloseButton(child)
		elseif(child:GetName() == "GuildTextEditFrameCloseButton") then
			S:HandleButton(child, true)
		end
	end

	--Guild Log
	S:HandleScrollBar(GuildLogScrollFrameScrollBar, 4)

	GuildLogFrame:StripTextures()
	GuildLogFrame:SetTemplate("Transparent")

	GuildLogContainer:StripTextures()

	GuildLogScrollFrame:SetTemplate("Transparent")

	for i = 1, GuildLogFrame:GetNumChildren() do
		local child = select(i, GuildLogFrame:GetChildren())
		if(child:GetName() == "GuildLogFrameCloseButton" and child:GetWidth() < 33) then
			S:HandleCloseButton(child)
		elseif(child:GetName() == "GuildLogFrameCloseButton") then
			S:HandleButton(child, true)
		end
	end

	-- Guild Recruitment
	GuildRecruitmentRolesFrame:StripTextures()
	GuildRecruitmentLevelFrame:StripTextures()
	GuildRecruitmentCommentFrame:StripTextures()
	GuildRecruitmentInterestFrame:StripTextures()
	GuildRecruitmentAvailabilityFrame:StripTextures()

	GuildRecruitmentCommentInputFrame:StripTextures()
	GuildRecruitmentCommentInputFrame:SetTemplate("Default")

	S:HandleScrollBar(GuildRecruitmentCommentInputFrameScrollFrameScrollBar)

	S:HandleButton(GuildRecruitmentInviteButton)
	S:HandleButton(GuildRecruitmentMessageButton)
	S:HandleButton(GuildRecruitmentDeclineButton)
	S:HandleButton(GuildRecruitmentListGuildButton)

	S:HandleCheckBox(GuildRecruitmentQuestButton)
	S:HandleCheckBox(GuildRecruitmentDungeonButton)
	S:HandleCheckBox(GuildRecruitmentRaidButton)
	S:HandleCheckBox(GuildRecruitmentPvPButton)
	S:HandleCheckBox(GuildRecruitmentRPButton)
	S:HandleCheckBox(GuildRecruitmentWeekdaysButton)
	S:HandleCheckBox(GuildRecruitmentWeekendsButton)
	S:HandleCheckBox(GuildRecruitmentLevelAnyButton)
	S:HandleCheckBox(GuildRecruitmentLevelMaxButton)

	local roleIcons = {
		"GuildRecruitmentTankButton",
		"GuildRecruitmentHealerButton",
		"GuildRecruitmentDamagerButton"
	}

	for i = 1, #roleIcons do
		S:HandleCheckBox(_G[roleIcons[i]]:GetChildren())
		_G[roleIcons[i]]:GetChildren():SetFrameLevel(_G[roleIcons[i]]:GetChildren():GetFrameLevel() + 2)

		_G[roleIcons[i]]:StripTextures()
		_G[roleIcons[i]]:CreateBackdrop()
		_G[roleIcons[i]].backdrop:Point("TOPLEFT", 2, -2)
		_G[roleIcons[i]].backdrop:Point("BOTTOMRIGHT", -2, 2)

		_G[roleIcons[i]].icon = _G[roleIcons[i]]:CreateTexture(nil, "ARTWORK")
		_G[roleIcons[i]].icon:SetTexCoord(unpack(E.TexCoords))
		_G[roleIcons[i]].icon:SetInside(_G[roleIcons[i]].backdrop)
	end

	GuildRecruitmentTankButton.icon:SetTexture("Interface\\Icons\\Ability_Defend")
	GuildRecruitmentHealerButton.icon:SetTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")
	GuildRecruitmentDamagerButton.icon:SetTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")
end

S:AddCallbackForAddon("Blizzard_GuildUI", "Guild", LoadSkin);