local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs, type, unpack, select = pairs, type, unpack, select
local find = string.find

local GetLFGProposal = GetLFGProposal
local hooksecurefunc = hooksecurefunc

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

local function SkinReadyDialogRewards(button, dungeonID)
	if not button.isSkinned then
		button:DisableDrawLayer("OVERLAY")
		button:SetTemplate()
		button:Size(26)
		S:HandleFrameHighlight(button)

		button.texture:SetInside()
		button.texture:SetTexCoord(unpack(E.TexCoords))

		button.isSkinned = true
	end

	local texturePath
	if button.rewardType == "misc" then
		texturePath = [[Interface\Icons\inv_misc_coin_02]]
		button:SetBackdropBorderColor(unpack(E.media.bordercolor))
	elseif dungeonID and button.rewardType == "shortage" then
		texturePath = select(2, GetLFGDungeonShortageRewardInfo(dungeonID, button.rewardArg, button.rewardID))
		local color = ITEM_QUALITY_COLORS[7]
		button:SetBackdropBorderColor(color.r, color.g, color.b)
	elseif dungeonID and button.rewardType == "reward" then
		texturePath = select(2, GetLFGDungeonRewardInfo(dungeonID, button.rewardID))
		local link = getLFGDungeonRewardLinkFix(dungeonID, button.rewardID)
		if link then
			button:SetBackdropBorderColor(GetItemQualityColor(select(3, GetItemInfo(link))))
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end

	if texturePath then
		SetPortraitToTexture(button.texture, nil)
		button.texture:SetTexture(texturePath)
	end
end

local function SkinLFGRewards(button, dungeonID, index)
	if not button then return end

	local buttonName = button:GetName()
	local icon = _G[buttonName.."IconTexture"]
	local name = _G[buttonName.."Name"]
	local count = _G[buttonName.."Count"]
	local texture = icon:GetTexture()

	if not button.isSkinned then
		button:StripTextures()
		button:SetTemplate("Transparent")
		button:StyleButton(nil, true)
		button:CreateBackdrop()
		button.backdrop:SetOutside(icon)

		icon:Point("TOPLEFT", 1, -1)
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetParent(button.backdrop)
		icon:SetDrawLayer("OVERLAY")

		count:SetParent(button.backdrop)
		count:SetDrawLayer("OVERLAY")

		for i = 1, 2 do
			local role = _G[buttonName.."RoleIcon"..i]

			if role then
				role:SetParent(button.backdrop)
			end
		end

		local parentName = button:GetParent():GetName()
		if index == 1 then
			button:Point("TOPLEFT", _G[parentName.."RewardsDescription"], "BOTTOMLEFT", -5, -10)
		else
			button:Point("LEFT", _G[parentName.."Item1"], "RIGHT", 4, 0)
		end

		button.isSkinned = true
	end

	icon:SetTexture(texture)

	if button.shortageIndex then
		local color = ITEM_QUALITY_COLORS[7]
		button:SetBackdropBorderColor(color.r, color.g, color.b)
		button.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		name:SetTextColor(color.r, color.g, color.b)
	else
		local link = getLFGDungeonRewardLinkFix(dungeonID, index)
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
end

local function SkinSpecificList(button)
	if not button or (button and button.isSkinned) then return end

	button.enableButton:CreateBackdrop()
	button.enableButton.backdrop:SetInside(nil, 4, 4)

	button.enableButton:SetNormalTexture("")
	button.enableButton.SetNormalTexture = E.noop

	button.enableButton:SetPushedTexture("")
	button.enableButton.SetPushedTexture = E.noop

	if E.private.skins.checkBoxSkin then
		button.enableButton:SetHighlightTexture(E.Media.Textures.Melli)
		button.enableButton.SetHighlightTexture = E.noop

		button.enableButton:SetCheckedTexture(E.Media.Textures.Melli)
		button.enableButton.SetCheckedTexture = E.noop

		button.enableButton:SetDisabledCheckedTexture(E.Media.Textures.Melli)
		button.enableButton.SetDisabledCheckedTexture = E.noop

		local Checked, Highlight, DisabledChecked = button.enableButton:GetCheckedTexture(), button.enableButton:GetHighlightTexture(), button.enableButton:GetDisabledCheckedTexture()

		Checked:SetInside(button.enableButton.backdrop)
		Checked:SetVertexColor(1, 0.8, 0.1, 0.8)

		Highlight:SetInside(button.enableButton.backdrop)
		Highlight:SetVertexColor(1, 1, 1, 0.35)

		DisabledChecked:SetInside(button.enableButton.backdrop)
		DisabledChecked:SetVertexColor(0.6, 0.6, 0.5, 0.8)
	else
		button.enableButton:SetHighlightTexture("")
		button.enableButton.SetHighlightTexture = E.noop
	end

	button.expandOrCollapseButton:SetNormalTexture(E.Media.Textures.Plus)
	button.expandOrCollapseButton:SetHighlightTexture("")
	button.expandOrCollapseButton.SetHighlightTexture = E.noop

	local normal = button.expandOrCollapseButton:GetNormalTexture()
	normal:Size(18)
	normal:Point("CENTER", 3, 4)

	hooksecurefunc(button.expandOrCollapseButton, "SetNormalTexture", function(_, texture)
		if find(texture, "MinusButton") then
			normal:SetTexture(E.Media.Textures.Minus)
		else
			normal:SetTexture(E.Media.Textures.Plus)
		end
	end)

	button.isSkinned = true
end

local function SkinLFG()
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
		button.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() + 3)

		button.icon:Size(58)
		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.icon:Point("LEFT", button, 1, 0)
		button.icon:SetParent(button.backdrop)
		SetPortraitToTexture(button.icon, nil)
	end

	GroupFinderFrameGroupButton1.icon:SetTexture([[Interface\Icons\INV_Helmet_08]])
	GroupFinderFrameGroupButton2.icon:SetTexture([[Interface\Icons\Inv_Helmet_06]])
	GroupFinderFrameGroupButton3.icon:SetTexture([[Interface\Icons\Icon_Scenarios]])
	GroupFinderFrameGroupButton4.icon:SetTexture([[Interface\Icons\Achievement_General_StayClassy]])

	hooksecurefunc("GroupFinderFrame_SelectGroupButton", function(index)
		for i = 1, 4 do			
			local button = GroupFinderFrame["groupButton"..i]
			local border = i == index and E.media.rgbvaluecolor or E.media.bordercolor

			button:SetBackdropBorderColor(unpack(border))
			button.backdrop:SetBackdropBorderColor(unpack(border))
		end
	end)

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

	hooksecurefunc("LFDQueueFrameRandom_UpdateFrame", function()
		local dungeonID = LFDQueueFrame.type
		if type(dungeonID) ~= "number" then return end

		for i = 1, LFD_MAX_REWARDS do
			SkinLFGRewards(_G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i], dungeonID, i)
		end
	end)

	for i = 1, NUM_LFD_CHOICE_BUTTONS do
		SkinSpecificList(_G["LFDQueueFrameSpecificListButton"..i])
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
			SkinLFGRewards(_G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..i], dungeonID, i)
		end
	end)

	hooksecurefunc("ScenarioQueueFrameSpecific_Update", function()
		for i = 1, NUM_SCENARIO_CHOICE_BUTTONS do
			SkinSpecificList(_G["ScenarioQueueFrameSpecificButton"..i])
		end
	end)

	-- Bonus Valor Info
	for _, frame in pairs({"LFDQueueFrame", "ScenarioQueueFrame"}) do
		local item = _G[frame.."RandomScrollFrameChildFrameBonusValor"]

		item:CreateBackdrop()
		item.backdrop:SetOutside(item.Icon)

		item.Icon:SetTexture([[Interface\Icons\pvecurrency-valor]])
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

	hooksecurefunc("LFGDungeonReadyDialogReward_SetMisc", function(button)
		SkinReadyDialogRewards(button)
	end)

	hooksecurefunc("LFGDungeonReadyDialogReward_SetReward", function(button, dungeonID)
		SkinReadyDialogRewards(button, dungeonID)
	end)

	hooksecurefunc("LFGDungeonReadyDialog_UpdateRewards", function()
		for i = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local button = _G["LFGDungeonReadyDialogRewardsFrameReward"..i]
			if button and i ~= 1 then
				button:Point("LEFT", _G["LFGDungeonReadyDialogRewardsFrameReward"..i - 1], "RIGHT", 4, 0)
			end
		end
	end)

	LFGDungeonReadyDialogRoleIcon:StripTextures()
	LFGDungeonReadyDialogRoleIcon:CreateBackdrop()
	LFGDungeonReadyDialogRoleIcon.backdrop:Point("TOPLEFT", 7, -7)
	LFGDungeonReadyDialogRoleIcon.backdrop:Point("BOTTOMRIGHT", -7, 7)

	LFGDungeonReadyDialogRoleIconTexture:SetTexCoord(unpack(E.TexCoords))
	LFGDungeonReadyDialogRoleIconTexture.SetTexCoord = E.noop
	LFGDungeonReadyDialogRoleIconTexture:SetInside(LFGDungeonReadyDialogRoleIcon.backdrop)
	LFGDungeonReadyDialogRoleIconTexture:SetParent(LFGDungeonReadyDialogRoleIcon.backdrop)

	hooksecurefunc("LFGDungeonReadyPopup_Update", function()
		if LFGDungeonReadyDialogRoleIcon:IsShown() then
			local _, _, _, _, _, _, role = GetLFGProposal()

			if role == "DAMAGER" then
				LFGDungeonReadyDialogRoleIconTexture:SetTexture([[Interface\Icons\INV_Knife_1H_Common_B_01]])
			elseif role == "TANK" then
				LFGDungeonReadyDialogRoleIconTexture:SetTexture([[Interface\Icons\Ability_Defend]])
			elseif role == "HEALER" then
				LFGDungeonReadyDialogRoleIconTexture:SetTexture([[Interface\Icons\SPELL_NATURE_HEALINGTOUCH]])
			end
		end
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
			roleButton.texture:Point("TOPLEFT", roleButton.backdrop, -8, 6)
			roleButton.texture:Point("BOTTOMRIGHT", roleButton.backdrop, 8, -9)
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

	-- Role Icons
	local roleButtons = {
		-- Dungeon FInder
		LFDQueueFrameRoleButtonTank,
		LFDQueueFrameRoleButtonDPS,
		LFDQueueFrameRoleButtonHealer,
		LFDQueueFrameRoleButtonLeader,
		-- Raid Finder
		RaidFinderQueueFrameRoleButtonTank,
		RaidFinderQueueFrameRoleButtonDPS,
		RaidFinderQueueFrameRoleButtonHealer,
		RaidFinderQueueFrameRoleButtonLeader,
		-- LFG Role Check
		LFDRoleCheckPopupRoleButtonTank,
		LFDRoleCheckPopupRoleButtonDPS,
		LFDRoleCheckPopupRoleButtonHealer,
		-- LFG Invite
		LFGInvitePopupRoleButtonTank,
		LFGInvitePopupRoleButtonDPS,
		LFGInvitePopupRoleButtonHealer
	}

	for _, btn in pairs(roleButtons) do
		S:HandleRoleButton(btn)
	end

	hooksecurefunc("LFG_SetRoleIconIncentive", function(roleButton, incentiveIndex)
		if incentiveIndex then
			local tex, r, g, b
			if incentiveIndex == LFG_ROLE_SHORTAGE_PLENTIFUL then
				tex = [[Interface\Icons\INV_Misc_Coin_19]]
				r, g, b = 0.82, 0.45, 0.25
			elseif incentiveIndex == LFG_ROLE_SHORTAGE_UNCOMMON then
				tex = [[Interface\Icons\INV_Misc_Coin_18]]
				r, g, b = 0.8, 0.8, 0.8
			elseif incentiveIndex == LFG_ROLE_SHORTAGE_RARE then
				tex = [[Interface\Icons\INV_Misc_Coin_17]]
				r, g, b = 1, 0.82, 0.2
			end

			SetPortraitToTexture(roleButton.incentiveIcon.texture, nil)
			roleButton.incentiveIcon.texture:SetTexture(tex)

			roleButton.backdrop:SetBackdropBorderColor(r, g, b)
			roleButton.incentiveIcon:SetBackdropBorderColor(r, g, b)
		else
			roleButton.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)
end

local function SkinChallengeUI()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lfg then return end

	ChallengesFrameInset:StripTextures(true)

	local _, a, _, _, _, _, _, _, b, c, d = ChallengesFrameDetails:GetRegions()
	a:Hide() b:Hide() c:Hide() d:Hide()
	ChallengesFrameDetails.bg:Hide()

	ChallengesFrameDetails.MapName:ClearAllPoints()
	ChallengesFrameDetails.MapName:Point("TOP", 0, -20)

	for i = 1, 9 do
		local button = ChallengesFrame["button"..i]

		button:CreateBackdrop("Transparent")

		if i == 1 then
			button:Point("TOPLEFT", ChallengesFrame, 6, -40)
		else
			button:Point("TOP", ChallengesFrame["button"..i - 1], "BOTTOM", 0, -8)
		end

		local highlight = button:GetHighlightTexture()
		highlight:SetTexture(E.Media.Textures.Highlight)
		highlight:SetVertexColor(1, 1, 1, 0.35)
		highlight:SetAllPoints()

		button.selectedTex:SetTexture(E.Media.Textures.Highlight)
		button.selectedTex:SetVertexColor(0, 0.7, 1, 0.35)
		button.selectedTex:SetAllPoints()
	end

	for i = 1, 3 do
		local rewardsRow = ChallengesFrame["RewardRow"..i]

		rewardsRow.Bg:SetTexture(E.Media.Textures.Highlight)

		if i == 1 then
			rewardsRow.Bg:SetVertexColor(0.859, 0.545, 0.204, 0.3)
		elseif i == 2 then
			rewardsRow.Bg:SetVertexColor(0.780, 0.722, 0.741, 0.3)
		else
			rewardsRow.Bg:SetVertexColor(0.945, 0.882, 0.337, 0.3)
		end

		for j = 1, 2 do
			local button = rewardsRow["Reward"..j]

			button:CreateBackdrop()
			S:HandleFrameHighlight(button, button.backdrop)

			button.Icon:SetTexCoord(unpack(E.TexCoords))
		end
	end

	S:HandleButton(ChallengesFrameLeaderboard)
end

local function SkinLFR()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lfg then return end

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

	for _, btn in pairs({LFRQueueFrameRoleButtonTank, LFRQueueFrameRoleButtonDPS, LFRQueueFrameRoleButtonHealer}) do
		S:HandleRoleButton(btn)
	end

	LFRQueueFrameRoleButtonTank:Point("TOPLEFT", 58, -40)

	for i = 1, NUM_LFR_CHOICE_BUTTONS do
		SkinSpecificList(_G["LFRQueueFrameSpecificListButton"..i])
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
end

local function SkinQueueStatus()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lfg then return end

	-- Queue Search Status
	QueueStatusFrame:StripTextures()
	QueueStatusFrame:SetTemplate("Transparent")

	hooksecurefunc("QueueStatusEntry_SetFullDisplay", function(entry, _, _, _, isTank, isHealer, isDPS)
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

		if not entry.isSkinned then
			entry.TanksFound:CreateBackdrop()
			entry.TanksFound.Texture:SetTexture([[Interface\Icons\Ability_Defend]])
			entry.TanksFound.Texture:SetTexCoord(unpack(E.TexCoords))

			entry.HealersFound:CreateBackdrop()
			entry.HealersFound.Texture:SetTexture([[Interface\Icons\SPELL_NATURE_HEALINGTOUCH]])
			entry.HealersFound.Texture:SetTexCoord(unpack(E.TexCoords))

			entry.DamagersFound:CreateBackdrop()
			entry.DamagersFound.Texture:SetTexture([[Interface\Icons\INV_Knife_1H_Common_B_01]])
			entry.DamagersFound.Texture:SetTexCoord(unpack(E.TexCoords))

			entry.isSkinned = true
		end
	end)
end

S:AddCallback("LFG", SkinLFG)
S:AddCallback("LFR", SkinLFR)
S:AddCallback("QueueStatus", SkinQueueStatus)
S:AddCallbackForAddon("Blizzard_ChallengesUI", "ChallengesUI", SkinChallengeUI)