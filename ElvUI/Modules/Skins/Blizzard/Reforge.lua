local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local unpack = unpack

local GetReforgeItemInfo = GetReforgeItemInfo

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.reforge then return end

	ReforgingFrame:StripTextures()
	ReforgingFrame:SetTemplate("Transparent")

	ReforgingFrame.FinishedGlow:Kill()

	ReforgingFrame.ButtonFrame:StripTextures()

	ReforgingFrame.RestoreMessage:SetTextColor(1, 1, 1)

	S:HandleButton(ReforgingFrameRestoreButton)

	S:HandleButton(ReforgingFrameReforgeButton)
	ReforgingFrameReforgeButton:Point("BOTTOMRIGHT", -3, 3)

	ReforgingFrame.ItemButton:StripTextures()
	ReforgingFrame.ItemButton:SetTemplate("Default", true)
	ReforgingFrame.ItemButton:StyleButton()

	ReforgingFrame.ItemButton.IconTexture:SetInside()
	ReforgingFrame.ItemButton.IconTexture:SetTexCoord(unpack(E.TexCoords))
	ReforgingFrame.ItemButton.IconTexture.SetTexCoord = E.noop

	ReforgingFrame.ItemButton.MissingText:SetTextColor(1, 0.80, 0.10)
	ReforgingFrame.MissingDescription:SetTextColor(1, 1, 1)

	hooksecurefunc("ReforgingFrame_Update", function()
		local _, icon, _, quality = GetReforgeItemInfo()

		if not icon then
			ReforgingFrame.ItemButton.IconTexture:SetTexture()
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