local E, L, V, P, G = unpack(select(2, ...))
local B = E:GetModule("Blizzard")
local Misc = E:GetModule("Misc")

local _G = _G
local pairs = pairs

local AlertFrame_FixAnchors = AlertFrame_FixAnchors
local NUM_GROUP_LOOT_FRAMES = NUM_GROUP_LOOT_FRAMES

local POSITION, ANCHOR_POINT, YOFFSET = "TOP", "BOTTOM", -10

function E:PostAlertMove(screenQuadrant)
	local _, y = AlertFrameMover:GetCenter()
	local screenHeight = E.UIParent:GetTop()

	if y > (screenHeight / 2) then
		POSITION = "TOP"
		ANCHOR_POINT = "BOTTOM"
		YOFFSET = -10
		AlertFrameMover:SetText(AlertFrameMover.textString.." [Grow Down]")
	else
		POSITION = "BOTTOM"
		ANCHOR_POINT = "TOP"
		YOFFSET = 10
		AlertFrameMover:SetText(AlertFrameMover.textString.." [Grow Up]")
	end

	local rollBars = Misc.RollBars
	if E.private.general.lootRoll then
		local lastframe, lastShownFrame

		for i, frame in pairs(rollBars) do
			frame:ClearAllPoints()
			if i ~= 1 then
				if POSITION == "TOP" then
					frame:Point("TOP", lastframe, "BOTTOM", 0, -4)
				else
					frame:Point("BOTTOM", lastframe, "TOP", 0, 4)
				end
			else
				if POSITION == "TOP" then
					frame:Point("TOP", AlertFrameHolder, "BOTTOM", 0, -4)
				else
					frame:Point("BOTTOM", AlertFrameHolder, "TOP", 0, 4)
				end
			end
			lastframe = frame

			if frame:IsShown() then
				lastShownFrame = frame
			end
		end

		AlertFrame:ClearAllPoints()
		if lastShownFrame then
			AlertFrame:SetAllPoints(lastShownFrame)
		else
			AlertFrame:SetAllPoints(AlertFrameHolder)
		end
	elseif E.private.skins.blizzard.enable and E.private.skins.blizzard.lootRoll then
		local lastframe, lastShownFrame
		for i = 1, NUM_GROUP_LOOT_FRAMES do
			local frame = _G["GroupLootFrame"..i]

			if frame then
				frame:ClearAllPoints()
				if i ~= 1 then
					if POSITION == "TOP" then
						frame:Point("TOP", lastframe, "BOTTOM", 0, -4)
					else
						frame:Point("BOTTOM", lastframe, "TOP", 0, 4)
					end
				else
					if POSITION == "TOP" then
						frame:Point("TOP", AlertFrameHolder, "BOTTOM", 0, -4)
					else
						frame:Point("BOTTOM", AlertFrameHolder, "TOP", 0, 4)
					end
				end
				lastframe = frame

				if frame:IsShown() then
					lastShownFrame = frame
				end
			end
		end

		AlertFrame:ClearAllPoints()
		if lastShownFrame then
			AlertFrame:SetAllPoints(lastShownFrame)
		else
			AlertFrame:SetAllPoints(AlertFrameHolder)
		end
	else
		AlertFrame:ClearAllPoints()
		AlertFrame:SetAllPoints(AlertFrameHolder)
	end

	if screenQuadrant then
		AlertFrame_FixAnchors()
	end
end

function B:AlertFrame_SetLootAnchors(alertAnchor)
	if MissingLootFrame:IsShown() then
		MissingLootFrame:ClearAllPoints()
		MissingLootFrame:Point(POSITION, alertAnchor, ANCHOR_POINT)

		if GroupLootContainer:IsShown() then
			GroupLootContainer:ClearAllPoints()
			GroupLootContainer:Point(POSITION, MissingLootFrame, ANCHOR_POINT, 0, YOFFSET)
		end
	elseif GroupLootContainer:IsShown() or FORCE_POSITION then
		GroupLootContainer:ClearAllPoints()
		GroupLootContainer:Point(POSITION, alertAnchor, ANCHOR_POINT)
	end
end

function B:AlertFrame_SetAchievementAnchors()
	local alertAnchor
	for i = 1, MAX_ACHIEVEMENT_ALERTS do
		local frame = _G["AchievementAlertFrame"..i]

		if frame then
			frame:ClearAllPoints()
			if alertAnchor and alertAnchor:IsShown() then
				frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
			else
				frame:Point(POSITION, AlertFrame, ANCHOR_POINT)
			end

			alertAnchor = frame
		end
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
			frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
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
	end
end

function B:AlertFrame_SetDungeonCompletionAnchors(alertAnchor)
	local frame = DungeonCompletionAlertFrame1

	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
	end
end

function B:AlertFrame_SetStorePurchaseAnchors(alertAnchor)
	local frame = StorePurchaseAlertFrame

	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
	end
end

function B:AlertFrame_SetScenarioAnchors(alertAnchor)
	local frame = ScenarioAlertFrame1

	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
	end
end

function B:AlertFrame_SetGuildChallengeAnchors(alertAnchor)
	local frame = GuildChallengeAlertFrame

	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
	end
end

function B:AlertFrame_SetDigsiteCompleteToastFrameAnchors(alertAnchor)
	local frame = DigsiteCompleteToastFrame

	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
	end
end

function B:AlertMovers()
	local AlertFrameHolder = CreateFrame("Frame", "AlertFrameHolder", E.UIParent)
	AlertFrameHolder:Width(180)
	AlertFrameHolder:Height(20)
	AlertFrameHolder:Point("TOP", E.UIParent, "TOP", 0, -18)

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