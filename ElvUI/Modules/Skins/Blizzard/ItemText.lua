local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.itemText then return end

	ItemTextFrame:StripTextures(true)
	ItemTextFrame:SetTemplate("Transparent")

	ItemTextFrameInset:Kill()

	ItemTextTitleText:ClearAllPoints()
	ItemTextTitleText:Point("TOP", 0, -8)

	ItemTextPageText:SetTextColor(1, 1, 1)
	ItemTextPageText.SetTextColor = E.noop

	ItemTextCurrentPage:Point("TOP", 0, -35)

	ItemTextScrollFrame:StripTextures()
	ItemTextScrollFrame:Point("TOPRIGHT", -41, -63)
	ItemTextScrollFrame:CreateBackdrop("Transparent")
	ItemTextScrollFrame.backdrop:Point("TOPLEFT", -10, 0)
	ItemTextScrollFrame.backdrop:Point("BOTTOMRIGHT", 10, 0)

	S:HandleScrollBar(ItemTextScrollFrameScrollBar)
	ItemTextScrollFrameScrollBar:ClearAllPoints()
	ItemTextScrollFrameScrollBar:Point("TOPRIGHT", ItemTextScrollFrame, 33, -18)
	ItemTextScrollFrameScrollBar:Point("BOTTOMRIGHT", ItemTextScrollFrame, 0, 18)

	S:HandleNextPrevButton(ItemTextPrevPageButton, nil, nil, true)
	ItemTextPrevPageButton:Point("CENTER", ItemTextFrame, "TOPLEFT", 18, -41)
	ItemTextPrevPageButton:Size(28)

	S:HandleNextPrevButton(ItemTextNextPageButton, nil, nil, true)
	ItemTextNextPageButton:Point("CENTER", ItemTextFrame, "TOPRIGHT", -42, -41)
	ItemTextNextPageButton:Size(28)

	S:HandleCloseButton(ItemTextFrameCloseButton)
end

S:AddCallback("ItemText", LoadSkin)