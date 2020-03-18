local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")
local TT = E:GetModule("Tooltip")

local _G = _G
local pairs = pairs

local C_PetBattles_GetLevel = C_PetBattles.GetLevel
local C_PetBattles_GetAbilityInfoByID = C_PetBattles.GetAbilityInfoByID
local C_PetBattles_GetAttackModifier = C_PetBattles.GetAttackModifier
local C_PetJournal_GetNumPetTypes = C_PetJournal.GetNumPetTypes

local PET_TYPE_SUFFIX = PET_TYPE_SUFFIX

local function SkinPetTooltip(tooltip, info)
	tooltip.Background:SetTexture()
	tooltip.BorderTop:SetTexture()
	tooltip.BorderTopLeft:SetTexture()
	tooltip.BorderTopRight:SetTexture()
	tooltip.BorderLeft:SetTexture()
	tooltip.BorderRight:SetTexture()
	tooltip.BorderBottom:SetTexture()
	tooltip.BorderBottomRight:SetTexture()
	tooltip.BorderBottomLeft:SetTexture()

	tooltip:SetTemplate("Transparent")

	if tooltip.Delimiter1 then
		tooltip.Delimiter1:SetTexture()
		tooltip.Delimiter2:SetTexture()
	end

	if not info then return end

	if tooltip.ActualHealthBar then
		tooltip.HealthBorder:SetTexture()
		tooltip.HealthBG:SetTexture()
	
		tooltip.healthBG = CreateFrame("Frame", nil, tooltip)
		tooltip.healthBG:SetTemplate()
		tooltip.healthBG:Point("TOPLEFT", tooltip.HealthBG, -1, 1)
		tooltip.healthBG:Point("BOTTOMRIGHT", tooltip.HealthBG, 1, -2)

		tooltip.ActualHealthBar:SetTexture(E.media.normTex)
		tooltip.ActualHealthBar:SetParent(tooltip.healthBG)

		tooltip.HealthText:SetParent(tooltip.healthBG)
	end

	if tooltip.XPBar then
		tooltip.XPBG:SetTexture()
		tooltip.XPBorder:SetTexture()

		tooltip.xpBG = CreateFrame("Frame", nil, tooltip)
		tooltip.xpBG:SetTemplate()
		tooltip.xpBG:Point("TOPLEFT", tooltip.XPBG, -1, 1)
		tooltip.xpBG:Point("BOTTOMRIGHT", tooltip.XPBG, 1, -2)

		hooksecurefunc("PetBattleUnitTooltip_UpdateForUnit", function(self, petOwner, petIndex)
			local level = C_PetBattles_GetLevel(petOwner, petIndex)

			self.xpBG:SetShown(petOwner == LE_BATTLE_PET_ALLY and level < 25)
		end)

		tooltip.XPBar:SetTexture(E.media.normTex)
		tooltip.XPBar:SetParent(tooltip.xpBG)

		tooltip.XPText:SetParent(tooltip.xpBG)
	end

	if tooltip.Icon then
		tooltip.Border:SetTexture()

		tooltip.iconBG = CreateFrame("Frame", nil, tooltip)
		tooltip.iconBG:SetTemplate()
		tooltip.iconBG:SetOutside(tooltip.Icon)

		hooksecurefunc(tooltip.Border, "SetVertexColor", function(_, r, g, b)
			tooltip.iconBG:SetBackdropBorderColor(r, g, b)
		end)

		tooltip.Icon:SetTexCoord(unpack(E.TexCoords))
		tooltip.Icon.SetTexCoord = E.noop
		tooltip.Icon:SetParent(tooltip.iconBG)

		if tooltip.Level then
			tooltip.Level:SetTextColor(1, 1, 1)
			tooltip.Level:SetParent(tooltip.iconBG)
		end
	end

	if tooltip.PetType and tooltip.PetType.Icon then
		tooltip.PetType.Icon:SetTexCoord(0.200, 0.710, 0.746, 0.917)
	end
end

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

	-- Battle Pet Tooltips
	SkinPetTooltip(PetJournalPrimaryAbilityTooltip)

	SkinPetTooltip(FloatingBattlePetTooltip, true)
	S:HandleCloseButton(FloatingBattlePetTooltip.CloseButton)

	SkinPetTooltip(FloatingPetBattleAbilityTooltip, true)
	S:HandleCloseButton(FloatingPetBattleAbilityTooltip.CloseButton)

	SkinPetTooltip(PetBattlePrimaryAbilityTooltip, true)
	hooksecurefunc("PetBattleAbilityTooltip_Show", function()
		PetBattlePrimaryAbilityTooltip:ClearAllPoints()
		PetBattlePrimaryAbilityTooltip:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -4, -4)
	end)

	SkinPetTooltip(PetBattlePrimaryUnitTooltip, true)
	SkinPetTooltip(BattlePetTooltip, true)

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
end

S:AddCallback("SkinTooltip", LoadSkin)