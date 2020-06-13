local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local next, ipairs, pairs, select, unpack = next, ipairs, pairs, select, unpack

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.guild then return end

	GuildFrame:StripTextures(true)
	GuildFrame:SetTemplate("Transparent")

	GuildFrameInset:StripTextures()
	GuildFrameBottomInset:StripTextures()

	GuildLevelFrame:Kill()

	S:HandleCloseButton(GuildFrameCloseButton)

	-- Bottom Tabs
	for i = 1, 5 do
		S:HandleTab(_G["GuildFrameTab"..i])
	end

	-- XP Bar
	GuildXPFrame:ClearAllPoints()
	GuildXPFrame:Point("TOP", GuildFrame, "TOP", 0, -40)

	GuildXPBar:StripTextures()
	GuildXPBar:CreateBackdrop()
	GuildXPBar.backdrop:Point("TOPLEFT", GuildXPBar.progress, -1, 1)
	GuildXPBar.backdrop:Point("BOTTOMRIGHT", GuildXPBar, 3, 1)

	GuildXPBar.progress:SetTexture(E.media.normTex)

	-- Faction Bar
	GuildFactionFrame:CreateBackdrop()
	GuildFactionFrame.backdrop:Point("TOPLEFT")
	GuildFactionFrame.backdrop:Point("BOTTOMRIGHT", -1, 1)

	GuildFactionBar:StripTextures()
	GuildFactionBar:SetAllPoints(GuildFactionFrame)
	GuildFactionBar.progress:SetTexture(E.media.normTex)

	-- Guild Latest/Next Perks/Updates
	GuildNewPerksFrame:StripTextures()
	GuildAllPerksFrame:StripTextures()

	GuildPerksToggleButton:StripTextures()
	S:HandleButton(GuildPerksToggleButton)

	S:HandleScrollBar(GuildPerksContainerScrollBar, 4)

	if GuildLatestPerkButton then
		GuildLatestPerkButton:StripTextures()
		GuildLatestPerkButton:CreateBackdrop()
		GuildLatestPerkButton.backdrop:SetOutside(GuildLatestPerkButtonIconTexture)

		GuildLatestPerkButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
		GuildLatestPerkButtonIconTexture:Point("TOPLEFT", 2, -2)
	end

	if GuildNextPerkButton then
		GuildNextPerkButton:StripTextures()
		GuildNextPerkButton:CreateBackdrop()
		GuildNextPerkButton.backdrop:SetOutside(GuildNextPerkButtonIconTexture)

		GuildNextPerkButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
		GuildNextPerkButtonIconTexture:Point("TOPLEFT", 2, -3)
	end

	for i = 1, 9 do
		local button = _G["GuildUpdatesButton"..i]

		S:HandleButtonHighlight(button)
	end

	-- Perks/Rewards
	GuildRewardsFrame:StripTextures()

	GuildRewardsFrameVisitText:ClearAllPoints()
	GuildRewardsFrameVisitText:Point("TOP", GuildRewardsFrame, "TOP", 0, 30)

	GuildRewardsContainer:CreateBackdrop("Transparent")
	GuildRewardsContainer.backdrop:Point("TOPLEFT", -1, 0)
	GuildRewardsContainer.backdrop:Point("BOTTOMRIGHT", 0, -2)

	S:HandleScrollBar(GuildRewardsContainerScrollBar)
	GuildRewardsContainerScrollBar:ClearAllPoints()
	GuildRewardsContainerScrollBar:Point("TOPRIGHT", GuildRewardsContainer, 23, -16)
	GuildRewardsContainerScrollBar:Point("BOTTOMRIGHT", GuildRewardsContainer, 0, 14)

	for _, object in pairs({"Rewards", "Perks"}) do
		for i = 1, 8 do
			local button = _G["Guild"..object.."ContainerButton"..i]

			button:StripTextures()
			button:CreateBackdrop()
			button.backdrop:SetOutside(button.icon)

			S:HandleButtonHighlight(button, true)
			button.handledHighlight:Point("TOPLEFT", 0, -1)
			button.handledHighlight:Point("BOTTOMRIGHT", 0, 1)

			button.icon:SetTexCoord(unpack(E.TexCoords))
			button.icon:Point("TOPLEFT", 2, -2)
			button.icon:SetParent(button.backdrop)

			if object == "Rewards" then
				button.subText:SetTextColor(1, 0.80, 0.10)
				button.icon:Size(E.PixelMode and 43 or 40)
			elseif object == "Perks" then
				button.icon:Size(E.PixelMode and 40 or 38)
			end
		end
	end

	local function SkinGuildRewards()
		local offset = HybridScrollFrame_GetOffset(GuildRewardsContainer)
		local buttons = GuildRewardsContainer.buttons
		local button, index, itemID, quality, r, g, b

		for i = 1, #buttons do
			button = buttons[i]
			index = offset + i
			itemID = select(2, GetGuildRewardInfo(index))

			if itemID then
				quality = select(3, GetItemInfo(itemID))

				if quality then
					r, g, b = GetItemQualityColor(quality)

					button.backdrop:SetBackdropBorderColor(r, g, b)
					button.name:SetTextColor(r, g, b)
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
					button.name:SetTextColor(1, 1, 1)
				end
			end

			button.index = index
		end
	end
	hooksecurefunc("GuildRewards_Update", SkinGuildRewards)
	hooksecurefunc("HybridScrollFrame_Update", SkinGuildRewards)

	-- Roster
	for i = 1, 15 do
		local button = _G["GuildRosterContainerButton"..i]

		button:CreateBackdrop("Default", true)
		button.backdrop:SetAllPoints(button.icon)
		S:HandleButtonHighlight(button)

		button.icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
		button.icon:SetParent(button.backdrop)
		button.icon:Size(18)

		_G["GuildRosterContainerButton"..i.."BarTexture"]:SetTexture(E.media.normTex)
		S:HandleButton(_G["GuildRosterContainerButton"..i.."HeaderButton"], true)
	end

	local VIEW
	local function viewChanged(view)
		VIEW = view
	end
	hooksecurefunc("GuildRoster_SetView", viewChanged)

	local function update()
		VIEW = VIEW or GetCVar("guildRosterView")
		local playerArea = GetRealZoneText()
		local buttons = GuildRosterContainer.buttons

		for _, button in ipairs(buttons) do
			if button:IsShown() and button.online and button.guildIndex then
				if VIEW == "tradeskill" then
					local _, _, _, headerName, _, _, _, playerName, _, _, zone = GetGuildTradeSkillInfo(button.guildIndex)
					if not headerName and playerName then
						if zone == playerArea then
							button.string2:SetText("|cff00ff00"..zone)
						end
					end
				else
					local _, _, _, level, _, zone = GetGuildRosterInfo(button.guildIndex)
					local levelTextColor = GetQuestDifficultyColor(level)

					if VIEW == "playerStatus" then
						button.string1:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b)
						if zone == playerArea then
							button.string3:SetText("|cff00ff00"..zone)
						end
					elseif VIEW == "achievement" or VIEW == "weeklyxp" or VIEW == "totalxp" then
						button.string1:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b)
					end
				end
			end

			if button.backdrop then
				if button.icon:IsShown() then
					button.backdrop:Show()
				else
					button.backdrop:Hide()
				end
			end
		end
	end
	hooksecurefunc("GuildRoster_Update", update)
	hooksecurefunc(GuildRosterContainer, "update", update)

	for i = 1, 4 do
		local frame = _G["GuildRosterColumnButton"..i]

		frame:StripTextures(true)
		frame:StyleButton()
	end

	S:HandleDropDownBox(GuildRosterViewDropdown, 200)

	S:HandleScrollBar(GuildRosterContainerScrollBar, 5)

	S:HandleCheckBox(GuildRosterShowOfflineButton)

	-- Guild Member
	GuildMemberNoteBackground:StripTextures()
	GuildMemberNoteBackground:SetTemplate("Transparent")

	GuildMemberOfficerNoteBackground:StripTextures()
	GuildMemberOfficerNoteBackground:SetTemplate("Transparent")

	S:HandleDropDownBox(GuildMemberRankDropdown, 175)
	GuildMemberRankDropdown:SetFrameLevel(GuildMemberRankDropdown:GetFrameLevel() + 5)
	GuildMemberRankDropdown:ClearAllPoints()
	GuildMemberRankDropdown:Point("CENTER", GuildMemberDetailFrame, "CENTER", 18, 45)

	S:HandleButton(GuildMemberGroupInviteButton)

	S:HandleButton(GuildMemberRemoveButton)
	GuildMemberRemoveButton:Point("BOTTOMLEFT", 9, 4)

	-- Guild Member Detail
	GuildMemberDetailFrame:StripTextures()
	GuildMemberDetailFrame:SetTemplate("Transparent")
	GuildMemberDetailFrame:Point("TOPLEFT", GuildFrame, "TOPRIGHT", 1, 0)

	S:HandleCloseButton(GuildMemberDetailCloseButton)
	GuildMemberDetailCloseButton:Point("TOPRIGHT", 2, 2)

	-- Guild News
	GuildNewsFrame:StripTextures()

	GuildNewsContainer:CreateBackdrop("Transparent")
	GuildNewsContainer.backdrop:Point("TOPLEFT", -1, 2)
	GuildNewsContainer.backdrop:Point("BOTTOMRIGHT", 1, -3)

	GuildNewsBossModel:StripTextures()
	GuildNewsBossModel:CreateBackdrop("Transparent")
	GuildNewsBossModel:Point("TOPLEFT", GuildFrame, "TOPRIGHT", 4, -43)

	GuildNewsBossModelTextFrame:StripTextures()
	GuildNewsBossModelTextFrame:CreateBackdrop()
	GuildNewsBossModelTextFrame.backdrop:Point("TOPLEFT", GuildNewsBossModel.backdrop, "BOTTOMLEFT", 0, -1)

	for i = 1, 18 do
		local button = _G["GuildNewsContainerButton"..i]

		if button then
			button.header:Kill()

			S:HandleButtonHighlight(button)
		end
	end

	S:HandleScrollBar(GuildNewsContainerScrollBar, 4)
	GuildNewsContainerScrollBar:Point("TOPLEFT", GuildNewsContainer, "TOPRIGHT", 4, -17)

	-- Guild News Filter
	GuildNewsFiltersFrame:StripTextures()
	GuildNewsFiltersFrame:SetTemplate("Transparent")
	GuildNewsFiltersFrame:Point("TOPLEFT", GuildFrame, "TOPRIGHT", 1, 0)

	for i = 1, 7 do
		S:HandleCheckBox(_G["GuildNewsFilterButton"..i])
	end

	S:HandleButton(GuildGMImpeachButton)

	S:HandleCloseButton(GuildNewsFiltersFrameCloseButton)
	GuildNewsFiltersFrameCloseButton:Point("TOPRIGHT", 2, 2)

	-- Guild Info
	GuildInfoFrameInfo:StripTextures()
	GuildInfoFrameApplicants:StripTextures()
	GuildInfoFrameApplicantsContainer:StripTextures()

	S:HandleScrollBar(GuildInfoDetailsFrameScrollBar, 4)
	S:HandleScrollBar(GuildInfoFrameApplicantsContainerScrollBar)

	S:HandleButton(GuildViewLogButton)
	S:HandleButton(GuildControlButton)
	S:HandleButton(GuildAddMemberButton)

	for _, button in next, GuildInfoFrameApplicantsContainer.buttons do
		button:SetBackdrop(nil)
		button:GetHighlightTexture():Kill()

		button:StripTextures()
		button:CreateBackdrop("Transparent")
		button.backdrop:SetAllPoints()
		button:StyleButton()

		button.bg = CreateFrame("Frame", nil, button)
		button.bg:SetTemplate("Default", true)
		button.bg:SetOutside(button.class)

		button.class:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
		button.class:SetParent(button.bg)

		button.selectedTex:SetTexture(1, 1, 1, 0.3)
		button.selectedTex:SetInside()

		button.name:Point("TOPLEFT", 75, -10)
		button.name:SetParent(button.backdrop)

		button.level:Point("TOPLEFT", 58, -10)
		button.level:SetParent(button.backdrop)

		button.comment:SetParent(button.backdrop)
		button.comment:Point("BOTTOMRIGHT", 0, 0)

		button.fullComment:SetParent(button.backdrop)
		button.timeLeft:SetParent(button.backdrop)

		button.tankTex:SetTexture(E.Media.Textures.Tank)
		button.tankTex:SetTexCoord(unpack(E.TexCoords))
		button.tankTex:Size(20)
		button.tankTex:SetParent(button.backdrop)

		button.healerTex:SetTexture(E.Media.Textures.Healer)
		button.healerTex:SetTexCoord(unpack(E.TexCoords))
		button.healerTex:Size(18)
		button.healerTex:SetParent(button.backdrop)

		button.damageTex:SetTexture(E.Media.Textures.DPS)
		button.damageTex:SetTexCoord(unpack(E.TexCoords))
		button.damageTex:Size(16)
		button.damageTex:SetParent(button.backdrop)
	end

	local function SkinGuildApplicants()
		local scrollFrame = GuildInfoFrameApplicantsContainer
		local offset = HybridScrollFrame_GetOffset(scrollFrame)
		local buttons = scrollFrame.buttons
		local numButtons = #buttons
		local button, index

		for i = 1, numButtons do
			button = buttons[i]
			index = offset + i
			local name, level, class = GetGuildApplicantInfo(index)
			if name then
				local classTextColor = E:ClassColor(class)
				local levelTextColor = GetQuestDifficultyColor(level)

				button.name:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
				button.level:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b)
				button.bg:SetBackdropBorderColor(classTextColor.r, classTextColor.g, classTextColor.b)
			end
		end
	end
	hooksecurefunc("GuildInfoFrameApplicants_Update", SkinGuildApplicants)
	hooksecurefunc("HybridScrollFrame_Update", SkinGuildApplicants)

	GuildInfoFrameTab1:Point("TOPLEFT", 55, 33)

	for i = 1, 3 do
		local headerTab = _G["GuildInfoFrameTab"..i]
		headerTab:StripTextures()
		headerTab.backdrop = CreateFrame("Frame", nil, headerTab)
		headerTab.backdrop:SetTemplate("Default", true)
		headerTab.backdrop:Point("TOPLEFT", 3, -7)
		headerTab.backdrop:Point("BOTTOMRIGHT", -2, -1)
		headerTab.backdrop:SetFrameLevel(headerTab:GetFrameLevel() - 1)

		headerTab:HookScript("OnEnter", S.SetModifiedBackdrop)
		headerTab:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	local backdrop1 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	backdrop1:SetTemplate()
	backdrop1:Point("TOPLEFT", 2, -22)
	backdrop1:Point("BOTTOMRIGHT", 0, 200)
	backdrop1:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)

	local backdrop2 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	backdrop2:SetTemplate()
	backdrop2:Point("TOPLEFT", 2, -160)
	backdrop2:Point("BOTTOMRIGHT", 0, 118)
	backdrop2:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)

	local backdrop3 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	backdrop3:SetTemplate()
	backdrop3:Point("TOPLEFT", 2, -235)
	backdrop3:Point("BOTTOMRIGHT", 0, 3)
	backdrop3:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)

	-- Text Edit Frame
	GuildTextEditFrame:StripTextures()
	GuildTextEditFrame:SetTemplate("Transparent")

	GuildTextEditContainer:StripTextures()
	GuildTextEditContainer:SetTemplate("Transparent")

	S:HandleButton(GuildTextEditFrameAcceptButton)

	S:HandleScrollBar(GuildTextEditScrollFrameScrollBar, 5)

	for i = 1, GuildTextEditFrame:GetNumChildren() do
		local child = select(i, GuildTextEditFrame:GetChildren())
		if (child:GetName() == "GuildTextEditFrameCloseButton") and child:GetWidth() < 33 then
			S:HandleCloseButton(child)
		elseif child:GetName() == "GuildTextEditFrameCloseButton" then
			S:HandleButton(child, true)
		end
	end

	-- Guild Log
	S:HandleScrollBar(GuildLogScrollFrameScrollBar, 4)

	GuildLogScrollFrameScrollBar:ClearAllPoints()
	GuildLogScrollFrameScrollBar:Point("TOPLEFT", GuildLogScrollFrame, "TOPRIGHT", 26, -13)
	GuildLogScrollFrameScrollBar:Point("BOTTOMRIGHT", GuildLogScrollFrame, "BOTTOMRIGHT", 0, 12)

	GuildLogFrame:StripTextures()
	GuildLogFrame:CreateBackdrop("Transparent")
	GuildLogFrame.backdrop:Point("TOPLEFT", 15, 0)
	GuildLogFrame.backdrop:Point("BOTTOMRIGHT", -15, 0)
	GuildLogFrame:Point("TOPLEFT", GuildFrame, "TOPRIGHT", -10, 0)

	GuildLogContainer:StripTextures()

	GuildLogScrollFrame:CreateBackdrop("Transparent")
	GuildLogScrollFrame.backdrop:Point("TOPLEFT", -2, 2)
	GuildLogScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -3)

	for i = 1, GuildLogFrame:GetNumChildren() do
		local child = select(i, GuildLogFrame:GetChildren())
		if (child:GetName() == "GuildLogFrameCloseButton") and child:GetWidth() < 33 then
			S:HandleCloseButton(child)
			child:Point("TOPRIGHT", -10, 5)
		elseif child:GetName() == "GuildLogFrameCloseButton" then
			S:HandleButton(child, true)
			child:Point("BOTTOMRIGHT", -25, 16)
		end
	end

	-- Guild Recruitment
	GuildRecruitmentRolesFrame:StripTextures()
	GuildRecruitmentLevelFrame:StripTextures()
	GuildRecruitmentCommentFrame:StripTextures()
	GuildRecruitmentInterestFrame:StripTextures()
	GuildRecruitmentAvailabilityFrame:StripTextures()

	GuildRecruitmentCommentInputFrame:StripTextures()
	GuildRecruitmentCommentInputFrame:SetTemplate()

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
		local button = _G[roleIcons[i]]
		local icon = button:GetNormalTexture()

		button:StripTextures()
		button:CreateBackdrop()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside(button.backdrop)

		S:HandleCheckBox(button.checkButton)
		button.checkButton:Point("BOTTOMLEFT", -5, -5)
		button.checkButton:SetFrameLevel(button.checkButton:GetFrameLevel() + 2)
	end

	GuildRecruitmentTankButton:SetNormalTexture("Interface\\Icons\\Ability_Defend")
	GuildRecruitmentHealerButton:SetNormalTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")
	GuildRecruitmentDamagerButton:SetNormalTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")
end

S:AddCallbackForAddon("Blizzard_GuildUI", "Guild", LoadSkin)

local function LoadSecondarySkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.guild then return end

	-- Guild Invitation PopUp Frame
	GuildInviteFrame:SetTemplate("Transparent")
	GuildInviteFrameBg:Kill()
	GuildInviteFrameTopLeftCorner:Kill()
	GuildInviteFrameTopRightCorner:Kill()
	GuildInviteFrameBottomLeftCorner:Kill()
	GuildInviteFrameBottomRightCorner:Kill()
	GuildInviteFrameTopBorder:Kill()
	GuildInviteFrameBottomBorder:Kill()
	GuildInviteFrameLeftBorder:Kill()
	GuildInviteFrameRightBorder:Kill()
	GuildInviteFrameBackground:Kill()
	GuildInviteFrameTabardRing:Kill()
	GuildInviteFrameLevel:StripTextures()

	S:HandleButton(GuildInviteFrameJoinButton)
	S:HandleButton(GuildInviteFrameDeclineButton)
end

S:AddCallback("GuildInvite", LoadSecondarySkin)