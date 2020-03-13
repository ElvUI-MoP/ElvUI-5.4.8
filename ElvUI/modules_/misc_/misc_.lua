local E, L, V, P, G = unpack(select(2, ...))
local M = E:NewModule("Misc", "AceEvent-3.0", "AceTimer-3.0")
E.Misc = M

local format, gsub = string.format, string.gsub

local UnitGUID = UnitGUID
local UnitInRaid = UnitInRaid
local IsInGroup, IsInRaid = IsInGroup, IsInRaid
local IsPartyLFG, IsInInstance = IsPartyLFG, IsInInstance
local SendChatMessage = SendChatMessage
local IsShiftKeyDown = IsShiftKeyDown
local CanMerchantRepair = CanMerchantRepair
local GetRepairAllCost = GetRepairAllCost
local GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney
local CanGuildBankRepair = CanGuildBankRepair
local RepairAllItems = RepairAllItems
local InCombatLockdown = InCombatLockdown
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local UninviteUnit = UninviteUnit
local UnitName = UnitName
local GetCoinTextureString = GetCoinTextureString
local GetUnitSpeed = GetUnitSpeed
local LeaveParty = LeaveParty
local RaidNotice_AddMessage = RaidNotice_AddMessage
local GetNumFriends = GetNumFriends
local ShowFriends = ShowFriends
local IsInGuild = IsInGuild
local GuildRoster = GuildRoster
local GetFriendInfo = GetFriendInfo
local AcceptGroup = AcceptGroup
local GetNumGuildMembers = GetNumGuildMembers
local GetGuildRosterInfo = GetGuildRosterInfo
local BNGetNumFriends = BNGetNumFriends
local BNGetFriendInfo = BNGetFriendInfo
local StaticPopup_Hide = StaticPopup_Hide
local GetCVarBool, SetCVar = GetCVarBool, SetCVar
local UIErrorsFrame = UIErrorsFrame
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS

local interruptMsg = INTERRUPTED.." %s's \124cff71d5ff\124Hspell:%d\124h[%s]\124h\124r!"

function M:ErrorFrameToggle(event)
	if not E.db.general.hideErrorFrame then return end

	if event == "PLAYER_REGEN_DISABLED" then
		UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	else
		UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
	end
end


function M:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, spellID, spellName)
	if E.db.general.interruptAnnounce == "NONE" then return end 
	if not (event == "SPELL_INTERRUPT" and (sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet"))) then return end

	if E.db.general.interruptAnnounce == "SAY" then
		SendChatMessage(format(interruptMsg, destName, spellID, spellName), "SAY")
	elseif E.db.general.interruptAnnounce == "EMOTE" then
		SendChatMessage(format(interruptMsg, destName, spellID, spellName), "EMOTE")
	else
		local inGroup, inRaid, inPartyLFG = IsInGroup(), IsInRaid(), IsPartyLFG()
		if not inGroup then return end

		if E.db.general.interruptAnnounce == "PARTY" then
			SendChatMessage(format(interruptMsg, destName, spellID, spellName), inPartyLFG and "INSTANCE_CHAT" or "PARTY")
		elseif E.db.general.interruptAnnounce == "RAID" then
			if inRaid then
				SendChatMessage(format(interruptMsg, destName, spellID, spellName), inPartyLFG and "INSTANCE_CHAT" or "RAID")
			else
				SendChatMessage(format(interruptMsg, destName, spellID, spellName), inPartyLFG and "INSTANCE_CHAT" or "PARTY")
			end
		elseif E.db.general.interruptAnnounce == "RAID_ONLY" then
			if inRaid then
				SendChatMessage(format(interruptMsg, destName, spellID, spellName), inPartyLFG and "INSTANCE_CHAT" or "RAID")
			end
		end
	end
end

function M:MERCHANT_SHOW()
	if E.db.bags.vendorGrays.enable then
		E:GetModule("Bags"):VendorGrays(nil, true)
	end

	local autoRepair = E.db.general.autoRepair
	if IsShiftKeyDown() or autoRepair == "NONE" or not CanMerchantRepair() then return end

	local cost, possible = GetRepairAllCost()
	local withdrawLimit = GetGuildBankWithdrawMoney()
	if autoRepair == "GUILD" and (not CanGuildBankRepair() or cost > withdrawLimit) then
		autoRepair = "PLAYER"
	end

	if cost > 0 then
		if possible then
			RepairAllItems(autoRepair == "GUILD")

			if autoRepair == "GUILD" then
				E:Print(L["Your items have been repaired using guild bank funds for: "]..GetCoinTextureString(cost, 12))
			else
				E:Print(L["Your items have been repaired for: "]..GetCoinTextureString(cost, 12))
			end
		else
			E:Print(L["You don't have enough money to repair."])
		end
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

function M:CheckMovement()
	if not WorldMapFrame:IsShown() then return end

	if GetUnitSpeed("player") ~= 0 then
		if WorldMapPositioningGuide:IsMouseOver() then
			WorldMapFrame:SetAlpha(1)
		else
			WorldMapFrame:SetAlpha(E.global.general.mapAlphaWhenMoving)
		end
	else
		WorldMapFrame:SetAlpha(1)
	end
end

function M:UpdateMapAlpha()
	if (E.global.general.mapAlphaWhenMoving >= 1) and self.MovingTimer then
		self:CancelTimer(self.MovingTimer)
		self.MovingTimer = nil
	elseif (E.global.general.mapAlphaWhenMoving < 1) and not self.MovingTimer then
		self.MovingTimer = self:ScheduleRepeatingTimer("CheckMovement", 0.1)
	end
end

function M:PVPMessageEnhancement(_, msg)
	if not E.db.general.enhancedPvpMessages then return end

	local _, instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then
		RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["RAID_BOSS_EMOTE"])
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
		if GetNumFriends() > 0 then ShowFriends() end
		if IsInGuild() then GuildRoster() end
		local inGroup = false

		for friendIndex = 1, GetNumFriends() do
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
					inGroup = true
					break
				end
			end
		end

		if not inGroup then
			for bnIndex = 1, BNGetNumFriends() do
				local _, _, _, name = BNGetFriendInfo(bnIndex)
				leaderName = leaderName:match("(.+)%-.+") or leaderName
				if name == leaderName then
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

function M:PLAYER_ENTERING_WORLD()
	self:ForceCVars()
	self:ToggleChatBubbleScript()
end

function M:Kill()

end

function M:Initialize()
	M:ScheduleTimer("Kill", 8)

	self:LoadRaidMarker()
	self:LoadLoot()
	self:LoadLootRoll()
	self:LoadChatBubbles()
	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "ErrorFrameToggle")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "ErrorFrameToggle")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "PVPMessageEnhancement")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "PVPMessageEnhancement")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL", "PVPMessageEnhancement")
	self:RegisterEvent("PARTY_INVITE_REQUEST", "AutoInvite")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "AutoInvite")
	self:RegisterEvent("CVAR_UPDATE", "ForceCVars")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	if E.global.general.mapAlphaWhenMoving < 1 then
		self.MovingTimer = self:ScheduleRepeatingTimer("CheckMovement", 0.1)
	end
end

local function InitializeCallback()
	M:Initialize()
end

E:RegisterModule(M:GetName(), InitializeCallback)