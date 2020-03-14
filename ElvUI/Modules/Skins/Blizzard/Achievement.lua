local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local ipairs, select, unpack = ipairs, select, unpack

local GetAchievementCriteriaInfo = GetAchievementCriteriaInfo
local GetAchievementNumCriteria = GetAchievementNumCriteria
local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded

local function LoadSkin(preSkin)
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.achievement then return end

	local function SkinAchievement(Achievement, BiggerIcon)
		if not Achievement.isSkinned then
			Achievement:StripTextures(true)
			Achievement:SetTemplate("Default", true)

			Achievement.icon:SetTemplate()
			Achievement.icon:SetSize(BiggerIcon and 54 or 36, BiggerIcon and 54 or 36)
			Achievement.icon:ClearAllPoints()
			Achievement.icon:Point("TOPLEFT", 8, -6)
			Achievement.icon.bling:Kill()
			Achievement.icon.frame:Kill()
			Achievement.icon.texture:SetTexCoord(unpack(E.TexCoords))
			Achievement.icon.texture:SetInside()

			if Achievement.highlight then
				Achievement.highlight:StripTextures()

				Achievement:HookScript("OnEnter", S.SetModifiedBackdrop)
				Achievement:HookScript("OnLeave", function(self)
					if self.player and self.player.accountWide or self.accountWide then
						self:SetBackdropBorderColor(0.129, 0.671, 0.875)
					else
						self:SetBackdropBorderColor(unpack(E.media.bordercolor))
					end
				end)
			end

			if Achievement.label then
				Achievement.label:SetTextColor(1, 1, 1)
			end

			if Achievement.description then
				Achievement.description:SetTextColor(0.6, 0.6, 0.6)

				hooksecurefunc(Achievement.description, "SetTextColor", function(self)
					if self._blocked then return end

					self._blocked = true
					self:SetTextColor(0.6, 0.6, 0.6)
					self._blocked = nil
				end)
			end

			if Achievement.hiddenDescription then
				Achievement.hiddenDescription:SetTextColor(1, 1, 1)
			end

			if Achievement.tracked then
				S:HandleCheckBox(Achievement.tracked, true)
				Achievement.tracked:Size(14)
				Achievement.tracked:ClearAllPoints()
				Achievement.tracked:Point("TOPLEFT", Achievement.icon, "BOTTOMLEFT", 0, -4)
			end

			local trackedText = _G[Achievement:GetName().."TrackedText"]
			if trackedText then
				trackedText:SetTextColor(1, 1, 1)
				trackedText:Point("TOPLEFT", 18, -2)
			end

			hooksecurefunc(Achievement, "Saturate", function(self)
				self:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end)
			hooksecurefunc(Achievement, "Desaturate", function(self)
				self:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end)

			Achievement.isSkinned = true
		end
	end

	if preSkin then
		hooksecurefunc("HybridScrollFrame_CreateButtons", function(frame, template)
			if template == "AchievementCategoryTemplate" then
				for _, button in ipairs(frame.buttons) do
					if not button.isSkinned then
						button:StripTextures()

						local highlight = button:GetHighlightTexture()
						highlight:SetTexture(E.Media.Textures.Highlight)
						highlight:SetTexCoord(0, 1, 0, 1)
						highlight:SetAlpha(0.35)
						highlight:SetInside()

						button.isSkinned = true
					end
				end
			elseif template == "AchievementTemplate" then
				for _, achievement in ipairs(frame.buttons) do
					SkinAchievement(achievement, true)
				end
			elseif template == "ComparisonTemplate" then
				for _, achievement in ipairs(frame.buttons) do

					SkinAchievement(achievement.player)
					SkinAchievement(achievement.friend)

					hooksecurefunc(achievement.player, "Saturate", function()
						if achievement.player.accountWide then
							achievement.player:SetBackdropBorderColor(0.129, 0.671, 0.875)
							achievement.friend:SetBackdropBorderColor(0.129, 0.671, 0.875)
						else
							achievement.player:SetBackdropBorderColor(unpack(E.media.bordercolor))
							achievement.friend:SetBackdropBorderColor(unpack(E.media.bordercolor))
						end
					end)
				end
			elseif template == "StatTemplate" then
				for _, stats in ipairs(frame.buttons) do
					if not stats.isSkinned then
						stats:StyleButton()

						stats.isSkinned = true
					end
				end
			end
		end)

		if not IsAddOnLoaded("Blizzard_AchievementUI") then return end
	end

	local frames = {
		"AchievementFrame",
		"AchievementFrameCategories",
		"AchievementFrameSummary",
		"AchievementFrameHeader",
		"AchievementFrameSummaryCategoriesHeader",
		"AchievementFrameSummaryAchievementsHeader",
		"AchievementFrameStatsBG",
		"AchievementFrameAchievements",
		"AchievementFrameComparison",
		"AchievementFrameComparisonHeader",
		"AchievementFrameComparisonSummaryPlayer",
		"AchievementFrameComparisonSummaryFriend"
	}

	for _, frame in ipairs(frames) do
		_G[frame]:StripTextures(true)
	end

	local nonameFrames = {
		"AchievementFrameStats",
		"AchievementFrameSummary",
		"AchievementFrameAchievements",
		"AchievementFrameComparison"
	}

	for _, frame in ipairs(nonameFrames) do
		frame = _G[frame]
		for i = 1, frame:GetNumChildren() do
			local child = select(i, frame:GetChildren())
			if child and not child:GetName() then
				child:SetBackdrop(nil)
			end
		end
	end

	AchievementFrame:CreateBackdrop("Transparent")
	AchievementFrame.backdrop:Point("TOPLEFT", 0, 6)
	AchievementFrame.backdrop:Point("BOTTOMRIGHT", -15, 0)

	AchievementFrameHeaderTitle:ClearAllPoints()
	AchievementFrameHeaderTitle:Point("TOPLEFT", AchievementFrame.backdrop, "TOPLEFT", -30, -8)

	AchievementFrameHeaderPoints:ClearAllPoints()
	AchievementFrameHeaderPoints:Point("LEFT", AchievementFrameHeaderTitle, "RIGHT", 2, 0)

	AchievementFrameSummaryAchievementsEmptyText:Point("TOP", AchievementFrameSummaryAchievements, "TOP", 0, 20)

	S:HandleDropDownBox(AchievementFrameFilterDropDown, 200)
	AchievementFrameFilterDropDown:Point("TOPRIGHT", AchievementFrame, "TOPRIGHT", -38, 8)

	S:HandleCloseButton(AchievementFrameCloseButton, AchievementFrame.backdrop)

	AchievementFrameCategoriesContainer:CreateBackdrop("Transparent")
	AchievementFrameCategoriesContainer.backdrop:Point("TOPLEFT", 0, 3)
	AchievementFrameCategoriesContainer.backdrop:Point("BOTTOMRIGHT", -2, -2)

	AchievementFrameAchievementsContainer:CreateBackdrop("Transparent")
	AchievementFrameAchievementsContainer.backdrop:Point("TOPLEFT", -2, 1)
	AchievementFrameAchievementsContainer.backdrop:Point("BOTTOMRIGHT", -4, -2)

	AchievementFrameComparisonContainer:CreateBackdrop("Transparent")
	AchievementFrameComparisonContainer.backdrop:Point("TOPLEFT", -2, 2)
	AchievementFrameComparisonContainer.backdrop:Point("BOTTOMRIGHT", -3, -2)

	AchievementFrameComparisonStatsContainer:CreateBackdrop("Transparent")
	AchievementFrameComparisonStatsContainer.backdrop:Point("TOPLEFT", -1, 1)
	AchievementFrameComparisonStatsContainer.backdrop:Point("BOTTOMRIGHT", -7, -2)

	S:HandleScrollBar(AchievementFrameComparisonContainerScrollBar)
	AchievementFrameComparisonContainerScrollBar:ClearAllPoints()
	AchievementFrameComparisonContainerScrollBar:Point("TOPLEFT", AchievementFrameComparisonSummary, "TOPRIGHT", 7, -63)
	AchievementFrameComparisonContainerScrollBar:Point("BOTTOMLEFT", AchievementFrameComparisonSummary, "BOTTOMRIGHT", 0, -389)

	S:HandleScrollBar(AchievementFrameComparisonStatsContainerScrollBar)
	AchievementFrameComparisonStatsContainerScrollBar:ClearAllPoints()
	AchievementFrameComparisonStatsContainerScrollBar:Point("TOPLEFT", AchievementFrameComparisonStatsContainer, "TOPRIGHT", 1, -15)
	AchievementFrameComparisonStatsContainerScrollBar:Point("BOTTOMLEFT", AchievementFrameComparisonStatsContainer, "BOTTOMRIGHT", 0, 14)

	S:HandleScrollBar(AchievementFrameCategoriesContainerScrollBar)
	AchievementFrameCategoriesContainerScrollBar:ClearAllPoints()
	AchievementFrameCategoriesContainerScrollBar:Point("TOPLEFT", AchievementFrameCategoriesContainer, "TOPRIGHT", 1, -13)
	AchievementFrameCategoriesContainerScrollBar:Point("BOTTOMLEFT", AchievementFrameCategoriesContainer, "BOTTOMRIGHT", 0, 14)

	S:HandleScrollBar(AchievementFrameAchievementsContainerScrollBar)
	AchievementFrameAchievementsContainerScrollBar:ClearAllPoints()
	AchievementFrameAchievementsContainerScrollBar:Point("TOPLEFT", AchievementFrameAchievementsContainer, "TOPRIGHT", 0, -15)
	AchievementFrameAchievementsContainerScrollBar:Point("BOTTOMLEFT", AchievementFrameAchievementsContainer, "BOTTOMRIGHT", 0, 14)

	S:HandleScrollBar(AchievementFrameStatsContainerScrollBar)
	AchievementFrameStatsContainerScrollBar:ClearAllPoints()
	AchievementFrameStatsContainerScrollBar:Point("TOPLEFT", AchievementFrameStatsContainer, "TOPRIGHT", 0, -15)
	AchievementFrameStatsContainerScrollBar:Point("BOTTOMLEFT", AchievementFrameStatsContainer, "BOTTOMRIGHT", 0, 14)

	for i = 1, 3 do
		S:HandleTab(_G["AchievementFrameTab"..i])
	end

	local function SkinStatusBar(bar)
		bar:StripTextures()
		bar:CreateBackdrop("Transparent")
		bar:SetStatusBarTexture(E.media.normTex)
		bar:SetStatusBarColor(0.22, 0.39, 0.84)
		E:RegisterStatusBar(bar)

		local barName = bar:GetName()
		local title = _G[barName.."Title"]
		local label = _G[barName.."Label"]
		local text = _G[barName.."Text"]

		if title then
			title:Point("LEFT", 4, 0)
			title:FontTemplate()
		end

		if label then
			label:Point("LEFT", 4, 0)
			label:FontTemplate()
		end
		if text then
			text:Point("RIGHT", -4, 0)
			text:FontTemplate()
		end
	end

	SkinStatusBar(AchievementFrameSummaryCategoriesStatusBar)

	SkinStatusBar(AchievementFrameComparisonSummaryPlayerStatusBar)
	AchievementFrameComparisonSummaryPlayerStatusBar:Point("TOPLEFT", -1, -17)

	SkinStatusBar(AchievementFrameComparisonSummaryFriendStatusBar)
	AchievementFrameComparisonSummaryFriendStatusBar:Point("TOP", -13, -17)

	AchievementFrameComparisonSummaryFriendStatusBar.text:ClearAllPoints()
	AchievementFrameComparisonSummaryFriendStatusBar.text:Point("CENTER")
	AchievementFrameComparisonHeader:Point("BOTTOMRIGHT", AchievementFrameComparison, "TOPRIGHT", 45, -10)

	AchievementFrameSummaryCategoriesHeader:Point("TOPLEFT", 0, -12)

	for i = 1, 10 do
		local frame = _G["AchievementFrameSummaryCategoriesCategory"..i]
		local button = _G["AchievementFrameSummaryCategoriesCategory"..i.."Button"]
		local highlight = _G["AchievementFrameSummaryCategoriesCategory"..i.."ButtonHighlight"]
		local middle = _G["AchievementFrameSummaryCategoriesCategory"..i.."ButtonHighlightMiddle"]

		SkinStatusBar(frame)
		button:StripTextures()
		highlight:StripTextures()

		middle:SetTexture(1, 1, 1, 0.3)
		middle:SetAllPoints(frame)
	end

	hooksecurefunc("AchievementButton_DisplayAchievement", function(frame)
		if frame.accountWide then
			frame:SetBackdropBorderColor(0.129, 0.671, 0.875)
		else
			frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	hooksecurefunc("AchievementFrameSummary_UpdateAchievements", function()
		local frame, prevFrame

		for i = 1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
			frame = _G["AchievementFrameSummaryAchievement"..i]

			SkinAchievement(frame)

			if frame.shield.points and not frame.shield.points.isSkinned then
				frame.shield.points:ClearAllPoints()
				frame.shield.points:Point("CENTER", 0, 2)

				frame.shield.points.isSkinned = true
			end

			if i ~= 1 then
				prevFrame = _G["AchievementFrameSummaryAchievement"..(i - 1)]
				frame:ClearAllPoints()
				frame:Point("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, -1)
				frame:Point("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, 1)
			end

			if frame.accountWide then
				frame:SetBackdropBorderColor(0.129, 0.671, 0.875)
			else
				frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	AchievementFrameStatsContainer:CreateBackdrop("Transparent")
	AchievementFrameStatsContainer.backdrop:Point("TOPLEFT", -1, 1)
	AchievementFrameStatsContainer.backdrop:Point("BOTTOMRIGHT", -6, -2)

	for _, frame in pairs({"AchievementFrameStatsContainerButton", "AchievementFrameComparisonStatsContainerButton"}) do
		for i = 1, 20 do
			local button = _G[frame..i]
			local buttonBG = _G[frame..i.."BG"]

			button:StripTextures()

			button:SetHighlightTexture(E.Media.Textures.Highlight)
			button:GetHighlightTexture():SetAlpha(0.35)
			button:GetHighlightTexture():SetInside()

			buttonBG:SetTexture(0, 0, 0, 0.6)
			buttonBG:Point("TOPLEFT", 1, 0)
			buttonBG:Point("BOTTOMRIGHT", -1, 0)

			_G[frame..i.."HeaderLeft"]:Kill()
			_G[frame..i.."HeaderRight"]:Kill()
			_G[frame..i.."HeaderMiddle"]:Kill()
		end
	end

	hooksecurefunc("AchievementButton_GetProgressBar", function(index)
		local Bar = _G["AchievementFrameProgressBar"..index]

		if Bar and not Bar.isSkinned then
			local BarBG = _G["AchievementFrameProgressBar"..index.."BG"]

			Bar:StripTextures()
			Bar:CreateBackdrop("Transparent")
			Bar.backdrop:SetBackdropColor(0, 0, 0, 0)
			Bar:Height(Bar:GetHeight() + 2)
			Bar:SetStatusBarTexture(E.media.normTex)
			Bar:SetStatusBarColor(0.22, 0.39, 0.84)
			E:RegisterStatusBar(Bar)

			BarBG:SetTexture(E.media.normTex)
			BarBG:SetVertexColor(0.22 * 0.3, 0.39 * 0.3, 0.84 * 0.3)

			Bar.text:ClearAllPoints()
			Bar.text:Point("CENTER", Bar, "CENTER", 0, -1)
			Bar.text:FontTemplate()
			Bar.text:SetJustifyH("CENTER")

			if index > 1 then
				Bar:ClearAllPoints()
				Bar.ClearAllPoints = E.noop
				Bar:Point("TOP", _G["AchievementFrameProgressBar"..index - 1], "BOTTOM", 0, -5)
				Bar.SetPoint = E.noop
			end

			Bar.isSkinned = true
		end
	end)

	hooksecurefunc("AchievementObjectives_DisplayCriteria", function(objectivesFrame, id)
		local numCriteria = GetAchievementNumCriteria(id)
		local textStrings, metas = 0, 0
		for i = 1, numCriteria do
			local _, criteriaType, completed, _, _, _, _, assetID = GetAchievementCriteriaInfo(id, i)
			if criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID then
				metas = metas + 1
				local metaCriteria = AchievementButton_GetMeta(metas)

				metaCriteria:CreateBackdrop("Transparent")
				metaCriteria.backdrop:SetOutside(metaCriteria.icon)
				metaCriteria.backdrop:SetBackdropColor(0, 0, 0, 0)
				metaCriteria:Height(21)
				metaCriteria:StyleButton()

				metaCriteria.hover:Point("TOPLEFT", 20, -1)
				metaCriteria.pushed:Point("TOPLEFT", 20, -1)

				metaCriteria.icon:Point("TOPLEFT", 2, -2)
				metaCriteria.icon:SetTexCoord(unpack(E.TexCoords))

				metaCriteria.label:Point("LEFT", 24, -1)

				metaCriteria.border:Kill()

				if objectivesFrame.completed and completed then
					metaCriteria.label:SetShadowOffset(0, 0)
					metaCriteria.label:SetTextColor(1, 1, 1, 1)
				elseif completed then
					metaCriteria.label:SetShadowOffset(1, -1)
					metaCriteria.label:SetTextColor(0, 1, 0, 1)
				else
					metaCriteria.label:SetShadowOffset(1, -1)
					metaCriteria.label:SetTextColor(0.6, 0.6, 0.6, 1)
				end
			elseif criteriaType ~= 1 then
				textStrings = textStrings + 1
				local criteria = AchievementButton_GetCriteria(textStrings)
				if objectivesFrame.completed and completed then
					criteria.name:SetTextColor(1, 1, 1, 1)
					criteria.name:SetShadowOffset(0, 0)
				elseif completed then
					criteria.name:SetTextColor(0, 1, 0, 1)
					criteria.name:SetShadowOffset(1, -1)
				else
					criteria.name:SetTextColor(0.6, 0.6, 0.6, 1)
					criteria.name:SetShadowOffset(1, -1)
				end
			end
		end
	end)

	hooksecurefunc("AchievementObjectives_DisplayProgressiveAchievement", function(objectivesFrame, id)
		for i = 1, 18 do
			local mini = _G["AchievementFrameMiniAchievement"..i]

			if mini and not mini.isSkinned then
				local icon = _G["AchievementFrameMiniAchievement"..i.."Icon"]
				local points = _G["AchievementFrameMiniAchievement"..i.."Points"]
				local border = _G["AchievementFrameMiniAchievement"..i.."Border"]
				local shield = _G["AchievementFrameMiniAchievement"..i.."Shield"]

				mini:SetTemplate()
				mini:SetBackdropColor(0, 0, 0, 0)
				mini.backdropTexture:SetAlpha(0)
				mini:Size(32)

				local prevFrame = _G["AchievementFrameMiniAchievement"..i - 1]
				if i ~= 1 and i ~= 7 then
					mini:Point("TOPLEFT", prevFrame, "TOPRIGHT", 10, 0)
				elseif i == 1 then
					mini:Point("TOPLEFT", 6, -4)
				elseif i == 7 then
					mini:Point("TOPLEFT", AchievementFrameMiniAchievement1, "BOTTOMLEFT", 0, -20)
				end
				mini.SetPoint = E.noop

				icon:SetTexCoord(unpack(E.TexCoords))
				icon:SetInside()

				points:Point("BOTTOMRIGHT", -8, -15)
				points:SetTextColor(1, 0.80, 0.10)

				border:Kill()
				shield:Kill()

				mini.isSkinned = true
			end
		end
	end)

	for i = 1, 20 do
		local button = _G["AchievementFrameCategoriesContainerButton"..i]
		if not button or (button and button.isSkinned) then return end

		button:StripTextures(true)
		button:StyleButton()
		button.isSkinned = true
	end

	for i = 1, 10 do
		local achievement = _G["AchievementFrameComparisonContainerButton"..i]
		if not achievement or (achievement and achievement.isSkinned) then return end

		SkinAchievement(achievement.player)
		SkinAchievement(achievement.friend)

		hooksecurefunc(achievement.player, "Saturate", function()
			if achievement.player.accountWide then
				achievement.player:SetBackdropBorderColor(0.129, 0.671, 0.875)
				achievement.friend:SetBackdropBorderColor(0.129, 0.671, 0.875)
			else
				achievement.player:SetBackdropBorderColor(unpack(E.media.bordercolor))
				achievement.friend:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end)

		achievement.isSkinned = true
	end
end

S:AddCallback("Skin_AchievementUI", function() LoadSkin(true) end)
S:AddCallbackForAddon("Blizzard_AchievementUI", "Skin_Blizzard_AchievementUI", LoadSkin)