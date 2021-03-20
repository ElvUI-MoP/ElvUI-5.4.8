local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs = pairs

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lfguild then return end

	LookingForGuildFrame:StripTextures()
	LookingForGuildFrame:SetTemplate("Transparent")

	LookingForGuildFrameInset:StripTextures()

	S:HandleCloseButton(LookingForGuildFrameCloseButton)

	-- Settings Tab
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

	S:HandleRoleButton(LookingForGuildTankButton, 36)
	LookingForGuildTankButton:Point("TOPLEFT", 30, -37)

	S:HandleRoleButton(LookingForGuildHealerButton, 36)
	LookingForGuildHealerButton:Point("TOP", 1, -37)

	S:HandleRoleButton(LookingForGuildDamagerButton, 36)
	LookingForGuildDamagerButton:Point("TOPRIGHT", -30, -37)

	LookingForGuildCommentInputFrame:StripTextures()
	LookingForGuildCommentInputFrame:CreateBackdrop("Transparent")

	S:HandleButton(LookingForGuildBrowseButton)

	-- Browse Tab
	LookingForGuildBrowseFrameContainer:CreateBackdrop("Transparent")
	LookingForGuildBrowseFrameContainer.backdrop:Point("BOTTOMRIGHT", 0, -2)

	S:HandleScrollBar(LookingForGuildBrowseFrameContainerScrollBar)
	LookingForGuildBrowseFrameContainerScrollBar:ClearAllPoints()
	LookingForGuildBrowseFrameContainerScrollBar:Point("TOPRIGHT", LookingForGuildBrowseFrameContainer, 22, -15)
	LookingForGuildBrowseFrameContainerScrollBar:Point("BOTTOMRIGHT", LookingForGuildBrowseFrameContainer, 0, 14)

	S:HandleButton(LookingForGuildRequestButton)
	LookingForGuildRequestButton:Point("BOTTOMLEFT", LookingForGuildFrame, 7, 3)

	for i = 1, 5 do
		local button = _G["LookingForGuildBrowseFrameContainerButton"..i]

		button:SetBackdrop(nil)

		local highlight = button:GetHighlightTexture()
		highlight:SetTexture(E.Media.Textures.Highlight)
		highlight:SetAlpha(0.35)
		highlight:SetTexCoord(0, 1, 0, 1)
		highlight:SetInside()

		button.selectedTex:SetTexture(E.Media.Textures.Highlight)
		button.selectedTex:SetAlpha(0.35)
		button.selectedTex:SetTexCoord(0, 1, 0, 1)
		button.selectedTex:SetInside()

		button.name:Point("TOPLEFT", 64, -10)
		button.level:Point("TOPLEFT", 52, -10)

		button.PointsSpentBgGold:SetAlpha(0)
		button.border:SetAlpha(0)
		_G["LookingForGuildBrowseFrameContainerButton"..i.."Ring"]:SetAlpha(0)
	end

	-- Requests Tab
	LookingForGuildAppsFrameContainer:SetTemplate("Transparent")

	for i = 1, 10 do
		local button = _G["LookingForGuildAppsFrameContainerButton"..i]
		local highlight = _G["LookingForGuildAppsFrameContainerButton"..i.."Highlight"]

		button:StripTextures()

		highlight:SetTexture(E.Media.Textures.Highlight)
		highlight:SetAlpha(0.35)
		highlight:SetTexCoord(0, 1, 0, 1)
		highlight:SetInside()

		S:HandleCloseButton(button.removeButton)
		button.removeButton:Size(26)
		button.removeButton.Texture:SetVertexColor(1, 0, 0)
		button.removeButton:HookScript("OnEnter", function(btn) btn.Texture:SetVertexColor(1, 1, 1) end)
		button.removeButton:HookScript("OnLeave", function(btn) btn.Texture:SetVertexColor(1, 0, 0) end)
	end

	for i = 1, 3 do
		local headerTab = _G["LookingForGuildFrameTab"..i]

		headerTab:StripTextures()
		headerTab.backdrop = CreateFrame("Frame", nil, headerTab)
		headerTab.backdrop:SetTemplate("Default", true)
		headerTab.backdrop:SetFrameLevel(headerTab:GetFrameLevel() - 1)
		headerTab.backdrop:Point("TOPLEFT", 3, -7)
		headerTab.backdrop:Point("BOTTOMRIGHT", -2, -1)

		headerTab:HookScript("OnEnter", S.SetModifiedBackdrop)
		headerTab:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	-- Request Frame
	GuildFinderRequestMembershipFrame:StripTextures(true)
	GuildFinderRequestMembershipFrame:SetTemplate("Transparent")

	S:HandleScrollBar(GuildFinderRequestMembershipFrameInputFrameScrollFrameScrollBar)

	S:HandleButton(GuildFinderRequestMembershipFrameAcceptButton)
	S:HandleButton(GuildFinderRequestMembershipFrameCancelButton)

	GuildFinderRequestMembershipFrameInputFrame:StripTextures()
	GuildFinderRequestMembershipFrameInputFrame:SetTemplate()
end

S:AddCallbackForAddon("Blizzard_LookingForGuildUI", "LookingForGuild", LoadSkin)