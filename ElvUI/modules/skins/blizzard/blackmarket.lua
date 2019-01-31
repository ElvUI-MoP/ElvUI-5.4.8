local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local unpack, select = unpack, select

local hooksecurefunc = hooksecurefunc
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local HybridScrollFrame_GetOffset = HybridScrollFrame_GetOffset
local C_BlackMarket_GetNumItems = C_BlackMarket.GetNumItems
local C_BlackMarket_GetItemInfoByIndex = C_BlackMarket.GetItemInfoByIndex
local C_BlackMarket_GetHotItem = C_BlackMarket.GetHotItem

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bmah ~= true then return end

	local BlackMarketFrame = _G["BlackMarketFrame"]
	BlackMarketFrame:StripTextures()
	BlackMarketFrame:SetTemplate("Transparent")

	BlackMarketFrame.Inset:StripTextures()
	BlackMarketFrame.Inset:CreateBackdrop()
	BlackMarketFrame.Inset.backdrop:SetAllPoints()

	BlackMarketFrame.ColumnName:StripTextures()
	BlackMarketFrame.ColumnLevel:StripTextures()
	BlackMarketFrame.ColumnType:StripTextures()
	BlackMarketFrame.ColumnDuration:StripTextures()
	BlackMarketFrame.ColumnHighBidder:StripTextures()
	BlackMarketFrame.ColumnCurrentBid:StripTextures()

	BlackMarketFrame.MoneyFrameBorder:StripTextures()

	S:HandleCloseButton(BlackMarketFrame.CloseButton)

	S:HandleScrollBar(BlackMarketScrollFrameScrollBar, 4)

	S:HandleEditBox(BlackMarketBidPriceGold)
	BlackMarketBidPriceGold.backdrop:Point("TOPLEFT", -2, 0)
	BlackMarketBidPriceGold.backdrop:Point("BOTTOMRIGHT", -2, 0)

	S:HandleButton(BlackMarketFrame.BidButton)

	local function SkinBlackMarketItems()
		local buttons = BlackMarketScrollFrame.buttons
		local numButtons = #buttons
		local offset = HybridScrollFrame_GetOffset(BlackMarketScrollFrame)
		local numItems = C_BlackMarket_GetNumItems()

		for i = 1, numButtons do
			local button = buttons[i]
			local index = offset + i

			if not button.skinned then
				S:HandleItemButton(button.Item)
				button:StripTextures("BACKGROUND")
				button:StyleButton()

				button.Item:Size(E.PixelMode and 33 or 30)
				button.Item:Point("TOPLEFT", -3, -(E.PixelMode and 2 or 3))

				button.Selection:SetTexture(1, 1, 1, 0.30)
				button.Selection:SetInside()

				button.skinned = true
			end

			if type(numItems) == "number" and index <= numItems then
				local name, texture, _, _, _, _, _, _, _, _, _, _, _, _, link = C_BlackMarket_GetItemInfoByIndex(index)
				if name then
					button.Item.IconTexture:SetTexture(texture)

					if link then
						local quality = select(3, GetItemInfo(link))
						if quality then
							button.Name:SetTextColor(GetItemQualityColor(quality))
							button.Item.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
						else
							button.Name:SetTextColor(1, 1, 1)
							button.Item.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
						end
					end
				end
			end
		end
	end
	hooksecurefunc("BlackMarketScrollFrame_Update", SkinBlackMarketItems)
	hooksecurefunc("HybridScrollFrame_Update", SkinBlackMarketItems)

	BlackMarketFrame.HotDeal:StripTextures()

	S:HandleItemButton(BlackMarketFrame.HotDeal.Item)

	BlackMarketFrame.HotDeal.Item.hover:SetAllPoints()
	BlackMarketFrame.HotDeal.Item.pushed:SetAllPoints()

	BlackMarketFrame.HotDeal.Level:ClearAllPoints()
	BlackMarketFrame.HotDeal.Level:Point("BOTTOMLEFT", BlackMarketFrame.HotDeal.Item, 0, -20)
	BlackMarketFrame.HotDeal.Type:ClearAllPoints()
	BlackMarketFrame.HotDeal.Type:Point("BOTTOMLEFT", BlackMarketFrame.HotDeal.Item, 75, -20)

	BlackMarketFrame.bg = CreateFrame("Frame", nil, BlackMarketFrame)
	BlackMarketFrame.bg:SetTemplate("Default")
	BlackMarketFrame.bg:Point("TOPLEFT", 640, -70)
	BlackMarketFrame.bg:Point("BOTTOMRIGHT", -8, 26)
	BlackMarketFrame.bg:SetFrameLevel(BlackMarketFrame.bg:GetFrameLevel() - 1)

	hooksecurefunc("BlackMarketFrame_UpdateHotItem", function(self)
		local name, _, _, _, _, _, _, _, _, _, _, _, _, _, link = C_BlackMarket_GetHotItem()
		if name then
			if link then
				local quality = select(3, GetItemInfo(link))
				if quality then
					self.HotDeal.Name:SetTextColor(GetItemQualityColor(quality))
					self.HotDeal.Item.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					self.HotDeal.Name:SetTextColor(1, 1, 1)
					self.HotDeal.Item.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end
		end
	end)

	for i = 1, BlackMarketFrame:GetNumRegions() do
		local region = select(i, BlackMarketFrame:GetRegions())
		if region and region:IsObjectType("FontString") and region:GetText() == BLACK_MARKET_TITLE then
			region:ClearAllPoints()
			region:Point("TOP", BlackMarketFrame, 0, -4)
		end
	end
end

S:AddCallbackForAddon("Blizzard_BlackMarketUI", "BlackMarketUI", LoadSkin)