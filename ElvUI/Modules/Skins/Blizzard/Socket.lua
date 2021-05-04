local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local GetNumSockets = GetNumSockets
local GetSocketTypes = GetSocketTypes
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.socket then return end

	ITEM_SOCKETING_DESCRIPTION_MIN_WIDTH = 278

	ItemSocketingFrame:StripTextures()
	ItemSocketingFrame:SetTemplate("Transparent")
	ItemSocketingFrame:Height(390)

	ItemSocketingFrameInset:Kill()
	ItemSocketingFramePortrait:Kill()

	ItemSocketingScrollFrame:StripTextures()
	ItemSocketingScrollFrame:CreateBackdrop("Transparent")
	ItemSocketingScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -2)
	ItemSocketingScrollFrame:Height(269)
	ItemSocketingScrollFrame:Point("TOPLEFT", 8, -30)

	S:HandleScrollBar(ItemSocketingScrollFrameScrollBar, 2)
	ItemSocketingScrollFrameScrollBar:Point("TOPLEFT", ItemSocketingScrollFrame, "TOPRIGHT", 7, -18)
	ItemSocketingScrollFrameScrollBar:Point("BOTTOMLEFT", ItemSocketingScrollFrame, "BOTTOMRIGHT", 7, 19)

	S:HandleButton(ItemSocketingSocketButton)
	ItemSocketingSocketButton:Point("BOTTOMRIGHT", -7, 7)

	S:HandleCloseButton(ItemSocketingFrameCloseButton)

	for i = 1, MAX_NUM_SOCKETS do
		local button = _G["ItemSocketingSocket"..i]
		local icon = _G["ItemSocketingSocket"..i.."IconTexture"]
		local shine = _G["ItemSocketingSocket"..i.."Shine"]

		button:StripTextures()
		button:SetTemplate("Transparent")
		button:StyleButton()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		shine:Size(40)
		shine:Point("CENTER")

		_G["ItemSocketingSocket"..i.."BracketFrame"]:Kill()
		_G["ItemSocketingSocket"..i.."Background"]:Kill()
	end

	hooksecurefunc("ItemSocketingFrame_Update", function()
		local numSockets = GetNumSockets()
		for i = 1, numSockets do
			local button = _G["ItemSocketingSocket"..i]
			local color = GEM_TYPE_INFO[GetSocketTypes(i)]

			button:SetBackdropColor(color.r, color.g, color.b, 0.15)
			button:SetBackdropBorderColor(color.r, color.g, color.b)
		end

		if numSockets == 3 then
			ItemSocketingSocket1:Point("BOTTOM", ItemSocketingFrame, "BOTTOM", -80, 38)
		elseif numSockets == 2 then
			ItemSocketingSocket1:Point("BOTTOM", ItemSocketingFrame, "BOTTOM", -36, 38)
		else
			ItemSocketingSocket1:Point("BOTTOM", ItemSocketingFrame, "BOTTOM", 0, 38)
		end
	end)

	hooksecurefunc(ItemSocketingScrollFrame, "SetWidth", function(self, width)
		if width == 269 then
			self:Width(300)
		elseif width == 297 then
			self:Width(321)
		end
	end)
end

S:AddCallbackForAddon("Blizzard_ItemSocketingUI", "ItemSocket", LoadSkin)