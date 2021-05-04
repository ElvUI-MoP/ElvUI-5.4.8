local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local GetItemInfo = GetItemInfo
local GetVoidItemInfo = GetVoidItemInfo
local GetVoidTransferDepositInfo = GetVoidTransferDepositInfo
local GetVoidTransferWithdrawalInfo = GetVoidTransferWithdrawalInfo
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.voidstorage then return end

	VoidStorageFrameMarbleBg:Kill()
	VoidStorageFrameLines:Kill()

	VoidStorageBorderFrame:StripTextures()
	VoidStorageCostFrame:StripTextures()

	select(2, VoidStorageFrame:GetRegions()):Kill()
	VoidStorageFrame:SetTemplate("Transparent")
	VoidStorageFrame:Size(675, 410)

	VoidStoragePurchaseFrame:StripTextures()
	VoidStoragePurchaseFrame:SetTemplate()

	VoidStorageDepositFrame:StripTextures()
	VoidStorageDepositFrame:CreateBackdrop()
	VoidStorageDepositFrame.backdrop:Point("TOPLEFT", 3, -3)
	VoidStorageDepositFrame.backdrop:Point("BOTTOMRIGHT", -3, 3)

	VoidStorageWithdrawFrame:StripTextures()
	VoidStorageWithdrawFrame:CreateBackdrop()
	VoidStorageWithdrawFrame.backdrop:Point("TOPLEFT", 3, -3)
	VoidStorageWithdrawFrame.backdrop:Point("BOTTOMRIGHT", -3, 3)

	VoidStorageStorageFrame:StripTextures()
	VoidStorageStorageFrame:CreateBackdrop()
	VoidStorageStorageFrame.backdrop:Point("TOPLEFT", 3, -3)
	VoidStorageStorageFrame.backdrop:Point("BOTTOMRIGHT", -31, 3)

	S:HandleButton(VoidStoragePurchaseButton)
	S:HandleButton(VoidStorageHelpBoxButton)
	S:HandleButton(VoidStorageTransferButton)

	VoidStorageHelpBox:StripTextures()
	VoidStorageHelpBox:SetTemplate("Transparent")

	VoidItemSearchBox:StripTextures()
	VoidItemSearchBox:CreateBackdrop()
	VoidItemSearchBox.backdrop:Point("TOPLEFT", 10, -1)
	VoidItemSearchBox.backdrop:Point("BOTTOMRIGHT", 4, 1)

	S:HandleCloseButton(VoidStorageBorderFrame.CloseButton)

	VoidStorageStorageButton17:Point("LEFT", VoidStorageStorageButton9, "RIGHT", 7, 0)
	VoidStorageStorageButton33:Point("LEFT", VoidStorageStorageButton25, "RIGHT", 7, 0)
	VoidStorageStorageButton49:Point("LEFT", VoidStorageStorageButton41, "RIGHT", 7, 0)
	VoidStorageStorageButton65:Point("LEFT", VoidStorageStorageButton57, "RIGHT", 7, 0)

	for i = 1, 9 do
		local deposit = _G["VoidStorageDepositButton"..i]
		local withdraw = _G["VoidStorageWithdrawButton"..i]

		deposit:SetTemplate("Default", true)
		deposit:StyleButton()

		deposit.icon:SetTexCoord(unpack(E.TexCoords))
		deposit.icon:SetInside()

		_G["VoidStorageDepositButton"..i.."Bg"]:Hide()

		withdraw:SetTemplate("Default", true)
		withdraw:StyleButton()

		withdraw.icon:SetTexCoord(unpack(E.TexCoords))
		withdraw.icon:SetInside()

		_G["VoidStorageWithdrawButton"..i.."Bg"]:Hide()
	end

	for i = 1, 80 do
		local button = _G["VoidStorageStorageButton"..i]

		button:SetTemplate("Default", true)
		button:StyleButton()

		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.icon:SetInside()

		_G["VoidStorageStorageButton"..i.."Bg"]:Hide()
	end

	local function VoidQualityColors(button, link)
		if link then
			local quality = select(3, GetItemInfo(link))

			if quality then
				button:SetBackdropBorderColor(GetItemQualityColor(quality))
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end

	hooksecurefunc("VoidStorage_ItemsUpdate", function(doDeposit, doContents)
		if doDeposit then
			for i = 1, 9 do
				VoidQualityColors(_G["VoidStorageDepositButton"..i], GetVoidTransferDepositInfo(i))
			end
		end

		if doContents then
			for i = 1, 9 do
				VoidQualityColors(_G["VoidStorageWithdrawButton"..i], GetVoidTransferWithdrawalInfo(i))
			end

			E:Delay(0.1, function()
				for i = 1, 80 do
					VoidQualityColors(_G["VoidStorageStorageButton"..i], GetVoidItemInfo(i))
				end
			end)
		end
	end)
end

S:AddCallbackForAddon("Blizzard_VoidStorageUI", "VoidStorageUI", LoadSkin)