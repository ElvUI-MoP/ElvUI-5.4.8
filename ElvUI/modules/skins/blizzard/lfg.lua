local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local _G = _G;
local pairs, unpack, select = pairs, unpack, select;
local find = string.find;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfg ~= true) then return end

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

		button:SetTemplate("Default");
		button:StyleButton()

		button:CreateBackdrop("Default");
		button.backdrop:SetOutside(button.icon);
		button.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() + 2);

		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.icon:Size(E.PixelMode and 58 or 56)
		button.icon:Point("LEFT", button, 1, 0);
		button.icon:SetParent(button.backdrop);
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

	LFDQueueFrameRoleButtonTank:StripTextures();
	LFDQueueFrameRoleButtonTank:CreateBackdrop();
	LFDQueueFrameRoleButtonTank:Size(50);
	LFDQueueFrameRoleButtonTank.texture = LFDQueueFrameRoleButtonTank:CreateTexture(nil, "ARTWORK");
	LFDQueueFrameRoleButtonTank.texture:SetTexture("Interface\\Icons\\Ability_Defend");
	LFDQueueFrameRoleButtonTank.texture:SetTexCoord(unpack(E.TexCoords));
	LFDQueueFrameRoleButtonTank.texture:SetInside(LFDQueueFrameRoleButtonTank.backdrop);
	LFDQueueFrameRoleButtonTank:Point("BOTTOMLEFT", 20, 334)
	S:HandleCheckBox(LFDQueueFrameRoleButtonTank.checkButton, true)


	LFDQueueFrameRoleButtonHealer:StripTextures();
	LFDQueueFrameRoleButtonHealer:CreateBackdrop();
	LFDQueueFrameRoleButtonHealer:Size(50);
	LFDQueueFrameRoleButtonHealer.texture = LFDQueueFrameRoleButtonHealer:CreateTexture(nil, "ARTWORK");
	LFDQueueFrameRoleButtonHealer.texture:SetTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH");
	LFDQueueFrameRoleButtonHealer.texture:SetTexCoord(unpack(E.TexCoords));
	LFDQueueFrameRoleButtonHealer.texture:SetInside(LFDQueueFrameRoleButtonHealer.backdrop);
	S:HandleCheckBox(LFDQueueFrameRoleButtonHealer.checkButton, true)

	LFDQueueFrameRoleButtonDPS:StripTextures();
	LFDQueueFrameRoleButtonDPS:CreateBackdrop();
	LFDQueueFrameRoleButtonDPS:Size(50);
	LFDQueueFrameRoleButtonDPS.texture = LFDQueueFrameRoleButtonDPS:CreateTexture(nil, "ARTWORK");
	LFDQueueFrameRoleButtonDPS.texture:SetTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01");
	LFDQueueFrameRoleButtonDPS.texture:SetTexCoord(unpack(E.TexCoords));
	LFDQueueFrameRoleButtonDPS.texture:SetInside(LFDQueueFrameRoleButtonDPS.backdrop);
	S:HandleCheckBox(LFDQueueFrameRoleButtonDPS.checkButton, true)

	LFDQueueFrameRoleButtonLeader:StripTextures();
	LFDQueueFrameRoleButtonLeader:CreateBackdrop();
	LFDQueueFrameRoleButtonLeader:Size(50);
	LFDQueueFrameRoleButtonLeader.texture = LFDQueueFrameRoleButtonLeader:CreateTexture(nil, "ARTWORK");
	LFDQueueFrameRoleButtonLeader.texture:SetTexture("Interface\\Icons\\Ability_Vehicle_LaunchPlayer");
	LFDQueueFrameRoleButtonLeader.texture:SetTexCoord(unpack(E.TexCoords));
	LFDQueueFrameRoleButtonLeader.texture:SetInside(LFDQueueFrameRoleButtonLeader.backdrop);
	LFDQueueFrameRoleButtonLeader:Point("LEFT", LFDQueueFrameRoleButtonDPS, "RIGHT", 55, 0)
	S:HandleCheckBox(LFDQueueFrameRoleButtonLeader.checkButton, true)

	LFDQueueFrameRandomScrollFrameChildFrameBonusValor:StripTextures()
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor:CreateBackdrop("Default", nil, true)
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor.backdrop:Point("TOPLEFT", 0, -7)
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor.backdrop:Point("BOTTOMRIGHT", -258, 7)
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor.backdrop:SetBackdropBorderColor(0, 0, 0);
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor.texture = LFDQueueFrameRandomScrollFrameChildFrameBonusValor:CreateTexture(nil, "OVERLAY");
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor.texture:SetTexture("Interface\\Icons\\pvecurrency-valor")
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor.texture:SetTexCoord(unpack(E.TexCoords))
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor.texture:SetInside(LFDQueueFrameRandomScrollFrameChildFrameBonusValor.backdrop)
	LFDQueueFrameRandomScrollFrameChildFrameBonusValor.texture:SetParent(LFDQueueFrameRandomScrollFrameChildFrameBonusValor.backdrop)

	S:HandleButton(_G[LFDQueueFrame.PartyBackfill:GetName().."BackfillButton"])
	S:HandleButton(_G[LFDQueueFrame.PartyBackfill:GetName().."NoBackfillButton"])

	S:HandleButton(LFDQueueFramePartyBackfillBackfillButton)
	S:HandleButton(LFDQueueFramePartyBackfillNoBackfillButton)
	S:HandleButton(LFDQueueFrameRandomScrollFrameChildFrameBonusRepFrame.ChooseButton)

	S:HandleButton(LFDQueueFrameFindGroupButton, true)

	S:HandleDropDownBox(LFDQueueFrameTypeDropDown)
	LFDQueueFrameTypeDropDown:Point("BOTTOMLEFT", 107, 285)

	LFDQueueFrameRandomScrollFrameScrollBar:StripTextures()
	S:HandleScrollBar(LFDQueueFrameRandomScrollFrameScrollBar)

	S:HandleScrollBar(LFDQueueFrameSpecificListScrollFrameScrollBar)

	hooksecurefunc("LFDQueueFrameRandom_UpdateFrame", function()
		for i = 1, LFD_MAX_REWARDS do
			local button = _G["LFDQueueFrameRandomScrollFrameChildFrameItem" .. i];

			if(button and not button.reskinned) then
				local icon = _G["LFDQueueFrameRandomScrollFrameChildFrameItem" .. i .. "IconTexture"];
				local border = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."ShortageBorder"]
				local count = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."Count"]
				local nameFrame = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."NameFrame"]
				local name  = _G["LFDQueueFrameRandomScrollFrameChildFrameItem" .. i .. "Name"];
				local role1 = _G["LFDQueueFrameRandomScrollFrameChildFrameItem" .. i .. "RoleIcon1"];
				local role2 = _G["LFDQueueFrameRandomScrollFrameChildFrameItem" .. i .. "RoleIcon2"];
				local role3 = _G["LFDQueueFrameRandomScrollFrameChildFrameItem" .. i .. "RoleIcon3"];

				local __texture = _G[button:GetName().."IconTexture"]:GetTexture()

				button:StripTextures();
				button:CreateBackdrop();
				button.backdrop:SetOutside(icon);

				icon:SetTexture(__texture)
				icon:SetTexCoord(unpack(E.TexCoords))
				icon:SetDrawLayer("OVERLAY")
				icon:SetParent(button.backdrop)

				count:SetDrawLayer("OVERLAY")
				count:SetParent(button.backdrop)

				if(role1) then role1:SetParent(button.backdrop); end
				if(role2) then role2:SetParent(button.backdrop); end
				if(role3) then role3:SetParent(button.backdrop); end

				button:HookScript("OnUpdate", function(self)
					button.backdrop:SetBackdropBorderColor(0, 0, 0);
					name:SetTextColor(1, 1, 1);
					if(button.dungeonID) then
						local Link = GetLFGDungeonRewardLink(button.dungeonID, i);
						if(Link) then
							local quality = select(3, GetItemInfo(Link));
							if(quality and quality > 1) then
								button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality));
								name:SetTextColor(GetItemQualityColor(quality));
							end
						end
					end
				end)
				button.reskinned = true
			end
		end
	end)

	for i = 1, NUM_LFD_CHOICE_BUTTONS do
		local button = _G["LFDQueueFrameSpecificListButton" .. i];
		S:HandleCheckBox(_G["LFDQueueFrameSpecificListButton"..i].enableButton)

		button.expandOrCollapseButton:SetNormalTexture("Interface\\Buttons\\UI-PlusMinus-Buttons");
		button.expandOrCollapseButton.SetNormalTexture = E.noop;
		button.expandOrCollapseButton:SetHighlightTexture(nil);
		button.expandOrCollapseButton:GetNormalTexture():Size(12);
		button.expandOrCollapseButton:GetNormalTexture():Point("CENTER", 4, 0);

		hooksecurefunc(button.expandOrCollapseButton, "SetNormalTexture", function(self, texture)
			if(find(texture, "MinusButton")) then
				self:GetNormalTexture():SetTexCoord(0.5625, 1, 0, 0.4375);
			else
				self:GetNormalTexture():SetTexCoord(0, 0.4375, 0, 0.4375);
			end
		end);
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
	ScenarioQueueFrameRandomScrollFrameChildFrameBonusValor.backdrop:SetBackdropBorderColor(0, 0, 0);

	ScenarioQueueFrameRandomScrollFrameChildFrameBonusValor.texture = ScenarioQueueFrameRandomScrollFrameChildFrameBonusValor:CreateTexture(nil, "OVERLAY");
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

	S:HandleScrollBar(ScenarioQueueFrameRandomScrollFrameScrollBar);
	S:HandleScrollBar(ScenarioQueueFrameSpecificScrollFrameScrollBar)

	hooksecurefunc("ScenarioQueueFrameRandom_UpdateFrame", function()
		for i = 1, LFD_MAX_REWARDS do
			local button = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..i]
			local icon = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..i.."IconTexture"]

			if(button) then
				if(not button.reskinned) then
					local border = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..i.."ShortageBorder"]
					local count = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..i.."Count"]
					local nameFrame = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..i.."NameFrame"]
					local name  = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem" .. i .. "Name"];

					button.bg = CreateFrame("Frame", nil, button)
					button.bg:SetTemplate()
					button.bg:SetOutside(icon)

					icon:SetTexCoord(unpack(E.TexCoords));
					icon:SetDrawLayer("OVERLAY")
					icon:SetParent(button.bg);

					count:SetDrawLayer("OVERLAY")
					count:SetParent(button.bg)

					nameFrame:SetTexture()
					nameFrame:Size(118, 39)

					border:SetAlpha(0)

					button:HookScript("OnUpdate", function(self)
						button.bg:SetBackdropBorderColor(0, 0, 0);
						name:SetTextColor(1, 1, 1);
						if(button.dungeonID) then
							local Link = GetLFGDungeonRewardLink(button.dungeonID, i);
							if(Link) then
								local quality = select(3, GetItemInfo(Link));
								if(quality and quality > 1) then
									button.bg:SetBackdropBorderColor(GetItemQualityColor(quality));
									name:SetTextColor(GetItemQualityColor(quality));
								end
							end
						end
					end)
					button.reskinned = true
				end
			end
		end
	end)

	hooksecurefunc("ScenarioQueueFrameSpecific_Update", function()
		for i = 1, NUM_SCENARIO_CHOICE_BUTTONS do
			local button = _G["ScenarioQueueFrameSpecificButton"..i]
			if button and not button.skinned then
				S:HandleCheckBox(_G["ScenarioQueueFrameSpecificButton"..i].enableButton)

				button.expandOrCollapseButton:SetNormalTexture("Interface\\Buttons\\UI-PlusMinus-Buttons");
				button.expandOrCollapseButton.SetNormalTexture = E.noop;
				button.expandOrCollapseButton:SetHighlightTexture(nil);
				button.expandOrCollapseButton:GetNormalTexture():Size(12);
				button.expandOrCollapseButton:GetNormalTexture():Point("CENTER", 4, 0);

				hooksecurefunc(button.expandOrCollapseButton, "SetNormalTexture", function(self, texture)
					if(find(texture, "MinusButton")) then
						self:GetNormalTexture():SetTexCoord(0.5625, 1, 0, 0.4375);
					else
						self:GetNormalTexture():SetTexCoord(0, 0.4375, 0, 0.4375);
					end
				end);

				button.skinned = true;
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

	RaidFinderQueueFrameRoleButtonTank:StripTextures();
	RaidFinderQueueFrameRoleButtonTank:CreateBackdrop();
	RaidFinderQueueFrameRoleButtonTank:Size(50);
	RaidFinderQueueFrameRoleButtonTank.texture = RaidFinderQueueFrameRoleButtonTank:CreateTexture(nil, "ARTWORK");
	RaidFinderQueueFrameRoleButtonTank.texture:SetTexture("Interface\\Icons\\Ability_Defend");
	RaidFinderQueueFrameRoleButtonTank.texture:SetTexCoord(unpack(E.TexCoords));
	RaidFinderQueueFrameRoleButtonTank.texture:SetInside(RaidFinderQueueFrameRoleButtonTank.backdrop);
	RaidFinderQueueFrameRoleButtonTank:Point("BOTTOMLEFT", 20, 336)
	S:HandleCheckBox(RaidFinderQueueFrameRoleButtonTank.checkButton, true)

	RaidFinderQueueFrameRoleButtonHealer:StripTextures();
	RaidFinderQueueFrameRoleButtonHealer:CreateBackdrop();
	RaidFinderQueueFrameRoleButtonHealer:Size(50);
	RaidFinderQueueFrameRoleButtonHealer.texture = RaidFinderQueueFrameRoleButtonHealer:CreateTexture(nil, "ARTWORK");
	RaidFinderQueueFrameRoleButtonHealer.texture:SetTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH");
	RaidFinderQueueFrameRoleButtonHealer.texture:SetTexCoord(unpack(E.TexCoords));
	RaidFinderQueueFrameRoleButtonHealer.texture:SetInside(RaidFinderQueueFrameRoleButtonHealer.backdrop);
	S:HandleCheckBox(RaidFinderQueueFrameRoleButtonHealer.checkButton, true)

	RaidFinderQueueFrameRoleButtonDPS:StripTextures();
	RaidFinderQueueFrameRoleButtonDPS:CreateBackdrop();
	RaidFinderQueueFrameRoleButtonDPS:Size(50);
	RaidFinderQueueFrameRoleButtonDPS.texture = RaidFinderQueueFrameRoleButtonDPS:CreateTexture(nil, "ARTWORK");
	RaidFinderQueueFrameRoleButtonDPS.texture:SetTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01");
	RaidFinderQueueFrameRoleButtonDPS.texture:SetTexCoord(unpack(E.TexCoords));
	RaidFinderQueueFrameRoleButtonDPS.texture:SetInside(RaidFinderQueueFrameRoleButtonDPS.backdrop);
	S:HandleCheckBox(RaidFinderQueueFrameRoleButtonDPS.checkButton, true)

	RaidFinderQueueFrameRoleButtonLeader:StripTextures();
	RaidFinderQueueFrameRoleButtonLeader:CreateBackdrop();
	RaidFinderQueueFrameRoleButtonLeader:Size(50);
	RaidFinderQueueFrameRoleButtonLeader.texture = RaidFinderQueueFrameRoleButtonLeader:CreateTexture(nil, "ARTWORK");
	RaidFinderQueueFrameRoleButtonLeader.texture:SetTexture("Interface\\Icons\\Ability_Vehicle_LaunchPlayer");
	RaidFinderQueueFrameRoleButtonLeader.texture:SetTexCoord(unpack(E.TexCoords));
	RaidFinderQueueFrameRoleButtonLeader.texture:SetInside(RaidFinderQueueFrameRoleButtonLeader.backdrop);
	RaidFinderQueueFrameRoleButtonLeader:Point("LEFT", RaidFinderQueueFrameRoleButtonDPS, "RIGHT", 55, 0)
	S:HandleCheckBox(RaidFinderQueueFrameRoleButtonLeader.checkButton, true)

	S:HandleButton(_G[RaidFinderQueueFrame.PartyBackfill:GetName().."BackfillButton"])
	S:HandleButton(_G[RaidFinderQueueFrame.PartyBackfill:GetName().."NoBackfillButton"])

	S:HandleDropDownBox(RaidFinderQueueFrameSelectionDropDown)
	RaidFinderQueueFrameSelectionDropDown:Point("BOTTOMLEFT", 107, 287)

	RaidFinderFrameFindRaidButton:StripTextures()
	S:HandleButton(RaidFinderFrameFindRaidButton)

	for i = 1, LFD_MAX_REWARDS do
		local button = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i]
		local icon = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."IconTexture"]

		if(button) then
			if(not button.reskinned) then
				local border = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."ShortageBorder"]
				local count = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."Count"]
				local nameFrame = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."NameFrame"]

				button:StripTextures()

				button.bg = CreateFrame("Frame", nil, button)
				button.bg:SetTemplate()
				button.bg:SetOutside(icon)

				icon:SetTexCoord(unpack(E.TexCoords))
				icon:SetDrawLayer("OVERLAY")
				icon:SetParent(button.bg)

				count:SetDrawLayer("OVERLAY")
				count:SetParent(button.bg)

				nameFrame:SetTexture()
				nameFrame:Size(118, 39)

				border:SetAlpha(0)

				button.reskinned = true
			end
		end
	end

	-- LFR Queue/Browse Tabs
	for i = 1, 2 do
		local tab = _G["LFRParentFrameSideTab"..i];
		tab:GetRegions():Hide();
		tab:SetTemplate("Default");
		tab:StyleButton(nil, true);
		tab:GetNormalTexture():SetInside();
		tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
	end

	-- LFR Queue Frame
	LFRParentFrame:StripTextures();
	LFRQueueFrame:StripTextures();
	LFRQueueFrameListInset:StripTextures();
	LFRQueueFrameRoleInset:StripTextures();
	LFRQueueFrameCommentInset:StripTextures();

	LFRQueueFrameSpecificListScrollFrameScrollBackgroundTopLeft:Hide()
	LFRQueueFrameSpecificListScrollFrameScrollBackgroundBottomRight:Hide()

	LFRQueueFrameCommentScrollFrame:StripTextures()
	LFRQueueFrameCommentScrollFrame:CreateBackdrop()

	S:HandleCheckBox(LFRQueueFrameRoleButtonTank:GetChildren())
	LFRQueueFrameRoleButtonTank:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonTank:GetChildren():GetFrameLevel() + 2)

	S:HandleCheckBox(LFRQueueFrameRoleButtonHealer:GetChildren())
	LFRQueueFrameRoleButtonHealer:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonHealer:GetChildren():GetFrameLevel() + 2)

	S:HandleCheckBox(LFRQueueFrameRoleButtonDPS:GetChildren())
	LFRQueueFrameRoleButtonDPS:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonDPS:GetChildren():GetFrameLevel() + 2)

	LFRQueueFrameRoleButtonTank:StripTextures();
	LFRQueueFrameRoleButtonTank:CreateBackdrop();
	LFRQueueFrameRoleButtonTank.backdrop:Point("TOPLEFT", 3, -3);
	LFRQueueFrameRoleButtonTank.backdrop:Point("BOTTOMRIGHT", -3, 3);
	LFRQueueFrameRoleButtonTank.texture = LFRQueueFrameRoleButtonTank:CreateTexture(nil, "OVERLAY");
	LFRQueueFrameRoleButtonTank.texture:SetTexCoord(unpack(E.TexCoords));
	LFRQueueFrameRoleButtonTank.texture:SetTexture("Interface\\Icons\\Ability_Defend");
	LFRQueueFrameRoleButtonTank.texture:SetInside(LFRQueueFrameRoleButtonTank.backdrop);

	LFRQueueFrameRoleButtonHealer:StripTextures();
	LFRQueueFrameRoleButtonHealer:CreateBackdrop();
	LFRQueueFrameRoleButtonHealer.backdrop:Point("TOPLEFT", 3, -3);
	LFRQueueFrameRoleButtonHealer.backdrop:Point("BOTTOMRIGHT", -3, 3);
	LFRQueueFrameRoleButtonHealer.texture = LFRQueueFrameRoleButtonHealer:CreateTexture(nil, "OVERLAY");
	LFRQueueFrameRoleButtonHealer.texture:SetTexCoord(unpack(E.TexCoords));
	LFRQueueFrameRoleButtonHealer.texture:SetTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH");
	LFRQueueFrameRoleButtonHealer.texture:SetInside(LFRQueueFrameRoleButtonHealer.backdrop);

	LFRQueueFrameRoleButtonDPS:StripTextures();
	LFRQueueFrameRoleButtonDPS:CreateBackdrop();
	LFRQueueFrameRoleButtonDPS.backdrop:Point("TOPLEFT", 3, -3);
	LFRQueueFrameRoleButtonDPS.backdrop:Point("BOTTOMRIGHT", -3, 3);
	LFRQueueFrameRoleButtonDPS.texture = LFRQueueFrameRoleButtonDPS:CreateTexture(nil, "OVERLAY");
	LFRQueueFrameRoleButtonDPS.texture:SetTexCoord(unpack(E.TexCoords));
	LFRQueueFrameRoleButtonDPS.texture:SetTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01");
	LFRQueueFrameRoleButtonDPS.texture:SetInside(LFRQueueFrameRoleButtonDPS.backdrop);

	S:HandleButton(LFRQueueFrameFindGroupButton)
	S:HandleButton(LFRQueueFrameAcceptCommentButton)

	S:HandleScrollBar(LFRQueueFrameCommentScrollFrameScrollBar)
	S:HandleScrollBar(LFRQueueFrameSpecificListScrollFrameScrollBar)

	for i = 1, NUM_LFR_CHOICE_BUTTONS do
		local button = _G["LFRQueueFrameSpecificListButton" .. i];
		S:HandleCheckBox(button.enableButton);

		button.expandOrCollapseButton:SetNormalTexture("Interface\\Buttons\\UI-PlusMinus-Buttons");
		button.expandOrCollapseButton.SetNormalTexture = E.noop;
		button.expandOrCollapseButton:SetHighlightTexture(nil);
		button.expandOrCollapseButton:GetNormalTexture():Size(12);
		button.expandOrCollapseButton:GetNormalTexture():Point("CENTER", 4, 0);

		hooksecurefunc(button.expandOrCollapseButton, "SetNormalTexture", function(self, texture)
			if(find(texture, "MinusButton")) then
				self:GetNormalTexture():SetTexCoord(0.5625, 1, 0, 0.4375);
			else
				self:GetNormalTexture():SetTexCoord(0, 0.4375, 0, 0.4375);
			end
		end);
 	end

	-- LFR Browse Frame
	LFRBrowseFrame:StripTextures();
	LFRBrowseFrameListScrollFrame:StripTextures()
	LFRBrowseFrameRoleInsetBg:Hide()
	LFRBrowseFrameRoleInset:DisableDrawLayer("BORDER")

	RaidBrowserFrameBg:Hide()

	for i = 1, 14 do
		if(i ~= 6 and i ~= 8) then
			select(i, RaidBrowserFrame:GetRegions()):Hide()
		end
	end

	RaidBrowserFrame:CreateBackdrop("Transparent")

	for i = 1, 7 do
		local button = "LFRBrowseFrameColumnHeader"..i;
		_G[button.."Left"]:Kill();
		_G[button.."Middle"]:Kill();
		_G[button.."Right"]:Kill();
		_G[button]:StyleButton();
	end

	LFRBrowseFrameColumnHeader1:Width(88)

	S:HandleButton(LFRBrowseFrameSendMessageButton);
	S:HandleButton(LFRBrowseFrameInviteButton);
	S:HandleButton(LFRBrowseFrameRefreshButton);

	S:HandleDropDownBox(LFRBrowseFrameRaidDropDown);

	S:HandleCloseButton(RaidBrowserFrameCloseButton)

	LFRBrowseFrame:HookScript("OnShow", function()
		if(not LFRBrowseFrameListScrollFrameScrollBar.skinned) then
			S:HandleScrollBar(LFRBrowseFrameListScrollFrameScrollBar);
			LFRBrowseFrameListScrollFrameScrollBar.skinned = true;
		end
	end)

	--[[
	hooksecurefunc("LFRBrowseFrameListButton_SetData", function(button, index)
		local name, level, _, _, _, _, _, class = SearchLFGGetResults(index)

		local classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class];
		local levelTextColor = GetQuestDifficultyColor(level);

		if(index and class and name and level and (name ~= myName)) then
			button.name:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
			button.class:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
			button.level:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b);
		end
	end)
	]]

	--Flexible Raid
	FlexRaidFrameScrollFrame:StripTextures()
	FlexRaidFrameBottomInset:StripTextures()

	hooksecurefunc("FlexRaidFrame_Update", function()
		FlexRaidFrame.ScrollFrame.Background:SetTexture(nil)
	end)

	S:HandleDropDownBox(FlexRaidFrameSelectionDropDown)
	S:HandleButton(FlexRaidFrameStartRaidButton, true)

	-- LFG Ready Dialog
	LFGDungeonReadyDialog:StripTextures();
	LFGDungeonReadyDialog:SetTemplate("Transparent");
	LFGDungeonReadyDialog.SetBackdrop = E.noop;
	LFGDungeonReadyDialog.filigree:SetAlpha(0);
	LFGDungeonReadyDialog.bottomArt:SetAlpha(0);

	LFGDungeonReadyDialogBackground:Kill();

	S:HandleButton(LFGDungeonReadyDialogLeaveQueueButton);
	S:HandleButton(LFGDungeonReadyDialogEnterDungeonButton);

	S:HandleCloseButton(LFGDungeonReadyDialogCloseButton);
	LFGDungeonReadyDialogCloseButton.text:SetText("-");
	LFGDungeonReadyDialogCloseButton.text:FontTemplate(nil, 22);

	hooksecurefunc("LFGDungeonReadyDialog_UpdateRewards", function()
		for i = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local reward = _G["LFGDungeonReadyDialogRewardsFrameReward" .. i];
			local texture = _G["LFGDungeonReadyDialogRewardsFrameReward" .. i .. "Texture"];
			local border = _G["LFGDungeonReadyDialogRewardsFrameReward" .. i .. "Border"];

			if(reward and not reward.IsDone) then
				border:Kill()
				reward:CreateBackdrop();
				reward.backdrop:Point("TOPLEFT", 7, -7);
				reward.backdrop:Point("BOTTOMRIGHT", -7, 7);

				texture:SetTexCoord(unpack(E.TexCoords));
				texture:SetInside(reward.backdrop);

				reward.IsDone = true;
			end
		end
	end)

	LFGDungeonReadyDialogRoleIcon:StripTextures();
	LFGDungeonReadyDialogRoleIcon:CreateBackdrop();
	LFGDungeonReadyDialogRoleIcon.backdrop:Point("TOPLEFT", 7, -7);
	LFGDungeonReadyDialogRoleIcon.backdrop:Point("BOTTOMRIGHT", -7, 7);
	LFGDungeonReadyDialogRoleIcon.texture = LFGDungeonReadyDialogRoleIcon:CreateTexture(nil, "OVERLAY");

	hooksecurefunc("LFGDungeonReadyPopup_Update", function()
		local _, _, _, _, _, _, role = GetLFGProposal();

		if(role == "DAMAGER") then
			LFGDungeonReadyDialogRoleIcon.texture:SetTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01");
		elseif(role == "TANK") then
			LFGDungeonReadyDialogRoleIcon.texture:SetTexture("Interface\\Icons\\Ability_Defend");
		elseif(role == "HEALER") then
			LFGDungeonReadyDialogRoleIcon.texture:SetTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH");
		end

		LFGDungeonReadyDialogRoleIcon.texture:SetTexCoord(unpack(E.TexCoords));
		LFGDungeonReadyDialogRoleIcon.texture:SetInside(LFGDungeonReadyDialogRoleIcon.backdrop);
		LFGDungeonReadyDialogRoleIcon.texture:SetParent(LFGDungeonReadyDialogRoleIcon.backdrop);
	end)

	-- LFG Ready Status
	LFGDungeonReadyStatus:StripTextures();
	LFGDungeonReadyStatus:SetTemplate("Transparent");

	S:HandleCloseButton(LFGDungeonReadyStatusCloseButton);

	do
		local roleButtons = {LFGDungeonReadyStatusGroupedTank, LFGDungeonReadyStatusGroupedHealer, LFGDungeonReadyStatusGroupedDamager};
		for i = 1, 5 do
			tinsert(roleButtons, _G["LFGDungeonReadyStatusIndividualPlayer"..i]);
		end
		for _, roleButton in pairs (roleButtons) do
			roleButton:CreateBackdrop("Default", true);
			roleButton.texture:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\lfgRoleIcons");
			roleButton.statusIcon:SetDrawLayer("OVERLAY", 2);
		end
	end

	-- LFD Role Check PopUp
	LFDRoleCheckPopup:SetTemplate("Transparent")
	LFDRoleCheckPopup:SetFrameStrata("HIGH")

	S:HandleButton(LFDRoleCheckPopupAcceptButton)
	S:HandleButton(LFDRoleCheckPopupDeclineButton)

	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonTank:GetChildren())
	LFDRoleCheckPopupRoleButtonTank:GetChildren():SetFrameLevel(LFDRoleCheckPopupRoleButtonTank:GetChildren():GetFrameLevel() + 2)

	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonHealer:GetChildren())
	LFDRoleCheckPopupRoleButtonHealer:GetChildren():SetFrameLevel(LFDRoleCheckPopupRoleButtonHealer:GetChildren():GetFrameLevel() + 2)

	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonDPS:GetChildren())
	LFDRoleCheckPopupRoleButtonDPS:GetChildren():SetFrameLevel(LFDRoleCheckPopupRoleButtonDPS:GetChildren():GetFrameLevel() + 2)

	LFDRoleCheckPopupRoleButtonTank:StripTextures();
	LFDRoleCheckPopupRoleButtonTank:CreateBackdrop();
	LFDRoleCheckPopupRoleButtonTank.backdrop:Point("TOPLEFT", 3, -3);
	LFDRoleCheckPopupRoleButtonTank.backdrop:Point("BOTTOMRIGHT", -3, 3);
	LFDRoleCheckPopupRoleButtonTank.texture = LFDRoleCheckPopupRoleButtonTank:CreateTexture(nil, "OVERLAY");
	LFDRoleCheckPopupRoleButtonTank.texture:SetTexCoord(unpack(E.TexCoords));
	LFDRoleCheckPopupRoleButtonTank.texture:SetTexture("Interface\\Icons\\Ability_Defend");
	LFDRoleCheckPopupRoleButtonTank.texture:SetInside(LFDRoleCheckPopupRoleButtonTank.backdrop);

	LFDRoleCheckPopupRoleButtonHealer:StripTextures();
	LFDRoleCheckPopupRoleButtonHealer:CreateBackdrop();
	LFDRoleCheckPopupRoleButtonHealer.backdrop:Point("TOPLEFT", 3, -3);
	LFDRoleCheckPopupRoleButtonHealer.backdrop:Point("BOTTOMRIGHT", -3, 3);
	LFDRoleCheckPopupRoleButtonHealer.texture = LFDRoleCheckPopupRoleButtonHealer:CreateTexture(nil, "OVERLAY");
	LFDRoleCheckPopupRoleButtonHealer.texture:SetTexCoord(unpack(E.TexCoords));
	LFDRoleCheckPopupRoleButtonHealer.texture:SetTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH");
	LFDRoleCheckPopupRoleButtonHealer.texture:SetInside(LFDRoleCheckPopupRoleButtonHealer.backdrop);

	LFDRoleCheckPopupRoleButtonDPS:StripTextures();
	LFDRoleCheckPopupRoleButtonDPS:CreateBackdrop();
	LFDRoleCheckPopupRoleButtonDPS.backdrop:Point("TOPLEFT", 3, -3);
	LFDRoleCheckPopupRoleButtonDPS.backdrop:Point("BOTTOMRIGHT", -3, 3);
	LFDRoleCheckPopupRoleButtonDPS.texture = LFDRoleCheckPopupRoleButtonDPS:CreateTexture(nil, "OVERLAY");
	LFDRoleCheckPopupRoleButtonDPS.texture:SetTexCoord(unpack(E.TexCoords));
	LFDRoleCheckPopupRoleButtonDPS.texture:SetTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01");
	LFDRoleCheckPopupRoleButtonDPS.texture:SetInside(LFDRoleCheckPopupRoleButtonDPS.backdrop);

	-- LFG Invite PopUp
	LFGInvitePopup:StripTextures()
	LFGInvitePopup:SetTemplate("Transparent")

	S:HandleButton(LFGInvitePopupAcceptButton)
	S:HandleButton(LFGInvitePopupDeclineButton)

	S:HandleCheckBox(LFGInvitePopupRoleButtonTank:GetChildren())
	LFGInvitePopupRoleButtonTank:GetChildren():SetFrameLevel(LFGInvitePopupRoleButtonTank:GetChildren():GetFrameLevel() + 2)

	S:HandleCheckBox(LFGInvitePopupRoleButtonHealer:GetChildren())
	LFGInvitePopupRoleButtonHealer:GetChildren():SetFrameLevel(LFGInvitePopupRoleButtonHealer:GetChildren():GetFrameLevel() + 2)

	S:HandleCheckBox(LFGInvitePopupRoleButtonDPS:GetChildren())
	LFGInvitePopupRoleButtonDPS:GetChildren():SetFrameLevel(LFGInvitePopupRoleButtonDPS:GetChildren():GetFrameLevel() + 2)

	LFGInvitePopupRoleButtonTank:StripTextures();
	LFGInvitePopupRoleButtonTank:CreateBackdrop();
	LFGInvitePopupRoleButtonTank.backdrop:Point("TOPLEFT", 3, -3);
	LFGInvitePopupRoleButtonTank.backdrop:Point("BOTTOMRIGHT", -3, 3);
	LFGInvitePopupRoleButtonTank.texture = LFGInvitePopupRoleButtonTank:CreateTexture(nil, "OVERLAY");
	LFGInvitePopupRoleButtonTank.texture:SetTexCoord(unpack(E.TexCoords));
	LFGInvitePopupRoleButtonTank.texture:SetTexture("Interface\\Icons\\Ability_Defend");
	LFGInvitePopupRoleButtonTank.texture:SetInside(LFGInvitePopupRoleButtonTank.backdrop);

	LFGInvitePopupRoleButtonHealer:StripTextures();
	LFGInvitePopupRoleButtonHealer:CreateBackdrop();
	LFGInvitePopupRoleButtonHealer.backdrop:Point("TOPLEFT", 3, -3);
	LFGInvitePopupRoleButtonHealer.backdrop:Point("BOTTOMRIGHT", -3, 3);
	LFGInvitePopupRoleButtonHealer.texture = LFGInvitePopupRoleButtonHealer:CreateTexture(nil, "OVERLAY");
	LFGInvitePopupRoleButtonHealer.texture:SetTexCoord(unpack(E.TexCoords));
	LFGInvitePopupRoleButtonHealer.texture:SetTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH");
	LFGInvitePopupRoleButtonHealer.texture:SetInside(LFGInvitePopupRoleButtonHealer.backdrop);

	LFGInvitePopupRoleButtonDPS:StripTextures();
	LFGInvitePopupRoleButtonDPS:CreateBackdrop();
	LFGInvitePopupRoleButtonDPS.backdrop:Point("TOPLEFT", 3, -3);
	LFGInvitePopupRoleButtonDPS.backdrop:Point("BOTTOMRIGHT", -3, 3);
	LFGInvitePopupRoleButtonDPS.texture = LFGInvitePopupRoleButtonDPS:CreateTexture(nil, "OVERLAY");
	LFGInvitePopupRoleButtonDPS.texture:SetTexCoord(unpack(E.TexCoords));
	LFGInvitePopupRoleButtonDPS.texture:SetTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01");
	LFGInvitePopupRoleButtonDPS.texture:SetInside(LFGInvitePopupRoleButtonDPS.backdrop);

	-- Queue Search Status
	QueueStatusFrame:StripTextures()
	QueueStatusFrame:SetTemplate("Transparent");

	hooksecurefunc("QueueStatusEntry_SetFullDisplay", function(entry, _, _, _, isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds)
		local nextRoleIcon = 1;

		if(isDPS) then
			local icon = entry["RoleIcon"..nextRoleIcon];
			icon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\dps.tga")
			icon:SetTexCoord(unpack(E.TexCoords));
			icon:Size(17)
			nextRoleIcon = nextRoleIcon + 1;
		end

		if(isHealer) then
			local icon = entry["RoleIcon"..nextRoleIcon];
			icon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\healer.tga")
			icon:SetTexCoord(unpack(E.TexCoords));
			icon:Size(20)
			nextRoleIcon = nextRoleIcon + 1;
		end

		if(isTank) then
			local icon = entry["RoleIcon"..nextRoleIcon];
			icon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\tank.tga")
			icon:SetTexCoord(unpack(E.TexCoords));
			icon:Size(22)
			nextRoleIcon = nextRoleIcon + 1;
		end

		if(totalTanks and totalHealers and totalDPS) then
			entry.TanksFound.Texture:SetTexture("Interface\\Icons\\Ability_Defend");
			entry.TanksFound.Texture:SetTexCoord(unpack(E.TexCoords));
			entry.TanksFound.Texture:SetDesaturated(tankNeeds ~= 0);

			entry.HealersFound.Texture:SetTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH");
			entry.HealersFound.Texture:SetTexCoord(unpack(E.TexCoords));
			entry.HealersFound.Texture:SetDesaturated(healerNeeds ~= 0);

			entry.DamagersFound.Texture:SetTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01");
			entry.DamagersFound.Texture:SetTexCoord(unpack(E.TexCoords));
			entry.DamagersFound.Texture:SetDesaturated(dpsNeeds ~= 0);
		end
	end)

	-- Desaturate/Incentive Scripts (Role Icons)
	hooksecurefunc("LFG_SetRoleIconIncentive", function(roleButton, incentiveIndex)
		if(incentiveIndex) then
			roleButton.backdrop:SetBackdropBorderColor(1, 0.80, 0.10);
		else
			roleButton.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor));
		end
	end)

	hooksecurefunc("LFG_PermanentlyDisableRoleButton", function(button)
		if(button.texture) then
			button.texture:SetDesaturated(true);
		end
	end)

	hooksecurefunc("LFG_DisableRoleButton", function(button)
		if(button.texture) then
			button.texture:SetDesaturated(true);
		end

		if(button.checkButton:GetChecked()) then
			button.checkButton:SetAlpha(1)
		else
			button.checkButton:SetAlpha(0)
		end
	end)

	hooksecurefunc("LFG_EnableRoleButton", function(button)
		if(button.texture) then
			button.texture:SetDesaturated(false);
			button.checkButton:SetAlpha(1)
		end
	end)
end

S:AddCallback("LFG", LoadSkin);

local function LoadSecondarySkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfg ~= true) then return end

	ChallengesFrameInset:StripTextures()
	ChallengesFrameInsetBg:Hide()
	ChallengesFrameDetails.bg:Hide()

	select(2, ChallengesFrameDetails:GetRegions()):Hide()
	select(9, ChallengesFrameDetails:GetRegions()):Hide()
	select(10, ChallengesFrameDetails:GetRegions()):Hide()
	select(11, ChallengesFrameDetails:GetRegions()):Hide()

	ChallengesFrameDungeonButton1:Point("TOPLEFT", ChallengesFrame, 8, -83)

	S:HandleButton(ChallengesFrameLeaderboard, true)

	for i = 1, 9 do
		local button = ChallengesFrame["button"..i]

		S:HandleButton(button)
		button:StyleButton(nil, true)
		button:SetHighlightTexture("")

		button.selectedTex:SetAlpha(0.20);
		button.selectedTex:Point("TOPLEFT", 1, -1)
		button.selectedTex:Point("BOTTOMRIGHT", -1, 1)

		button.NoMedal:Kill()
	end

	for i = 10, 16 do
		local button = ChallengesFrame["button"..i]
		if(button) then
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

S:AddCallbackForAddon("Blizzard_ChallengesUI", "ChallengesUI", LoadSecondarySkin);