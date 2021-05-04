local E, L, V, P, G = unpack(select(2, ...))
local TT = E:GetModule("Tooltip")

local _G = _G
local unpack, tonumber, select = unpack, tonumber, select
local twipe, tinsert, tconcat = table.wipe, table.insert, table.concat
local floor = math.floor
local find, format, sub, match = string.find, string.format, string.sub, string.match

local CanInspect = CanInspect
local CreateFrame = CreateFrame
local GameTooltip_ClearMoney = GameTooltip_ClearMoney
local GetAverageItemLevel = GetAverageItemLevel
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local GetCurrencyListLink = GetCurrencyListLink
local GetGuildInfo = GetGuildInfo
local GetInspectSpecialization = GetInspectSpecialization
local GetInventoryItemLink = GetInventoryItemLink
local GetInventorySlotInfo = GetInventorySlotInfo
local GetItemCount = GetItemCount
local GetMouseFocus = GetMouseFocus
local GetNumGroupMembers = GetNumGroupMembers
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetRelativeDifficultyColor = GetRelativeDifficultyColor
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecializationInfoByID = GetSpecializationInfoByID
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsShiftKeyDown = IsShiftKeyDown
local NotifyInspect = NotifyInspect
local SetTooltipMoney = SetTooltipMoney
local UnitAura = UnitAura
local UnitBattlePetLevel = UnitBattlePetLevel
local UnitBattlePetType = UnitBattlePetType
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitCreatureType = UnitCreatureType
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitGUID = UnitGUID
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitIsAFK = UnitIsAFK
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion
local UnitIsDND = UnitIsDND
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsPVP = UnitIsPVP
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapped = UnitIsTapped
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local UnitIsUnit = UnitIsUnit
local UnitIsWildBattlePet = UnitIsWildBattlePet
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitPVPName = UnitPVPName
local UnitRace = UnitRace
local UnitReaction = UnitReaction
local UnitRealmRelationship = UnitRealmRelationship
local UnitSex = UnitSex

local C_PetBattles_IsInBattle = C_PetBattles.IsInBattle
local C_PetJournalGetPetTeamAverageLevel = C_PetJournal.GetPetTeamAverageLevel

local AFK, BOSS, DEAD, DND, ID, PVP = AFK, BOSS, DEAD, DND, ID, PVP
local ROLE, TANK, HEALER = ROLE, TANK, HEALER
local FACTION_ALLIANCE, FACTION_HORDE, FACTION_BAR_COLORS = FACTION_ALLIANCE, FACTION_HORDE, FACTION_BAR_COLORS
local FOREIGN_SERVER_LABEL = FOREIGN_SERVER_LABEL
local ITEM_QUALITY3_DESC = ITEM_QUALITY3_DESC
local LE_REALM_RELATION_COALESCED = LE_REALM_RELATION_COALESCED
local LE_REALM_RELATION_VIRTUAL = LE_REALM_RELATION_VIRTUAL
local PET_TYPE_SUFFIX = PET_TYPE_SUFFIX
local SPECIALIZATION = SPECIALIZATION
local UNKNOWN = UNKNOWN

local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST

-- Custom to find LEVEL string on tooltip
local LEVEL1 = strlower(TOOLTIP_UNIT_LEVEL:gsub("%s?%%s%s?%-?", ""))
local LEVEL2 = strlower(TOOLTIP_UNIT_LEVEL_CLASS:gsub("^%%2$s%s?(.-)%s?%%1$s", "%1"):gsub("^%-?г?о?%s?", ""):gsub("%s?%%s%s?%-?", ""))

local IDLine = "|cFFCA3C3C%s|r %d"
local GameTooltip, GameTooltipStatusBar = GameTooltip, GameTooltipStatusBar
local targetList = {}
local TAPPED_COLOR = {r = 0.6, g = 0.6, b = 0.6}
local AFK_LABEL = " |cffFFFFFF[|r|cffFF0000"..AFK.."|r|cffFFFFFF]|r"
local DND_LABEL = " |cffFFFFFF[|r|cffFFFF00"..DND.."|r|cffFFFFFF]|r"
local keybindFrame

local classification = {
	worldboss = format("|cffAF5050 %s|r", BOSS),
	rareelite = format("|cffAF5050+ %s|r", ITEM_QUALITY3_DESC),
	elite = "|cffAF5050+|r",
	rare = format("|cffAF5050 %s|r", ITEM_QUALITY3_DESC)
}

local genderTable = {
	UNKNOWN or "",
	MALE,
	FEMALE
}

function TT:IsModKeyDown(db)
	local k = db or TT.db.modifierID -- defaulted to "HIDE" unless otherwise specified
	return k == "SHOW" or ((k == "SHIFT" and IsShiftKeyDown()) or (k == "CTRL" and IsControlKeyDown()) or (k == "ALT" and IsAltKeyDown()))
end

function TT:GameTooltip_SetDefaultAnchor(tt, parent)
	if E.private.tooltip.enable ~= true then return end
	if not TT.db.visibility then return end
	if tt:GetAnchorType() ~= "ANCHOR_NONE" then return end

	if InCombatLockdown() and not TT:IsModKeyDown(TT.db.visibility.combatOverride) then
		tt:Hide()
		return
	end

	local ownerName = tt:GetOwner() and tt:GetOwner().GetName and tt:GetOwner():GetName()
	if ownerName and (find(ownerName, "ElvUI_Bar") or find(ownerName, "ElvUI_StanceBar") or find(ownerName, "PetAction")) and not keybindFrame.active and not TT:IsModKeyDown(TT.db.visibility.actionbars) then
		tt:Hide()
		return
	end

	if tt.StatusBar then
		tt.StatusBar:SetAlpha(TT.db.healthBar.statusPosition == "DISABLED" and 0 or 1)
		if TT.db.healthBar.statusPosition == "BOTTOM" then
			if tt.StatusBar.anchoredToTop then
				tt.StatusBar:ClearAllPoints()
				tt.StatusBar:Point("TOPLEFT", tt, "BOTTOMLEFT", E.Border, -(E.Spacing * 3))
				tt.StatusBar:Point("TOPRIGHT", tt, "BOTTOMRIGHT", -E.Border, -(E.Spacing * 3))
				tt.StatusBar.text:Point("CENTER", tt.StatusBar, 0, 0)
				tt.StatusBar.anchoredToTop = nil
			end
		elseif TT.db.healthBar.statusPosition == "TOP" then
			if not tt.StatusBar.anchoredToTop then
				tt.StatusBar:ClearAllPoints()
				tt.StatusBar:Point("BOTTOMLEFT", tt, "TOPLEFT", E.Border, (E.Spacing * 3))
				tt.StatusBar:Point("BOTTOMRIGHT", tt, "TOPRIGHT", -E.Border, (E.Spacing * 3))
				tt.StatusBar.text:Point("CENTER", tt.StatusBar, 0, 0)
				tt.StatusBar.anchoredToTop = true
			end
		end
	end

	if parent then
		if TT.db.cursorAnchor then
			tt:SetOwner(parent, TT.db.cursorAnchorType, TT.db.cursorAnchorX, TT.db.cursorAnchorY)
			return
		else
			tt:SetOwner(parent, "ANCHOR_NONE")
		end
	end

	local _, anchor = tt:GetPoint()
	if anchor == nil or (ElvUI_ContainerFrame and anchor == ElvUI_ContainerFrame) or anchor == RightChatPanel or anchor == TooltipMover or anchor == UIParent or anchor == E.UIParent then
		tt:ClearAllPoints()
		if not E:HasMoverBeenMoved("TooltipMover") then
			if ElvUI_ContainerFrame and ElvUI_ContainerFrame:IsShown() then
				tt:Point("BOTTOMRIGHT", ElvUI_ContainerFrame, "TOPRIGHT", 0, 18)
			elseif RightChatPanel:GetAlpha() == 1 and RightChatPanel:IsShown() then
				tt:Point("BOTTOMRIGHT", RightChatPanel, "TOPRIGHT", 0, 18)
			else
				tt:Point("BOTTOMRIGHT", RightChatPanel, "BOTTOMRIGHT", 0, 18)
			end
		else
			local point = E:GetScreenQuadrant(TooltipMover)
			if point == "TOPLEFT" then
				tt:Point("TOPLEFT", TooltipMover, "BOTTOMLEFT", 1, -4)
			elseif point == "TOPRIGHT" then
				tt:Point("TOPRIGHT", TooltipMover, "BOTTOMRIGHT", -1, -4)
			elseif point == "BOTTOMLEFT" or point == "LEFT" then
				tt:Point("BOTTOMLEFT", TooltipMover, "TOPLEFT", 1, 18)
			else
				tt:Point("BOTTOMRIGHT", TooltipMover, "TOPRIGHT", -1, 18)
			end
		end
	end
end

function TT:RemoveTrashLines(tt)
	for i = 3, tt:NumLines() do
		local tiptext = _G["GameTooltipTextLeft"..i]
		local linetext = tiptext:GetText()

		if linetext == PVP or linetext == FACTION_ALLIANCE or linetext == FACTION_HORDE then
			tiptext:SetText("")
			tiptext:Hide()
		end
	end
end

function TT:GetLevelLine(tt, offset)
	for i = offset, tt:NumLines() do
		local tipLine = _G["GameTooltipTextLeft"..i]
		local tipText = tipLine and tipLine:GetText() and strlower(tipLine:GetText())
		if tipText and find(tipText, LEVEL1) or find(tipText, LEVEL2) then
			return tipLine
		end
	end
end

function TT:SetUnitText(tt, unit)
	local name, realm = UnitName(unit)

	if UnitIsPlayer(unit) then
		local localeClass, class = UnitClass(unit)
		if not localeClass or not class then return end

		local nameRealm = (realm and realm ~= "" and format("%s-%s", name, realm)) or name
		local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
		local pvpName = UnitPVPName(unit)
		local level = UnitLevel(unit)
		local relationship = UnitRealmRelationship(unit)
		local isShiftKeyDown = IsShiftKeyDown()
		local nameColor = E:ClassColor(class) or PRIEST_COLOR

		if TT.db.playerTitles and pvpName then
			name = pvpName
		end

		if realm and realm ~= "" then
			if isShiftKeyDown or TT.db.alwaysShowRealm then
				name = name.."-"..realm
			elseif relationship == LE_REALM_RELATION_COALESCED then
				name = name..FOREIGN_SERVER_LABEL
			elseif relationship == LE_REALM_RELATION_VIRTUAL then
				name = name..INTERACTIVE_SERVER_LABEL
			end
		end

		local awayText = UnitIsAFK(unit) and AFK_LABEL or UnitIsDND(unit) and DND_LABEL or ""
		GameTooltipTextLeft1:SetFormattedText("|c%s%s%s|r", nameColor.colorStr, name or UNKNOWN, awayText)

		local lineOffset = 2
		if guildName then
			if guildRealm and isShiftKeyDown then
				guildName = guildName.."-"..guildRealm
			end

			if TT.db.guildRanks then
				GameTooltipTextLeft2:SetFormattedText("<|cff00ff10%s|r> [|cff00ff10%s|r]", guildName, guildRankName)
			else
				GameTooltipTextLeft2:SetFormattedText("<|cff00ff10%s|r>", guildName)
			end
			lineOffset = 3
		end

		local levelLine = TT:GetLevelLine(tt, lineOffset)
		if levelLine then
			local diffColor = GetQuestDifficultyColor(level)
			local race, englishRace = UnitRace(unit)
			local _, localizedFaction = E:GetUnitBattlefieldFaction(unit)
			if localizedFaction and englishRace == "Pandaren" then race = localizedFaction.." "..race end
			local hexColor = E:RGBToHex(diffColor.r, diffColor.g, diffColor.b)
			if TT.db.gender then
				levelLine:SetFormattedText("%s%s|r %s %s |c%s%s|r", hexColor, level > 0 and level or "??", genderTable[UnitSex(unit)], race or "", nameColor.colorStr, localeClass)
			else
				levelLine:SetFormattedText("%s%s|r %s |c%s%s|r", hexColor, level > 0 and level or "??", race, nameColor.colorStr, localeClass)
			end
		end

		if TT.db.role then
			local r, g, b, role = 1, 1, 1, UnitGroupRolesAssigned(unit)
			if IsInGroup() and (UnitInParty(unit) or UnitInRaid(unit)) and (role ~= "NONE") then
				if role == "HEALER" then
					role, r, g, b = HEALER, 0, 1, 0.59
				elseif role == "TANK" then
					role, r, g, b = TANK, 0.16, 0.31, 0.61
				elseif role == "DAMAGER" then
					role, r, g, b = L["DPS"], 0.77, 0.12, 0.24
				end

				GameTooltip:AddDoubleLine(format("%s:", ROLE), role, nil, nil, nil, r, g, b)
			end
		end

		if TT.db.showElvUIUsers then
			local addonUser = E.UserList[nameRealm]
			if addonUser then
				local r, g
				if addonUser == E.version then
					r, g = 0, 1
				elseif addonUser > E.version then
					r, g = 1, 1
				elseif addonUser < E.version then
					r, g = 1, 0
				end

				GameTooltip:AddDoubleLine(E.title, format("%.02f", addonUser), nil, nil, nil, r, g, 0)
			end

			-- Support private servers with custom realm name at character's 'name-realm'
			for _, customRealm in pairs(E.privateServerRealms) do
				local customRealmName = format("%s-%s", name, customRealm)
				local customAddonUser = E.UserList[customRealmName]

				if customAddonUser then
					local r, g
					if customAddonUser == E.version then
						r, g = 0, 1
					elseif customAddonUser > E.version then
						r, g = 1, 1
					elseif customAddonUser < E.version then
						r, g = 1, 0
					end

					GameTooltip:AddDoubleLine(E.title, format("%.02f", customAddonUser), nil, nil, nil, r, g, 0)
				end
			end
		end

		return nameColor
	else
		local levelLine = TT:GetLevelLine(tt, 2)
		if levelLine then
			local isPetWild, isPetCompanion = UnitIsWildBattlePet(unit), UnitIsBattlePetCompanion(unit)
			local creatureClassification = UnitClassification(unit)
			local creatureType = UnitCreatureType(unit)
			local pvpFlag, diffColor

			local level = UnitLevel(unit)
			if isPetWild or isPetCompanion then
				level = UnitBattlePetLevel(unit)

				local petType = _G["BATTLE_PET_NAME_"..UnitBattlePetType(unit)]
				if creatureType then
					creatureType = format("%s %s", creatureType, petType)
				else
					creatureType = petType
				end

				local teamLevel = C_PetJournalGetPetTeamAverageLevel()
				if teamLevel then
					diffColor = GetRelativeDifficultyColor(teamLevel, level)
				else
					diffColor = GetQuestDifficultyColor(level)
				end
			else
				diffColor = GetQuestDifficultyColor(level)
			end

			if UnitIsPVP(unit) then
				pvpFlag = format(" (%s)", PVP)
			end

			levelLine:SetFormattedText("|cff%02x%02x%02x%s|r%s %s%s", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", classification[creatureClassification] or "", creatureType or "", pvpFlag or "")
		end

		local unitReaction = UnitReaction(unit, "player")
		local unitTapped = UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)
		local nameColor = unitReaction and ((TT.db.useCustomFactionColors and TT.db.factionColors[unitReaction]) or FACTION_BAR_COLORS[unitReaction]) or PRIEST_COLOR
		local nameColorStr = nameColor.colorStr or E:RGBToHex(nameColor.r, nameColor.g, nameColor.b, "ff")

		GameTooltipTextLeft1:SetFormattedText("|c%s%s|r", nameColorStr, name or UNKNOWN)

		return (unitTapped and TAPPED_COLOR) or nameColor
	end
end

local inspectGUIDCache = {}
local inspectColorFallback = {1, 1, 1}
function TT:PopulateInspectGUIDCache(unitGUID, itemLevel)
	local specName = TT:GetSpecializationInfo("mouseover")
	if specName and itemLevel then
		local inspectCache = inspectGUIDCache[unitGUID]
		if inspectCache then
			inspectCache.time = GetTime()
			inspectCache.itemLevel = itemLevel
			inspectCache.specName = specName
		end

		GameTooltip:AddDoubleLine(SPECIALIZATION..":", specName, nil, nil, nil, unpack((inspectCache and inspectCache.unitColor) or inspectColorFallback))
		GameTooltip:AddDoubleLine(L["Item Level:"], itemLevel, nil, nil, nil, 1, 1, 1)
		GameTooltip:Show()
	end
end

function TT:INSPECT_READY(event, unitGUID)
	if UnitExists("mouseover") and UnitGUID("mouseover") == unitGUID then
		local itemLevel, retryUnit, retryTable, iLevelDB = E:GetUnitItemLevel("mouseover")

		if itemLevel == "tooSoon" then
			E:Delay(0.05, function()
				local canUpdate = true

				for _, x in ipairs(retryTable) do
					local slotInfo = E:GetGearSlotInfo(retryUnit, x)

					if slotInfo == "tooSoon" then
						canUpdate = false
					else
						iLevelDB[x] = slotInfo.iLvl
					end
				end

				if canUpdate then
					local calculateItemLevel = E:CalculateAverageItemLevel(iLevelDB, retryUnit)
					TT:PopulateInspectGUIDCache(unitGUID, calculateItemLevel)
				end
			end)
		else
			TT:PopulateInspectGUIDCache(unitGUID, itemLevel)
		end
	end

	if event then
		TT:UnregisterEvent(event)
	end
end

function TT:GetSpecializationInfo(unit, isPlayer)
	local spec = (isPlayer and GetSpecialization()) or (unit and GetInspectSpecialization(unit))

	if spec and spec > 0 then
		local _, name, icon

		if isPlayer then
			_, name, _, icon = GetSpecializationInfo(spec)
		else
			_, name, _, icon = GetSpecializationInfoByID(spec)
		end

		return "|T"..icon..":12:12:0:0:64:64:5:59:5:59|t "..name
	end
end

local lastGUID
function TT:AddInspectInfo(tooltip, unit, numTries, r, g, b)
	if (not unit) or (numTries > 3) or not CanInspect(unit) then return end

	local unitGUID = UnitGUID(unit)
	if not unitGUID then return end

	if unitGUID == E.myguid then
		tooltip:AddDoubleLine(SPECIALIZATION..":", TT:GetSpecializationInfo(unit, true), nil, nil, nil, r, g, b)
		tooltip:AddDoubleLine(L["Item Level:"], E:GetUnitItemLevel(unit), nil, nil, nil, 1, 1, 1)
	elseif inspectGUIDCache[unitGUID] and inspectGUIDCache[unitGUID].time then
		local specName = inspectGUIDCache[unitGUID].specName
		local itemLevel = inspectGUIDCache[unitGUID].itemLevel
		if not (specName and itemLevel) or (GetTime() - inspectGUIDCache[unitGUID].time > 120) then
			inspectGUIDCache[unitGUID].time = nil
			inspectGUIDCache[unitGUID].specName = nil
			inspectGUIDCache[unitGUID].itemLevel = nil
			return E:Delay(0.33, TT.AddInspectInfo, TT, tooltip, unit, numTries + 1, r, g, b)
		end

		tooltip:AddDoubleLine(SPECIALIZATION..":", specName, nil, nil, nil, r, g, b)
		tooltip:AddDoubleLine(L["Item Level:"], itemLevel, nil, nil, nil, 1, 1, 1)
	elseif unitGUID then
		if not inspectGUIDCache[unitGUID] then
			inspectGUIDCache[unitGUID] = {unitColor = {r, g, b}}
		end

		if lastGUID ~= unitGUID then
			lastGUID = unitGUID
			NotifyInspect(unit)
			TT:RegisterEvent("INSPECT_READY")
		else
			TT:INSPECT_READY(nil, unitGUID)
		end
	end
end

function TT:GameTooltip_OnTooltipSetUnit(tt)
	local unit = select(2, tt:GetUnit())
	local isPlayerUnit = UnitIsPlayer(unit)

	if TT.db.visibility and not TT:IsModKeyDown(TT.db.visibility.unitFrames) and (tt:GetOwner() ~= UIParent) then
		tt:Hide()
		return
	end

	if not unit then
		local GMF = GetMouseFocus()
		local focusUnit = GMF and GMF.GetAttribute and GMF:GetAttribute("unit")

		if focusUnit then unit = focusUnit end
		if not unit or not UnitExists(unit) then return end
	end

	TT:RemoveTrashLines(tt)

	local isShiftKeyDown = IsShiftKeyDown()
	local isControlKeyDown = IsControlKeyDown()
	local color = TT:SetUnitText(tt, unit)

	if not isShiftKeyDown and not isControlKeyDown then
		local unitTarget = unit.."target"
		if TT.db.targetInfo and unit ~= "player" and UnitExists(unitTarget) then
			local targetColor
			if UnitIsPlayer(unitTarget) and not UnitHasVehicleUI(unitTarget) then
				local _, class = UnitClass(unitTarget)
				targetColor = E:ClassColor(class) or PRIEST_COLOR
			else
				local reaction = UnitReaction(unitTarget, "player")
				targetColor = (TT.db.useCustomFactionColors and TT.db.factionColors[reaction]) or FACTION_BAR_COLORS[reaction] or PRIEST_COLOR
			end

			tt:AddDoubleLine(format("%s:", TARGET), format("|cff%02x%02x%02x%s|r", targetColor.r * 255, targetColor.g * 255, targetColor.b * 255, UnitName(unitTarget)))
		end

		if TT.db.targetInfo and IsInGroup() then
			for i = 1, GetNumGroupMembers() do
				local groupUnit = (IsInRaid() and "raid"..i or "party"..i)
				if (UnitIsUnit(groupUnit.."target", unit)) and (not UnitIsUnit(groupUnit, "player")) then
					local _, class = UnitClass(groupUnit)
					local classColor = E:ClassColor(class) or PRIEST_COLOR
					tinsert(targetList, format("|c%s%s|r", classColor.colorStr, UnitName(groupUnit)))
				end
			end
			local numList = #targetList
			if numList > 0 then
				tt:AddLine(format("%s (|cffffffff%d|r): %s", L["Targeted By:"], numList, tconcat(targetList, ", ")), nil, nil, nil, true)
				twipe(targetList)
			end
		end
	end

	if isShiftKeyDown and isPlayerUnit then
		TT:AddInspectInfo(tt, unit, 0, color.r, color.g, color.b)
	end

	-- NPC ID's
	if unit and not isPlayerUnit and TT:IsModKeyDown() then
		if C_PetBattles_IsInBattle() then return end

		local guid = UnitGUID(unit) or ""
		local id = tonumber(sub(guid, 6, 10), 16)

		if id then
			tt:AddLine(format(IDLine, ID, id))
		end
	end

	if color then
		tt.StatusBar:SetStatusBarColor(color.r, color.g, color.b)
	else
		tt.StatusBar:SetStatusBarColor(0.6, 0.6, 0.6)
	end

	local textWidth = tt.StatusBar.text:GetStringWidth()
	if textWidth then
		tt:SetMinimumWidth(textWidth)
	end
end

function TT:GameTooltipStatusBar_OnValueChanged(tt, value)
	if not value or not TT.db.healthBar.text or not tt.text then return end

	local unit = select(2, tt:GetParent():GetUnit())
	if not unit then
		local GMF = GetMouseFocus()
		if GMF and GMF.GetAttribute and GMF:GetAttribute("unit") then
			unit = GMF:GetAttribute("unit")
		end
	end

	local _, max = tt:GetMinMaxValues()
	if value > 0 and max == 1 then
		tt.text:SetFormattedText("%d%%", floor(value * 100))
		tt:SetStatusBarColor(TAPPED_COLOR.r, TAPPED_COLOR.g, TAPPED_COLOR.b) --most effeciant?
	elseif value == 0 or (unit and UnitIsDeadOrGhost(unit)) then
		tt.text:SetText(DEAD)
	else
		tt.text:SetText(E:ShortValue(value).." / "..E:ShortValue(max))
	end
end

function TT:GameTooltip_OnTooltipCleared(tt)
	tt.itemCleared = nil
end

function TT:GameTooltip_OnTooltipSetItem(tt)
	local ownerName = tt:GetOwner() and tt:GetOwner().GetName and tt:GetOwner():GetName()
	if TT.db.visibility and ownerName and (strfind(ownerName, "ElvUI_Container") or strfind(ownerName, "ElvUI_BankContainer")) and not TT:IsModKeyDown(TT.db.visibility.bags) then
		tt.itemCleared = true
		tt:Hide()
		return
	end

	if not tt.itemCleared and TT:IsModKeyDown() then
		local _, link = tt:GetItem()
		local num = GetItemCount(link)
		local numall = GetItemCount(link, true)
		local left, right, bankCount = " ", " ", " "

		if link then
			local id = tonumber(match(link, ":(%w+)"))
			left = format("|cFFCA3C3C%s|r %s", ID, id)
		end

		if TT.db.itemCount == "BAGS_ONLY" then
			right = format(IDLine, L["Count"], num)
		elseif TT.db.itemCount == "BANK_ONLY" then
			bankCount = format(IDLine, L["Bank"], (numall - num))
		elseif TT.db.itemCount == "BOTH" then
			right = format(IDLine, L["Count"], num)
			bankCount = format(IDLine, L["Bank"], (numall - num))
		end

		if left ~= " " or right ~= " " then
			tt:AddLine(" ")
			tt:AddDoubleLine(left, right)
		end

		if bankCount ~= " " then
			tt:AddDoubleLine(" ", bankCount)
		end

		tt.itemCleared = true
	end
end

function TT:GameTooltip_ShowStatusBar(tt)
	if not tt then return end

	local sb = _G[tt:GetName().."StatusBar"..tt.shownStatusBars]
	if not sb or sb.backdrop then return end

	sb:StripTextures()
	sb:CreateBackdrop(nil, nil, true)
	sb:SetStatusBarTexture(E.media.normTex)
end

function TT:CheckBackdropColor(tt)
	if not tt then return end

	local r, g, b = tt:GetBackdropColor()
	if r and g and b then
		r, g, b = E:Round(r, 1), E:Round(g, 1), E:Round(b, 1)
		local red, green, blue = unpack(E.media.backdropfadecolor)
		if r ~= red or g ~= green or b ~= blue then
			tt:SetBackdropColor(red, green, blue, TT.db.colorAlpha)
		end
	end
end

function TT:SetStyle(tt)
	if not tt or tt == E.ScanTooltip then return end

	tt:SetTemplate("Transparent", nil, true) --ignore updates

	local r, g, b = tt:GetBackdropColor()
	tt:SetBackdropColor(r, g, b, TT.db.colorAlpha)
end

function TT:MODIFIER_STATE_CHANGED(_, key)
	if key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL" or key == "LALT" or key == "RALT" then
		local owner = GameTooltip:GetOwner()
		local notOnAuras = not (owner and owner.UpdateTooltip)

		if notOnAuras and UnitExists("mouseover") then
			GameTooltip:SetUnit("mouseover")
		end
	end
end

function TT:SetUnitAura(tt, ...)
	if not tt then return end

	local _, _, _, _, _, _, _, caster, _, _, id = UnitAura(...)

	if id then
		if TT:IsModKeyDown() then
			if caster then
				local name = UnitName(caster)
				local _, class = UnitClass(caster)
				local color = E:ClassColor(class) or PRIEST_COLOR

				tt:AddDoubleLine(format(IDLine, ID, id), format("|c%s%s|r", color.colorStr, name))
			else
				tt:AddLine(format(IDLine, ID, id))
			end
		end

		tt:Show()
	end
end

function TT:SetConsolidatedUnitAura(tt, unit, index)
	local name = GetRaidBuffTrayAuraInfo(index)
	local _, _, _, _, _, _, _, caster, _, _, id = UnitAura(unit, name)

	if id then
		if TT:IsModKeyDown() then
			if caster then
				local name = UnitName(caster)
				local _, class = UnitClass(caster)
				local color = E:ClassColor(class) or PRIEST_COLOR

				tt:AddDoubleLine(format(IDLine, ID, id), format("|c%s%s|r", color.colorStr, name))
			else
				tt:AddLine(format(IDLine, ID, id))
			end
		end

		tt:Show()
	end
end

function TT:GameTooltip_OnTooltipSetSpell(tt)
	if not TT:IsModKeyDown() then return end

	local id = select(3, tt:GetSpell())
	if not id then return end

	local textID = format(IDLine, ID, id)
	for i = 3, tt:NumLines() do
		local line = _G[format("GameTooltipTextLeft%d", i)]
		local text = line and line:GetText()
		if text and strfind(text, textID) then
			return -- this is called twice on talents for some reason?
		end
	end

	tt:AddLine(textID)
	tt:Show()
end

function TT:SetItemRef(link)
	if IsModifierKeyDown() or not (link and strfind(link, "^spell:") or strfind(link, "^item:") or strfind(link, "^currency:") or strfind(link, "^talent:")) then return end

	local id = tonumber(match(link, "(%d+)"))

	ItemRefTooltip:AddLine(format(IDLine, ID, id))
	ItemRefTooltip:Show()
end

function TT:SetCurrencyToken(tt, index)
	local id = TT:IsModKeyDown() and tonumber(strmatch(GetCurrencyListLink(index), "currency:(%d+)"))
	if not id then return end

	tt:AddLine(format(IDLine, ID, id))
	tt:Show()
end

function TT:SetBackpackToken(tt, id)
	if id and TT:IsModKeyDown() then
		tt:AddLine(format(IDLine, ID, select(4, GetBackpackCurrencyInfo(id))))
		tt:Show()
	end
end

function TT:RepositionBNET(frame, _, anchor)
	if anchor ~= BNETMover then
		frame:ClearAllPoints()
		frame:Point(BNETMover.anchorPoint or "TOPLEFT", BNETMover, BNETMover.anchorPoint or "TOPLEFT")
	end
end

function TT:SetTooltipFonts()
	local font = E.Libs.LSM:Fetch("font", TT.db.font)
	local fontOutline = TT.db.fontOutline
	local headerSize = TT.db.headerFontSize
	local smallTextSize = TT.db.smallTextFontSize
	local textSize = TT.db.textFontSize

	GameTooltipHeaderText:SetFont(font, headerSize, fontOutline)
	GameTooltipTextSmall:SetFont(font, smallTextSize, fontOutline)
	GameTooltipText:SetFont(font, textSize, fontOutline)

	if GameTooltip.hasMoney then
		for i = 1, GameTooltip.numMoneyFrames do
			_G["GameTooltipMoneyFrame"..i.."PrefixText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."SuffixText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."GoldButtonText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."SilverButtonText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."CopperButtonText"]:FontTemplate(font, textSize, fontOutline)
		end
	end

	-- Ignore header font size on DatatextTooltip
	if DatatextTooltip then
		DatatextTooltipTextLeft1:FontTemplate(font, textSize, fontOutline)
		DatatextTooltipTextRight1:FontTemplate(font, textSize, fontOutline)
	end

	-- Comparison Tooltips should use smallTextSize
	for _, tt in ipairs(GameTooltip.shoppingTooltips) do
		for i = 1, tt:GetNumRegions() do
			local region = select(i, tt:GetRegions())

			if region:IsObjectType("FontString") then
				region:FontTemplate(font, smallTextSize, fontOutline)
			end
		end
	end
end

--This changes the growth direction of the toast frame depending on position of the mover
local function PostBNToastMove(mover)
	local x, y = mover:GetCenter()
	local screenHeight = E.UIParent:GetTop()
	local screenWidth = E.UIParent:GetRight()

	local anchorPoint
	if y > (screenHeight / 2) then
		anchorPoint = (x > (screenWidth / 2)) and "TOPRIGHT" or "TOPLEFT"
	else
		anchorPoint = (x > (screenWidth / 2)) and "BOTTOMRIGHT" or "BOTTOMLEFT"
	end
	mover.anchorPoint = anchorPoint

	BNToastFrame:ClearAllPoints()
	BNToastFrame:Point(anchorPoint, mover)
end

function TT:Initialize()
	TT.db = E.db.tooltip

	BNToastFrame:Point("TOPRIGHT", MMHolder, "BOTTOMRIGHT", 0, -10)
	E:CreateMover(BNToastFrame, "BNETMover", L["BNet Frame"], nil, nil, PostBNToastMove)
	BNToastFrame.mover:SetSize(BNToastFrame:GetSize())
	TT:SecureHook(BNToastFrame, "SetPoint", "RepositionBNET")

	if not E.private.tooltip.enable then return end

	TT.Initialized = true

	GameTooltip.StatusBar = GameTooltipStatusBar
	GameTooltip.StatusBar:Height(TT.db.healthBar.height)
	GameTooltip.StatusBar:SetScript("OnValueChanged", nil) -- Do we need to unset this?
	GameTooltip.StatusBar.text = GameTooltip.StatusBar:CreateFontString(nil, "OVERLAY")
	GameTooltip.StatusBar.text:Point("CENTER", GameTooltip.StatusBar, 0, 0)
	GameTooltip.StatusBar.text:FontTemplate(E.Libs.LSM:Fetch("font", TT.db.healthBar.font), TT.db.healthBar.fontSize, TT.db.healthBar.fontOutline)

	--Tooltip Fonts
	if not GameTooltip.hasMoney then
		--Force creation of the money lines, so we can set font for it
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		GameTooltip_ClearMoney(GameTooltip)
	end
	TT:SetTooltipFonts()

	local GameTooltipAnchor = CreateFrame("Frame", "GameTooltipAnchor", E.UIParent)
	GameTooltipAnchor:Point("BOTTOMRIGHT", RightChatToggleButton, "BOTTOMRIGHT")
	GameTooltipAnchor:Size(130, 20)
	GameTooltipAnchor:SetFrameLevel(GameTooltipAnchor:GetFrameLevel() + 50)
	E:CreateMover(GameTooltipAnchor, "TooltipMover", L["Tooltip"], nil, nil, nil, nil, nil, "tooltip,general")

	TT:SecureHook("SetItemRef")
	TT:SecureHook("GameTooltip_SetDefaultAnchor")
	TT:SecureHook(GameTooltip, "SetCurrencyToken")
	TT:SecureHook(GameTooltip, "SetBackpackToken")
	TT:SecureHook(GameTooltip, "SetUnitAura")
	TT:SecureHook(GameTooltip, "SetUnitBuff", "SetUnitAura")
	TT:SecureHook(GameTooltip, "SetUnitDebuff", "SetUnitAura")
	TT:SecureHook(GameTooltip, "SetUnitConsolidatedBuff", "SetConsolidatedUnitAura")
	TT:HookScript(GameTooltip, "OnTooltipSetSpell", "GameTooltip_OnTooltipSetSpell")
	TT:HookScript(GameTooltip, "OnTooltipCleared", "GameTooltip_OnTooltipCleared")
	TT:HookScript(GameTooltip, "OnTooltipSetItem", "GameTooltip_OnTooltipSetItem")
	TT:HookScript(GameTooltip, "OnTooltipSetUnit", "GameTooltip_OnTooltipSetUnit")
	TT:HookScript(GameTooltip.StatusBar, "OnValueChanged", "GameTooltipStatusBar_OnValueChanged")
	TT:RegisterEvent("MODIFIER_STATE_CHANGED")

	--Variable is localized at top of file, then set here when we're sure the frame has been created
	--Used to check if keybinding is active, if so then don't hide tooltips on actionbars
	keybindFrame = ElvUI_KeyBinder
end

local function InitializeCallback()
	TT:Initialize()
end

E:RegisterModule(TT:GetName(), InitializeCallback)