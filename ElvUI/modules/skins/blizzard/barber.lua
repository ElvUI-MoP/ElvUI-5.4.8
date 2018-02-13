local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.barber ~= true then return end

	BarberShopFrame:CreateBackdrop("Transparent")
	BarberShopFrame.backdrop:Point("TOPLEFT", 44, -70)
	BarberShopFrame.backdrop:Point("BOTTOMRIGHT", -38, 42)

	BarberShopFrameBackground:Kill()

	for i = 1, 4 do
		local selectorPrev = _G["BarberShopFrameSelector"..i.."Prev"]
		local selectorNext = _G["BarberShopFrameSelector"..i.."Next"]

		S:HandleNextPrevButton(selectorPrev)
		S:HandleNextPrevButton(selectorNext)
	end

	BarberShopFrameMoneyFrame:StripTextures()
	BarberShopFrameMoneyFrame:CreateBackdrop()

	S:HandleButton(BarberShopFrameOkayButton)
	S:HandleButton(BarberShopFrameCancelButton)
	S:HandleButton(BarberShopFrameResetButton)
end

S:AddCallbackForAddon("Blizzard_BarbershopUI", "Barbershop", LoadSkin)