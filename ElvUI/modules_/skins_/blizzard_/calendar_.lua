local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local ipairs, unpack = ipairs, unpack

local CLASS_SORT_ORDER = CLASS_SORT_ORDER
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.calendar ~= true then return end

	local CalendarFrame = _G["CalendarFrame"]
	CalendarFrame:StripTextures()
	CalendarFrame:SetTemplate("Transparent")

	S:HandleCloseButton(CalendarCloseButton)
	CalendarCloseButton:Point("TOPRIGHT", 2, 2)

	CalendarFrame:EnableMouseWheel(true)
	CalendarFrame:SetScript("OnMouseWheel", function(_, value)
		if value > 0 then
			if CalendarPrevMonthButton:IsEnabled() == 1 then
				CalendarPrevMonthButton_OnClick()
			end
		else
			if CalendarNextMonthButton:IsEnabled() == 1 then
				CalendarNextMonthButton_OnClick()
			end
		end
	end)

	S:HandleNextPrevButton(CalendarPrevMonthButton)
	S:HandleNextPrevButton(CalendarNextMonthButton)

	do --Handle drop down button, this one is different than the others
		local frame = CalendarFilterFrame
		local button = CalendarFilterButton

		frame:StripTextures()
		frame:Width(155)

		_G[frame:GetName().."Text"]:ClearAllPoints()
		_G[frame:GetName().."Text"]:Point("RIGHT", button, "LEFT", -2, 0)

		button:ClearAllPoints()
		button:Point("RIGHT", frame, "RIGHT", -10, 3)
		button.SetPoint = E.noop

		S:HandleNextPrevButton(button, true)

		frame:CreateBackdrop("Default")
		frame.backdrop:Point("TOPLEFT", 20, 2)
		frame.backdrop:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
	end

	--backdrop
	local bg = CreateFrame("Frame", "CalendarFrameBackdrop", CalendarFrame)
	bg:SetTemplate("Default")
	bg:Point("TOPLEFT", 10, -72)
	bg:Point("BOTTOMRIGHT", -9, 3)

	CalendarContextMenu:SetTemplate("Transparent")
	CalendarContextMenu.SetBackdropColor = E.noop
	CalendarContextMenu.SetBackdropBorderColor = E.noop
	CalendarContextMenuButton1:StyleButton()

	for i = 1, 7 do
		_G["CalendarContextMenuButton"..i]:StyleButton()
	end

	for i = 1, 42 do
		local button = _G["CalendarDayButton"..i]
		local eventTexture = _G["CalendarDayButton"..i.."EventTexture"]
		local overlayFrame = _G["CalendarDayButton"..i.."OverlayFrame"]

		button:SetFrameLevel(button:GetFrameLevel() + 1)
		button:Size(91 - E.Border)
		button:StripTextures()
		button:CreateBackdrop("Default")
		button:GetHighlightTexture():SetInside()
		button:GetHighlightTexture():SetTexture(1, 1, 1, 0.10)

		eventTexture:SetInside()
		overlayFrame:SetInside()

		for j = 1, 4 do
			local EventButton = _G["CalendarDayButton"..i.."EventButton"..j]
			EventButton:StripTextures()
			EventButton:StyleButton()
		end

		button:ClearAllPoints()

		if i == 1 then
			button:Point("TOPLEFT", CalendarWeekday1Background, "BOTTOMLEFT", E.Spacing, 0)
		elseif mod(i, 7) == 1 then
			button:Point("TOPLEFT", _G["CalendarDayButton"..(i - 7)], "BOTTOMLEFT", 0, -E.Border)
		else
			button:Point("TOPLEFT", _G["CalendarDayButton"..(i - 1)], "TOPRIGHT", E.Border, 0)
		end
	end

	CalendarTodayFrame:StripTextures()
	CalendarTodayFrame:CreateBackdrop("Default")
	CalendarTodayFrame:Size(CalendarDayButton1:GetWidth(), CalendarDayButton1:GetHeight())
	CalendarTodayFrame:SetBackdropBorderColor(0, 0.44, .87, 1)
	CalendarTodayFrame:SetBackdropColor(0, 0, 0, 0)
	CalendarTodayFrame:HookScript("OnUpdate", function(self) self:SetAlpha(CalendarTodayTextureGlow:GetAlpha()) end)
	CalendarTodayFrame.backdrop:SetFrameLevel(CalendarTodayFrame.backdrop:GetFrameLevel() + 1)
	CalendarTodayFrame.backdrop:SetBackdropBorderColor(0, 0.44, .87, 1)
	CalendarTodayFrame.backdrop:SetBackdropColor(0, 0, 0, 0)
	CalendarTodayFrame.backdrop:CreateShadow()

	--Create Event Frame
	CalendarCreateEventFrame:StripTextures()
	CalendarCreateEventFrame:SetTemplate("Transparent")
	CalendarCreateEventFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 1, 0)

	CalendarCreateEventTitleFrame:StripTextures()

	S:HandleButton(CalendarCreateEventCreateButton, true)
	S:HandleButton(CalendarCreateEventMassInviteButton, true)
	S:HandleButton(CalendarCreateEventInviteButton, true)

	CalendarCreateEventInviteButton:Point("TOPLEFT", CalendarCreateEventInviteEdit, "TOPRIGHT", 4, 1)
	CalendarCreateEventInviteEdit:Width(CalendarCreateEventInviteEdit:GetWidth() - 2)

	CalendarCreateEventInviteList:StripTextures()
	CalendarCreateEventInviteList:SetTemplate("Transparent",true)

	S:HandleEditBox(CalendarCreateEventInviteEdit)
	S:HandleEditBox(CalendarCreateEventTitleEdit)

	CalendarCreateEventTitleEdit:ClearAllPoints()
	CalendarCreateEventTitleEdit:Point("TOPLEFT", 23, -90)
	CalendarCreateEventTitleEdit:Size(170, 20)

	S:HandleDropDownBox(CalendarCreateEventTypeDropDown, 120)
	CalendarCreateEventTypeDropDown:ClearAllPoints()
	CalendarCreateEventTypeDropDown:Point("TOPRIGHT", -10, -87)

	CalendarCreateEventDescriptionContainer:StripTextures()
	CalendarCreateEventDescriptionContainer:SetTemplate("Default")

	S:HandleCloseButton(CalendarCreateEventCloseButton)

	S:HandleCheckBox(CalendarCreateEventLockEventCheck)

	S:HandleDropDownBox(CalendarCreateEventHourDropDown, 68)
	S:HandleDropDownBox(CalendarCreateEventMinuteDropDown, 68)
	S:HandleDropDownBox(CalendarCreateEventAMPMDropDown, 68)
	S:HandleDropDownBox(CalendarCreateEventRepeatOptionDropDown, 120)
	CalendarCreateEventIcon:SetTexCoord(unpack(E.TexCoords))
	CalendarCreateEventIcon.SetTexCoord = E.noop

	CalendarCreateEventInviteListSection:StripTextures()

	S:HandleScrollBar(CalendarCreateEventDescriptionScrollFrameScrollBar)
	S:HandleScrollBar(CalendarCreateEventInviteListScrollFrameScrollBar)

	CalendarClassButtonContainer:HookScript("OnShow", function()
		for i, class in ipairs(CLASS_SORT_ORDER) do
			local button = _G["CalendarClassButton"..i]
			button:StripTextures()
			button:CreateBackdrop("Default")
			button:Size(23)

			local tcoords = CLASS_ICON_TCOORDS[class]
			local buttonIcon = button:GetNormalTexture()
			buttonIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
			buttonIcon:SetTexCoord(tcoords[1] + 0.015, tcoords[2] - 0.02, tcoords[3] + 0.018, tcoords[4] - 0.02)
		end

		CalendarClassButton1:Point("TOPLEFT", E.PixelMode and 2 or 5, 0)

		CalendarClassTotalsButton:StripTextures()
		CalendarClassTotalsButton:CreateBackdrop("Default")
		CalendarClassTotalsButton:Size(23)
	end)

	CalendarInviteStatusContextMenu:StripTextures()
	CalendarInviteStatusContextMenu:SetTemplate("Transparent")

	--Texture Picker Frame
	CalendarTexturePickerFrame:StripTextures()
	CalendarTexturePickerFrame:SetTemplate("Transparent")
	CalendarTexturePickerFrame:Point("TOPRIGHT", CalendarFrame, "TOPRIGHT", 640, 0)

	CalendarTexturePickerScrollFrame:CreateBackdrop("Transparent")

	CalendarTexturePickerTitleFrame:StripTextures()

	for i = 1, 16 do
		_G["CalendarTexturePickerScrollFrameButton"..i]:StyleButton()
	end

	S:HandleScrollBar(CalendarTexturePickerScrollBar)
	CalendarTexturePickerScrollBar:Point("RIGHT", 28, 0)

	S:HandleButton(CalendarTexturePickerAcceptButton, true)
	S:HandleButton(CalendarTexturePickerCancelButton, true)
	S:HandleButton(CalendarCreateEventInviteButton, true)
	S:HandleButton(CalendarCreateEventRaidInviteButton, true)

	CalendarTexturePickerAcceptButton:Width(110)
	CalendarTexturePickerAcceptButton:ClearAllPoints()
	CalendarTexturePickerAcceptButton:Point("RIGHT", CalendarTexturePickerCancelButton, "LEFT", -20, 0)

	CalendarTexturePickerCancelButton:Width(110)
	CalendarTexturePickerCancelButton:ClearAllPoints()
	CalendarTexturePickerCancelButton:Point("BOTTOMRIGHT", CalendarTexturePickerFrame, "BOTTOMRIGHT", -30, 7)

	--Mass Invite Frame
	CalendarMassInviteFrame:StripTextures()
	CalendarMassInviteFrame:SetTemplate("Transparent")
	CalendarMassInviteFrame:ClearAllPoints()
	CalendarMassInviteFrame:Point("TOPLEFT", CalendarCreateEventFrame, "TOPRIGHT", 25, 0)

	CalendarMassInviteTitleFrame:StripTextures()

	S:HandleCloseButton(CalendarMassInviteCloseButton)

	S:HandleButton(CalendarMassInviteGuildAcceptButton)

	S:HandleDropDownBox(CalendarMassInviteGuildRankMenu, 130)

	S:HandleEditBox(CalendarMassInviteGuildMinLevelEdit)
	S:HandleEditBox(CalendarMassInviteGuildMaxLevelEdit)

	--Raid View
	CalendarViewRaidFrame:StripTextures()
	CalendarViewRaidFrame:SetTemplate("Transparent")
	CalendarViewRaidFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 1, 0)

	CalendarViewRaidTitleFrame:StripTextures()

	S:HandleCloseButton(CalendarViewRaidCloseButton)

	--Holiday View
	CalendarViewHolidayFrame:StripTextures(true)
	CalendarViewHolidayFrame:SetTemplate("Transparent")
	CalendarViewHolidayFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 1, 0)

	CalendarViewHolidayTitleFrame:StripTextures()

	S:HandleCloseButton(CalendarViewHolidayCloseButton)

	-- Event View
	CalendarViewEventFrame:StripTextures()
	CalendarViewEventFrame:SetTemplate("Transparent")
	CalendarViewEventFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 1, 0)

	CalendarViewEventTitleFrame:StripTextures()

	CalendarViewEventDescriptionContainer:StripTextures()
	CalendarViewEventDescriptionContainer:SetTemplate("Transparent")

	CalendarViewEventInviteList:StripTextures()
	CalendarViewEventInviteList:SetTemplate("Transparent")

	CalendarViewEventInviteListSection:StripTextures()

	S:HandleCloseButton(CalendarViewEventCloseButton)

	S:HandleScrollBar(CalendarViewEventInviteListScrollFrameScrollBar)
	S:HandleScrollBar(CalendarViewEventDescriptionScrollFrameScrollBar)

	S:HandleButton(CalendarViewEventAcceptButton)
	S:HandleButton(CalendarViewEventTentativeButton)
	S:HandleButton(CalendarViewEventRemoveButton)
	S:HandleButton(CalendarViewEventDeclineButton)

	--Event Picker Frame
	CalendarEventPickerFrame:StripTextures()
	CalendarEventPickerFrame:SetTemplate("Transparent")

	CalendarEventPickerTitleFrame:StripTextures()

	S:HandleScrollBar(CalendarEventPickerScrollBar)

	S:HandleButton(CalendarEventPickerCloseButton, true)
end

S:AddCallbackForAddon("Blizzard_Calendar", "Calendar", LoadSkin)