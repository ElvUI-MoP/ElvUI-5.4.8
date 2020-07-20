local E, L, V, P, G = unpack(select(2, ...))
local UF = E:GetModule("UnitFrames")

local CreateFrame = CreateFrame

function UF:Construct_Stagger(frame)
	local stagger = CreateFrame("Statusbar", nil, frame)
	UF.statusbars[stagger] = true
	stagger:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
	stagger:SetOrientation("VERTICAL")
	stagger:SetFrameLevel(50)

	stagger.bg = stagger:CreateTexture(nil, "BORDER")
	stagger.bg:SetAllPoints(stagger)
	stagger.bg:SetTexture(E.media.blankTex)
	stagger.bg.multiplier = 0.3

	stagger.PostUpdate = UF.PostUpdateStagger

	stagger:SetScript("OnShow", UF.ToggleStaggerBar)
	stagger:SetScript("OnHide", UF.ToggleStaggerBar)

	return stagger
end

function UF:Configure_Stagger(frame)
	if not frame.VARIABLES_SET then return end

	local stagger = frame.Stagger
	local db = frame.db

	if db.stagger.enable then
		if not frame:IsElementEnabled("Stagger") then
			frame:EnableElement("Stagger")
		end

		E:SetSmoothing(stagger, UF.db.smoothbars)

		local powerSettings = db.power.enable and not frame.USE_MINI_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED and not frame.USE_POWERBAR_OFFSET
		local anchor = powerSettings and frame.Power or frame.Health

		stagger:ClearAllPoints()
		if frame.ORIENTATION == "RIGHT" then
			stagger:Point("BOTTOMRIGHT", anchor, "BOTTOMLEFT", -frame.BORDER * 2 + (frame.BORDER - frame.SPACING * 3), 0)
			stagger:Point("TOPLEFT", frame.Health, "TOPLEFT", -frame.STAGGER_WIDTH, 0)
		else
			stagger:Point("BOTTOMLEFT", anchor, "BOTTOMRIGHT", frame.BORDER * 2 + (-frame.BORDER + frame.SPACING * 3), 0)
			stagger:Point("TOPRIGHT", frame.Health, "TOPRIGHT", frame.STAGGER_WIDTH, 0)
		end
	elseif frame:IsElementEnabled("Stagger") then
		frame:DisableElement("Stagger")
	end
end

function UF:ToggleStaggerBar()
	local frame = self:GetParent()
	local isShown = self:IsShown()
	local stateChanged

	if (frame.STAGGER_SHOWN and not isShown) or (not frame.STAGGER_SHOWN and isShown) then
		stateChanged = true
	end

	frame.STAGGER_SHOWN = isShown
	frame.STAGGER_WIDTH = frame.USE_STAGGER and frame.STAGGER_SHOWN and (frame.db.stagger.width + (frame.BORDER * 3)) or 0

	if stateChanged then
		UF:Configure_Stagger(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame, true)
		UF:Configure_Threat(frame)
		UF:Configure_InfoPanel(frame, true)
	end
end

function UF:PostUpdateStagger(stagger)
	local frame = self:GetParent()

	self:SetShown(stagger > 0 or not frame.db.stagger.autoHide)

	local stateChanged
	local isShown = self:IsShown()

	if (frame.STAGGER_SHOWN and not isShown) or (not frame.STAGGER_SHOWN and isShown) then
		stateChanged = true
	end

	frame.STAGGER_SHOWN = isShown

	if stateChanged then
		UF:Configure_Stagger(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_Power(frame, true)
		UF:Configure_Threat(frame)
		UF:Configure_InfoPanel(frame, true)
	end
end