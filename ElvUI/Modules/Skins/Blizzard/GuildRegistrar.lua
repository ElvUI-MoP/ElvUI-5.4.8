local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local select = select

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.guildregistrar then return end

	GuildRegistrarFrame:StripTextures(true)
	GuildRegistrarFrame:SetTemplate("Transparent")

	GuildRegistrarFrameInset:Kill()
	GuildRegistrarGreetingFrame:StripTextures()

	GuildRegistrarFrameEditBox:StripTextures()
	S:HandleEditBox(GuildRegistrarFrameEditBox)
	GuildRegistrarFrameEditBox:Height(20)

	for i = 1, GuildRegistrarFrameEditBox:GetNumRegions() do
		local region = select(i, GuildRegistrarFrameEditBox:GetRegions())
		if region and region:GetObjectType() == "Texture" then
			if (region:GetTexture() == [[Interface\ChatFrame\UI-ChatInputBorder-Left]]) or (region:GetTexture() == [[Interface\ChatFrame\UI-ChatInputBorder-Right]]) then
				region:Kill()
			end
		end
	end

	S:HandleButton(GuildRegistrarFrameGoodbyeButton)
	S:HandleButton(GuildRegistrarFrameCancelButton)
	S:HandleButton(GuildRegistrarFramePurchaseButton)

	S:HandleCloseButton(GuildRegistrarFrameCloseButton)

	for i = 1, 2 do
		local button = _G["GuildRegistrarButton"..i]

		S:HandleButtonHighlight(button)

		button:GetFontString():SetTextColor(1, 1, 1)
	end

	GuildRegistrarPurchaseText:SetTextColor(1, 1, 1)
	AvailableServicesText:SetTextColor(1, 0.80, 0.10)
end

S:AddCallback("GuildRegistrar", LoadSkin)