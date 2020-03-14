local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetTradePlayerItemLink = GetTradePlayerItemLink
local GetTradeTargetItemLink = GetTradeTargetItemLink

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.trade then return end

	TradeFrame:StripTextures(true)
	TradeFrame:CreateBackdrop("Transparent")
	TradeFrame.backdrop:SetAllPoints()

	TradeFrameInset:Kill()
	TradeRecipientItemsInset:Kill()
	TradePlayerItemsInset:Kill()
	TradePlayerInputMoneyInset:Kill()
	TradePlayerEnchantInset:Kill()
	TradeRecipientEnchantInset:Kill()
	TradeRecipientMoneyInset:Kill()
	TradeRecipientMoneyBg:Kill()

	S:HandleButton(TradeFrameTradeButton)
	S:HandleButton(TradeFrameCancelButton)

	S:HandleEditBox(TradePlayerInputMoneyFrameGold)
	S:HandleEditBox(TradePlayerInputMoneyFrameSilver)
	S:HandleEditBox(TradePlayerInputMoneyFrameCopper)

	S:HandleCloseButton(TradeFrameCloseButton, TradeFrame.backdrop)

	for _, frame in pairs({"TradePlayerItem", "TradeRecipientItem"}) do
		for i = 1, MAX_TRADE_ITEMS do
			local item = _G[frame..i]
			local button = _G[frame..i.."ItemButton"]
			local icon = _G[frame..i.."ItemButtonIconTexture"]
			local nameFrame = _G[frame..i.."NameFrame"]

			item:StripTextures()

			button:StripTextures()
			button:StyleButton()
			button:SetTemplate("Default", true)

			button.bg = CreateFrame("Frame", nil, button)
			button.bg:SetTemplate("Default")
			button.bg:Point("TOPLEFT", button, "TOPRIGHT", 4, 0)
			button.bg:Point("BOTTOMRIGHT", nameFrame, "BOTTOMRIGHT", 0, 14)
			button.bg:SetFrameLevel(button:GetFrameLevel() - 3)

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))
		end
	end

	TradeHighlightPlayer:Point("TOPLEFT", TradeFrame, 10, -85)
	TradeHighlightRecipient:Point("TOPLEFT", TradeFrame, 178, -85)

	for _, frame in pairs({"TradeHighlightPlayer", "TradeHighlightRecipient"}) do
		_G[frame]:SetFrameStrata("HIGH")
		_G[frame.."Enchant"]:SetFrameStrata("HIGH")

		_G[frame.."Top"]:SetTexture(0, 1, 0, 0.2)
		_G[frame.."Middle"]:SetTexture(0, 1, 0, 0.2)
		_G[frame.."Bottom"]:SetTexture(0, 1, 0, 0.2)

		_G[frame.."EnchantTop"]:SetTexture(0, 1, 0, 0.2)
		_G[frame.."EnchantMiddle"]:SetTexture(0, 1, 0, 0.2)
		_G[frame.."EnchantBottom"]:SetTexture(0, 1, 0, 0.2)
	end

	local function TradeQualityColors(button, name, link)
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

	hooksecurefunc("TradeFrame_UpdatePlayerItem", function(id)
		local button = _G["TradePlayerItem"..id.."ItemButton"]
		local name = _G["TradePlayerItem"..id.."Name"]
		local link = GetTradePlayerItemLink(id)

		TradeQualityColors(button, name, link)
	end)

	hooksecurefunc("TradeFrame_UpdateTargetItem", function(id)
		local button = _G["TradeRecipientItem"..id.."ItemButton"]
		local name = _G["TradeRecipientItem"..id.."Name"]
		local link = GetTradeTargetItemLink(id)

		TradeQualityColors(button, name, link)
	end)
end

S:AddCallback("Trade", LoadSkin)