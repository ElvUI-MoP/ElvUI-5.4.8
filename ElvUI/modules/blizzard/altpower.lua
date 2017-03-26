local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

function B:PositionAltPowerBar()
	local holder = CreateFrame('Frame', 'AltPowerBarHolder', UIParent)
	holder:Point('TOP', E.UIParent, 'TOP', 0, -160)
	holder:Size(128, 50)

	PlayerPowerBarAlt:ClearAllPoints()
	PlayerPowerBarAlt:Point('CENTER', holder, 'CENTER')
	PlayerPowerBarAlt:SetParent(holder)
	PlayerPowerBarAlt.ignoreFramePositionManager = true
	PlayerPowerBarAlt:SetScale(0.9)

	local function Position(self)
		self:Point('CENTER', AltPowerBarHolder, 'CENTER')
	end
	hooksecurefunc(PlayerPowerBarAlt, "ClearAllPoints", Position)

	E:CreateMover(holder, 'AltPowerBarMover', L["Alternative Power"])
end