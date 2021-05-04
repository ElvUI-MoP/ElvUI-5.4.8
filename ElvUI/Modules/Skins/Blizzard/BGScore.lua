local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs = pairs
local format, split = string.format, string.split

local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
local GetBattlefieldScore = GetBattlefieldScore
local IsActiveBattlefieldArena = IsActiveBattlefieldArena

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.bgscore then return end

	WorldStateScoreFrame:StripTextures()
	WorldStateScoreFrame:SetTemplate("Transparent")

	WorldStateScoreFrameInset:Kill()

	S:HandleButton(WorldStateScoreFrameLeaveButton)

	for _, tab in pairs({"KB", "Deaths", "HK", "DamageDone", "HealingDone", "HonorGained", "Name", "Class", "Team", "RatingChange"}) do
		_G["WorldStateScoreFrame"..tab]:StyleButton()
	end

	for i = 1, 5 do
		_G["WorldStateScoreColumn"..i]:StyleButton()
	end

	S:HandleCloseButton(WorldStateScoreFrameCloseButton)
	WorldStateScoreFrameCloseButton:Point("TOPRIGHT", 4, 6)

	-- Winner Frame
	WorldStateScoreWinnerFrame:StripTextures()
	WorldStateScoreWinnerFrame:CreateBackdrop("Transparent")
	WorldStateScoreWinnerFrame:Point("TOPLEFT", 1, -1)
	WorldStateScoreWinnerFrame:Point("TOPRIGHT", -1, -1)

	WorldStateScoreWinnerFrameRight:SetTexture(E.Media.Textures.Highlight)
	WorldStateScoreWinnerFrameRight:SetAlpha(0.85)
	WorldStateScoreWinnerFrameRight:SetInside(WorldStateScoreWinnerFrame.backdrop)

	WorldStateScoreWinnerFrameText:Point("CENTER")

	WorldStateScoreWinnerFrame:HookScript("OnShow", function()
		WorldStateScoreFrameLabel:Hide()
	end)
	WorldStateScoreWinnerFrame:HookScript("OnHide", function()
		WorldStateScoreFrameLabel:Show()
	end)

	-- Scroll Frame
	WorldStateScoreScrollFrame:StripTextures()
	WorldStateScoreScrollFrame:CreateBackdrop("Transparent")
	WorldStateScoreScrollFrame.backdrop:Point("TOPLEFT", 0, 1)
	WorldStateScoreScrollFrame.backdrop:Point("BOTTOMRIGHT", -0, -4)
	WorldStateScoreScrollFrame:Show()
	WorldStateScoreScrollFrame.Hide = E.noop

	S:HandleScrollBar(WorldStateScoreScrollFrameScrollBar)
	WorldStateScoreScrollFrameScrollBar:ClearAllPoints()
	WorldStateScoreScrollFrameScrollBar:Point("TOPRIGHT", WorldStateScoreScrollFrame, 24, -17)
	WorldStateScoreScrollFrameScrollBar:Point("BOTTOMRIGHT", WorldStateScoreScrollFrame, 0, 14)

	for i = 1, MAX_WORLDSTATE_SCORE_BUTTONS do
		local button = _G["WorldStateScoreButton"..i]

		button.factionRight:ClearAllPoints()
		button.factionRight:Point("TOPLEFT", 1, 0)
		button.factionRight:Point("BOTTOMRIGHT", -24, 1)
		button.factionRight:SetTexture(E.Media.Textures.Highlight)
		button.factionRight:SetAlpha(0.85)
		button.factionRight:SetTexCoord(0.1, 0.9, 0, 1)
		button.factionRight:Hide()

		button.factionLeft:ClearAllPoints()
		button.factionLeft:Point("TOPLEFT", 1, 0)
		button.factionLeft:Point("BOTTOMRIGHT", -24, 1)
		button.factionLeft:SetTexture(E.Media.Textures.Highlight)
		button.factionLeft:SetBlendMode("ADD")
		button.factionLeft:SetAlpha(0.6)
		button.factionLeft:Hide()

		button.factionLeft._Show = button.factionLeft.Show
		button.factionLeft.Show = button.factionLeft.Hide
	end
	MAX_WORLDSTATE_SCORE_BUTTONS = 18
	WorldStateScoreFrame_Resize()

	hooksecurefunc("WorldStateScoreFrame_Update", function()
		local inArena = IsActiveBattlefieldArena()
		local offset = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame)
		local _, name, faction, class, button, nameText, realmText, classColor, color

		for i = 1, MAX_WORLDSTATE_SCORE_BUTTONS do
			name, _, _, _, _, faction, _, _, class = GetBattlefieldScore(offset + i)

			if name then
				button = _G["WorldStateScoreButton"..i]

				if name == E.myname then
					button.factionRight:Hide()
					button.factionLeft:_Show()

					if inArena then
						button.factionLeft:SetVertexColor(1, 1, 1)
					else
						if faction == 1 then
							button.factionLeft:SetVertexColor(0.18, 0.6, 0.8)
						else
							button.factionLeft:SetVertexColor(0.85, 0.1, 0)
						end
					end
				end

				nameText, realmText = split("-", name, 2)
				classColor = E:ClassColor(class)

				if realmText then
					if inArena then
						color = faction == 1 and "|cffffd100" or "|cff19ff19"
					else
						color = faction == 1 and "|cff00adf0" or "|cffff1919"
					end
					nameText = format("%s|cffffffff - |r%s%s|r", nameText, color, realmText)
				end

				button.name.text:SetText(nameText)
				button.name.text:SetTextColor(classColor.r, classColor.g, classColor.b)
			end
		end
	end)

	-- Bottom Tabs
	for i = 1, 3 do
		local tab = _G["WorldStateScoreFrameTab"..i]

		S:HandleTab(tab)

		if i == 1 then
			tab:Point("TOPLEFT", WorldStateScoreFrame, "BOTTOMLEFT", 5, 2)
		end
	end
end

S:AddCallback("WorldStateScore", LoadSkin)