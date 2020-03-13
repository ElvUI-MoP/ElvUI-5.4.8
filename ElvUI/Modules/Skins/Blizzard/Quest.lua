local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack
local find = string.find

local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.quest ~= true then return end

	QuestLogFrame:StripTextures(true)
	QuestLogFrame:CreateBackdrop("Transparent")

	QuestLogFrameInset:Kill()

	QuestLogScrollFrame:StripTextures()

	QuestLogCount:StripTextures()
	QuestLogCount:SetTemplate("Transparent")

	for frame, numItems in pairs({["QuestInfoItem"] = MAX_NUM_ITEMS, ["QuestProgressItem"] = MAX_REQUIRED_ITEMS}) do
		for i = 1, numItems do
			local item = _G[frame..i]
			local icon = _G[frame..i.."IconTexture"]
			local count = _G[frame..i.."Count"]

			item:StripTextures()
			item:SetTemplate("Default")
			item:StyleButton()
			item:Size(143, 40)
			item:SetFrameLevel(item:GetFrameLevel() + 2)

			icon:Size(E.PixelMode and 38 or 32)
			icon:SetDrawLayer("OVERLAY")
			icon:Point("TOPLEFT", E.PixelMode and 1 or 4, -(E.PixelMode and 1 or 4))
			S:HandleIcon(icon)

			count:SetParent(item.backdrop)
			count:SetDrawLayer("OVERLAY")
		end
	end

	local questIcons = {
		"QuestInfoSkillPointFrame",
		"QuestInfoSpellObjectiveFrame",
		"QuestInfoRewardSpell",
		"QuestInfoTalentFrame"
	}

	for _, frame in pairs(questIcons) do
		local item = _G[frame]
		local icon = _G[frame.."IconTexture"]
		local name = _G[frame.."Name"]
		local nameFrame = _G[frame.."NameFrame"]
		local count = _G[frame.."Count"]
		local points = _G[frame.."Points"]

		item:StripTextures()
		item:SetTemplate("Default")
		item:StyleButton()
		item:Size(140, 40)
		item:SetFrameLevel(item:GetFrameLevel() + 2)

		icon:Size(E.PixelMode and 38 or 32)
		icon:Point("TOPLEFT", E.PixelMode and 1 or 4, -(E.PixelMode and 1 or 4))
		icon:SetDrawLayer("OVERLAY")
		S:HandleIcon(icon)

		name:Point("LEFT", nameFrame, "LEFT", 15, 0) 

		if count then
			count:SetParent(item.backdrop)
			count:SetDrawLayer("OVERLAY")
		end

		if points then
			points:SetParent(item.backdrop)
			points:Point("BOTTOMRIGHT", icon)
			points:FontTemplate(nil, 12, "OUTLINE")
			points:SetTextColor(1, 1, 1)
		end
	end

	QuestInfoRewardSpell:SetHitRectInsets(0, 1, 3, -2)
	QuestInfoSpellObjectiveFrame:SetHitRectInsets(0, 1, 3, -2)

	local function QuestQualityColors(frame, text, link, quality)
		if link and not quality then
			quality = select(3, GetItemInfo(link))
		end

		if frame and frame.objectType == "currency" then
			frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
			frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))

			text:SetTextColor(1, 1, 1)
		else
			if quality then
				frame:SetBackdropBorderColor(GetItemQualityColor(quality))
				frame.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))

				text:SetTextColor(GetItemQualityColor(quality))
			else
				frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
				frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))

				text:SetTextColor(1, 1, 1)
			end
		end
	end

	QuestInfoItemHighlight:StripTextures()

	hooksecurefunc("QuestInfoItem_OnClick", function(self)
		if self.type == "choice" then
			_G[self:GetName()]:SetBackdropBorderColor(1, 0.80, 0.10)
			_G[self:GetName()].backdrop:SetBackdropBorderColor(1, 0.80, 0.10)
			_G[self:GetName().."Name"]:SetTextColor(1, 0.80, 0.10)

			for i = 1, MAX_NUM_ITEMS do
				local item = _G["QuestInfoItem"..i]
				local name = _G["QuestInfoItem"..i.."Name"]
				local link = item.type and (QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

				if item ~= self then
					QuestQualityColors(item, name, link)
				end
			end
		end
	end)

	EmptyQuestLogFrame:StripTextures()

	S:HandleScrollBar(QuestDetailScrollFrameScrollBar)

	QuestLogFrameShowMapButton:StripTextures()
	S:HandleButton(QuestLogFrameShowMapButton)
	QuestLogFrameShowMapButton.text:ClearAllPoints()
	QuestLogFrameShowMapButton.text:Point("CENTER")
	QuestLogFrameShowMapButton:Size(QuestLogFrameShowMapButton:GetWidth() - 30, QuestLogFrameShowMapButton:GetHeight(), - 40)

	S:HandleButton(QuestLogFrameAbandonButton)
	QuestLogFrameAbandonButton:Point("LEFT", 1, 0)

	S:HandleButton(QuestLogFrameTrackButton)
	QuestLogFrameTrackButton:Point("RIGHT", 1, 0)

	S:HandleButton(QuestLogFrameCancelButton)
	QuestLogFrameCancelButton:Point("BOTTOMRIGHT", -9, 4)

	S:HandleButton(QuestLogFrameCompleteButton, true)
	QuestLogFrameCompleteButton:Point("TOPRIGHT", QuestLogFrameCancelButton, "TOPLEFT", -3, 0)
	QuestLogFrameCompleteButton:HookScript("OnUpdate", function(self) self:SetAlpha(QuestLogFrameCompleteButtonFlash:GetAlpha()) end)

	S:HandleButton(QuestLogFramePushQuestButton)
	QuestLogFramePushQuestButton:Point("LEFT", QuestLogFrameAbandonButton, "RIGHT", 2, 0)
	QuestLogFramePushQuestButton:Point("RIGHT", QuestLogFrameTrackButton, "LEFT", -2, 0)

	local function QuestObjectiveText()
		local numObjectives = GetNumQuestLeaderBoards()
		local objective
		local _, type, finished
		local numVisibleObjectives = 0
		for i = 1, numObjectives do
			_, type, finished = GetQuestLogLeaderBoard(i)
			if type ~= "spell" then
				numVisibleObjectives = numVisibleObjectives + 1
				objective = _G["QuestInfoObjective"..numVisibleObjectives]
				if finished  then
					objective:SetTextColor(1, 0.80, 0.10)
				else
					objective:SetTextColor(0.6, 0.6, 0.6)
				end
			end
		end
	end

	hooksecurefunc("QuestInfo_Display", function()
		local textColor = {1, 1, 1}
		local titleTextColor = {1, 0.80, 0.10}

		QuestInfoTitleHeader:SetTextColor(unpack(titleTextColor))
		QuestInfoDescriptionHeader:SetTextColor(unpack(titleTextColor))
		QuestInfoObjectivesHeader:SetTextColor(unpack(titleTextColor))
		QuestInfoRewardsHeader:SetTextColor(unpack(titleTextColor))

		QuestInfoDescriptionText:SetTextColor(unpack(textColor))
		QuestInfoObjectivesText:SetTextColor(unpack(textColor))
		QuestInfoGroupSize:SetTextColor(unpack(textColor))
		QuestInfoRewardText:SetTextColor(unpack(textColor))

		QuestInfoItemChooseText:SetTextColor(unpack(textColor))
		QuestInfoItemReceiveText:SetTextColor(unpack(textColor))
		QuestInfoSpellLearnText:SetTextColor(unpack(textColor))
		QuestInfoXPFrameReceiveText:SetTextColor(unpack(textColor))
		QuestInfoSpellObjectiveLearnLabel:SetTextColor(unpack(textColor))

		for i = 1, MAX_REPUTATIONS do
			_G["QuestInfoReputation"..i.."Faction"]:SetTextColor(unpack(textColor))
		end

		if GetQuestLogRequiredMoney() > 0 then
			if GetQuestLogRequiredMoney() > GetMoney() then
				QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end

		QuestObjectiveText()

		for i = 1, MAX_NUM_ITEMS do
			local item = _G["QuestInfoItem"..i]
			local name = _G["QuestInfoItem"..i.."Name"]
			local link = item.type and (QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			QuestQualityColors(item, name, link)
		end
	end)

	hooksecurefunc("QuestInfo_ShowRewards", function()
		for i = 1, MAX_NUM_ITEMS do
			local item = _G["QuestInfoItem"..i]
			local name = _G["QuestInfoItem"..i.."Name"]
			local link = item.type and (QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			QuestQualityColors(item, name, link)
		end
	end)

	hooksecurefunc("QuestInfo_ShowRequiredMoney", function()
		local requiredMoney = GetQuestLogRequiredMoney()
		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end
	end)

	QuestInfoTimerText:SetTextColor(1, 1, 1)
	QuestInfoAnchor:SetTextColor(1, 1, 1)

	QuestLogDetailFrame:StripTextures()
	QuestLogDetailFrame:SetTemplate("Transparent")

	QuestLogDetailScrollFrame:StripTextures()

	QuestLogFrame:HookScript("OnShow", function()
		local questFrame = QuestLogFrame:GetFrameLevel()
		local controlPanel = QuestLogControlPanel:GetFrameLevel()
		local scrollFrame = QuestLogDetailScrollFrame:GetFrameLevel()

		if questFrame >= controlPanel then
			QuestLogControlPanel:SetFrameLevel(questFrame + 1)
		end
		if questFrame >= scrollFrame then
			QuestLogDetailScrollFrame:SetFrameLevel(questFrame + 1)
		end

		if not QuestLogScrollFrame.backdrop then
			QuestLogScrollFrame:CreateBackdrop("Transparent")
		end
		QuestLogScrollFrame.backdrop:Point("TOPLEFT", 0, 1)
		QuestLogScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -2)
		QuestLogScrollFrame:Height(401)

		if not QuestLogDetailScrollFrame.backdrop then
			QuestLogDetailScrollFrame:CreateBackdrop("Transparent")
		end
		QuestLogDetailScrollFrame.backdrop:Point("TOPLEFT", 0, 1)
		QuestLogDetailScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -2)
		QuestLogDetailScrollFrame:Height(401)
		QuestLogDetailScrollFrame:Point("TOPRIGHT", -32, -64)

		QuestLogFrameShowMapButton:Point("TOPRIGHT", -31, -28)

		QuestLogDetailScrollFrameScrollBar:Point("TOPLEFT", QuestLogDetailScrollFrame, "TOPRIGHT", 6, -15)
	end)

	QuestLogDetailFrame:HookScript("OnShow", function()
		local questFrame = QuestLogFrame:GetFrameLevel()
		local controlPanel = QuestLogControlPanel:GetFrameLevel()
		local scrollFrame = QuestLogDetailScrollFrame:GetFrameLevel()

		if questFrame >= controlPanel then
			QuestLogControlPanel:SetFrameLevel(questFrame + 1)
		end
		if questFrame >= scrollFrame then
			QuestLogDetailScrollFrame:SetFrameLevel(questFrame + 1)
		end

		if not QuestLogDetailScrollFrame.backdrop then
			QuestLogDetailScrollFrame:CreateBackdrop("Transparent")
		end
		QuestLogDetailScrollFrame.backdrop:Point("TOPLEFT", 0, 1)
		QuestLogDetailScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -3)
		QuestLogDetailScrollFrame:Height(401)

		QuestLogFrameShowMapButton:Point("TOPRIGHT", -31, -28)

		QuestLogDetailScrollFrameScrollBar:Point("TOPLEFT", QuestLogDetailScrollFrame, "TOPRIGHT", 6, -15)
	end)

	S:HandleCloseButton(QuestLogDetailFrameCloseButton)
	QuestLogDetailFrameCloseButton:Point("TOPRIGHT", 2, 3)

	S:HandleCloseButton(QuestLogFrameCloseButton)
	QuestLogFrameCloseButton:Point("TOPRIGHT", 2, 3)

	S:HandleScrollBar(QuestLogDetailScrollFrameScrollBar)

	S:HandleScrollBar(QuestLogScrollFrameScrollBar)
	QuestLogScrollFrameScrollBar:Point("TOPLEFT", QuestLogScrollFrame, "TOPRIGHT", 3, -14)

	S:HandleScrollBar(QuestProgressScrollFrameScrollBar)
	S:HandleScrollBar(QuestRewardScrollFrameScrollBar)

	QuestLogSkillHighlight:StripTextures()

	QuestLogHighlightFrame:Width(306)
	QuestLogHighlightFrame.SetWidth = E.noop

	QuestLogHighlightFrame.Left = QuestLogHighlightFrame:CreateTexture(nil, "ARTWORK")
	QuestLogHighlightFrame.Left:Size(152, 15)
	QuestLogHighlightFrame.Left:SetPoint("LEFT", QuestLogHighlightFrame, "CENTER")
	QuestLogHighlightFrame.Left:SetTexture(E.media.blankTex)

	QuestLogHighlightFrame.Right = QuestLogHighlightFrame:CreateTexture(nil, "ARTWORK")
	QuestLogHighlightFrame.Right:Size(152, 15)
	QuestLogHighlightFrame.Right:SetPoint("RIGHT", QuestLogHighlightFrame, "CENTER")
	QuestLogHighlightFrame.Right:SetTexture(E.media.blankTex)

	hooksecurefunc(QuestLogSkillHighlight, "SetVertexColor", function(_, r, g, b)
		QuestLogHighlightFrame.Left:SetGradientAlpha("Horizontal", r, g, b, 0.35, r, g, b, 0)
		QuestLogHighlightFrame.Right:SetGradientAlpha("Horizontal", r, g, b, 0, r, g, b, 0.35)
	end)

	-- Quest Frame
	QuestFrame:StripTextures(true)
	QuestFrame:CreateBackdrop("Transparent")
	QuestLogFrame:StripTextures()
	QuestFrameInset:Kill()
	QuestFrameBg:Kill()
	QuestLogDetailFrameInset:Kill()
	QuestDetailScrollFrame:SetTemplate()

	QuestProgressScrollFrame:StripTextures()

	QuestFrameDetailPanel:StripTextures(true)
	QuestDetailScrollFrame:StripTextures(true)
	QuestDetailScrollChildFrame:StripTextures(true)
	QuestRewardScrollFrame:StripTextures(true)
	QuestRewardScrollChildFrame:StripTextures(true)
	QuestFrameProgressPanel:StripTextures(true)
	QuestFrameRewardPanel:StripTextures(true)

	S:HandleButton(QuestFrameAcceptButton, true)
	S:HandleButton(QuestFrameDeclineButton, true)
	S:HandleButton(QuestFrameCompleteButton, true)
	S:HandleButton(QuestFrameGoodbyeButton, true)
	S:HandleButton(QuestFrameCompleteQuestButton, true)

	S:HandleCloseButton(QuestFrameCloseButton, QuestFrame.backdrop)

	hooksecurefunc("QuestFrameProgressItems_Update", function()
		QuestProgressTitleText:SetTextColor(1, 0.80, 0.10)
		QuestProgressText:SetTextColor(1, 1, 1)
		QuestProgressRequiredItemsText:SetTextColor(1, 0.80, 0.10)

		if GetQuestMoneyToGet() > 0 then
			if GetQuestMoneyToGet() > GetMoney() then
				QuestProgressRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				QuestProgressRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end

		for i = 1, MAX_REQUIRED_ITEMS do
			local item = _G["QuestProgressItem"..i]
			local name = _G["QuestProgressItem"..i.."Name"]
			local link = item.type and GetQuestItemLink(item.type, item:GetID())

			QuestQualityColors(item, name, link)
		end
	end)

	QuestNPCModel:StripTextures()
	QuestNPCModel:CreateBackdrop("Transparent")
	QuestNPCModel.backdrop:Point("BOTTOMRIGHT", 2, -2)
	QuestNPCModel:Point("TOPLEFT", QuestLogDetailFrame, "TOPRIGHT", 4, -34)

	QuestNPCModelTextFrame:StripTextures()
	QuestNPCModelTextFrame:CreateBackdrop("Default")
	QuestNPCModelTextFrame.backdrop:Point("TOPLEFT", E.PixelMode and -1 or -2, 16)
	QuestNPCModelTextFrame.backdrop:Point("BOTTOMRIGHT", 2, -2)

	QuestNPCModelNameText:Point("TOPLEFT", QuestNPCModelNameplate, 22, -20)

	hooksecurefunc("QuestFrame_ShowQuestPortrait", function(parentFrame, _, _, _, x, y)
		QuestNPCModel:ClearAllPoints()
		QuestNPCModel:Point("TOPLEFT", parentFrame, "TOPRIGHT", x + 18, y)
	end)

	S:HandleNextPrevButton(QuestNPCModelTextScrollFrameScrollBarScrollUpButton)
	SquareButton_SetIcon(QuestNPCModelTextScrollFrameScrollBarScrollUpButton, "UP")
	QuestNPCModelTextScrollFrameScrollBarScrollUpButton:Size(18, 16)

	S:HandleNextPrevButton(QuestNPCModelTextScrollFrameScrollBarScrollDownButton)
	SquareButton_SetIcon(QuestNPCModelTextScrollFrameScrollBarScrollDownButton, "DOWN")
	QuestNPCModelTextScrollFrameScrollBarScrollDownButton:Size(18, 16)

	for i = 1, #QuestLogScrollFrame.buttons do
		local questLogTitle = _G["QuestLogScrollFrameButton"..i]
		questLogTitle:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusMinusButton")
		questLogTitle.SetNormalTexture = E.noop
		questLogTitle:GetNormalTexture():Size(14)
		questLogTitle:GetNormalTexture():Point("LEFT", 5, 0)
		questLogTitle:SetHighlightTexture("")
		questLogTitle.SetHighlightTexture = E.noop

		hooksecurefunc(questLogTitle, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self:GetNormalTexture():SetTexCoord(0.540, 0.965, 0.085, 0.920)
			elseif find(texture, "PlusButton") then
				self:GetNormalTexture():SetTexCoord(0.040, 0.465, 0.085, 0.920)
			else
				self:GetNormalTexture():SetTexCoord(0, 0, 0, 0)
 			end
		end)
	end
end

S:AddCallback("Quest", LoadSkin)