local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tutorial then return end

	TutorialFrameAlertButton:StripTextures()
	TutorialFrameAlertButton:SetTemplate("Default", true)
	TutorialFrameAlertButton:Size(40, 50)

	TutorialFrameAlertButton:HookScript("OnEnter", S.SetModifiedBackdrop)
	TutorialFrameAlertButton:HookScript("OnLeave", S.SetOriginalBackdrop)

	local tutorialbuttonIcon = TutorialFrameAlertButton:GetNormalTexture()
	tutorialbuttonIcon:Point("TOPLEFT", 5, -5)
	tutorialbuttonIcon:Point("BOTTOMRIGHT", -5, 5)
	tutorialbuttonIcon:SetTexture("Interface\\QuestFrame\\AutoQuest-Parts")
	tutorialbuttonIcon:SetTexCoord(0.134, 0.171, 0.015, 0.531)

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

S:AddCallback("Tutorial", LoadSkin)