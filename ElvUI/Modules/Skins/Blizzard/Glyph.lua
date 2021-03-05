local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack
local strfind = strfind

local NUM_GLYPH_SLOTS = NUM_GLYPH_SLOTS

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.talent then return end

	GlyphFrame:StripTextures()
	GlyphFrame:CreateBackdrop("Transparent")
	GlyphFrame.backdrop:Point("BOTTOMRIGHT", 0, -3)

	GlyphFrame.sideInset:StripTextures()

	GlyphFrame.specIcon:SetTexCoord(unpack(E.TexCoords))

	S:HandleEditBox(GlyphFrameSearchBox)
	GlyphFrameSearchBox:Point("TOPLEFT", GlyphFrameSideInset, 5, 54)

	S:HandleDropDownBox(GlyphFrameFilterDropDown, 208)
	GlyphFrameFilterDropDown:Point("TOPLEFT", GlyphFrameSearchBox, "BOTTOMLEFT", -13, -3)

	for i = 1, NUM_GLYPH_SLOTS do
		local frame = _G["GlyphFrameGlyph"..i]

		frame:SetTemplate("Default", true)
		frame:SetFrameLevel(frame:GetFrameLevel() + 5)
		frame:StyleButton(nil, true)

		if i == 1 or i == 3 or i == 5 then
			frame:Size(60)
		else
			frame:Size(80)
		end

		frame.highlight:SetTexture(nil)
		frame.ring:Hide()
		hooksecurefunc(frame.glyph, "Show", function(self) self:Hide() end)

		frame.icon = frame:CreateTexture(nil, "OVERLAY")
		frame.icon:SetInside()
		frame.icon:SetTexCoord(unpack(E.TexCoords))

		frame.onUpdate = CreateFrame("Frame", nil, frame)
		frame.onUpdate:SetScript("OnUpdate", function()
			local alpha = frame.highlight:GetAlpha()
			local glyphIcon = strfind(frame.icon:GetTexture(), "Interface\\Spellbook\\UI%-Glyph%-Rune")

			if alpha == 0 then
				frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
				frame:SetAlpha(1)

				if glyphIcon then
					frame.icon:SetVertexColor(1, 1, 1, 1)
				end
			else
				frame:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
				frame:SetAlpha(alpha)

				if glyphIcon then
					frame.icon:SetVertexColor(unpack(E.media.rgbvaluecolor))
					frame.icon:SetAlpha(alpha)
				end
			end
		end)
	end

	hooksecurefunc("GlyphFrame_Update", function(self)
		local isActiveTalentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup == GetActiveSpecGroup()

		GlyphFrame.levelOverlayText1:SetTextColor(1, 1, 1)
		GlyphFrame.levelOverlayText2:SetTextColor(1, 1, 1)

		for i = 1, NUM_GLYPH_SLOTS do
			local glyph = _G["GlyphFrameGlyph"..i]
			local _, _, _, _, iconFilename = GetGlyphSocketInfo(i, PlayerTalentFrame.talentGroup)

			if iconFilename then
				glyph.icon:SetTexture(iconFilename)
			else
				glyph.icon:SetTexture("Interface\\Spellbook\\UI-Glyph-Rune-"..i)
			end
			GlyphFrameGlyph_UpdateSlot(glyph)
			SetDesaturation(glyph.icon, not isActiveTalentGroup)
		end
		SetDesaturation(self.specIcon, not isActiveTalentGroup)
	end)

	-- Scroll Frame
	GlyphFrameScrollFrameScrollChild:StripTextures()

	GlyphFrameScrollFrame:StripTextures()
	GlyphFrameScrollFrame:CreateBackdrop("Transparent")
	GlyphFrameScrollFrame.backdrop:Point("TOPLEFT", -1, 1)
	GlyphFrameScrollFrame.backdrop:Point("BOTTOMRIGHT", -4, -2)

	S:HandleScrollBar(GlyphFrameScrollFrameScrollBar)
	GlyphFrameScrollFrameScrollBar:ClearAllPoints()
	GlyphFrameScrollFrameScrollBar:Point("TOPRIGHT", GlyphFrameScrollFrame, 20, -15)
	GlyphFrameScrollFrameScrollBar:Point("BOTTOMRIGHT", GlyphFrameScrollFrame, 0, 14)

	for i = 1, 2 do
		local header = _G["GlyphFrameHeader"..i]

		header:StripTextures()
		header:StyleButton()
	end

	for i = 1, 10 do
		local button = _G["GlyphFrameScrollFrameButton"..i]

		button:StripTextures()
		button:CreateBackdrop()
		button.backdrop:SetOutside(button.icon)

		S:HandleButtonHighlight(button)
		button.handledHighlight:Point("TOPLEFT", 38, 0)
		button.handledHighlight:Point("BOTTOMRIGHT", -2, 0)

		button.selectedTex:SetTexture(E.Media.Textures.Highlight)
		button.selectedTex:SetVertexColor(1, 0.80, 0.10, 0.35)
		button.selectedTex:SetTexCoord(0, 1, 0, 1)
		button.selectedTex:Point("TOPLEFT", 38, 0)
		button.selectedTex:Point("BOTTOMRIGHT", -2, 0)

		button.icon:Size(38)
		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.icon:SetParent(button.backdrop)
	end

	-- Clear Info
	GlyphFrame.clearInfo:CreateBackdrop()
	GlyphFrame.clearInfo.backdrop:SetAllPoints()
	GlyphFrame.clearInfo:StyleButton()
	GlyphFrame.clearInfo:Size(E.PixelMode and 26 or 24)
	GlyphFrame.clearInfo:Point("TOPLEFT", GlyphFrame, "BOTTOMLEFT", -1, E.PixelMode and -6 or -7)

	GlyphFrame.clearInfo.icon:SetTexCoord(unpack(E.TexCoords))
	GlyphFrame.clearInfo.icon:ClearAllPoints()
	GlyphFrame.clearInfo.icon:SetInside()

	GlyphFrame.clearInfo.name:Point("LEFT", GlyphFrame.clearInfo.icon, "RIGHT", 6, E.PixelMode and 1 or 0)
end

S:AddCallbackForAddon("Blizzard_GlyphUI", "Glyph", LoadSkin)