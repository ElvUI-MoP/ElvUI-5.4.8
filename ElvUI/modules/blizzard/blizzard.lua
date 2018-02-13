local E, L, V, P, G = unpack(select(2, ...));
local B = E:NewModule('Blizzard', 'AceEvent-3.0', 'AceHook-3.0');

E.Blizzard = B;

function B:Initialize()
	self:AlertMovers();
	self:EnhanceColorPicker();
	self:KillBlizzard();
	self:PositionCaptureBar();
	self:PositionDurabilityFrame();
	self:PositionGMFrames();
	self:PositionVehicleFrame();
	self:MoveWatchFrame();
	self:SkinBlizzTimers();
	self:ErrorFrameSize()
	self:Handle_LevelUpDisplay()

 	if(not IsAddOnLoaded("SimplePowerBar")) then
 		self:PositionAltPowerBar();
	end

	if(GetLocale() == "deDE") then
		DAY_ONELETTER_ABBR = "%d d";
	end

	E:CreateMover(LossOfControlFrame, "LossControlMover", L["Loss Control Icon"])

	CreateFrame("Frame"):SetScript("OnUpdate", function()
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)
end

local function InitializeCallback()
	B:Initialize()
end

E:RegisterModule(B:GetName(), InitializeCallback)