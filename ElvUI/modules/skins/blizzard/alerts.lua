local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select
local tonumber = tonumber

local CreateFrame = CreateFrame

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.alertframes ~= true then return end

	local function forceAlpha(self, alpha, isForced)
		if alpha ~= 1 and isForced ~= true then
			self:SetAlpha(1, true)
		end
	end

	-- Achievement Alerts
	hooksecurefunc("AlertFrame_SetAchievementAnchors", function()
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["AchievementAlertFrame"..i]

			if frame and not frame.isSkinned then
				local name = frame:GetName()
				frame:SetAlpha(1)
				if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha) frame.hooked = true end

				frame:DisableDrawLayer("OVERLAY")
				frame:CreateBackdrop("Transparent")
				frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", -2, -6)
				frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 6)

				_G[name.."Background"]:Kill()
				_G[name.."Glow"]:Kill()
				_G[name.."Shine"]:Kill()
				_G[name.."OldAchievement"]:Kill()
				_G[name.."GuildBanner"]:Kill()
				_G[name.."GuildBorder"]:Kill()
				_G[name.."IconOverlay"]:Kill()

				_G[name.."Unlocked"]:SetTextColor(1, 1, 1)

				_G[name.."IconTexture"]:ClearAllPoints()
				_G[name.."IconTexture"]:Point("LEFT", frame, 7, 0)
				_G[name.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))
				_G[name.."IconTexture"].backdrop = CreateFrame("Frame", nil, frame)
				_G[name.."IconTexture"].backdrop:SetTemplate("Default")
				_G[name.."IconTexture"].backdrop:SetOutside(_G[name.."IconTexture"])
				
				frame.isSkinned = true
			end
		end
	end)

	-- Achievement Criteria Alerts
	hooksecurefunc("AlertFrame_SetAchievementAnchors", function()
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["CriteriaAlertFrame"..i]

			if frame and not frame.isSkinned then
				local name = frame:GetName()
				frame:SetAlpha(1)
				if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha) frame.hooked = true end

				frame:DisableDrawLayer("OVERLAY")
				frame:CreateBackdrop("Transparent")
				frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", -2, -6)
				frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 6)

				_G[name.."Background"]:Kill()
				_G[name.."Glow"]:Kill()
				_G[name.."Shine"]:Kill()
				_G[name.."IconBling"]:Kill()
				_G[name.."IconOverlay"]:Kill()

				_G[name.."Unlocked"]:SetTextColor(1, 1, 1)
				_G[name.."Name"]:SetTextColor(1, 0.80, 0.10)

				_G[name.."IconTexture"]:ClearAllPoints()
				_G[name.."IconTexture"]:Point("LEFT", frame, -6, 0)
				_G[name.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))
				_G[name.."IconTexture"].backdrop = CreateFrame("Frame", nil, frame)
				_G[name.."IconTexture"].backdrop:SetTemplate("Default")
				_G[name.."IconTexture"].backdrop:SetOutside(_G[name.."IconTexture"])
				_G[name.."IconTexture"]:SetParent(_G[name.."IconTexture"].backdrop)

				frame.isSkinned = true
			end
		end
	end)

	-- Dungeon Completion Alerts
	local frame = DungeonCompletionAlertFrame1
	frame:DisableDrawLayer("BORDER")
	frame:DisableDrawLayer("OVERLAY")

	frame:CreateBackdrop("Transparent")
	frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", -2, -6)
	frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 6)

	frame.shine:Kill()
	frame.glowFrame:Kill()
	frame.glowFrame:DisableDrawLayer("OVERLAY")
	frame.glowFrame.glow:Kill()
	frame.heroicIcon:Hide()

	frame.raidArt:Kill()
	frame.dungeonArt1:Kill()
	frame.dungeonArt2:Kill()
	frame.dungeonArt3:Kill()
	frame.dungeonArt4:Kill()

	frame.dungeonTexture:ClearAllPoints()
	frame.dungeonTexture:Point("LEFT", frame.backdrop, 9, 0)
	frame.dungeonTexture:SetTexCoord(unpack(E.TexCoords))

	frame.dungeonTexture.backdrop = CreateFrame("Frame", "$parentDungeonTextureBackground", frame)
	frame.dungeonTexture.backdrop:SetTemplate("Default")
	frame.dungeonTexture.backdrop:SetOutside(frame.dungeonTexture)
	frame.dungeonTexture.backdrop:SetFrameLevel(0)

	DungeonCompletionAlertFrame1Reward1:Hide()

	local function DungeonCompletionAlertFrameReward_SetReward(self)
		self:Hide()
	end
	hooksecurefunc("DungeonCompletionAlertFrameReward_SetReward", DungeonCompletionAlertFrameReward_SetReward)

	-- Guild Challenge Alerts
	GuildChallengeAlertFrame:CreateBackdrop("Transparent")
	GuildChallengeAlertFrame.backdrop:SetPoint("TOPLEFT", GuildChallengeAlertFrame, "TOPLEFT", -2, -6)
	GuildChallengeAlertFrame.backdrop:SetPoint("BOTTOMRIGHT", GuildChallengeAlertFrame, "BOTTOMRIGHT", -2, 6)

	for i = 1, GuildChallengeAlertFrame:GetNumRegions() do
		local region = select(i, GuildChallengeAlertFrame:GetRegions()) 
		if region and region:GetObjectType() == "Texture" and not region:GetName() then
			region:SetTexture(nil)
		end
	end

	GuildChallengeAlertFrameEmblemBorder:Kill()
	GuildChallengeAlertFrameGlow:Kill()
	GuildChallengeAlertFrameShine:Kill()

	GuildChallengeAlertFrameEmblemIcon.backdrop = CreateFrame("Frame", nil, GuildChallengeAlertFrame)
	GuildChallengeAlertFrameEmblemIcon.backdrop:SetTemplate("Default")
	GuildChallengeAlertFrameEmblemIcon.backdrop:SetPoint("TOPLEFT", GuildChallengeAlertFrameEmblemIcon, "TOPLEFT", -2, 2)
	GuildChallengeAlertFrameEmblemIcon.backdrop:SetPoint("BOTTOMRIGHT", GuildChallengeAlertFrameEmblemIcon, "BOTTOMRIGHT", 2, -1)
	GuildChallengeAlertFrameEmblemIcon.backdrop:SetFrameLevel(0)

	-- Challenge Mode Alerts
	ChallengeModeAlertFrame1:CreateBackdrop("Transparent")
	ChallengeModeAlertFrame1.backdrop:SetPoint("TOPLEFT", ChallengeModeAlertFrame1, "TOPLEFT", -2, -6)
	ChallengeModeAlertFrame1.backdrop:SetPoint("BOTTOMRIGHT", ChallengeModeAlertFrame1, "BOTTOMRIGHT", -2, 6)

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

	ChallengeModeAlertFrame1Shine:Kill()
	ChallengeModeAlertFrame1GlowFrame:Kill()
	ChallengeModeAlertFrame1GlowFrame.glow:Kill()
	ChallengeModeAlertFrame1Border:Kill()

	ChallengeModeAlertFrame1DungeonTexture:ClearAllPoints()
	ChallengeModeAlertFrame1DungeonTexture:Point("LEFT", ChallengeModeAlertFrame1.backdrop, 9, 0)
	ChallengeModeAlertFrame1DungeonTexture:SetTexCoord(unpack(E.TexCoords))

	ChallengeModeAlertFrame1DungeonTexture.backdrop = CreateFrame("Frame", nil, ChallengeModeAlertFrame1)
	ChallengeModeAlertFrame1DungeonTexture.backdrop:SetTemplate("Default")
	ChallengeModeAlertFrame1DungeonTexture.backdrop:SetOutside(ChallengeModeAlertFrame1DungeonTexture)
	ChallengeModeAlertFrame1DungeonTexture.backdrop:SetFrameLevel(0)

	-- Scenario Alert
	ScenarioAlertFrame1:CreateBackdrop("Transparent")
	ScenarioAlertFrame1.backdrop:SetPoint("TOPLEFT", ScenarioAlertFrame1, "TOPLEFT", -2, -6)
	ScenarioAlertFrame1.backdrop:SetPoint("BOTTOMRIGHT", ScenarioAlertFrame1, "BOTTOMRIGHT", -2, 6)

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

	ScenarioAlertFrame1Shine:Kill()
	ScenarioAlertFrame1GlowFrame:Kill()
	ScenarioAlertFrame1GlowFrame.glow:Kill()

	ScenarioAlertFrame1DungeonTexture:ClearAllPoints()
	ScenarioAlertFrame1DungeonTexture:Point("LEFT", ScenarioAlertFrame1.backdrop, 9, 0)
	ScenarioAlertFrame1DungeonTexture:SetTexCoord(unpack(E.TexCoords))

	ScenarioAlertFrame1DungeonTexture.backdrop = CreateFrame("Frame", nil, ScenarioAlertFrame1)
	ScenarioAlertFrame1DungeonTexture.backdrop:SetTemplate("Default")
	ScenarioAlertFrame1DungeonTexture.backdrop:SetPoint("TOPLEFT", ScenarioAlertFrame1DungeonTexture, "TOPLEFT", -2, 2)
	ScenarioAlertFrame1DungeonTexture.backdrop:SetPoint("BOTTOMRIGHT", ScenarioAlertFrame1DungeonTexture, "BOTTOMRIGHT", 2, -2)
	ScenarioAlertFrame1DungeonTexture.backdrop:SetFrameLevel(0)

	-- Money Won Alerts
	hooksecurefunc("MoneyWonAlertFrame_SetUp", function(frame)
		if frame and not frame.isSkinned then
			frame:SetAlpha(1)
			if not frame.hooked then
				hooksecurefunc(frame, "SetAlpha", forceAlpha)
				frame.hooked = true
			end
			frame:SetTemplate("Transparent")
			frame:Size(260, 64)

			frame.Background:Kill()
			frame.IconBorder:Kill()

			frame.Icon:ClearAllPoints()
			frame.Icon:Point("LEFT", frame, 6, 0)
			frame.Icon:SetTexCoord(unpack(E.TexCoords))
			frame.Icon.backdrop = CreateFrame("Frame", nil, frame)
			frame.Icon.backdrop:SetTemplate("Default")
			frame.Icon.backdrop:SetOutside(frame.Icon)
			frame.Icon:SetParent(frame.Icon.backdrop)

			frame.Amount:ClearAllPoints()
			frame.Amount:Point("LEFT", frame.Icon, 58, 0)

			frame.isSkinned = true
		end
	end)

	-- Loot Won Alerts
	hooksecurefunc("LootWonAlertFrame_SetUp", function(frame)
		if frame and not frame.isSkinned then
			frame:SetAlpha(1)
			if not frame.hooked then
				hooksecurefunc(frame, "SetAlpha", forceAlpha)
				frame.hooked = true
			end
			frame:SetTemplate("Transparent")
			frame:Size(260, 64)

			frame.Background:Kill()
			frame.IconBorder:Kill()
			frame.glow:Kill()
			frame.shine:Kill()
			if frame.SpecRing and frame.SpecIcon and frame.SpecIcon.GetTexture and frame.SpecIcon:GetTexture() == nil then frame.SpecRing:Hide() end

			frame.Icon:ClearAllPoints()
			frame.Icon:Point("LEFT", frame, 6, 0)
			frame.Icon:SetTexCoord(unpack(E.TexCoords))
			frame.Icon.backdrop = CreateFrame("Frame", nil, frame)
			frame.Icon.backdrop:SetTemplate("Default")
			frame.Icon.backdrop:SetOutside(frame.Icon)
			frame.Icon:SetParent(frame.Icon.backdrop)

			frame.ItemName:ClearAllPoints()
			frame.ItemName:Point("LEFT", frame.Icon, 58, 0)

			frame.RollTypeIcon:Point("TOPRIGHT", frame, -2, 0)

			frame.isSkinned = true
		end
	end)

	-- Bonus Roll Money Alert
	BonusRollMoneyWonFrame:SetAlpha(1)
	hooksecurefunc(BonusRollMoneyWonFrame, "SetAlpha", forceAlpha)

	BonusRollMoneyWonFrame.Background:Kill()
	BonusRollMoneyWonFrame.IconBorder:Kill()

	BonusRollMoneyWonFrame.Icon:SetTexCoord(unpack(E.TexCoords))
	BonusRollMoneyWonFrame.Icon.backdrop = CreateFrame("Frame", nil, BonusRollMoneyWonFrame)
	BonusRollMoneyWonFrame.Icon.backdrop:SetTemplate("Default")
	BonusRollMoneyWonFrame.Icon.backdrop:SetOutside(BonusRollMoneyWonFrame.Icon)
	BonusRollMoneyWonFrame.Icon:SetParent(BonusRollMoneyWonFrame.Icon.backdrop)

	BonusRollMoneyWonFrame:CreateBackdrop("Transparent")
	BonusRollMoneyWonFrame.backdrop:Point("TOPLEFT", BonusRollMoneyWonFrame.Icon.backdrop, "TOPLEFT", -4, 4)
	BonusRollMoneyWonFrame.backdrop:Point("BOTTOMRIGHT", BonusRollMoneyWonFrame.Icon.backdrop, "BOTTOMRIGHT", 180, -4)

	-- Bonus Roll Loot Alert
	BonusRollLootWonFrame:SetAlpha(1)
	hooksecurefunc(BonusRollLootWonFrame, "SetAlpha", forceAlpha)

	BonusRollLootWonFrame.Background:Kill()
	BonusRollLootWonFrame.IconBorder:Kill()
	BonusRollLootWonFrame.glow:Kill()
	BonusRollLootWonFrame.shine:Kill()

	BonusRollLootWonFrame.Icon:SetTexCoord(unpack(E.TexCoords))
	BonusRollLootWonFrame.Icon.backdrop = CreateFrame("Frame", nil, BonusRollLootWonFrame)
	BonusRollLootWonFrame.Icon.backdrop:SetTemplate("Default")
	BonusRollLootWonFrame.Icon.backdrop:SetOutside(BonusRollLootWonFrame.Icon)
	BonusRollLootWonFrame.Icon:SetParent(BonusRollLootWonFrame.Icon.backdrop)

	BonusRollLootWonFrame:CreateBackdrop("Transparent")
	BonusRollLootWonFrame.backdrop:Point("TOPLEFT", BonusRollLootWonFrame.Icon.backdrop, "TOPLEFT", -4, 4)
	BonusRollLootWonFrame.backdrop:Point("BOTTOMRIGHT", BonusRollLootWonFrame.Icon.backdrop, "BOTTOMRIGHT", 180, -4)
end

S:AddCallback("Alerts", LoadSkin)