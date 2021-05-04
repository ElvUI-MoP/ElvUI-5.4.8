local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetLootSlotInfo = GetLootSlotInfo
local GetMissingLootItemInfo = GetMissingLootItemInfo
local GetNumMissingLootItems = GetNumMissingLootItems
local GetItemQualityColor = GetItemQualityColor
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local UnitName = UnitName
local IsFishingLoot = IsFishingLoot

local LOOTFRAME_NUMBUTTONS = LOOTFRAME_NUMBUTTONS
local LOOT, ITEMS = LOOT, ITEMS

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.loot then return end

	-- Master Loot Frame
	MasterLooterFrame:StripTextures()
	MasterLooterFrame:SetTemplate("Transparent")
	MasterLooterFrame:SetFrameStrata("TOOLTIP")
	MasterLooterFrame:EnableMouse(true)

	hooksecurefunc("MasterLooterFrame_Show", function()
		local button = MasterLooterFrame.Item

		if button then
			if not button.isSkinned then
				button:StripTextures()
				button:CreateBackdrop()
				button.backdrop:SetOutside(button.Icon)

				button.Icon:SetTexCoord(unpack(E.TexCoords))

				button.isSkinned = true
			end

			local quality = ITEM_QUALITY_COLORS[LootFrame.selectedQuality]
			button.backdrop:SetBackdropBorderColor(quality.r, quality.g, quality.b)

			button.Icon:SetTexture(LootFrame.selectedTexture)
		end

		for i = 1, MasterLooterFrame:GetNumChildren() do
			local child = select(i, MasterLooterFrame:GetChildren())

			if child and not child:GetName() and child.IsObjectType and child:IsObjectType("Button") and not child.isSkinned then
				if child:GetPushedTexture() then
					S:HandleCloseButton(child)
				else
					child:StripTextures()
					child:SetTemplate("Transparent")
					S:HandleButtonHighlight(child, true)
					child.handledHighlight:SetInside()
				end

				child.isSkinned = true
			end
		end
	end)

	-- Missing Loot Frame
	MissingLootFrame:StripTextures()
	MissingLootFrame:CreateBackdrop("Transparent")
	MissingLootFrame.backdrop:Point("TOPLEFT", 2, -8)
	MissingLootFrame.backdrop:Point("BOTTOMRIGHT", -2, 6)

	S:HandleCloseButton(MissingLootFramePassButton, MissingLootFrame.backdrop)

	hooksecurefunc("MissingLootFrame_Show", function()
		for i = 1, GetNumMissingLootItems() do
			local item = _G["MissingLootFrameItem"..i]

			if not item.isSkinned then
				item:StripTextures()
				item:SetTemplate()
				item:StyleButton()

				item.icon:SetTexCoord(unpack(E.TexCoords))
				item.icon:SetDrawLayer("ARTWORK")
				item.icon:SetInside()

				item.isSkinned = true
			end

			local texture, _, _, quality = GetMissingLootItemInfo(i)
			local color = ITEM_QUALITY_COLORS[quality]

			item:SetBackdropBorderColor(color.r, color.g, color.b)
			item.icon:SetTexture(texture)
		end
	end)

	-- Loot Frame
	if E.private.general.loot then return end

	LootFramePortraitOverlay:SetParent(E.HiddenFrame)
	LootFrameInset:Kill()

	LootFrame:StripTextures()
	LootFrame:SetTemplate("Transparent")
	LootFrame:SetFrameStrata("DIALOG")
	LootFrame:EnableMouseWheel(true)
	LootFrame:SetScript("OnMouseWheel", function(_, value)
		if value > 0 then
			if LootFrameUpButton:IsShown() and LootFrameUpButton:IsEnabled() == 1 then
				LootFrame_PageUp()
			end
		else
			if LootFrameDownButton:IsShown() and LootFrameDownButton:IsEnabled() == 1 then
				LootFrame_PageDown()
			end
		end
	end)

	S:HandleNextPrevButton(LootFrameUpButton)
	LootFrameUpButton:Size(24)

	S:HandleNextPrevButton(LootFrameDownButton)
	LootFrameDownButton:Size(24)

	S:HandleCloseButton(LootFrameCloseButton)
	LootFrameCloseButton:Point("CENTER", LootFrame, "TOPRIGHT", -87, -26)

	for i = 1, LootFrame:GetNumRegions() do
		local region = select(i, LootFrame:GetRegions())

		if region.IsObjectType and region:IsObjectType("FontString") then
			if region:GetText() == ITEMS then
				LootFrame.Title = region
			end
		end
	end

	LootFrame.Title:ClearAllPoints()
	LootFrame.Title:Point("TOPLEFT", LootFrame.backdrop, "TOPLEFT", 4, -4)
	LootFrame.Title:SetJustifyH("LEFT")

	LootFrame:HookScript("OnShow", function(self)
		if IsFishingLoot() then
			self.Title:SetText(L["Fishy Loot"])
		elseif not UnitIsFriend("player", "target") and UnitIsDead("target") then
			self.Title:SetText(UnitName("target"))
		else
			self.Title:SetText(LOOT)
		end
	end)

	for i = 1, LOOTFRAME_NUMBUTTONS do
		local button = _G["LootButton"..i]
		local questTexture = _G["LootButton"..i.."IconQuestTexture"]

		S:HandleItemButton(button, true)

		button.bg = CreateFrame("Frame", nil, button)
		button.bg:SetTemplate()
		button.bg:Point("TOPLEFT", 40, 0)
		button.bg:Point("BOTTOMRIGHT", 110, 0)
		button.bg:SetFrameLevel(button.bg:GetFrameLevel() - 1)

		questTexture:SetTexture(E.Media.Textures.BagQuestIcon)
		questTexture.SetTexture = E.noop
		questTexture:SetTexCoord(0, 1, 0, 1)
		questTexture:SetInside()

		_G["LootButton"..i.."NameFrame"]:Hide()
	end

	local QuestColors = {
		questStarter = {E.db.bags.colors.items.questStarter.r, E.db.bags.colors.items.questStarter.g, E.db.bags.colors.items.questStarter.b},
		questItem =	{E.db.bags.colors.items.questItem.r, E.db.bags.colors.items.questItem.g, E.db.bags.colors.items.questItem.b}
	}

	hooksecurefunc("LootFrame_UpdateButton", function(index)
		local numLootItems = LootFrame.numLootItems
		local numLootToShow = LOOTFRAME_NUMBUTTONS
		if numLootItems > LOOTFRAME_NUMBUTTONS then
			numLootToShow = numLootToShow - 1
		end

		local button = _G["LootButton"..index]
		local slot = (numLootToShow * (LootFrame.page - 1)) + index

		if slot <= numLootItems then
			if LootSlotHasItem(slot) and index <= numLootToShow then
				local texture, _, _, quality, _, isQuestItem, questId, isActive = GetLootSlotInfo(slot)
				if texture then
					local questTexture = _G["LootButton"..index.."IconQuestTexture"]

					questTexture:Hide()

					if questId and not isActive then
						button.backdrop:SetBackdropBorderColor(unpack(QuestColors.questStarter))
						questTexture:Show()
					elseif questId or isQuestItem then
						button.backdrop:SetBackdropBorderColor(unpack(QuestColors.questItem))
					elseif quality then
						button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					else
						button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
					end
				end
			end
		end
	end)
end

S:AddCallback("Loot", LoadSkin)