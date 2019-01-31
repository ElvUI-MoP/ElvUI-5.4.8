local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.trainer ~= true then return end

	ClassTrainerScrollFrameScrollChild:StripTextures()
	ClassTrainerFrameBottomInset:StripTextures()

	ClassTrainerFrameInset:Kill()
	ClassTrainerFramePortrait:Kill()
	ClassTrainerScrollFrameScrollBarBG:Kill()
	ClassTrainerScrollFrameScrollBarTop:Kill()
	ClassTrainerScrollFrameScrollBarBottom:Kill()
	ClassTrainerScrollFrameScrollBarMiddle:Kill()

	for i = 1, 8 do
		local button = _G["ClassTrainerScrollFrameButton"..i]
		local icon = _G["ClassTrainerScrollFrameButton"..i.."Icon"]
		local money = _G["ClassTrainerScrollFrameButton"..i.."MoneyFrame"]

		button:StripTextures()
		button:CreateBackdrop()
		button.backdrop:SetInside()

		button.selectedTex:SetTexture(1, 1, 1, 0.3)
		button.selectedTex:SetInside(button.backdrop)
		button.selectedTex:SetParent(button.backdrop)

		money:SetScale(0.88)
		money:Point("TOPRIGHT", 9, -6)
		money:SetParent(button.backdrop)

		button.name:SetParent(button.backdrop)
		button.subText:SetParent(button.backdrop)

		button.bg = CreateFrame("Frame", nil, button)
		button.bg:SetTemplate("Default")
		button.bg:SetOutside(icon)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:Size(E.PixelMode and 43 or 34)
		if i == 1 then
			icon:Point("TOPLEFT", E.PixelMode and 2 or 7, E.PixelMode and -2 or -6)
		else
			icon:Point("TOPLEFT", E.PixelMode and 2 or 6, E.PixelMode and -2 or -6)
		end
		icon:SetParent(button.bg)
	end

	local ClassTrainerFrame = _G["ClassTrainerFrame"]
	ClassTrainerFrame:StripTextures()
	ClassTrainerFrame:CreateBackdrop("Transparent")
	ClassTrainerFrame:Height(ClassTrainerFrame:GetHeight() + 42)

	ClassTrainerTrainButton:StripTextures()
	S:HandleButton(ClassTrainerTrainButton)

	S:HandleCloseButton(ClassTrainerFrameCloseButton, ClassTrainerFrame)

	S:HandleScrollBar(ClassTrainerScrollFrameScrollBar, 5)

	S:HandleDropDownBox(ClassTrainerFrameFilterDropDown)
	ClassTrainerFrameFilterDropDown:Point("TOPRIGHT", -10, -50)

	ClassTrainerFrameSkillStepButton:StripTextures()
	ClassTrainerFrameSkillStepButton:SetTemplate()
	ClassTrainerFrameSkillStepButton:StyleButton()

	ClassTrainerFrameSkillStepButton.icon:SetTexCoord(unpack(E.TexCoords))
	ClassTrainerFrameSkillStepButton.icon:Point("TOPLEFT", E.PixelMode and 0 or 4, -(E.PixelMode and 1 or 4))
	ClassTrainerFrameSkillStepButton.icon:Size(E.PixelMode and 38 or 32)

	ClassTrainerFrameSkillStepButton.selectedTex:SetTexture(1, 1, 1, 0.3)
	ClassTrainerFrameSkillStepButton.selectedTex:SetInside()

	ClassTrainerFrameSkillStepButton.bg = CreateFrame("Frame", nil, ClassTrainerFrameSkillStepButton)
	ClassTrainerFrameSkillStepButton.bg:SetTemplate()
	ClassTrainerFrameSkillStepButton.bg:SetOutside(ClassTrainerFrameSkillStepButton.icon)

	ClassTrainerFrameSkillStepButton.icon:SetParent(ClassTrainerFrameSkillStepButton.bg)

	ClassTrainerFrameSkillStepButton.name:Point("TOPLEFT", 42, -1)

	ClassTrainerFrameSkillStepButtonMoneyFrame:SetScale(0.90)
	ClassTrainerFrameSkillStepButtonMoneyFrame:Point("TOPRIGHT", 10, -3)

	ClassTrainerStatusBar:StripTextures()
	ClassTrainerStatusBar:CreateBackdrop("Default")
	ClassTrainerStatusBar:Size(300, 18)
	ClassTrainerStatusBar:SetStatusBarTexture(E.media.normTex)
	ClassTrainerStatusBar:SetStatusBarColor(0.11, 0.50, 1.00)
	ClassTrainerStatusBar:ClearAllPoints()
	ClassTrainerStatusBar:Point("TOP", ClassTrainerFrame, "TOP", 0, -30)

	ClassTrainerStatusBar.rankText:Point("CENTER")
	ClassTrainerStatusBar.rankText:FontTemplate(nil, 12, "OUTLINE")
end

S:AddCallbackForAddon("Blizzard_TrainerUI", "Trainer", LoadSkin)