local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local _G = _G;
local unpack, select = unpack, select;

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.voidstorage ~= true then return end

	VoidStorageFrameMarbleBg:Kill()
	VoidStorageFrameLines:Kill()

	VoidStorageBorderFrame:StripTextures()
	VoidStorageCostFrame:StripTextures()

	select(2, VoidStorageFrame:GetRegions()):Kill()
	VoidStorageFrame:SetTemplate("Transparent")
	VoidStorageFrame:Size(675, 410)

	VoidStoragePurchaseFrame:StripTextures()
	VoidStoragePurchaseFrame:SetTemplate("Default")

	VoidStorageDepositFrame:StripTextures()
	VoidStorageDepositFrame:CreateBackdrop("Default")
	VoidStorageDepositFrame.backdrop:Point("TOPLEFT", 3, -3)
	VoidStorageDepositFrame.backdrop:Point("BOTTOMRIGHT", -3, 3)

	VoidStorageWithdrawFrame:StripTextures()
	VoidStorageWithdrawFrame:CreateBackdrop("Default")
	VoidStorageWithdrawFrame.backdrop:Point("TOPLEFT", 3, -3)
	VoidStorageWithdrawFrame.backdrop:Point("BOTTOMRIGHT", -3, 3)

	VoidStorageStorageFrame:StripTextures()
	VoidStorageStorageFrame:CreateBackdrop("Default")
	VoidStorageStorageFrame.backdrop:Point("TOPLEFT", 3, -3)
	VoidStorageStorageFrame.backdrop:Point("BOTTOMRIGHT", -31, 3)

	S:HandleButton(VoidStoragePurchaseButton)
	S:HandleButton(VoidStorageHelpBoxButton)
	S:HandleButton(VoidStorageTransferButton)

	VoidStorageHelpBox:StripTextures()
	VoidStorageHelpBox:SetTemplate()

	VoidItemSearchBox:StripTextures()
	VoidItemSearchBox:CreateBackdrop("Overlay")
	VoidItemSearchBox.backdrop:Point("TOPLEFT", 10, -1)
	VoidItemSearchBox.backdrop:Point("BOTTOMRIGHT", 4, 1)

	S:HandleCloseButton(VoidStorageBorderFrame.CloseButton)

	VoidStorageStorageButton17:Point("LEFT", VoidStorageStorageButton9, "RIGHT", 7, 0)
	VoidStorageStorageButton33:Point("LEFT", VoidStorageStorageButton25, "RIGHT", 7, 0)
	VoidStorageStorageButton49:Point("LEFT", VoidStorageStorageButton41, "RIGHT", 7, 0)
	VoidStorageStorageButton65:Point("LEFT", VoidStorageStorageButton57, "RIGHT", 7, 0)

	for i = 1, 9 do
		local depositButton = _G["VoidStorageDepositButton"..i]
		local depositIcon = _G["VoidStorageDepositButton"..i.."IconTexture"]
		local depositBg = _G["VoidStorageDepositButton"..i.."Bg"]
		local withdrawButton = _G["VoidStorageWithdrawButton"..i]
		local withdrawIcon = _G["VoidStorageWithdrawButton"..i.."IconTexture"]
		local withdrawBg = _G["VoidStorageWithdrawButton"..i.."Bg"]

		depositButton:SetTemplate("Default", true)
		depositButton:StyleButton()

		depositIcon:SetTexCoord(unpack(E.TexCoords))
		depositIcon:SetInside()

		depositBg:Hide()

		withdrawButton:SetTemplate("Default", true)
		withdrawButton:StyleButton()

		withdrawIcon:SetTexCoord(unpack(E.TexCoords))
		withdrawIcon:SetInside()

		withdrawBg:Hide()
	end

	for i = 1, 80 do
		local button = _G["VoidStorageStorageButton"..i]
		local icon = _G["VoidStorageStorageButton"..i.."IconTexture"]
		local bg = _G["VoidStorageStorageButton"..i.."Bg"]

		button:StyleButton()
		button:SetTemplate("Default", true)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		bg:Hide()
	end

	hooksecurefunc("VoidStorage_ItemsUpdate", function(doDeposit, doContents)
		if(doDeposit) then
			for i = 1, 9 do
				local button = _G["VoidStorageDepositButton"..i]
				local itemID = GetVoidTransferDepositInfo(i);

				if(itemID) then
					local quality = select(3, GetItemInfo(itemID))
					if(quality and quality > 1) then
						button:SetBackdropBorderColor(GetItemQualityColor(quality));
					else
						button:SetBackdropBorderColor(unpack(E["media"].bordercolor));
					end
				else
					button:SetTemplate("Default", true)
				end
			end
		end

		if(doContents) then
			for i = 1, 9 do
				local button = _G["VoidStorageWithdrawButton"..i]
				local itemID = GetVoidTransferWithdrawalInfo(i);

				if(itemID) then
					local quality = select(3, GetItemInfo(itemID))
					if(quality and quality > 1) then
						button:SetBackdropBorderColor(GetItemQualityColor(quality));
					else
						button:SetBackdropBorderColor(unpack(E["media"].bordercolor));
					end
				else
					button:SetTemplate("Default", true)
				end
			end

			E:Delay(0.02, function()
				for i = 1, 80 do
					local button = _G["VoidStorageStorageButton"..i]
					local itemID = GetVoidItemInfo(i);

					if(itemID) then
						local quality = select(3, GetItemInfo(itemID))
						if(quality and quality > 1) then
							button:SetBackdropBorderColor(GetItemQualityColor(quality));
						else
							button:SetBackdropBorderColor(unpack(E["media"].bordercolor));
						end
					else
						button:SetTemplate("Default", true)
					end
				end
			end)
		end
	end)
end

S:AddCallbackForAddon("Blizzard_VoidStorageUI", "VoidStorageUI", LoadSkin);