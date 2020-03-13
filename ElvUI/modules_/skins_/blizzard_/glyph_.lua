local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true then return end

	GlyphFrame:StripTextures()
	GlyphFrame:CreateBackdrop("Transparent")

	GlyphFrameSideInset:StripTextures()

	GlyphFrame.specIcon:SetTexCoord(unpack(E.TexCoords))

	GlyphFrame:HookScript("OnUpdate", function(self)
		self.specIcon:SetAlpha(1 - self.glow:GetAlpha())
	end)

	if not GlyphFrame.isSkinned then
		for i = 1, 6 do
			local Glyph = _G["GlyphFrameGlyph"..i]

			Glyph:SetTemplate("Default", true)
			Glyph:SetFrameLevel(Glyph:GetFrameLevel() + 5)
			Glyph:StyleButton(nil, true)

			Glyph.ring:Hide()
			Glyph.glyph:Hide()
			Glyph.highlight:SetTexture(nil)
			Glyph.glyph:Hide()

			Glyph.icon = Glyph:CreateTexture(nil, "OVERLAY")
			Glyph.icon:SetInside()
			Glyph.icon:SetTexCoord(unpack(E.TexCoords))

			Glyph:CreateBackdrop()
			Glyph.backdrop:SetAllPoints()
			Glyph.backdrop:SetFrameLevel(Glyph:GetFrameLevel() + 1)
			Glyph.backdrop:SetBackdropColor(0, 0, 0, 0)
			Glyph.backdrop:SetBackdropBorderColor(1, 0.80, 0.10)

			Glyph.backdrop:SetScript("OnUpdate", function(self)
				local Alpha = Glyph.highlight:GetAlpha()
				self:SetAlpha(Alpha)

				if strfind(Glyph.icon:GetTexture(), "Interface\\Spellbook\\UI%-Glyph%-Rune") then
					if Alpha == 0 then
						Glyph.icon:SetVertexColor(1, 1, 1)
						Glyph.icon:SetAlpha(1)
					else
						Glyph.icon:SetVertexColor(1, 0.80, 0.10)
						Glyph.icon:SetAlpha(Alpha)
					end
				end
			end)

			hooksecurefunc(Glyph.highlight, "Show", function()
				Glyph.backdrop:Show()
			end)

			Glyph.glyph:Hide()
			hooksecurefunc(Glyph.glyph, "Show", function(self) self:Hide() end)

			if(i % 2 == 1) then
				Glyph:Size(Glyph:GetWidth() * .8, Glyph:GetHeight() * .8)
			end
		end

		hooksecurefunc("GlyphFrame_Update", function(self)
			local isActiveTalentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup == GetActiveSpecGroup()
			for i = 1, NUM_GLYPH_SLOTS do
				local GlyphSocket = _G["GlyphFrameGlyph"..i]
				local _, _, _, _, iconFilename = GetGlyphSocketInfo(i, PlayerTalentFrame.talentGroup)

				if iconFilename then
					GlyphSocket.icon:SetTexture(iconFilename)
				else
					GlyphSocket.icon:SetTexture("Interface\\Spellbook\\UI-Glyph-Rune-"..i)
				end
				GlyphFrameGlyph_UpdateSlot(GlyphSocket)
				SetDesaturation(GlyphSocket.icon, not isActiveTalentGroup)
			end
			SetDesaturation(self.specIcon, not isActiveTalentGroup)

			GlyphFrame.levelOverlayText1:SetTextColor(1, 1, 1)
			GlyphFrame.levelOverlayText2:SetTextColor(1, 1, 1)
		end)

		GlyphFrame.isSkinned = true
	end

	for i = 1, 2 do
		_G["GlyphFrameHeader"..i]:StripTextures()
		_G["GlyphFrameHeader"..i]:StyleButton()
	end

	GlyphFrameClearInfoFrame:CreateBackdrop("Default")
	GlyphFrameClearInfoFrame:Point("TOPLEFT", GlyphFrame, "BOTTOMLEFT", 25, -8)	
	GlyphFrameClearInfoFrame:Size(20)
	GlyphFrameClearInfoFrame:StyleButton()
	GlyphFrameClearInfoFrame.icon:SetTexCoord(unpack(E.TexCoords))
	GlyphFrameClearInfoFrame.count:FontTemplate(nil, 12, "OUTLINE")
	GlyphFrameClearInfoFrame.count:Point("BOTTOMRIGHT", -20, 4)

	S:HandleDropDownBox(GlyphFrameFilterDropDown, 212)
	S:HandleEditBox(GlyphFrameSearchBox)
	S:HandleScrollBar(GlyphFrameScrollFrameScrollBar, 5)

	for i = 1, 10 do
		local button = _G["GlyphFrameScrollFrameButton"..i]
		local icon = _G["GlyphFrameScrollFrameButton"..i.."Icon"]

		button:StripTextures()
		S:HandleButton(button)
		icon:SetTexCoord(unpack(E.TexCoords))
	end
end

S:AddCallbackForAddon("Blizzard_GlyphUI", "Glyph", LoadSkin)