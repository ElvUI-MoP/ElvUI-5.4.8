local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")
local TT = E:GetModule("Tooltip")

local _G = _G
local pairs = pairs

local C_PetBattles_GetLevel = C_PetBattles.GetLevel
local C_PetBattles_GetAbilityInfoByID = C_PetBattles.GetAbilityInfoByID
local C_PetBattles_GetAttackModifier = C_PetBattles.GetAttackModifier
local C_PetJournal_GetNumPetTypes = C_PetJournal.GetNumPetTypes
local C_PetBattles_GetPetType = C_PetBattles.GetPetType

local PET_TYPE_SUFFIX = PET_TYPE_SUFFIX

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tooltip then return end

	S:HandleCloseButton(ItemRefCloseButton)

	-- Skin Blizzard Tooltips
	local tooltips = {
		GameTooltip,
		ItemRefTooltip,
		ItemRefShoppingTooltip1,
		ItemRefShoppingTooltip2,
		ItemRefShoppingTooltip3,
		AutoCompleteBox,
		FriendsTooltip,
		ConsolidatedBuffsTooltip,
		ShoppingTooltip1,
		ShoppingTooltip2,
		ShoppingTooltip3,
		WorldMapTooltip,
		WorldMapCompareTooltip1,
		WorldMapCompareTooltip2,
		WorldMapCompareTooltip3
	}
	for _, tt in pairs(tooltips) do
		TT:SecureHookScript(tt, "OnShow", "SetStyle")
	end

	-- Skin GameTooltip Status Bar
	GameTooltipStatusBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(GameTooltipStatusBar)
	GameTooltipStatusBar:CreateBackdrop("Transparent")
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:Point("TOPLEFT", GameTooltip, "BOTTOMLEFT", E.Border, -(E.Spacing * 3))
	GameTooltipStatusBar:Point("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -E.Border, -(E.Spacing * 3))

	TT:SecureHook("GameTooltip_ShowStatusBar") -- Skin Status Bars

	-- [Backdrop coloring] There has to be a more elegant way of doing this.
	TT:SecureHookScript(GameTooltip, "OnSizeChanged", "CheckBackdropColor")
	TT:SecureHookScript(GameTooltip, "OnUpdate", "CheckBackdropColor")
end

local function LoadSkin2()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tooltip then return end

	-- Skin Battle Pet Tooltips
	local petTooltips = {
		PetJournalPrimaryAbilityTooltip,
		FloatingBattlePetTooltip,
		FloatingPetBattleAbilityTooltip,
		PetBattlePrimaryAbilityTooltip,
		PetBattlePrimaryUnitTooltip,
		BattlePetTooltip
	}
	for _, frame in pairs(petTooltips) do
		frame.Background:SetTexture()
		frame.BorderTop:SetTexture()
		frame.BorderTopLeft:SetTexture()
		frame.BorderTopRight:SetTexture()
		frame.BorderLeft:SetTexture()
		frame.BorderRight:SetTexture()
		frame.BorderBottom:SetTexture()
		frame.BorderBottomRight:SetTexture()
		frame.BorderBottomLeft:SetTexture()

		frame:SetTemplate("Transparent", nil, true)

		if frame.Delimiter1 then
			frame.Delimiter1:SetTexture()
			frame.Delimiter2:SetTexture()
		end

		if frame == FloatingBattlePetTooltip or frame == FloatingPetBattleAbilityTooltip then
			S:HandleCloseButton(frame.CloseButton)
		end

		if frame == PetBattlePrimaryUnitTooltip then
			-- Health
			frame.HealthBorder:SetTexture()
			frame.HealthBG:SetTexture()

			frame.healthBG = CreateFrame("Frame", nil, frame)
			frame.healthBG:SetTemplate()
			frame.healthBG:Point("TOPLEFT", frame.HealthBG, -1, 1)
			frame.healthBG:Point("BOTTOMRIGHT", frame.HealthBG, 1, -2)

			frame.ActualHealthBar:SetTexture(E.media.normTex)
			frame.ActualHealthBar:SetParent(frame.healthBG)

			frame.HealthText:SetParent(frame.healthBG)

			-- XP
			frame.XPBG:SetTexture()
			frame.XPBorder:SetTexture()

			frame.xpBG = CreateFrame("Frame", nil, frame)
			frame.xpBG:SetTemplate()
			frame.xpBG:Point("TOPLEFT", frame.XPBG, -1, 1)
			frame.xpBG:Point("BOTTOMRIGHT", frame.XPBG, 1, -2)

			hooksecurefunc("PetBattleUnitTooltip_UpdateForUnit", function(self, petOwner, petIndex)
				local level = C_PetBattles_GetLevel(petOwner, petIndex)

				self.xpBG:SetShown(petOwner == LE_BATTLE_PET_ALLY and level < 25)
			end)

			frame.XPBar:SetTexture(E.media.normTex)
			frame.XPBar:SetParent(frame.xpBG)

			frame.XPText:SetParent(frame.xpBG)

			-- Icon
			frame.iconBG = CreateFrame("Frame", nil, frame)
			frame.iconBG:SetTemplate()
			frame.iconBG:SetOutside(frame.Icon)

			frame.Border:SetTexture()

			hooksecurefunc(frame.Border, "SetVertexColor", function(_, r, g, b)
				frame.iconBG:SetBackdropBorderColor(r, g, b)
			end)

			frame.Icon:SetTexCoord(unpack(E.TexCoords))
			frame.Icon.SetTexCoord = E.noop
			frame.Icon:SetParent(frame.iconBG)

			-- Level
			frame.Level:SetTextColor(1, 1, 1)
			frame.Level:SetParent(frame.iconBG)

			-- Type
			frame.PetType.Icon:SetTexCoord(0, 1, 0, 1)
		end
	end

	hooksecurefunc("SharedPetBattleAbilityTooltip_SetAbility", function(self, abilityInfo)
		local abilityID = abilityInfo:GetAbilityID()
		if not abilityID then return end

		local _, _, _, _, _, _, petType, noStrongWeakHints = C_PetBattles_GetAbilityInfoByID(abilityID)

		if petType and petType > 0 then
			self.AbilityPetType:SetTexture(E.Media.BattlePetTypes[PET_TYPE_SUFFIX[petType]])
			self.AbilityPetType:SetTexCoord(0, 1, 0, 1)
		end

		if petType and not noStrongWeakHints then
			local nextStrongIndex, nextWeakIndex = 1, 1

			for i = 1, C_PetJournal_GetNumPetTypes() do
				local modifier = C_PetBattles_GetAttackModifier(petType, i)

				if modifier > 1 then
					local icon = self.strongAgainstTextures[nextStrongIndex]

					icon:SetTexture(E.Media.BattlePetTypes[PET_TYPE_SUFFIX[i]])
					icon:SetTexCoord(0, 1, 0, 1)

					nextStrongIndex = nextStrongIndex + 1
				elseif modifier < 1 then
					local icon = self.weakAgainstTextures[nextWeakIndex]

					icon:SetTexture(E.Media.BattlePetTypes[PET_TYPE_SUFFIX[i]])
					icon:SetTexCoord(0, 1, 0, 1)

					nextWeakIndex = nextWeakIndex + 1
				end
			end
		end
	end)

	hooksecurefunc("BattlePetTooltipTemplate_SetBattlePet", function(tooltipFrame, data)
		tooltipFrame.PetTypeTexture:SetTexture(E.Media.BattlePetTypes[PET_TYPE_SUFFIX[data.petType]])
		tooltipFrame.PetTypeTexture:SetTexCoord(0, 1, 0, 1)
	end)

	hooksecurefunc("PetBattleUnitFrame_UpdatePetType", function()
		if not PetBattlePrimaryUnitTooltip.PetType then return end

		local petType = C_PetBattles_GetPetType(PetBattlePrimaryUnitTooltip.petOwner, PetBattlePrimaryUnitTooltip.petIndex)
		PetBattlePrimaryUnitTooltip.PetType.Icon:SetTexture(E.Media.BattlePetTypes[PET_TYPE_SUFFIX[petType]])
	end)
end

S:AddCallback("SkinTooltip", LoadSkin)
S:AddCallback("SkinBattlePetTooltip", LoadSkin2)