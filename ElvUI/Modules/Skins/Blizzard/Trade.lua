local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs, unpack, select = pairs, unpack, select

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetTradePlayerItemLink = GetTradePlayerItemLink
local GetTradeTargetItemLink = GetTradeTargetItemLink

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.trade then return end

	TradeFrame:StripTextures(true)
	TradeFrame:SetTemplate("Transparent")

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

	S:HandleCloseButton(TradeFrameCloseButton, TradeFrame)

	for _, frame in pairs({"TradePlayerItem", "TradeRecipientItem"}) do
		for i = 1, MAX_TRADE_ITEMS do
			local button = _G[frame..i.."ItemButton"]
			local icon = _G[frame..i.."ItemButtonIconTexture"]

			_G[frame..i]:StripTextures()

			button:StripTextures()
			button:StyleButton()
			button:SetTemplate("Default", true)

			button.bg = CreateFrame("Frame", nil, button)
			button.bg:SetTemplate()
			button.bg:Point("TOPLEFT", button, "TOPRIGHT", 4, 0)
			button.bg:Point("BOTTOMRIGHT", _G[frame..i.."NameFrame"], "BOTTOMRIGHT", 0, 14)
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
		TradeQualityColors(_G["TradePlayerItem"..id.."ItemButton"], _G["TradePlayerItem"..id.."Name"], GetTradePlayerItemLink(id))
	end)

	hooksecurefunc("TradeFrame_UpdateTargetItem", function(id)
		TradeQualityColors(_G["TradeRecipientItem"..id.."ItemButton"], _G["TradeRecipientItem"..id.."Name"], GetTradeTargetItemLink(id))
	end)
end

S:AddCallback("Trade", LoadSkin)