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
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", -2, -6)
			frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 6)

			_G[name.."IconTexture"]:ClearAllPoints()
			_G[name.."IconTexture"]:Point("LEFT", frame, 7, 0)
			_G[name.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))

			_G[name.."IconTexture"].backdrop = CreateFrame("Frame", nil, frame)
			_G[name.."IconTexture"].backdrop:SetTemplate()
			_G[name.."IconTexture"].backdrop:SetOutside(_G[name.."IconTexture"])

			_G[name.."Unlocked"]:SetTextColor(1, 1, 1)

			_G[name.."Background"]:Kill()
			_G[name.."Glow"]:Kill()
			_G[name.."Shine"]:Kill()
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
			frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", -2, -6)
			frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 6)

			_G[name.."IconTexture"]:ClearAllPoints()
			_G[name.."IconTexture"]:Point("LEFT", frame, -6, 0)
			_G[name.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))

			_G[name.."IconTexture"].backdrop = CreateFrame("Frame", nil, frame)
			_G[name.."IconTexture"].backdrop:SetTemplate()
			_G[name.."IconTexture"].backdrop:SetOutside(_G[name.."IconTexture"])
			_G[name.."IconTexture"]:SetParent(_G[name.."IconTexture"].backdrop)

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

	-- Dungeon Completion Alerts
	DungeonCompletionAlertFrame1:DisableDrawLayer("BORDER")
	DungeonCompletionAlertFrame1:DisableDrawLayer("OVERLAY")

	DungeonCompletionAlertFrame1:CreateBackdrop("Transparent")
	DungeonCompletionAlertFrame1.backdrop:Point("TOPLEFT", DungeonCompletionAlertFrame1, "TOPLEFT", -2, -6)
	DungeonCompletionAlertFrame1.backdrop:Point("BOTTOMRIGHT", DungeonCompletionAlertFrame1, "BOTTOMRIGHT", -2, 6)

	DungeonCompletionAlertFrame1.dungeonTexture:ClearAllPoints()
	DungeonCompletionAlertFrame1.dungeonTexture:Point("LEFT", DungeonCompletionAlertFrame1.backdrop, 9, 0)
	DungeonCompletionAlertFrame1.dungeonTexture:SetTexCoord(unpack(E.TexCoords))

	DungeonCompletionAlertFrame1.dungeonTexture.backdrop = CreateFrame("Frame", "$parentDungeonTextureBackground", DungeonCompletionAlertFrame1)
	DungeonCompletionAlertFrame1.dungeonTexture.backdrop:SetTemplate()
	DungeonCompletionAlertFrame1.dungeonTexture.backdrop:SetOutside(DungeonCompletionAlertFrame1.dungeonTexture)
	DungeonCompletionAlertFrame1.dungeonTexture.backdrop:SetFrameLevel(0)

	DungeonCompletionAlertFrame1.shine:Kill()
	DungeonCompletionAlertFrame1.raidArt:Kill()

	DungeonCompletionAlertFrame1.dungeonArt1:Kill()
	DungeonCompletionAlertFrame1.dungeonArt2:Kill()
	DungeonCompletionAlertFrame1.dungeonArt3:Kill()
	DungeonCompletionAlertFrame1.dungeonArt4:Kill()

	DungeonCompletionAlertFrame1.glowFrame:Kill()
	DungeonCompletionAlertFrame1.glowFrame.glow:Kill()
	DungeonCompletionAlertFrame1.glowFrame:DisableDrawLayer("OVERLAY")

	DungeonCompletionAlertFrame1.heroicIcon:Hide()
	DungeonCompletionAlertFrame1Reward1:Hide()

	local function DungeonCompletionAlertFrameReward_SetReward(self)
		self:Hide()
	end
	hooksecurefunc("DungeonCompletionAlertFrameReward_SetReward", DungeonCompletionAlertFrameReward_SetReward)

	-- Guild Challenge Alerts
	for i = 1, GuildChallengeAlertFrame:GetNumRegions() do
		local region = select(i, GuildChallengeAlertFrame:GetRegions())
		if region and region:GetObjectType() == "Texture" and not region:GetName() then
			region:SetTexture(nil)
		end
	end

	GuildChallengeAlertFrame:CreateBackdrop("Transparent")
	GuildChallengeAlertFrame.backdrop:SetPoint("TOPLEFT", GuildChallengeAlertFrame, "TOPLEFT", -2, -6)
	GuildChallengeAlertFrame.backdrop:SetPoint("BOTTOMRIGHT", GuildChallengeAlertFrame, "BOTTOMRIGHT", -2, 6)

	GuildChallengeAlertFrameEmblemIcon.backdrop = CreateFrame("Frame", nil, GuildChallengeAlertFrame)
	GuildChallengeAlertFrameEmblemIcon.backdrop:SetTemplate()
	GuildChallengeAlertFrameEmblemIcon.backdrop:SetPoint("TOPLEFT", GuildChallengeAlertFrameEmblemIcon, "TOPLEFT", -2, 2)
	GuildChallengeAlertFrameEmblemIcon.backdrop:SetPoint("BOTTOMRIGHT", GuildChallengeAlertFrameEmblemIcon, "BOTTOMRIGHT", 2, -1)
	GuildChallengeAlertFrameEmblemIcon.backdrop:SetFrameLevel(0)

	GuildChallengeAlertFrameGlow:Kill()
	GuildChallengeAlertFrameShine:Kill()
	GuildChallengeAlertFrameEmblemBorder:Kill()

	-- Challenge Mode Alerts
	hooksecurefunc("AlertFrame_SetChallengeModeAnchors", function(anchorFrame)
		for i = 1, ChallengeModeAlertFrame1:GetNumRegions() do
			local region = select(i, ChallengeModeAlertFrame1:GetRegions())

			if region and region:GetObjectType() == "Texture" then
				if region:GetTexture() == "Interface\\Challenges\\challenges-main" then
					region:Kill()
				end
			end
		end
	end)

	ChallengeModeAlertFrame1:CreateBackdrop("Transparent")
	ChallengeModeAlertFrame1.backdrop:SetPoint("TOPLEFT", ChallengeModeAlertFrame1, "TOPLEFT", -2, -6)
	ChallengeModeAlertFrame1.backdrop:SetPoint("BOTTOMRIGHT", ChallengeModeAlertFrame1, "BOTTOMRIGHT", -2, 6)

	ChallengeModeAlertFrame1DungeonTexture:ClearAllPoints()
	ChallengeModeAlertFrame1DungeonTexture:Point("LEFT", ChallengeModeAlertFrame1.backdrop, 9, 0)
	ChallengeModeAlertFrame1DungeonTexture:SetTexCoord(unpack(E.TexCoords))

	ChallengeModeAlertFrame1DungeonTexture.backdrop = CreateFrame("Frame", nil, ChallengeModeAlertFrame1)
	ChallengeModeAlertFrame1DungeonTexture.backdrop:SetTemplate()
	ChallengeModeAlertFrame1DungeonTexture.backdrop:SetOutside(ChallengeModeAlertFrame1DungeonTexture)
	ChallengeModeAlertFrame1DungeonTexture.backdrop:SetFrameLevel(0)

	ChallengeModeAlertFrame1Border:Kill()
	ChallengeModeAlertFrame1Shine:Kill()
	ChallengeModeAlertFrame1GlowFrame:Kill()
	ChallengeModeAlertFrame1GlowFrame.glow:Kill()

	-- Scenario Alert
	hooksecurefunc("AlertFrame_SetScenarioAnchors", function(anchorFrame)
		for i = 1, ScenarioAlertFrame1:GetNumRegions() do
			local region = select(i, ScenarioAlertFrame1:GetRegions())

			if region and region:GetObjectType() == "Texture" then
				if region:GetTexture() == "Interface\\Scenarios\\ScenariosParts" then
					region:Kill()
				end
			end
		end
	end)

	ScenarioAlertFrame1:CreateBackdrop("Transparent")
	ScenarioAlertFrame1.backdrop:SetPoint("TOPLEFT", ScenarioAlertFrame1, "TOPLEFT", -2, -6)
	ScenarioAlertFrame1.backdrop:SetPoint("BOTTOMRIGHT", ScenarioAlertFrame1, "BOTTOMRIGHT", -2, 6)

	ScenarioAlertFrame1DungeonTexture:ClearAllPoints()
	ScenarioAlertFrame1DungeonTexture:Point("LEFT", ScenarioAlertFrame1.backdrop, 9, 0)
	ScenarioAlertFrame1DungeonTexture:SetTexCoord(unpack(E.TexCoords))

	ScenarioAlertFrame1DungeonTexture.backdrop = CreateFrame("Frame", nil, ScenarioAlertFrame1)
	ScenarioAlertFrame1DungeonTexture.backdrop:SetTemplate()
	ScenarioAlertFrame1DungeonTexture.backdrop:SetPoint("TOPLEFT", ScenarioAlertFrame1DungeonTexture, "TOPLEFT", -2, 2)
	ScenarioAlertFrame1DungeonTexture.backdrop:SetPoint("BOTTOMRIGHT", ScenarioAlertFrame1DungeonTexture, "BOTTOMRIGHT", 2, -2)
	ScenarioAlertFrame1DungeonTexture.backdrop:SetFrameLevel(0)

	ScenarioAlertFrame1Shine:Kill()
	ScenarioAlertFrame1GlowFrame:Kill()
	ScenarioAlertFrame1GlowFrame.glow:Kill()

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
			frame.Icon:SetTexCoord(unpack(E.TexCoords))
			frame.Icon:SetParent(frame.Icon.backdrop)

			frame.Amount:ClearAllPoints()
			frame.Amount:Point("LEFT", frame.Icon, 58, 0)

			frame.IconBorder:Kill()
			frame.Background:Kill()

			frame.isSkinned = true
		end
	end)

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
				frame.SpecIcon:Point("LEFT", frame.RollTypeIcon, -4, -34)
				frame.SpecIcon:SetTexCoord(unpack(E.TexCoords))
				frame.SpecIcon:SetParent(frame.SpecIcon.backdrop)

				if frame.SpecRing and frame.SpecIcon and frame.SpecIcon.GetTexture and frame.SpecIcon:GetTexture() == nil then
					frame.SpecRing:Hide()
				end

				frame.ItemName:ClearAllPoints()
				frame.ItemName:Point("LEFT", frame.Icon, 58, 0)

				frame.RollTypeIcon:Point("TOPRIGHT", frame, -4, -2)

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

			frame.SpecIcon.backdrop:SetShown(specID and specID > 0)
		end
	end)

	-- Bonus Roll Money Alert
	BonusRollMoneyWonFrame:CreateBackdrop("Transparent")
	BonusRollMoneyWonFrame.backdrop:Point("TOPLEFT", BonusRollMoneyWonFrame.Icon, "TOPLEFT", -4, 4)
	BonusRollMoneyWonFrame.backdrop:Point("BOTTOMRIGHT", BonusRollMoneyWonFrame.Icon, "BOTTOMRIGHT", 180, -4)

	BonusRollMoneyWonFrame.Icon.backdrop = CreateFrame("Frame", nil, BonusRollMoneyWonFrame)
	BonusRollMoneyWonFrame.Icon.backdrop:SetTemplate()
	BonusRollMoneyWonFrame.Icon.backdrop:SetOutside(BonusRollMoneyWonFrame.Icon)

	BonusRollMoneyWonFrame.Icon:SetTexCoord(unpack(E.TexCoords))
	BonusRollMoneyWonFrame.Icon:SetParent(BonusRollMoneyWonFrame.Icon.backdrop)

	BonusRollMoneyWonFrame.Background:Kill()
	BonusRollMoneyWonFrame.IconBorder:Kill()

	-- Bonus Roll Loot Alert
	BonusRollLootWonFrame:CreateBackdrop("Transparent")
	BonusRollLootWonFrame.backdrop:Point("TOPLEFT", BonusRollLootWonFrame.Icon, "TOPLEFT", -4, 4)
	BonusRollLootWonFrame.backdrop:Point("BOTTOMRIGHT", BonusRollLootWonFrame.Icon, "BOTTOMRIGHT", 180, -4)

	BonusRollLootWonFrame.Icon.backdrop = CreateFrame("Frame", nil, BonusRollLootWonFrame)
	BonusRollLootWonFrame.Icon.backdrop:SetTemplate()
	BonusRollLootWonFrame.Icon.backdrop:SetOutside(BonusRollLootWonFrame.Icon)

	BonusRollLootWonFrame.Icon:SetTexCoord(unpack(E.TexCoords))
	BonusRollLootWonFrame.Icon:SetParent(BonusRollLootWonFrame.Icon.backdrop)

	BonusRollLootWonFrame.glow:Kill()
	BonusRollLootWonFrame.shine:Kill()
	BonusRollLootWonFrame.Background:Kill()
	BonusRollLootWonFrame.IconBorder:Kill()

	-- Digsite Alert
	DigsiteCompleteToastFrame:GetRegions():Hide()
	DigsiteCompleteToastFrame:CreateBackdrop("Transparent")
	DigsiteCompleteToastFrame.backdrop:Point("TOPLEFT", DigsiteCompleteToastFrame, "TOPLEFT", -16, -6)
	DigsiteCompleteToastFrame.backdrop:Point("BOTTOMRIGHT", DigsiteCompleteToastFrame, "BOTTOMRIGHT", 13, 6)

	DigsiteCompleteToastFrame.DigsiteTypeTexture:Point("LEFT", -10, -14)

	DigsiteCompleteToastFrame.glow:Kill()
	DigsiteCompleteToastFrame.shine:Kill()
end

S:AddCallback("Alerts", LoadSkin)