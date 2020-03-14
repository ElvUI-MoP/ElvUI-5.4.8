local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.macro then return end

	MacroFrame:StripTextures()
	MacroFrame:SetTemplate("Transparent")

	MacroFrameInset:Kill()

	for i = 1, 2 do
		local Tab = _G["MacroFrameTab"..i]
		Tab:StripTextures()
		S:HandleButton(Tab)

		Tab:Height(22)
		Tab:ClearAllPoints()

		if i == 1 then
			Tab:Point("TOPLEFT", MacroFrame, "TOPLEFT", 11, -30)
			Tab:Width(125)
		elseif i == 2 then
			Tab:Point("TOPRIGHT", MacroFrame, "TOPRIGHT", -30, -30)
			Tab:Width(168)
		end
		Tab.SetWidth = E.noop
	end

	S:HandleButton(MacroDeleteButton)
	S:HandleButton(MacroExitButton)
	S:HandleButton(MacroNewButton)
	S:HandleButton(MacroSaveButton)
	S:HandleButton(MacroCancelButton)

	S:HandleCloseButton(MacroFrameCloseButton)

	MacroFrameTextBackground:StripTextures()
	MacroFrameTextBackground:CreateBackdrop("Default")
	MacroFrameTextBackground.backdrop:Point("TOPLEFT", 5, -3)
	MacroFrameTextBackground.backdrop:Point("BOTTOMRIGHT", -22, 4)

	MacroButtonScrollFrame:StripTextures()
	MacroButtonScrollFrame:CreateBackdrop("Transparent")

	S:HandleButton(MacroEditButton)

	S:HandleScrollBar(MacroButtonScrollFrame)

	S:HandleScrollBar(MacroButtonScrollFrameScrollBar)
	MacroButtonScrollFrameScrollBar:ClearAllPoints()
	MacroButtonScrollFrameScrollBar:Point("TOPRIGHT", MacroButtonScrollFrame, "TOPRIGHT", 21, -17)
	MacroButtonScrollFrameScrollBar:Point("BOTTOMRIGHT", MacroButtonScrollFrame, "BOTTOMRIGHT", 0, 17)

	S:HandleScrollBar(MacroFrameScrollFrameScrollBar)
	MacroFrameScrollFrameScrollBar:ClearAllPoints()
	MacroFrameScrollFrameScrollBar:Point("TOPRIGHT", MacroFrameScrollFrame, "TOPRIGHT", 25, -16)
	MacroFrameScrollFrameScrollBar:Point("BOTTOMRIGHT", MacroFrameScrollFrame, "BOTTOMRIGHT", 0, 17)

	S:HandleScrollBar(MacroPopupScrollFrameScrollBar)
	MacroPopupScrollFrameScrollBar:ClearAllPoints()
	MacroPopupScrollFrameScrollBar:Point("TOPRIGHT", MacroPopupScrollFrame, "TOPRIGHT", 23, -16)
	MacroPopupScrollFrameScrollBar:Point("BOTTOMRIGHT", MacroPopupScrollFrame, "BOTTOMRIGHT", 0, 22)

	MacroFrameSelectedMacroButton:StripTextures()
	MacroFrameSelectedMacroButton:SetTemplate()
	MacroFrameSelectedMacroButton:StyleButton(nil, true)
	MacroFrameSelectedMacroButton:GetNormalTexture():SetTexture(nil)
	MacroFrameSelectedMacroButton:Point("TOPLEFT", MacroFrameSelectedMacroBackground, 6, 2)

	MacroFrameSelectedMacroButtonIcon:SetTexCoord(unpack(E.TexCoords))
	MacroFrameSelectedMacroButtonIcon:SetInside()

	MacroFrameEnterMacroText:Point("TOPLEFT", MacroFrameSelectedMacroBackground, "BOTTOMLEFT", 8, 7)
	MacroFrameCharLimitText:Point("BOTTOM", -15, 27)

	for i = 1, MAX_ACCOUNT_MACROS do
		local button = _G["MacroButton"..i]
		local buttonIcon = _G["MacroButton"..i.."Icon"]

		if button then
			button:StripTextures()
			button:SetTemplate("Default", true)
			button:StyleButton(nil, true)
		end

		if buttonIcon then
			buttonIcon:SetTexCoord(unpack(E.TexCoords))
			buttonIcon:SetInside()
		end
	end

	S:HandleIconSelectionFrame(MacroPopupFrame, NUM_MACRO_ICONS_SHOWN, "MacroPopupButton", "MacroPopup")

	MacroPopupScrollFrame:CreateBackdrop("Transparent")
	MacroPopupScrollFrame.backdrop:Point("TOPLEFT", 51, 2)
	MacroPopupScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, 4)

	MacroPopupFrame:Point("TOPLEFT", MacroFrame, "TOPRIGHT", 1, 0)
end

S:AddCallbackForAddon("Blizzard_MacroUI", "Macro", LoadSkin)