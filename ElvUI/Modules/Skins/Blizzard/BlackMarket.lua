local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local unpack, select = unpack, select

local hooksecurefunc = hooksecurefunc
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local HybridScrollFrame_GetOffset = HybridScrollFrame_GetOffset
local C_BlackMarket_GetNumItems = C_BlackMarket.GetNumItems
local C_BlackMarket_GetHotItem = C_BlackMarket.GetHotItem

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.bmah then return end

	BlackMarketFrame:StripTextures()
	BlackMarketFrame:SetTemplate("Transparent")

	BlackMarketFrame.Inset:StripTextures()
	BlackMarketFrame.Inset:CreateBackdrop("Transparent")
	BlackMarketFrame.Inset.backdrop:Point("TOPLEFT", 0, -5)
	BlackMarketFrame.Inset.backdrop:Point("BOTTOMRIGHT", -20, 5)

	BlackMarketFrame.ColumnName:StripTextures()
	BlackMarketFrame.ColumnLevel:StripTextures()
	BlackMarketFrame.ColumnType:StripTextures()
	BlackMarketFrame.ColumnDuration:StripTextures()
	BlackMarketFrame.ColumnHighBidder:StripTextures()
	BlackMarketFrame.ColumnCurrentBid:StripTextures()

	BlackMarketFrame.MoneyFrameBorder:StripTextures()

	S:HandleCloseButton(BlackMarketFrame.CloseButton)

	S:HandleScrollBar(BlackMarketScrollFrameScrollBar)
	BlackMarketScrollFrameScrollBar:ClearAllPoints()
	BlackMarketScrollFrameScrollBar:Point("TOPRIGHT", BlackMarketScrollFrame, 31, -13)
	BlackMarketScrollFrameScrollBar:Point("BOTTOMRIGHT", BlackMarketScrollFrame, 0, 13)

	S:HandleEditBox(BlackMarketBidPriceGold)
	BlackMarketBidPriceGold.backdrop:Point("TOPLEFT", -2, 0)
	BlackMarketBidPriceGold.backdrop:Point("BOTTOMRIGHT", -2, 0)

	S:HandleButton(BlackMarketFrame.BidButton)
	BlackMarketFrame.BidButton:Point("BOTTOMRIGHT", -276, 5)

	local function SkinBlackMarketItems()
		local buttons = BlackMarketScrollFrame.buttons
		local offset = HybridScrollFrame_GetOffset(BlackMarketScrollFrame)
		local numItems = C_BlackMarket_GetNumItems()

		for i = 1, #buttons do
			local button = buttons[i]
			local index = offset + i

			if type(numItems) == "number" and index <= numItems then
				if not button.isSkinned then
					S:HandleItemButton(button.Item)
					button:StripTextures()

					S:HandleButtonHighlight(button)
					button.handledHighlight:SetInside()

					button.Item:Size(E.PixelMode and 33 or 30)
					button.Item:Point("TOPLEFT", -3, -(E.PixelMode and 2 or 3))

					button.Selection:SetTexture(E.Media.Textures.Highlight)
					button.Selection:SetAlpha(0.35)
					button.Selection:SetInside()

					button.isSkinned = true
				end

				local r, g, b
				if button.itemLink then
					r, g, b = GetItemQualityColor(select(3, GetItemInfo(button.itemLink)))
				else
					r, g, b = 1, 1, 1
				end

				button.Name:SetTextColor(r, g, b)
				button.handledHighlight:SetVertexColor(r, g, b)
				button.Selection:SetVertexColor(r, g, b)
				button.Item.backdrop:SetBackdropBorderColor(r, g, b)
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
	BlackMarketFrame.bg:SetTemplate("Transparent")
	BlackMarketFrame.bg:Point("TOPLEFT", 640, -75)
	BlackMarketFrame.bg:Point("BOTTOMRIGHT", -8, 31)
	BlackMarketFrame.bg:SetFrameLevel(BlackMarketFrame.bg:GetFrameLevel() - 1)

	hooksecurefunc("BlackMarketFrame_UpdateHotItem", function(self)
		local link = select(15, C_BlackMarket_GetHotItem())

		if link then
			local quality = select(3, GetItemInfo(link))

			self.HotDeal.Name:SetTextColor(GetItemQualityColor(quality))
			self.HotDeal.Item.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
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