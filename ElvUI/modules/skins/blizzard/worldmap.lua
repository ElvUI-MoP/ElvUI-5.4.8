local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.worldmap ~= true) then return; end

	S:HandleScrollBar(WorldMapQuestScrollFrameScrollBar)
	S:HandleScrollBar(WorldMapQuestDetailScrollFrameScrollBar, 4)
	S:HandleScrollBar(WorldMapQuestRewardScrollFrameScrollBar, 4)

	WorldMapFrame:CreateBackdrop("Transparent")
	WorldMapDetailFrame.backdrop = CreateFrame("Frame", nil, WorldMapFrame)
	WorldMapDetailFrame.backdrop:SetTemplate("Default")
	WorldMapDetailFrame.backdrop:SetOutside(WorldMapDetailFrame)
	WorldMapDetailFrame.backdrop:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() - 2)

	S:HandleCloseButton(WorldMapFrameCloseButton)
	S:HandleCloseButton(WorldMapFrameSizeDownButton, nil, "-")
	S:HandleCloseButton(WorldMapFrameSizeUpButton, nil, "+")

	WorldMapFrameSizeUpButton.text:Point("CENTER", 0, -1)
	WorldMapFrameSizeDownButton.text:Point("CENTER")

	S:HandleDropDownBox(WorldMapLevelDropDown)
	S:HandleDropDownBox(WorldMapZoneMinimapDropDown)
	S:HandleDropDownBox(WorldMapContinentDropDown)
	S:HandleDropDownBox(WorldMapZoneDropDown)
	S:HandleDropDownBox(WorldMapShowDropDown)

	S:HandleButton(WorldMapZoomOutButton)
	WorldMapZoomOutButton:Point("LEFT", WorldMapZoneDropDown, "RIGHT", 0, 4)
	WorldMapLevelUpButton:Point("TOPLEFT", WorldMapLevelDropDown, "TOPRIGHT", -2, 8)
	WorldMapLevelDownButton:Point("BOTTOMLEFT", WorldMapLevelDropDown, "BOTTOMRIGHT", -2, 2)

	S:HandleCheckBox(WorldMapTrackQuest)

	--Mini
	local function SmallSkin()
		WorldMapLevelDropDown:ClearAllPoints()
		WorldMapLevelDropDown:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -10, -4)

		WorldMapFrame.backdrop:ClearAllPoints()
		WorldMapFrame.backdrop:Point("TOPLEFT", 2, 2)
		WorldMapFrame.backdrop:Point("BOTTOMRIGHT", 5, -2)
	end

	--Large
	local function LargeSkin()
		if(not InCombatLockdown()) then
			WorldMapFrame:SetParent(E.UIParent)
			WorldMapFrame:EnableMouse(false)
			WorldMapFrame:EnableKeyboard(false)
			SetUIPanelAttribute(WorldMapFrame, "area", "center");
			SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
		end

		WorldMapFrame.backdrop:ClearAllPoints()
		WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -12, 70)
		WorldMapFrame.backdrop:Point("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", 17, -30)
	end

	local function QuestSkin()
		if(not InCombatLockdown()) then
			WorldMapFrame:SetParent(E.UIParent)
			WorldMapFrame:EnableMouse(false)
			WorldMapFrame:EnableKeyboard(false)
			SetUIPanelAttribute(WorldMapFrame, "area", "center");
			SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
		end

		WorldMapFrame.backdrop:ClearAllPoints()
		WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -8, 70)
		WorldMapFrame.backdrop:Point("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", 325, -235)

		if(not WorldMapQuestDetailScrollFrame.backdrop) then
			WorldMapQuestDetailScrollFrame:CreateBackdrop("Transparent")
			WorldMapQuestDetailScrollFrame.backdrop:Point("TOPLEFT", -22, 2)
			WorldMapQuestDetailScrollFrame.backdrop:Point("BOTTOMRIGHT", 23, -4)
		end

		if(not WorldMapQuestRewardScrollFrame.backdrop) then
			WorldMapQuestRewardScrollFrame:CreateBackdrop("Transparent")
			WorldMapQuestRewardScrollFrame.backdrop:Point("TOPLEFT", -2, 2)
			WorldMapQuestRewardScrollFrame.backdrop:Point("BOTTOMRIGHT", 22, -4)
		end

		if(not WorldMapQuestScrollFrame.backdrop) then
			WorldMapQuestScrollFrame:CreateBackdrop("Transparent")
			WorldMapQuestScrollFrame.backdrop:Point("TOPLEFT", 0, 2)
			WorldMapQuestScrollFrame.backdrop:Point("BOTTOMRIGHT", 25, -3)
		end
	end

	local function FixSkin()
		WorldMapFrame:StripTextures()

		if(WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE) then
			LargeSkin()
		elseif(WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE) then
			SmallSkin()
		elseif(WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE) then
			QuestSkin()
		end

		if(not InCombatLockdown()) then
			WorldMapFrame:SetScale(1)
			WorldMapFrameSizeDownButton:Show()
			WorldMapFrame:SetFrameLevel(30)
			WorldMapDetailFrame:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 1)
		else
			WorldMapFrameSizeDownButton:Disable()
			WorldMapFrameSizeUpButton:Disable()
		end
	end

	WorldMapFrame:HookScript("OnShow", FixSkin)
	hooksecurefunc("WorldMapFrame_SetFullMapView", LargeSkin)
	hooksecurefunc("WorldMapFrame_SetQuestMapView", QuestSkin)
	hooksecurefunc("WorldMap_ToggleSizeUp", FixSkin)

	WorldMapFrame:Show()
	WorldMapFrame:Hide()

	WorldMapFrame:HookScript("OnUpdate", function(self, elapsed)
		--For some reason these buttons aren't functioning correctly, and we can't afford for it to fuckup because toggling to a big map in combat will cause a taint.
		if(InCombatLockdown()) then
			WorldMapFrameSizeDownButton:Disable()
			WorldMapFrameSizeUpButton:Disable()
		else
			WorldMapFrameSizeDownButton:Enable()
			WorldMapFrameSizeUpButton:Enable()
		end

		if(WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE) then
			WorldMapFrameSizeUpButton:Hide()
			WorldMapFrameSizeDownButton:Show()
		elseif(WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE) then
			WorldMapFrameSizeUpButton:Show()
			WorldMapFrameSizeDownButton:Hide()
		elseif(WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE) then
			WorldMapFrameSizeUpButton:Hide()
			WorldMapFrameSizeDownButton:Show()
		end

		if(DropDownList1:GetScale() ~= UIParent:GetScale()) then
			DropDownList1:SetScale(UIParent:GetScale())
		end
	end)

	WorldMapZoneDropDownButton:HookScript("OnClick", function(self)
		DropDownList1:ClearAllPoints()
		DropDownList1:Point("TOPRIGHT", self, "BOTTOMRIGHT", -17, -4)
	end)
end

S:AddCallback("SkinWorldMap", LoadSkin)