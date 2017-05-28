local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local unpack, select = unpack, select;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.merchant ~= true) then return; end

	MerchantFrame:StripTextures(true);
	MerchantFrame:CreateBackdrop("Transparent");
	MerchantFrame.backdrop:Point("BOTTOMRIGHT", 10, -1)

	MerchantBuyBackItem:StripTextures(true);
	MerchantBuyBackItem:CreateBackdrop("Transparent");
	MerchantBuyBackItem.backdrop:Point("TOPLEFT", -6, 6)
	MerchantBuyBackItem.backdrop:Point("BOTTOMRIGHT", 6, -6)

	MerchantBuyBackItemItemButton:StripTextures();
	MerchantBuyBackItemItemButton:SetTemplate("Default", true);
	MerchantBuyBackItemItemButton:StyleButton();

	MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(unpack(E.TexCoords));
	MerchantBuyBackItemItemButtonIconTexture:SetInside();

	MerchantExtraCurrencyInset:StripTextures()
	MerchantExtraCurrencyBg:StripTextures()
	MerchantFrameInset:StripTextures()
	MerchantMoneyBg:StripTextures()
	MerchantMoneyInset:StripTextures()

	S:HandleDropDownBox(MerchantFrameLootFilter)

	S:HandleNextPrevButton(MerchantNextPageButton);
	S:HandleNextPrevButton(MerchantPrevPageButton);

	S:HandleCloseButton(MerchantFrameCloseButton, MerchantFrame.backdrop)

	for i =  1, 2 do
		S:HandleTab(_G["MerchantFrameTab"..i])
	end

	for i = 1, MERCHANT_ITEMS_PER_PAGE do
		local item = _G["MerchantItem" .. i];
		local itemButton = _G["MerchantItem" .. i .. "ItemButton"];
		local iconTexture = _G["MerchantItem" .. i .. "ItemButtonIconTexture"];
		local moneyFrame = _G["MerchantItem" .. i .. "MoneyFrame"];
		local altCurrencyFrame = _G["MerchantItem"..i.."AltCurrencyFrame"];
		local altCurrencyItem1 = _G["MerchantItem" .. i .. "AltCurrencyFrameItem1"];
		local altCurrencyTex1 = _G["MerchantItem" .. i .. "AltCurrencyFrameItem1Texture"];
		local altCurrencyTex2 = _G["MerchantItem" .. i .. "AltCurrencyFrameItem2Texture"];

		item:StripTextures(true);
		item:CreateBackdrop("Default");

		itemButton:StripTextures();
		itemButton:StyleButton();
		itemButton:SetTemplate("Default", true);
		itemButton:Size(40);
		itemButton:Point("TOPLEFT", 2, -2);

		iconTexture:SetTexCoord(unpack(E.TexCoords));
		iconTexture:SetInside();

		altCurrencyItem1:Point("LEFT", altCurrencyFrame, "LEFT", 15, 4);

		altCurrencyTex1:SetTexCoord(unpack(E.TexCoords));
		altCurrencyTex2:SetTexCoord(unpack(E.TexCoords));

		moneyFrame:ClearAllPoints();
		moneyFrame:Point("BOTTOMLEFT", itemButton, "BOTTOMRIGHT", 3, 0);
	end

	hooksecurefunc("MerchantFrame_UpdateCurrencies", function()
		for i = 1, MAX_MERCHANT_CURRENCIES do
			local token = _G["MerchantToken"..i]
			if(token) then
				token:CreateBackdrop()
				token.backdrop:SetOutside(token.icon)

				token.icon:Size(14)
				token.icon:SetTexCoord(unpack(E.TexCoords));
				token.icon:Point("LEFT", token.count, "RIGHT", 2, 0)
			end
		end
	end)

	MerchantRepairItemButton:StyleButton();
	MerchantRepairItemButton:SetTemplate("Default", true);

	for i = 1, MerchantRepairItemButton:GetNumRegions() do
		local region = select(i, MerchantRepairItemButton:GetRegions());
		if(region:GetObjectType() == "Texture") then
			region:SetTexCoord(0.04, 0.24, 0.06, 0.5);
			region:SetInside();
		end
	end

	MerchantRepairAllButton:StyleButton();
	MerchantRepairAllButton:SetTemplate("Default", true);

	MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535);
	MerchantRepairAllIcon:SetInside();

	MerchantGuildBankRepairButton:StyleButton();
	MerchantGuildBankRepairButton:SetTemplate("Default", true);

	MerchantGuildBankRepairButtonIcon:SetTexCoord(0.61, 0.82, 0.1, 0.52);
	MerchantGuildBankRepairButtonIcon:SetInside();

	hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function()
		local numMerchantItems = GetMerchantNumItems();
		local index;
		local itemButton, itemName;
		for i = 1, MERCHANT_ITEMS_PER_PAGE do
			index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i);
			itemButton = _G["MerchantItem" .. i .. "ItemButton"];
			itemName = _G["MerchantItem" .. i .. "Name"];

			if(index <= numMerchantItems) then
				if(itemButton.link) then
					local _, _, quality = GetItemInfo(itemButton.link);
					local r, g, b = GetItemQualityColor(quality);

					itemName:SetTextColor(r, g, b);
					if(quality > 1) then
						itemButton:SetBackdropBorderColor(r, g, b);
					else
						itemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor));
					end
				end
			end

			local buybackName = GetBuybackItemInfo(GetNumBuybackItems());
			if(buybackName) then
				local _, _, quality = GetItemInfo(buybackName);
				local r, g, b = GetItemQualityColor(quality);

				MerchantBuyBackItemName:SetTextColor(r, g, b);
				if(quality > 1) then
					MerchantBuyBackItemItemButton:SetBackdropBorderColor(r, g, b);
				else
					MerchantBuyBackItemItemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor));
				end
			else
				MerchantBuyBackItemItemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor));
			end
		end
	end);

	hooksecurefunc("MerchantFrame_UpdateBuybackInfo", function()
		local numBuybackItems = GetNumBuybackItems();
		local itemButton, itemName;
		for i = 1, BUYBACK_ITEMS_PER_PAGE do
			itemButton = _G["MerchantItem" .. i .. "ItemButton"];
			itemName = _G["MerchantItem" .. i .. "Name"];

			if(i <= numBuybackItems) then
				local buybackName = GetBuybackItemInfo(i);
				if(buybackName) then
					local _, _, quality = GetItemInfo(buybackName);
					local r, g, b = GetItemQualityColor(quality);

					itemName:SetTextColor(r, g, b);
					if(quality > 1) then
						itemButton:SetBackdropBorderColor(r, g, b);
					else
						itemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor));
					end
				end
			end
		end
	end);
end

S:AddCallback("Merchant", LoadSkin);