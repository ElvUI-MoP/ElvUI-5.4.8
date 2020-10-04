local E, L, V, P, G = unpack(select(2, ...))
local B = E:GetModule("Blizzard")
local Misc = E:GetModule("Misc")

local _G = _G
local pairs = pairs
local format = format

local POSITION, ANCHOR_POINT, YOFFSET = "TOP", "BOTTOM", -10

function E:PostAlertMove()
	local _, y = AlertFrameMover:GetCenter()
	local screenHeight = E.UIParent:GetTop()
	local screenY = y > (screenHeight / 2)

	POSITION = screenY and "TOP" or "BOTTOM"
	ANCHOR_POINT = screenY and "BOTTOM" or "TOP"
	YOFFSET = screenY and -10 or 10

	local directionText = screenY and "(Grow Down)" or "(Grow Up)"
	AlertFrameMover:SetText(format("%s %s", AlertFrameMover.textString, directionText))

	if E.private.general.lootRoll then
		local lastframe, lastShownFrame

		for i, frame in pairs(Misc.RollBars) do
			local alertAnchor = i ~= 1 and lastframe or AlertFrameHolder
			local yOffset = screenY and -4 or 4

			frame:ClearAllPoints()
			frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, yOffset)

			lastframe = frame

			if frame:IsShown() then
				lastShownFrame = frame
			end
		end

		AlertFrame:ClearAllPoints()
		GroupLootContainer:ClearAllPoints()

		if lastShownFrame then
			AlertFrame:SetAllPoints(lastShownFrame)
			GroupLootContainer:Point(POSITION, lastShownFrame, ANCHOR_POINT, 0, YOFFSET)
		else
			AlertFrame:SetAllPoints(AlertFrameHolder)
			GroupLootContainer:Point(POSITION, AlertFrameHolder, ANCHOR_POINT, 0, YOFFSET)
		end
	else
		AlertFrame:ClearAllPoints()
		AlertFrame:SetAllPoints(AlertFrameHolder)

		GroupLootContainer:ClearAllPoints()
		GroupLootContainer:Point(POSITION, AlertFrameHolder, ANCHOR_POINT, 0, YOFFSET)
	end
end

function B:AlertFrame_SetLootAnchors(alertAnchor)
	if MissingLootFrame:IsShown() then
		MissingLootFrame:ClearAllPoints()
		MissingLootFrame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)

		if GroupLootContainer:IsShown() then
			GroupLootContainer:ClearAllPoints()
			GroupLootContainer:Point(POSITION, MissingLootFrame, ANCHOR_POINT, 0, YOFFSET)
		end
	elseif GroupLootContainer:IsShown() then
		GroupLootContainer:ClearAllPoints()
		GroupLootContainer:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
	end
end

function B:AlertFrame_SetStorePurchaseAnchors(alertAnchor)
	local frame = StorePurchaseAlertFrame

	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
		alertAnchor = frame
	end
end

function B:AlertFrame_SetLootWonAnchors(alertAnchor)
	for i = 1, #LOOT_WON_ALERT_FRAMES do
		local frame = LOOT_WON_ALERT_FRAMES[i]

		if frame:IsShown() then
			frame:ClearAllPoints()
			frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
			alertAnchor = frame
		end
	end
end

function B:AlertFrame_SetMoneyWonAnchors(alertAnchor)
	for i = 1, #MONEY_WON_ALERT_FRAMES do
		local frame = MONEY_WON_ALERT_FRAMES[i]

		if frame:IsShown() then
			frame:ClearAllPoints()
			frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
			alertAnchor = frame
		end
	end
end

function B:AlertFrame_SetAchievementAnchors(alertAnchor)
	for i = 1, MAX_ACHIEVEMENT_ALERTS do
		local frame = _G["AchievementAlertFrame"..i]

		if frame and frame:IsShown() then
			frame:ClearAllPoints()
			frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
			alertAnchor = frame
		end
	end
end

function B:AlertFrame_SetCriteriaAnchors(alertAnchor)
	if CriteriaAlertFrame1 then
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["CriteriaAlertFrame"..i]

			if frame and frame:IsShown() then
				frame:ClearAllPoints()
				frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
				alertAnchor = frame
			end
		end
	end
end

function B:AlertFrame_SetChallengeModeAnchors(alertAnchor)
	local frame = ChallengeModeAlertFrame1

	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
		alertAnchor = frame
	end
end

function B:AlertFrame_SetDungeonCompletionAnchors(alertAnchor)
	local frame = DungeonCompletionAlertFrame1

	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
		alertAnchor = frame
	end
end

function B:AlertFrame_SetScenarioAnchors(alertAnchor)
	local frame = ScenarioAlertFrame1

	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
		alertAnchor = frame
	end
end

function B:AlertFrame_SetGuildChallengeAnchors(alertAnchor)
	local frame = GuildChallengeAlertFrame

	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
		alertAnchor = frame
	end
end

function B:AlertFrame_SetDigsiteCompleteToastFrameAnchors(alertAnchor)
	local frame = DigsiteCompleteToastFrame

	if frame and frame:IsShown() then
		frame:ClearAllPoints()
		frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
		alertAnchor = frame
	end
end

function B:AlertMovers()
	local AlertFrameHolder = CreateFrame("Frame", "AlertFrameHolder", E.UIParent)
	AlertFrameHolder:Size(250, 20)
	AlertFrameHolder:Point("TOP", E.UIParent, "TOP", 0, -18)

	UIPARENT_MANAGED_FRAME_POSITIONS.GroupLootContainer = nil

	self:SecureHook("AlertFrame_FixAnchors", E.PostAlertMove)
	self:SecureHook("AlertFrame_SetLootAnchors")
	self:SecureHook("AlertFrame_SetStorePurchaseAnchors")
	self:SecureHook("AlertFrame_SetLootWonAnchors")
	self:SecureHook("AlertFrame_SetMoneyWonAnchors")
	self:SecureHook("AlertFrame_SetAchievementAnchors")
	self:SecureHook("AlertFrame_SetCriteriaAnchors")
	self:SecureHook("AlertFrame_SetChallengeModeAnchors")
	self:SecureHook("AlertFrame_SetDungeonCompletionAnchors")
	self:SecureHook("AlertFrame_SetScenarioAnchors")
	self:SecureHook("AlertFrame_SetGuildChallengeAnchors")
	self:SecureHook("AlertFrame_SetDigsiteCompleteToastFrameAnchors")

	E:CreateMover(AlertFrameHolder, "AlertFrameMover", L["Loot / Alert Frames"], nil, nil, E.PostAlertMove, nil, nil, "general,general")
end