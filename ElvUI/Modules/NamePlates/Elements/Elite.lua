local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule("NamePlates")

function NP:Update_Elite(frame)
	if not NP.db.units[frame.UnitType].eliteIcon then return end

	local icon = frame.Elite
	if NP.db.units[frame.UnitType].eliteIcon.enable then
		local elite, boss = frame.EliteIcon:IsShown(), frame.BossIcon:IsShown()

		if boss then
			icon:SetTexCoord(0, 0.15, 0.65, 0.94)
			icon:Show()
		elseif elite then
			icon:SetTexCoord(0, 0.15, 0.35, 0.63)
			icon:Show()
		else
			icon:Hide()
		end
	else
		icon:Hide()
	end
end

function NP:Configure_Elite(frame)
	if not NP.db.units[frame.UnitType].eliteIcon then return end

	local icon = frame.Elite
	local size = NP.db.units[frame.UnitType].eliteIcon.size
	local position = NP.db.units[frame.UnitType].eliteIcon.position

	icon:Size(size)
	icon:ClearAllPoints()

	if frame.Health:IsShown() then
		icon:SetParent(frame.Health)
		icon:Point(position, frame.Health, position, NP.db.units[frame.UnitType].eliteIcon.xOffset, NP.db.units[frame.UnitType].eliteIcon.yOffset)
	else
		icon:SetParent(frame)
		icon:Point(position, frame, position, NP.db.units[frame.UnitType].eliteIcon.xOffset, NP.db.units[frame.UnitType].eliteIcon.yOffset)
	end
end

function NP:Construct_Elite(frame)
	local icon = frame.Health:CreateTexture(nil, "OVERLAY")
	icon:SetTexture(E.Media.Textures.Nameplates)
	icon:Hide()

	return icon
end