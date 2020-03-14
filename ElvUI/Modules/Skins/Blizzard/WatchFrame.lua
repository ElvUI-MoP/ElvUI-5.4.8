local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local GetNumQuestWatches = GetNumQuestWatches
local GetQuestIndexForWatch = GetQuestIndexForWatch
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetNumAutoQuestPopUps = GetNumAutoQuestPopUps

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.watchframe then return end

	-- WatchFrame Expand/Collapse Button
	WatchFrameCollapseExpandButton:StripTextures()
	WatchFrameCollapseExpandButton:Size(18)
	WatchFrameCollapseExpandButton:SetFrameStrata("MEDIUM")
	WatchFrameCollapseExpandButton:Point("TOPRIGHT", -20, 0)
	WatchFrameCollapseExpandButton.tex = WatchFrameCollapseExpandButton:CreateTexture(nil, "OVERLAY")
	WatchFrameCollapseExpandButton.tex:SetTexture(E.Media.Textures.MinusButton)
	WatchFrameCollapseExpandButton.tex:SetInside()
	WatchFrameCollapseExpandButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")

	WatchFrameHeader:Point("TOPLEFT", 0, -3)

	WatchFrameLines:StripTextures()

	hooksecurefunc("WatchFrame_Expand", function()
		WatchFrameCollapseExpandButton.tex:SetTexture(E.Media.Textures.MinusButton)

		WatchFrame:Width(WATCHFRAME_EXPANDEDWIDTH)
	end)

	hooksecurefunc("WatchFrame_Collapse", function()
		WatchFrameCollapseExpandButton.tex:SetTexture(E.Media.Textures.PlusButton)

		WatchFrame:Width(WATCHFRAME_EXPANDEDWIDTH)
	end)
--[[
	-- WatchFrame Box Header
	WatchFrameScenarioFrame.ScrollChild.BlockHeader:StripTextures()
	WatchFrameScenarioFrame.ScrollChild.BlockHeader:CreateBackdrop("Transparent")
	WatchFrameScenarioFrame.ScrollChild.BlockHeader.backdrop:Point("TOPLEFT", 0, -4)
	WatchFrameScenarioFrame.ScrollChild.BlockHeader.backdrop:Point("BOTTOMRIGHT", 0, 4)

	WatchFrameScenarioFrame.ScrollChild.BlockHeader.stageComplete:SetTextColor(1, 1, 1)
	WatchFrameScenarioFrame.ScrollChild.BlockHeader.stageLevel:SetTextColor(1, 1, 1)
	WatchFrameScenarioFrame.ScrollChild.BlockHeader.stageName:SetTextColor(1, 1, 1)
]]
	-- WatchFrame Text
	hooksecurefunc("WatchFrame_Update", function()
		local title, level, color
		for i = 1, GetNumQuestWatches() do
			local questIndex = GetQuestIndexForWatch(i)
			if questIndex then
				title, level = GetQuestLogTitle(questIndex)
				color = GetQuestDifficultyColor(level)

				for j = 1, #WATCHFRAME_QUESTLINES do
					if WATCHFRAME_QUESTLINES[j].text:GetText() == title then
						WATCHFRAME_QUESTLINES[j].text:SetTextColor(color.r, color.g, color.b)
						WATCHFRAME_QUESTLINES[j].color = color
					end
				end
			end
		end

		for i = 1, #WATCHFRAME_ACHIEVEMENTLINES do
			WATCHFRAME_ACHIEVEMENTLINES[i].color = nil
		end
		-- WatchFrame Items
		for i = 1, WATCHFRAME_NUM_ITEMS do
			local button = _G["WatchFrameItem"..i]
			local icon = _G["WatchFrameItem"..i.."IconTexture"]
			local normal = _G["WatchFrameItem"..i.."NormalTexture"]
			local cooldown = _G["WatchFrameItem"..i.."Cooldown"]

			if button and not button.isSkinned then
				button:CreateBackdrop()
				button.backdrop:SetAllPoints()
				button:StyleButton()
				button:Size(25)

				normal:SetAlpha(0)

				icon:SetInside()
				icon:SetTexCoord(unpack(E.TexCoords))

				E:RegisterCooldown(cooldown)

				button.isSkinned = true
			end
		end

		-- WatchFrame Quest PopUp
		for i = 1, GetNumAutoQuestPopUps() do
			local frame = _G["WatchFrameAutoQuestPopUp"..i]
			local child = _G["WatchFrameAutoQuestPopUp"..i.."ScrollChild"]

			if frame and not frame.isSkinned then
				local name = child:GetName()

				frame:CreateBackdrop("Transparent")
				frame.backdrop:Point("TOPLEFT", 0, -2)
				frame.backdrop:Point("BOTTOMRIGHT", 0, 2)

				frame:SetHitRectInsets(2, 2, 2, 2)

				child.TopText:ClearAllPoints()
				child.TopText:Point("TOP", frame.backdrop, "TOP", 0, -10)
				child.TopText.SetPoint = E.noop

				child.QuestName:ClearAllPoints()
				child.QuestName:Point("CENTER", frame.backdrop, "CENTER", 0, 0)
				child.QuestName.SetPoint = E.noop

				child.BottomText:ClearAllPoints()
				child.BottomText:Point("BOTTOM", frame.backdrop, "BOTTOM", 0, 10)
				child.BottomText.SetPoint = E.noop

				child.QuestionMark:ClearAllPoints()
				child.QuestionMark:Point("RIGHT", child.QuestName, "LEFT", -2, 0)
				child.QuestionMark:SetParent(frame.backdrop)
				child.QuestionMark:SetDrawLayer("OVERLAY", 7)

				child.Exclamation:ClearAllPoints()
				child.Exclamation:Point("RIGHT", child.QuestName, "LEFT", -2, 0)
				child.Exclamation:SetParent(frame.backdrop)
				child.Exclamation:SetDrawLayer("OVERLAY", 7)

				_G[name.."Bg"]:Kill()
				_G[name.."QuestIconBg"]:Kill()
				_G[name.."Flash"]:Kill()
				_G[name.."Shine"]:Kill()
				_G[name.."IconShine"]:Kill()
				_G[name.."FlashIconFlash"]:Kill()
				_G[name.."BorderBotLeft"]:Kill()
				_G[name.."BorderBotRight"]:Kill()
				_G[name.."BorderBottom"]:Kill()
				_G[name.."BorderLeft"]:Kill()
				_G[name.."BorderRight"]:Kill()
				_G[name.."BorderTop"]:Kill()
				_G[name.."BorderTopLeft"]:Kill()
				_G[name.."BorderTopRight"]:Kill()

				frame:HookScript("OnEnter", function(self)
					self.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
				end)
				frame:HookScript("OnLeave", function(self)
					self.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end)

				frame.isSkinned = true
			end
		end
	end)

	-- WatchFrame Highlight
	hooksecurefunc("WatchFrameLinkButtonTemplate_Highlight", function(self, onEnter)
		local line
		for index = self.startLine, self.lastLine do
			line = self.lines[index]
			if line then
				if index == self.startLine then
					if onEnter then
						line.text:SetTextColor(1, 0.80, 0.10)
					else
						if line.color then
							line.text:SetTextColor(line.color.r, line.color.g, line.color.b)
						else
							line.text:SetTextColor(0.75, 0.61, 0)
						end
					end
				end
			end
		end
	end)

	-- WatchFrame POI Buttons
	hooksecurefunc("QuestPOI_DisplayButton", function(parentName, buttonType, buttonIndex)
		local poiButton = _G[format("poi%s%s_%d", parentName, buttonType, buttonIndex)]

		if poiButton and parentName == "WatchFrameLines" then
			if not poiButton.isSkinned then
				poiButton.normalTexture:SetTexture("")
				poiButton.pushedTexture:SetTexture("")
				poiButton.highlightTexture:SetTexture("")
				poiButton.selectionGlow:SetTexture("")

				poiButton:SetScale(1)
				poiButton:SetHitRectInsets(6, 6, 6, 6)

				poiButton.bg = CreateFrame("Frame", nil, poiButton)
				poiButton.bg:SetTemplate("Default", true)
				poiButton.bg:Point("TOPLEFT", 6, -6)
				poiButton.bg:Point("BOTTOMRIGHT", -6, 6)
				poiButton.bg:SetFrameLevel(poiButton.bg:GetFrameLevel() - 1)

				poiButton:HookScript("OnEnter", function(self)
					self.bg:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
				end)
				poiButton:HookScript("OnLeave", function(self)
					self.bg:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end)

				poiButton.isSkinned = true
			end
		end
	end)

	hooksecurefunc("QuestPOI_SelectButton", function(poiButton)
		if poiButton and poiButton.bg then
			poiButton.bg.backdropTexture:SetVertexColor(unpack(E.media.rgbvaluecolor))
		end
	end)

	hooksecurefunc("QuestPOI_DeselectButton", function(poiButton)
		if poiButton and poiButton.bg then
			poiButton.bg.backdropTexture:SetVertexColor(unpack(E.media.backdropcolor))
		end
	end)
end

S:AddCallback("WatchFrame", LoadSkin)