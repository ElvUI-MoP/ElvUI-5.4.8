local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.taxi then return end

	TaxiFrame:StripTextures()
	TaxiFrame:CreateBackdrop("Transparent")

	S:HandleCloseButton(TaxiFrame.CloseButton)

	TaxiRouteMap:CreateBackdrop()
	TaxiRouteMap.backdrop.backdropTexture:Hide()
end

S:AddCallback("Taxi", LoadSkin)