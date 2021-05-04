local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select
local ceil = math.ceil

local CreateFrame = CreateFrame
local GetCurrentGuildBankTab = GetCurrentGuildBankTab
local GetGuildBankItemLink = GetGuildBankItemLink
local GetItemQualityColor = GetItemQualityColor
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gbank then return end

	GuildBankFrame:StripTextures()
	GuildBankFrame:SetTemplate("Transparent")
	GuildBankFrame:Width(654)

	GuildBankEmblemFrame:StripTextures(true)
	GuildBankMoneyFrameBackground:StripTextures()

	S:HookScript(GuildBankFrame, "OnShow", function(self)
		S:SetUIPanelWindowInfo(self, "width", nil, 35)
		S:SetBackdropHitRect(self)
		S:Unhook(self, "OnShow")
	end)

	S:HandleEditBox(GuildItemSearchBox)
	GuildItemSearchBox:Point("TOPRIGHT", -24, -28)
	GuildItemSearchBox:Size(150, 20)

	GuildBankTabTitleBackground:Point("TOP", 0, -8)

	for i = 1, GuildBankFrame:GetNumChildren() do
		local child = select(i, GuildBankFrame:GetChildren())
		if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
			S:HandleCloseButton(child)
			child:Point("TOPRIGHT", 2, 2)
		end
	end

	S:HandleButton(GuildBankFrameDepositButton)
	GuildBankFrameDepositButton:Size(88, 22)
	GuildBankFrameDepositButton:Point("BOTTOMRIGHT", -10, 30)

	S:HandleButton(GuildBankFrameWithdrawButton)
	GuildBankFrameWithdrawButton:Width(88, 22)
	GuildBankFrameWithdrawButton:Point("RIGHT", GuildBankFrameDepositButton, "LEFT", -2, 0)

	-- Bank Frame
	GuildBankFrame.inset = CreateFrame("Frame", nil, GuildBankFrame)
	GuildBankFrame.inset:SetTemplate()
	GuildBankFrame.inset:Point("TOPLEFT", GuildBankColumn1Button1, -8, 8)
	GuildBankFrame.inset:Point("BOTTOMRIGHT", GuildBankColumn7Button14, 8, -8)

	S:HandleButton(GuildBankFramePurchaseButton)

	GuildBankLimitLabel:ClearAllPoints()
	GuildBankLimitLabel:Point("BOTTOMLEFT", GuildBankFrame, 90, 34)

	for i = 1, NUM_GUILDBANK_COLUMNS do
		local column = _G["GuildBankColumn"..i]

		column:StripTextures()

		if i == 1 then
			column:Point("TOPLEFT", 21, -59)
		else
			column:Point("TOPLEFT", _G["GuildBankColumn"..i - 1], "TOPRIGHT", -14, 0)
		end

		for x = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
			local button = _G["GuildBankColumn"..i.."Button"..x]
			local icon = _G["GuildBankColumn"..i.."Button"..x.."IconTexture"]
			local texture = _G["GuildBankColumn"..i.."Button"..x.."NormalTexture"]

			button:StyleButton()
			button:SetTemplate("Default", true)
			button:Size(36)

			if x == 8 then
				button:Point("TOPLEFT", _G["GuildBankColumn"..i.."Button1"], "TOPRIGHT", 7, 0)
			end

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer("OVERLAY")

			if texture then
				texture:SetTexture(nil)
			end

			_G["GuildBankColumn"..i.."Button"..x.."Count"]:SetDrawLayer("OVERLAY")
		end
	end

	hooksecurefunc("GuildBankFrame_Update", function()
		if GuildBankFrame.mode == "bank" then
			local tab = GetCurrentGuildBankTab()
			local index, column, button, link, quality

			for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
				index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)
				if index == 0 then
					index = NUM_SLOTS_PER_GUILDBANK_GROUP
				end
				column = ceil((i - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
				button = _G["GuildBankColumn"..column.."Button"..index]
				link = GetGuildBankItemLink(tab, i)

				if link then
					quality = select(3, GetItemInfo(link))

					if quality and quality > 1 then
						button:SetBackdropBorderColor(GetItemQualityColor(quality))
					else
						button:SetBackdropBorderColor(unpack(E.media.bordercolor))
					end
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end

			GuildBankFrame.inset:Show()
		else
			GuildBankFrame.inset:Hide()
		end
	end)

	-- Log Tab
	GuildBankCashFlowLabel:ClearAllPoints()
	GuildBankCashFlowLabel:Point("BOTTOMLEFT", GuildBankFrame, 90, 34)

	GuildBankCashFlowMoneyFrame:ClearAllPoints()
	GuildBankCashFlowMoneyFrame:Point("LEFT", GuildBankCashFlowLabel, "RIGHT", 20, 0)

	GuildBankMessageFrame:CreateBackdrop("Transparent")
	GuildBankMessageFrame.backdrop:Point("TOPLEFT", -2, 2)
	GuildBankMessageFrame.backdrop:Point("BOTTOMRIGHT", 2, 0)
	GuildBankMessageFrame:Point("TOPLEFT", 12, -58)
	GuildBankMessageFrame:Width(610)

	GuildBankTransactionsScrollFrame:StripTextures()

	S:HandleScrollBar(GuildBankTransactionsScrollFrameScrollBar)
	GuildBankTransactionsScrollFrameScrollBar:ClearAllPoints()
	GuildBankTransactionsScrollFrameScrollBar:Point("TOPRIGHT", GuildBankMessageFrame, 23, -16)
	GuildBankTransactionsScrollFrameScrollBar:Point("BOTTOMRIGHT", GuildBankMessageFrame, 0, 18)

	-- Info Tab
	GuildBankInfoScrollFrame:StripTextures()
	GuildBankInfoScrollFrame:CreateBackdrop("Transparent")
	GuildBankInfoScrollFrame.backdrop:Point("TOPLEFT", -2, 2)
	GuildBankInfoScrollFrame.backdrop:Point("BOTTOMRIGHT", 2, 0)
	GuildBankInfoScrollFrame:Point("TOPLEFT", -20, 16)
	GuildBankInfoScrollFrame:Size(610, 304)

	S:HandleScrollBar(GuildBankInfoScrollFrameScrollBar)
	GuildBankInfoScrollFrameScrollBar:ClearAllPoints()
	GuildBankInfoScrollFrameScrollBar:Point("TOPRIGHT", GuildBankInfoScrollFrame, 23, -16)
	GuildBankInfoScrollFrameScrollBar:Point("BOTTOMRIGHT", GuildBankInfoScrollFrame, 0, 18)

	GuildBankTabInfoEditBox:Width(610)

	S:HandleButton(GuildBankInfoSaveButton)
	GuildBankInfoSaveButton:Point("BOTTOMLEFT", GuildBankFrame, 10, 31)

	-- Side Tabs
	for i = 1, 8 do
		local tab = _G["GuildBankTab"..i]
		local button = _G["GuildBankTab"..i.."Button"]
		local texture = _G["GuildBankTab"..i.."ButtonIconTexture"]

		tab:StripTextures(true)

		if i == 1 then
			tab:Point("TOPLEFT", GuildBankFrame, "TOPRIGHT", E.PixelMode and -3 or -1, -36)
		else
			tab:Point("TOPLEFT", _G["GuildBankTab"..i - 1], "BOTTOMLEFT", 0, 7)
		end

		button:StripTextures()
		button:SetTemplate()
		button:StyleButton()

		button:GetCheckedTexture():SetTexture(1, 1, 1, 0.3)
		button:GetCheckedTexture():SetInside()

		texture:SetInside()
		texture:SetTexCoord(unpack(E.TexCoords))
		texture:SetDrawLayer("ARTWORK")
	end

	-- Bottom Tabs
	for i = 1, 4 do
		local tab = _G["GuildBankFrameTab"..i]

		S:HandleTab(tab)

		if i == 1 then
			tab:ClearAllPoints()
			tab:Point("BOTTOMLEFT", GuildBankFrame, 0, -30)
		end
	end

	-- Popup
	S:HandleIconSelectionFrame(GuildBankPopupFrame, NUM_GUILDBANK_ICONS_SHOWN, "GuildBankPopupButton", "GuildBankPopup")
	GuildBankPopupFrame:Point("TOPLEFT", GuildBankFrame, "TOPRIGHT", 37, 0)
	GuildBankPopupFrame:Size(228, 290)
end

S:AddCallbackForAddon("Blizzard_GuildBankUI", "GuildBank", LoadSkin)