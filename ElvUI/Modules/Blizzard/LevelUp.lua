local E, L, V, P, G = unpack(select(2, ...))
local B = E:GetModule("Blizzard")

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local Holder
local function Reanchor(frame, _, anchor)
	if anchor and (anchor ~= Holder) then
		frame:ClearAllPoints()
		frame:Point("TOP", Holder)
	end
end

function B:Handle_LevelUpDisplay()
	if not Holder then
		Holder = CreateFrame("Frame", "LevelUpHolder", E.UIParent)
		Holder:Size(200, 20)
		Holder:Point("TOP", E.UIParent, "TOP", 0, -120)
	end

	E:CreateMover(Holder, "LevelUpMover", L["Level Up Display"])

	LevelUpDisplay:ClearAllPoints()
	LevelUpDisplay:Point("TOP", Holder)
	hooksecurefunc(LevelUpDisplay, "SetPoint", Reanchor)
end