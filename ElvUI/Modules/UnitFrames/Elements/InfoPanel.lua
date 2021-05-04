local E, L, V, P, G = unpack(select(2, ...))
local UF = E:GetModule("UnitFrames")

function UF:Construct_InfoPanel(frame)
	local infoPanel = CreateFrame("Frame", nil, frame)

	infoPanel:SetFrameLevel(7) --Health is 10 and filled power is 5 by default
	infoPanel:CreateBackdrop("Default", true, nil, self.thinBorders, true)

	return infoPanel
end

function UF:Configure_InfoPanel(frame, noTemplateChange)
	if not frame.VARIABLES_SET then return end
	local db = frame.db

	if frame.USE_INFO_PANEL then
		frame.InfoPanel:Show()
		frame.InfoPanel:ClearAllPoints()

		if frame.ORIENTATION == "RIGHT" then
			frame.InfoPanel:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -UF.BORDER - UF.SPACING, UF.BORDER + UF.SPACING)
			if frame.USE_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED then
				frame.InfoPanel:Point("TOPLEFT", frame.Power.backdrop, "BOTTOMLEFT", UF.BORDER - (frame.PVPINFO_WIDTH or 0) - (frame.STAGGER_WIDTH or 0), -(UF.SPACING * 3))
			else
				frame.InfoPanel:Point("TOPLEFT", frame.Health.backdrop, "BOTTOMLEFT", UF.BORDER - (frame.PVPINFO_WIDTH or 0) - (frame.STAGGER_WIDTH or 0), -(UF.SPACING * 3))
			end
		else
			frame.InfoPanel:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", UF.BORDER + UF.SPACING, UF.BORDER + UF.SPACING)
			if frame.USE_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED then
				frame.InfoPanel:Point("TOPRIGHT", frame.Power.backdrop, "BOTTOMRIGHT", -UF.BORDER + (frame.PVPINFO_WIDTH or 0) + (frame.STAGGER_WIDTH or 0), -(UF.SPACING * 3))
			else
				frame.InfoPanel:Point("TOPRIGHT", frame.Health.backdrop, "BOTTOMRIGHT", -UF.BORDER + (frame.PVPINFO_WIDTH or 0) + (frame.STAGGER_WIDTH or 0), -(UF.SPACING * 3))
			end
		end

		if not noTemplateChange then
			if db.infoPanel.transparent then
				frame.InfoPanel.backdrop:SetTemplate("Transparent", nil, nil, self.thinBorders, true)
			else
				frame.InfoPanel.backdrop:SetTemplate("Default", true, nil, self.thinBorders, true)
			end
		end
	else
		frame.InfoPanel:Hide()
	end
end