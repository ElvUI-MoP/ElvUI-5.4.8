local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local CreateFrame = CreateFrame
local GetContainerItemLink = GetContainerItemLink
local GetContainerItemQuestInfo = GetContainerItemQuestInfo
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local hooksecurefunc = hooksecurefunc
local C_NewItemsIsNewItem = C_NewItems.IsNewItem
local BANK_CONTAINER = BANK_CONTAINER
local MAX_CONTAINER_ITEMS = MAX_CONTAINER_ITEMS
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS
local NUM_BANKBAGSLOTS = NUM_BANKBAGSLOTS
local NUM_BANKGENERIC_SLOTS = NUM_BANKGENERIC_SLOTS
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES

local function LoadSkin()
	if E.private.bags.enable then return end
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bags ~= true then return end

	local ProfessionColors = {
		[0x0008]   = {E.db.bags.colors.profession.leatherworking.r, E.db.bags.colors.profession.leatherworking.g, E.db.bags.colors.profession.leatherworking.b},
		[0x0010]   = {E.db.bags.colors.profession.inscription.r, E.db.bags.colors.profession.inscription.g, E.db.bags.colors.profession.inscription.b},
		[0x0020]   = {E.db.bags.colors.profession.herbs.r, E.db.bags.colors.profession.herbs.g, E.db.bags.colors.profession.herbs.b},
		[0x0040]   = {E.db.bags.colors.profession.enchanting.r, E.db.bags.colors.profession.enchanting.g, E.db.bags.colors.profession.enchanting.b},
		[0x0080]   = {E.db.bags.colors.profession.engineering.r, E.db.bags.colors.profession.engineering.g, E.db.bags.colors.profession.engineering.b},
		[0x0200]   = {E.db.bags.colors.profession.gems.r, E.db.bags.colors.profession.gems.g, E.db.bags.colors.profession.gems.b},
		[0x0400]   = {E.db.bags.colors.profession.mining.r, E.db.bags.colors.profession.mining.g, E.db.bags.colors.profession.mining.b},
		[0x8000]   = {E.db.bags.colors.profession.fishing.r, E.db.bags.colors.profession.fishing.g, E.db.bags.colors.profession.fishing.b},
		[0x010000] = {E.db.bags.colors.profession.cooking.r, E.db.bags.colors.profession.cooking.g, E.db.bags.colors.profession.cooking.b}
	}

	local QuestColors = {
		["questStarter"] = {E.db.bags.colors.items.questStarter.r, E.db.bags.colors.items.questStarter.g, E.db.bags.colors.items.questStarter.b},
		["questItem"] =	{E.db.bags.colors.items.questItem.r, E.db.bags.colors.items.questItem.g, E.db.bags.colors.items.questItem.b}
	}

	-- ContainerFrame
	for i = 1, NUM_CONTAINER_FRAMES, 1 do
		local frame = _G["ContainerFrame"..i]
		local closeButton = _G["ContainerFrame"..i.."CloseButton"]

		frame:StripTextures(true)
		frame:CreateBackdrop("Transparent")
		frame.backdrop:Point("TOPLEFT", 9, -4)
		frame.backdrop:Point("BOTTOMRIGHT", -4, 2)

		S:HandleCloseButton(closeButton)
		closeButton:Point("TOPRIGHT", 0, 1)

		for k = 1, MAX_CONTAINER_ITEMS, 1 do
			local item = _G["ContainerFrame"..i.."Item"..k]
			local icon = _G["ContainerFrame"..i.."Item"..k.."IconTexture"]
			local questIcon = _G["ContainerFrame"..i.."Item"..k.."IconQuestTexture"]
			local cooldown = _G["ContainerFrame"..i.."Item"..k.."Cooldown"]

			item:SetNormalTexture(nil)
			item:SetTemplate("Default", true)
			item:StyleButton()

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))

			questIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\bagQuestIcon.tga")
			questIcon.SetTexture = E.noop
			questIcon:SetTexCoord(0, 1, 0, 1)
			questIcon:SetInside()

			item.newItemGlow = item:CreateTexture(nil, "OVERLAY")
			item.newItemGlow:SetInside()
			item.newItemGlow:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\bagNewItemGlow.tga")
			item.newItemGlow:Hide()

			cooldown.CooldownOverride = "bags"
			E:RegisterCooldown(cooldown)
		end
	end

	S:HandleEditBox(BagItemSearchBox)
	BagItemSearchBox:Height(BagItemSearchBox:GetHeight() - 5)

	BackpackTokenFrame:StripTextures()

	for i = 1, MAX_WATCHED_TOKENS do
		local token = _G["BackpackTokenFrameToken"..i]

		token:CreateBackdrop("Default")
		token.backdrop:SetOutside(token.icon)

		token.icon:SetTexCoord(unpack(E.TexCoords))
		token.icon:Point("LEFT", token.count, "RIGHT", 2, 0)
		token.icon:Size(15)
	end

	hooksecurefunc("ContainerFrame_Update", function(self)
		local id = self:GetID()
		local name = self:GetName()
		local item, link, quality
		local r, g, b
		local questIcon, isQuestItem, questId, isActive
		local _, bagType = GetContainerNumFreeSlots(id)

		for i = 1, self.size, 1 do
			item = _G[name.."Item"..i]
			questIcon = _G[name.."Item"..i.."IconQuestTexture"]
			link = GetContainerItemLink(id, item:GetID())

			questIcon:Hide()

			if ProfessionColors[bagType] then
				item.newItemGlow:SetVertexColor(unpack(ProfessionColors[bagType]))
				item:SetBackdropBorderColor(unpack(ProfessionColors[bagType]))
				item.ignoreBorderColors = true
			elseif link then
				isQuestItem, questId, isActive = GetContainerItemQuestInfo(id, item:GetID())
				_, _, quality = GetItemInfo(link)

				if quality then
					r, g, b = GetItemQualityColor(quality)
				end

				if questId and not isActive then
					item.newItemGlow:SetVertexColor(1.0, 1.0, 0.0)
					item:SetBackdropBorderColor(1.0, 1.0, 0.0)
					item.ignoreBorderColors = true
					questIcon:Show()
				elseif questId or isQuestItem then
					item.newItemGlow:SetVertexColor(1.0, 0.3, 0.3)
					item:SetBackdropBorderColor(1.0, 0.3, 0.3)
					item.ignoreBorderColors = true
				elseif quality then
					item.newItemGlow:SetVertexColor(r, g, b)
					item:SetBackdropBorderColor(GetItemQualityColor(quality))
					item.ignoreBorderColors = true
				else
					item.newItemGlow:SetVertexColor(1, 1, 1)
					item:SetBackdropBorderColor(unpack(E.media.bordercolor))
					item.ignoreBorderColors = true
				end
			else
				item:SetBackdropBorderColor(unpack(E.media.bordercolor))
				item.ignoreBorderColors = true
			end

			if C_NewItemsIsNewItem(id, item:GetID()) then
				item.newItemGlow:Show()
				E:Flash(item.newItemGlow, 0.5, true)
			else
				item.newItemGlow:Hide()
				E:StopFlash(item.newItemGlow)
			end
		end
	end)

	-- BankFrame
	local BankFrame = _G["BankFrame"]
	BankFrame:StripTextures(true)
	BankFrame:SetTemplate("Transparent")

	BankFrameMoneyFrameInset:StripTextures()
	BankFrameMoneyFrameBorder:StripTextures()

	S:HandleCloseButton(BankFrameCloseButton)

	for i = 1, NUM_BANKGENERIC_SLOTS, 1 do
		local button = _G["BankFrameItem"..i]
		local buttonIcon = _G["BankFrameItem"..i.."IconTexture"]
		local questTexture = _G["BankFrameItem"..i.."IconQuestTexture"]
		local cooldown = _G["BankFrameItem"..i.."Cooldown"]

		button:SetNormalTexture(nil)
		button:SetTemplate("Default", true)
		button:StyleButton()

		buttonIcon:SetInside()
		buttonIcon:SetTexCoord(unpack(E.TexCoords))

		questTexture:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\bagQuestIcon.tga")
		questTexture.SetTexture = E.noop
		questTexture:SetTexCoord(0, 1, 0, 1)
		questTexture:SetInside()

		cooldown.CooldownOverride = "bags"
		E:RegisterCooldown(cooldown)
	end

	BankFrame.itemBackdrop = CreateFrame("Frame", "BankFrameItemBackdrop", BankFrame)
	BankFrame.itemBackdrop:SetTemplate("Default")
	BankFrame.itemBackdrop:Point("TOPLEFT", BankFrameItem1, "TOPLEFT", -6, 6)
	BankFrame.itemBackdrop:Point("BOTTOMRIGHT", BankFrameItem28, "BOTTOMRIGHT", 6, -6)
	BankFrame.itemBackdrop:SetFrameLevel(BankFrame:GetFrameLevel())

	for i = 1, NUM_BANKBAGSLOTS, 1 do
		local button = _G["BankFrameBag"..i]
		local buttonIcon = _G["BankFrameBag"..i.."IconTexture"]

		button:SetNormalTexture(nil)
		button:SetTemplate("Default", true)
		button:StyleButton()

		buttonIcon:SetInside()
		buttonIcon:SetTexCoord(unpack(E.TexCoords))

		_G["BankFrameBag"..i.."HighlightFrameTexture"]:SetInside()
		_G["BankFrameBag"..i.."HighlightFrameTexture"]:SetTexture(unpack(E.media.rgbvaluecolor), 0.3)
	end

	BankFrame.bagBackdrop = CreateFrame("Frame", "BankFrameBagBackdrop", BankFrame)
	BankFrame.bagBackdrop:SetTemplate("Default")
	BankFrame.bagBackdrop:Point("TOPLEFT", BankFrameBag1, "TOPLEFT", -6, 6)
	BankFrame.bagBackdrop:Point("BOTTOMRIGHT", BankFrameBag7, "BOTTOMRIGHT", 6, -6)
	BankFrame.bagBackdrop:SetFrameLevel(BankFrame:GetFrameLevel())

	S:HandleButton(BankFramePurchaseButton)

	S:HandleEditBox(BankItemSearchBox)
	BankItemSearchBox:Point("TOPRIGHT", -22, -43)

	hooksecurefunc("BankFrameItemButton_Update", function(button)
		local id = button:GetID()
		local link, quality, questTexture
		local isQuestItem, questId, isActive

		if button.isBag then
			link = GetInventoryItemLink("player", ContainerIDToInventoryID(id))
		else
			link = GetContainerItemLink(BANK_CONTAINER, id)
		end

		if link then
			questTexture = _G[button:GetName().."IconQuestTexture"]
			isQuestItem, questId, isActive = GetContainerItemQuestInfo(BANK_CONTAINER, id)
			quality = select(3, GetItemInfo(link))

			if questTexture then
				questTexture:Hide()
			end

			if questId and not isActive then
				button:SetBackdropBorderColor(1.0, 1.0, 0.0)
				button.ignoreBorderColors = true
				if questTexture then
					questTexture:Show()
				end
			elseif questId or isQuestItem then
				button:SetBackdropBorderColor(1.0, 0.3, 0.3)
				button.ignoreBorderColors = true
			elseif quality then
				button:SetBackdropBorderColor(GetItemQualityColor(quality))
				button.ignoreBorderColors = true
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				button.ignoreBorderColors = true
			end
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			button.ignoreBorderColors = true
		end
	end)
end

S:AddCallback("SkinBags", LoadSkin)