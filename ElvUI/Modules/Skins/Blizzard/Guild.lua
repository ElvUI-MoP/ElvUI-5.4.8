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
	GuildXPFrame:Point("TOP", GuildFrame, 0, -40)

	GuildXPBar:StripTextures()
	GuildXPBar:CreateBackdrop()
	GuildXPBar.backdrop:Point("TOPLEFT", GuildXPBar.progress, -1, 1)
	GuildXPBar.backdrop:Point("BOTTOMRIGHT", GuildXPBar, 3, 1)
	GuildXPBar.progress:SetTexture(E.media.normTex)

	GuildXPBarCap:SetTexture(E.media.normTex)

	GuildXPBarCapMarker:Size(4, E.PixelMode and 14 or 12)
	GuildXPBarCapMarker:SetTexture(1, 1, 1, 0.40)

	-- Faction Bar
	GuildFactionFrame:CreateBackdrop()
	GuildFactionFrame.backdrop:Point("TOPLEFT")
	GuildFactionFrame.backdrop:Point("BOTTOMRIGHT", -1, 1)

	GuildFactionBar:StripTextures()
	GuildFactionBar:SetAllPoints(GuildFactionFrame)
	GuildFactionBar.progress:SetTexture(E.media.normTex)

	GuildFactionBarCap:SetTexture(E.media.normTex)

	GuildFactionBarCapMarker:Size(4, E.PixelMode and 14 or 12)
	GuildFactionBarCapMarker:SetTexture(1, 1, 1, 0.40)

	GuildFactionBarLabel:Point("CENTER")

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
		S:HandleButtonHighlight(_G["GuildUpdatesButton"..i])
	end

	-- Perks/Rewards
	GuildRewardsFrame:StripTextures()

	GuildRewardsFrameVisitText:ClearAllPoints()
	GuildRewardsFrameVisitText:Point("TOP", GuildRewardsFrame, 0, 30)

	GuildRewardsContainer:CreateBackdrop("Transparent")
	GuildRewardsContainer.backdrop:Point("TOPLEFT", -1, E.PixelMode and 0 or 1)
	GuildRewardsContainer.backdrop:Point("BOTTOMRIGHT", 0, E.PixelMode and -2 or -3)

	S:HandleScrollBar(GuildRewardsContainerScrollBar)
	GuildRewardsContainerScrollBar:ClearAllPoints()
	GuildRewardsContainerScrollBar:Point("TOPRIGHT", GuildRewardsContainer, 23, E.PixelMode and -16 or -15)
	GuildRewardsContainerScrollBar:Point("BOTTOMRIGHT", GuildRewardsContainer, 0, E.PixelMode and 14 or 13)

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
					button.handledHighlight:SetVertexColor(r, g, b)
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
					button.name:SetTextColor(1, 1, 1)
					button.handledHighlight:SetVertexColor(1, 1, 1)
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

		button.icon:SetTexture([[Interface\WorldStateFrame\Icons-Classes]])
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
				button.backdrop:SetShown(button.icon:IsShown())
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
	GuildMemberRankDropdown:Point("CENTER", GuildMemberDetailFrame, 18, 45)

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

	GuildNewsSetFiltersButton:Point("RIGHT", GuildNewsFrameHeader, "RIGHT", -18, 2)

	GuildNewsContainer:CreateBackdrop("Transparent")
	GuildNewsContainer.backdrop:Point("TOPLEFT", -1, 1)
	GuildNewsContainer.backdrop:Point("BOTTOMRIGHT", 1, -2)

	S:HandleScrollBar(GuildNewsContainerScrollBar)
	GuildNewsContainerScrollBar:ClearAllPoints()
	GuildNewsContainerScrollBar:Point("TOPRIGHT", GuildNewsContainer, 26, -14)
	GuildNewsContainerScrollBar:Point("BOTTOMRIGHT", GuildNewsContainer, 0, 13)

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
	for i = 1, 3 do
		local tab = _G["GuildInfoFrameTab"..i]

		tab:StripTextures()
		tab.backdrop = CreateFrame("Frame", nil, tab)
		tab.backdrop:SetTemplate("Default", true)
		tab.backdrop:Point("TOPLEFT", 3, -7)
		tab.backdrop:Point("BOTTOMRIGHT", -2, -1)
		tab.backdrop:SetFrameLevel(tab:GetFrameLevel() - 1)

		if i == 1 then
			tab:Point("TOPLEFT", 40, 40)
		end

		tab:HookScript("OnEnter", S.SetModifiedBackdrop)
		tab:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	-- Info Tab
	GuildInfoFrameInfo:StripTextures()

	GuildInfoFrameInfoHeader1:Point("TOPLEFT", 4, -3)

	GuildInfoFrameInfoHeader1.bg = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	GuildInfoFrameInfoHeader1.bg:SetTemplate("Transparent")
	GuildInfoFrameInfoHeader1.bg:Point("TOPLEFT", 4, -25)
	GuildInfoFrameInfoHeader1.bg:Point("BOTTOMRIGHT", -3, 197)

	for i = 1, 5 do
		S:HandleButtonHighlight(_G["GuildInfoFrameInfoChallenge"..i])
	end

	GuildInfoEditMOTDButton:Point("RIGHT", GuildInfoFrameInfoHeader2, -8, 2)

	GuildInfoFrameInfoHeader2.bg = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	GuildInfoFrameInfoHeader2.bg:SetTemplate()
	GuildInfoFrameInfoHeader2.bg:Point("TOPLEFT", 4, -160)
	GuildInfoFrameInfoHeader2.bg:Point("BOTTOMRIGHT", -3, 118)

	S:HandleScrollBar(GuildInfoFrameInfoMOTDScrollFrameScrollBar, 8)
	GuildInfoFrameInfoMOTDScrollFrameScrollBar:ClearAllPoints()
	GuildInfoFrameInfoMOTDScrollFrameScrollBar:Point("TOPRIGHT", GuildInfoFrameInfoMOTDScrollFrame, 22, -12)
	GuildInfoFrameInfoMOTDScrollFrameScrollBar:Point("BOTTOMRIGHT", GuildInfoFrameInfoMOTDScrollFrame, 0, 9)

	GuildInfoEditDetailsButton:Point("RIGHT", GuildInfoFrameInfoHeader3, -8, 2)

	GuildInfoFrameInfoHeader3.bg = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	GuildInfoFrameInfoHeader3.bg:SetTemplate()
	GuildInfoFrameInfoHeader3.bg:Point("TOPLEFT", 4, -235)
	GuildInfoFrameInfoHeader3.bg:Point("BOTTOMRIGHT", -3, 3)

	S:HandleScrollBar(GuildInfoDetailsFrameScrollBar)
	GuildInfoDetailsFrameScrollBar:ClearAllPoints()
	GuildInfoDetailsFrameScrollBar:Point("TOPRIGHT", GuildInfoDetailsFrame, 22, -13)
	GuildInfoDetailsFrameScrollBar:Point("BOTTOMRIGHT", GuildInfoDetailsFrame, 0, 11)

	S:HandleButton(GuildAddMemberButton)
	GuildAddMemberButton:Point("BOTTOMLEFT", 4, -22)
	GuildAddMemberButton:Width(110)

	S:HandleButton(GuildControlButton)
	GuildControlButton:Point("BOTTOMRIGHT", -3, -22)
	GuildControlButton:Width(110)

	S:HandleButton(GuildViewLogButton)
	GuildViewLogButton:Point("LEFT", GuildAddMemberButton, "RIGHT", 2, 0)
	GuildViewLogButton:Point("RIGHT", GuildControlButton, "LEFT", -2, 0)

	-- Text Edit Frame
	GuildTextEditFrame:StripTextures()
	GuildTextEditFrame:CreateBackdrop("Transparent")
	GuildTextEditFrame.backdrop:Point("TOPLEFT", 12, 0)
	GuildTextEditFrame.backdrop:Point("BOTTOMRIGHT", -20, 10)
	GuildTextEditFrame:Point("TOPLEFT", GuildFrame, "TOPRIGHT", -11, 0)

	GuildTextEditContainer:StripTextures()
	GuildTextEditContainer:CreateBackdrop("Transparent")
	GuildTextEditContainer.backdrop:Point("BOTTOMRIGHT", -28, 0)

	S:HandleButton(GuildTextEditFrameAcceptButton)
	GuildTextEditFrameAcceptButton:Point("BOTTOMLEFT", E.PixelMode and 21 or 20, 16)

	S:HandleScrollBar(GuildTextEditScrollFrameScrollBar, 5)
	GuildTextEditScrollFrameScrollBar:ClearAllPoints()
	GuildTextEditScrollFrameScrollBar:Point("TOPRIGHT", GuildTextEditScrollFrame, 23, E.PixelMode and -10 or -9)
	GuildTextEditScrollFrameScrollBar:Point("BOTTOMRIGHT", GuildTextEditScrollFrame, 0, 11)

	for i = 1, GuildTextEditFrame:GetNumChildren() do
		local child = select(i, GuildTextEditFrame:GetChildren())

		if child:GetName() == "GuildTextEditFrameCloseButton" then
			if child:GetWidth() < 33 then
				S:HandleCloseButton(child, GuildTextEditFrame.backdrop)
			else
				S:HandleButton(child)
				child:Point("BOTTOMRIGHT", -50, 16)
			end
		end
	end

	-- Recruitment Tab
	GuildRecruitmentRolesFrame:StripTextures()
	GuildRecruitmentLevelFrame:StripTextures()
	GuildRecruitmentCommentFrame:StripTextures()
	GuildRecruitmentInterestFrame:StripTextures()
	GuildRecruitmentAvailabilityFrame:StripTextures()

	GuildRecruitmentCommentInputFrame:StripTextures()
	GuildRecruitmentCommentInputFrame:SetTemplate()

	S:HandleScrollBar(GuildRecruitmentCommentInputFrameScrollFrameScrollBar)

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

	S:HandleRoleButton(GuildRecruitmentTankButton)
	GuildRecruitmentTankButton:Point("TOPLEFT", 30, -37)

	S:HandleRoleButton(GuildRecruitmentHealerButton)
	GuildRecruitmentHealerButton:Point("TOP", 1, -37)

	S:HandleRoleButton(GuildRecruitmentDamagerButton)
	GuildRecruitmentDamagerButton:Point("TOPRIGHT", -30, -37)

	-- Requests Tab
	GuildInfoFrameApplicants:StripTextures()

	GuildInfoFrameApplicantsContainer:StripTextures()
	GuildInfoFrameApplicantsContainer:CreateBackdrop("Transparent")
	GuildInfoFrameApplicantsContainer.backdrop:Point("TOPLEFT", 0, 0)
	GuildInfoFrameApplicantsContainer.backdrop:Point("BOTTOMRIGHT", 0, -3)
	GuildInfoFrameApplicantsContainer:Point("TOPLEFT", 1, 0)

	S:HandleScrollBar(GuildInfoFrameApplicantsContainerScrollBar)
	GuildInfoFrameApplicantsContainerScrollBar:ClearAllPoints()
	GuildInfoFrameApplicantsContainerScrollBar:Point("TOPRIGHT", GuildInfoFrameApplicantsContainer, 24, -16)
	GuildInfoFrameApplicantsContainerScrollBar:Point("BOTTOMRIGHT", GuildInfoFrameApplicantsContainer, 0, 13)
	GuildInfoFrameApplicantsContainerScrollBar:Show()
	GuildInfoFrameApplicantsContainerScrollBar.Hide = E.noop

	S:HandleButton(GuildRecruitmentInviteButton)
	GuildRecruitmentInviteButton:Point("BOTTOMLEFT", 1, -22)

	S:HandleButton(GuildRecruitmentDeclineButton)
	GuildRecruitmentDeclineButton:Point("BOTTOMRIGHT", -22, -22)

	S:HandleButton(GuildRecruitmentMessageButton)
	GuildRecruitmentMessageButton:Point("LEFT", GuildRecruitmentInviteButton, "RIGHT", 2, 0)
	GuildRecruitmentMessageButton:Point("RIGHT", GuildRecruitmentDeclineButton, "LEFT", -2, 0)

	for _, button in next, GuildInfoFrameApplicantsContainer.buttons do
		button:StripTextures()

		button.bg = CreateFrame("Frame", nil, button)
		button.bg:SetTemplate(nil, true)
		button.bg:SetOutside(button.class)

		button.class:SetTexture([[Interface\WorldStateFrame\Icons-Classes]])
		button.class:SetParent(button.bg)

		local highlight = button:GetHighlightTexture()
		highlight:SetTexture(E.Media.Textures.Highlight)
		highlight:SetTexCoord(0, 1, 0, 1)
		highlight:SetInside()

		button.selectedTex:SetTexture(E.Media.Textures.Highlight)
		button.selectedTex:SetTexCoord(0, 1, 0, 1)
		button.selectedTex:SetInside()

		button.name:Point("TOPLEFT", 75, -10)
		button.level:Point("TOPLEFT", 58, -10)
		button.timeLeft:Point("TOPLEFT", 0, -10)

		button.tankTex:SetTexture(E.Media.Textures.Tank)
		button.tankTex:SetTexCoord(0, 1, 0, 1)

		button.healerTex:SetTexture(E.Media.Textures.Healer)
		button.healerTex:SetTexCoord(0, 1, 0, 1)

		button.damageTex:SetTexture(E.Media.Textures.DPS)
		button.damageTex:SetTexCoord(0, 1, 0, 1)
	end

	local function SkinGuildApplicants()
		local offset = HybridScrollFrame_GetOffset(GuildInfoFrameApplicantsContainer)
		local buttons = GuildInfoFrameApplicantsContainer.buttons
		local _, level, class, button, index, classColor, levelColor

		for i = 1, #buttons do
			button = buttons[i]
			index = offset + i
			_, level, class = GetGuildApplicantInfo(index)

			if class then
				classColor = E:ClassColor(class)

				button:GetHighlightTexture():SetVertexColor(classColor.r, classColor.g, classColor.b, 0.35)
				button.selectedTex:SetVertexColor(classColor.r, classColor.g, classColor.b, 0.35)
				button.bg:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b)
				button.name:SetTextColor(classColor.r, classColor.g, classColor.b)
			end

			if level then
				levelColor = GetQuestDifficultyColor(level)

				button.level:SetTextColor(levelColor.r, levelColor.g, levelColor.b)
			end
		end
	end
	hooksecurefunc("GuildInfoFrameApplicants_Update", SkinGuildApplicants)
	hooksecurefunc("HybridScrollFrame_Update", SkinGuildApplicants)

	-- Guild Log
	S:HandleScrollBar(GuildLogScrollFrameScrollBar, 4)

	GuildLogScrollFrameScrollBar:ClearAllPoints()
	GuildLogScrollFrameScrollBar:Point("TOPRIGHT", GuildLogScrollFrame, 26, -13)
	GuildLogScrollFrameScrollBar:Point("BOTTOMRIGHT", GuildLogScrollFrame, 0, 12)

	GuildLogFrame:StripTextures()
	GuildLogFrame:CreateBackdrop("Transparent")
	GuildLogFrame.backdrop:Point("TOPLEFT", 15, 0)
	GuildLogFrame.backdrop:Point("BOTTOMRIGHT", -15, 0)
	GuildLogFrame:Point("TOPLEFT", GuildFrame, "TOPRIGHT", -14, 0)

	GuildLogContainer:StripTextures()

	GuildLogScrollFrame:CreateBackdrop("Transparent")
	GuildLogScrollFrame.backdrop:Point("TOPLEFT", -2, 2)
	GuildLogScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -3)

	for i = 1, GuildLogFrame:GetNumChildren() do
		local child = select(i, GuildLogFrame:GetChildren())

		if child:GetName() == "GuildLogFrameCloseButton" then
			if child:GetWidth() < 33 then
				S:HandleCloseButton(child, GuildLogFrame.backdrop)
			else
				S:HandleButton(child)
				child:Point("BOTTOMRIGHT", -47, 16)
			end
		end
	end
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