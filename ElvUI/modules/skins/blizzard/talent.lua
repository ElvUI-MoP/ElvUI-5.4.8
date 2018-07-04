local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs, select, unpack = pairs, select, unpack

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetNumSpecializations = GetNumSpecializations
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecializationSpells = GetSpecializationSpells
local GetSpellTexture = GetSpellTexture

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true then return end

	local PlayerTalentFrame = _G["PlayerTalentFrame"]
	PlayerTalentFrame:StripTextures()
	PlayerTalentFrame:CreateBackdrop("Transparent")
	PlayerTalentFrame.backdrop:Point("BOTTOMRIGHT", PlayerTalentFrame, 0, -6)

	PlayerTalentFrameTalents:StripTextures()

	PlayerTalentFrameInset:StripTextures()
	PlayerTalentFrameInset:CreateBackdrop("Default")
	PlayerTalentFrameInset.backdrop:Hide()

	PlayerTalentFrameSpecializationTutorialButton:Kill()
	PlayerTalentFrameTalentsTutorialButton:Kill()
	PlayerTalentFramePetSpecializationTutorialButton:Kill()

	S:HandleCloseButton(PlayerTalentFrameCloseButton)

	S:HandleButton(PlayerTalentFrameActivateButton)

	local buttons = {
		PlayerTalentFrameSpecializationLearnButton,
		PlayerTalentFrameTalentsLearnButton,
		PlayerTalentFramePetSpecializationLearnButton
	}

	for _, button in pairs(buttons) do
		S:HandleButton(button, true)
		local point, anchor, anchorPoint, x = button:GetPoint()
		button:Point(point, anchor, anchorPoint, x, -28)
	end

	PlayerTalentFrameTalentsClearInfoFrame:CreateBackdrop("Default")
	PlayerTalentFrameTalentsClearInfoFrame:Point("TOPLEFT", PlayerTalentFrameTalents, "BOTTOMLEFT", 28, -5)
	PlayerTalentFrameTalentsClearInfoFrame:Size(20)
	PlayerTalentFrameTalentsClearInfoFrame:StyleButton()
	PlayerTalentFrameTalentsClearInfoFrame.icon:SetTexCoord(unpack(E.TexCoords))
	PlayerTalentFrameTalentsClearInfoFrame.count:FontTemplate(nil, 12, "OUTLINE")
	PlayerTalentFrameTalentsClearInfoFrame.count:Point("BOTTOMRIGHT", -20, 4)

	for i = 1, 4 do
		S:HandleTab(_G["PlayerTalentFrameTab"..i])

		if i == 1 then
			local point, anchor, anchorPoint, x = _G["PlayerTalentFrameTab"..i]:GetPoint()
			_G["PlayerTalentFrameTab"..i]:Point(point, anchor, anchorPoint, x, -4)
		end
	end

	hooksecurefunc("PlayerTalentFrame_UpdateTabs", function()
		for i = 1, 4 do
			local point, anchor, anchorPoint, x = _G["PlayerTalentFrameTab"..i]:GetPoint()
			_G["PlayerTalentFrameTab"..i]:Point(point, anchor, anchorPoint, x, -4)
		end
	end)

	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.Seperator:SetTexture(1, 1, 1)
	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.Seperator:SetAlpha(0.2)

	for i = 1, 2 do
		local tab = _G["PlayerSpecTab"..i]

		_G["PlayerSpecTab"..i.."Background"]:Kill()

		tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		tab:GetNormalTexture():SetInside()

		tab.pushed = true
		tab:CreateBackdrop("Default")
		tab.backdrop:SetAllPoints()
		tab:StyleButton(true)	

		tab:SetHighlightTexture("")
		tab.SetHighlightTexture = E.noop
	end

	hooksecurefunc("PlayerTalentFrame_UpdateSpecs", function()
		local point, relatedTo, point2, _, y = PlayerSpecTab1:GetPoint()
		PlayerSpecTab1:Point(point, relatedTo, point2, E.PixelMode and -1 or 1, y)
	end)

	for i = 1, MAX_NUM_TALENT_TIERS do
		local row = _G["PlayerTalentFrameTalentsTalentRow"..i]

		_G["PlayerTalentFrameTalentsTalentRow"..i.."Bg"]:Hide()
		row:DisableDrawLayer("BORDER")
		row:StripTextures()

		row.TopLine:Point("TOP", 0, 4)
		row.BottomLine:Point("BOTTOM", 0, -4)

		for j = 1, NUM_TALENT_COLUMNS do
			local button = _G["PlayerTalentFrameTalentsTalentRow"..i.."Talent"..j]
			local icon = _G["PlayerTalentFrameTalentsTalentRow"..i.."Talent"..j.."IconTexture"]
			local level = _G["PlayerTalentFrameTalentsTalentRow"..i.."Level"]
			local leftCap = _G["PlayerTalentFrameTalentsTalentRow"..i.."LeftCap"]

			button:StripTextures()
			button:SetFrameLevel(button:GetFrameLevel() + 5)
			button:CreateBackdrop("Default")
			button.backdrop:SetOutside(icon)

			icon:SetDrawLayer("OVERLAY", 1)
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:Size(48)
			icon:Point("TOPLEFT", 15, -1)

			button.bg = CreateFrame("Frame", nil, button)
			button.bg:CreateBackdrop("Overlay", true)
			button.bg:SetFrameLevel(button:GetFrameLevel() -2)
			button.bg:Point("TOPLEFT", 15, -1)
			button.bg:Point("BOTTOMRIGHT", -10, 1)

			button.bg.SelectedTexture = button.bg:CreateTexture(nil, "ARTWORK")
			button.bg.SelectedTexture:Point("TOPLEFT", button, 15, -1)
			button.bg.SelectedTexture:Point("BOTTOMRIGHT", button, -10, 1)

			button.ShadowedTexture = button:CreateTexture(nil, "OVERLAY", nil, 2)
			button.ShadowedTexture:SetAllPoints(button.bg.SelectedTexture)
			button.ShadowedTexture:SetTexture(0, 0, 0, 0.6)

			button.bg2 = CreateFrame("Frame", nil, button)
			button.bg2:CreateBackdrop("Default", true)
			button.bg2:Point("TOPLEFT", level, -3, 4)
			button.bg2:Point("BOTTOMRIGHT", level, 2, -1)

			level:SetParent(button.bg2)
			level:FontTemplate(nil, 18, "OUTLINE")
			level:Point("CENTER", leftCap, "RIGHT", 0, 0)
		end
	end

	hooksecurefunc("TalentFrame_Update", function()
		for i = 1, MAX_NUM_TALENT_TIERS do
			for j = 1, NUM_TALENT_COLUMNS do
				local button = _G["PlayerTalentFrameTalentsTalentRow"..i.."Talent"..j]

				if button.bg and button.knownSelection then
					if button.knownSelection:IsShown() then
						button.bg.SelectedTexture:Show()
						button.bg.SelectedTexture:SetTexture(0, 0.7, 1, 0.20)
						button.ShadowedTexture:Hide()
					else
						button.bg.SelectedTexture:Hide()
						button.ShadowedTexture:Show()
					end
				end

				if button.bg and button.learnSelection then
					if button.learnSelection:IsShown() then
						button.bg.SelectedTexture:Show()
						button.bg.SelectedTexture:SetTexture(1, 1, 1, 0.30)
						button.ShadowedTexture:Hide()
					end
				end
			end
		end
	end)

	for i = 1, 5 do
		select(i, PlayerTalentFrameSpecializationSpellScrollFrameScrollChild:GetRegions()):Hide()
	end

	local pspecspell = _G["PlayerTalentFrameSpecializationSpellScrollFrameScrollChild"]
	local specspell2 = _G["PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild"]

	pspecspell.ring:Hide()
	pspecspell:CreateBackdrop("Default")
	pspecspell.backdrop:SetOutside(pspecspell.specIcon)
	pspecspell.specIcon:SetTexCoord(unpack(E.TexCoords))
	pspecspell.specIcon:SetParent(pspecspell.backdrop)

	specspell2.ring:Hide()
	specspell2:CreateBackdrop("Default")
	specspell2.backdrop:SetOutside(specspell2.specIcon)
	specspell2.specIcon:SetTexCoord(unpack(E.TexCoords))
	specspell2.specIcon:SetParent(specspell2.backdrop)

	PlayerTalentFrameSpecialization:CreateBackdrop("Transparent", true)
	PlayerTalentFrameSpecialization.backdrop:Point("TOPLEFT", 235, -16)
	PlayerTalentFrameSpecialization.backdrop:Point("BOTTOMRIGHT", -17, 329)

	PlayerTalentFrameSpecialization:DisableDrawLayer("ARTWORK")
	PlayerTalentFrameSpecialization:DisableDrawLayer("BORDER")

	for i = 1, PlayerTalentFrameSpecialization:GetNumChildren() do
		local child = select(i, PlayerTalentFrameSpecialization:GetChildren())
		if child and not child:GetName() then
			child:DisableDrawLayer("OVERLAY")
		end
	end

	hooksecurefunc("PlayerTalentFrame_UpdateSpecFrame", function(self, spec)
		local playerTalentSpec = GetSpecialization(nil, self.isPet, PlayerSpecTab2:GetChecked() and 2 or 1)
		local shownSpec = spec or playerTalentSpec or 1

		local id, _, _, icon = GetSpecializationInfo(shownSpec, nil, self.isPet)
		local scrollChild = self.spellsScroll.child

		scrollChild.specIcon:SetTexture(icon)

		local role1 = GetSpecializationRole(shownSpec, nil, self.isPet)

		if role1 == "DAMAGER" then
			scrollChild.roleIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\dps.tga")
			scrollChild.roleIcon:Size(20)
		elseif role1 == "TANK" then
			scrollChild.roleIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\tank.tga")
			scrollChild.roleIcon:Size(23)
		elseif role1 == "HEALER" then
			scrollChild.roleIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\healer.tga")
			scrollChild.roleIcon:Size(21)
		end

		scrollChild.roleIcon:SetTexCoord(unpack(E.TexCoords))

		local bonuses
		if self.isPet then
			bonuses = {GetSpecializationSpells(shownSpec, nil, self.isPet)}
		else
			bonuses = SPEC_SPELLS_DISPLAY[id]
		end

		if bonuses then
			local index = 1
			for i = 1, #bonuses, 2 do
				local frame = scrollChild["abilityButton"..index]
				if frame then
					local _, spellTex = GetSpellTexture(bonuses[i])
					if spellTex then
						frame.icon:SetTexture(spellTex)
					end

					if mod(index, 2) == 0 then
						frame:Point("LEFT", scrollChild["abilityButton"..(index - 1)], "RIGHT", 141, 0)
					else
						if (#bonuses / 2) > 4 then
							frame:Point("TOP", scrollChild["abilityButton"..(index - 2)], "BOTTOM", 0, -5)
						else
							frame:Point("TOP", scrollChild["abilityButton"..(index - 2)], "BOTTOM", 0, -5)
						end
					end

					if not frame.isSkinned then
						frame:SetTemplate()
						frame:StyleButton(nil, true)
						frame:Size(45)

						frame.bg = CreateFrame("Frame", nil, frame)
						frame.bg:SetTemplate("Transparent", true)
						frame.bg:Point("TOPLEFT", 44, 0)
						frame.bg:Point("BOTTOMRIGHT", 137, 0)

						frame.icon:SetTexCoord(unpack(E.TexCoords))
						frame.icon:SetInside()

						frame.name:SetTextColor(1, 0.80, 0.10)
						frame.name:Point("LEFT", frame.icon, "RIGHT", 7, 2)
						frame.name:SetParent(frame.bg)

						frame.subText:SetTextColor(1, 1, 1)
						frame.subText:SetParent(frame.bg)

						frame.ring:Hide()

						frame.isSkinned = true
					end
				end
				index = index + 1
			end
		end

		for i = 1, GetNumSpecializations(nil, self.isPet) do
			local button = self["specButton"..i]
			button.SelectedTexture:SetInside(button.backdrop)

			if button.selected then
				button.SelectedTexture:Show()
			else
				button.SelectedTexture:Hide()
			end
		end
	end)

	for i = 1, GetNumSpecializations(false, nil) do
		local button = PlayerTalentFrameSpecialization["specButton"..i]
		local _, _, _, icon = GetSpecializationInfo(i, false, nil)
		local role = GetSpecializationRole(i, false, nil)

		if role == "DAMAGER" then
			button.roleIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\dps.tga")
			button.roleIcon:Size(19)
		elseif role == "TANK" then
			button.roleIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\tank.tga")
			button.roleIcon:Size(20)
		elseif role == "HEALER" then
			button.roleIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\healer.tga")
			button.roleIcon:Size(20)
		end

		button.roleIcon:SetTexCoord(unpack(E.TexCoords))
		button.roleName:SetTextColor(0.75, 0.75, 0.75)
		button.ring:Hide()

		button:CreateBackdrop()
		button.backdrop:SetOutside(button.specIcon)
		button.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() + 2)

		button.specIcon:SetTexture(icon)
		button.specIcon:Size(60)
		button.specIcon:SetTexCoord(unpack(E.TexCoords))
		button.specIcon:Point("LEFT", button, 0, 0)
		button.specIcon:SetParent(button.backdrop)

		button.SelectedTexture = button:CreateTexture(nil, "ARTWORK")
		button.SelectedTexture:SetTexture(0, 0.7, 1, 0.20)
	end

	local buttons = {"PlayerTalentFrameSpecializationSpecButton", "PlayerTalentFramePetSpecializationSpecButton"}

	for _, name in pairs(buttons) do
		for i = 1, 4 do
			local button = _G[name..i]
			_G["PlayerTalentFrameSpecializationSpecButton"..i.."Glow"]:Kill()

			local texture = button:CreateTexture(nil, "ARTWORK")
			texture:SetTexture(1, 1, 1, 0.1)
			button:SetHighlightTexture(texture)

			button.bg:SetAlpha(0)
			button.learnedTex:SetAlpha(0)
			button.selectedTex:SetAlpha(0)

			button:CreateBackdrop()

			button:GetHighlightTexture():SetInside(button.backdrop)
		end
	end

	-- Hunter Pet Talents
	if E.myclass == "HUNTER" then
		for i = 1, 6 do
			select(i, PlayerTalentFramePetSpecialization:GetRegions()):Hide()
		end

		for i = 1, PlayerTalentFramePetSpecialization:GetNumChildren() do
			local child = select(i, PlayerTalentFramePetSpecialization:GetChildren())
			if child and not child:GetName() then
				child:DisableDrawLayer("OVERLAY")
			end
		end

		for i = 1, 5 do
			select(i, PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild:GetRegions()):Hide()
		end

		PlayerTalentFramePetSpecialization:CreateBackdrop("Transparent", true)
		PlayerTalentFramePetSpecialization.backdrop:Point("TOPLEFT", 234, -16)
		PlayerTalentFramePetSpecialization.backdrop:Point("BOTTOMRIGHT", -17, 329)

		for i = 1, GetNumSpecializations(false, true) do
			local button = PlayerTalentFramePetSpecialization["specButton"..i]
			local glow = _G["PlayerTalentFramePetSpecializationSpecButton"..i.."Glow"]
			local _, _, _, icon = GetSpecializationInfo(i, false, true)
			local role = GetSpecializationRole(i, false, true)

			if role == "DAMAGER" then
				button.roleIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\dps.tga")
				button.roleIcon:Size(19)
			else
				button.roleIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\tank.tga")
				button.roleIcon:Size(20)
			end

			button.roleIcon:SetTexCoord(unpack(E.TexCoords))
			button.roleName:SetTextColor(0.75, 0.75, 0.75)
			button.ring:Hide()

			glow:Kill()

			button:CreateBackdrop()
			button.backdrop:SetOutside(button.specIcon)
			button.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() + 2)

			button.specIcon:SetTexture(icon)
			button.specIcon:Size(58)
			button.specIcon:SetTexCoord(unpack(E.TexCoords))
			button.specIcon:Point("LEFT", button, 0, 0)
			button.specIcon:SetParent(button.backdrop)

			button.SelectedTexture = button:CreateTexture(nil, "ARTWORK")
			button.SelectedTexture:SetTexture(0, 0.7, 1, 0.20)
		end

		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.Seperator:SetTexture(1, 1, 1)
		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.Seperator:SetAlpha(0.2)
	end
end

S:AddCallbackForAddon("Blizzard_TalentUI", "Talent", LoadSkin)