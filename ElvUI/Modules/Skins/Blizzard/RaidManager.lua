local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.RaidManager then return end
	if (E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.raid and E.private.unitframe.disabledBlizzardFrames.party) then return end

	CompactRaidFrameManager:StripTextures()
	CompactRaidFrameManager:SetTemplate("Transparent")

	CompactRaidFrameManagerDisplayFrame:StripTextures()
	CompactRaidFrameManagerDisplayFrameFilterOptions:StripTextures()

	CompactRaidFrameManagerDisplayFrameRaidMembersLabel:FontTemplate()
	CompactRaidFrameManagerDisplayFrameRaidMemberCountLabel:FontTemplate()

	S:HandleButton(CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll)
	S:HandleButton(CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck)
	S:HandleButton(CompactRaidFrameManagerDisplayFrameConvertToRaid)
	S:HandleButton(CompactRaidFrameManagerDisplayFrameLockedModeToggle)

	CompactRaidFrameManagerDisplayFrameHiddenModeToggle:StripTextures(true)
	CompactRaidFrameManagerDisplayFrameHiddenModeToggle:CreateBackdrop("Default", true)
	CompactRaidFrameManagerDisplayFrameHiddenModeToggle.backdrop:Point("TOPLEFT", 1, 0)
	CompactRaidFrameManagerDisplayFrameHiddenModeToggle.backdrop:Point("BOTTOMRIGHT", 0, 0)
	CompactRaidFrameManagerDisplayFrameHiddenModeToggle:HookScript("OnEnter", S.SetModifiedBackdrop)
	CompactRaidFrameManagerDisplayFrameHiddenModeToggle:HookScript("OnLeave", S.SetOriginalBackdrop)

	S:HandleButton(CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleDamager)
	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleDamager:Width(55)
	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleDamager:Point("LEFT", CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleHealer, "RIGHT", 2, 0)

	S:HandleButton(CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleHealer)
	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleHealer:Width(56)
	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleHealer:Point("LEFT", CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleTank, "RIGHT", 2, 0)

	S:HandleButton(CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleTank)
	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleTank:Width(55)
	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleTank:Point("TOPLEFT", CompactRaidFrameManagerDisplayFrameFilterOptions, "TOPLEFT", 22, 4)

	S:HandleCheckBox(CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton)

	S:HandleDropDownBox(CompactRaidFrameManagerDisplayFrameProfileSelector)

	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleTankSelectedHighlight:SetTexture(1, 1, 1, 0.2)
	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleTankSelectedHighlight:SetInside()

	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleHealerSelectedHighlight:SetTexture(1, 1, 1, 0.2)
	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleHealerSelectedHighlight:SetInside()

	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleDamagerSelectedHighlight:SetTexture(1, 1, 1, 0.2)
	CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleDamagerSelectedHighlight:SetInside()

	if not E.private.general.raidUtility then
		S:HandleButton(CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton)

		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:Point("TOPLEFT", CompactRaidFrameManagerDisplayFrameLeaderOptions, "TOPLEFT", 20, -3)
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:Width(170)

		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:Point("TOPLEFT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll, "BOTTOMLEFT", 0, -1)

		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:Point("TOPLEFT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck, "TOPRIGHT", 1, 0)

		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton.icon = CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:CreateTexture(nil, "ARTWORK")
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton.icon:Size(14)
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton.icon:Point("CENTER")
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton.icon:SetTexture([[Interface\RaidFrame\Raid-WorldPing]])
	end

	for i = 1, 8 do
		local button = _G["CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup"..i]
		local highlight = _G["CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup"..i.."SelectedHighlight"]

		S:HandleButton(button)

		highlight:SetTexture(1, 1, 1, 0.2)
		highlight:SetInside(button)

		if i == 1 then
			button:Point("TOPLEFT", CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleTank, "BOTTOMLEFT", 0, -4)
		elseif i == 5 then
			button:Point("TOPLEFT", CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup1, "BOTTOMLEFT", 0, -2)
		end
	end

	S:HandleButton(CompactRaidFrameManagerToggleButton)
	CompactRaidFrameManagerToggleButton:Size(15, 40)
	CompactRaidFrameManagerToggleButton:Point("RIGHT", -3, -15)

	CompactRaidFrameManagerToggleButton.icon = CompactRaidFrameManagerToggleButton:CreateTexture(nil, "ARTWORK")
	CompactRaidFrameManagerToggleButton.icon:Size(14)
	CompactRaidFrameManagerToggleButton.icon:Point("CENTER")
	CompactRaidFrameManagerToggleButton.icon:SetTexture(E.Media.Textures.ArrowUp)
	CompactRaidFrameManagerToggleButton.icon:SetRotation(-1.57)

	hooksecurefunc("CompactRaidFrameManager_Expand", function()
		CompactRaidFrameManagerToggleButton.icon:SetRotation(1.57)
	end)

	hooksecurefunc("CompactRaidFrameManager_Collapse", function()
		CompactRaidFrameManagerToggleButton.icon:SetRotation(-1.57)
	end)
end

S:AddCallback("RaidManager", LoadSkin)