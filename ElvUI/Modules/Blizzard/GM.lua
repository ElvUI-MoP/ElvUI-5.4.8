local E, L, V, P, G = unpack(select(2, ...))
local B = E:GetModule("Blizzard")

local hooksecurefunc = hooksecurefunc

local function SetPosition(frame, _, anchor)
	if anchor and (anchor == UIParent) then
		frame:ClearAllPoints()
		frame:Point("TOPLEFT", GMMover, 0, 0)
	end
end

function B:PositionGMFrames()
	TicketStatusFrame:ClearAllPoints()
	TicketStatusFrame:Point("TOPLEFT", E.UIParent, "TOPLEFT", 250, -4)
	E:CreateMover(TicketStatusFrame, "GMMover", L["GM Ticket Frame"])

	--Blizzard repositions this frame now in UIParent_UpdateTopFramePositions
	hooksecurefunc(TicketStatusFrame, "SetPoint", SetPosition)
end