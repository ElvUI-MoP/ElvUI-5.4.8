local E, L, V, P, G = unpack(select(2, ...))
local mod = E:GetModule("RaidBrowser")

local twipe, tsort = table.wipe, table.sort
local format = string.format
local floor = math.floor

local SearchLFGGetResults_Old = SearchLFGGetResults
local sortOrderIlvl, sortOrderSpec = false, false
local ilvls, specs, idx = {}, {}, {}

local function SortByILevel(a, b)
	if sortOrderIlvl then
		return ilvls[a] < ilvls[b]
	else
		return ilvls[a] > ilvls[b]
	end
end

local function SortBySpec(a, b)
	if sortOrderSpec then
		return specs[a] < specs[b]
	else
		return specs[a] > specs[b]
	end
end

function mod:Button_OnEnter()
	local name, level, _, className, comment, partyMembers, _, _, encountersTotal, encountersComplete, isIneligible, _, isTank, isHealer, isDamage = SearchLFGGetResults(self.index)

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 50, 16)

	if partyMembers > 0 then
		GameTooltip:AddLine(LOOKING_FOR_RAID)

		GameTooltip:AddLine(name)
		GameTooltip:AddTexture("Interface\\LFGFrame\\LFGRole", 0, 0.25, 0, 1)
		GameTooltip:AddTexture("")

		GameTooltip:AddLine(format(LFM_NUM_RAID_MEMBER_TEMPLATE, partyMembers))
		if comment and comment ~= "" then
			GameTooltip:AddLine(comment, 1, 1, 1, 1)
		end

		local groupILevel = 0
		local groupMembers = 0
		local displayedMembersLabel = false
		local classTextColor

		for i = 0, partyMembers do
			local memberName, _, _, className, _, _, _, isTank, isHealer, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, avgILevel = SearchLFGGetPartyResults(self.index, i)

			if avgILevel and avgILevel > 0 then
				groupILevel = groupILevel + avgILevel
				groupMembers = groupMembers + 1
			end

			if isTank or isHealer then
				if not displayedMembersLabel then
					displayedMembersLabel = true
					GameTooltip:AddLine("\n"..L["Important Group Members:"])
				end

				if className then
					local classFileName = E:UnlocalizedClassName(className)
					classTextColor = E:ClassColor(classFileName)
				else
					classTextColor = NORMAL_FONT_COLOR
				end

				if avgILevel and avgILevel > 0 then
					GameTooltip:AddDoubleLine(memberName, floor(avgILevel), classTextColor.r, classTextColor.g, classTextColor.b, 1, 1, 1)
				else
					GameTooltip:AddDoubleLine(memberName, "??", classTextColor.r, classTextColor.g, classTextColor.b, 1, 1, 1)
				end

				if isTank then
					GameTooltip:AddTexture("Interface\\LFGFrame\\LFGRole", 0.5, 0.75, 0, 1)
				end
				if isHealer then
					GameTooltip:AddTexture("Interface\\LFGFrame\\LFGRole", 0.75, 1, 0, 1)
				end
			end
		end

		if groupILevel > 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(L["Average Group iLvl:"], floor(groupILevel / groupMembers), nil, nil, nil, 1, 1, 1)
		end
	else
		GameTooltip:AddLine(name)
		GameTooltip:AddLine(format(FRIENDS_LEVEL_TEMPLATE, level, className))

		if comment and comment ~= "" then
			GameTooltip:AddLine("\n"..comment, 1, 1, 1, 1)
		end
	end

	if partyMembers == 0 then
		GameTooltip:AddLine("\n"..LFG_TOOLTIP_ROLES)

		if isTank then
			GameTooltip:AddLine(TANK)
			GameTooltip:AddTexture("Interface\\LFGFrame\\LFGRole", 0.5, 0.75, 0, 1)
		end
		if isHealer then
			GameTooltip:AddLine(HEALER)
			GameTooltip:AddTexture("Interface\\LFGFrame\\LFGRole", 0.75, 1, 0, 1)
		end
		if isDamage then
			GameTooltip:AddLine(DAMAGER)
			GameTooltip:AddTexture("Interface\\LFGFrame\\LFGRole", 0.25, 0.5, 0, 1)
		end
	end

	if encountersComplete > 0 or isIneligible then
		GameTooltip:AddLine("\n"..BOSSES)

		for i = 1, encountersTotal do
			local bossName, _, isKilled, isIneligible = SearchLFGGetEncounterResults(self.index, i)

			if isKilled then
				GameTooltip:AddDoubleLine(bossName, BOSS_DEAD, 1, 0, 0, 1, 0, 0)
			elseif isIneligible then
				GameTooltip:AddDoubleLine(bossName, BOSS_ALIVE_INELIGIBLE, 0, 1, 0, 0, 1, 0)
			else
				GameTooltip:AddDoubleLine(bossName, BOSS_ALIVE, 0, 1, 0, 0, 1, 0)
			end
		end
	elseif partyMembers > 0 and encountersTotal > 0 then
		GameTooltip:AddLine("\n"..ALL_BOSSES_ALIVE)
	end

	GameTooltip:Show()
end

function mod:LFRBrowseFrameListButton_SetData(button, index)
	local name, level, _, _, _, _, _, class, _, _, _, _, _, _, _, _, specID, _, _, _, _, _, _, _, _, _, _, _, _, _, _, avgILevel = SearchLFGGetResults(index)

	local classTextColor
	if class then
		classTextColor = E:ClassColor(class)
	else
		classTextColor = NORMAL_FONT_COLOR
	end

	button.name:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
	button.level:SetText(format("%.0f", avgILevel))

	if specID and specID > 0 then
		button.class:SetText(select(2, GetSpecializationInfoByID(specID)))
	end
end

function mod:SearchLFGSort()
	if self.sortType == "level" then
		sortOrderIlvl = not sortOrderIlvl
		SearchLFGGetResults = mod.SearchLFGGetResultsILVL

		if LFRBrowseFrame:IsVisible() then
			LFRBrowseFrameList_Update(true)
		end
	elseif self.sortType == "class" then
		sortOrderSpec = not sortOrderSpec
		SearchLFGGetResults = mod.SearchLFGGetResultsSpec

		if LFRBrowseFrame:IsVisible() then
			LFRBrowseFrameList_Update(true)
		end
	else
		SearchLFGGetResults = SearchLFGGetResults_Old

		if self.sortType then
			SearchLFGSort(self.sortType)
		end
	end

	PlaySound("igMainMenuOptionCheckBoxOn")
end

function mod:SearchLFGGetResultsSpec()
	local numResults, totalResults = SearchLFGGetNumResults()

	twipe(idx)
	twipe(specs)

	for i = 1, numResults do
		specs[i] = select(2, GetSpecializationInfoByID(select(17, SearchLFGGetResults_Old(i))))
		idx[i] = i
	end

	tsort(idx, SortBySpec)

	return SearchLFGGetResults_Old(idx[self])
end

function mod:SearchLFGGetResultsILVL()
	local numResults = SearchLFGGetNumResults()

	twipe(idx)
	twipe(ilvls)

	for i = 1, numResults do
		ilvls[i] = select(32, SearchLFGGetResults_Old(i))
		idx[i] = i
	end

	tsort(idx, SortByILevel)

	return SearchLFGGetResults_Old(idx[self])
end

function mod:Initialize()
	if not E.private.general.lfrEnhancement then return end

	for i = 1, NUM_LFR_LIST_BUTTONS do
		local button = _G["LFRBrowseFrameListButton"..i]

		button:SetScript("OnEnter", self.Button_OnEnter)
		button.level:SetWidth(22)
	end

	for i = 1, 7 do
		_G["LFRBrowseFrameColumnHeader"..i]:SetScript("OnClick", self.SearchLFGSort)
	end

	LFRBrowseFrameColumnHeader2:SetText(L["iLvl"])
	LFRBrowseFrameColumnHeader3:SetText(L["Talent Spec"])

	self:SecureHook("LFRBrowseFrameListButton_SetData")
end

local function InitializeCallback()
	mod:Initialize()
end

E:RegisterModule(mod:GetName(), InitializeCallback)