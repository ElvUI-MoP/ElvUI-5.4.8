local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local unpack, select = unpack, select
local find = string.find

local hooksecurefunc = hooksecurefunc
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor

local C_LootHistory_GetNumItems = C_LootHistory.GetNumItems

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lootHistory then return end

	LootHistoryFrame:StripTextures()
	LootHistoryFrame:SetTemplate("Transparent")

	LootHistoryFrameScrollFrame:StripTextures()

	LootHistoryFrame.ResizeButton:StripTextures()
	LootHistoryFrame.ResizeButton:SetTemplate("Default", true)
	LootHistoryFrame.ResizeButton:HookScript("OnEnter", S.SetModifiedBackdrop)
	LootHistoryFrame.ResizeButton:HookScript("OnLeave", S.SetOriginalBackdrop)
	LootHistoryFrame.ResizeButton:Width(LootHistoryFrame:GetWidth())
	LootHistoryFrame.ResizeButton:Height(19)
	LootHistoryFrame.ResizeButton:ClearAllPoints()
	LootHistoryFrame.ResizeButton:Point("TOP", LootHistoryFrame, "BOTTOM", 0, -2)

	LootHistoryFrame.ResizeButton.icon = LootHistoryFrame.ResizeButton:CreateTexture(nil, "ARTWORK")
	LootHistoryFrame.ResizeButton.icon:Size(20, 17)
	LootHistoryFrame.ResizeButton.icon:Point("CENTER")
	LootHistoryFrame.ResizeButton.icon:SetTexture(E.Media.Textures.ArrowUp)

	LootHistoryFrame.ScrollFrame:CreateBackdrop("Transparent")
	LootHistoryFrame.ScrollFrame.backdrop:Point("TOPLEFT", -1, 0)
	LootHistoryFrame.ScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -3)

	S:HandleScrollBar(LootHistoryFrameScrollFrameScrollBar)
	LootHistoryFrameScrollFrameScrollBar:ClearAllPoints()
	LootHistoryFrameScrollFrameScrollBar:Point("TOPRIGHT", LootHistoryFrame.ScrollFrame, 21, -18)
	LootHistoryFrameScrollFrameScrollBar:Point("BOTTOMRIGHT", LootHistoryFrame.ScrollFrame, 0, 15)

	S:HandleCloseButton(LootHistoryFrame.CloseButton, LootHistoryFrame)

	hooksecurefunc("LootHistoryFrame_FullUpdate", function()
		for i = 1, C_LootHistory_GetNumItems() do
			local frame = LootHistoryFrame.itemFrames[i]

			if not frame.isSkinned then
				local tex = frame.Icon:GetTexture()

				frame:StripTextures()
				frame:CreateBackdrop()
				frame.backdrop:SetOutside(frame.Icon)

				S:HandleButtonHighlight(frame, true)

				frame.Icon:SetTexture(tex)
				frame.Icon:SetTexCoord(unpack(E.TexCoords))
				frame.Icon:SetParent(frame.backdrop)

				frame.ToggleButton:Point("LEFT", 2, 0)

				frame.ToggleButton:SetNormalTexture(E.Media.Textures.Plus)
				frame.ToggleButton.SetNormalTexture = E.noop
				frame.ToggleButton:GetNormalTexture():Size(18)

				frame.ToggleButton:SetPushedTexture(E.Media.Textures.Plus)
				frame.ToggleButton.SetPushedTexture = E.noop
				frame.ToggleButton:GetPushedTexture():Size(18)

				frame.ToggleButton:SetDisabledTexture(E.Media.Textures.Plus)
				frame.ToggleButton.SetDisabledTexture = E.noop
				frame.ToggleButton:GetDisabledTexture():Size(18)

				frame.ToggleButton:SetHighlightTexture("")
				frame.ToggleButton.SetHighlightTexture = E.noop

				hooksecurefunc(frame.ToggleButton, "SetNormalTexture", function(self, texture)
					local normal, pushed = self:GetNormalTexture(), self:GetPushedTexture()

					if find(texture, "MinusButton") then
						normal:SetTexture(E.Media.Textures.Minus)
						pushed:SetTexture(E.Media.Textures.Minus)
					elseif find(texture, "PlusButton") then
						normal:SetTexture(E.Media.Textures.Plus)
						pushed:SetTexture(E.Media.Textures.Plus)
					else
						normal:SetTexture()
						pushed:SetTexture()
					end
				end)

				frame.isSkinned = true
			end

			local quality = select(3, GetItemInfo(frame.itemLink))
			if quality then
				local r, g, b = GetItemQualityColor(quality)
				frame.backdrop:SetBackdropBorderColor(r, g, b)
				frame.handledHighlight:SetVertexColor(r, g, b)
			else
				frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				frame.handledHighlight:SetVertexColor(1, 1, 1)
			end
		end
	end)
end

S:AddCallback("LootHistory", LoadSkin)