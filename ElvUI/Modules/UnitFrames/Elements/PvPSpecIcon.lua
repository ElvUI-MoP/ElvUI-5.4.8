local E, L, V, P, G = unpack(select(2, ...))
local UF = E:GetModule("UnitFrames")

local CreateFrame = CreateFrame

function UF:Construct_PVPSpecIcon(frame)
	local specIcon = CreateFrame("Frame", nil, frame)

	specIcon.bg = CreateFrame("Frame", nil, specIcon)
	specIcon.bg:SetTemplate("Default", nil, nil, self.thinBorders, true)
	specIcon.bg:SetFrameLevel(specIcon:GetFrameLevel() - 1)

	specIcon:SetFrameLevel(50)
	specIcon:SetInside(specIcon.bg)

	return specIcon
end

function UF:Configure_PVPSpecIcon(frame)
	if not frame.VARIABLES_SET then return end

	local specIcon = frame.PVPSpecIcon
	local db = frame.db

	if db.pvpSpecIcon.enable then
		if not frame:IsElementEnabled("PVPSpecIcon") then
			frame:EnableElement("PVPSpecIcon")
		end

		local powerSettings = db.power.enable and not frame.USE_MINI_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED and not frame.USE_POWERBAR_OFFSET
		local anchor = powerSettings and frame.Power or frame.Health

		specIcon.bg:ClearAllPoints()
		if frame.ORIENTATION == "RIGHT" then
			specIcon.bg:Point("BOTTOMRIGHT", anchor, "BOTTOMLEFT", -UF.BORDER + (UF.BORDER - UF.SPACING * 3), -UF.BORDER)
			specIcon.bg:Point("TOPLEFT", frame.Health, "TOPLEFT", -frame.PVPINFO_WIDTH - UF.BORDER, UF.BORDER)
		else
			specIcon.bg:Point("BOTTOMLEFT", anchor, "BOTTOMRIGHT", UF.BORDER + (-UF.BORDER + UF.SPACING * 3), -UF.BORDER)
			specIcon.bg:Point("TOPRIGHT", frame.Health, "TOPRIGHT", frame.PVPINFO_WIDTH + UF.BORDER, UF.BORDER)
		end
	else
		if frame:IsElementEnabled("PVPSpecIcon") then
			frame:DisableElement("PVPSpecIcon")
		end
	end
end