local E, L, V, P, G = unpack(select(2, ...))
local UF = E:GetModule("UnitFrames")

local unpack = unpack
local match = string.match

local CreateFrame = CreateFrame

function UF:Construct_Threat(frame)
	local threat = CreateFrame("Frame", nil, frame)

	--Main ThreatGlow
	threat.MainGlow = frame:CreateShadow(nil, true)
	threat.MainGlow:SetParent(frame)
	threat.MainGlow:Hide()

	--Secondary ThreatGlow, for power frame when using power offset
	threat.PowerGlow = frame:CreateShadow(nil, true)
	threat.PowerGlow:SetParent(frame)
	threat.PowerGlow:SetFrameStrata("BACKGROUND")
	threat.PowerGlow:Hide()

	threat.TextureIcon = threat:CreateTexture(nil, "OVERLAY")
	threat.TextureIcon:Size(8)
	threat.TextureIcon:SetTexture(E.media.blankTex)
	threat.TextureIcon:Hide()

	threat.PostUpdate = self.UpdateThreat

	return threat
end

function UF:Configure_Threat(frame)
	if not (frame.VARIABLES_SET and frame.ThreatIndicator) then return end

	local threat = frame.ThreatIndicator
	if not threat then return end

	local threatStyle = frame.db and frame.db.threatStyle
	if threatStyle and threatStyle ~= "NONE" then
		if not frame:IsElementEnabled("ThreatIndicator") then
			frame:EnableElement("ThreatIndicator")
		end

		if threatStyle == "GLOW" then
			threat:SetFrameStrata("BACKGROUND")
			threat.MainGlow:ClearAllPoints()
			threat.MainGlow:SetAllPoints(frame.TargetGlow)

			if frame.USE_POWERBAR_OFFSET then
				threat.PowerGlow:ClearAllPoints()
				threat.PowerGlow:SetAllPoints(frame.TargetGlow.powerGlow)
			end
		elseif match(threatStyle, "^ICON") then
			threat:SetFrameStrata("LOW")
			threat:SetFrameLevel(75) --Inset power uses 50, we want it to appear above that

			local point = threatStyle:gsub("ICON", "")
			threat.TextureIcon:ClearAllPoints()
			threat.TextureIcon:Point(point, frame.Health, point)
		elseif threatStyle == "HEALTHBORDER" and frame.InfoPanel then
			frame.InfoPanel:SetFrameLevel(frame.Health:GetFrameLevel() - 3)
		elseif threatStyle == "INFOPANELBORDER" and frame.InfoPanel then
			frame.InfoPanel:SetFrameLevel(frame.Health:GetFrameLevel() + 3)
		end
	elseif frame:IsElementEnabled("ThreatIndicator") then
		frame:DisableElement("ThreatIndicator")
	end
end

function UF:ThreatBorderColor(backdrop, lock, r, g, b)
	backdrop.ignoreBorderColors = lock and {r, g, b} or nil
	backdrop:SetBackdropBorderColor(r, g, b)
end

function UF:ThreatClassBarBorderColor(parent, status, r, g, b)
	if parent.AdditionalPower then UF:ThreatBorderColor(parent.AdditionalPower.backdrop, status, r, g, b) end
	if parent.AlternativePower then UF:ThreatBorderColor(parent.AlternativePower.backdrop, status, r, g, b) end
	if parent.BurningEmbers then UF:ThreatBorderColor(parent.BurningEmbers.backdrop, status, r, g, b) end
	if parent.ClassPower then UF:ThreatBorderColor(parent.ClassPower.backdrop, status, r, g, b) end
	if parent.DemonicFury then UF:ThreatBorderColor(parent.DemonicFury.backdrop, status, r, g, b) end
	if parent.EclipseBar then UF:ThreatBorderColor(parent.EclipseBar.backdrop, status, r, g, b) end
	if parent.Runes then UF:ThreatBorderColor(parent.Runes.backdrop, status, r, g, b) end
	if parent.SoulShards then UF:ThreatBorderColor(parent.SoulShards.backdrop, status, r, g, b) end
	if parent.SpecPower then UF:ThreatBorderColor(parent.SpecPower.backdrop, status, r, g, b) end
	if parent.Stagger then UF:ThreatBorderColor(parent.Stagger.backdrop, status, r, g, b) end

	if parent.ClassPower or parent.SpecPower or parent.Runes or parent.BurningEmbers or parent.SoulShards then
		local maxClassBarButtons = max(UF.classMaxResourceBar[E.myclass] or 0)
		for i = 1, maxClassBarButtons do
			if i <= parent.MAX_CLASS_BAR then
				if parent.BurningEmbers then UF:ThreatBorderColor(parent.BurningEmbers[i].backdrop, status, r, g, b) end
				if parent.ClassPower then UF:ThreatBorderColor(parent.ClassPower[i].backdrop, status, r, g, b) end
				if parent.Runes then UF:ThreatBorderColor(parent.Runes[i].backdrop, status, r, g, b) end
				if parent.SoulShards then UF:ThreatBorderColor(parent.SoulShards[i].backdrop, status, r, g, b) end
				if parent.SpecPower then UF:ThreatBorderColor(parent.SpecPower[i].backdrop, status, r, g, b) end
			end
		end
	end

	if parent.ComboPoints then
		for i = 1, MAX_COMBO_POINTS do
			UF:ThreatBorderColor(parent.ComboPoints[i].backdrop, status, r, g, b)
		end
	end
end

function UF:ThreatHandler(threat, parent, threatStyle, status, r, g, b)
	if threatStyle == "GLOW" then
		if status then
			threat.MainGlow:Show()
			threat.MainGlow:SetBackdropBorderColor(r, g, b)

			if parent.USE_POWERBAR_OFFSET then
				threat.PowerGlow:Show()
				threat.PowerGlow:SetBackdropBorderColor(r, g, b)
			end
		else
			threat.MainGlow:Hide()
			threat.PowerGlow:Hide()
		end
	elseif threatStyle == "BORDERS" then
		if parent.InfoPanel then UF:ThreatBorderColor(parent.InfoPanel.backdrop, status, r, g, b) end
		if parent.Power then UF:ThreatBorderColor(parent.Power.backdrop, status, r, g, b) end
		UF:ThreatBorderColor(parent.Health.backdrop, status, r, g, b)
		UF:ThreatClassBarBorderColor(parent, status, r, g, b)
	elseif threatStyle == "HEALTHBORDER" then
		UF:ThreatBorderColor(parent.Health.backdrop, status, r, g, b)
	elseif threatStyle == "INFOPANELBORDER" then
		if parent.InfoPanel then UF:ThreatBorderColor(parent.InfoPanel.backdrop, status, r, g, b) end
	elseif threatStyle ~= "NONE" and threat.TextureIcon then
		if status then
			threat.TextureIcon:Show()
			threat.TextureIcon:SetVertexColor(r, g, b)
		else
			threat.TextureIcon:Hide()
		end
	end
end

function UF:UpdateThreat(unit, status, r, g, b)
	local parent = self:GetParent()
	local db = parent.db and parent.db.threatStyle
	local badUnit = not unit or parent.unit ~= unit

	if not badUnit and status and status > 1 then
		UF:ThreatHandler(self, parent, db, status, r, g, b)
	else
		UF:ThreatHandler(self, parent, db, nil, unpack(E.media.unitframeBorderColor))
	end
end