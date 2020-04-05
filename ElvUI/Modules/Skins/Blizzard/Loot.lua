local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select
local find = string.find

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetLootSlotInfo = GetLootSlotInfo
local GetLootRollItemInfo = GetLootRollItemInfo
local GetItemQualityColor = GetItemQualityColor
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local UnitName = UnitName
local IsFishingLoot = IsFishingLoot

local C_LootHistory_GetNumItems = C_LootHistory.GetNumItems

local LOOTFRAME_NUMBUTTONS = LOOTFRAME_NUMBUTTONS
local NUM_GROUP_LOOT_FRAMES = NUM_GROUP_LOOT_FRAMES
local LOOT, ITEMS = LOOT, ITEMS

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.loot then return end

	-- Loot History Frame
	LootHistoryFrame:StripTextures()
	LootHistoryFrame:SetTemplate("Transparent")

	LootHistoryFrameScrollFrame:StripTextures()

	LootHistoryFrame.ResizeButton:StripTextures()
	LootHistoryFrame.ResizeButton:SetTemplate("Default", true)
	LootHistoryFrame.ResizeButton:HookScript("OnEnter", S.SetModifiedBackdrop)
	LootHistoryFrame.ResizeButton:HookScript("OnLeave", S.SetOriginalBackdrop)
	LootHistoryFrame.ResizeButton:Width(LootHistoryFrame:GetWidth())
	LootHistoryFrame.ResizeButton:Height(19)
	LootHistoryFrame.ResizeButton:ClearAllPoints()
	LootHistoryFrame.ResizeButton:Point("TOP", LootHistoryFrame, "BOTTOM", 0, -2)

	LootHistoryFrame.ResizeButton.icon = LootHistoryFrame.ResizeButton:CreateTexture(nil, "ARTWORK")
	LootHistoryFrame.ResizeButton.icon:Size(20, 17)
	LootHistoryFrame.ResizeButton.icon:Point("CENTER")
	LootHistoryFrame.ResizeButton.icon:SetTexture(E.Media.Textures.ArrowUp)

	LootHistoryFrame.ScrollFrame:CreateBackdrop("Transparent")
	LootHistoryFrame.ScrollFrame.backdrop:Point("TOPLEFT", -1, 0)
	LootHistoryFrame.ScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -3)

	S:HandleScrollBar(LootHistoryFrameScrollFrameScrollBar)
	LootHistoryFrameScrollFrameScrollBar:ClearAllPoints()
	LootHistoryFrameScrollFrameScrollBar:Point("TOPRIGHT", LootHistoryFrame.ScrollFrame, 21, -18)
	LootHistoryFrameScrollFrameScrollBar:Point("BOTTOMRIGHT", LootHistoryFrame.ScrollFrame, 0, 15)

	S:HandleCloseButton(LootHistoryFrame.CloseButton, LootHistoryFrame)

	local function UpdateLoots()
		for i = 1, C_LootHistory_GetNumItems() do
			local frame = LootHistoryFrame.itemFrames[i]

			if not frame.isSkinned then
				local tex = frame.Icon:GetTexture()

				frame:StripTextures()
				frame:CreateBackdrop()
				frame.backdrop:SetOutside(frame.Icon)

				S:HandleButtonHighlight(frame, true)

				frame.Icon:SetTexture(tex)
				frame.Icon:SetTexCoord(unpack(E.TexCoords))
				frame.Icon:SetParent(frame.backdrop)

				frame.ToggleButton:Point("LEFT", 2, 0)

				frame.ToggleButton:SetNormalTexture(E.Media.Textures.Plus)
				frame.ToggleButton.SetNormalTexture = E.noop
				frame.ToggleButton:GetNormalTexture():Size(18)

				frame.ToggleButton:SetPushedTexture(E.Media.Textures.Plus)
				frame.ToggleButton.SetPushedTexture = E.noop
				frame.ToggleButton:GetPushedTexture():Size(18)

				frame.ToggleButton:SetDisabledTexture(E.Media.Textures.Plus)
				frame.ToggleButton.SetDisabledTexture = E.noop
				frame.ToggleButton:GetDisabledTexture():Size(18)

				frame.ToggleButton:SetHighlightTexture("")
				frame.ToggleButton.SetHighlightTexture = E.noop

				hooksecurefunc(frame.ToggleButton, "SetNormalTexture", function(self, texture)
					local normal, pushed = self:GetNormalTexture(), self:GetPushedTexture()

					if find(texture, "MinusButton") then
						normal:SetTexture(E.Media.Textures.Minus)
						pushed:SetTexture(E.Media.Textures.Minus)
					elseif find(texture, "PlusButton") then
						normal:SetTexture(E.Media.Textures.Plus)
						pushed:SetTexture(E.Media.Textures.Plus)
					else
						normal:SetTexture()
						pushed:SetTexture()
					end
				end)

				frame.isSkinned = true
			end

			local quality = select(3, GetItemInfo(frame.itemLink))
			local r, g, b = GetItemQualityColor(quality)

			frame.backdrop:SetBackdropBorderColor(r, g, b)
			frame.handledHighlight:SetVertexColor(r, g, b)
		end
	end
	hooksecurefunc("LootHistoryFrame_FullUpdate", UpdateLoots)

	-- MasterLoot Frame
	MasterLooterFrame:StripTextures()
	MasterLooterFrame:SetTemplate("Transparent")
	MasterLooterFrame:SetFrameStrata("TOOLTIP")

	hooksecurefunc("MasterLooterFrame_Show", function()
		local button = MasterLooterFrame.Item

		if button then
			local texture = button.Icon:GetTexture()
			local quality = ITEM_QUALITY_COLORS[LootFrame.selectedQuality]

			button:StripTextures()
			button:CreateBackdrop()
			button.backdrop:SetOutside(button.Icon)
			button.backdrop:SetBackdropBorderColor(quality.r, quality.g, quality.b)

			button.Icon:SetTexture(texture)
			button.Icon:SetTexCoord(unpack(E.TexCoords))
		end

		for i = 1, MasterLooterFrame:GetNumChildren() do
			local child = select(i, MasterLooterFrame:GetChildren())

			if child and not child.isSkinned and not child:GetName() then
				if child:GetObjectType() == "Button" then
					if child:GetPushedTexture() then
						S:HandleCloseButton(child)
					else
						child:StripTextures()
						child:SetTemplate()
						child:StyleButton()
					end

					child.isSkinned = true
				end
			end
		end
	end)

	-- Bonus Roll Frame
	BonusRollFrame:StripTextures()
	BonusRollFrame:SetTemplate("Transparent")

	BonusRollFrame.SpecRing:SetTexture()
	BonusRollFrame.CurrentCountFrame.Text:FontTemplate()

	BonusRollFrame.PromptFrame.Icon:SetTexCoord(unpack(E.TexCoords))

	BonusRollFrame.PromptFrame.IconBackdrop = CreateFrame("Frame", nil, BonusRollFrame.PromptFrame)
	BonusRollFrame.PromptFrame.IconBackdrop:SetFrameLevel(BonusRollFrame.PromptFrame.IconBackdrop:GetFrameLevel() - 1)
	BonusRollFrame.PromptFrame.IconBackdrop:SetOutside(BonusRollFrame.PromptFrame.Icon)
	BonusRollFrame.PromptFrame.IconBackdrop:SetTemplate()

	BonusRollFrame.PromptFrame.Timer:SetStatusBarTexture(E.media.normTex)
	BonusRollFrame.PromptFrame.Timer:SetStatusBarColor(unpack(E.media.rgbvaluecolor))

	BonusRollFrame.BlackBackgroundHoist.Background:Hide()

	BonusRollFrame.BlackBackgroundHoist.b = CreateFrame("Frame", nil, BonusRollFrame)
	BonusRollFrame.BlackBackgroundHoist.b:SetTemplate()
	BonusRollFrame.BlackBackgroundHoist.b:SetOutside(BonusRollFrame.PromptFrame.Timer)

	BonusRollFrame.SpecIcon.b = CreateFrame("Frame", nil, BonusRollFrame)
	BonusRollFrame.SpecIcon.b:SetTemplate()
	BonusRollFrame.SpecIcon.b:Point("BOTTOMRIGHT", BonusRollFrame, -2, 2)
	BonusRollFrame.SpecIcon.b:Size(BonusRollFrame.SpecIcon:GetSize())
	BonusRollFrame.SpecIcon.b:SetFrameLevel(6)

	BonusRollFrame.SpecIcon:SetParent(BonusRollFrame.SpecIcon.b)
	BonusRollFrame.SpecIcon:SetTexCoord(unpack(E.TexCoords))
	BonusRollFrame.SpecIcon:SetInside()

	hooksecurefunc(BonusRollFrame.SpecIcon, "Hide", function(specIcon)
		if specIcon.b and specIcon.b:IsShown() then
			BonusRollFrame.CurrentCountFrame:ClearAllPoints()
			BonusRollFrame.CurrentCountFrame:Point("BOTTOMRIGHT", BonusRollFrame, -2, 1)
			specIcon.b:Hide()
		end
	end)
	hooksecurefunc(BonusRollFrame.SpecIcon, "Show", function(specIcon)
		if specIcon.b and not specIcon.b:IsShown() and specIcon:GetTexture() ~= nil then
			BonusRollFrame.CurrentCountFrame:ClearAllPoints()
			BonusRollFrame.CurrentCountFrame:Point("RIGHT", BonusRollFrame.SpecIcon.b, "LEFT", -2, -2)
			specIcon.b:Show()
		end
	end)

	hooksecurefunc("BonusRollFrame_StartBonusRoll", function()
		--keep the status bar a frame above but its increased 1 extra beacuse mera has a grid layer
		local BonusRollFrameLevel = BonusRollFrame:GetFrameLevel()
		BonusRollFrame.PromptFrame.Timer:SetFrameLevel(BonusRollFrameLevel+2)
		if BonusRollFrame.BlackBackgroundHoist.b then
			BonusRollFrame.BlackBackgroundHoist.b:SetFrameLevel(BonusRollFrameLevel+1)
		end

		--set currency icons position at bottom right (or left of the spec icon, on the bottom right)
		BonusRollFrame.CurrentCountFrame:ClearAllPoints()
		if BonusRollFrame.SpecIcon.b then
			BonusRollFrame.SpecIcon.b:SetShown(BonusRollFrame.SpecIcon:IsShown() and BonusRollFrame.SpecIcon:GetTexture() ~= nil)
			if BonusRollFrame.SpecIcon.b:IsShown() then
				BonusRollFrame.CurrentCountFrame:Point("RIGHT", BonusRollFrame.SpecIcon.b, "LEFT", -2, -2)
			else
				BonusRollFrame.CurrentCountFrame:Point("BOTTOMRIGHT", BonusRollFrame, -2, 1)
			end
		else
			BonusRollFrame.CurrentCountFrame:Point("BOTTOMRIGHT", BonusRollFrame, -2, 1)
		end

		--skin currency icons
		local ccf, pfifc = BonusRollFrame.CurrentCountFrame.Text, BonusRollFrame.PromptFrame.InfoFrame.Cost
		local text1, text2 = ccf and ccf:GetText(), pfifc and pfifc:GetText()
		if text1 and text1:find("|t") then ccf:SetText(text1:gsub("|T(.-):.-|t", "|T%1:16:16:0:0:64:64:5:59:5:59|t")) end
		if text2 and text2:find("|t") then pfifc:SetText(text2:gsub("|T(.-):.-|t", "|T%1:16:16:0:0:64:64:5:59:5:59|t")) end
	end)

	-- Loot Frame
	if E.private.general.loot then return end

	LootFrame:StripTextures()
	LootFrame:SetTemplate("Transparent")

	LootFramePortraitOverlay:SetParent(E.HiddenFrame)

	S:HandleNextPrevButton(LootFrameUpButton)
	LootFrameUpButton:Size(24)

	S:HandleNextPrevButton(LootFrameDownButton)
	LootFrameDownButton:Size(24)

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

	LootFrameInset:Kill()

	S:HandleCloseButton(LootFrameCloseButton)
	LootFrameCloseButton:Point("CENTER", LootFrame, "TOPRIGHT", -87, -26)

	for i = 1, LootFrame:GetNumRegions() do
		local region = select(i, LootFrame:GetRegions())
		if region:GetObjectType() == "FontString" then
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
		local nameFrame = _G["LootButton"..i.."NameFrame"]
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

		nameFrame:Hide()
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

local function LoadRollSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lootRoll then return end

	local function OnShow(self)
		local _, _, _, quality = GetLootRollItemInfo(self.rollID)
		local r, g, b = GetItemQualityColor(quality)

		self:SetTemplate("Transparent")

		self.IconFrame:SetBackdropBorderColor(r, g, b)
		self.Timer:SetStatusBarColor(r, g, b)
	end

	for i = 1, NUM_GROUP_LOOT_FRAMES do
		local frame = _G["GroupLootFrame"..i]

		frame:StripTextures()
		frame:ClearAllPoints()

		if i == 1 then
			frame:Point("TOP", AlertFrameHolder, "BOTTOM", 0, -4)
		else
			frame:Point("TOP", _G["GroupLootFrame"..i - 1], "BOTTOM", 0, -4)
		end

		frame.IconFrame:SetTemplate()
		frame.IconFrame:StyleButton()
		frame.IconFrame.Border:Hide()

		frame.IconFrame.Icon:SetInside()
		frame.IconFrame.Icon:SetTexCoord(unpack(E.TexCoords))

		frame.Timer:StripTextures()
		frame.Timer:CreateBackdrop()
		frame.Timer:SetStatusBarTexture(E.media.normTex)
		frame.Timer:Point("BOTTOMLEFT", 6, 9)
		E:RegisterStatusBar(frame.Timer)

		S:HandleCloseButton(frame.PassButton, frame)

		frame:HookScript("OnShow", OnShow)
	end
end

S:AddCallback("Loot", LoadSkin)
S:AddCallback("LootRoll", LoadRollSkin)