local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts")

local time = time;
local format, join = string.format, string.join

local GetGameTime = GetGameTime
local RequestRaidInfo = RequestRaidInfo
local GetNumWorldPVPAreas = GetNumWorldPVPAreas
local GetWorldPVPAreaInfo = GetWorldPVPAreaInfo
local SecondsToTime = SecondsToTime
local GetNumSavedInstances = GetNumSavedInstances
local GetSavedInstanceInfo = GetSavedInstanceInfo
local VOICE_CHAT_BATTLEGROUND = VOICE_CHAT_BATTLEGROUND
local WINTERGRASP_IN_PROGRESS = WINTERGRASP_IN_PROGRESS
local QUEUE_TIME_UNAVAILABLE = QUEUE_TIME_UNAVAILABLE
local TIMEMANAGER_TOOLTIP_REALMTIME = TIMEMANAGER_TOOLTIP_REALMTIME
local RAID_INFO_WORLD_BOSS = RAID_INFO_WORLD_BOSS

local timeDisplayFormat = "";
local dateDisplayFormat = "";
local europeDisplayFormat_nocolor = join("", "%02d", ":|r%02d")
local lockoutInfoFormat = "%s%s |cffaaaaaa(%s, |cfff04000%s/%s|r|cffaaaaaa)"
local lockoutInfoFormatNoEnc = "%s%s |cffaaaaaa(%s)"
local formatBattleGroundInfo = "%s: "
local difficultyInfo = {"N", "N", "H", "H"};
local lockoutColorExtended, lockoutColorNormal = {r = 0.3, g = 1, b = 0.3}, {r = 0.8, g = 0.8, b = 0.8};
local enteredFrame = false;

local localizedName, isActive, startTime, canEnter, _
local name, reset, difficultyId, locked, extended, isRaid, maxPlayers, numEncounters, encounterProgress

local function OnClick(_, btn)
	if(btn == "RightButton") then
	if(not IsAddOnLoaded("Blizzard_TimeManager")) then LoadAddOn("Blizzard_TimeManager"); end
 		TimeManagerClockButton_OnClick(TimeManagerClockButton);
 	else
 		GameTimeFrame:Click();
 	end
end

local function OnLeave()
	DT.tooltip:Hide();
	enteredFrame = false;
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	if(not enteredFrame) then
		enteredFrame = true;
		RequestRaidInfo()
	end

	DT.tooltip:AddLine(VOICE_CHAT_BATTLEGROUND);
	for i = 1, GetNumWorldPVPAreas() do
		_, localizedName, isActive, _, startTime, canEnter = GetWorldPVPAreaInfo(i)
		if canEnter then
			if isActive then
				startTime = WINTERGRASP_IN_PROGRESS
			elseif startTime == nil then
				startTime = QUEUE_TIME_UNAVAILABLE
			else
				startTime = SecondsToTime(startTime, false, nil, 3)
			end
			DT.tooltip:AddDoubleLine(format(formatBattleGroundInfo, localizedName), startTime, 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
		end
	end

	local oneraid, lockoutColor
	for i = 1, GetNumSavedInstances() do
		name, _, reset, difficultyId, locked, extended, _, isRaid, maxPlayers, _, numEncounters, encounterProgress  = GetSavedInstanceInfo(i)
		if isRaid and (locked or extended) and name then
			if not oneraid then
				DT.tooltip:AddLine(" ")
				DT.tooltip:AddLine(L["Saved Raid(s)"])
				oneraid = true
			end
			if extended then
				lockoutColor = lockoutColorExtended
			else
				lockoutColor = lockoutColorNormal
			end

			local _, _, isHeroic = GetDifficultyInfo(difficultyId)
			if(numEncounters and numEncounters > 0) and (encounterProgress and encounterProgress > 0) then
				DT.tooltip:AddDoubleLine(format(lockoutInfoFormat, maxPlayers, (isHeroic and "H" or "N"), name, encounterProgress, numEncounters), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			else
				DT.tooltip:AddDoubleLine(format(lockoutInfoFormatNoEnc, maxPlayers, (isHeroic and "H" or "N"), name), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			end
		end
	end

	local addedLine = false
	for i = 1, GetNumSavedWorldBosses() do
		name, _, reset = GetSavedWorldBossInfo(i)
		if(reset) then
			if(not addedLine) then
				DT.tooltip:AddLine(" ")
				DT.tooltip:AddLine(RAID_INFO_WORLD_BOSS.."(s)")
				addedLine = true
			end
			DT.tooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, 0.8, 0.8, 0.8)
		end
	end

	DT.tooltip:AddLine(" ")

	DT.tooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, format(europeDisplayFormat_nocolor, GetGameTime()), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b);

	DT.tooltip:Show()
end

local function OnEvent(self, event)
	if event == "UPDATE_INSTANCE_INFO" and enteredFrame then
		OnEnter(self)
	end
end

local lastPanel;
local int = 5
function OnUpdate(self, t)
	int = int - t

	if(int > 0) then return end

	if(GameTimeFrame.flashInvite) then
		E:Flash(self, 0.53, true)
	else
		E:StopFlash(self)
	end

	if(enteredFrame) then
		OnEnter(self)
	end

	self.text:SetText(BetterDate(E.db.datatexts.timeFormat .. " " .. E.db.datatexts.dateFormat, time()):gsub(":", timeDisplayFormat):gsub("%s", dateDisplayFormat));

	lastPanel = self
	int = 1
end

local function ValueColorUpdate(hex)
	timeDisplayFormat = join("", hex, ":|r");
	dateDisplayFormat = join("", hex, " ");

	if(lastPanel ~= nil) then
		OnUpdate(lastPanel, 20000)
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true

DT:RegisterDatatext("Time", {"UPDATE_INSTANCE_INFO"}, OnEvent, OnUpdate, OnClick, OnEnter, OnLeave)