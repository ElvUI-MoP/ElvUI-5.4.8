local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.worldmap then return end

	WorldMapFrame:CreateBackdrop("Transparent")

	WorldMapDetailFrame:CreateBackdrop()
	WorldMapDetailFrame.backdrop:Point("TOPLEFT", -2, 2)
	WorldMapDetailFrame.backdrop:Point("BOTTOMRIGHT", 2, -1)
	WorldMapDetailFrame.backdrop:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() - 2)

	WorldMapQuestDetailScrollFrame:Width(348)
	WorldMapQuestDetailScrollFrame:Point("BOTTOMLEFT", WorldMapDetailFrame, "BOTTOMLEFT", -25, -207)
	WorldMapQuestDetailScrollFrame:CreateBackdrop("Transparent")
	WorldMapQuestDetailScrollFrame.backdrop:Point("TOPLEFT", 24, 2)
	WorldMapQuestDetailScrollFrame.backdrop:Point("BOTTOMRIGHT", 23, -4)
	WorldMapQuestDetailScrollFrame:SetHitRectInsets(24, -23, 0, -2)
	WorldMapQuestDetailScrollFrame.backdrop:SetFrameLevel(WorldMapQuestDetailScrollFrame:GetFrameLevel())

	WorldMapQuestDetailScrollChildFrame:SetScale(1)
	S:HandleScrollBar(WorldMapQuestDetailScrollFrameScrollBar, 4)
	WorldMapQuestDetailScrollFrameScrollBar:ClearAllPoints()
	WorldMapQuestDetailScrollFrameScrollBar:Point("TOPRIGHT", WorldMapQuestDetailScrollFrame, "TOPRIGHT", 22, -16)
	WorldMapQuestDetailScrollFrameScrollBar:Point("BOTTOMRIGHT", WorldMapQuestDetailScrollFrame, "BOTTOMRIGHT", 0, 14)

	WorldMapQuestRewardScrollFrame:Width(340)
	WorldMapQuestRewardScrollFrame:Point("LEFT", WorldMapQuestDetailScrollFrame, "RIGHT", 8, 0)
	WorldMapQuestRewardScrollFrame:CreateBackdrop("Transparent")
	WorldMapQuestRewardScrollFrame.backdrop:Point("TOPLEFT", 20, 2)
	WorldMapQuestRewardScrollFrame.backdrop:Point("BOTTOMRIGHT", 22, -4)
	WorldMapQuestRewardScrollFrame:SetHitRectInsets(20, -22, 0, -2)
	WorldMapQuestRewardScrollFrame.backdrop:SetFrameLevel(WorldMapQuestRewardScrollFrame:GetFrameLevel())

	WorldMapQuestRewardScrollChildFrame:SetScale(1)
	S:HandleScrollBar(WorldMapQuestRewardScrollFrameScrollBar, 4)
	WorldMapQuestRewardScrollFrameScrollBar:ClearAllPoints()
	WorldMapQuestRewardScrollFrameScrollBar:Point("TOPRIGHT", WorldMapQuestRewardScrollFrame, "TOPRIGHT", 21, -16)
	WorldMapQuestRewardScrollFrameScrollBar:Point("BOTTOMRIGHT", WorldMapQuestRewardScrollFrame, "BOTTOMRIGHT", 0, 14)

	WorldMapQuestScrollFrame:CreateBackdrop("Transparent")
	WorldMapQuestScrollFrame.backdrop:Point("TOPLEFT", -1, 1)
	WorldMapQuestScrollFrame.backdrop:Point("BOTTOMRIGHT", 25, -3)
	WorldMapQuestScrollFrame.backdrop:SetFrameLevel(WorldMapQuestScrollFrame:GetFrameLevel())

	S:HandleScrollBar(WorldMapQuestScrollFrameScrollBar)
	WorldMapQuestScrollFrameScrollBar:ClearAllPoints()
	WorldMapQuestScrollFrameScrollBar:Point("TOPRIGHT", WorldMapQuestScrollFrame, "TOPRIGHT", 21, -20)
	WorldMapQuestScrollFrameScrollBar:Point("BOTTOMRIGHT", WorldMapQuestScrollFrame, "BOTTOMRIGHT", 0, 18)

	WorldMapQuestHighlightBar:SetTexture(E.Media.Textures.Highlight)
	WorldMapQuestHighlightBar:SetAlpha(0.35)

	WorldMapQuestSelectBar:SetTexture(E.Media.Textures.Highlight)
	WorldMapQuestSelectBar:SetAlpha(0.35)

	S:HandleCloseButton(WorldMapFrameCloseButton)

	S:HandleArrowButton(WorldMapFrameSizeUpButton)
	S:HandleArrowButton(WorldMapFrameSizeDownButton, true)

	S:HandleDropDownBox(WorldMapLevelDropDown)
	S:HandleDropDownBox(WorldMapZoneMinimapDropDown)
	S:HandleDropDownBox(WorldMapContinentDropDown)
	S:HandleDropDownBox(WorldMapZoneDropDown)
	S:HandleDropDownBox(WorldMapShowDropDown)

	S:HandleButton(WorldMapZoomOutButton)
	WorldMapZoomOutButton:Point("LEFT", WorldMapZoneDropDown, "RIGHT", 0, 0)

	S:HandleNextPrevButton(WorldMapLevelUpButton)
	WorldMapLevelUpButton:Point("TOPLEFT", WorldMapLevelDropDown, "TOPRIGHT", -2, 6)
	WorldMapLevelUpButton:Size(16)

	S:HandleNextPrevButton(WorldMapLevelDownButton)
	WorldMapLevelDownButton:Point("BOTTOMLEFT", WorldMapLevelDropDown, "BOTTOMRIGHT", -2, 3)
	WorldMapLevelDownButton:Size(16)

	S:HandleCheckBox(WorldMapTrackQuest)

	local function SmallSkin()
		WorldMapFrame.backdrop:ClearAllPoints()
		WorldMapFrame.backdrop:Point("TOPLEFT", 5, 0)
		WorldMapFrame.backdrop:Point("BOTTOMRIGHT", -2, 4)

		WorldMapDetailFrame.backdrop:ClearAllPoints()
		WorldMapDetailFrame.backdrop:Point("TOPLEFT", -3, 3)
		WorldMapDetailFrame.backdrop:Point("BOTTOMRIGHT", 3, -2)

		WorldMapLevelDropDown:ClearAllPoints()
		WorldMapLevelDropDown:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -10, -4)

		WorldMapShowDropDown:ClearAllPoints()
		WorldMapShowDropDown:Point("BOTTOMRIGHT", 2, -2)
	end

	local function LargeSkin()
		WorldMapFrame.backdrop:ClearAllPoints()
		WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -10, 70)
		WorldMapFrame.backdrop:Point("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", 12, -30)

		WorldMapDetailFrame.backdrop:ClearAllPoints()
		WorldMapDetailFrame.backdrop:Point("TOPLEFT", -2, 2)
		WorldMapDetailFrame.backdrop:Point("BOTTOMRIGHT", 2, -1)

		WorldMapShowDropDown:ClearAllPoints()
		WorldMapShowDropDown:Point("BOTTOMRIGHT", 9, -53)
	end

	local function QuestSkin()
		WorldMapFrame.backdrop:ClearAllPoints()
		WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -(E.PixelMode and 10 or 11), 69)
		WorldMapFrame.backdrop:Point("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", E.PixelMode and 321 or 322, -237)

		WorldMapDetailFrame.backdrop:ClearAllPoints()
		WorldMapDetailFrame.backdrop:Point("TOPLEFT", -2, 2)
		WorldMapDetailFrame.backdrop:Point("BOTTOMRIGHT", 2, -1)

		WorldMapShowDropDown:ClearAllPoints()
		WorldMapShowDropDown:Point("BOTTOMRIGHT", 9, -53)
	end

	local function FixSkin()
		WorldMapFrame:StripTextures()

		if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
			LargeSkin()
		elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
			SmallSkin()
		elseif WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE then
			QuestSkin()
		end

		WorldMapFrameAreaLabel:FontTemplate(nil, 50, "OUTLINE")
		WorldMapFrameAreaLabel:SetShadowOffset(2, -2)
		WorldMapFrameAreaLabel:SetTextColor(0.9, 0.8, 0.6)

		WorldMapFrameAreaDescription:FontTemplate(nil, 40, "OUTLINE")
		WorldMapFrameAreaDescription:SetShadowOffset(2, -2)

		WorldMapZoneInfo:FontTemplate(nil, 25, "OUTLINE")
		WorldMapZoneInfo:SetShadowOffset(2, -2)

		if InCombatLockdown() then return end

		WorldMapFrame:SetFrameLevel(30)
		WorldMapDetailFrame:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 1)
	end

	WorldMapFrame:HookScript("OnShow", FixSkin)
	hooksecurefunc("WorldMapFrame_SetFullMapView", LargeSkin)
	hooksecurefunc("WorldMapFrame_SetQuestMapView", QuestSkin)
	hooksecurefunc("WorldMap_ToggleSizeUp", FixSkin)
end

S:AddCallback("SkinWorldMap", LoadSkin)