local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select
local find, gsub = string.find, string.gsub

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetLootRollItemInfo = GetLootRollItemInfo
local GetItemQualityColor = GetItemQualityColor

local NUM_GROUP_LOOT_FRAMES = NUM_GROUP_LOOT_FRAMES

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lootRoll then return end

	-- Bonus Roll Frame
	BonusRollFrame:StripTextures()
	BonusRollFrame:SetTemplate("Transparent")

	BonusRollFrame.BlackBackgroundHoist.Background:Hide()
	BonusRollFrame.BlackBackgroundHoist.backdrop = CreateFrame("Frame", nil, BonusRollFrame)
	BonusRollFrame.BlackBackgroundHoist.backdrop:SetTemplate()
	BonusRollFrame.BlackBackgroundHoist.backdrop:SetOutside(BonusRollFrame.PromptFrame.Timer)

	BonusRollFrame.CurrentCountFrame.Text:FontTemplate()
	BonusRollFrame.CurrentCountFrame:Point("BOTTOMRIGHT", BonusRollFrame, -5, 3)

	BonusRollFrame.PromptFrame.InfoFrame:Point("TOPLEFT", 54, -19)

	BonusRollFrame.PromptFrame.IconBackdrop = CreateFrame("Frame", nil, BonusRollFrame.PromptFrame)
	BonusRollFrame.PromptFrame.IconBackdrop:SetTemplate()
	BonusRollFrame.PromptFrame.IconBackdrop:SetOutside(BonusRollFrame.PromptFrame.Icon)
	BonusRollFrame.PromptFrame.IconBackdrop:SetFrameLevel(BonusRollFrame.PromptFrame.IconBackdrop:GetFrameLevel() - 1)

	BonusRollFrame.PromptFrame.Icon:SetTexCoord(unpack(E.TexCoords))
	BonusRollFrame.PromptFrame.Icon:Point("TOPLEFT", 6, -19)

	local classColor = E:ClassColor(E.myclass)
	BonusRollFrame.PromptFrame.Timer:SetStatusBarTexture(E.media.normTex)
	BonusRollFrame.PromptFrame.Timer:SetStatusBarColor(classColor.r, classColor.g, classColor.b)

	BonusRollFrame.PromptFrame.RollButton:Point("TOPRIGHT", -30, -21)

	BonusRollFrame.PromptFrame.PassButton:ClearAllPoints()
	S:HandleCloseButton(BonusRollFrame.PromptFrame.PassButton, BonusRollFrame, -2, -2)

	BonusRollFrame.SpecRing:SetTexture()

	BonusRollFrame.SpecIcon.backdrop = CreateFrame("Frame", nil, BonusRollFrame)
	BonusRollFrame.SpecIcon.backdrop:SetTemplate()
	BonusRollFrame.SpecIcon.backdrop:Point("TOPLEFT", BonusRollFrame, 33, 9)
	BonusRollFrame.SpecIcon.backdrop:Size(24)

	BonusRollFrame.SpecIcon:SetParent(BonusRollFrame.SpecIcon.backdrop)
	BonusRollFrame.SpecIcon:SetTexCoord(unpack(E.TexCoords))
	BonusRollFrame.SpecIcon:Size(22)
	BonusRollFrame.SpecIcon:ClearAllPoints()
	BonusRollFrame.SpecIcon:Point("TOPLEFT", BonusRollFrame, 34, 8)

	hooksecurefunc(BonusRollFrame.SpecIcon, "Hide", function(icon)
		if icon.backdrop and icon.backdrop:IsShown() then
			icon.backdrop:Hide()
		end
	end)

	hooksecurefunc(BonusRollFrame.SpecIcon, "Show", function(icon)
		if icon.backdrop and not icon.backdrop:IsShown() and icon:GetTexture() ~= nil then
			icon.backdrop:Show()
		end
	end)

	hooksecurefunc("BonusRollFrame_StartBonusRoll", function()
		local frameLevel = BonusRollFrame:GetFrameLevel()

		if frameLevel >= BonusRollFrame.PromptFrame.Timer:GetFrameLevel() then
			BonusRollFrame.PromptFrame.Timer:SetFrameLevel(frameLevel + 2)
		end

		if BonusRollFrame.BlackBackgroundHoist.backdrop and (frameLevel >= BonusRollFrame.BlackBackgroundHoist.backdrop:GetFrameLevel()) then
			BonusRollFrame.BlackBackgroundHoist.backdrop:SetFrameLevel(frameLevel + 1)
		end

		if BonusRollFrame.SpecIcon.backdrop then
			BonusRollFrame.SpecIcon.backdrop:SetShown(BonusRollFrame.SpecIcon:IsShown() and BonusRollFrame.SpecIcon:GetTexture() ~= nil)
		end

		local text = BonusRollFrame.CurrentCountFrame.Text and BonusRollFrame.CurrentCountFrame.Text:GetText()
		if text and find(text, "|t") then BonusRollFrame.CurrentCountFrame.Text:SetText(gsub(text, "|T(.-):.-|t", "|T%1:16:16:0:0:64:64:5:59:5:59|t")) end

		local cost = BonusRollFrame.PromptFrame.InfoFrame.Cost and BonusRollFrame.PromptFrame.InfoFrame.Cost:GetText()
		if cost and find(cost, "|t") then BonusRollFrame.PromptFrame.InfoFrame.Cost:SetText(gsub(cost, "|T(.-):.-|t", "|T%1:14:14:0:0:64:64:5:59:5:59|t")) end
	end)

	-- Roll Frame
	if E.private.general.lootRoll then return end

	local function OnShow(frame)
		frame:SetTemplate("Transparent")

		local r, g, b = GetItemQualityColor(select(4, GetLootRollItemInfo(frame.rollID)))
		frame.IconFrame:SetBackdropBorderColor(r, g, b)
		frame.Timer:SetStatusBarColor(r, g, b)

		local frameLevel = frame:GetFrameLevel()
		if frameLevel >= frame.Timer:GetFrameLevel() then
			frame.Timer:SetFrameLevel(frameLevel + 2)
		end
	end

	for i = 1, NUM_GROUP_LOOT_FRAMES do
		local frame = _G["GroupLootFrame"..i]

		frame:StripTextures()

		frame.IconFrame:SetTemplate()
		frame.IconFrame:StyleButton()
		frame.IconFrame:Point("TOPLEFT", 6, -6)

		frame.IconFrame.Border:Hide()

		frame.IconFrame.Icon:SetInside()
		frame.IconFrame.Icon:SetTexCoord(unpack(E.TexCoords))

		frame.Name:Point("TOPLEFT", 46, -8)

		frame.Timer:StripTextures()
		frame.Timer:CreateBackdrop()
		frame.Timer:SetStatusBarTexture(E.media.normTex)
		frame.Timer:Point("BOTTOMLEFT", 6, 9)
		E:RegisterStatusBar(frame.Timer)

		S:HandleCloseButton(frame.PassButton, frame)

		frame:HookScript("OnShow", OnShow)
	end
end

S:AddCallback("LootRoll", LoadSkin)