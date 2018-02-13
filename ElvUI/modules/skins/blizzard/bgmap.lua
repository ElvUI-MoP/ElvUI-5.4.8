local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G

local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bgmap ~= true then return end

	local BattlefieldMinimap = _G["BattlefieldMinimap"]
	BattlefieldMinimap:SetClampedToScreen(true)
	BattlefieldMinimapCorner:Kill()
	BattlefieldMinimapBackground:Kill()
	BattlefieldMinimapTab:Kill()
	BattlefieldMinimapTabLeft:Kill()
	BattlefieldMinimapTabMiddle:Kill()
	BattlefieldMinimapTabRight:Kill()

	BattlefieldMinimap:CreateBackdrop("Default")
	BattlefieldMinimap.backdrop:Point("BOTTOMRIGHT", -4, 2)
	BattlefieldMinimap:SetFrameStrata("MEDIUM")
	BattlefieldMinimap:SetFrameLevel(25)

	BattlefieldMinimapCloseButton:ClearAllPoints()
	BattlefieldMinimapCloseButton:Point("TOPRIGHT", -2, 2)
	S:HandleCloseButton(BattlefieldMinimapCloseButton)
	BattlefieldMinimapCloseButton.text:ClearAllPoints()
	BattlefieldMinimapCloseButton.text:Point("CENTER", BattlefieldMinimapCloseButton, "CENTER", 0, 1)
	BattlefieldMinimapCloseButton:SetFrameLevel(35)

	BattlefieldMinimap:EnableMouse(true)
	BattlefieldMinimap:SetMovable(true)

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

	BattlefieldMinimap:SetScript("OnMouseDown", function(self, btn)
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