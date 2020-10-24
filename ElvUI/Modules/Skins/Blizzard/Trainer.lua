local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.trainer then return end

	ClassTrainerFrame:StripTextures()
	ClassTrainerFrame:CreateBackdrop("Transparent")
	ClassTrainerFrame.backdrop:Point("TOPLEFT", 4, 0)
	ClassTrainerFrame:Height(472)

	ClassTrainerFrameBottomInset:StripTextures()

	ClassTrainerFrameInset:Kill()
	ClassTrainerFramePortrait:Kill()

	S:HandleButton(ClassTrainerTrainButton)
	ClassTrainerTrainButton:Point("BOTTOMRIGHT", -5, 5)

	S:HandleDropDownBox(ClassTrainerFrameFilterDropDown)
	ClassTrainerFrameFilterDropDown:Point("TOPRIGHT", 0, -52)

	S:HandleCloseButton(ClassTrainerFrameCloseButton, ClassTrainerFrame)

	-- Status Bar
	ClassTrainerStatusBar:StripTextures()
	ClassTrainerStatusBar:CreateBackdrop()
	ClassTrainerStatusBar:Size(321, 18)
	ClassTrainerStatusBar:SetStatusBarTexture(E.media.normTex)
	ClassTrainerStatusBar:SetStatusBarColor(0.22, 0.39, 0.84)
	ClassTrainerStatusBar:ClearAllPoints()
	ClassTrainerStatusBar:Point("TOP", ClassTrainerFrame, 3, -30)

	ClassTrainerStatusBar.rankText:Point("CENTER")
	ClassTrainerStatusBar.rankText:FontTemplate(nil, 12, "OUTLINE")

	-- Step Button
	ClassTrainerFrameSkillStepButton:StripTextures()
	ClassTrainerFrameSkillStepButton:SetTemplate("Transparent")
	ClassTrainerFrameSkillStepButton:Size(322, 40)
	ClassTrainerFrameSkillStepButton:Point("TOPLEFT", ClassTrainerFrameInset, 5, -5)

	ClassTrainerFrameSkillStepButton.selectedTex:SetTexture(1, 1, 1, 0.3)
	ClassTrainerFrameSkillStepButton.selectedTex:SetInside()

	ClassTrainerFrameSkillStepButton.bg = CreateFrame("Frame", nil, ClassTrainerFrameSkillStepButton)
	ClassTrainerFrameSkillStepButton.bg:SetTemplate()
	ClassTrainerFrameSkillStepButton.bg:SetOutside(ClassTrainerFrameSkillStepButton.icon)

	ClassTrainerFrameSkillStepButton.icon:SetTexCoord(unpack(E.TexCoords))
	ClassTrainerFrameSkillStepButton.icon:Point("TOPLEFT", E.PixelMode and 0 or 4, -(E.PixelMode and 1 or 4))
	ClassTrainerFrameSkillStepButton.icon:Size(E.PixelMode and 38 or 32)
	ClassTrainerFrameSkillStepButton.icon:SetParent(ClassTrainerFrameSkillStepButton.bg)

	ClassTrainerFrameSkillStepButton.name:Point("TOPLEFT", 42, -1)

	ClassTrainerFrameSkillStepButtonMoneyFrame:Point("TOPRIGHT", 10, -3)

	-- Scroll Frame
	ClassTrainerScrollFrame:CreateBackdrop("Transparent")
	ClassTrainerScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -3)

	S:HandleScrollBar(ClassTrainerScrollFrameScrollBar)
	ClassTrainerScrollFrameScrollBar:ClearAllPoints()
	ClassTrainerScrollFrameScrollBar:Point("TOPRIGHT", ClassTrainerScrollFrame, 23, -15)
	ClassTrainerScrollFrameScrollBar:Point("BOTTOMRIGHT", ClassTrainerScrollFrame, 0, 13)

	for i = 1, 8 do
		local button = _G["ClassTrainerScrollFrameButton"..i]

		button:StripTextures()

		button.selectedTex:SetTexture(E.Media.Textures.Highlight)
		button.selectedTex:SetVertexColor(1, 0.8, 0.1, 0.35)
		button.selectedTex:SetTexCoord(0, 1, 0, 1)
		button.selectedTex.SetTexCoord = E.noop
		button.selectedTex:Point("TOPLEFT", 48, -(E.PixelMode and 1 or 3))
		button.selectedTex:Point("BOTTOMRIGHT")

		S:HandleButtonHighlight(button)
		button.handledHighlight:Point("TOPLEFT", 48, -(E.PixelMode and 1 or 3))
		button.handledHighlight:Point("BOTTOMRIGHT")

		button.bg = CreateFrame("Frame", nil, button)
		button.bg:SetTemplate()
		button.bg:SetOutside(button.icon)

		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.icon:Size(E.PixelMode and 44 or 40)
		button.icon:Point("TOPLEFT", E.PixelMode and 3 or 6, -(E.PixelMode and 2 or 3))
		button.icon:SetParent(button.bg)

		button.money:Point("TOPRIGHT", 9, -2)
	end
end

S:AddCallbackForAddon("Blizzard_TrainerUI", "Trainer", LoadSkin)