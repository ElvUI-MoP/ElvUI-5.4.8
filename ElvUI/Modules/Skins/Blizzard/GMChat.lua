local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")
local LSM = E.Libs.LSM

local _G = _G
local unpack = unpack

local function LoadChatSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gmchat then return end

	GMChatFrame:StripTextures()
	GMChatFrame:CreateBackdrop("Transparent")
	GMChatFrame.backdrop:Point("TOPLEFT", -2, 6)
	GMChatFrame.backdrop:Point("BOTTOMRIGHT", 2, -6)
	GMChatFrame:SetClampRectInsets(-2, 2, 33, -55)
	GMChatFrame:Size(LeftChatPanel:GetWidth() - 4, 120)
	GMChatFrame:Point("BOTTOMLEFT", LeftChatPanel, "TOPLEFT", 2, 30)
	GMChatFrame:EnableMouseWheel(true)

	GMChatTab:StripTextures()
	GMChatTab:SetTemplate("Default", true)
	GMChatTab:ClearAllPoints()
	GMChatTab:Point("TOPLEFT", GMChatFrame, -2, 30)
	GMChatTab:Point("BOTTOMRIGHT", GMChatFrame, 2, 127)

	GMChatTabText:Point("LEFT", GMChatTab, 8, 0)
	GMChatTabText:FontTemplate(LSM:Fetch("font", E.db.chat.tabFont), E.db.chat.tabFontSize, E.db.chat.tabFontOutline)
	GMChatTabText:SetTextColor(unpack(E.media.rgbvaluecolor))

	GMChatFrameEditBoxLeft:Kill()
	GMChatFrameEditBoxRight:Kill()
	GMChatFrameEditBoxMid:Kill()
	GMChatFrameEditBoxFocusLeft:Kill()
	GMChatFrameEditBoxFocusRight:Kill()
	GMChatFrameEditBoxFocusMid:Kill()
	GMChatFrameEditBox:SetTemplate()
	GMChatFrameEditBox:ClearAllPoints()
	GMChatFrameEditBox:Point("TOPLEFT", GMChatFrame, -2, -127)
	GMChatFrameEditBox:Point("BOTTOMRIGHT", GMChatFrame, 2, -29)

	GMChatFrameButtonFrame:Kill()

	GMChatFrameCloseButton:Point("TOPRIGHT", GMChatTab, 4, 5)
	S:HandleCloseButton(GMChatFrameCloseButton)

	GMChatFrameResizeButton:SetNormalTexture(nil)

	local numScrollMessages = E.db.chat.numScrollMessages or 3
	GMChatFrame:SetScript("OnMouseWheel", function(self, delta)
		if delta < 0 then
			if IsShiftKeyDown() then
				self:ScrollToBottom()
			else
				for i = 1, numScrollMessages do
					self:ScrollDown()
				end
			end
		elseif delta > 0 then
			if IsShiftKeyDown() then
				self:ScrollToTop()
			else
				for i = 1, numScrollMessages do
					self:ScrollUp()
				end
			end
		end
	end)

	GMChatStatusFrameBorderLeft:Kill()
	GMChatStatusFrameBorderRight:Kill()
	GMChatStatusFrameBorderMid:Kill()
	GMChatStatusFrameGlowLeft:Kill()
	GMChatStatusFrameGlowRight:Kill()
	GMChatStatusFrameGlowMid:Kill()

	GMChatStatusFrame:SetTemplate("Transparent")
	GMChatStatusFrame:HookScript("OnEnter", S.SetModifiedBackdrop)
	GMChatStatusFrame:HookScript("OnLeave", S.SetOriginalBackdrop)

	GMChatStatusFrameBorderLeft:Point("LEFT", GMChatStatusFrame, "LEFT", -17, 20)
	GMChatStatusFrameTitleText:Point("TOPLEFT", GMChatStatusFrameBorderLeft, "TOPRIGHT", -20, -45)
	GMChatStatusFrameDescription:Point("TOPLEFT", GMChatStatusFrameTitleText, "BOTTOMLEFT", -20, -10)

	GMChatStatusFrame:HookScript("OnShow", function(self)
		if TicketStatusFrame and TicketStatusFrame:IsShown() then
			self:Point("TOPLEFT", TicketStatusFrame, "BOTTOMLEFT", 0, 1)
		else
			self:SetAllPoints(TicketStatusFrame)
		end
	end)

	TicketStatusFrame:HookScript("OnShow", function(self)
		GMChatStatusFrame:Point("TOPLEFT", self, "BOTTOMLEFT", 0, 1)
	end)
	TicketStatusFrame:HookScript("OnHide", function(self)
		GMChatStatusFrame:SetAllPoints(self)
	end)
end

local function LoadSurveySkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gmchat then return end

	GMSurveyFrame:StripTextures()
	GMSurveyFrame:CreateBackdrop("Transparent")
	GMSurveyFrame.backdrop:Point("TOPLEFT", 4, 4)
	GMSurveyFrame.backdrop:Point("BOTTOMRIGHT", -44, 10)

	GMSurveyHeader:StripTextures()
	S:HandleCloseButton(GMSurveyCloseButton, GMSurveyFrame.backdrop)

	GMSurveyScrollFrame:StripTextures()
	S:HandleScrollBar(GMSurveyScrollFrameScrollBar)

	GMSurveyCancelButton:Point("BOTTOMLEFT", 19, 18)
	S:HandleButton(GMSurveyCancelButton)

	GMSurveySubmitButton:Point("BOTTOMRIGHT", -57, 18)
	S:HandleButton(GMSurveySubmitButton)

	for i = 1, 7 do
		local frame = _G["GMSurveyQuestion"..i]
		frame:StripTextures()
		frame:SetTemplate("Transparent")
	end

	GMSurveyCommentFrame:StripTextures()
	GMSurveyCommentFrame:SetTemplate("Transparent")
end

S:AddCallbackForAddon("Blizzard_GMChatUI", "GMChatFrame", LoadChatSkin)
S:AddCallbackForAddon("Blizzard_GMSurveyUI", "GMSurveyFrame", LoadSurveySkin)