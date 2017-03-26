local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local unpack = unpack;

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tutorial ~= true then return end

	local tutorialbutton = TutorialFrameAlertButton
	local tutorialbuttonIcon = TutorialFrameAlertButton:GetNormalTexture()

	tutorialbutton:StripTextures()
	tutorialbutton:CreateBackdrop("Default", true)
	tutorialbutton:Size(50)

	tutorialbuttonIcon:SetTexture("INTERFACE\\ICONS\\INV_Letter_18")
	tutorialbuttonIcon:Point("TOPLEFT", 5, -5)
	tutorialbuttonIcon:Point("BOTTOMRIGHT", -5, 5)
	tutorialbuttonIcon:SetTexCoord(unpack(E.TexCoords))

	TutorialFrame:StripTextures()
	TutorialFrame:SetTemplate("Transparent")

	S:HandleNextPrevButton(TutorialFrameNextButton)
	TutorialFrameNextButton:Point("BOTTOMRIGHT", -132, 7)
	TutorialFrameNextButton:Size(22)

	S:HandleNextPrevButton(TutorialFramePrevButton)
	TutorialFramePrevButton:Point("BOTTOMLEFT", 30, 7)
	TutorialFramePrevButton:Size(22)

	S:HandleButton(TutorialFrameOkayButton)

	S:HandleCloseButton(TutorialFrameCloseButton)
	TutorialFrameCloseButton:Point("TOPRIGHT", 0, 0)

	TutorialFrameCallOut:Kill()
end

S:AddCallback("Tutorial", LoadSkin);