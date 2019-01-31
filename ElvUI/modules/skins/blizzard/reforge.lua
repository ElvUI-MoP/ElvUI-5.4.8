local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local unpack = unpack

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.inspect ~= true then return end

	ReforgingFrame:StripTextures()
	ReforgingFrame:SetTemplate("Transparent")

	ReforgingFrame.ButtonFrame:StripTextures()

	ReforgingFrame.FinishedGlow:Kill()

	S:HandleButton(ReforgingFrameRestoreButton, true)

	S:HandleButton(ReforgingFrameReforgeButton, true)
	ReforgingFrameReforgeButton:Point("BOTTOMRIGHT", -3, 3)

	ReforgingFrame.ItemButton:StripTextures()
	ReforgingFrame.ItemButton:SetTemplate("Default", true)
	ReforgingFrame.ItemButton:StyleButton()

	ReforgingFrame.ItemButton.IconTexture:SetInside()

	ReforgingFrame.RestoreMessage:SetTextColor(1, 1, 1)
	ReforgingFrame.ItemButton.MissingText:SetTextColor(1, 0.80, 0.10)
	ReforgingFrame.MissingDescription:SetTextColor(1, 1, 1)

	hooksecurefunc("ReforgingFrame_Update", function(self)
		local _, icon, _, quality = GetReforgeItemInfo()
		if icon then
			ReforgingFrame.ItemButton.IconTexture:SetTexCoord(unpack(E.TexCoords))
		else
			ReforgingFrame.ItemButton.IconTexture:SetTexture(nil)
		end

		if quality then
			ReforgingFrame.ItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
		else
			ReforgingFrame.ItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	S:HandleCloseButton(ReforgingFrameCloseButton)
end

S:AddCallbackForAddon("Blizzard_ReforgingUI", "ReforgingUI", LoadSkin)