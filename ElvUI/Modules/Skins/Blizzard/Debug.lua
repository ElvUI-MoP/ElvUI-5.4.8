local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.debug then return end

	ScriptErrorsFrame:SetParent(E.UIParent)
	ScriptErrorsFrame:SetTemplate("Transparent")

	S:HandleScrollBar(ScriptErrorsFrameScrollFrameScrollBar)

	S:HandleCloseButton(ScriptErrorsFrameClose)

	ScriptErrorsFrameScrollFrameText:FontTemplate(nil, 13)

	ScriptErrorsFrameScrollFrame:CreateBackdrop()
	ScriptErrorsFrameScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -3)
	ScriptErrorsFrameScrollFrame:SetFrameLevel(ScriptErrorsFrameScrollFrame:GetFrameLevel() + 2)

	EventTraceFrame:SetTemplate("Transparent")
	S:HandleSliderFrame(EventTraceFrameScroll)

	local texs = {
		"TopLeft",
		"TopRight",
		"Top",
		"BottomLeft",
		"BottomRight",
		"Bottom",
		"Left",
		"Right",
		"TitleBG",
		"DialogBG"
	}

	for i = 1, #texs do
		_G["ScriptErrorsFrame"..texs[i]]:SetTexture(nil)
		_G["EventTraceFrame"..texs[i]]:SetTexture(nil)
	end

	for i = 1, ScriptErrorsFrame:GetNumChildren() do
		local child = select(i, ScriptErrorsFrame:GetChildren())
		if child:GetObjectType() == "Button" and not child:GetName() then
			S:HandleButton(child)
		end
	end

	if E.private.skins.blizzard.tooltip then
		FrameStackTooltip:HookScript("OnShow", function(self)
			self:SetTemplate("Transparent")
			self:SetBackdropBorderColor(unpack(E.media.bordercolor))
			self:SetBackdropColor(unpack(E.media.backdropfadecolor))
		end)

		EventTraceTooltip:HookScript("OnShow", function(self)
			self:SetTemplate("Transparent")
			self:SetBackdropBorderColor(unpack(E.media.bordercolor))
			self:SetBackdropColor(unpack(E.media.backdropfadecolor))
		end)
	end

	-- FrameStack Highlight
	CreateFrame("Frame", "FrameStackHighlight")
	FrameStackHighlight:SetFrameStrata("TOOLTIP")
	FrameStackHighlight.texture = FrameStackHighlight:CreateTexture(nil, "BORDER")
	FrameStackHighlight.texture:SetAllPoints()
	FrameStackHighlight.texture:SetTexture(0, 1, 0, 0.4)

	hooksecurefunc("FrameStackTooltip_Toggle", function()
		if not FrameStackTooltip:IsVisible() then
			FrameStackHighlight:Hide()
		end
	end)

	local lastUpdate = 0
	FrameStackTooltip:HookScript("OnUpdate", function(_, elapsed)
		lastUpdate = lastUpdate - elapsed

		if lastUpdate <= 0 then
			lastUpdate = FRAMESTACK_UPDATE_TIME

			local highlightFrame = GetMouseFocus()
			FrameStackHighlight:ClearAllPoints()

			if highlightFrame and highlightFrame ~= _G["WorldFrame"] then
				FrameStackHighlight:Point("BOTTOMLEFT", highlightFrame)
				FrameStackHighlight:Point("TOPRIGHT", highlightFrame)

				FrameStackHighlight:Show()
			else
				FrameStackHighlight:Hide()
			end
		end
	end)

	S:HandleCloseButton(EventTraceFrameCloseButton)
end

S:AddCallbackForAddon("Blizzard_DebugTools", "SkinDebugTools", LoadSkin)