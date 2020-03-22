local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs, unpack, select = pairs, unpack, select
local find = string.find

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lfg then return end

	-- PVE Frame
	PVEFrame:StripTextures(true)
	PVEFrame:SetTemplate("Transparent")

	PVEFrame.shadows:Hide()

	-- Side Buttons
	PVEFrameLeftInset:StripTextures()

	for i = 1, 4 do
		local button = GroupFinderFrame["groupButton"..i]

		button.ring:Hide()
		button.bg:SetTexture("")

		button:SetTemplate("Transparent")
		button:StyleButton()

		button:CreateBackdrop()
		button.backdrop:SetOutside(button.icon)
		button.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() + 2)

		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.icon:Size(E.PixelMode and 58 or 56)
		button.icon:Point("LEFT", button, 1, 0)
		button.icon:SetParent(button.backdrop)
	end

	GroupFinderFrameGroupButton1.icon:SetTexture("Interface\\Icons\\INV_Helmet_08")
	GroupFinderFrameGroupButton2.icon:SetTexture("Interface\\Icons\\inv_helmet_06")
	GroupFinderFrameGroupButton3.icon:SetTexture("Interface\\Icons\\Icon_Scenarios")

	-- Bottom Tabs
	for i = 1, 2 do
		local tab = _G["PVEFrameTab"..i]

		S:HandleTab(tab)

		if i == 1 then
			tab:Point("BOTTOMLEFT", PVEFrame, 19, -30)
		end
	end

	S:HandleCloseButton(PVEFrameCloseButton)

	-- Dungeon Finder
	LFDParentFrame:StripTextures()
	LFDParentFrameInset:StripTextures()

	LFDQueueFrameBackground:Kill()

	LFDQueueFrameRoleButtonTank:Point("BOTTOMLEFT", 20, 334)
	LFDQueueFrameRoleButtonLeader:Point("LEFT", LFDQueueFrameRoleButtonDPS, "RIGHT", 34, 0)

	S:HandleButton(LFDQueueFramePartyBackfillBackfillButton)
	S:HandleButton(LFDQueueFramePartyBackfillNoBackfillButton)
	S:HandleButton(LFDQueueFrameRandomScrollFrameChildFrameBonusRepFrame.ChooseButton)
	S:HandleButton(LFDQueueFrameFindGroupButton)

	S:HandleDropDownBox(LFDQueueFrameTypeDropDown)
	LFDQueueFrameTypeDropDown:Point("BOTTOMLEFT", 90, 283)

	S:HandleScrollBar(LFDQueueFrameRandomScrollFrameScrollBar)
	LFDQueueFrameRandomScrollFrameScrollBar:ClearAllPoints()
	LFDQueueFrameRandomScrollFrameScrollBar:Point("TOPRIGHT", LFDQueueFrameRandomScrollFrame, 20, -17)
	LFDQueueFrameRandomScrollFrameScrollBar:Point("BOTTOMRIGHT", LFDQueueFrameRandomScrollFrame, 0, 12)

	LFDQueueFrameSpecificListScrollFrame:StripTextures()

	S:HandleScrollBar(LFDQueueFrameSpecificListScrollFrameScrollBar)
	LFDQueueFrameSpecificListScrollFrameScrollBar:ClearAllPoints()
	LFDQueueFrameSpecificListScrollFrameScrollBar:Point("TOPRIGHT", LFDQueueFrameSpecificListScrollFrame, 23, -22)
	LFDQueueFrameSpecificListScrollFrameScrollBar:Point("BOTTOMRIGHT", LFDQueueFrameSpecificListScrollFrame, 0, 22)

	local function getLFGDungeonRewardLinkFix(dungeonID, rewardIndex)
		local _, link = GetLFGDungeonRewardLink(dungeonID, rewardIndex)

		if not link then
			E.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			E.ScanTooltip:SetLFGDungeonReward(dungeonID, rewardIndex)
			_, link = E.ScanTooltip:GetItem()
			E.ScanTooltip:Hide()
		end

		return link
	end

	local function LFGQualityColors(button, name, link)
		if link then
			local quality = select(3, GetItemInfo(link))

			if quality then
				local r, g, b = GetItemQualityColor(quality)
				button:SetBackdropBorderColor(r, g, b)
				button.backdrop:SetBackdropBorderColor(r, g, b)
				name:SetTextColor(r, g, b)
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				name:SetTextColor(1, 1, 1)
			end
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			name:SetTextColor(1, 1, 1)
		end
	end

	local function SkinLFGRewards(button, dungeonID, index)
		local buttonName = button:GetName()
		local count = _G[buttonName.."Count"]
		local icon = _G[buttonName.."IconTexture"]

		button:StripTextures()
		button:SetTemplate("Transparent")
		button:StyleButton(nil, true)
		button:CreateBackdrop()
		button.backdrop:SetOutside(icon)

		icon:Point("TOPLEFT", 1, -1)
		icon:SetTexture(icon:GetTexture())
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetParent(button.backdrop)
		icon:SetDrawLayer("OVERLAY")

		count:SetParent(button.backdrop)
		count:SetDrawLayer("OVERLAY")

		button.isSkinned = true
	end

	hooksecurefunc("LFDQueueFrameRandom_UpdateFrame", function()
		local dungeonID = LFDQueueFrame.type
		if type(dungeonID) ~= "number" then return end

		for i = 1, LFD_MAX_REWARDS do
			local button = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i]

			if button then
				local buttonName = button:GetName()
				local name = _G[buttonName.."Name"]
				local link = getLFGDungeonRewardLinkFix(dungeonID, i)

				if not button.isSkinned then
					SkinLFGRewards(button, dungeonID, i)

					if i == 1 then
						button:Point("TOPLEFT", LFDQueueFrameRandomScrollFrameChildFrameRewardsDescription, "BOTTOMLEFT", -5, -10)
					else
						button:Point("LEFT", LFDQueueFrameRandomScrollFrameChildFrameItem1, "RIGHT", 4, 0) 
					end

					for j = 1, 2 do
						_G[button:GetName().."RoleIcon"..j]:SetParent(button.backdrop)
					end

					button.isSkinned = true
				end

				LFGQualityColors(button, name, link)
			end
		end
	end)

	for i = 1, NUM_LFD_CHOICE_BUTTONS do
		local button = _G["LFDQueueFrameSpecificListButton"..i]

		S:HandleCheckBox(button.enableButton)

		button.expandOrCollapseButton:SetNormalTexture(E.Media.Textures.Plus)

		button.expandOrCollapseButton:GetNormalTexture():Size(18)
		button.expandOrCollapseButton:GetNormalTexture():Point("CENTER", 3, 4)

		button.expandOrCollapseButton:SetHighlightTexture("")
		button.expandOrCollapseButton.SetHighlightTexture = E.noop

		hooksecurefunc(button.expandOrCollapseButton, "SetNormalTexture", function(self, texture)
			local normal = self:GetNormalTexture()

			if find(texture, "MinusButton") then
				normal:SetTexture(E.Media.Textures.Minus)
			else
				normal:SetTexture(E.Media.Textures.Plus)
			end
		end)
 	end

	-- Scenarios
	ScenarioFinderFrame:StripTextures()
	ScenarioFinderFrameInset:StripTextures()

	ScenarioQueueFrame.Bg:Hide()

	S:HandleButton(ScenarioQueueFramePartyBackfillBackfillButton)
	S:HandleButton(ScenarioQueueFramePartyBackfillNoBackfillButton)
	S:HandleButton(ScenarioQueueFrameRandomScrollFrameChildFrameBonusRepFrame.ChooseButton)
	S:HandleButton(ScenarioQueueFrameFindGroupButton)

	S:HandleDropDownBox(ScenarioQueueFrameTypeDropDown)
	ScenarioQueueFrameTypeDropDown:Point("TOPLEFT", 90, -42)

	S:HandleScrollBar(ScenarioQueueFrameRandomScrollFrameScrollBar)
	ScenarioQueueFrameRandomScrollFrameScrollBar:ClearAllPoints()
	ScenarioQueueFrameRandomScrollFrameScrollBar:Point("TOPRIGHT", ScenarioQueueFrameRandomScrollFrame, 20, -11)
	ScenarioQueueFrameRandomScrollFrameScrollBar:Point("BOTTOMRIGHT", ScenarioQueueFrameRandomScrollFrame, 0, 11)

	ScenarioQueueFrameSpecificScrollFrame:StripTextures()

	S:HandleScrollBar(ScenarioQueueFrameSpecificScrollFrameScrollBar)
	ScenarioQueueFrameSpecificScrollFrameScrollBar:ClearAllPoints()
	ScenarioQueueFrameSpecificScrollFrameScrollBar:Point("TOPRIGHT", ScenarioQueueFrameSpecificScrollFrame, 23, -20)
	ScenarioQueueFrameSpecificScrollFrameScrollBar:Point("BOTTOMRIGHT", ScenarioQueueFrameSpecificScrollFrame, 0, 20)

	hooksecurefunc("ScenarioQueueFrameRandom_UpdateFrame", function()
		local dungeonID = ScenarioQueueFrame.type
		if type(dungeonID) ~= "number" then return end

		for i = 1, LFD_MAX_REWARDS do
			local button = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..i]

			if button then
				local buttonName = button:GetName()
				local name = _G[buttonName.."Name"]
				local link = getLFGDungeonRewardLinkFix(dungeonID, i)

				if not button.isSkinned then
					SkinLFGRewards(button, dungeonID, i)

					if i == 1 then
						button:Point("TOPLEFT", ScenarioQueueFrameRandomScrollFrameChildFrameRewardsDescription, "BOTTOMLEFT", -5, -10)
					else
						button:Point("LEFT", ScenarioQueueFrameRandomScrollFrameChildFrameItem1, "RIGHT", 4, 0) 
					end

					button.isSkinned = true
				end

				LFGQualityColors(button, name, link)
			end
		end
	end)

	hooksecurefunc("ScenarioQueueFrameSpecific_Update", function()
		for i = 1, NUM_SCENARIO_CHOICE_BUTTONS do
			local button = _G["ScenarioQueueFrameSpecificButton"..i]

			if button and not button.isSkinned then
				S:HandleCheckBox(button.enableButton)

				button.expandOrCollapseButton:SetNormalTexture(E.Media.Textures.Minus)

				button.expandOrCollapseButton:GetNormalTexture():Size(18)
				button.expandOrCollapseButton:GetNormalTexture():Point("CENTER", 3, 4)

				button.expandOrCollapseButton:SetHighlightTexture("")
				button.expandOrCollapseButton.SetHighlightTexture = E.noop

				hooksecurefunc(button.expandOrCollapseButton, "SetNormalTexture", function(self, texture)
					local normal = self:GetNormalTexture()

					if find(texture, "MinusButton") then
						normal:SetTexture(E.Media.Textures.Minus)
					else
						normal:SetTexture(E.Media.Textures.Plus)
					end
				end)

				button.isSkinned = true
			end
		end
	end)

	-- Bonus Valor Info
	for _, frame in pairs({"LFDQueueFrame", "ScenarioQueueFrame"}) do
		local item = _G[frame.."RandomScrollFrameChildFrameBonusValor"]

		item:CreateBackdrop()
		item.backdrop:SetOutside(item.Icon)

		item.Icon:SetTexture("Interface\\Icons\\pvecurrency-valor")
		item.Icon:SetTexCoord(unpack(E.TexCoords))
		item.Icon:SetParent(item.backdrop)

		item.Border:Hide()
	end

	-- Raid Finder
	RaidFinderFrame:StripTextures()
	RaidFinderFrameBottomInset:StripTextures()
	RaidFinderFrameRoleInset:StripTextures()

	RaidFinderQueueFrameBackground:Hide()

	RaidFinderQueueFrameRoleButtonTank:Point("BOTTOMLEFT", 20, 336)
	RaidFinderQueueFrameRoleButtonLeader:Point("LEFT", RaidFinderQueueFrameRoleButtonDPS, "RIGHT", 34, 0)

	S:HandleButton(RaidFinderQueueFramePartyBackfillBackfillButton)
	S:HandleButton(RaidFinderQueueFramePartyBackfillNoBackfillButton)
	S:HandleButton(RaidFinderFrameFindRaidButton)

	S:HandleDropDownBox(RaidFinderQueueFrameSelectionDropDown)
	RaidFinderQueueFrameSelectionDropDown:Point("BOTTOMLEFT", 90, 285)

	RaidFinderQueueFrameScrollFrameChildFrameItem1:StripTextures()
	RaidFinderQueueFrameScrollFrameChildFrameItem1:SetTemplate("Transparent")
	RaidFinderQueueFrameScrollFrameChildFrameItem1:StyleButton(nil, true)
	RaidFinderQueueFrameScrollFrameChildFrameItem1:CreateBackdrop()
	RaidFinderQueueFrameScrollFrameChildFrameItem1.backdrop:SetOutside(RaidFinderQueueFrameScrollFrameChildFrameItem1IconTexture)

	RaidFinderQueueFrameScrollFrameChildFrameItem1IconTexture:Point("TOPLEFT", 1, -1)
	RaidFinderQueueFrameScrollFrameChildFrameItem1IconTexture:SetTexture(RaidFinderQueueFrameScrollFrameChildFrameItem1IconTexture:GetTexture())
	RaidFinderQueueFrameScrollFrameChildFrameItem1IconTexture:SetTexCoord(unpack(E.TexCoords))
	RaidFinderQueueFrameScrollFrameChildFrameItem1IconTexture:SetParent(RaidFinderQueueFrameScrollFrameChildFrameItem1.backdrop)
	RaidFinderQueueFrameScrollFrameChildFrameItem1IconTexture:SetDrawLayer("OVERLAY")

	RaidFinderQueueFrameScrollFrameChildFrameItem1Count:SetParent(RaidFinderQueueFrameScrollFrameChildFrameItem1.backdrop)
	RaidFinderQueueFrameScrollFrameChildFrameItem1Count:SetDrawLayer("OVERLAY")

	-- LFR Queue/Browse Tabs
	for i = 1, 2 do
		local tab = _G["LFRParentFrameSideTab"..i]
		local icon = tab:GetNormalTexture()

		tab:GetRegions():Hide()
		tab:SetTemplate()
		tab:StyleButton(nil, true)

		if i == 1 then
			tab:Point("TOPLEFT", LFRParentFrame, "TOPRIGHT", E.PixelMode and -1 or 1, -35)
		end

		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))
	end

	-- LFR Queue Frame
	LFRParentFrame:StripTextures()
	LFRQueueFrameListInset:StripTextures()
	LFRQueueFrameRoleInset:StripTextures()
	LFRQueueFrameCommentInset:StripTextures()

	S:HandleButton(LFRQueueFrameFindGroupButton)
	LFRQueueFrameFindGroupButton:Point("BOTTOMLEFT", 5, 3)

	S:HandleButton(LFRQueueFrameAcceptCommentButton)
	LFRQueueFrameAcceptCommentButton:Point("BOTTOMRIGHT", -6, 3)

	LFRQueueFrameCommentScrollFrame:CreateBackdrop()
	LFRQueueFrameCommentScrollFrame:Size(337, 40)
	LFRQueueFrameCommentScrollFrame:Point("TOPLEFT", LFRQueueFrame, "BOTTOMLEFT", 6, 70)

	S:HandleScrollBar(LFRQueueFrameCommentScrollFrameScrollBar)

	LFRQueueFrameSpecificListScrollFrame:StripTextures()
	LFRQueueFrameSpecificListScrollFrame:CreateBackdrop("Transparent")

	S:HandleScrollBar(LFRQueueFrameSpecificListScrollFrameScrollBar)
	LFRQueueFrameSpecificListScrollFrameScrollBar:ClearAllPoints()
	LFRQueueFrameSpecificListScrollFrameScrollBar:Point("TOPRIGHT", LFRQueueFrameSpecificListScrollFrame, 25, -17)
	LFRQueueFrameSpecificListScrollFrameScrollBar:Point("BOTTOMRIGHT", LFRQueueFrameSpecificListScrollFrame, 0, 18)

	for i = 1, NUM_LFR_CHOICE_BUTTONS do
		local button = _G["LFRQueueFrameSpecificListButton"..i]

		S:HandleCheckBox(button.enableButton)

		button.expandOrCollapseButton:SetNormalTexture(E.Media.Textures.Plus)

		button.expandOrCollapseButton:GetNormalTexture():Size(18)
		button.expandOrCollapseButton:GetNormalTexture():Point("CENTER", 3, 4)

		button.expandOrCollapseButton:SetHighlightTexture("")
		button.expandOrCollapseButton.SetHighlightTexture = E.noop

		hooksecurefunc(button.expandOrCollapseButton, "SetNormalTexture", function(self, texture)
			local normal = self:GetNormalTexture()

			if find(texture, "MinusButton") then
				normal:SetTexture(E.Media.Textures.Minus)
			else
				normal:SetTexture(E.Media.Textures.Plus)
			end
		end)
 	end

	-- LFR Browse Frame
	LFRBrowseFrame:StripTextures()
	LFRBrowseFrameRoleInset:StripTextures()

	for i = 1, 14 do
		if i ~= 6 and i ~= 8 then
			select(i, RaidBrowserFrame:GetRegions()):Hide()
		end
	end

	RaidBrowserFrame:SetTemplate("Transparent")

	for i = 1, 7 do
		local button = "LFRBrowseFrameColumnHeader"..i

		_G[button.."Left"]:Kill()
		_G[button.."Middle"]:Kill()
		_G[button.."Right"]:Kill()

		_G[button]:StyleButton()

		if i == 1 then
			_G[button]:Width(88)
		end
	end

	S:HandleButton(LFRBrowseFrameSendMessageButton)
	LFRBrowseFrameSendMessageButton:Point("BOTTOMLEFT", 5, 3)

	S:HandleButton(LFRBrowseFrameInviteButton)
	LFRBrowseFrameInviteButton:Point("LEFT", LFRBrowseFrameSendMessageButton, "RIGHT", 11, 0)

	S:HandleButton(LFRBrowseFrameRefreshButton)
	LFRBrowseFrameRefreshButton:Point("LEFT", LFRBrowseFrameInviteButton, "RIGHT", 11, 0)

	S:HandleDropDownBox(LFRBrowseFrameRaidDropDown)

	LFRBrowseFrameListScrollFrame:StripTextures()
	LFRBrowseFrameListScrollFrame:CreateBackdrop("Transparent")

	S:HandleScrollBar(LFRBrowseFrameListScrollFrameScrollBar)
	LFRBrowseFrameListScrollFrameScrollBar:ClearAllPoints()
	LFRBrowseFrameListScrollFrameScrollBar:Point("TOPRIGHT", LFRBrowseFrameListScrollFrame, 24, -17)
	LFRBrowseFrameListScrollFrameScrollBar:Point("BOTTOMRIGHT", LFRBrowseFrameListScrollFrame, 0, 17)

	S:HandleCloseButton(RaidBrowserFrameCloseButton)

	--[[
	hooksecurefunc("LFRBrowseFrameListButton_SetData", function(button, index)
		local name, level, _, _, _, _, _, class = SearchLFGGetResults(index)

		local classColor = E:ClassColor(class)
		local levelColor = GetQuestDifficultyColor(level)

		if index and class and name and level and (name ~= E.myname) then
			button.name:SetTextColor(classColor.r, classColor.g, classColor.b)
			button.class:SetTextColor(classColor.r, classColor.g, classColor.b)
			button.level:SetTextColor(levelColor.r, levelColor.g, levelColor.b)
		end
	end)
	]]

	-- Flexible Raid
	FlexRaidFrameBottomInset:StripTextures()

	S:HandleButton(FlexRaidFrameStartRaidButton)

	S:HandleDropDownBox(FlexRaidFrameSelectionDropDown)
	FlexRaidFrameSelectionDropDown:Point("BOTTOMRIGHT", FlexRaidFrameBottomInset, "TOPRIGHT", -13, -10)

	FlexRaidFrameScrollFrame:StripTextures(true)

	S:HandleScrollBar(FlexRaidFrameScrollFrameScrollBar)
	FlexRaidFrameScrollFrameScrollBar:ClearAllPoints()
	FlexRaidFrameScrollFrameScrollBar:Point("TOPRIGHT", FlexRaidFrameScrollFrame, 20, -19)
	FlexRaidFrameScrollFrameScrollBar:Point("BOTTOMRIGHT", FlexRaidFrameScrollFrame, 0, 19)

	-- LFG Ready Dialog
	LFGDungeonReadyDialog:StripTextures()
	LFGDungeonReadyDialog:SetTemplate("Transparent")
	LFGDungeonReadyDialog.SetBackdrop = E.noop
	LFGDungeonReadyDialog.filigree:SetAlpha(0)
	LFGDungeonReadyDialog.bottomArt:SetAlpha(0)

	LFGDungeonReadyDialogBackground:Kill()

	S:HandleButton(LFGDungeonReadyDialogLeaveQueueButton)
	S:HandleButton(LFGDungeonReadyDialogEnterDungeonButton)

	S:HandleCloseButton(LFGDungeonReadyDialogCloseButton)

	hooksecurefunc("LFGDungeonReadyDialog_UpdateRewards", function()
		for i = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local reward = _G["LFGDungeonReadyDialogRewardsFrameReward"..i]
			local texture = _G["LFGDungeonReadyDialogRewardsFrameReward"..i.."Texture"]
			local border = _G["LFGDungeonReadyDialogRewardsFrameReward"..i.."Border"]

			if reward and not reward.isSkinned then
				border:Kill()
				reward:CreateBackdrop()
				reward.backdrop:Point("TOPLEFT", 7, -7)
				reward.backdrop:Point("BOTTOMRIGHT", -7, 7)

				texture:SetTexCoord(unpack(E.TexCoords))
				texture:SetInside(reward.backdrop)

				reward.isSkinned = true
			end
		end
	end)

	LFGDungeonReadyDialogRoleIcon:StripTextures()
	LFGDungeonReadyDialogRoleIcon:CreateBackdrop()
	LFGDungeonReadyDialogRoleIcon.backdrop:Point("TOPLEFT", 7, -7)
	LFGDungeonReadyDialogRoleIcon.backdrop:Point("BOTTOMRIGHT", -7, 7)
	LFGDungeonReadyDialogRoleIcon.texture = LFGDungeonReadyDialogRoleIcon:CreateTexture(nil, "OVERLAY")

	hooksecurefunc("LFGDungeonReadyPopup_Update", function()
		local _, _, _, _, _, _, role = GetLFGProposal()

		if role == "DAMAGER" then
			LFGDungeonReadyDialogRoleIcon.texture:SetTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")
		elseif role == "TANK" then
			LFGDungeonReadyDialogRoleIcon.texture:SetTexture("Interface\\Icons\\Ability_Defend")
		elseif role == "HEALER" then
			LFGDungeonReadyDialogRoleIcon.texture:SetTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")
		end

		LFGDungeonReadyDialogRoleIcon.texture:SetTexCoord(unpack(E.TexCoords))
		LFGDungeonReadyDialogRoleIcon.texture:SetInside(LFGDungeonReadyDialogRoleIcon.backdrop)
		LFGDungeonReadyDialogRoleIcon.texture:SetParent(LFGDungeonReadyDialogRoleIcon.backdrop)
	end)

	-- LFG Ready Status
	LFGDungeonReadyStatus:StripTextures()
	LFGDungeonReadyStatus:SetTemplate("Transparent")

	S:HandleCloseButton(LFGDungeonReadyStatusCloseButton)

	do
		local roleButtons = {LFGDungeonReadyStatusGroupedTank, LFGDungeonReadyStatusGroupedHealer, LFGDungeonReadyStatusGroupedDamager}
		for i = 1, 5 do
			tinsert(roleButtons, _G["LFGDungeonReadyStatusIndividualPlayer"..i])
		end

		for _, roleButton in pairs (roleButtons) do
			roleButton:CreateBackdrop()
			roleButton.backdrop:Point("TOPLEFT", 3, -3)
			roleButton.backdrop:Point("BOTTOMRIGHT", -3, 3)
			roleButton.texture:SetTexture(E.Media.Textures.RoleIcons)
			roleButton.texture:Point("TOPLEFT", roleButton.backdrop, "TOPLEFT", -8, 6)
			roleButton.texture:Point("BOTTOMRIGHT", roleButton.backdrop, "BOTTOMRIGHT", 8, -10)
			roleButton.statusIcon:SetDrawLayer("OVERLAY", 2)
		end
	end

	-- LFD Role Check PopUp
	LFDRoleCheckPopup:SetTemplate("Transparent")
	LFDRoleCheckPopup:SetFrameStrata("HIGH")

	S:HandleButton(LFDRoleCheckPopupAcceptButton)
	S:HandleButton(LFDRoleCheckPopupDeclineButton)

	-- LFG Invite PopUp
	LFGInvitePopup:StripTextures()
	LFGInvitePopup:SetTemplate("Transparent")

	S:HandleButton(LFGInvitePopupAcceptButton)
	S:HandleButton(LFGInvitePopupDeclineButton)

	-- Queue Search Status
	QueueStatusFrame:StripTextures()
	QueueStatusFrame:SetTemplate("Transparent")

	hooksecurefunc("QueueStatusEntry_SetFullDisplay", function(entry, _, _, _, isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS)
		local nextRoleIcon = 1
		local icon

		if isDPS then
			icon = entry["RoleIcon"..nextRoleIcon]
			icon:SetTexture(E.Media.Textures.DPS)
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:Size(17)
			nextRoleIcon = nextRoleIcon + 1
		end

		if isHealer then
			icon = entry["RoleIcon"..nextRoleIcon]
			icon:SetTexture(E.Media.Textures.Healer)
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:Size(20)
			nextRoleIcon = nextRoleIcon + 1
		end

		if isTank then
			icon = entry["RoleIcon"..nextRoleIcon]
			icon:SetTexture(E.Media.Textures.Tank)
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:Size(22)
			nextRoleIcon = nextRoleIcon + 1
		end

		if totalTanks and totalHealers and totalDPS then
			entry.TanksFound.Texture:SetTexture("Interface\\Icons\\Ability_Defend")
			entry.TanksFound.Texture:SetTexCoord(unpack(E.TexCoords))

			entry.HealersFound.Texture:SetTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")
			entry.HealersFound.Texture:SetTexCoord(unpack(E.TexCoords))

			entry.DamagersFound.Texture:SetTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")
			entry.DamagersFound.Texture:SetTexCoord(unpack(E.TexCoords))
		end
	end)

	-- Role Icons
	local roleButtonFrames = {
		"LFDQueueFrameRoleButton",
		"RaidFinderQueueFrameRoleButton",
		"LFRQueueFrameRoleButton",
		"LFDRoleCheckPopupRoleButton",
		"LFGInvitePopupRoleButton"
	}

	for _, frame in pairs(roleButtonFrames) do
		local tank = _G[frame.."Tank"]
		local damager = _G[frame.."DPS"]
		local healer = _G[frame.."Healer"]
		local leader = _G[frame.."Leader"]

		for _, btn in pairs({tank, damager, healer, leader}) do
			if btn then
				local icon = btn:GetNormalTexture()
				local checkbox = btn.checkButton or btn:GetChildren()

				btn:StripTextures()
				btn:CreateBackdrop()
				btn.backdrop:Point("TOPLEFT", 3, -3)
				btn.backdrop:Point("BOTTOMRIGHT", -3, 3)

				icon:SetTexCoord(unpack(E.TexCoords))
				icon:SetInside(btn.backdrop)

				S:HandleCheckBox(checkbox)
				checkbox:SetFrameLevel(checkbox:GetFrameLevel() + 2)
			end
		end

		tank:SetNormalTexture("Interface\\Icons\\Ability_Defend")
		damager:SetNormalTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")
		healer:SetNormalTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")

		if leader then
			leader:SetNormalTexture("Interface\\Icons\\Ability_Vehicle_LaunchPlayer")
		end
	end

	-- Incentive Role Icons
	hooksecurefunc("LFG_SetRoleIconIncentive", function(button, incentiveIndex)
		if incentiveIndex then
			button.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
		else
			button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)
end

local function LoadSecondarySkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lfg then return end

	ChallengesFrameInset:StripTextures()
	ChallengesFrameInsetBg:Hide()
	ChallengesFrameDetails.bg:Hide()

	select(2, ChallengesFrameDetails:GetRegions()):Hide()
	select(9, ChallengesFrameDetails:GetRegions()):Hide()
	select(10, ChallengesFrameDetails:GetRegions()):Hide()
	select(11, ChallengesFrameDetails:GetRegions()):Hide()

	ChallengesFrameDungeonButton1:Point("TOPLEFT", ChallengesFrame, 8, -83)

	S:HandleButton(ChallengesFrameLeaderboard)

	for i = 1, 9 do
		local button = ChallengesFrame["button"..i]

		S:HandleButton(button)
		button:StyleButton(nil, true)
		button:SetHighlightTexture("")

		button.selectedTex:SetAlpha(0.20)
		button.selectedTex:Point("TOPLEFT", 1, -1)
		button.selectedTex:Point("BOTTOMRIGHT", -1, 1)

		button.NoMedal:Kill()
	end

	for i = 10, 16 do
		local button = ChallengesFrame["button"..i]

		if button then
			button:Hide()
		end
	end

	for i = 1, 3 do
		local rewardsRow = ChallengesFrame["RewardRow"..i]

		for j = 1, 2 do
			local button = rewardsRow["Reward"..j]

			button:CreateBackdrop()
			button.Icon:SetTexCoord(unpack(E.TexCoords))
		end
	end
end

S:AddCallback("LFG", LoadSkin)
S:AddCallbackForAddon("Blizzard_ChallengesUI", "ChallengesUI", LoadSecondarySkin)