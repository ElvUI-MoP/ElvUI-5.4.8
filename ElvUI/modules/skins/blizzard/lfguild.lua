local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local _G = _G;
local pairs, unpack = pairs, unpack, select;

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfguild ~= true then return end

	local checkbox = {
		"LookingForGuildPvPButton",
		"LookingForGuildWeekendsButton",
		"LookingForGuildWeekdaysButton",
		"LookingForGuildRPButton",
		"LookingForGuildRaidButton",
		"LookingForGuildQuestButton",
		"LookingForGuildDungeonButton"
	}

	for _, v in pairs(checkbox) do
		S:HandleCheckBox(_G[v])
	end

	LookingForGuildFrameInset:StripTextures(false)
	LookingForGuildFrame:StripTextures()
	LookingForGuildFrame:SetTemplate("Transparent")

	LookingForGuildBrowseButton_LeftSeparator:Kill()
	LookingForGuildRequestButton_RightSeparator:Kill()

	S:HandleScrollBar(LookingForGuildBrowseFrameContainerScrollBar)

	S:HandleButton(LookingForGuildBrowseButton)
	S:HandleButton(LookingForGuildRequestButton)

	S:HandleCloseButton(LookingForGuildFrameCloseButton)

	LookingForGuildCommentInputFrame:CreateBackdrop("Transparent")
	LookingForGuildCommentInputFrame:StripTextures(false)

	for i = 1, 5 do
		local button = _G["LookingForGuildBrowseFrameContainerButton"..i]

		button:SetBackdrop(nil)
		button:SetTemplate("Transparent")
		button:StyleButton()

		button.selectedTex:SetTexture(1, 1, 1, 0.3);
		button.selectedTex:SetInside();

		button.name:Point("TOPLEFT", 75, -10);
		button.level:Point("TOPLEFT", 58, -10);

		_G["LookingForGuildBrowseFrameContainerButton"..i.."Ring"]:SetAlpha(0)
		_G["LookingForGuildBrowseFrameContainerButton"..i.."LevelRing"]:SetAlpha(0)
		_G["LookingForGuildBrowseFrameContainerButton"..i.."TabardBorder"]:SetAlpha(0)
	end

	for i = 1, 10 do
		local button = _G["LookingForGuildAppsFrameContainerButton"..i]

		button:SetBackdrop(nil)
		button:SetTemplate("Transparent")
		button:StyleButton()
	end

	for i = 1, 3 do
		local headerTab = _G["LookingForGuildFrameTab"..i]
		headerTab:StripTextures()
		headerTab.backdrop = CreateFrame("Frame", nil, headerTab)
		headerTab.backdrop:SetTemplate("Default", true)
		headerTab.backdrop:SetFrameLevel(headerTab:GetFrameLevel() - 1)
		headerTab.backdrop:Point("TOPLEFT", 3, -7)
		headerTab.backdrop:Point("BOTTOMRIGHT", -2, -1)

		headerTab:HookScript("OnEnter", S.SetModifiedBackdrop);
		headerTab:HookScript("OnLeave", S.SetOriginalBackdrop);
	end

	GuildFinderRequestMembershipFrame:StripTextures(true)
	GuildFinderRequestMembershipFrame:SetTemplate("Transparent")

	S:HandleButton(GuildFinderRequestMembershipFrameAcceptButton)
	S:HandleButton(GuildFinderRequestMembershipFrameCancelButton)

	GuildFinderRequestMembershipFrameInputFrame:StripTextures()
	GuildFinderRequestMembershipFrameInputFrame:SetTemplate()

	-- Role Icons
	S:HandleCheckBox(LookingForGuildTankButton.checkButton)
	LookingForGuildTankButton:GetChildren():SetFrameLevel(LookingForGuildTankButton:GetChildren():GetFrameLevel() + 2);

	S:HandleCheckBox(LookingForGuildHealerButton.checkButton)
	LookingForGuildHealerButton:GetChildren():SetFrameLevel(LookingForGuildHealerButton:GetChildren():GetFrameLevel() + 2);

	S:HandleCheckBox(LookingForGuildDamagerButton.checkButton)
	LookingForGuildDamagerButton:GetChildren():SetFrameLevel(LookingForGuildDamagerButton:GetChildren():GetFrameLevel() + 2);

	LookingForGuildTankButton:StripTextures()
	LookingForGuildTankButton:CreateBackdrop();
	LookingForGuildTankButton.backdrop:Point("TOPLEFT", 3, -3)
	LookingForGuildTankButton.backdrop:Point("BOTTOMRIGHT", -3, 3)
	LookingForGuildTankButton.icon = LookingForGuildTankButton:CreateTexture(nil, "OVERLAY");
	LookingForGuildTankButton.icon:SetTexCoord(unpack(E.TexCoords))
	LookingForGuildTankButton.icon:SetTexture("Interface\\Icons\\Ability_Defend");
	LookingForGuildTankButton.icon:SetInside(LookingForGuildTankButton.backdrop)

	LookingForGuildHealerButton:StripTextures()
	LookingForGuildHealerButton:CreateBackdrop();
	LookingForGuildHealerButton.backdrop:Point("TOPLEFT", 3, -3)
	LookingForGuildHealerButton.backdrop:Point("BOTTOMRIGHT", -3, 3)
	LookingForGuildHealerButton.icon = LookingForGuildHealerButton:CreateTexture(nil, "OVERLAY");
	LookingForGuildHealerButton.icon:SetTexCoord(unpack(E.TexCoords))
	LookingForGuildHealerButton.icon:SetTexture("Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH");
	LookingForGuildHealerButton.icon:SetInside(LookingForGuildHealerButton.backdrop)

	LookingForGuildDamagerButton:StripTextures()
	LookingForGuildDamagerButton:CreateBackdrop();
	LookingForGuildDamagerButton.backdrop:Point("TOPLEFT", 3, -3)
	LookingForGuildDamagerButton.backdrop:Point("BOTTOMRIGHT", -3, 3)
	LookingForGuildDamagerButton.icon = LookingForGuildDamagerButton:CreateTexture(nil, "OVERLAY");
	LookingForGuildDamagerButton.icon:SetTexCoord(unpack(E.TexCoords))
	LookingForGuildDamagerButton.icon:SetTexture("Interface\\Icons\\INV_Knife_1H_Common_B_01");
	LookingForGuildDamagerButton.icon:SetInside(LookingForGuildDamagerButton.backdrop)
end

S:AddCallbackForAddon("Blizzard_LookingForGuildUI", "LookingForGuild", LoadSkin);