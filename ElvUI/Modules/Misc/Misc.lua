local E, L, V, P, G = unpack(select(2, ...))
local M = E:GetModule("Misc")
local Bags = E:GetModule("Bags")

local format, gsub = string.format, string.gsub

local AcceptGroup = AcceptGroup
local CanGuildBankRepair = CanGuildBankRepair
local CanMerchantRepair = CanMerchantRepair
local GetCVarBool, SetCVar = GetCVarBool, SetCVar
local GetFriendInfo = GetFriendInfo
local GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney
local GetGuildRosterInfo = GetGuildRosterInfo
local GetItemInfo = GetItemInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetNumFriends = GetNumFriends
local GetNumGuildMembers = GetNumGuildMembers
local GetNumQuestChoices = GetNumQuestChoices
local GetNumPartyMembers = GetNumPartyMembers
local GetQuestItemInfo = GetQuestItemInfo
local GetQuestItemLink = GetQuestItemLink
local GetRaidRosterInfo = GetRaidRosterInfo
local GetRepairAllCost = GetRepairAllCost
local GuildRoster = GuildRoster
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local IsInGroup, IsInRaid = IsInGroup, IsInRaid
local IsInInstance = IsInInstance
local IsPartyLFG = IsPartyLFG
local IsShiftKeyDown = IsShiftKeyDown
local LeaveParty = LeaveParty
local RaidNotice_AddMessage = RaidNotice_AddMessage
local ShowFriends = ShowFriends
local StaticPopup_Hide = StaticPopup_Hide
local RepairAllItems = RepairAllItems
local SendChatMessage = SendChatMessage
local UninviteUnit = UninviteUnit
local UnitExists = UnitExists
local UnitInRaid = UnitInRaid
local UnitGUID = UnitGUID
local UnitName = UnitName
local UIErrorsFrame = UIErrorsFrame

local ERR_NOT_ENOUGH_MONEY = ERR_NOT_ENOUGH_MONEY
local ERR_GUILD_NOT_ENOUGH_MONEY = ERR_GUILD_NOT_ENOUGH_MONEY
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS

local INTERRUPT_MSG = L["Interrupted %s's \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r!"]

function M:ErrorFrameToggle(event)
	if not E.db.general.hideErrorFrame then return end

	if event == "PLAYER_REGEN_DISABLED" then
		UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	else
		UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
	end
end

function M:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, _, _, _, spellID, spellName)
	local announce = event == "SPELL_INTERRUPT" and (sourceGUID == E.myguid or sourceGUID == UnitGUID("pet")) and destGUID ~= E.myguid
	if not announce then return end -- No announce-able interrupt from player or pet, exit.

	local channel, msg = E.db.general.interruptAnnounce, format(INTERRUPT_MSG, destName, spellID, spellName)
	if channel == "NONE" then return end

	if channel == "SAY" then
		SendChatMessage(msg, "SAY")
	elseif channel == "EMOTE" then
		SendChatMessage(msg, "EMOTE")
	else
		local inGroup, inRaid, inPartyLFG = IsInGroup(), IsInRaid(), IsPartyLFG()
		if not inGroup then return end

		if channel == "PARTY" then
			SendChatMessage(format(interruptMsg, destName, spellID, spellName), inPartyLFG and "INSTANCE_CHAT" or "PARTY")
		elseif channel == "RAID" then
			if inRaid then
				SendChatMessage(format(interruptMsg, destName, spellID, spellName), inPartyLFG and "INSTANCE_CHAT" or "RAID")
			else
				SendChatMessage(format(interruptMsg, destName, spellID, spellName), inPartyLFG and "INSTANCE_CHAT" or "PARTY")
			end
		elseif channel == "RAID_ONLY" then
			if inRaid then
				SendChatMessage(format(interruptMsg, destName, spellID, spellName), inPartyLFG and "INSTANCE_CHAT" or "RAID")
			end
		end
	end
end

function M:COMBAT_TEXT_UPDATE(event, ...)
	if not E.db.general.autoTrackReputation then return end

	local messagetype, faction = ...
	if messagetype == "FACTION" then
		if faction ~= "Guild" and faction ~= GetWatchedFactionInfo() then
			ExpandAllFactionHeaders()
			for i = 1, GetNumFactions() do
				if faction == GetFactionInfo(i) then
					SetWatchedFactionIndex(i)
					break
				end
			end
		end
	end
end

do -- Auto Repair Functions
	local STATUS, TYPE, COST, POSS
	function M:AttemptAutoRepair(playerOverride)
		STATUS, TYPE, COST, POSS = "", E.db.general.autoRepair, GetRepairAllCost()

		if POSS and COST > 0 then
			--This check evaluates to true even if the guild bank has 0 gold, so we add an override
			if IsInGuild() and TYPE == "GUILD" and (playerOverride or (not CanGuildBankRepair() or COST > GetGuildBankWithdrawMoney())) then
				TYPE = "PLAYER"
			end

			RepairAllItems(TYPE == "GUILD")

			--Delay this a bit so we have time to catch the outcome of first repair attempt
			E:Delay(0.5, M.AutoRepairOutput)
		end
	end

	function M:AutoRepairOutput()
		if TYPE == "GUILD" then
			if STATUS == "GUILD_REPAIR_FAILED" then
				M:AttemptAutoRepair(true) --Try using player money instead
			else
				E:Print(L["Your items have been repaired using guild bank funds for: "]..E:FormatMoney(COST, "SMART", true)) --Amount, style, textOnly
			end
		elseif TYPE == "PLAYER" then
			if STATUS == "PLAYER_REPAIR_FAILED" then
				E:Print(L["You don't have enough money to repair."])
			else
				E:Print(L["Your items have been repaired for: "]..E:FormatMoney(COST, "SMART", true)) --Amount, style, textOnly
			end
		end
	end

	function M:UI_ERROR_MESSAGE(_, messageType)
		if messageType == ERR_GUILD_NOT_ENOUGH_MONEY then
			STATUS = "GUILD_REPAIR_FAILED"
		elseif messageType == ERR_NOT_ENOUGH_MONEY then
			STATUS = "PLAYER_REPAIR_FAILED"
		end
	end
end

function M:MERCHANT_CLOSED()
	self:UnregisterEvent("UI_ERROR_MESSAGE")
	self:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:UnregisterEvent("MERCHANT_CLOSED")
end

function M:MERCHANT_SHOW()
	if E.db.bags.vendorGrays.enable then E:Delay(0.5, Bags.VendorGrays, Bags) end

	if E.db.general.autoRepair == "NONE" or IsShiftKeyDown() or not CanMerchantRepair() then return end

	--Prepare to catch "not enough money" messages
	self:RegisterEvent("UI_ERROR_MESSAGE")

	--Use this to unregister events afterwards
	self:RegisterEvent("MERCHANT_CLOSED")

	M:AttemptAutoRepair()
end

function M:RESURRECT_REQUEST()
	if not E.db.general.resurrectSound then return end

	PlaySoundFile(E.Media.Sounds.ThanksForPlaying)
end

function M:ADDON_LOADED(_, addon)
	if addon == "Blizzard_InspectUI" then
		M:SetupInspectPageInfo()
	end
end

function M:DisbandRaidGroup()
	if InCombatLockdown() then return end -- Prevent user error in combat

	if UnitInRaid("player") then
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online and name ~= E.myname then
				UninviteUnit(name)
			end
		end
	else
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			if UnitExists("party"..i) then
				UninviteUnit(UnitName("party"..i))
			end
		end
	end

	LeaveParty()
end

function M:PVPMessageEnhancement(_, msg)
	if not E.db.general.enhancedPvpMessages then return end

	local _, instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then
		RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo.RAID_BOSS_EMOTE)
	end
end

local hideStatic = false
function M:AutoInvite(event, leaderName)
	if not E.db.general.autoAcceptInvite then return end

	if event == "PARTY_INVITE_REQUEST" then
		if QueueStatusMinimapButton:IsShown() then return end
		if IsInGroup() then return end
		hideStatic = true

		-- Update Guild and Friendlist
		local numFriends = GetNumFriends()
		if numFriends > 0 then ShowFriends() end
		if IsInGuild() then GuildRoster() end
		local inGroup = false

		for friendIndex = 1, numFriends do
			local friendName = gsub(GetFriendInfo(friendIndex), "-.*", "")
			if friendName == leaderName then
				AcceptGroup()
				inGroup = true
				break
			end
		end

		if not inGroup then
			for guildIndex = 1, GetNumGuildMembers(true) do
				local guildMemberName = gsub(GetGuildRosterInfo(guildIndex), "-.*", "")
				if guildMemberName == leaderName then
					AcceptGroup()
					break
				end
			end
		end
	elseif event == "GROUP_ROSTER_UPDATE" and hideStatic == true then
		StaticPopup_Hide("PARTY_INVITE")
		hideStatic = false
	end
end

function M:ForceCVars()
	if not GetCVarBool("lockActionBars") and E.private.actionbar.enable then
		SetCVar("lockActionBars", 1)
	end
end

function M:QUEST_COMPLETE()
	if not E.db.general.questRewardMostValueIcon then return end
	if not QuestInfoItem1 then return end

	local numQuests = GetNumQuestChoices()
	if numQuests < 2 then return end

	local bestValue, bestItem = 0
	for i = 1, numQuests do
		local questLink = GetQuestItemLink("choice", i)
		local _, _, amount = GetQuestItemInfo("choice", i)
		local itemSellPrice = questLink and select(11, GetItemInfo(questLink))
		local totalValue = (itemSellPrice and itemSellPrice * amount) or 0

		if totalValue > bestValue then
			bestValue = totalValue
			bestItem = i
		end
	end

	if bestItem then
		local btn = _G["QuestInfoItem"..bestItem]
		if btn and btn.type == "choice" then
			M.QuestRewardGoldIconFrame:ClearAllPoints()
			M.QuestRewardGoldIconFrame:Point("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
			M.QuestRewardGoldIconFrame:Show()
		end
	end
end

function M:Initialize()
	self:LoadRaidMarker()
	self:LoadLoot()
	self:LoadLootRoll()
	self:LoadChatBubbles()
	self:ToggleItemLevelInfo(true)

	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("RESURRECT_REQUEST")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "ErrorFrameToggle")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "ErrorFrameToggle")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "PVPMessageEnhancement")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "PVPMessageEnhancement")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL", "PVPMessageEnhancement")
	self:RegisterEvent("PARTY_INVITE_REQUEST", "AutoInvite")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "AutoInvite")
	self:RegisterEvent("CVAR_UPDATE", "ForceCVars")
	self:RegisterEvent("COMBAT_TEXT_UPDATE")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ForceCVars")
	self:RegisterEvent("QUEST_COMPLETE")

	do	-- questRewardMostValueIcon
		local MostValue = CreateFrame("Frame", "ElvUI_QuestRewardGoldIconFrame", UIParent)
		MostValue:SetFrameStrata("HIGH")
		MostValue:Size(14)
		MostValue:Hide()

		MostValue.Icon = MostValue:CreateTexture(nil, "OVERLAY")
		MostValue.Icon:SetAllPoints(MostValue)
		MostValue.Icon:SetTexture([[Interface\MONEYFRAME\UI-GoldIcon]])

		M.QuestRewardGoldIconFrame = MostValue

		hooksecurefunc(QuestFrameRewardPanel, "Hide", function()
			if M.QuestRewardGoldIconFrame then
				M.QuestRewardGoldIconFrame:Hide()
			end
		end)
	end

	if IsAddOnLoaded("Blizzard_InspectUI") then
		M:SetupInspectPageInfo()
	else
		self:RegisterEvent("ADDON_LOADED")
	end

	self.Initialized = true
end

local function InitializeCallback()
	M:Initialize()
end

E:RegisterModule(M:GetName(), InitializeCallback)