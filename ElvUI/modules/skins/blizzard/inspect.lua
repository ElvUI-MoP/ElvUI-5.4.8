local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs, unpack = pairs, unpack

local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.inspect then return end

	local InspectFrame = _G["InspectFrame"]
	InspectFrame:StripTextures(true)
	InspectFrame:SetTemplate("Transparent")

	InspectFrameInset:StripTextures(true)

	S:HandleCloseButton(InspectFrameCloseButton)

	for i = 1, 4 do
		S:HandleTab(_G["InspectFrameTab"..i])
	end

	InspectModelFrameBorderTopLeft:Kill()
	InspectModelFrameBorderTopRight:Kill()
	InspectModelFrameBorderTop:Kill()
	InspectModelFrameBorderLeft:Kill()
	InspectModelFrameBorderRight:Kill()
	InspectModelFrameBorderBottomLeft:Kill()
	InspectModelFrameBorderBottomRight:Kill()
	InspectModelFrameBorderBottom:Kill()
	InspectModelFrameBorderBottom2:Kill()
	InspectModelFrameBackgroundOverlay:Kill()
	InspectModelFrame:CreateBackdrop("Default")

	local slots = {
		"HeadSlot",
		"NeckSlot",
		"ShoulderSlot",
		"BackSlot",
		"ChestSlot",
		"ShirtSlot",
		"TabardSlot",
		"WristSlot",
		"HandsSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"Finger0Slot",
		"Finger1Slot",
		"Trinket0Slot",
		"Trinket1Slot",
		"MainHandSlot",
		"SecondaryHandSlot"
	}

	for _, slot in pairs(slots) do
		local icon = _G["Inspect"..slot.."IconTexture"]
		local slot = _G["Inspect"..slot]

		slot:StripTextures()
		slot:CreateBackdrop("Default")
		slot.backdrop:SetAllPoints()
		slot:SetFrameLevel(slot:GetFrameLevel() + 2)
		slot:StyleButton()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
	end

	hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
		if button.hasItem then
			local itemID = GetInventoryItemID(InspectFrame.unit, button:GetID())
			if itemID then
				local _, _, quality = GetItemInfo(itemID)
				if not quality then
					E:Delay(0.1, function()
						if(InspectFrame.unit) then
							InspectPaperDollItemSlotButton_Update(button)
						end
					end)
					return
				elseif quality and quality > 1 then
					button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					return
 				end
			end
		end
		button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
 	end)

	-- Control Frame
	InspectModelFrameControlFrame:StripTextures()
	InspectModelFrameControlFrame:Size(123, 23)

	local controlbuttons = {
		"InspectModelFrameControlFrameZoomInButton",
		"InspectModelFrameControlFrameZoomOutButton",
		"InspectModelFrameControlFramePanButton",
		"InspectModelFrameControlFrameRotateRightButton",
		"InspectModelFrameControlFrameRotateLeftButton",
		"InspectModelFrameControlFrameRotateResetButton"
	}

	for i = 1, #controlbuttons do
		S:HandleButton(_G[controlbuttons[i]])
		_G[controlbuttons[i].."Bg"]:Hide()
	end

	InspectModelFrameControlFrameZoomOutButton:Point("LEFT", "InspectModelFrameControlFrameZoomInButton", "RIGHT", 2, 0)
	InspectModelFrameControlFramePanButton:Point("LEFT", "InspectModelFrameControlFrameZoomOutButton", "RIGHT", 2, 0)
	InspectModelFrameControlFrameRotateRightButton:Point("LEFT", "InspectModelFrameControlFramePanButton", "RIGHT", 2, 0)
	InspectModelFrameControlFrameRotateLeftButton:Point("LEFT", "InspectModelFrameControlFrameRotateRightButton", "RIGHT", 2, 0)
	InspectModelFrameControlFrameRotateResetButton:Point("LEFT", "InspectModelFrameControlFrameRotateLeftButton", "RIGHT", 2, 0)

	--Talent Tab
	InspectTalentFrame:StripTextures()

	Specialization.ring:SetTexture("")
	Specialization:CreateBackdrop()
	Specialization.backdrop:SetOutside(Specialization.specIcon)
	Specialization.specIcon:SetTexCoord(unpack(E.TexCoords))

	Specialization.bg = CreateFrame("Frame", nil, Specialization)
	Specialization.bg:SetTemplate("Default", true)
	Specialization.bg:Point("TOPLEFT", 17, -15)
	Specialization.bg:Point("BOTTOMRIGHT", 20, 10)
	Specialization.bg:SetFrameLevel(Specialization.bg:GetFrameLevel() - 2)

	Specialization:HookScript("OnShow", function(self)
		if INSPECTED_UNIT ~= nil then
			Spec = GetInspectSpecialization(INSPECTED_UNIT)
			Sex = UnitSex(INSPECTED_UNIT)
		end

		if Spec ~= nil and Spec > 0 and Sex ~= nil then
			local Role = GetSpecializationRoleByID(Spec)

			if Role ~= nil then
				self.specIcon:SetTexture(select(4, GetSpecializationInfoByID(Spec, Sex)))

				if Role == "DAMAGER" then
					self.roleIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\dps.tga")
					self.roleIcon:Size(19)
				elseif Role == "TANK" then
					self.roleIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\tank.tga")
					self.roleIcon:Size(20)
				elseif Role == "HEALER" then
					self.roleIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\healer.tga")
					self.roleIcon:Size(20)
				end
				self.roleIcon:SetTexCoord(unpack(E.TexCoords))

				self.roleName:SetTextColor(1, 1, 1)
			end
		end
	end)

	for i = 1, 6 do
		for j = 1, 3 do
			local button = _G["TalentsTalentRow"..i.."Talent"..j]

			if button then
				button:StripTextures()
				button:CreateBackdrop()
				button.backdrop:SetOutside(button.icon)
				button.icon:SetTexCoord(unpack(E.TexCoords))

				hooksecurefunc(button.border, "Show", function()
					button.backdrop:SetBackdropBorderColor(0, 0.44, .87)
				end)

				hooksecurefunc(button.border, "Hide", function()
					button.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				end)
			end
		end
	end

	InspectTalentFrame:HookScript("OnShow", function(self)
		if self.isGlyphsDone then return end

		for i = 1, 6 do
			local Glyph = InspectGlyphs["Glyph"..i]

			Glyph:SetTemplate("Default", true)
			Glyph:StyleButton(nil, true)
			Glyph:SetFrameLevel(Glyph:GetFrameLevel() + 5)
			Glyph.ring:Kill()
			Glyph.highlight:SetTexture(nil)
			Glyph.glyph:Kill()

			Glyph.icon = Glyph:CreateTexture(nil, "OVERLAY")
			Glyph.icon:SetInside()
			Glyph.icon:SetTexCoord(unpack(E.TexCoords))

			if i % 2 == 1 then
				Glyph:Size(Glyph:GetWidth() * .6, Glyph:GetHeight() * .6)
			else
				Glyph:Size(Glyph:GetWidth() * .8, Glyph:GetHeight() * .8)
			end
		end

		InspectGlyphs.Glyph1:Point("TOPLEFT", 90, -7)
		InspectGlyphs.Glyph2:Point("TOPLEFT", 15, 0)
		InspectGlyphs.Glyph3:Point("TOPLEFT", 90, -97)
		InspectGlyphs.Glyph4:Point("TOPLEFT", 15, -90)
		InspectGlyphs.Glyph5:Point("TOPLEFT", 90, -187)
		InspectGlyphs.Glyph6:Point("TOPLEFT", 15, -180)

		InspectGlyphFrameGlyph_UpdateGlyphs(self.InspectGlyphs, false)

		self.isGlyphsDone = true
	end)

	hooksecurefunc("InspectGlyphFrameGlyph_UpdateSlot", function(self)
		local id = self:GetID()
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup
		local enabled, glyphType, _, glyphSpell, iconFilename = GetGlyphSocketInfo(id, talentGroup, true, INSPECTED_UNIT)

		if self.icon then
			self.icon:SetTexture("Interface\\Spellbook\\UI-Glyph-Rune1")
		end
		if not glyphType then
			return
		end
		if not enabled then
		elseif(not glyphSpell or (clear == true)) then
		else
			if self.icon then
				if iconFilename then
					self.icon:SetTexture(iconFilename)
				end
			end
		end
	end)

	--PVP Tab
	InspectPVPFrame:StripTextures()

	for _, Section in pairs({"RatedBG", "Arena2v2", "Arena3v3", "Arena5v5"}) do
		local Frame = InspectPVPFrame[Section]
		Frame:SetTemplate("Transparent")
		Frame:EnableMouse(true)

		Frame:SetScript("OnEnter", function(self)
			self:SetBackdropBorderColor(0, 0.44, .87, 1)
		end)

		Frame:SetScript("OnLeave", function(self)
			self:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		end)
	end

	--Guild Tab
	InspectGuildFrameBG:SetDesaturated(true)
end

S:AddCallbackForAddon("Blizzard_InspectUI", "Inspect", LoadSkin)