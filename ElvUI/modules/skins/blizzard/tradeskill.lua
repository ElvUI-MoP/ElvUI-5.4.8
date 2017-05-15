local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local unpack, select = unpack, select;
local find = string.find;

local GetItemInfo = GetItemInfo;
local GetItemQualityColor = GetItemQualityColor;
local GetTradeSkillItemLink = GetTradeSkillItemLink;
local GetTradeSkillReagentInfo = GetTradeSkillReagentInfo;
local GetTradeSkillReagentItemLink = GetTradeSkillReagentItemLink;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tradeskill ~= true) then return; end

	TradeSkillFrame:StripTextures(true);
	TradeSkillFrameInset:StripTextures();
	TradeSkillListScrollFrame:StripTextures();
	TradeSkillDetailScrollFrame:StripTextures();
	TradeSkillDetailScrollChildFrame:StripTextures();

	if(not E.private.skins.tradeSkillBig) then
		TradeSkillFrame:SetTemplate("Transparent");

		TradeSkillLinkFrame:Point("LEFT", TradeSkillRankFrame, "RIGHT", -18, -21)

		TradeSkillFilterButton:Size(60, 19);

		TradeSkillRankFrame:Size(280, 16);
		TradeSkillRankFrame:Point("TOPLEFT", TradeSkillFrame, "TOPLEFT", 28, -22);

		TradeSkillFrameSearchBox:Size(170, 17);
		TradeSkillFrameSearchBox:Point("TOPLEFT", TradeSkillRankFrame, "BOTTOMLEFT", 0, -5);

		TradeSkillExpandButtonFrame:Point("TOPLEFT", TradeSkillFrame, "TOPLEFT", 0, -60)

		TradeSkillDecrementButton:Point("LEFT", TradeSkillCreateAllButton, "RIGHT", 8, 0);
		TradeSkillIncrementButton:Point("RIGHT", TradeSkillCreateButton, "LEFT", -9, 0);
	else
		TRADE_SKILLS_DISPLAYED = 25;

		TradeSkillFrame:SetAttribute("UIPanelLayout-width", E:Scale(720));
		TradeSkillFrame:SetAttribute("UIPanelLayout-height", E:Scale(508));
		TradeSkillFrame:Size(720, 508);

		TradeSkillFrame:CreateBackdrop("Transparent");
		TradeSkillFrame.backdrop:Point("TOPLEFT", 5, 0);
		TradeSkillFrame.backdrop:Point("BOTTOMRIGHT", -60, 0);

		TradeSkillRankFrame:Size(447, 17);
		TradeSkillRankFrame:ClearAllPoints();
		TradeSkillRankFrame:Point("TOP", 0, -25);

		TradeSkillFrameSearchBox:Point("TOPLEFT", TradeSkillRankFrame, "BOTTOMLEFT", 0, -9)

		TradeSkillLinkFrame:Point("LEFT", TradeSkillRankFrame, "RIGHT", -18, -23)

		TradeSkillFilterButton:Size(65, 22);

		TradeSkillListScrollFrame:Size(285, 405);
		TradeSkillListScrollFrame:ClearAllPoints();
		TradeSkillListScrollFrame:Point("TOPLEFT", 17, -95);

		TradeSkillDetailScrollFrame:Size(300, 381);
		TradeSkillDetailScrollFrame:ClearAllPoints();
		TradeSkillDetailScrollFrame:Point("TOPRIGHT", TradeSkillFrame, -90, -95);
		TradeSkillDetailScrollFrame.scrollBarHideable = nil;

		for i = 9, 25 do
			CreateFrame("Button", "TradeSkillSkill" .. i, TradeSkillFrame, "TradeSkillSkillButtonTemplate"):Point("TOPLEFT", _G["TradeSkillSkill" .. i - 1], "BOTTOMLEFT");
		end

		TradeSkillDetailScrollChildFrame:Size(300, 150);

		TradeSkillSkillName:Point("TOPLEFT", 65, -20);

		TradeSkillDescription:Point("TOPLEFT", 8, -75);

		TradeSkillSkillIcon:Size(47);
		TradeSkillSkillIcon:Point("TOPLEFT", 5, -1);

		TradeSkillCancelButton:ClearAllPoints();
		TradeSkillCancelButton:Point("TOPRIGHT", TradeSkillDetailScrollFrame, "BOTTOMRIGHT", 23, -3);

		TradeSkillCreateButton:ClearAllPoints();
		TradeSkillCreateButton:Point("TOPRIGHT", TradeSkillCancelButton, "TOPLEFT", -3, 0);

		TradeSkillCreateAllButton:ClearAllPoints();
		TradeSkillCreateAllButton:Point("TOPLEFT", TradeSkillDetailScrollFrame, "BOTTOMLEFT", 4, -3);

		TradeSkillFrameCloseButton:Point("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -55, 5)

		TradeSkillExpandButtonFrame:Point("TOPLEFT", TradeSkillFrame, "TOPLEFT", 2, -58)

		TradeSkillViewGuildCraftersButton:Point("BOTTOMLEFT", 330, 8)
	end

	S:HandleButton(TradeSkillCancelButton);
	S:HandleButton(TradeSkillCreateButton);
	S:HandleButton(TradeSkillCreateAllButton);

	S:HandleNextPrevButton(TradeSkillDecrementButton);
	S:HandleNextPrevButton(TradeSkillIncrementButton);

	TradeSkillInputBox:Height(16);
	S:HandleEditBox(TradeSkillInputBox);

	S:HandleCloseButton(TradeSkillFrameCloseButton);

	TradeSkillFilterButton:StripTextures(true);
	TradeSkillFilterButton.backdrop = CreateFrame("Frame", nil, TradeSkillFilterButton)
	TradeSkillFilterButton.backdrop:SetTemplate("Default", true)
	TradeSkillFilterButton.backdrop:SetFrameLevel(TradeSkillFilterButton:GetFrameLevel() - 1)
	TradeSkillFilterButton.backdrop:SetAllPoints();

	TradeSkillFilterButton:HookScript("OnEnter", S.SetModifiedBackdrop);
	TradeSkillFilterButton:HookScript("OnLeave", S.SetOriginalBackdrop);

	TradeSkillLinkButton:GetNormalTexture():SetTexCoord(0.25, 0.7, 0.37, 0.75);
	TradeSkillLinkButton:GetPushedTexture():SetTexCoord(0.25, 0.7, 0.45, 0.8);
	TradeSkillLinkButton:GetHighlightTexture():Kill();
	TradeSkillLinkButton:CreateBackdrop("Default");
	TradeSkillLinkButton:Size(17, 14);

	TradeSkillRankFrame:StripTextures();
	TradeSkillRankFrame:CreateBackdrop();
	TradeSkillRankFrame:SetStatusBarTexture(E["media"].normTex);
	TradeSkillRankFrame:SetStatusBarColor(0.13, 0.35, 0.80);
	E:RegisterStatusBar(TradeSkillRankFrame);

	TradeSkillRankFrameSkillRank:ClearAllPoints();
	TradeSkillRankFrameSkillRank:FontTemplate(nil, 12, "OUTLINE");
	TradeSkillRankFrameSkillRank:Point("CENTER", TradeSkillRankFrame, "CENTER", 0, 0);

	S:HandleEditBox(TradeSkillFrameSearchBox);

	S:HandleScrollBar(TradeSkillListScrollFrameScrollBar);
	S:HandleScrollBar(TradeSkillDetailScrollFrameScrollBar);

	TradeSkillSkillIcon:StyleButton(nil, true);
	TradeSkillSkillIcon:SetTemplate("Default");

	TradeSkillRequirementLabel:SetTextColor(1, 0.80, 0.10);

	for i = 1, MAX_TRADE_SKILL_REAGENTS do
		local reagent = _G["TradeSkillReagent" .. i];
		local icon = _G["TradeSkillReagent" .. i .. "IconTexture"];
		local count = _G["TradeSkillReagent" .. i .. "Count"];
		local name = _G["TradeSkillReagent" .. i .. "Name"];
		local nameFrame = _G["TradeSkillReagent" .. i .. "NameFrame"];

		reagent:SetTemplate("Transparent", true);
		reagent:StyleButton(nil, true);
		reagent:Size(reagent:GetWidth(), reagent:GetHeight() + 1);

		icon:SetTexCoord(unpack(E.TexCoords));
		icon:SetDrawLayer("OVERLAY");
		icon:Size(38);
		icon:Point("TOPLEFT", 2, -2);

		icon.backdrop = CreateFrame("Frame", nil, reagent);
		icon.backdrop:SetFrameLevel(reagent:GetFrameLevel() - 1);
		icon.backdrop:SetTemplate("Default");
		icon.backdrop:SetOutside(icon);

		icon:SetParent(icon.backdrop);
		count:SetParent(icon.backdrop);
		count:SetDrawLayer("OVERLAY");

		name:Point("LEFT", nameFrame, "LEFT", 20, 0)

		nameFrame:Kill();
	end

	TradeSkillReagent1:Point("TOPLEFT", TradeSkillReagentLabel, "BOTTOMLEFT", -2, -3);
	TradeSkillReagent2:Point("LEFT", TradeSkillReagent1, "RIGHT", 3, 0);
	TradeSkillReagent4:Point("LEFT", TradeSkillReagent3, "RIGHT", 3, 0);
	TradeSkillReagent6:Point("LEFT", TradeSkillReagent5, "RIGHT", 3, 0);
	TradeSkillReagent8:Point("LEFT", TradeSkillReagent7, "RIGHT", 3, 0);

	TradeSkillSkillIcon:StyleButton(nil, true);
	TradeSkillSkillIcon:SetTemplate();

	hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
		TradeSkillRankFrame:SetStatusBarColor(0.11, 0.50, 1.00);
		if(TradeSkillSkillIcon:GetNormalTexture()) then
			TradeSkillSkillIcon:SetAlpha(1);
			TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
			TradeSkillSkillIcon:GetNormalTexture():SetInside();
		else
			TradeSkillSkillIcon:SetAlpha(0);
		end

		local skillLink = GetTradeSkillItemLink(id)
		if(skillLink) then
			local quality = select(3, GetItemInfo(skillLink));
			if(quality and quality > 1) then
				TradeSkillSkillIcon:SetBackdropBorderColor(GetItemQualityColor(quality));
				TradeSkillSkillName:SetTextColor(GetItemQualityColor(quality));
			else
				TradeSkillSkillIcon:SetBackdropBorderColor(unpack(E["media"].bordercolor));
				TradeSkillSkillName:SetTextColor(1, 1, 1);
			end
		end

		local numReagents = GetTradeSkillNumReagents(id);
		for i = 1, numReagents, 1 do
			local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i);
			local reagentLink = GetTradeSkillReagentItemLink(id, i);
			local icon = _G["TradeSkillReagent" .. i .. "IconTexture"];
			local name = _G["TradeSkillReagent" .. i .. "Name"];

			if(reagentLink) then
				local quality = select(3, GetItemInfo(reagentLink));
				if(quality and quality > 1) then
					icon.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality));
					 if(playerReagentCount < reagentCount) then
						name:SetTextColor(0.5, 0.5, 0.5);
					else
						name:SetTextColor(GetItemQualityColor(quality));
					end
				else
					icon.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor));
 				end
			end
		end
	end);

	TradeSkillExpandButtonFrame:StripTextures();

	TradeSkillCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-PlusMinus-Buttons");
	TradeSkillCollapseAllButton.SetNormalTexture = E.noop;
	TradeSkillCollapseAllButton:GetNormalTexture():Point("LEFT", 3, 2);
	TradeSkillCollapseAllButton:GetNormalTexture():Size(12);

	TradeSkillCollapseAllButton:SetHighlightTexture("");
	TradeSkillCollapseAllButton.SetHighlightTexture = E.noop;

	TradeSkillCollapseAllButton:SetDisabledTexture("Interface\\Buttons\\UI-PlusMinus-Buttons");
	TradeSkillCollapseAllButton.SetDisabledTexture = E.noop;
	TradeSkillCollapseAllButton:GetDisabledTexture():Point("LEFT", 3, 2);
	TradeSkillCollapseAllButton:GetDisabledTexture():Size(12);
	TradeSkillCollapseAllButton:GetDisabledTexture():SetTexCoord(0, 0.4375, 0, 0.4375);
	TradeSkillCollapseAllButton:GetDisabledTexture():SetDesaturated(true);

	hooksecurefunc(TradeSkillCollapseAllButton, "SetNormalTexture", function(self, texture)
		if(find(texture, "MinusButton")) then
			self:GetNormalTexture():SetTexCoord(0.5625, 1, 0, 0.4375);
		else
			self:GetNormalTexture():SetTexCoord(0, 0.4375, 0, 0.4375);
		end
	end);

	for i = 1, TRADE_SKILLS_DISPLAYED do
		local skillButton = _G["TradeSkillSkill" .. i];
		local skillButtonHighlight = _G["TradeSkillSkill"..i.."Highlight"];

		skillButton:SetNormalTexture("Interface\\Buttons\\UI-PlusMinus-Buttons");
		skillButton.SetNormalTexture = E.noop;
		skillButton:GetNormalTexture():Size(11);
		skillButton:GetNormalTexture():Point("LEFT", 3, 1);

		skillButtonHighlight:SetTexture("");
		skillButtonHighlight.SetTexture = E.noop;

		hooksecurefunc(skillButton, "SetNormalTexture", function(self, texture)
			if(find(texture, "MinusButton")) then
				self:GetNormalTexture():SetTexCoord(0.5625, 1, 0, 0.4375);
			elseif(find(texture, "PlusButton")) then
				self:GetNormalTexture():SetTexCoord(0, 0.4375, 0, 0.4375);
			else
				self:GetNormalTexture():SetTexCoord(0, 0, 0, 0);
 			end
		end);
	end

	--Guild Crafters
	TradeSkillGuildFrame:StripTextures();
	TradeSkillGuildFrame:SetTemplate("Transparent");
	TradeSkillGuildFrame:Point("BOTTOMLEFT", TradeSkillFrame, "BOTTOMRIGHT", 3, 19);

	TradeSkillGuildFrameContainer:StripTextures();
	TradeSkillGuildFrameContainer:SetTemplate("Default");

	S:HandleButton(TradeSkillViewGuildCraftersButton)
	S:HandleCloseButton(TradeSkillGuildFrameCloseButton);
end

S:AddCallbackForAddon("Blizzard_TradeSkillUI", "TradeSkill", LoadSkin);