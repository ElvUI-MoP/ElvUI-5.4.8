local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs, unpack = pairs, unpack

local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local GetAuctionSellItemInfo = GetAuctionSellItemInfo

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.auctionhouse ~= true then return end

	BrowseFilterScrollFrame:StripTextures()
	BrowseScrollFrame:StripTextures()
	AuctionsScrollFrame:StripTextures()
	BidScrollFrame:StripTextures()

	local AuctionFrame = _G["AuctionFrame"]
	AuctionFrame:StripTextures(true)
	AuctionFrame:SetTemplate("Transparent")

	S:HandleDropDownBox(BrowseDropDown)
	S:HandleDropDownBox(PriceDropDown)
	S:HandleDropDownBox(DurationDropDown)

	S:HandleScrollBar(BrowseFilterScrollFrameScrollBar)
	S:HandleScrollBar(BrowseScrollFrameScrollBar)
	S:HandleScrollBar(AuctionsScrollFrameScrollBar)

	S:HandleCheckBox(IsUsableCheckButton)
	S:HandleCheckBox(ShowOnPlayerCheckButton)

	S:HandleCloseButton(AuctionFrameCloseButton)
	AuctionFrameCloseButton:Point("TOPRIGHT", 2, 2)

	-- Progress Frame
	AuctionProgressFrame:StripTextures()
	AuctionProgressFrame:SetTemplate("Transparent")

	S:HandleNextPrevButton(AuctionProgressFrameCancelButton)
	SquareButton_SetIcon(AuctionProgressFrameCancelButton, "DELETE")
	AuctionProgressFrameCancelButton:SetHitRectInsets(0, 0, 0, 0)
	AuctionProgressFrameCancelButton:Size(28)
	AuctionProgressFrameCancelButton:Point("LEFT", AuctionProgressBar, "RIGHT", 8, 0)

	AuctionProgressBarIcon.backdrop = CreateFrame("Frame", nil, AuctionProgressBarIcon:GetParent())
	AuctionProgressBarIcon.backdrop:SetTemplate("Default")
	AuctionProgressBarIcon.backdrop:SetOutside(AuctionProgressBarIcon)

	AuctionProgressBarIcon:SetTexCoord(unpack(E.TexCoords))
	AuctionProgressBarIcon:SetParent(AuctionProgressBarIcon.backdrop)

	AuctionProgressBarText:ClearAllPoints()
	AuctionProgressBarText:SetPoint("CENTER")

	AuctionProgressBar:StripTextures()
	AuctionProgressBar:CreateBackdrop("Default")
	AuctionProgressBar:SetStatusBarTexture(E["media"].normTex)
	AuctionProgressBar:SetStatusBarColor(1, 1, 0)

	S:HandleNextPrevButton(BrowseNextPageButton)
	S:HandleNextPrevButton(BrowsePrevPageButton)

	S:HandleButton(BrowseCloseButton)
	S:HandleButton(BidCloseButton)
	S:HandleButton(AuctionsCreateAuctionButton)
	S:HandleButton(AuctionsStackSizeMaxButton)
	S:HandleButton(AuctionsNumStacksMaxButton)

	S:HandleButton(AuctionsCloseButton)
	AuctionsCloseButton:Point("BOTTOMRIGHT", 66, 10)

	S:HandleButton(AuctionsCancelAuctionButton)
	AuctionsCancelAuctionButton:Point("RIGHT", AuctionsCloseButton, "LEFT", -4, 0)

	S:HandleButton(BidBuyoutButton)
	BidBuyoutButton:Point("RIGHT", BidCloseButton, "LEFT", -4, 0)

	S:HandleButton(BidBidButton)
	BidBidButton:Point("RIGHT", BidBuyoutButton, "LEFT", -4, 0)

	S:HandleButton(BrowseBuyoutButton)
	BrowseBuyoutButton:Point("RIGHT", BrowseCloseButton, "LEFT", -4, 0)

	S:HandleButton(BrowseBidButton)
	BrowseBidButton:Point("RIGHT", BrowseBuyoutButton, "LEFT", -4, 0)

	S:HandleButton(BrowseResetButton)
	BrowseResetButton:Point("TOPLEFT", 81, -74)

	S:HandleButton(BrowseSearchButton)
	BrowseSearchButton:Point("TOPRIGHT", 25, -34)

	AuctionsItemButton:StripTextures()
	AuctionsItemButton:SetTemplate("Default", true)
	AuctionsItemButton:StyleButton()

	AuctionsItemButton:SetScript("OnUpdate", function()
		if AuctionsItemButton:GetNormalTexture() then
			AuctionsItemButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			AuctionsItemButton:GetNormalTexture():SetInside()
		end

		local _, _, _, quality = GetAuctionSellItemInfo()
		if(quality and quality > 1) then
			AuctionsItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
		else
			AuctionsItemButton:SetTemplate("Default", true)
		end
	end)

	local sorttabs = {
		"BrowseQualitySort",
		"BrowseLevelSort",
		"BrowseDurationSort",
		"BrowseHighBidderSort",
		"BrowseCurrentBidSort",
		"BidQualitySort",
		"BidLevelSort",
		"BidDurationSort",
		"BidBuyoutSort",
		"BidStatusSort",
		"BidBidSort",
		"AuctionsQualitySort",
		"AuctionsDurationSort",
		"AuctionsHighBidderSort",
		"AuctionsBidSort"
	}

	for _, sorttab in pairs(sorttabs) do
		_G[sorttab]:StripTextures()
		_G[sorttab]:StyleButton()
	end

	for i = 1, 3 do
		S:HandleTab(_G["AuctionFrameTab"..i])
	end

	AuctionFrameTab1:ClearAllPoints()
	AuctionFrameTab1:Point("BOTTOMLEFT", AuctionFrame, "BOTTOMLEFT", 0, -30)
	AuctionFrameTab1.Point = E.noop

	for i = 1, NUM_FILTERS_TO_DISPLAY do
		local tab = _G["AuctionFilterButton"..i]
		tab:StripTextures()
		tab:StyleButton()
	end

	local editboxs = {
		"BrowseName",
		"BrowseMinLevel",
		"BrowseMaxLevel",
		"BrowseBidPriceGold",
		"BrowseBidPriceSilver",
		"BrowseBidPriceCopper",
		"BidBidPriceGold",
		"BidBidPriceSilver",
		"BidBidPriceCopper",
		"AuctionsStackSizeEntry",
		"AuctionsNumStacksEntry",
		"StartPriceGold",
		"StartPriceSilver",
		"StartPriceCopper",
		"BuyoutPriceGold",
		"BuyoutPriceSilver",
		"BuyoutPriceCopper"
	}

	for _, editbox in pairs(editboxs) do
		S:HandleEditBox(_G[editbox])
		_G[editbox]:SetTextInsets(1, 1, -1, 1)
	end

	BrowseNameText:Point("TOPLEFT", 80, -37)
	BrowseName:Point("TOPLEFT", BrowseNameText, "BOTTOMLEFT", 3, -3)
	BrowseName:Size(140, 18)

	BrowseMaxLevel:Point("LEFT", BrowseMinLevel, "RIGHT", 8, 0)

	AuctionsStackSizeEntry.backdrop:SetAllPoints()
	AuctionsNumStacksEntry.backdrop:SetAllPoints()

	for i = 1, NUM_BROWSE_TO_DISPLAY do
		local button = _G["BrowseButton"..i]
		local icon = _G["BrowseButton"..i.."Item"]
		local name = _G["BrowseButton"..i.."Name"]
		local texture = _G["BrowseButton"..i.."ItemIconTexture"]

		if texture then
			texture:SetTexCoord(unpack(E.TexCoords))
			texture:SetInside()
		end

		if icon then
			icon:StyleButton()
			icon:GetNormalTexture():SetTexture("")
			icon:SetTemplate("Default")

			hooksecurefunc(name, "SetVertexColor", function(_, r, g, b)
				if r == 1 and g == 1 and b == 1 then
					icon:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				else
					icon:SetBackdropBorderColor(r, g, b)
				end
			end)
			hooksecurefunc(name, "Hide", function()
				icon:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			end)
		end

		button:StripTextures()
		button:StyleButton()

		_G["BrowseButton"..i.."Highlight"] = button:GetHighlightTexture()
		button:GetHighlightTexture():ClearAllPoints()
		button:GetHighlightTexture():Point("TOPLEFT", icon, "TOPRIGHT", 2, 0)
		button:GetHighlightTexture():Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
		button:GetPushedTexture():SetAllPoints(button:GetHighlightTexture())
	end

	for i = 1, NUM_AUCTIONS_TO_DISPLAY do
		local button = _G["AuctionsButton"..i]
		local icon = _G["AuctionsButton"..i.."Item"]
		local name = _G["AuctionsButton"..i.."Name"]

		_G["AuctionsButton"..i.."ItemIconTexture"]:SetTexCoord(unpack(E.TexCoords))
		_G["AuctionsButton"..i.."ItemIconTexture"]:SetInside()

		icon:StyleButton()
		icon:GetNormalTexture():SetTexture("")
		icon:SetTemplate("Default")

		hooksecurefunc(name, "SetVertexColor", function(_, r, g, b)
			if r == 1 and g == 1 and b == 1 then
				icon:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			else
				icon:SetBackdropBorderColor(r, g, b)
			end
		end)
		hooksecurefunc(name, "Hide", function()
			icon:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		end)

		button:StripTextures()
		button:StyleButton()

		_G["AuctionsButton"..i.."Highlight"] = button:GetHighlightTexture()
		button:GetHighlightTexture():ClearAllPoints()
		button:GetHighlightTexture():Point("TOPLEFT", icon, "TOPRIGHT", 2, 0)
		button:GetHighlightTexture():Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
		button:GetPushedTexture():SetAllPoints(button:GetHighlightTexture())
	end

	for i = 1, NUM_BIDS_TO_DISPLAY do
		local button = _G["BidButton"..i]
		local icon = _G["BidButton"..i.."Item"]
		local name = _G["BidButton"..i.."Name"]

		_G["BidButton"..i.."ItemIconTexture"]:SetTexCoord(unpack(E.TexCoords))
		_G["BidButton"..i.."ItemIconTexture"]:SetInside()

		icon:StyleButton()
		icon:GetNormalTexture():SetTexture("")
		icon:SetTemplate("Default")
		icon:CreateBackdrop("Default")
		icon.backdrop:SetAllPoints()

		hooksecurefunc(name, "SetVertexColor", function(_, r, g, b)
			if r == 1 and g == 1 and b == 1 then
				icon:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			else
				icon:SetBackdropBorderColor(r, g, b)
			end
		end)
		hooksecurefunc(name, "Hide", function()
			icon:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		end)

		button:StripTextures()
		button:StyleButton()
		_G["BidButton"..i.."Highlight"] = button:GetHighlightTexture()
		button:GetHighlightTexture():ClearAllPoints()
		button:GetHighlightTexture():Point("TOPLEFT", icon, "TOPRIGHT", 2, 0)
		button:GetHighlightTexture():Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
		button:GetPushedTexture():SetAllPoints(button:GetHighlightTexture())
	end

	-- Custom Backdrops
	AuctionFrameBrowse.bg1 = CreateFrame("Frame", nil, AuctionFrameBrowse)
	AuctionFrameBrowse.bg1:SetTemplate("Default")
	AuctionFrameBrowse.bg1:Point("TOPLEFT", 20, -103)
	AuctionFrameBrowse.bg1:Point("BOTTOMRIGHT", -575, 40)
	BrowseNoResultsText:SetParent(AuctionFrameBrowse.bg1)
	BrowseSearchCountText:SetParent(AuctionFrameBrowse.bg1)
	AuctionFrameBrowse.bg1:SetFrameLevel(AuctionFrameBrowse.bg1:GetFrameLevel() - 1)
	BrowseFilterScrollFrame:Height(300)

	AuctionFrameBrowse.bg2 = CreateFrame("Frame", nil, AuctionFrameBrowse)
	AuctionFrameBrowse.bg2:SetTemplate("Default")
	AuctionFrameBrowse.bg2:Point("TOPLEFT", AuctionFrameBrowse.bg1, "TOPRIGHT", 4, 0)
	AuctionFrameBrowse.bg2:Point("BOTTOMRIGHT", AuctionFrame, "BOTTOMRIGHT", -8, 40)
	AuctionFrameBrowse.bg2:SetFrameLevel(AuctionFrameBrowse.bg2:GetFrameLevel() - 1)
	BrowseScrollFrame:Height(300)

	AuctionFrameBid.bg = CreateFrame("Frame", nil, AuctionFrameBid)
	AuctionFrameBid.bg:SetTemplate("Default")
	AuctionFrameBid.bg:Point("TOPLEFT", 22, -72)
	AuctionFrameBid.bg:Point("BOTTOMRIGHT", 66, 39)
	AuctionFrameBid.bg:SetFrameLevel(AuctionFrameBid.bg:GetFrameLevel() - 1)
	BidScrollFrame:Height(332)

	AuctionsScrollFrame:Height(336)
	AuctionFrameAuctions.bg1 = CreateFrame("Frame", nil, AuctionFrameAuctions)
	AuctionFrameAuctions.bg1:SetTemplate("Default", true)
	AuctionFrameAuctions.bg1:Point("TOPLEFT", 15, -70)
	AuctionFrameAuctions.bg1:Point("BOTTOMRIGHT", -545, 35)
	--AuctionFrameAuctions.bg1:SetFrameLevel(AuctionFrameAuctions.bg1:GetFrameLevel() - 3)

	AuctionFrameAuctions.bg2 = CreateFrame("Frame", nil, AuctionFrameAuctions)
	AuctionFrameAuctions.bg2:SetTemplate("Default", true)
	AuctionFrameAuctions.bg2:Point("TOPLEFT", AuctionFrameAuctions.bg1, "TOPRIGHT", 3, 0)
	AuctionFrameAuctions.bg2:Point("BOTTOMRIGHT", AuctionFrame, -8, 35)
	--AuctionFrameAuctions.bg2:SetFrameLevel(AuctionFrameAuctions.bg2:GetFrameLevel() - 3)
end

S:AddCallbackForAddon("Blizzard_AuctionUI", "AuctionHouse", LoadSkin)