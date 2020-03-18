local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs, unpack, select = pairs, unpack, select
local find = string.find

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lfg then return end

	-- PVE Frame
	PVEFrame:StripTextures()
	PVEFrame:SetTemplate("Transparent")

	PVEFrame.shadows:Hide()

	PVEFramePortrait:Hide()
	PVEFramePortraitFrame:Hide()

	PVEFrameLeftInset:StripTextures()

	GroupFinderFrameGroupButton1.icon:SetTexture("Interface\\Icons\\INV_Helmet_08")
	GroupFinderFrameGroupButton2.icon:SetTexture("Interface\\Icons\\inv_helmet_06")
	GroupFinderFrameGroupButton3.icon:SetTexture("Interface\\Icons\\Icon_Scenarios")

	for i = 1, 4 do
		local button = GroupFinderFrame["groupButton"..i]

		button.ring:Hide()
		button.bg:SetTexture("")

		button:SetTemplate()
		button:StyleButton()

		button:CreateBackdrop()
		button.backdrop:SetOutside(button.icon)
		button.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() + 2)

		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.icon:Size(E.PixelMode and 58 or 56)
		button.icon:Point("LEFT", button, 1, 0)
		button.icon:SetParent(button.backdrop)
	end

	for i = 1, 2 do
		S:HandleTab(_G["PVEFrameTab"..i])
	end

	PVEFrameTab1:SetPoint("BOTTOMLEFT", PVEFrame, 19, -30)

	S:HandleCloseButton(PVEFrameCloseButton)

	-- Dungeon Finder
	LFDParentFrame:StripTextures()
	LFDParentFrameInset:StripTextures()

	LFDQueueFrame:StripTextures()

	LFDQueueFrameBackground:Kill()

	LFDQueueFrameSpecificListScrollFrame:StripTextures()

	-- LFD Role Icons
	local lfdQueueRoleIcons = {
		"LFDQueueFrameRoleButtonTank",
		"LFDQueueFrameRoleButtonHealer",
		"LFDQueueFrameRoleButtonDPS",
		"LFDQueueFrameRoleButtonLeader"
	}

	for i = 1, #lfdQueueRoleIcons do
		_G[lfdQueueRoleIcons[i]]:StripTextures()
		_G[lfdQueueRoleIcons[i]]:CreateBackdrop()
		_G[lfdQueueRoleIcons[i]].backdrop:Point("TOPLEFT", 5, -5)
		_G[lfdQueueRoleIcons[i]].backdrop:Point("BOTTOMRIGHT", -5, 5)
		_G[lfdQueueRoleIcons[i]]:Size(56)

		_G[lfdQueueRoleIcons[i]]:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		_G[lfdQueueRoleIcons[i]]:GetNormalTexture():SetInside(_G[lfdQueueRoleIcons[i]].backdrop)

		S:HandleCheckBox(_G[lfdQueueRoleIcons[i]].checkButton, true)
	end

	LFDQueueFrameRoleButtonTank:Point("BOTTOMLEFT", 20, 334)
	LFDQueueFrameRoleButtonLeader:Point("LEFT", LFDQueueFrameRoleButtonDPS, "RIGHT", 34, 0)

	LFDQueueFrameRoleButtonTank:SetNormalTexture("Interface\\Icons\\Ability_Defend")
	LFDQueueFrameRoleButtonHealer:SetNormalTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")
	LFDQueueFrameRoleButtonDPS:SetNormalTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")
	LFDQueueFrameRoleButtonLeader:SetNormalTexture("Interface\\Icons\\Ability_Vehicle_LaunchPlayer")

	LFDQueueFrameRandomScrollFrameChildFrameBonusValor:StripTextures()
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor:CreateBackdrop("Default", nil, true)
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor.backdrop:Point("TOPLEFT", 0, -7)
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor.backdrop:Point("BOTTOMRIGHT", -258, 7)
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor.texture = LFDQueueFrameRandomScrollFrameChildFrameBonusValor:CreateTexture(nil, "OVERLAY")
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor.texture:SetTexture("Interface\\Icons\\pvecurrency-valor")
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor.texture:SetTexCoord(unpack(E.TexCoords))
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor.texture:SetInside(LFDQueueFrameRandomScrollFrameChildFrameBonusValor.backdrop)
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor.texture:SetParent(LFDQueueFrameRandomScrollFrameChildFrameBonusValor.backdrop)

	S:HandleButton(_G[LFDQueueFrame.PartyBackfill:GetName().."BackfillButton"])
	S:HandleButton(_G[LFDQueueFrame.PartyBackfill:GetName().."NoBackfillButton"])

	S:HandleButton(LFDQueueFramePartyBackfillBackfillButton)
	S:HandleButton(LFDQueueFramePartyBackfillNoBackfillButton)
	S:HandleButton(LFDQueueFrameRandomScrollFrameChildFrameBonusRepFrame.ChooseButton)

	S:HandleButton(LFDQueueFrameFindGroupButton)

	S:HandleDropDownBox(LFDQueueFrameTypeDropDown)
	LFDQueueFrameTypeDropDown:Point("BOTTOMLEFT", 107, 285)

	LFDQueueFrameRandomScrollFrameScrollBar:StripTextures()
	S:HandleScrollBar(LFDQueueFrameRandomScrollFrameScrollBar)

	S:HandleScrollBar(LFDQueueFrameSpecificListScrollFrameScrollBar)

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
					local count = _G[buttonName.."Count"]
					local icon = _G[buttonName.."IconTexture"]

					button:StripTextures()
					button:SetTemplate("Transparent")
					button:StyleButton(nil, true)
					button:CreateBackdrop()
					button.backdrop:SetOutside(icon)

					if i == 1 then
						button:Point("TOPLEFT", LFDQueueFrameRandomScrollFrameChildFrameRewardsDescription, "BOTTOMLEFT", -5, -10)
					else
						button:Point("LEFT", LFDQueueFrameRandomScrollFrameChildFrameItem1, "RIGHT", 4, 0) 
					end

					icon:Point("TOPLEFT", 1, -1)
					icon:SetTexture(icon:GetTexture())
					icon:SetTexCoord(unpack(E.TexCoords))
					icon:SetParent(button.backdrop)
					icon:SetDrawLayer("OVERLAY")

					count:SetParent(button.backdrop)
					count:SetDrawLayer("OVERLAY")

					for j = 1, 2 do
						_G[button:GetName().."RoleIcon"..j]:SetParent(button.backdrop)
					end

					button.isSkinned = true
				end

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
	end)

	for i = 1, NUM_LFD_CHOICE_BUTTONS do
		local button = _G["LFDQueueFrameSpecificListButton"..i]

		S:HandleCheckBox(button.enableButton)

		button.expandOrCollapseButton:SetNormalTexture(E.Media.Textures.Plus)
		button.expandOrCollapseButton.SetNormalTexture = E.noop

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
	ScenarioFinderFrameInset:DisableDrawLayer("BORDER")
	ScenarioFinderFrame.TopTileStreaks:Hide()
	ScenarioFinderFrameBtnCornerRight:Hide()
	ScenarioFinderFrameButtonBottomBorder:Hide()
	ScenarioQueueFrame.Bg:Hide()
	ScenarioFinderFrameInset:GetRegions():Hide()

	ScenarioQueueFrameSpecificScrollFrame:StripTextures()

	ScenarioQueueFrameRandomScrollFrameChildFrameBonusValor:StripTextures()
	ScenarioQueueFrameRandomScrollFrameChildFrameBonusValor:CreateBackdrop("Default", nil, true)
	ScenarioQueueFrameRandomScrollFrameChildFrameBonusValor.backdrop:Point("TOPLEFT", 0, -7)
	ScenarioQueueFrameRandomScrollFrameChildFrameBonusValor.backdrop:Point("BOTTOMRIGHT", -258, 7)
	ScenarioQueueFrameRandomScrollFrameChildFrameBonusValor.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))

	ScenarioQueueFrameRandomScrollFrameChildFrameBonusValor.texture = ScenarioQueueFrameRandomScrollFrameChildFrameBonusValor:CreateTexture(nil, "OVERLAY")
	ScenarioQueueFrameRandomScrollFrameChildFrameBonusValor.texture:SetTexture("Interface\\Icons\\pvecurrency-valor")
	ScenarioQueueFrameRandomScrollFrameChildFrameBonusValor.texture:SetTexCoord(unpack(E.TexCoords))
	ScenarioQueueFrameRandomScrollFrameChildFrameBonusValor.texture:SetInside(ScenarioQueueFrameRandomScrollFrameChildFrameBonusValor.backdrop)
	ScenarioQueueFrameRandomScrollFrameChildFrameBonusValor.texture:SetParent(ScenarioQueueFrameRandomScrollFrameChildFrameBonusValor.backdrop)

	ScenarioQueueFrameFindGroupButton:StripTextures()
	S:HandleButton(ScenarioQueueFrameFindGroupButton)

	S:HandleButton(_G[ScenarioQueueFrame.PartyBackfill:GetName().."BackfillButton"])
	S:HandleButton(_G[ScenarioQueueFrame.PartyBackfill:GetName().."NoBackfillButton"])

	S:HandleButton(ScenarioQueueFrameRandomScrollFrameChildFrameBonusRepFrame.ChooseButton)

	S:HandleDropDownBox(ScenarioQueueFrameTypeDropDown)
	ScenarioQueueFrameTypeDropDown:Point("TOPLEFT", 107, -40)

	S:HandleScrollBar(ScenarioQueueFrameRandomScrollFrameScrollBar)
	S:HandleScrollBar(ScenarioQueueFrameSpecificScrollFrameScrollBar)

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
					local count = _G[buttonName.."Count"]
					local icon = _G[buttonName.."IconTexture"]

					button:StripTextures()
					button:SetTemplate("Transparent")
					button:StyleButton(nil, true)
					button:CreateBackdrop()
					button.backdrop:SetOutside(icon)

					if i == 1 then
						button:Point("TOPLEFT", ScenarioQueueFrameRandomScrollFrameChildFrameRewardsDescription, "BOTTOMLEFT", -5, -10)
					else
						button:Point("LEFT", ScenarioQueueFrameRandomScrollFrameChildFrameItem1, "RIGHT", 4, 0) 
					end

					icon:Point("TOPLEFT", 1, -1)
					icon:SetTexture(icon:GetTexture())
					icon:SetTexCoord(unpack(E.TexCoords))
					icon:SetParent(button.backdrop)
					icon:SetDrawLayer("OVERLAY")

					count:SetParent(button.backdrop)
					count:SetDrawLayer("OVERLAY")

					button.isSkinned = true
				end

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
	end)

	hooksecurefunc("ScenarioQueueFrameSpecific_Update", function()
		for i = 1, NUM_SCENARIO_CHOICE_BUTTONS do
			local button = _G["ScenarioQueueFrameSpecificButton"..i]

			if button and not button.isSkinned then
				S:HandleCheckBox(button.enableButton)

				button.expandOrCollapseButton:SetNormalTexture(E.Media.Textures.Plus)
				button.expandOrCollapseButton.SetNormalTexture = E.noop

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

	-- Raid Finder
	RaidFinderFrame:StripTextures()
	RaidFinderFrameBottomInset:StripTextures()
	RaidFinderFrameRoleInset:StripTextures()

	RaidFinderQueueFrame:StripTextures(true)
	RaidFinderQueueFrame:StripTextures()

	RaidFinderFrameBottomInsetBg:Hide()
	RaidFinderFrameBtnCornerRight:Hide()
	RaidFinderFrameButtonBottomBorder:Hide()

	-- Raid Finder Role Icons
	local raidFinderQueueRoleIcons = {
		"RaidFinderQueueFrameRoleButtonTank",
		"RaidFinderQueueFrameRoleButtonHealer",
		"RaidFinderQueueFrameRoleButtonDPS",
		"RaidFinderQueueFrameRoleButtonLeader"
	}

	for i = 1, #raidFinderQueueRoleIcons do
		S:HandleCheckBox(_G[raidFinderQueueRoleIcons[i]].checkButton, true)

		_G[raidFinderQueueRoleIcons[i]]:StripTextures()
		_G[raidFinderQueueRoleIcons[i]]:CreateBackdrop()
		_G[raidFinderQueueRoleIcons[i]].backdrop:Point("TOPLEFT", 5, -5)
		_G[raidFinderQueueRoleIcons[i]].backdrop:Point("BOTTOMRIGHT", -5, 5)
		_G[raidFinderQueueRoleIcons[i]]:Size(56)

		_G[raidFinderQueueRoleIcons[i]]:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		_G[raidFinderQueueRoleIcons[i]]:GetNormalTexture():SetInside(_G[raidFinderQueueRoleIcons[i]].backdrop)
	end

	RaidFinderQueueFrameRoleButtonTank:SetNormalTexture("Interface\\Icons\\Ability_Defend")
	RaidFinderQueueFrameRoleButtonHealer:SetNormalTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")
	RaidFinderQueueFrameRoleButtonDPS:SetNormalTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")
	RaidFinderQueueFrameRoleButtonLeader:SetNormalTexture("Interface\\Icons\\Ability_Vehicle_LaunchPlayer")

	RaidFinderQueueFrameRoleButtonTank:Point("BOTTOMLEFT", 20, 336)
	RaidFinderQueueFrameRoleButtonLeader:Point("LEFT", RaidFinderQueueFrameRoleButtonDPS, "RIGHT", 34, 0)

	S:HandleButton(_G[RaidFinderQueueFrame.PartyBackfill:GetName().."BackfillButton"])
	S:HandleButton(_G[RaidFinderQueueFrame.PartyBackfill:GetName().."NoBackfillButton"])

	S:HandleDropDownBox(RaidFinderQueueFrameSelectionDropDown)
	RaidFinderQueueFrameSelectionDropDown:Point("BOTTOMLEFT", 107, 287)

	RaidFinderFrameFindRaidButton:StripTextures()
	S:HandleButton(RaidFinderFrameFindRaidButton)

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

		tab:GetRegions():Hide()
		tab:SetTemplate()
		tab:StyleButton(nil, true)
		tab:GetNormalTexture():SetInside()
		tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
	end

	LFRParentFrameSideTab1:Point("TOPLEFT", LFRParentFrame, "TOPRIGHT", E.PixelMode and -1 or 1, -35)

	-- LFR Queue Frame
	LFRParentFrame:StripTextures()
	LFRQueueFrame:StripTextures()
	LFRQueueFrameListInset:StripTextures()
	LFRQueueFrameRoleInset:StripTextures()
	LFRQueueFrameCommentInset:StripTextures()

	LFRQueueFrameSpecificListScrollFrameScrollBackgroundTopLeft:Hide()
	LFRQueueFrameSpecificListScrollFrameScrollBackgroundBottomRight:Hide()

	LFRQueueFrameCommentScrollFrame:StripTextures()
	LFRQueueFrameCommentScrollFrame:CreateBackdrop()

	-- LFR Queue Role Icons
	local lfrQueueRoleIcons = {
		"LFRQueueFrameRoleButtonTank",
		"LFRQueueFrameRoleButtonHealer",
		"LFRQueueFrameRoleButtonDPS"
	}

	for i = 1, #lfrQueueRoleIcons do
		S:HandleCheckBox(_G[lfrQueueRoleIcons[i]]:GetChildren())
		_G[lfrQueueRoleIcons[i]]:GetChildren():SetFrameLevel(_G[lfrQueueRoleIcons[i]]:GetChildren():GetFrameLevel() + 2)

		_G[lfrQueueRoleIcons[i]]:StripTextures()
		_G[lfrQueueRoleIcons[i]]:CreateBackdrop()
		_G[lfrQueueRoleIcons[i]].backdrop:Point("TOPLEFT", 3, -3)
		_G[lfrQueueRoleIcons[i]].backdrop:Point("BOTTOMRIGHT", -3, 3)

		_G[lfrQueueRoleIcons[i]].texture = _G[lfrQueueRoleIcons[i]]:CreateTexture(nil, "OVERLAY")
		_G[lfrQueueRoleIcons[i]].texture:SetTexCoord(unpack(E.TexCoords))
		_G[lfrQueueRoleIcons[i]].texture:SetInside(_G[lfrQueueRoleIcons[i]].backdrop)
	end

	LFRQueueFrameRoleButtonTank.texture:SetTexture("Interface\\Icons\\Ability_Defend")
	LFRQueueFrameRoleButtonHealer.texture:SetTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")
	LFRQueueFrameRoleButtonDPS.texture:SetTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")

	S:HandleButton(LFRQueueFrameFindGroupButton)
	S:HandleButton(LFRQueueFrameAcceptCommentButton)

	S:HandleScrollBar(LFRQueueFrameCommentScrollFrameScrollBar)
	S:HandleScrollBar(LFRQueueFrameSpecificListScrollFrameScrollBar)

	for i = 1, NUM_LFR_CHOICE_BUTTONS do
		local button = _G["LFRQueueFrameSpecificListButton"..i]

		S:HandleCheckBox(button.enableButton)

		button.expandOrCollapseButton:SetNormalTexture(E.Media.Textures.Plus)
		button.expandOrCollapseButton.SetNormalTexture = E.noop

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
	LFRBrowseFrameListScrollFrame:StripTextures()
	LFRBrowseFrameRoleInsetBg:Hide()
	LFRBrowseFrameRoleInset:DisableDrawLayer("BORDER")

	RaidBrowserFrameBg:Hide()

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
	end

	LFRBrowseFrameColumnHeader1:Width(88)

	S:HandleButton(LFRBrowseFrameSendMessageButton)
	S:HandleButton(LFRBrowseFrameInviteButton)
	S:HandleButton(LFRBrowseFrameRefreshButton)

	S:HandleDropDownBox(LFRBrowseFrameRaidDropDown)

	S:HandleCloseButton(RaidBrowserFrameCloseButton)

	LFRBrowseFrame:HookScript("OnShow", function()
		if not LFRBrowseFrameListScrollFrameScrollBar.isSkinned then
			S:HandleScrollBar(LFRBrowseFrameListScrollFrameScrollBar)

			LFRBrowseFrameListScrollFrameScrollBar.isSkinned = true
		end
	end)

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
	FlexRaidFrameScrollFrame:StripTextures()
	FlexRaidFrameBottomInset:StripTextures()

	FlexRaidFrame.ScrollFrame.Background:SetTexture()
	FlexRaidFrame.ScrollFrame.Background.SetTexture = E.noop

	S:HandleDropDownBox(FlexRaidFrameSelectionDropDown)
	S:HandleButton(FlexRaidFrameStartRaidButton)

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

	-- LFD Role Check Icons
	local lfdRoleCheckRoleIcons = {
		"LFDRoleCheckPopupRoleButtonTank",
		"LFDRoleCheckPopupRoleButtonHealer",
		"LFDRoleCheckPopupRoleButtonDPS"
	}

	for i = 1, #lfdRoleCheckRoleIcons do
		S:HandleCheckBox(_G[lfdRoleCheckRoleIcons[i]]:GetChildren())
		_G[lfdRoleCheckRoleIcons[i]]:GetChildren():SetFrameLevel(_G[lfdRoleCheckRoleIcons[i]]:GetChildren():GetFrameLevel() + 2)

		_G[lfdRoleCheckRoleIcons[i]]:StripTextures()
		_G[lfdRoleCheckRoleIcons[i]]:CreateBackdrop()
		_G[lfdRoleCheckRoleIcons[i]].backdrop:Point("TOPLEFT", 3, -3)
		_G[lfdRoleCheckRoleIcons[i]].backdrop:Point("BOTTOMRIGHT", -3, 3)

		_G[lfdRoleCheckRoleIcons[i]]:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		_G[lfdRoleCheckRoleIcons[i]]:GetNormalTexture():SetInside(_G[lfdRoleCheckRoleIcons[i]].backdrop)
	end

	LFDRoleCheckPopupRoleButtonTank:SetNormalTexture("Interface\\Icons\\Ability_Defend")
	LFDRoleCheckPopupRoleButtonHealer:SetNormalTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")
	LFDRoleCheckPopupRoleButtonDPS:SetNormalTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")

	-- LFG Invite PopUp
	LFGInvitePopup:StripTextures()
	LFGInvitePopup:SetTemplate("Transparent")

	S:HandleButton(LFGInvitePopupAcceptButton)
	S:HandleButton(LFGInvitePopupDeclineButton)

	-- LFD Role Check Icons
	local lfgInviteRoleIcons = {
		"LFGInvitePopupRoleButtonTank",
		"LFGInvitePopupRoleButtonHealer",
		"LFGInvitePopupRoleButtonDPS"
	}

	for i = 1, #lfgInviteRoleIcons do
		_G[lfgInviteRoleIcons[i]]:StripTextures()
		_G[lfgInviteRoleIcons[i]]:CreateBackdrop()
		_G[lfgInviteRoleIcons[i]].backdrop:Point("TOPLEFT", 3, -3)
		_G[lfgInviteRoleIcons[i]].backdrop:Point("BOTTOMRIGHT", -3, 3)

		_G[lfgInviteRoleIcons[i]]:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		_G[lfgInviteRoleIcons[i]]:GetNormalTexture():SetInside(_G[lfgInviteRoleIcons[i]].backdrop)

		S:HandleCheckBox(_G[lfgInviteRoleIcons[i]]:GetChildren())
		_G[lfgInviteRoleIcons[i]]:GetChildren():SetFrameLevel(_G[lfgInviteRoleIcons[i]]:GetChildren():GetFrameLevel() + 2)
	end

	LFGInvitePopupRoleButtonTank:SetNormalTexture("Interface\\Icons\\Ability_Defend")
	LFGInvitePopupRoleButtonHealer:SetNormalTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH")
	LFGInvitePopupRoleButtonDPS:SetNormalTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01")

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

	-- Incentive Role Icons
	hooksecurefunc("LFG_SetRoleIconIncentive", function(roleButton, incentiveIndex)
		if incentiveIndex then
			roleButton.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
		else
			roleButton.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
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