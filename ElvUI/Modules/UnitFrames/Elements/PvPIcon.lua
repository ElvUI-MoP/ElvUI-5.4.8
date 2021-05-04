local E, L, V, P, G = unpack(select(2, ...))
local UF = E:GetModule("UnitFrames")

function UF:Construct_PvPIcon(frame)
	local PvPIndicator = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "ARTWORK", nil, 1)
	PvPIndicator:Size(30)
	PvPIndicator:Point("CENTER", frame, "CENTER")

	PvPIndicator.Override = UF.PvPIconOverride

	return PvPIndicator
end

function UF:Configure_PVPIcon(frame)
	local PvPIndicator = frame.PvPIndicator
	PvPIndicator:ClearAllPoints()
	PvPIndicator:Point(frame.db.pvpIcon.anchorPoint, frame.Health, frame.db.pvpIcon.anchorPoint, frame.db.pvpIcon.xOffset, frame.db.pvpIcon.yOffset)

	local scale = frame.db.pvpIcon.scale or 1
	PvPIndicator:Size(30 * scale)

	if frame.db.pvpIcon.enable and not frame:IsElementEnabled("PvPIndicator") then
		frame:EnableElement("PvPIndicator")
	elseif not frame.db.pvpIcon.enable and frame:IsElementEnabled("PvPIndicator") then
		frame:DisableElement("PvPIndicator")
	end
end

function UF:PvPIconOverride(event, unit)
	if not unit or self.unit ~= unit then return end

	local element = self.PvPIndicator

	if element.PreUpdate then
		element:PreUpdate()
	end

	local status
	local factionGroup = UnitFactionGroup(unit)

	if UnitIsPVPFreeForAll(unit) then
		element:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		element:SetTexCoord(0, 0.65625, 0, 0.65625)

		status = "ffa"
	elseif factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(unit) then
		element:SetTexture("Interface\\PVPFrame\\PVP-Conquest-Misc")

		if factionGroup == "Alliance" then
			element:SetTexCoord(0.69433594, 0.74804688, 0.60351563, 0.72851563)
		else
			element:SetTexCoord(0.63867188, 0.69238281, 0.60351563, 0.73242188)
		end

		status = factionGroup
	end

	if status then
		element:Show()
	else
		element:Hide()
	end

	if element.PostUpdate then
		return element:PostUpdate(unit, status)
	end
end