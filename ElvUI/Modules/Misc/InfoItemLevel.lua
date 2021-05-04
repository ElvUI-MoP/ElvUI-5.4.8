local E, L, V, P, G = unpack(select(2, ...))
local M = E:GetModule("Misc")
local LSM = E.Libs.LSM

local _G = _G
local next, pairs, unpack = next, pairs, unpack
local rad = rad
local gsub = gsub
local wipe = wipe

local UnitGUID = UnitGUID
local CreateFrame = CreateFrame

local InspectItems = {
	"HeadSlot",
	"NeckSlot",
	"ShoulderSlot",
	"",
	"ChestSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"WristSlot",
	"HandsSlot",
	"Finger0Slot",
	"Finger1Slot",
	"Trinket0Slot",
	"Trinket1Slot",
	"BackSlot",
	"MainHandSlot",
	"SecondaryHandSlot",
}

local whileOpenEvents = {
	["UPDATE_INVENTORY_DURABILITY"] = true
}

function M:CreateInspectTexture(slot, x, y)
	local texture = slot:CreateTexture()
	texture:Point("BOTTOM", x, y)
	texture:SetTexCoord(unpack(E.TexCoords))
	texture:Size(12)

	local backdrop = CreateFrame("Frame", nil, slot)
	backdrop:SetTemplate(nil, nil, true)
	backdrop:SetBackdropColor(0, 0, 0, 0)
	backdrop:SetOutside(texture)
	backdrop:Hide()

	return texture, backdrop
end

function M:GetInspectPoints(id)
	if not id then return end

	if id <= 5 or (id == 9 or id == 15) then
		return 40, 3, 18, "BOTTOMLEFT" -- Left side
	elseif (id >= 6 and id <= 8) or (id >= 10 and id <= 14) then
		return -40, 3, 18, "BOTTOMRIGHT" -- Right side
	else
		return 0, 45, 60, "BOTTOM"
	end
end

function M:UpdateInspectInfo(_, arg1)
	M:UpdatePageInfo(InspectFrame, "Inspect", arg1)
end

function M:UpdateCharacterInfo(event)
	if (not E.db.general.itemLevel.displayCharacterInfo) or (whileOpenEvents[event] and not CharacterFrame:IsShown()) then return end

	M:UpdatePageInfo(CharacterFrame, "Character", nil, event)
end

function M:UpdateCharacterItemLevel()
	M:UpdateAverageString(CharacterFrame, "Character")
end

function M:ClearPageInfo(frame, which)
	if not (frame and frame.ItemLevelText) then return end
	frame.ItemLevelText:SetText("")

	for i = 1, 17 do
		if i ~= 4 then
			local inspectItem = _G[which..InspectItems[i]]
			inspectItem.enchantText:SetText("")
			inspectItem.iLvlText:SetText("")

			for y = 1, 10 do
				inspectItem["textureSlot"..y]:SetTexture()
				inspectItem["textureSlotBackdrop"..y]:Hide()
			end
		end
	end
end

function M:INSPECT_READY(_, unitGUID)
	M:UpdateInspectInfo(nil, unitGUID)

	if not E.db.general.itemLevel.displayInspectInfo then
		M:ClearPageInfo(InspectFrame, "Inspect")
	end
end

function M:ToggleItemLevelInfo(setupCharacterPage)
	if setupCharacterPage then
		M:CreateSlotStrings(CharacterFrame, "Character")
	end

	if E.db.general.itemLevel.displayCharacterInfo then
		M:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "UpdateCharacterInfo")
		M:RegisterEvent("UPDATE_INVENTORY_DURABILITY", "UpdateCharacterInfo")
		M:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE", "UpdateCharacterItemLevel")

		if not CharacterFrame.CharacterInfoHooked then
			CharacterFrame:HookScript("OnShow", M.UpdateCharacterInfo)
			CharacterFrame.CharacterInfoHooked = true
		end

		if not setupCharacterPage then
			M:UpdateCharacterInfo()
		end
	else
		M:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
		M:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
		M:UnregisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE")

		M:ClearPageInfo(CharacterFrame, "Character")
	end

	if E.db.general.itemLevel.displayInspectInfo or (E.private.skins.blizzard.enable and E.private.skins.blizzard.inspect) then
		M:RegisterEvent("INSPECT_READY")
	else
		M:UnregisterEvent("INSPECT_READY")
	end
end

function M:UpdatePageStrings(i, iLevelDB, inspectItem, slotInfo, which) -- `which` is used by plugins
	if which == "Inspect" and E.private.skins.blizzard.enable and E.private.skins.blizzard.inspect then
		if slotInfo.itemLevelColors and next(slotInfo.itemLevelColors) then
			inspectItem.backdrop:SetBackdropBorderColor(unpack(slotInfo.itemLevelColors))
		else
			inspectItem.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end

	if which == "Inspect" and not E.db.general.itemLevel.displayInspectInfo then return end

	iLevelDB[i] = slotInfo.iLvl

	inspectItem.enchantText:SetText(slotInfo.enchantTextShort)
	if slotInfo.enchantColors and next(slotInfo.enchantColors) then
		inspectItem.enchantText:SetTextColor(unpack(slotInfo.enchantColors))
	end

	inspectItem.iLvlText:SetText(slotInfo.iLvl)
	if slotInfo.itemLevelColors and next(slotInfo.itemLevelColors) then
		inspectItem.iLvlText:SetTextColor(unpack(slotInfo.itemLevelColors))
	end

	local gemStep = 1
	for x = 1, 10 do
		local texture = inspectItem["textureSlot"..x]
		local backdrop = inspectItem["textureSlotBackdrop"..x]
		local gem = slotInfo.gems and slotInfo.gems[gemStep]

		if gem then
			texture:SetTexture(gem)
			texture:SetParent(backdrop)

			backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			backdrop:Show()

			gemStep = gemStep + 1
		else
			texture:SetTexture()
			backdrop:Hide()
		end
	end
end

function M:UpdateAverageString(frame, which, iLevelDB)
	local isCharPage = which == "Character"
	local AvgItemLevel = (isCharPage and E:GetPlayerItemLevel()) or (frame.unit and E:CalculateAverageItemLevel(iLevelDB, frame.unit))

	if AvgItemLevel then
		if isCharPage then
			--frame.ItemLevelText:SetText(AvgItemLevel)
			frame.ItemLevelText:SetText("")
			frame.ItemLevelText:SetTextColor(1, 1, 1)
		else
			frame.ItemLevelText:SetFormattedText(L["Item level: %.2f"], AvgItemLevel)
		end
	else
		frame.ItemLevelText:SetText("")
	end
end

function M:TryGearAgain(frame, which, i, deepScan, iLevelDB, inspectItem)
	E:Delay(0.2, function()
		if which == "Inspect" and (not frame or not frame.unit) then return end

		local unit = (which == "Character" and "player") or frame.unit
		local slotInfo = E:GetGearSlotInfo(unit, i, deepScan)
		if slotInfo == "tooSoon" then return end

		M:UpdatePageStrings(i, iLevelDB, inspectItem, slotInfo, which)
	end)
end

do
	local iLevelDB = {}
	function M:UpdatePageInfo(frame, which, guid, event)
		if not (which and frame and frame.ItemLevelText) then return end
		if which == "Inspect" and (not frame or not frame.unit or (guid and frame:IsShown() and UnitGUID(frame.unit) ~= guid)) then return end

		wipe(iLevelDB)

		local waitForItems
		for i = 1, 17 do
			if i ~= 4 then
				local inspectItem = _G[which..InspectItems[i]]

				inspectItem.enchantText:SetText("")
				inspectItem.iLvlText:SetText("")

				local unit = (which == "Character" and "player") or frame.unit
				local slotInfo = E:GetGearSlotInfo(unit, i, true)

				if slotInfo == "tooSoon" then
					if not waitForItems then waitForItems = true end
					M:TryGearAgain(frame, which, i, true, iLevelDB, inspectItem)
				else
					M:UpdatePageStrings(i, iLevelDB, inspectItem, slotInfo, which)
				end
			end
		end

		if event and event == "PLAYER_EQUIPMENT_CHANGED" then return end

		if waitForItems then
			E:Delay(0.2, M.UpdateAverageString, M, frame, which, iLevelDB)
		else
			M:UpdateAverageString(frame, which, iLevelDB)
		end
	end
end

function M:CreateSlotStrings(frame, which)
	if not (frame and which) then return end

	local itemLevelFont = E.db.general.itemLevel.itemLevelFont
	local itemLevelFontSize = E.db.general.itemLevel.itemLevelFontSize or 12
	local itemLevelFontOutline = E.db.general.itemLevel.itemLevelFontOutline or "OUTLINE"

	if which == "Inspect" then
		frame.ItemLevelText = InspectPaperDollItemsFrame:CreateFontString(nil, "ARTWORK")
		frame.ItemLevelText:Point("BOTTOMRIGHT", -6, 6)
	else
		frame.ItemLevelText = CharacterStatsPane:CreateFontString(nil, "ARTWORK")
		frame.ItemLevelText:Point("BOTTOM", CharacterStatsPane, "BOTTOM", 0, 0)
	end
	frame.ItemLevelText:FontTemplate(nil, which == "Inspect" and 12 or 20)

	for i, s in pairs(InspectItems) do
		if i ~= 4 then
			local slot = _G[which..s]
			local x, y, z, justify = M:GetInspectPoints(i)

			slot.iLvlText = slot:CreateFontString(nil, "OVERLAY")
			slot.iLvlText:FontTemplate(LSM:Fetch("font", itemLevelFont), itemLevelFontSize, itemLevelFontOutline)
			slot.iLvlText:Point("BOTTOM", slot, x, y)

			slot.enchantText = slot:CreateFontString(nil, "OVERLAY")
			slot.enchantText:FontTemplate(LSM:Fetch("font", itemLevelFont), itemLevelFontSize, itemLevelFontOutline)

			if i == 16 or i == 17 then
				slot.enchantText:Point(i == 16 and "BOTTOMRIGHT" or "BOTTOMLEFT", slot, i == 16 and -40 or 40, 3)
			else
				slot.enchantText:Point(justify, slot, x + (justify == "BOTTOMLEFT" and 5 or -5), z)
			end

			for u = 1, 10 do
				local offset = 8 + (u * (E.PixelMode and 16 or 20))
				local newX = ((justify == "BOTTOMLEFT" or i == 17) and x + offset) or x - offset

				slot["textureSlot"..u], slot["textureSlotBackdrop"..u] = M:CreateInspectTexture(slot, newX, --[[newY or]] y)
			end
		end
	end
end

function M:SetupInspectPageInfo()
	M:CreateSlotStrings(InspectFrame, "Inspect")
end

function M:UpdateInspectPageFonts(which)
	local itemLevelFont = E.db.general.itemLevel.itemLevelFont
	local itemLevelFontSize = E.db.general.itemLevel.itemLevelFontSize or 12
	local itemLevelFontOutline = E.db.general.itemLevel.itemLevelFontOutline or "OUTLINE"

	for i, s in pairs(InspectItems) do
		if i ~= 4 then
			local slot = _G[which..s]

			if slot then
				slot.iLvlText:FontTemplate(LSM:Fetch("font", itemLevelFont), itemLevelFontSize, itemLevelFontOutline)
				slot.enchantText:FontTemplate(LSM:Fetch("font", itemLevelFont), itemLevelFontSize, itemLevelFontOutline)
			end
		end
	end
end