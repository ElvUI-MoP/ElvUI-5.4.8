local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local next, ipairs, pairs, select, unpack = next, ipairs, pairs, select, unpack

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.guild ~= true then return end

	local GuildFrame = _G["GuildFrame"]
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
	GuildXPBar.backdrop:Point("TOPLEFT", 0, 1)
	GuildXPBar.backdrop:Point("BOTTOMRIGHT", -1, 4)
	GuildXPBar.progress:SetTexture(E.media.normTex)

	-- Faction Bar
	GuildFactionBar:StripTextures()
	GuildFactionBar.progress:SetTexture(E.media.normTex)
	GuildFactionBar.progress.bg = CreateFrame("Frame", nil, GuildFactionBar)
	GuildFactionBar.progress.bg:SetTemplate()
	GuildFactionBar.progress.bg:Point("TOPLEFT", 0, -3)
	GuildFactionBar.progress.bg:Point("BOTTOMRIGHT", 0, 1)
	GuildFactionBar.progress.bg:SetFrameLevel(GuildFactionBar.progress.bg:GetFrameLevel() - 2)

	-- Guild Latest/Next Perks/Updates
	GuildNewPerksFrame:StripTextures()
	GuildAllPerksFrame:StripTextures()

	GuildPerksToggleButton:StripTextures()
	S:HandleButton(GuildPerksToggleButton)

	S:HandleScrollBar(GuildPerksContainerScrollBar, 4)

	if GuildLatestPerkButton then
		GuildLatestPerkButton:StripTextures()
		GuildLatestPerkButton:CreateBackdrop("Default")
		GuildLatestPerkButton.backdrop:SetOutside(GuildLatestPerkButtonIconTexture)
		GuildLatestPerkButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
		GuildLatestPerkButtonIconTexture:Point("TOPLEFT", 2, -2)
	end

	if GuildNextPerkButton then
		GuildNextPerkButton:StripTextures()
		GuildNextPerkButton:CreateBackdrop("Default")
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

	S:HandleScrollBar(GuildRewardsContainerScrollBar, 5)

	for i = 1, 8 do
		local Rewards = _G["GuildRewardsContainerButton"..i]
		local Perks =  _G["GuildPerksContainerButton"..i]

		Perks.icon:Size(E.PixelMode and 40 or 38)
		Rewards.icon:Size(E.PixelMode and 43 or 40)
	end

	for _, Object in pairs({"Rewards", "Perks"}) do
		for i = 1, 8 do
			local Button = _G["Guild"..Object.."ContainerButton"..i]
			local Name = _G["Guild"..Object.."ContainerButton"..i.."Name"]
			local SubText = _G["Guild"..Object.."ContainerButton"..i.."SubText"]

			Button:StripTextures()
			Button:CreateBackdrop("Default")
			Button.backdrop:SetOutside(Button.icon)

			Button:StyleButton(nil, true)

			Button.icon:SetTexCoord(unpack(E.TexCoords))
			Button.icon:Point("TOPLEFT", 2, -2)
			Button.icon:SetParent(Button.backdrop)

			if Object == "Rewards" then
				SubText:SetTextColor(1, 0.80, 0.10)
				Button.backdrop:HookScript("OnUpdate", function(self)
					local _, itemID = GetGuildRewardInfo(Button.index)
					if itemID then
						local quality = select(3, GetItemInfo(itemID))
						if quality then
							self:SetBackdropBorderColor(GetItemQualityColor(quality))
							Name:SetTextColor(GetItemQualityColor(quality))
						else
							self:SetBackdropBorderColor(unpack(E.media.bordercolor))
							Name:SetTextColor(1, 1, 1)
						end
					end
				end)
			end
		end
	end

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
		_G["GuildRosterColumnButton"..i]:StripTextures(true)
		_G["GuildRosterColumnButton"..i]:StyleButton()
	end

	S:HandleDropDownBox(GuildRosterViewDropdown, 200)

	S:HandleScrollBar(GuildRosterContainerScrollBar, 5)

	S:HandleCheckBox(GuildRosterShowOfflineButton)

	-- Guild Member
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
	GuildNewsBossModelTextFrame:CreateBackdrop("Default")
	GuildNewsBossModelTextFrame.backdrop:Point("TOPLEFT", GuildNewsBossModel.backdrop, "BOTTOMLEFT", 0, -1)

	for i = 1, 17 do
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

	GuildGMImpeachButton:StyleButton()

	S:HandleCloseButton(GuildNewsFiltersFrameCloseButton)
	GuildNewsFiltersFrameCloseButton:Point("TOPRIGHT", 2, 2)

	-- Guild Info
	local GuildInfoFrameInfo = _G["GuildInfoFrameInfo"]
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

		button.timeLeft:Point("LEFT", button.name, "RIGHT", -50, 0)
		button.timeLeft:SetParent(button.backdrop)

		button.comment:SetParent(button.backdrop)
		button.comment:Point("BOTTOMRIGHT", 0, 0)

		button.fullComment:SetParent(button.backdrop)

		button.tankTex:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\tank.tga")
		button.tankTex:SetTexCoord(unpack(E.TexCoords))
		button.tankTex:Size(20)
		button.tankTex:SetParent(button.backdrop)

		button.healerTex:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\healer.tga")
		button.healerTex:SetTexCoord(unpack(E.TexCoords))
		button.healerTex:Size(18)
		button.healerTex:SetParent(button.backdrop)

		button.damageTex:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\dps.tga")
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
				local classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
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

	-- Text Edit Frame
	GuildTextEditFrame:StripTextures()
	GuildTextEditFrame:SetTemplate("Transparent")

	GuildTextEditContainer:StripTextures()
	GuildTextEditContainer:SetTemplate("Transparent")

	S:HandleButton(GuildTextEditFrameAcceptButton)

	S:HandleScrollBar(GuildTextEditScrollFrameScrollBar, 5)

	for i = 1, GuildTextEditFrame:GetNumChildren() do
		local child = select(i, GuildTextEditFrame:GetChildren())
		if child:GetName() == "GuildTextEditFrameCloseButton" and child:GetWidth() < 33 then
			S:HandleCloseButton(child)
		elseif child:GetName() == "GuildTextEditFrameCloseButton" then
			S:HandleButton(child, true)
		end
	end

	-- Guild Log
	S:HandleScrollBar(GuildLogScrollFrameScrollBar, 4)

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
		if child:GetName() == "GuildLogFrameCloseButton" and child:GetWidth() < 33 then
			S:HandleCloseButton(child)
			child:Point("TOPRIGHT", -10, 5)
		elseif child:GetName() == "GuildLogFrameCloseButton" then
			S:HandleButton(child, true)
			child:Point("BOTTOMRIGHT", -28, 16)
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

		_G[roleIcons[i]]:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		_G[roleIcons[i]]:GetNormalTexture():SetInside(_G[roleIcons[i]].backdrop)
	end

	GuildRecruitmentTankButton:SetNormalTexture("Interface\\Icons\\Ability_Defend")
	GuildRecruitmentHealerButton:SetNormalTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")
	GuildRecruitmentDamagerButton:SetNormalTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")
end

S:AddCallbackForAddon("Blizzard_GuildUI", "Guild", LoadSkin)

local function LoadSecondarySkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.guild ~= true then return end

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