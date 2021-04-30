local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.macro then return end

	MacroFrame:StripTextures()
	MacroFrame:SetTemplate("Transparent")

	MacroFrameInset:StripTextures()

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
	S:HandleButton(MacroEditButton)
	S:HandleButton(MacroSaveButton)
	S:HandleButton(MacroCancelButton)

	S:HandleButton(MacroNewButton)
	MacroNewButton:Point("BOTTOMRIGHT", -87, 4)

	S:HandleCloseButton(MacroFrameCloseButton)

	MacroButtonScrollFrame:StripTextures()
	MacroButtonScrollFrame:CreateBackdrop("Transparent")

	S:HandleScrollBar(MacroButtonScrollFrameScrollBar)
	MacroButtonScrollFrameScrollBar:ClearAllPoints()
	MacroButtonScrollFrameScrollBar:Point("TOPRIGHT", MacroButtonScrollFrame, 24, -17)
	MacroButtonScrollFrameScrollBar:Point("BOTTOMRIGHT", MacroButtonScrollFrame, 0, 17)

	MacroFrameTextBackground:StripTextures()
	MacroFrameTextBackground:CreateBackdrop()
	MacroFrameTextBackground.backdrop:Point("TOPLEFT", 5, -3)
	MacroFrameTextBackground.backdrop:Point("BOTTOMRIGHT", -21, 4)

	S:HandleScrollBar(MacroFrameScrollFrameScrollBar)
	MacroFrameScrollFrameScrollBar:ClearAllPoints()
	MacroFrameScrollFrameScrollBar:Point("TOPRIGHT", MacroFrameScrollFrame, 28, -15)
	MacroFrameScrollFrameScrollBar:Point("BOTTOMRIGHT", MacroFrameScrollFrame, 0, 18)

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
	MacroPopupFrame:Point("TOPLEFT", MacroFrame, "TOPRIGHT", 1, 0)
	MacroPopupFrame:Size(282, 290)
end

S:AddCallbackForAddon("Blizzard_MacroUI", "Macro", LoadSkin)