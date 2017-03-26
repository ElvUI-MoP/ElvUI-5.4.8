local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G
local unpack, select = unpack, select;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.trainer ~= true) then return; end

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
		button:SetTemplate("Default")
		button:CreateBackdrop()
		button.backdrop:SetOutside(icon)
		button:StyleButton()

		button.selectedTex:SetTexture(1, 1, 1, 0.3)
		button.selectedTex:SetInside()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:Point("TOPLEFT", 0, -1)
		icon:Size(44)
		icon:SetParent(button.backdrop)

		money:SetScale(0.88)
		money:Point("TOPRIGHT", 10, -3)
	end

	ClassTrainerTrainButton:StripTextures()
	S:HandleButton(ClassTrainerTrainButton)

	S:HandleCloseButton(ClassTrainerFrameCloseButton,ClassTrainerFrame)

	S:HandleScrollBar(ClassTrainerScrollFrameScrollBar, 5)

	S:HandleDropDownBox(ClassTrainerFrameFilterDropDown)
	ClassTrainerFrameFilterDropDown:Point("TOPRIGHT", -10, -50)

	ClassTrainerFrame:StripTextures()
	ClassTrainerFrame:CreateBackdrop("Transparent")
	ClassTrainerFrame:Height(ClassTrainerFrame:GetHeight() + 42)

	ClassTrainerFrameSkillStepButton:StripTextures()
	ClassTrainerFrameSkillStepButton:CreateBackdrop()
	ClassTrainerFrameSkillStepButton:StyleButton()

	ClassTrainerFrameSkillStepButton.icon:SetTexCoord(unpack(E.TexCoords))
	ClassTrainerFrameSkillStepButton.icon:Point("TOPLEFT", 1, 0)
	ClassTrainerFrameSkillStepButton.icon:Size(40)

	ClassTrainerFrameSkillStepButton.selectedTex:SetTexture(1, 1, 1, 0.3)
	ClassTrainerFrameSkillStepButton.selectedTex:SetInside()

	ClassTrainerFrameSkillStepButtonMoneyFrame:SetScale(0.90)
	ClassTrainerFrameSkillStepButtonMoneyFrame:Point("TOPRIGHT", 10, -3)

	ClassTrainerFrameSkillStepButton.bg = CreateFrame("Frame", nil, ClassTrainerFrameSkillStepButton)
	ClassTrainerFrameSkillStepButton.bg:CreateBackdrop()
	ClassTrainerFrameSkillStepButton.bg:SetInside(ClassTrainerFrameSkillStepButton.icon)

	ClassTrainerFrameSkillStepButton.icon:SetParent(ClassTrainerFrameSkillStepButton.bg)

	ClassTrainerStatusBar:StripTextures()
	ClassTrainerStatusBar:CreateBackdrop("Default")
	ClassTrainerStatusBar:Size(300, 18)
	ClassTrainerStatusBar:SetStatusBarTexture(E["media"].normTex)
	ClassTrainerStatusBar:SetStatusBarColor(0.11, 0.50, 1.00)
	ClassTrainerStatusBar:ClearAllPoints()
	ClassTrainerStatusBar:Point("TOP", ClassTrainerFrame, "TOP", 0, -30)

	ClassTrainerStatusBar.rankText:Point("CENTER")
	ClassTrainerStatusBar.rankText:FontTemplate(nil, 12, "OUTLINE");
end

S:AddCallbackForAddon("Blizzard_TrainerUI", "Trainer", LoadSkin);