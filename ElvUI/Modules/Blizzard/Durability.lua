local E, L, V, P, G = unpack(select(2, ...))
local B = E:GetModule("Blizzard")

local hooksecurefunc = hooksecurefunc

local function SetPosition(frame, _, parent)
	if parent ~= DurabilityFrameHolder then
		frame:ClearAllPoints()
		frame:SetPoint("CENTER", DurabilityFrameHolder, "CENTER")
	end
end

function B:PositionDurabilityFrame()
	local Scale = E.db.general.durabilityScale or 1

	local DurabilityFrameHolder = CreateFrame("Frame", "DurabilityFrameHolder", E.UIParent)
	DurabilityFrameHolder:Size(DurabilityFrame:GetSize())
	DurabilityFrameHolder:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", -135, -300)

	E:CreateMover(DurabilityFrameHolder, "DurabilityFrameMover", L["Durability Frame"], nil, nil, nil, nil, nil, "all,general")

	DurabilityFrame:SetFrameStrata("HIGH")
	DurabilityFrame:SetScale(Scale)

	hooksecurefunc(DurabilityFrame, "SetPoint", SetPosition)
end