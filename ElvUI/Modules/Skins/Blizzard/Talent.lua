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
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.talent then return end

	PlayerTalentFrame:StripTextures()
	PlayerTalentFrame:CreateBackdrop("Transparent")
	PlayerTalentFrame.backdrop:Point("BOTTOMRIGHT", PlayerTalentFrame, 0, -6)

	PlayerTalentFrameTalents:StripTextures()

	PlayerTalentFrameInset:StripTextures()
	PlayerTalentFrameInset:CreateBackdrop()
	PlayerTalentFrameInset.backdrop:Hide()

	PlayerTalentFrameSpecializationTutorialButton:Kill()
	PlayerTalentFrameTalentsTutorialButton:Kill()
	PlayerTalentFramePetSpecializationTutorialButton:Kill()

	S:HandleCloseButton(PlayerTalentFrameCloseButton)

	S:HandleButton(PlayerTalentFrameActivateButton)
	PlayerTalentFrameActivateButton:Point("BOTTOMRIGHT", -8, -1)

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

	for i = 1, 4 do
		S:HandleTab(_G["PlayerTalentFrameTab"..i])
	end

	hooksecurefunc("PlayerTalentFrame_UpdateTabs", function()
		for i = 1, 4 do
			local tab = _G["PlayerTalentFrameTab"..i]
			local point, anchor, anchorPoint, x = tab:GetPoint()

			tab:Point(point, anchor, anchorPoint, x, -4)
		end
	end)

	-- Spec Buttons
	for _, frame in pairs({"PlayerTalentFrameSpecializationSpecButton", "PlayerTalentFramePetSpecializationSpecButton"}) do
		for i = 1, 4 do
			local button = _G[frame..i]

			button:SetTemplate("Transparent")
			button:CreateBackdrop()
			button.backdrop:SetOutside(button.specIcon)
			button.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() + 3)
			button:StyleButton()

			button.roleIcon:SetTexCoord(unpack(E.TexCoords))
			button.roleName:SetTextColor(0.75, 0.75, 0.75)

			button.specIcon:Size(58)
			button.specIcon:SetTexCoord(unpack(E.TexCoords))
			button.specIcon:Point("LEFT", button)
			button.specIcon:SetParent(button.backdrop)

			button.bg:SetAlpha(0)
			button.learnedTex:SetAlpha(0)
			button.selectedTex:SetAlpha(0)

			button.ring:Hide()

			_G[frame..i.."Glow"]:Kill()
		end
	end

	-- Player Spec Frame
	for i = 1, PlayerTalentFrameSpecialization:GetNumChildren() do
		local child = select(i, PlayerTalentFrameSpecialization:GetChildren())

		if child and not child:GetName() then
			child:DisableDrawLayer("OVERLAY")
		end
	end

	PlayerTalentFrameSpecialization:StripTextures()
	PlayerTalentFrameSpecialization:CreateBackdrop("Transparent")
	PlayerTalentFrameSpecialization.backdrop:Point("TOPLEFT", 235, -16)
	PlayerTalentFrameSpecialization.backdrop:Point("BOTTOMRIGHT", -17, 330)

	for i = 1, 5 do
		select(i, PlayerTalentFrameSpecializationSpellScrollFrameScrollChild:GetRegions()):Hide()
	end

	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild:CreateBackdrop()
	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.backdrop:SetOutside(PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.specIcon)

	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.specIcon:SetTexCoord(unpack(E.TexCoords))
	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.specIcon:SetParent(PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.backdrop)

	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.Seperator:SetTexture(1, 1, 1)
	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.Seperator:SetAlpha(0.2)

	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.ring:Hide()

	for i = 1, GetNumSpecializations(false, nil) do
		local button = PlayerTalentFrameSpecialization["specButton"..i]
		local _, _, _, icon = GetSpecializationInfo(i, false, nil)
		local role = GetSpecializationRole(i, false, nil)

		button.specIcon:SetTexture(icon)

		if role == "DAMAGER" then
			button.roleIcon:SetTexture(E.Media.Textures.DPS)
			button.roleIcon:Size(19)
		elseif role == "TANK" then
			button.roleIcon:SetTexture(E.Media.Textures.Tank)
			button.roleIcon:Size(20)
		elseif role == "HEALER" then
			button.roleIcon:SetTexture(E.Media.Textures.Healer)
			button.roleIcon:Size(20)
		end
	end

	-- Pet Spec Frame
	if E.myclass == "HUNTER" then
		for i = 1, PlayerTalentFramePetSpecialization:GetNumChildren() do
			local child = select(i, PlayerTalentFramePetSpecialization:GetChildren())
			if child and not child:GetName() then
				child:DisableDrawLayer("OVERLAY")
			end
		end

		PlayerTalentFramePetSpecialization:StripTextures()
		PlayerTalentFramePetSpecialization:CreateBackdrop("Transparent")
		PlayerTalentFramePetSpecialization.backdrop:Point("TOPLEFT", 235, -16)
		PlayerTalentFramePetSpecialization.backdrop:Point("BOTTOMRIGHT", -17, 330)

		for i = 1, 5 do
			select(i, PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild:GetRegions()):Hide()
		end

		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild:CreateBackdrop()
		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.backdrop:SetOutside(PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.specIcon)

		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.specIcon:SetTexCoord(unpack(E.TexCoords))
		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.specIcon:SetParent(PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.backdrop)

		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.Seperator:SetTexture(1, 1, 1)
		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.Seperator:SetAlpha(0.2)

		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.ring:Hide()

		for i = 1, GetNumSpecializations(false, true) do
			local button = PlayerTalentFramePetSpecialization["specButton"..i]
			local _, _, _, icon = GetSpecializationInfo(i, false, true)
			local role = GetSpecializationRole(i, false, true)

			button.specIcon:SetTexture(icon)

			if role == "DAMAGER" then
				button.roleIcon:SetTexture(E.Media.Textures.DPS)
				button.roleIcon:Size(19)
			else
				button.roleIcon:SetTexture(E.Media.Textures.Tank)
				button.roleIcon:Size(20)
			end
		end
	end

	hooksecurefunc("PlayerTalentFrame_UpdateSpecFrame", function(self, spec)
		local button = self.spellsScroll.child
		local playerTalentSpec = GetSpecialization(nil, self.isPet, PlayerSpecTab2:GetChecked() and 2 or 1)
		local shownSpec = spec or playerTalentSpec or 1
		local id, _, _, icon = GetSpecializationInfo(shownSpec, nil, self.isPet)
		local role = GetSpecializationRole(shownSpec, nil, self.isPet)
		local bonuses = self.isPet and {GetSpecializationSpells(shownSpec, nil, self.isPet)} or SPEC_SPELLS_DISPLAY[id]
		local numSpecs = GetNumSpecializations(nil, self.isPet)

		for i = 1, numSpecs do
			local specButton = self["specButton"..i]
			local border = specButton.selected and E.media.rgbvaluecolor or E.media.bordercolor

			specButton:SetBackdropBorderColor(unpack(border))
			specButton.backdrop:SetBackdropBorderColor(unpack(border))
		end

		if role == "DAMAGER" then
			button.roleIcon:SetTexture(E.Media.Textures.DPS)
			button.roleIcon:Size(20)
		elseif role == "TANK" then
			button.roleIcon:SetTexture(E.Media.Textures.Tank)
			button.roleIcon:Size(24)
		elseif role == "HEALER" then
			button.roleIcon:SetTexture(E.Media.Textures.Healer)
			button.roleIcon:Size(22)
		end

		button.roleIcon:SetTexCoord(0, 1, 0, 1)
		button.specIcon:SetTexture(icon)

		if bonuses then
			local index = 1

			for i = 1, #bonuses, 2 do
				local frame = button["abilityButton"..index]

				if frame then
					local _, spellTex = GetSpellTexture(bonuses[i])

					if spellTex then
						frame.icon:SetTexture(spellTex)
					end

					if mod(index, 2) == 0 then
						frame:Point("LEFT", button["abilityButton"..(index - 1)], "RIGHT", 141, 0)
					else
						if (#bonuses / 2) > 4 then
							frame:Point("TOP", button["abilityButton"..(index - 2)], "BOTTOM", 0, -5)
						else
							frame:Point("TOP", button["abilityButton"..(index - 2)], "BOTTOM", 0, -5)
						end
					end

					if not frame.isSkinned then
						frame:SetTemplate()
						frame:StyleButton(nil, true)
						frame:Size(45)

						frame.bg = CreateFrame("Frame", nil, frame)
						frame.bg:SetTemplate("Transparent")
						frame.bg:Point("TOPLEFT", 44, 0)
						frame.bg:Point("BOTTOMRIGHT", 137, 0)

						frame.icon:SetTexCoord(unpack(E.TexCoords))
						frame.icon:SetInside()

						frame.name:SetTextColor(1, 0.80, 0.10)
						frame.name:Point("LEFT", frame.icon, "RIGHT", 7, 2)
						frame.name:SetParent(frame.bg)

						frame.subText:SetParent(frame.bg)

						frame.ring:Hide()

						frame.isSkinned = true
					end

					frame.subText:SetTextColor(1, 1, 1)
				end

				index = index + 1
			end
		end
	end)

	-- Side Tabs
	for i = 1, 2 do
		local tab = _G["PlayerSpecTab"..i]
		local icon = tab:GetNormalTexture()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		tab:CreateBackdrop()
		tab.backdrop:SetAllPoints()
		tab:StyleButton(nil, true)

		tab:GetHighlightTexture():SetTexture(1, 1, 1, 0.3)

		_G["PlayerSpecTab"..i.."Background"]:Kill()
	end

	hooksecurefunc("PlayerTalentFrame_UpdateSpecs", function()
		local point, relatedTo, point2, _, y = PlayerSpecTab1:GetPoint()
		PlayerSpecTab1:Point(point, relatedTo, point2, E.PixelMode and -1 or 1, y)
	end)

	-- Talents
	for i = 1, MAX_NUM_TALENT_TIERS do
		local row = _G["PlayerTalentFrameTalentsTalentRow"..i]

		_G["PlayerTalentFrameTalentsTalentRow"..i.."Bg"]:Hide()
		row:DisableDrawLayer("BORDER")
		row:StripTextures()

		row.TopLine:Point("TOP", 0, 4)
		row.BottomLine:Point("BOTTOM", 0, -4)

		for j = 1, NUM_TALENT_COLUMNS do
			local button = _G["PlayerTalentFrameTalentsTalentRow"..i.."Talent"..j]
			local level = _G["PlayerTalentFrameTalentsTalentRow"..i.."Level"]

			button:StripTextures()
			button:SetFrameLevel(button:GetFrameLevel() + 5)
			button:CreateBackdrop()
			button.backdrop:SetOutside(button.icon)

			button.icon:SetDrawLayer("OVERLAY", 1)
			button.icon:SetTexCoord(unpack(E.TexCoords))
			button.icon:Size(48)
			button.icon:Point("TOPLEFT", 15, -1)

			button.bg = CreateFrame("Frame", nil, button)
			button.bg:CreateBackdrop("Default", true)
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
			level:FontTemplate(nil, 18)
			level:Point("CENTER", _G["PlayerTalentFrameTalentsTalentRow"..i.."LeftCap"], "RIGHT", 0, 0)
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

	-- Clear Info
	PlayerTalentFrameTalentsClearInfoFrame:CreateBackdrop()
	PlayerTalentFrameTalentsClearInfoFrame.backdrop:SetAllPoints()
	PlayerTalentFrameTalentsClearInfoFrame:StyleButton()
	PlayerTalentFrameTalentsClearInfoFrame:Size(E.PixelMode and 26 or 24)
	PlayerTalentFrameTalentsClearInfoFrame:Point("TOPLEFT", PlayerTalentFrameTalents, "BOTTOMLEFT", 2, E.PixelMode and -3 or -4)

	PlayerTalentFrameTalentsClearInfoFrame.icon:SetTexCoord(unpack(E.TexCoords))
	PlayerTalentFrameTalentsClearInfoFrame.icon:ClearAllPoints()
	PlayerTalentFrameTalentsClearInfoFrame.icon:SetInside()
end

S:AddCallbackForAddon("Blizzard_TalentUI", "Talent", LoadSkin)