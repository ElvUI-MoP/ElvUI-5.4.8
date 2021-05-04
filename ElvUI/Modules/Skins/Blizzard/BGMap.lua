local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.bgmap then return end

	BattlefieldMinimapCorner:Kill()
	BattlefieldMinimapBackground:Kill()
	BattlefieldMinimapTab:Kill()
	BattlefieldMinimapTabLeft:Kill()
	BattlefieldMinimapTabMiddle:Kill()
	BattlefieldMinimapTabRight:Kill()

	BattlefieldMinimap:CreateBackdrop()
	BattlefieldMinimap.backdrop:Point("BOTTOMRIGHT", -4, 2)
	BattlefieldMinimap:SetFrameStrata("MEDIUM")
	BattlefieldMinimap:SetFrameLevel(25)
	BattlefieldMinimap:EnableMouse(true)
	BattlefieldMinimap:SetMovable(true)
	BattlefieldMinimap:SetClampedToScreen(true)

	BattlefieldMinimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "LeftButton" then
			BattlefieldMinimapTab:StopMovingOrSizing()
			BattlefieldMinimapTab:SetUserPlaced(true)
			if OpacityFrame:IsShown() then OpacityFrame:Hide() end
		elseif btn == "RightButton" then
			ToggleDropDownMenu(1, nil, BattlefieldMinimapTabDropDown, self:GetName(), 0, -4)
			if OpacityFrame:IsShown() then OpacityFrame:Hide() end
		end
	end)

	BattlefieldMinimap:SetScript("OnMouseDown", function(_, btn)
		if btn == "LeftButton" and (BattlefieldMinimapOptions and not BattlefieldMinimapOptions.locked) then
			BattlefieldMinimapTab:StartMoving()
		end
	end)

	hooksecurefunc("BattlefieldMinimap_UpdateOpacity", function()
		local alpha = 1.0 - (BattlefieldMinimapOptions and BattlefieldMinimapOptions.opacity or 0)
		BattlefieldMinimap.backdrop:SetAlpha(alpha)
	end)

	local oldAlpha
	BattlefieldMinimap:HookScript("OnEnter", function()
		oldAlpha = BattlefieldMinimapOptions and BattlefieldMinimapOptions.opacity or 0
		BattlefieldMinimap_UpdateOpacity(0)
	end)

	BattlefieldMinimap:HookScript("OnLeave", function()
		if oldAlpha then
			BattlefieldMinimap_UpdateOpacity(oldAlpha)
			oldAlpha = nil
		end
	end)

	S:HandleCloseButton(BattlefieldMinimapCloseButton, BattlefieldMinimap.backdrop)

	BattlefieldMinimapCloseButton:HookScript("OnEnter", function()
		oldAlpha = BattlefieldMinimapOptions and BattlefieldMinimapOptions.opacity or 0
		BattlefieldMinimap_UpdateOpacity(0)
	end)

	BattlefieldMinimapCloseButton:HookScript("OnLeave", function()
		if oldAlpha then
			BattlefieldMinimap_UpdateOpacity(oldAlpha)
			oldAlpha = nil
		end
	end)
end

S:AddCallbackForAddon("Blizzard_BattlefieldMinimap", "BattlefieldMinimap", LoadSkin)