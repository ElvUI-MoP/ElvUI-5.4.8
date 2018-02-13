local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.taxi ~= true then return end

	local TaxiFrame = _G["TaxiFrame"]
	TaxiFrame:StripTextures()
	TaxiFrame:CreateBackdrop("Transparent")

	S:HandleCloseButton(TaxiFrame.CloseButton)

	_G["TaxiRouteMap"]:CreateBackdrop("Default")
	_G["TaxiRouteMap"].backdrop.backdropTexture:Hide()
end

S:AddCallback("Taxi", LoadSkin)