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
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.watchframe ~= true then return end

	-- WatchFrame Expand/Collapse Button
	WatchFrameCollapseExpandButton:StripTextures()
	S:HandleCloseButton(WatchFrameCollapseExpandButton)
	WatchFrameCollapseExpandButton:Size(32)
	WatchFrameCollapseExpandButton.text:SetText("-")
	WatchFrameCollapseExpandButton.text:Point("CENTER")
	WatchFrameCollapseExpandButton:SetFrameStrata("MEDIUM")
	WatchFrameCollapseExpandButton:Point("TOPRIGHT", -20, 5)

	WatchFrameHeader:Point("TOPLEFT", 0, -3)

	WatchFrameLines:StripTextures()

	hooksecurefunc("WatchFrame_Expand", function()
		WatchFrameCollapseExpandButton.text:SetText("-")

		WatchFrame:Width(WATCHFRAME_EXPANDEDWIDTH)
	end)

	hooksecurefunc("WatchFrame_Collapse", function()
		WatchFrameCollapseExpandButton.text:SetText("+")

		WatchFrame:Width(WATCHFRAME_EXPANDEDWIDTH)
	end)

	-- WatchFrame Text
	hooksecurefunc("WatchFrame_Update", function()
		local questIndex
		local numQuestWatches = GetNumQuestWatches()

		for i = 1, numQuestWatches do
			questIndex = GetQuestIndexForWatch(i)
			if questIndex then
				local title, level = GetQuestLogTitle(questIndex)
				local color = GetQuestDifficultyColor(level)
				--local hex = E:RGBToHex(color.r, color.g, color.b)
				--local text = hex.."["..level.."]|r "..title

				for j = 1, #WATCHFRAME_QUESTLINES do
					if WATCHFRAME_QUESTLINES[j].text:GetText() == title then
						--WATCHFRAME_QUESTLINES[j].text:SetText(text)
						WATCHFRAME_QUESTLINES[j].text:SetTextColor(color.r, color.g, color.b)
						WATCHFRAME_QUESTLINES[j].color = color
					end
				end
				
				for k = 1, #WATCHFRAME_ACHIEVEMENTLINES do
					WATCHFRAME_ACHIEVEMENTLINES[k].color = nil
				end
			end
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

		for i = 1, WATCHFRAME_NUM_POPUPS do
			local frame = _G["WatchFrameAutoQuestPopUp"..i]
			local child = _G["WatchFrameAutoQuestPopUp"..i.."ScrollChild"]

			if frame and frame.isSkinned ~= true then
				local name = child:GetName()

				frame:CreateBackdrop("Transparent", nil, true)
				frame.backdrop:Point("TOPLEFT", 0, -2)
				frame.backdrop:Point("BOTTOMRIGHT", 0, 2)

				frame:SetHitRectInsets(2, 2, 2, 2)

				child.QuestionMark:ClearAllPoints()
				child.QuestionMark:Point("CENTER", frame.backdrop, "LEFT", 12, 0)
				child.QuestionMark:SetParent(frame.backdrop)
				child.QuestionMark:SetDrawLayer("OVERLAY", 7)

				child.Exclamation:ClearAllPoints()
				child.Exclamation:Point("CENTER", frame.backdrop, "LEFT", 12, 0)
				child.Exclamation:SetParent(frame.backdrop)
				child.Exclamation:SetDrawLayer("OVERLAY", 7)

				child.TopText:ClearAllPoints()
				child.TopText:Point("TOP", frame.backdrop, "TOP", 0, -10)
				child.TopText.SetPoint = E.noop

				child.QuestName:ClearAllPoints()
				child.QuestName:Point("LEFT", child.Exclamation, "RIGHT", 2, 0)
				child.QuestName.SetPoint = E.noop

				child.BottomText:ClearAllPoints()
				child.BottomText:Point("BOTTOM", frame.backdrop, "BOTTOM", 0, 10)
				child.BottomText.SetPoint = E.noop

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

				frame:HookScript("OnEnter", S.SetModifiedBackdrop)
				frame:HookScript("OnLeave", S.SetOriginalBackdrop)

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
		local buttonName = "poi"..parentName..buttonType.."_"..buttonIndex
		local poiButton = _G[buttonName]

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