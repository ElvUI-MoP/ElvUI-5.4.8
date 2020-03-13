local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local unpack = unpack

local GetItemUpgradeItemInfo = GetItemUpgradeItemInfo
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.itemUpgrade ~= true then return end

	local ItemUpgradeFrame = _G["ItemUpgradeFrame"]
	ItemUpgradeFrame:StripTextures()
	ItemUpgradeFrame:SetTemplate("Transparent")

	ItemUpgradeFrame.FinishedGlow:Kill()
	ItemUpgradeFrame.ButtonFrame:DisableDrawLayer("BORDER")

	ItemUpgradeFrame.FinishedGlow:Kill()

	ItemUpgradeFrameMoneyFrame:StripTextures()

	S:HandleButton(ItemUpgradeFrameUpgradeButton, true)

	S:HandleCloseButton(ItemUpgradeFrameCloseButton)

	ItemUpgradeFrame.ItemButton:StripTextures()
	ItemUpgradeFrame.ItemButton:SetTemplate("Default", true)
	ItemUpgradeFrame.ItemButton:StyleButton()

	ItemUpgradeFrame.ItemButton.IconTexture:SetInside()

	ItemUpgradeFrame.ItemButton.Cost.Icon:SetTexCoord(unpack(E.TexCoords))
	ItemUpgradeFrame.ItemButton.Cost.Icon:Size(16)
	ItemUpgradeFrame.ItemButton.Cost.Amount:FontTemplate(nil, 12, "OUTLINE")

	ItemUpgradeFrameMoneyFrame.Currency.icon:SetTexCoord(unpack(E.TexCoords))
	ItemUpgradeFrameMoneyFrame.Currency.icon:Size(16)
	ItemUpgradeFrameMoneyFrame.Currency.count:FontTemplate(nil, 12, "OUTLINE")

	ItemUpgradeFrame.ItemButton.MissingText:SetTextColor(1, 0.80, 0.10)
	ItemUpgradeFrame.MissingDescription:SetTextColor(1, 1, 1)
	ItemUpgradeFrame.NoMoreUpgrades:SetTextColor(1, 1, 1)

	hooksecurefunc("ItemUpgradeFrame_Update", function(self)
		local icon, _, quality = GetItemUpgradeItemInfo()
		if icon then
			ItemUpgradeFrame.ItemButton.IconTexture:SetTexCoord(unpack(E.TexCoords))
		else
			ItemUpgradeFrame.ItemButton.IconTexture:SetTexture(nil)
		end
		if quality then
			ItemUpgradeFrame.ItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
		else
			ItemUpgradeFrame.ItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)
end

S:AddCallbackForAddon("Blizzard_ItemUpgradeUI", "ItemUpgrade", LoadSkin)