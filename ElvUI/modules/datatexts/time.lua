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

local timeDisplayFormat = "";
local dateDisplayFormat = "";
local europeDisplayFormat_nocolor = join("", "%02d", ":|r%02d")
local lockoutInfoFormat = "%s%s |cffaaaaaa(%s, |cfff04000%s/%s|r|cffaaaaaa)"
local formatBattleGroundInfo = "%s: "
local difficultyInfo = {"N", "N", "H", "H"};
local lockoutColorExtended, lockoutColorNormal = {r = 0.3, g = 1, b = 0.3}, {r = 0.8, g = 0.8, b = 0.8};
local enteredFrame = false;

local localizedName, isActive, canQueue, startTime, canEnter, _

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

local function OnEvent(_, event)
	if(event == "UPDATE_INSTANCE_INFO" and enteredFrame) then
		RequestRaidInfo();
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self)
	enteredFrame = true;
	DT.tooltip:AddLine(VOICE_CHAT_BATTLEGROUND);
	local localizedName, isActive, canQueue, startTime, canEnter
	for i = 1, GetNumWorldPVPAreas() do
		_, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(i)
		if(canEnter) then
			if(isActive) then
				startTime = WINTERGRASP_IN_PROGRESS
			elseif startTime == nil then
				startTime = QUEUE_TIME_UNAVAILABLE
			else
				startTime = SecondsToTime(startTime, false, nil, 3)
			end
			DT.tooltip:AddDoubleLine(format(formatBattleGroundInfo, localizedName), startTime, 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
		end
	end

	local name, _, reset, difficultyId, locked, extended, isRaid, maxPlayers, difficulty, numEncounters, encounterProgress
	local oneraid, lockoutColor
	for i = 1, GetNumSavedInstances() do
		name, _, reset, difficulty, locked, extended, _, isRaid, maxPlayers, _, numEncounters, encounterProgress  = GetSavedInstanceInfo(i)
		if(isRaid and (locked or extended)) then
			local tr,tg,tb,diff
			if(not oneraid) then
				DT.tooltip:AddLine(" ")
				DT.tooltip:AddLine(L["Saved Raid(s)"])
				oneraid = true
			end
			if extended then lockoutColor = lockoutColorExtended else lockoutColor = lockoutColorNormal end
			DT.tooltip:AddDoubleLine(format(lockoutInfoFormat, maxPlayers, difficultyInfo[difficulty], name, encounterProgress, numEncounters), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
		end
	end

	DT.tooltip:AddLine(" ")

	DT.tooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, format(europeDisplayFormat_nocolor, GetGameTime()), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b);

	DT.tooltip:Show()
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