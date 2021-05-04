local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local select, tonumber, unpack = select, tonumber, unpack
local match = string.match

local CreateFrame = CreateFrame
local GetContainerItemLink = GetContainerItemLink
local GetContainerItemQuestInfo = GetContainerItemQuestInfo
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local hooksecurefunc = hooksecurefunc

local C_NewItems_IsNewItem = C_NewItems.IsNewItem

local BACKPACK_TOOLTIP = BACKPACK_TOOLTIP
local BANK_CONTAINER = BANK_CONTAINER
local MAX_CONTAINER_ITEMS = MAX_CONTAINER_ITEMS
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS
local NUM_BANKBAGSLOTS = NUM_BANKBAGSLOTS
local NUM_BANKGENERIC_SLOTS = NUM_BANKGENERIC_SLOTS
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES

local bagIconCache = {}

local function LoadSkin()
	if E.private.bags.enable then return end
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.bags then return end

	local db = E.db.bags.colors.profession
	local ProfessionColors = {
		[0x0008] = {db.leatherworking.r, db.leatherworking.g, db.leatherworking.b},
		[0x0010] = {db.inscription.r, db.inscription.g, db.inscription.b},
		[0x0020] = {db.herbs.r, db.herbs.g, db.herbs.b},
		[0x0040] = {db.enchanting.r, db.enchanting.g, db.enchanting.b},
		[0x0080] = {db.engineering.r, db.engineering.g, db.engineering.b},
		[0x0200] = {db.gems.r, db.gems.g, db.gems.b},
		[0x0400] = {db.mining.r, db.mining.g, db.mining.b},
		[0x8000] = {db.fishing.r, db.fishing.g, db.fishing.b},
		[0x010000] = {db.cooking.r, db.cooking.g, db.cooking.b}
	}

	db = E.db.bags.colors.items
	local QuestColors = {
		questStarter = {db.questStarter.r, db.questStarter.g, db.questStarter.b},
		questItem =	{db.questItem.r, db.questItem.g, db.questItem.b}
	}

	-- Container Frame
	for i = 1, NUM_CONTAINER_FRAMES, 1 do
		local frame = _G["ContainerFrame"..i]
		local closeButton = _G["ContainerFrame"..i.."CloseButton"]

		frame:StripTextures(true)
		frame:CreateBackdrop("Transparent")
		frame.backdrop:Point("TOPLEFT", 9, -4)
		frame.backdrop:Point("BOTTOMRIGHT", -4, 2)

		S:HandleCloseButton(closeButton, frame.backdrop)

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

			questIcon:SetTexture(E.Media.Textures.BagQuestIcon)
			questIcon.SetTexture = E.noop
			questIcon:SetTexCoord(0, 1, 0, 1)
			questIcon:SetInside()

			item.newItemGlow = item:CreateTexture(nil, "OVERLAY")
			item.newItemGlow:SetInside()
			item.newItemGlow:SetTexture(E.Media.Textures.BagNewItemGlow)
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

		token:CreateBackdrop()
		token.backdrop:SetOutside(token.icon)

		token.icon:SetTexCoord(unpack(E.TexCoords))
		token.icon:Point("LEFT", token.count, "RIGHT", 2, 0)
		token.icon:Size(15)
	end

	local function BagIcon(container, texture)
		local portraitButton = _G[container:GetName().."PortraitButton"]

		if portraitButton then
			portraitButton:CreateBackdrop()
			portraitButton:Size(32)
			portraitButton:Point("TOPLEFT", 12, -7)
			portraitButton:StyleButton(nil, true)
			portraitButton.hover:SetAllPoints()

			if not container.BagIcon then
				container.BagIcon = portraitButton:CreateTexture()
				container.BagIcon:SetTexCoord(unpack(E.TexCoords))
				container.BagIcon:SetAllPoints()
			end

			container.BagIcon:SetTexture(texture)
		end
	end

	local function getQuality(link)
		local isBattlePet = match(link, "battlepet:(%d+)")
		local quality

		if isBattlePet then
			local petQuality = select(4, match(link, "(%l+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)"))
			quality = tonumber(petQuality)
		else
			quality = select(3, GetItemInfo(link))
		end

		return quality
	end

	hooksecurefunc("ContainerFrame_Update", function(frame)
		local id = frame:GetID()
		local _, bagType = GetContainerNumFreeSlots(id)
		local frameName = frame:GetName()
		local title = _G[frameName.."Name"]

		if title and title.GetText then
			local name = title:GetText()
			if bagIconCache[name] then
				BagIcon(frame, bagIconCache[name])
			else
				if name == BACKPACK_TOOLTIP then
					bagIconCache[name] = MainMenuBarBackpackButtonIconTexture:GetTexture()
				else
					bagIconCache[name] = select(10, GetItemInfo(name))
				end

				BagIcon(frame, bagIconCache[name])
			end
		end

		for i = 1, frame.size, 1 do
			local item = _G[frameName.."Item"..i]
			local questIcon = _G[frameName.."Item"..i.."IconQuestTexture"]
			local link = GetContainerItemLink(id, item:GetID())

			questIcon:Hide()

			if ProfessionColors[bagType] then
				local profR, profG, profB = unpack(B.ProfessionColors[bagType])
				item.newItemGlow:SetVertexColor(profR, profG, profB)
				item:SetBackdropBorderColor(profR, profG, profB)
				item.ignoreBorderColors = true
			elseif link then
				local isQuestItem, questId, isActive = GetContainerItemQuestInfo(id, item:GetID())
				local quality = getQuality(link)

				if questId and not isActive then
					local starterR, starterG, starterB = unpack(QuestColors.questStarter)
					item.newItemGlow:SetVertexColor(starterR, starterG, starterB)
					item:SetBackdropBorderColor(starterR, starterG, starterB)
					item.ignoreBorderColors = true
					questIcon:Show()
				elseif questId or isQuestItem then
					local questR, questG, questB = unpack(QuestColors.questItem)
					item.newItemGlow:SetVertexColor(questR, questG, questB)
					item:SetBackdropBorderColor(questR, questG, questB)
					item.ignoreBorderColors = true
				elseif quality and quality > 1 then
					local qualityR, qualityG, qualityB = GetItemQualityColor(quality)
					item.newItemGlow:SetVertexColor(qualityR, qualityG, qualityB)
					item:SetBackdropBorderColor(qualityR, qualityG, qualityB)
					item.ignoreBorderColors = true
				else
					item.newItemGlow:SetVertexColor(1, 1, 1)
					item:SetBackdropBorderColor(unpack(E.media.bordercolor))
					item.ignoreBorderColors = true
				end
			else
				item:SetBackdropBorderColor(unpack(E.media.bordercolor))
				item.ignoreBorderColors = nil
			end

			if C_NewItems_IsNewItem(id, item:GetID()) then
				item.newItemGlow:Show()
				E:Flash(item.newItemGlow, 0.5, true)
			else
				item.newItemGlow:Hide()
				E:StopFlash(item.newItemGlow)
			end

		end
	end)

	-- Bank Frame
	BankFrame:StripTextures(true)
	BankFrame:SetTemplate("Transparent")

	BankFrameMoneyFrameInset:StripTextures()
	BankFrameMoneyFrameBorder:StripTextures()

	S:HandleCloseButton(BankFrameCloseButton)

	for i = 1, NUM_BANKGENERIC_SLOTS, 1 do
		local button = _G["BankFrameItem"..i]
		local icon = _G["BankFrameItem"..i.."IconTexture"]
		local quest = _G["BankFrameItem"..i.."IconQuestTexture"]
		local cooldown = _G["BankFrameItem"..i.."Cooldown"]

		button:SetNormalTexture(nil)
		button:SetTemplate("Default", true)
		button:StyleButton()

		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))

		quest:SetTexture(E.Media.Textures.BagQuestIcon)
		quest.SetTexture = E.noop
		quest:SetTexCoord(0, 1, 0, 1)
		quest:SetInside()

		cooldown.CooldownOverride = "bags"
		E:RegisterCooldown(cooldown)
	end

	BankFrame.itemBackdrop = CreateFrame("Frame", "BankFrameItemBackdrop", BankFrame)
	BankFrame.itemBackdrop:SetTemplate()
	BankFrame.itemBackdrop:Point("TOPLEFT", BankFrameItem1, -6, 6)
	BankFrame.itemBackdrop:Point("BOTTOMRIGHT", BankFrameItem28, 6, -6)
	BankFrame.itemBackdrop:SetFrameLevel(BankFrame:GetFrameLevel())

	for i = 1, NUM_BANKBAGSLOTS, 1 do
		local button = _G["BankFrameBag"..i]
		local icon = _G["BankFrameBag"..i.."IconTexture"]
		local highlight = _G["BankFrameBag"..i.."HighlightFrameTexture"]

		button:SetNormalTexture(nil)
		button:SetTemplate("Default", true)
		button:StyleButton()

		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))

		highlight:SetInside()
		highlight:SetTexture(unpack(E.media.rgbvaluecolor), 0.3)
	end

	BankFrame.bagBackdrop = CreateFrame("Frame", "BankFrameBagBackdrop", BankFrame)
	BankFrame.bagBackdrop:SetTemplate()
	BankFrame.bagBackdrop:Point("TOPLEFT", BankFrameBag1, -6, 6)
	BankFrame.bagBackdrop:Point("BOTTOMRIGHT", BankFrameBag7, 6, -6)
	BankFrame.bagBackdrop:SetFrameLevel(BankFrame:GetFrameLevel())

	S:HandleButton(BankFramePurchaseButton)

	S:HandleEditBox(BankItemSearchBox)
	BankItemSearchBox:Point("TOPRIGHT", -49, -43)
	BankItemSearchBox:Width(150)

	hooksecurefunc("BankFrameItemButton_Update", function(button)
		local id = button:GetID()
		local link, quality
		local questTexture, isQuestItem, questId, isActive

		if button.isBag then
			link = GetInventoryItemLink("player", ContainerIDToInventoryID(id))
			if link then
				quality = select(3, GetItemInfo(link))
				if quality and quality > 1 then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
					button.ignoreBorderColors = true
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
					button.ignoreBorderColors = nil
				end
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				button.ignoreBorderColors = nil
			end
		else
			link = GetContainerItemLink(BANK_CONTAINER, id)
			questTexture = _G[button:GetName().."IconQuestTexture"]

			if questTexture then questTexture:Hide() end

			if link then
				isQuestItem, questId, isActive = GetContainerItemQuestInfo(BANK_CONTAINER, id)
				quality = getQuality(link)

				if questId and not isActive then
					button:SetBackdropBorderColor(unpack(QuestColors.questStarter))
					button.ignoreBorderColors = true
					if questTexture then questTexture:Show() end
				elseif questId or isQuestItem then
					button:SetBackdropBorderColor(unpack(QuestColors.questItem))
					button.ignoreBorderColors = true
				elseif quality and quality > 1 then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
					button.ignoreBorderColors = true
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
					button.ignoreBorderColors = nil
				end
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				button.ignoreBorderColors = nil
			end
		end
	end)
end

S:AddCallback("SkinBags", LoadSkin)