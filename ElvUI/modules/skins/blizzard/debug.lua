local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local GetCVar = GetCVar

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.debug ~= true then return end

	ScriptErrorsFrame:SetParent(E.UIParent)
	ScriptErrorsFrame:SetTemplate("Transparent")

	S:HandleScrollBar(ScriptErrorsFrameScrollFrameScrollBar)

	S:HandleCloseButton(ScriptErrorsFrameClose)

	ScriptErrorsFrameScrollFrameText:FontTemplate(nil, 13)

	ScriptErrorsFrameScrollFrame:CreateBackdrop("Default")
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
			if not self.template then
				self:SetTemplate("Transparent")
			end
		end)

		EventTraceTooltip:HookScript("OnShow", function(self)
			if not self.template then
				self:SetTemplate("Transparent", nil, true) --ignore updates
			else
				self:SetBackdropBorderColor(unpack(E.media.bordercolor))
				self:SetBackdropColor(unpack(E.media.backdropfadecolor))
			end
		end)
	end

	S:HandleCloseButton(EventTraceFrameCloseButton)
end

S:AddCallbackForAddon("Blizzard_DebugTools", "SkinDebugTools", LoadSkin)