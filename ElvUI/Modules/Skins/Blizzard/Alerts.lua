local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select
local tonumber = tonumber

local CreateFrame = CreateFrame

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.alertframes then return end

	-- Achievement Alerts
	S:RawHook("AchievementAlertFrame_GetAlertFrame", function()
		local frame = S.hooks.AchievementAlertFrame_GetAlertFrame()
		if frame and not frame.isSkinned then
			local name = frame:GetName()

			frame:DisableDrawLayer("OVERLAY")
			frame:SetTemplate("Transparent")
			frame:Height(66)
			frame.SetHeight = E.noop

			local icon = _G[name.."IconTexture"]
			icon:ClearAllPoints()
			icon:Point("LEFT", frame, 7, 0)
			icon:SetTexCoord(unpack(E.TexCoords))

			icon.backdrop = CreateFrame("Frame", nil, frame)
			icon.backdrop:SetTemplate()
			icon.backdrop:SetOutside(icon)

			local unlocked = _G[name.."Unlocked"]
			unlocked:ClearAllPoints()
			unlocked:Point("BOTTOM", frame, 0, 8)
			unlocked.SetPoint = E.noop
			unlocked:SetTextColor(0.973, 0.937, 0.580)

			local achievementName = _G[name.."Name"]
			achievementName:ClearAllPoints()
			achievementName:Point("LEFT", frame, 62, 3)
			achievementName:Point("RIGHT", frame, -55, 3)
			achievementName.SetPoint = E.noop

			local achievementGuildName = _G[name.."GuildName"]
			achievementGuildName:ClearAllPoints()
			achievementGuildName:Point("TOPLEFT", frame, 50, -2)
			achievementGuildName:Point("TOPRIGHT", frame, -50, -2)
			achievementGuildName.SetPoint = E.noop

			local shield = _G[name.."Shield"]
			shield:ClearAllPoints()
			shield:Point("TOPRIGHT", frame, -4, -6)
			shield.SetPoint = E.noop

			_G[name.."Background"]:Kill()
			_G[name.."OldAchievement"]:Kill()
			_G[name.."GuildBanner"]:Kill()
			_G[name.."GuildBorder"]:Kill()
			_G[name.."IconOverlay"]:Kill()

			frame.isSkinned = true

			if tonumber(name:match(".+(%d+)")) == MAX_ACHIEVEMENT_ALERTS then
				S:Unhook("AchievementAlertFrame_GetAlertFrame")
			end
		end
		return frame
	end, true)

	-- Achievement Criteria Alerts
	S:RawHook("CriteriaAlertFrame_GetAlertFrame", function()
		local frame = S.hooks.CriteriaAlertFrame_GetAlertFrame()
		if frame and not frame.isSkinned then
			local name = frame:GetName()

			frame:DisableDrawLayer("OVERLAY")
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point("TOPLEFT", frame, -2, -6)
			frame.backdrop:Point("BOTTOMRIGHT", frame, -2, 6)
			frame:SetHitRectInsets(0, 0, 6, 6)

			local icon = _G[name.."IconTexture"]
			icon:ClearAllPoints()
			icon:Point("LEFT", frame, -6, 0)
			icon:SetTexCoord(unpack(E.TexCoords))

			icon.backdrop = CreateFrame("Frame", nil, frame)
			icon.backdrop:SetTemplate()
			icon.backdrop:SetOutside(icon)
			icon:SetParent(icon.backdrop)

			_G[name.."Unlocked"]:SetTextColor(1, 1, 1)
			_G[name.."Name"]:SetTextColor(1, 0.80, 0.10)

			_G[name.."Background"]:Kill()
			_G[name.."Glow"]:Kill()
			_G[name.."Shine"]:Kill()
			_G[name.."IconBling"]:Kill()
			_G[name.."IconOverlay"]:Kill()

			frame.isSkinned = true

			if tonumber(name:match(".+(%d+)")) == MAX_ACHIEVEMENT_ALERTS then
				S:Unhook("CriteriaAlertFrame_GetAlertFrame")
			end
		end
		return frame
	end, true)

	-- Dungeon / Scenario / Challenge Alerts
	local function SkinRewards(frame)
		if frame.isSkinned then return end

		frame:SetTemplate()
		frame:Size(24)
		S:HandleFrameHighlight(frame, frame.backdrop)

		frame.texture:SetInside(frame.backdrop)
		frame.texture:SetTexCoord(unpack(E.TexCoords))

		_G[frame:GetName().."Border"]:Hide()

		frame.isSkinned = true
	end

	for _, frame in pairs({DungeonCompletionAlertFrame1, ScenarioAlertFrame1, ChallengeModeAlertFrame1}) do
		frame:StripTextures()
		frame:SetTemplate("Transparent")
		frame:Size(310, 60)

		frame.dungeonTexture:ClearAllPoints()
		frame.dungeonTexture:Point("BOTTOMLEFT", 8, 8)
		frame.dungeonTexture.SetPoint = E.noop

		frame.dungeonTexture.backdrop = CreateFrame("Frame", nil, frame)
		frame.dungeonTexture.backdrop:SetTemplate()
		frame.dungeonTexture.backdrop:SetOutside(frame.dungeonTexture)

		frame.dungeonTexture:SetTexCoord(unpack(E.TexCoords))
		frame.dungeonTexture:Size(44)
		frame.dungeonTexture:SetDrawLayer("ARTWORK")
		frame.dungeonTexture:SetParent(frame.dungeonTexture.backdrop)

		frame.glowFrame:DisableDrawLayer("OVERLAY")

		local reward = _G[frame:GetName().."Reward1"] or frame.reward1
		SkinRewards(reward)
		reward:Point("TOPLEFT", frame, 64, 7)
		reward.SetPoint = E.noop

		for i = 1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region.IsObjectType and region:IsObjectType("FontString") and region.GetText and (region:GetText() == DUNGEON_COMPLETED or region:GetText() == SCENARIO_COMPLETED or region:GetText() == CHALLENGE_MODE_COMPLETED) then
				region:Point("TOP", 20, -18)
				region:SetTextColor(0.973, 0.937, 0.580)
			end
		end

		local name = frame.instanceName or frame.dungeonName or frame.time
		name:ClearAllPoints()
		name:Point("BOTTOM", 20, 12)
		name.SetPoint = E.noop
	end

	DungeonCompletionAlertFrame1.instanceName:SetTextColor(1, 1, 1)
	DungeonCompletionAlertFrame1.heroicIcon:SetTexture([[Interface\LFGFrame\UI-LFG-ICON-HEROIC]])

	ChallengeModeAlertFrame1.medalIcon:ClearAllPoints()
	ChallengeModeAlertFrame1.medalIcon:Point("RIGHT", -2, 0)
	ChallengeModeAlertFrame1.medalIcon.SetPoint = E.noop

	hooksecurefunc("DungeonCompletionAlertFrameReward_SetReward", function(frame, index)
		SkinRewards(frame)

		SetPortraitToTexture(frame.texture, nil)
		frame.texture:SetTexture(GetLFGCompletionRewardItem(index))
	end)

	hooksecurefunc("ChallengeModeAlertFrameReward_SetReward", function(frame, index)
		SkinRewards(frame)

		SetPortraitToTexture(frame.texture, nil)
		frame.texture:SetTexture(select(3, GetChallengeModeCompletionReward(index)))
	end)

	-- Guild Challenge Alerts
	GuildChallengeAlertFrame:StripTextures()
	GuildChallengeAlertFrame:SetTemplate("Transparent")
	GuildChallengeAlertFrame:Size(260, 64)

	GuildChallengeAlertFrameEmblemIcon.backdrop = CreateFrame("Frame", nil, GuildChallengeAlertFrame)
	GuildChallengeAlertFrameEmblemIcon.backdrop:SetTemplate()
	GuildChallengeAlertFrameEmblemIcon.backdrop:SetOutside(GuildChallengeAlertFrameEmblemIcon)

	GuildChallengeAlertFrameEmblemIcon:Size(52)
	GuildChallengeAlertFrameEmblemIcon:Point("LEFT", 6, 0)
	GuildChallengeAlertFrameEmblemIcon:SetParent(GuildChallengeAlertFrameEmblemIcon.backdrop)

	GuildChallengeAlertFrameType:Point("LEFT", 67, -10)
	GuildChallengeAlertFrameCount:Point("BOTTOMRIGHT", -7, 7)

	-- Digsite Alert
	DigsiteCompleteToastFrame:StripTextures()
	DigsiteCompleteToastFrame:SetTemplate("Transparent")
	DigsiteCompleteToastFrame:Size(260, 64)

	DigsiteCompleteToastFrame.Title:SetTextColor(1, 0.82, 0)
	DigsiteCompleteToastFrame.Title:Point("CENTER", 8, 12)
	DigsiteCompleteToastFrame.DigsiteType:Point("CENTER", 8, -8)
	DigsiteCompleteToastFrame.DigsiteTypeTexture:Point("LEFT", 2, -14)

	-- Store Purchase Alert
	StorePurchaseAlertFrame:StripTextures()
	StorePurchaseAlertFrame:SetTemplate("Transparent")
	StorePurchaseAlertFrame:Size(260, 64)

	StorePurchaseAlertFrame.Icon.backdrop = CreateFrame("Frame", nil, StorePurchaseAlertFrame)
	StorePurchaseAlertFrame.Icon.backdrop:SetTemplate()
	StorePurchaseAlertFrame.Icon.backdrop:SetOutside(StorePurchaseAlertFrame.Icon)

	StorePurchaseAlertFrame.Icon:Point("LEFT", 6, 0)
	StorePurchaseAlertFrame.Icon:SetTexCoord(unpack(E.TexCoords))
	StorePurchaseAlertFrame.Icon:Size(52)
	StorePurchaseAlertFrame.Icon:SetParent(StorePurchaseAlertFrame.Icon.backdrop)

	StorePurchaseAlertFrame.Title:Point("TOP", 20, -10)
	StorePurchaseAlertFrame.Description:Point("BOTTOM", 20, 14)

	-- Loot Won Alerts
	hooksecurefunc("LootWonAlertFrame_SetUp", function(frame, itemLink, _, _, _, specID, isCurrency)
		if frame then
			if not frame.isSkinned then
				frame:SetTemplate("Transparent")
				frame:Size(260, 64)

				frame.Icon.backdrop = CreateFrame("Frame", nil, frame)
				frame.Icon.backdrop:SetTemplate()
				frame.Icon.backdrop:SetOutside(frame.Icon)

				frame.Icon:ClearAllPoints()
				frame.Icon:Point("LEFT", frame, 6, 0)
				frame.Icon:SetTexCoord(unpack(E.TexCoords))
				frame.Icon:SetParent(frame.Icon.backdrop)

				frame.SpecIcon.backdrop = CreateFrame("Frame", nil, frame)
				frame.SpecIcon.backdrop:SetTemplate()
				frame.SpecIcon.backdrop:SetOutside(frame.SpecIcon)

				frame.SpecIcon:ClearAllPoints()
				frame.SpecIcon:Point("LEFT", frame.RollTypeIcon, -2, -34)
				frame.SpecIcon:Size(22)
				frame.SpecIcon:SetTexCoord(unpack(E.TexCoords))
				frame.SpecIcon:SetParent(frame.SpecIcon.backdrop)

				frame.ItemName:ClearAllPoints()
				frame.ItemName:Point("LEFT", frame.Icon, 58, 0)

				frame.RollTypeIcon:Point("TOPRIGHT", frame, -4, -2)

				frame.SpecRing:Kill()
				frame.glow:Kill()
				frame.shine:Kill()
				frame.Background:Kill()
				frame.IconBorder:Kill()

				frame.isSkinned = true
			end

			local quality = isCurrency and select(8, GetCurrencyInfo(itemLink)) or select(3, GetItemInfo(itemLink))
			if quality then
				frame.Icon.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
			else
				frame.Icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end

			frame.SpecIcon.backdrop:SetShown(not isCurrency and specID and specID > 0)
		end
	end)

	-- Money Won Alerts
	hooksecurefunc("MoneyWonAlertFrame_SetUp", function(frame)
		if frame and not frame.isSkinned then
			frame:SetTemplate("Transparent")
			frame:Size(260, 64)

			frame.Icon.backdrop = CreateFrame("Frame", nil, frame)
			frame.Icon.backdrop:SetTemplate()
			frame.Icon.backdrop:SetOutside(frame.Icon)

			frame.Icon:ClearAllPoints()
			frame.Icon:Point("LEFT", frame, 6, 0)
			frame.Icon:Size(52)
			frame.Icon:SetTexCoord(unpack(E.TexCoords))
			frame.Icon:SetParent(frame.Icon.backdrop)

			frame.Amount:ClearAllPoints()
			frame.Amount:Point("LEFT", frame.Icon, 58, 0)

			frame.IconBorder:Kill()
			frame.Background:Kill()

			frame.isSkinned = true
		end
	end)
end

S:AddCallback("Alerts", LoadSkin)