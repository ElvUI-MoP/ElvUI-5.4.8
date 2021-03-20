local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, pairs, select = unpack, pairs, select
local find, gsub = string.find, string.gsub

local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.quest then return end

	QuestLogFrame:StripTextures()
	QuestLogFrame:SetTemplate("Transparent")
	QuestLogFrameInset:Kill()

	EmptyQuestLogFrame:StripTextures()

	QuestLogCount:StripTextures()
	QuestLogCount:SetTemplate("Transparent")

	QuestLogScrollFrame:StripTextures()
	QuestLogScrollFrame:CreateBackdrop("Transparent")
	QuestLogScrollFrame.backdrop:Point("TOPLEFT", 0, 1)
	QuestLogScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -2)
	QuestLogScrollFrame:Point("TOPLEFT", 6, -62)
	QuestLogScrollFrame:Height(401)

	S:HandleScrollBar(QuestLogScrollFrameScrollBar)
	QuestLogScrollFrameScrollBar:ClearAllPoints()
	QuestLogScrollFrameScrollBar:Point("TOPRIGHT", QuestLogScrollFrame, 23, -15)
	QuestLogScrollFrameScrollBar:Point("BOTTOMRIGHT", QuestLogScrollFrame, 0, 14)

	QuestLogSkillHighlight:SetTexture(E.Media.Textures.Highlight)
	QuestLogSkillHighlight:SetAlpha(0.35)

	for i = 1, #QuestLogScrollFrame.buttons do
		local questLogTitle = _G["QuestLogScrollFrameButton"..i]
		questLogTitle:SetNormalTexture(E.Media.Textures.Plus)
		questLogTitle.SetNormalTexture = E.noop

		local normal = questLogTitle:GetNormalTexture()
		normal:Size(16)
		normal:Point("LEFT", 3, 1)

		questLogTitle:SetHighlightTexture("")
		questLogTitle.SetHighlightTexture = E.noop

		hooksecurefunc(questLogTitle, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				normal:SetTexture(E.Media.Textures.Minus)
			elseif find(texture, "PlusButton") then
				normal:SetTexture(E.Media.Textures.Plus)
			else
				normal:SetTexture("")
			end
		end)
	end

	S:HandleCloseButton(QuestLogFrameCloseButton)
	QuestLogFrameCloseButton:Point("TOPRIGHT", 2, 3)

	QuestLogDetailFrame:StripTextures()
	QuestLogDetailFrame:SetTemplate("Transparent")
	QuestLogDetailFrameInset:Kill()

	QuestLogDetailScrollFrame:StripTextures()
	QuestLogDetailScrollFrame:CreateBackdrop("Transparent")
	QuestLogDetailScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -2)
	QuestLogDetailScrollFrame:Height(401)

	S:HandleScrollBar(QuestLogDetailScrollFrameScrollBar)
	QuestLogDetailScrollFrameScrollBar:ClearAllPoints()
	QuestLogDetailScrollFrameScrollBar:Point("TOPRIGHT", QuestLogDetailScrollFrame, 22, -17)
	QuestLogDetailScrollFrameScrollBar:Point("BOTTOMRIGHT", QuestLogDetailScrollFrame, 0, 16)
	QuestLogDetailScrollFrameScrollBar.SetPoint = E.noop

	S:HandleCloseButton(QuestLogDetailFrameCloseButton)
	QuestLogDetailFrameCloseButton:Point("TOPRIGHT", 2, 3)

	S:HandleButton(QuestLogFrameShowMapButton, true)
	QuestLogFrameShowMapButton:Size(84, 32)
	QuestLogFrameShowMapButton.text:ClearAllPoints()
	QuestLogFrameShowMapButton.text:Point("CENTER")

	S:HandleButton(QuestLogFrameAbandonButton)
	QuestLogFrameAbandonButton:Size(100, 22)
	QuestLogFrameAbandonButton:Point("LEFT", 2, 2)

	S:HandleButton(QuestLogFrameTrackButton)
	QuestLogFrameTrackButton:Size(100, 22)

	S:HandleButton(QuestLogFramePushQuestButton)
	QuestLogFramePushQuestButton:Height(22)
	QuestLogFramePushQuestButton:Point("LEFT", QuestLogFrameAbandonButton, "RIGHT", E.PixelMode and 2 or 3, 0)
	QuestLogFramePushQuestButton:Point("RIGHT", QuestLogFrameTrackButton, "LEFT", E.PixelMode and -2 or -3, 0)

	S:HandleButton(QuestLogFrameCancelButton)
	QuestLogFrameCancelButton:Point("BOTTOMRIGHT", -29, 5)

	S:HandleButton(QuestLogFrameCompleteButton, true)
	QuestLogFrameCompleteButton:Point("TOPRIGHT", QuestLogFrameCancelButton, "TOPLEFT", E.PixelMode and -2 or -3, 0)
	QuestLogFrameCompleteButton:HookScript("OnUpdate", function(self)
		self:SetAlpha(QuestLogFrameCompleteButtonFlash:GetAlpha())
	end)

	QuestLogFrame:HookScript("OnShow", function()
		local questFrame = QuestLogFrame:GetFrameLevel()
		if questFrame >= QuestLogControlPanel:GetFrameLevel() then
			QuestLogControlPanel:SetFrameLevel(questFrame + 1)
		end
		if questFrame >= QuestLogDetailScrollFrame:GetFrameLevel() then
			QuestLogDetailScrollFrame:SetFrameLevel(questFrame + 1)
		end

		QuestLogDetailScrollFrame:Point("TOPRIGHT", -29, -62)
		QuestLogDetailScrollFrame.backdrop:Point("TOPLEFT", -3, 1)

		QuestLogFrameShowMapButton:Point("TOPRIGHT", -29, -24)
		QuestLogFrameTrackButton:Point("RIGHT", 0, 2)
	end)

	QuestLogDetailFrame:HookScript("OnShow", function()
		local questFrame = QuestLogFrame:GetFrameLevel()
		if questFrame >= QuestLogControlPanel:GetFrameLevel() then
			QuestLogControlPanel:SetFrameLevel(questFrame + 1)
		end
		if questFrame >= QuestLogDetailScrollFrame:GetFrameLevel() then
			QuestLogDetailScrollFrame:SetFrameLevel(questFrame + 1)
		end

		QuestLogDetailScrollFrame:Point("TOPLEFT", 11, -62)
		QuestLogDetailScrollFrame.backdrop:Point("TOPLEFT", -5, 1)

		QuestLogFrameShowMapButton:Point("TOPRIGHT", -29, -24)
		QuestLogFrameTrackButton:Point("RIGHT", -22, 2)
	end)

	-- Quest NPC Model
	QuestNPCModel:StripTextures()
	QuestNPCModel:CreateBackdrop("Transparent")
	QuestNPCModel.backdrop:Point("BOTTOMRIGHT", 2, -2)
	QuestNPCModel:Point("TOPLEFT", QuestLogDetailFrame, "TOPRIGHT", 4, -34)

	QuestNPCModelTextFrame:StripTextures()
	QuestNPCModelTextFrame:CreateBackdrop()
	QuestNPCModelTextFrame.backdrop:Point("TOPLEFT", E.PixelMode and -1 or -2, 16)
	QuestNPCModelTextFrame.backdrop:Point("BOTTOMRIGHT", 2, -2)

	QuestNPCModelNameText:Point("TOPLEFT", QuestNPCModelNameplate, 22, -20)

	hooksecurefunc("QuestFrame_ShowQuestPortrait", function(parentFrame, _, _, _, x, y)
		QuestNPCModel:ClearAllPoints()
		QuestNPCModel:Point("TOPLEFT", parentFrame, "TOPRIGHT", x + 18, y)
	end)

	S:HandleNextPrevButton(QuestNPCModelTextScrollFrameScrollBarScrollUpButton)
	QuestNPCModelTextScrollFrameScrollBarScrollUpButton:Size(18, 16)

	S:HandleNextPrevButton(QuestNPCModelTextScrollFrameScrollBarScrollDownButton)
	QuestNPCModelTextScrollFrameScrollBarScrollDownButton:Size(18, 16)

	-- Quest Info
	QuestInfoTimerText:SetTextColor(1, 1, 1)
	QuestInfoAnchor:SetTextColor(1, 1, 1)

	for frame, numItems in pairs({["QuestInfoItem"] = MAX_NUM_ITEMS, ["QuestProgressItem"] = MAX_REQUIRED_ITEMS}) do
		for i = 1, numItems do
			local item = _G[frame..i]
			local icon = _G[frame..i.."IconTexture"]
			local count = _G[frame..i.."Count"]

			item:StripTextures()
			item:SetTemplate()
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

	for _, frame in pairs({"QuestInfoSkillPointFrame", "QuestInfoSpellObjectiveFrame", "QuestInfoRewardSpell", "QuestInfoTalentFrame"}) do
		local item = _G[frame]
		local icon = _G[frame.."IconTexture"]
		local count = _G[frame.."Count"]
		local points = _G[frame.."Points"]

		item:StripTextures()
		item:SetTemplate()
		item:StyleButton()
		item:Size(140, 40)
		item:SetFrameLevel(item:GetFrameLevel() + 2)

		icon:Size(E.PixelMode and 38 or 32)
		icon:Point("TOPLEFT", E.PixelMode and 1 or 4, -(E.PixelMode and 1 or 4))
		icon:SetDrawLayer("OVERLAY")
		S:HandleIcon(icon)

		_G[frame.."Name"]:Point("LEFT", _G[frame.."NameFrame"], "LEFT", 15, 0)

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

	QuestInfoPlayerTitleFrame:SetTemplate()
	QuestInfoPlayerTitleFrame:Size(285, 40)

	QuestInfoPlayerTitleFrameIconTexture:Size(E.PixelMode and 38 or 32)
	QuestInfoPlayerTitleFrameIconTexture:Point("TOPLEFT", E.PixelMode and 1 or 4, -(E.PixelMode and 1 or 4))
	QuestInfoPlayerTitleFrameIconTexture:SetDrawLayer("OVERLAY")
	S:HandleIcon(QuestInfoPlayerTitleFrameIconTexture)

	QuestInfoRewardSpell:SetHitRectInsets(0, 1, 3, -2)
	QuestInfoSpellObjectiveFrame:SetHitRectInsets(0, 1, 3, -2)

	local function QuestQualityColors(frame, text, link)
		local quality
		if link then
			quality = select(3, GetItemInfo(link))
		end

		if frame and frame.objectType == "currency" then
			frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
			frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))

			text:SetTextColor(1, 1, 1)
		else
			if quality then
				local r, g, b = GetItemQualityColor(quality)
				frame:SetBackdropBorderColor(r, g, b)
				frame.backdrop:SetBackdropBorderColor(r, g, b)

				text:SetTextColor(r, g, b)
			else
				frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
				frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))

				text:SetTextColor(1, 1, 1)
			end
		end
	end

	QuestInfoItemHighlight:StripTextures()

	hooksecurefunc("QuestInfoItem_OnClick", function(self)
		if self.type and self.type == "choice" then
			self:SetBackdropBorderColor(1, 0.80, 0.10)
			self.backdrop:SetBackdropBorderColor(1, 0.80, 0.10)
			_G[self:GetName().."Name"]:SetTextColor(1, 0.80, 0.10)

			for i = 1, MAX_NUM_ITEMS do
				local item = _G["QuestInfoItem"..i]
				local name = _G["QuestInfoItem"..i.."Name"]
				local link = item.type and GetQuestItemLink(item.type, item:GetID())

				if item ~= self then
					QuestQualityColors(item, name, link)
				end
			end
		end
	end)

	local function QuestObjectiveText()
		local numVisibleObjectives = 0
		for i = 1, GetNumQuestLeaderBoards() do
			local _, questType, finished = GetQuestLogLeaderBoard(i)

			if questType ~= "spell" then
				numVisibleObjectives = numVisibleObjectives + 1
				local objective = _G["QuestInfoObjective"..numVisibleObjectives]

				if finished then
					objective:SetTextColor(1, 0.80, 0.10)
				else
					objective:SetTextColor(0.6, 0.6, 0.6)
				end
			end
		end
	end

	hooksecurefunc("QuestInfo_Display", function()
		local textColor = {1, 1, 1}
		local greyColor = {0.6, 0.6, 0.6}
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

		local requiredMoney = GetQuestLogRequiredMoney()
		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				QuestInfoRequiredMoneyText:SetTextColor(unpack(greyColor))
			else
				QuestInfoRequiredMoneyText:SetTextColor(unpack(titleTextColor))
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

	-- Quest Frames
	QuestFrame:StripTextures(true)
	QuestFrame:SetTemplate("Transparent")

	QuestFrameInset:Kill()

	QuestFrameNpcNameText:ClearAllPoints()
	QuestFrameNpcNameText:Point("TOP", QuestFrame, 1, -1)

	S:HandleCloseButton(QuestFrameCloseButton, QuestFrame.backdrop)

	for _, frame in pairs({"Greeting", "Detail", "Progress", "Reward"}) do
		_G["QuestFrame"..frame.."Panel"]:StripTextures(true)

		local scrollFrame = _G["Quest"..frame.."ScrollFrame"]
		scrollFrame:StripTextures(true)
		scrollFrame:CreateBackdrop("Transparent")
		scrollFrame.backdrop:Point("TOPLEFT", 0, 1)
		scrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -2)
		scrollFrame:Point("TOPLEFT", 6, -60)

		local scrollBar = _G["Quest"..frame.."ScrollFrameScrollBar"]
		S:HandleScrollBar(scrollBar)
		scrollBar:ClearAllPoints()
		scrollBar:Point("TOPRIGHT", scrollFrame, 23, -17)
		scrollBar:Point("BOTTOMRIGHT", scrollFrame, 0, 16)
	end

	-- Quest Greeting Frame
	QuestGreetingFrameHorizontalBreak:Kill()

	S:HandleButton(QuestFrameGreetingGoodbyeButton)
	QuestFrameGreetingGoodbyeButton:Point("BOTTOMRIGHT", -78, 21)

	GreetingText:SetTextColor(1, 1, 1)
	GreetingText.SetTextColor = E.noop

	CurrentQuestsText:SetTextColor(1, 0.80, 0.10)
	CurrentQuestsText.SetTextColor = E.noop

	AvailableQuestsText:SetTextColor(1, 0.80, 0.10)
	AvailableQuestsText.SetTextColor = E.noop

	for i = 1, MAX_NUM_QUESTS do
		S:HandleButtonHighlight(_G["QuestTitleButton"..i])
	end

	QuestFrameGreetingPanel:HookScript("OnEvent", function(frame)
		if not frame:IsShown() then return end

		for i = 1, MAX_NUM_QUESTS do
			local button = _G["QuestTitleButton"..i]

			if button:GetFontString() then
				local text = button:GetText()

				if text and find(text, "|cff000000") then
					button:SetText(gsub(text, "|cff000000", "|cffFFFF00"))
				end
			end
		end
	end)
	QuestFrameGreetingPanel:RegisterEvent("QUEST_GREETING")
	QuestFrameGreetingPanel:RegisterEvent("QUEST_LOG_UPDATE")

	-- Quest Detail Frame
	S:HandleButton(QuestFrameAcceptButton)
	QuestFrameAcceptButton:Point("BOTTOMLEFT", 6, 5)

	S:HandleButton(QuestFrameDeclineButton)
	QuestFrameDeclineButton:Point("BOTTOMRIGHT", -32, 5)

	-- Quest Progress Frame
	S:HandleButton(QuestFrameCompleteButton)
	QuestFrameCompleteButton:Point("BOTTOMLEFT", 6, 21)

	S:HandleButton(QuestFrameGoodbyeButton)
	QuestFrameGoodbyeButton:Point("BOTTOMRIGHT", -78, 21)

	hooksecurefunc("QuestFrameProgressItems_Update", function()
		QuestProgressTitleText:SetTextColor(1, 0.80, 0.10)
		QuestProgressText:SetTextColor(1, 1, 1)
		QuestProgressRequiredItemsText:SetTextColor(1, 0.80, 0.10)

		local moneyToGet = GetQuestMoneyToGet()
		if moneyToGet > 0 then
			if moneyToGet > GetMoney() then
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

	-- Quest Reward Frame
	S:HandleButton(QuestFrameCompleteQuestButton)
	QuestFrameCompleteQuestButton:Point("BOTTOMLEFT", 6, 21)
end

S:AddCallback("Quest", LoadSkin)