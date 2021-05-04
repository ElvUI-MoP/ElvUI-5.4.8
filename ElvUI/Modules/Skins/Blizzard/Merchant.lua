local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local GetBuybackItemInfo = GetBuybackItemInfo
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetMerchantNumItems = GetMerchantNumItems
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.merchant then return end

	MerchantFrame:StripTextures(true)
	MerchantFrame:CreateBackdrop("Transparent")
	MerchantFrame.backdrop:Point("BOTTOMRIGHT", 10, -1)

	MerchantFrame:EnableMouseWheel(true)
	MerchantFrame:SetScript("OnMouseWheel", function(_, value)
		if value > 0 then
			if MerchantPrevPageButton:IsShown() and MerchantPrevPageButton:IsEnabled() == 1 then
				MerchantPrevPageButton_OnClick()
			end
		else
			if MerchantNextPageButton:IsShown() and MerchantNextPageButton:IsEnabled() == 1 then
				MerchantNextPageButton_OnClick()
			end
		end
	end)

	MerchantExtraCurrencyInset:StripTextures()
	MerchantExtraCurrencyBg:StripTextures()
	MerchantFrameInset:StripTextures()
	MerchantMoneyBg:StripTextures()
	MerchantMoneyInset:StripTextures()

	S:HandleDropDownBox(MerchantFrameLootFilter)

	S:HandleCloseButton(MerchantFrameCloseButton, MerchantFrame.backdrop)

	for i = 1, 12 do
		local item = _G["MerchantItem"..i]
		local button = _G["MerchantItem"..i.."ItemButton"]
		local icon = _G["MerchantItem"..i.."ItemButtonIconTexture"]
		local money = _G["MerchantItem"..i.."MoneyFrame"]

		item:StripTextures(true)
		item:CreateBackdrop()

		button:StripTextures()
		button:SetTemplate("Default", true)
		button:StyleButton()
		button:Size(40)
		button:Point("TOPLEFT", 2, -2)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		_G["MerchantItem"..i.."ItemButtonStock"]:Point("TOPLEFT", 2, -2)

		money:ClearAllPoints()
		money:Point("BOTTOMLEFT", button, "BOTTOMRIGHT", 3, 0)

		for j = 1, 2 do
			local currency = _G["MerchantItem"..i.."AltCurrencyFrameItem"..j]
			local currencyIcon = _G["MerchantItem"..i.."AltCurrencyFrameItem"..j.."Texture"]

			currency:CreateBackdrop()
			currency.backdrop:SetOutside(currencyIcon)

			currencyIcon:SetTexCoord(unpack(E.TexCoords))
			currencyIcon:SetParent(currency.backdrop)
		end
	end

	hooksecurefunc("MerchantFrame_UpdateCurrencies", function()
		for i = 1, MAX_MERCHANT_CURRENCIES do
			local token = _G["MerchantToken"..i]

			if token and not token.isSkinned then
				token:CreateBackdrop()
				token.backdrop:SetOutside(token.icon)

				if i ~= 1 then
					token:Point("RIGHT", _G["MerchantToken"..i - 1], "LEFT", -6, 0)
				else
					token:Point("BOTTOMRIGHT", -9, 8)
				end

				token.icon:Size(16)
				token.icon:SetTexCoord(unpack(E.TexCoords))
				token.icon:Point("LEFT", token.count, "RIGHT", 3, 0)

				token.isSkinned = true
			end
		end
	end)

	S:HandleNextPrevButton(MerchantNextPageButton, nil, nil, true)
	MerchantNextPageButton:Size(32)

	S:HandleNextPrevButton(MerchantPrevPageButton, nil, nil, true)
	MerchantPrevPageButton:Size(32)

	S:HandleButton(MerchantRepairItemButton)
	MerchantRepairItemButton:StyleButton()

	local merchantRegions = MerchantRepairItemButton:GetRegions()
	merchantRegions:SetTexCoord(0.04, 0.24, 0.07, 0.5)
	merchantRegions:SetInside()

	S:HandleButton(MerchantGuildBankRepairButton)
	MerchantGuildBankRepairButton:StyleButton()
	MerchantGuildBankRepairButtonIcon:SetTexCoord(0.61, 0.82, 0.1, 0.52)
	MerchantGuildBankRepairButtonIcon:SetInside()

	S:HandleButton(MerchantRepairAllButton)
	MerchantRepairAllButton:StyleButton()
	MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)
	MerchantRepairAllIcon:SetInside()

	MerchantBuyBackItem:StripTextures(true)
	MerchantBuyBackItem:CreateBackdrop("Transparent")
	MerchantBuyBackItem.backdrop:Point("TOPLEFT", -6, 6)
	MerchantBuyBackItem.backdrop:Point("BOTTOMRIGHT", 6, -6)
	MerchantBuyBackItem:Point("TOPLEFT", MerchantItem10, "BOTTOMLEFT", 0, -48)

	MerchantBuyBackItemItemButton:StripTextures()
	MerchantBuyBackItemItemButton:SetTemplate("Default", true)
	MerchantBuyBackItemItemButton:StyleButton()

	MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	MerchantBuyBackItemItemButtonIconTexture:SetInside()

	for i = 1, 2 do
		S:HandleTab(_G["MerchantFrameTab"..i])
	end

	local function MerchantQualityColors(button, name, link)
		if link then
			local quality = select(3, GetItemInfo(link))

			if quality then
				local r, g, b = GetItemQualityColor(quality)
				button:SetBackdropBorderColor(r, g, b)
				name:SetTextColor(r, g, b)
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				name:SetTextColor(1, 1, 1)
			end
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			name:SetTextColor(1, 1, 1)
		end
	end

	hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function()
		local numMerchantItems = GetMerchantNumItems()
		local _, index, button, currency, price, extendedCost

		for i = 1, BUYBACK_ITEMS_PER_PAGE do
			index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i)
			button = _G["MerchantItem"..i.."ItemButton"]
			currency = _G["MerchantItem"..i.."AltCurrencyFrame"]

			if index <= numMerchantItems then
				_, _, price, _, _, _, extendedCost = GetMerchantItemInfo(index)

				currency:ClearAllPoints()
				if extendedCost and (price and price <= 0) then
					currency:Point("BOTTOMLEFT", _G["MerchantItem"..i.."NameFrame"], 2, 34)
				elseif extendedCost and (price and price > 0) then
					currency:Point("LEFT", _G["MerchantItem"..i.."MoneyFrame"], "RIGHT", -12, 0)
				end

				MerchantQualityColors(button, _G["MerchantItem"..i.."Name"], button.link)
			end

			MerchantQualityColors(MerchantBuyBackItemItemButton, MerchantBuyBackItemName, GetBuybackItemInfo(GetNumBuybackItems()))
		end
	end)

	hooksecurefunc("MerchantFrame_UpdateBuybackInfo", function()
		local numBuybackItems = GetNumBuybackItems()

		for i = 1, BUYBACK_ITEMS_PER_PAGE do
			if i <= numBuybackItems then
				MerchantQualityColors(_G["MerchantItem"..i.."ItemButton"], _G["MerchantItem"..i.."Name"], GetBuybackItemInfo(i))
			end
		end
	end)
end

S:AddCallback("Merchant", LoadSkin)