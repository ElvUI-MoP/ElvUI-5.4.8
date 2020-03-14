local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.movepad then return end

	MovePadFrame:StripTextures()
	MovePadFrame:SetTemplate("Transparent")

	S:HandleButton(MovePadStrafeLeft)
	S:HandleButton(MovePadStrafeRight)
	S:HandleButton(MovePadForward)
	S:HandleButton(MovePadBackward)
	S:HandleButton(MovePadJump)

	MovePadLock:SetBackdrop(nil)
	MovePadLock:GetNormalTexture():SetDesaturated(true)
	MovePadLock:GetPushedTexture():SetDesaturated(true)
	MovePadLock:GetCheckedTexture():SetDesaturated(true)
	MovePadLock:GetHighlightTexture():SetDesaturated(true)
	MovePadLock:Point("BOTTOMRIGHT", 5, -5)
end

S:AddCallbackForAddon("Blizzard_MovePad", "MovePad", LoadSkin)