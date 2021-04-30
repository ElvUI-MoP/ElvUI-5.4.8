local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select
local find = string.find

local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetTradeSkillItemLink = GetTradeSkillItemLink
local GetTradeSkillReagentInfo = GetTradeSkillReagentInfo
local GetTradeSkillReagentItemLink = GetTradeSkillReagentItemLink
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tradeskill then return end

	TRADE_SKILLS_DISPLAYED = 26

	TradeSkillFrame:StripTextures(true)
	TradeSkillFrame:SetTemplate("Transparent")
	TradeSkillFrame:Size(670, 508)

	S:SetUIPanelWindowInfo(TradeSkillFrame, "width")

	TradeSkillFrame.bg1 = CreateFrame("Frame", nil, TradeSkillFrame)
	TradeSkillFrame.bg1:SetTemplate("Transparent")
	TradeSkillFrame.bg1:Point("TOPLEFT", 6, -84)
	TradeSkillFrame.bg1:Point("BOTTOMRIGHT", -367, 6)
	TradeSkillFrame.bg1:SetFrameLevel(TradeSkillFrame.bg1:GetFrameLevel() - 1)

	TradeSkillFrame.bg2 = CreateFrame("Frame", nil, TradeSkillFrame)
	TradeSkillFrame.bg2:SetTemplate("Transparent")
	TradeSkillFrame.bg2:Point("TOPLEFT", TradeSkillFrame.bg1, "TOPRIGHT", 26, 0)
	TradeSkillFrame.bg2:Point("BOTTOMRIGHT", TradeSkillFrame, -28, 32)
	TradeSkillFrame.bg2:SetFrameLevel(TradeSkillFrame.bg2:GetFrameLevel() - 1)

	TradeSkillFrameInset:StripTextures()

	TradeSkillRankFrame:StripTextures()
	TradeSkillRankFrame:CreateBackdrop()
	TradeSkillRankFrame:Size(447, 17)
	TradeSkillRankFrame:ClearAllPoints()
	TradeSkillRankFrame:Point("TOP", 0, -25)
	TradeSkillRankFrame:SetStatusBarTexture(E.media.normTex)
	TradeSkillRankFrame:SetStatusBarColor(0.22, 0.39, 0.84)
	TradeSkillRankFrame.SetStatusBarColor = E.noop
	E:RegisterStatusBar(TradeSkillRankFrame)

	TradeSkillRankFrameSkillRank:ClearAllPoints()
	TradeSkillRankFrameSkillRank:Point("CENTER", TradeSkillRankFrame)

	S:HandleEditBox(TradeSkillFrameSearchBox)
	TradeSkillFrameSearchBox:Width(191)
	TradeSkillFrameSearchBox:Point("TOPLEFT", TradeSkillRankFrame, "BOTTOMLEFT", 0, -9)

	TradeSkillLinkFrame:Point("LEFT", TradeSkillRankFrame, "RIGHT", -18, -23)

	S:HandleNextPrevButton(TradeSkillLinkButton, "right")
	TradeSkillLinkButton:Size(22)
	TradeSkillLinkButton:Point("LEFT", -3, -3)

	TradeSkillListScrollFrame:StripTextures()
	TradeSkillListScrollFrame:Size(285, 405)
	TradeSkillListScrollFrame:ClearAllPoints()
	TradeSkillListScrollFrame:Point("TOPLEFT", 17, -95)
	TradeSkillListScrollFrame:Show()
	TradeSkillListScrollFrame.Hide = E.noop

	S:HandleScrollBar(TradeSkillListScrollFrameScrollBar)
	TradeSkillListScrollFrameScrollBar:ClearAllPoints()
	TradeSkillListScrollFrameScrollBar:Point("TOPRIGHT", TradeSkillListScrollFrame, 22, -7)
	TradeSkillListScrollFrameScrollBar:Point("BOTTOMRIGHT", TradeSkillListScrollFrame, 0, 16)

	TradeSkillDetailScrollFrame:StripTextures()
	TradeSkillDetailScrollFrame:Size(310, 381)
	TradeSkillDetailScrollFrame:ClearAllPoints()
	TradeSkillDetailScrollFrame:Point("TOPLEFT", TradeSkillListScrollFrame, "TOPRIGHT", 28, 0)
	TradeSkillDetailScrollFrame.scrollBarHideable = nil

	S:HandleScrollBar(TradeSkillDetailScrollFrameScrollBar)
	TradeSkillDetailScrollFrameScrollBar:ClearAllPoints()
	TradeSkillDetailScrollFrameScrollBar:Point("TOPRIGHT", TradeSkillDetailScrollFrame, 23, -7)
	TradeSkillDetailScrollFrameScrollBar:Point("BOTTOMRIGHT", TradeSkillDetailScrollFrame, 0, 18)

	for i = 9, TRADE_SKILLS_DISPLAYED do
		CreateFrame("Button", "TradeSkillSkill"..i, TradeSkillFrame, "TradeSkillSkillButtonTemplate"):Point("TOPLEFT", _G["TradeSkillSkill"..i - 1], "BOTTOMLEFT")
	end

	TradeSkillDetailScrollChildFrame:StripTextures()
	TradeSkillDetailScrollChildFrame:Size(300, 150)

	TradeSkillSkillName:Point("TOPLEFT", 58, -3)
	TradeSkillDescription:Point("TOPLEFT", 8, -75)

	TradeSkillSkillIcon:SetTemplate()
	TradeSkillSkillIcon:StyleButton(nil, true)
	TradeSkillSkillIcon:Size(48)
	TradeSkillSkillIcon:Point("TOPLEFT", 6, -1)

	S:HandleButton(TradeSkillCreateAllButton)
	TradeSkillCreateAllButton:ClearAllPoints()
	TradeSkillCreateAllButton:Point("TOPLEFT", TradeSkillDetailScrollFrame, "BOTTOMLEFT", -1, -4)

	S:HandleNextPrevButton(TradeSkillDecrementButton)
	TradeSkillDecrementButton:Height(22)
	TradeSkillDecrementButton:Point("LEFT", TradeSkillCreateAllButton, "RIGHT", 2, 0)

	S:HandleEditBox(TradeSkillInputBox)
	TradeSkillInputBox:Size(25, 20)
	TradeSkillInputBox:Point("LEFT", TradeSkillDecrementButton, "RIGHT", 3, 0)

	S:HandleNextPrevButton(TradeSkillIncrementButton)
	TradeSkillIncrementButton:Height(22)
	TradeSkillIncrementButton:ClearAllPoints()
	TradeSkillIncrementButton:Point("LEFT", TradeSkillInputBox, "RIGHT", 3, 0)

	S:HandleButton(TradeSkillCreateButton)
	TradeSkillCreateButton:ClearAllPoints()
	TradeSkillCreateButton:Point("LEFT", TradeSkillIncrementButton, "RIGHT", 2, 0)

	S:HandleButton(TradeSkillCancelButton)
	TradeSkillCancelButton:ClearAllPoints()
	TradeSkillCancelButton:Point("LEFT", TradeSkillCreateButton, "RIGHT", 2, 0)

	TradeSkillExpandButtonFrame:Point("TOPLEFT", TradeSkillFrame, 2, -58)

	S:HandleButton(TradeSkillFilterButton, true)
	TradeSkillFilterButton:Size(65, 22)

	S:HandleCloseButton(TradeSkillFrameCloseButton)

	TradeSkillRequirementLabel:SetTextColor(1, 0.80, 0.10)

	for i = 1, MAX_TRADE_SKILL_REAGENTS do
		local reagent = _G["TradeSkillReagent"..i]
		local icon = _G["TradeSkillReagent"..i.."IconTexture"]
		local count = _G["TradeSkillReagent"..i.."Count"]
		local nameFrame = _G["TradeSkillReagent"..i.."NameFrame"]

		reagent:SetTemplate()
		reagent:StyleButton(nil, true)
		reagent:Height(40)

		icon.backdrop = CreateFrame("Frame", nil, reagent)
		icon.backdrop:SetTemplate()
		icon.backdrop:Point("TOPLEFT", icon, -1, 1)
		icon.backdrop:Point("BOTTOMRIGHT", icon, 1, -1)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetDrawLayer("OVERLAY")
		icon:Size(E.PixelMode and 38 or 32)
		icon:Point("TOPLEFT", E.PixelMode and 1 or 4, -(E.PixelMode and 1 or 4))
		icon:SetParent(icon.backdrop)

		count:SetParent(icon.backdrop)
		count:SetDrawLayer("OVERLAY")

		_G["TradeSkillReagent"..i.."Name"]:Point("LEFT", nameFrame, "LEFT", 20, 0)

		nameFrame:Kill()
	end

	TradeSkillReagent1:Point("TOPLEFT", TradeSkillReagentLabel, "BOTTOMLEFT", -2, -3)
	TradeSkillReagent2:Point("LEFT", TradeSkillReagent1, "RIGHT", 4, 0)
	TradeSkillReagent3:Point("TOPLEFT", TradeSkillReagent1, "BOTTOMLEFT", 0, -4)
	TradeSkillReagent4:Point("LEFT", TradeSkillReagent3, "RIGHT", 4, 0)
	TradeSkillReagent5:Point("TOPLEFT", TradeSkillReagent3, "BOTTOMLEFT", 0, -4)
	TradeSkillReagent6:Point("LEFT", TradeSkillReagent5, "RIGHT", 4, 0)
	TradeSkillReagent7:Point("TOPLEFT", TradeSkillReagent5, "BOTTOMLEFT", 0, -4)
	TradeSkillReagent8:Point("LEFT", TradeSkillReagent7, "RIGHT", 4, 0)

	TradeSkillFilterBar:StripTextures()
	TradeSkillFilterBar.texture = TradeSkillFilterBar:CreateTexture(nil, "ARTWORK")
	TradeSkillFilterBar.texture:SetAllPoints()
	TradeSkillFilterBar.texture:SetTexture(E.Media.Textures.Highlight)
	TradeSkillFilterBar.texture:SetVertexColor(1, 1, 1, 0.35)

	S:HandleCloseButton(TradeSkillFilterBarExitButton)
	TradeSkillFilterBarExitButton:Size(26)
	TradeSkillFilterBarExitButton.Texture:SetVertexColor(1, 0, 0)
	TradeSkillFilterBarExitButton:HookScript("OnEnter", function(btn) btn.Texture:SetVertexColor(1, 1, 1) end)
	TradeSkillFilterBarExitButton:HookScript("OnLeave", function(btn) btn.Texture:SetVertexColor(1, 0, 0) end)

	TradeSkillHighlight:SetTexture(E.Media.Textures.Highlight)
	TradeSkillHighlight:SetAlpha(0.35)

	hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
		local texture = TradeSkillSkillIcon:GetNormalTexture()
		if texture then
			TradeSkillSkillIcon:SetAlpha(1)
			texture:SetTexCoord(unpack(E.TexCoords))
			texture:SetInside()
		else
			TradeSkillSkillIcon:SetAlpha(0)
		end

		local skillLink = GetTradeSkillItemLink(id)
		if skillLink then
			local quality = select(3, GetItemInfo(skillLink))
			if quality then
				local r, g, b = GetItemQualityColor(quality)
				TradeSkillSkillIcon:SetBackdropBorderColor(r, g, b)
				TradeSkillSkillName:SetTextColor(r, g, b)
			else
				TradeSkillSkillIcon:SetBackdropBorderColor(unpack(E.media.bordercolor))
				TradeSkillSkillName:SetTextColor(1, 1, 1)
			end
		end

		for i = 1, GetTradeSkillNumReagents(id), 1 do
			local _, _, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i)
			local reagentLink = GetTradeSkillReagentItemLink(id, i)

			if reagentLink then
				local reagent = _G["TradeSkillReagent"..i]
				local icon = _G["TradeSkillReagent"..i.."IconTexture"]
				local quality = select(3, GetItemInfo(reagentLink))

				if quality then
					local name = _G["TradeSkillReagent"..i.."Name"]
					local r, g, b = GetItemQualityColor(quality)

					icon.backdrop:SetBackdropBorderColor(r, g, b)
					reagent:SetBackdropBorderColor(r, g, b)

					if playerReagentCount < reagentCount then
						name:SetTextColor(0.5, 0.5, 0.5)
					else
						name:SetTextColor(r, g, b)
					end
				else
					reagent:SetBackdropBorderColor(unpack(E.media.bordercolor))
					icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end
		end
	end)

	-- Expand / Collapse Buttons
	TradeSkillExpandButtonFrame:StripTextures()

	TradeSkillCollapseAllButton:SetNormalTexture(E.Media.Textures.Plus)
	TradeSkillCollapseAllButton.SetNormalTexture = E.noop

	local collapseNormal = TradeSkillCollapseAllButton:GetNormalTexture()
	collapseNormal:Point("LEFT", 3, 2)
	collapseNormal:Size(16)
	collapseNormal:SetVertexColor(1, 1, 1)

	TradeSkillCollapseAllButton:SetHighlightTexture("")
	TradeSkillCollapseAllButton.SetHighlightTexture = E.noop

	TradeSkillCollapseAllButton:SetDisabledTexture(E.Media.Textures.Plus)
	TradeSkillCollapseAllButton.SetDisabledTexture = E.noop

	local collapseDisabled = TradeSkillCollapseAllButton:GetDisabledTexture()
	collapseDisabled:Point("LEFT", 3, 2)
	collapseDisabled:Size(16)
	collapseDisabled:SetVertexColor(0.6, 0.6, 0.6)

	hooksecurefunc(TradeSkillCollapseAllButton, "SetNormalTexture", function(self, texture)
		local normal = self:GetNormalTexture()

		if find(texture, "MinusButton") then
			normal:SetTexture(E.Media.Textures.Minus)
		else
			normal:SetTexture(E.Media.Textures.Plus)
		end
	end)

	for i = 1, TRADE_SKILLS_DISPLAYED do
		local button = _G["TradeSkillSkill"..i]
		local highlight = _G["TradeSkillSkill"..i.."Highlight"]

		button:SetNormalTexture(E.Media.Textures.Plus)
		button.SetNormalTexture = E.noop

		local normal = button:GetNormalTexture()
		normal:Size(14)
		normal:Point("LEFT", 3, 2)
		normal.SetPoint = E.noop

		highlight:SetTexture("")
		highlight.SetTexture = E.noop

		button.SubSkillRankBar:StripTextures()
		button.SubSkillRankBar:CreateBackdrop()
		button.SubSkillRankBar.backdrop:SetOutside()
		button.SubSkillRankBar:Height(12)
		button.SubSkillRankBar:SetStatusBarTexture(E.media.normTex)
		button.SubSkillRankBar:SetStatusBarColor(0.22, 0.39, 0.84)
		E:RegisterStatusBar(button.SubSkillRankBar)

		button.SubSkillRankBar.Rank:Point("CENTER", 0, -1)

		hooksecurefunc(button, "SetNormalTexture", function(_, texture)
			if find(texture, "MinusButton") then
				normal:SetTexture(E.Media.Textures.Minus)
			elseif find(texture, "PlusButton") then
				normal:SetTexture(E.Media.Textures.Plus)
			else
				normal:SetTexture("")
			end
		end)
	end

	-- Guild Crafters
	TradeSkillGuildFrame:StripTextures()
	TradeSkillGuildFrame:SetTemplate("Transparent")
	TradeSkillGuildFrame:Point("BOTTOMLEFT", TradeSkillFrame, "BOTTOMRIGHT", 3, 19)

	TradeSkillGuildFrameContainer:StripTextures()
	TradeSkillGuildFrameContainer:SetTemplate()

	S:HandleButton(TradeSkillViewGuildCraftersButton)
	TradeSkillViewGuildCraftersButton:Point("BOTTOMLEFT", 333, 7)

	S:HandleCloseButton(TradeSkillGuildFrameCloseButton)
end

S:AddCallbackForAddon("Blizzard_TradeSkillUI", "TradeSkill", LoadSkin)