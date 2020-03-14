local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.losscontrol then return end

	local IconBackdrop = CreateFrame("Frame", nil, LossOfControlFrame)
	IconBackdrop:SetTemplate()
	IconBackdrop:SetOutside(LossOfControlFrame.Icon)
	IconBackdrop:SetFrameLevel(LossOfControlFrame:GetFrameLevel() - 1)

	LossOfControlFrame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	LossOfControlFrame:StripTextures()
	LossOfControlFrame.AbilityName:ClearAllPoints()
	LossOfControlFrame:Size(LossOfControlFrame.Icon:GetWidth() + 50)

	hooksecurefunc("LossOfControlFrame_SetUpDisplay", function(self, ...)
		self.Icon:ClearAllPoints()
		self.Icon:Point("CENTER", self, "CENTER", 0, 0)

		self.AbilityName:ClearAllPoints()
		self.AbilityName:Point("BOTTOM", self, 0, -28)
		self.AbilityName.scrollTime = nil
		self.AbilityName:FontTemplate(E.media.normFont, 20, "OUTLINE")

		self.TimeLeft.NumberText:ClearAllPoints()
		self.TimeLeft.NumberText:Point("BOTTOM", self, 4, -58)
		self.TimeLeft.NumberText.scrollTime = nil
		self.TimeLeft.NumberText:FontTemplate(E.media.normFont, 20, "OUTLINE")

		self.TimeLeft.SecondsText:ClearAllPoints()
		self.TimeLeft.SecondsText:Point("BOTTOM", self, 0, -80)
		self.TimeLeft.SecondsText.scrollTime = nil
		self.TimeLeft.SecondsText:FontTemplate(E.media.normFont, 20, "OUTLINE")

		if self.Anim:IsPlaying() then
			self.Anim:Stop()
		end
	end)
end

S:AddCallback("LossOfControlFrame", LoadSkin)