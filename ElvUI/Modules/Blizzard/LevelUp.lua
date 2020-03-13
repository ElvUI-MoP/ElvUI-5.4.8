local E, L, DF = unpack(select(2, ...))
local B = E:GetModule("Blizzard")

local Holder = CreateFrame("Frame", "LevelUpHolder", UIParent)
Holder:SetSize(200, 20)
Holder:SetPoint("TOP", E.UIParent, "TOP", 0, -120)

function B:Handle_LevelUpDisplay()
	E:CreateMover(Holder, "LevelUpMover", L["Level Up Display"])

	local function Reanchor(frame, _, anchor)
		if anchor ~= Holder then
			frame:ClearAllPoints()
			frame:SetPoint("TOP", Holder)
		end
	end

	--Level Up Display
	LevelUpDisplay:ClearAllPoints()
	LevelUpDisplay:SetPoint("TOP", Holder)
	hooksecurefunc(LevelUpDisplay, "SetPoint", Reanchor)
end
