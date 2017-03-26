local E, L, V, P, G = unpack(ElvUI); 
local B = E:GetModule('Blizzard');

function B:ErrorFrameSize()
	UIErrorsFrame:SetSize(E.db.general.errorFrame.width, E.db.general.errorFrame.height)

	E:CreateMover(UIErrorsFrame, "UIErrorsFrameMover", L["Error Frame"])
end
