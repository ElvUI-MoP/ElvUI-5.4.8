local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")
local TT = E:GetModule("Tooltip")

local _G = _G
local pairs = pairs

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tooltip then return end

	S:HandleCloseButton(ItemRefCloseButton)

	-- Skin Blizzard Tooltips
	local GameTooltip = _G["GameTooltip"]
	local GameTooltipStatusBar = _G["GameTooltipStatusBar"]
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

S:AddCallback("SkinTooltip", LoadSkin)