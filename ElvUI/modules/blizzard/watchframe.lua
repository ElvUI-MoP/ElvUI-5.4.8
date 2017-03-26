local E, L, DF = unpack(select(2, ...));
local B = E:GetModule("Blizzard");

local min = math.min

local hooksecurefunc = hooksecurefunc;
local GetScreenWidth = GetScreenWidth;
local GetScreenHeight = GetScreenHeight;

local WatchFrameHolder = CreateFrame("Frame", "WatchFrameHolder", E.UIParent);
WatchFrameHolder:Size(207, 22);
WatchFrameHolder:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", -135, -300);

function B:SetWatchFrameHeight()
	local top = WatchFrame:GetTop() or 0;
	local screenHeight = GetScreenHeight();
	local gapFromTop = screenHeight - top;
	local maxHeight = screenHeight - gapFromTop;
	local watchFrameHeight = min(maxHeight, E.db.general.watchFrameHeight);

	WatchFrame:Height(watchFrameHeight);
end

function B:MoveWatchFrame()
	E:CreateMover(WatchFrameHolder, "WatchFrameMover", L["Objective Frame"]);
	WatchFrameHolder:SetAllPoints(WatchFrameMover);

	WatchFrame:ClearAllPoints();
	WatchFrame:SetPoint("TOP", WatchFrameHolder, "TOP");
	B:SetWatchFrameHeight();
	WatchFrame:SetClampedToScreen(false);

	local function WatchFrame_SetPosition(_, _, parent)
		if(parent ~= WatchFrameHolder) then
			WatchFrame:ClearAllPoints();
			WatchFrame:SetPoint("TOP", WatchFrameHolder, "TOP");
		end
	end
	hooksecurefunc(WatchFrame, "SetPoint", WatchFrame_SetPosition)
end