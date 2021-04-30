local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, assert, pairs, ipairs, select, type = unpack, assert, pairs, ipairs, select, type
local strfind = strfind

local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local UIPanelWindows = UIPanelWindows
local UpdateUIPanelPositions = UpdateUIPanelPositions
local hooksecurefunc = hooksecurefunc

S.allowBypass = {}
S.addonCallbacks = {}
S.nonAddonCallbacks = {["CallPriority"] = {}}

S.Blizzard = {}
S.Blizzard.Regions = {
	"Left",
	"Middle",
	"Right",
	"Mid",
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"TopLeft",
	"TopRight",
	"BottomLeft",
	"BottomRight",
	"TopMiddle",
	"MiddleLeft",
	"MiddleRight",
	"BottomMiddle",
	"MiddleMiddle",
	"TabSpacer",
	"TabSpacer1",
	"TabSpacer2",
	"_RightSeparator",
	"_LeftSeparator",
	"Cover",
	"Border",
	"Background",
	-- EditBox
	"TopTex",
	"TopLeftTex",
	"TopRightTex",
	"LeftTex",
	"BottomTex",
	"BottomLeftTex",
	"BottomRightTex",
	"RightTex",
	"MiddleTex",
}

-- Depends on the arrow texture to be up by default.
S.ArrowRotation = {
	["up"] = 0,
	["down"] = 3.14,
	["left"] = 1.57,
	["right"] = -1.57
}

function S:SetModifiedBackdrop()
	if self:IsEnabled() then
		if self.backdrop then self = self.backdrop end
		self:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	end
end

function S:SetOriginalBackdrop()
	if self:IsEnabled() then
		if self.backdrop then self = self.backdrop end
		self:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

local handleCloseButtonOnEnter = function(btn) if btn.Texture then btn.Texture:SetVertexColor(unpack(E.media.rgbvaluecolor)) end end
local handleCloseButtonOnLeave = function(btn) if btn.Texture then btn.Texture:SetVertexColor(1, 1, 1) end end

function S:HandleButton(button, strip, isDeclineButton, useCreateBackdrop, noSetTemplate)
	if button.isSkinned then return end
	assert(button, "doesn't exist!")

	local buttonName = button.GetName and button:GetName()

	if button.SetNormalTexture then button:SetNormalTexture("") end
	if button.SetHighlightTexture then button:SetHighlightTexture("") end
	if button.SetPushedTexture then button:SetPushedTexture("") end
	if button.SetDisabledTexture then button:SetDisabledTexture("") end

	if strip then button:StripTextures() end

	for _, region in pairs(S.Blizzard.Regions) do
		region = buttonName and _G[buttonName..region] or button[region]
		if region then
			region:SetAlpha(0)
		end
	end

	if isDeclineButton then
		if button.Icon then
			button.Icon:SetTexture(E.Media.Textures.Close)
		end
	end

	if useCreateBackdrop then
		button:CreateBackdrop("Default", true)
	elseif not noSetTemplate then
		button:SetTemplate("Default", true)
	end

	button:HookScript("OnEnter", S.SetModifiedBackdrop)
	button:HookScript("OnLeave", S.SetOriginalBackdrop)

	button.isSkinned = true
end

function S:HandleButtonHighlight(frame, override, r, g, b, a)
	local highlightTexture

	if override then
		highlightTexture = frame:CreateTexture(nil, "HIGHLIGHT")
		highlightTexture:SetAllPoints(frame)
		frame.HighlightTexture = highlightTexture
	else
		if frame.SetHighlightTexture and frame.GetHighlightTexture then
			highlightTexture = frame:GetHighlightTexture()
			highlightTexture:SetAllPoints(frame)
		elseif frame.SetTexture then
			highlightTexture = frame
			frame:SetAllPoints(frame:GetParent())
		elseif frame.HighlightTexture then
			highlightTexture = frame.HighlightTexture
		else
			highlightTexture = frame:CreateTexture(nil, "HIGHLIGHT")
			highlightTexture:SetAllPoints(frame)
			frame.HighlightTexture = highlightTexture
		end
	end

	highlightTexture:SetTexture(E.Media.Textures.Highlight)
	highlightTexture:SetVertexColor(r or 1, g or 1, b or 1, a or 0.35)
	highlightTexture:SetTexCoord(0, 1, 0, 1)
	highlightTexture.SetTexCoord = E.noop

	frame.handledHighlight = highlightTexture
end

function S:HandleFrameHighlight(frame, point)
	frame.highlightTexture = frame:CreateTexture(nil, "HIGHLIGHT")
	frame.highlightTexture:SetTexture(1, 1, 1, 0.35)
	frame.highlightTexture:SetInside(point or nil)
	frame.highlightTexture:Hide()

	frame:HookScript("OnEnter", function() frame.highlightTexture:Show() end)
	frame:HookScript("OnLeave", function() frame.highlightTexture:Hide() end)
end

local function GrabScrollBarElement(frame, element)
	local FrameName = frame:GetName()
	return frame[element] or FrameName and (_G[FrameName..element] or strfind(FrameName, element)) or nil
end

function S:HandleScrollBar(frame, thumbTrimY, thumbTrimX)
	if frame.backdrop then return end
	local parent = frame:GetParent()

	local ScrollUpButton = GrabScrollBarElement(frame, "ScrollUpButton") or GrabScrollBarElement(frame, "UpButton") or GrabScrollBarElement(frame, "ScrollUp") or GrabScrollBarElement(parent, "scrollUp")
	local ScrollDownButton = GrabScrollBarElement(frame, "ScrollDownButton") or GrabScrollBarElement(frame, "DownButton") or GrabScrollBarElement(frame, "ScrollDown") or GrabScrollBarElement(parent, "scrollDown")
	local Thumb = GrabScrollBarElement(frame, "ThumbTexture") or GrabScrollBarElement(frame, "thumbTexture") or frame.GetThumbTexture and frame:GetThumbTexture()

	frame:StripTextures()
	frame:CreateBackdrop()
	frame.backdrop:Point("TOPLEFT", ScrollUpButton or frame, ScrollUpButton and "BOTTOMLEFT" or "TOPLEFT", 0, -1)
	frame.backdrop:Point("BOTTOMRIGHT", ScrollDownButton or frame, ScrollUpButton and "TOPRIGHT" or "BOTTOMRIGHT", 0, 1)
	frame.backdrop:SetFrameLevel(frame.backdrop:GetFrameLevel() + 1)

	for _, Button in pairs({ScrollUpButton, ScrollDownButton}) do
		if Button then
			S:HandleNextPrevButton(Button)
		end
	end

	if Thumb and not Thumb.backdrop then
		Thumb:SetTexture()
		Thumb:CreateBackdrop(nil, true, true)

		if not thumbTrimY then thumbTrimY = 3 end
		if not thumbTrimX then thumbTrimX = 2 end
		Thumb.backdrop:Point("TOPLEFT", Thumb, "TOPLEFT", thumbTrimX, -thumbTrimY)
		Thumb.backdrop:Point("BOTTOMRIGHT", Thumb, "BOTTOMRIGHT", -thumbTrimX, thumbTrimY)
		Thumb.backdrop:SetFrameLevel(Thumb.backdrop:GetFrameLevel() + 2)
		Thumb.backdrop.backdropTexture:SetVertexColor(0.6, 0.6, 0.6)

		frame.Thumb = Thumb
	end
end

local tabs = {
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"Left",
	"Middle",
	"Right"
}

function S:HandleTab(tab)
	local name = tab:GetName()
	for _, object in pairs(tabs) do
		local tex = _G[name..object]
		if tex then
			tex:SetTexture(nil)
		end
	end

	if tab.GetHighlightTexture and tab:GetHighlightTexture() then
		tab:GetHighlightTexture():SetTexture(nil)
	else
		tab:StripTextures()
	end

	tab.backdrop = CreateFrame("Frame", nil, tab)
	tab.backdrop:SetTemplate()
	tab.backdrop:SetFrameLevel(tab:GetFrameLevel() - 1)
	tab.backdrop:Point("TOPLEFT", 10, E.PixelMode and -1 or -3)
	tab.backdrop:Point("BOTTOMRIGHT", -10, 3)
end

function S:HandleNextPrevButton(btn, arrowDir, color, noBackdrop, stipTexts)
	if btn.isSkinned then return end

	if not arrowDir then
		arrowDir = "down"
		local ButtonName = btn:GetName() and btn:GetName():lower()

		if ButtonName then
			if (strfind(ButtonName, "left") or strfind(ButtonName, "prev") or strfind(ButtonName, "decrement") or strfind(ButtonName, "backward") or strfind(ButtonName, "back")) then
				arrowDir = "left"
			elseif (strfind(ButtonName, "right") or strfind(ButtonName, "next") or strfind(ButtonName, "increment") or strfind(ButtonName, "forward")) then
				arrowDir = "right"
			elseif (strfind(ButtonName, "scrollup") or strfind(ButtonName, "upbutton") or strfind(ButtonName, "top") or strfind(ButtonName, "asc") or strfind(ButtonName, "home") or strfind(ButtonName, "maximize")) then
				arrowDir = "up"
			end
		end
	end

	btn:StripTextures()
	if not noBackdrop then
		S:HandleButton(btn)
	end

	if stipTexts then
		btn:StripTexts()
	end

	btn:SetNormalTexture(E.Media.Textures.ArrowUp)
	btn:SetPushedTexture(E.Media.Textures.ArrowUp)
	btn:SetDisabledTexture(E.Media.Textures.ArrowUp)

	local Normal, Disabled, Pushed = btn:GetNormalTexture(), btn:GetDisabledTexture(), btn:GetPushedTexture()

	if noBackdrop then
		btn:Size(20, 20)
		Disabled:SetVertexColor(0.5, 0.5, 0.5)
		btn.Texture = Normal
		btn:HookScript("OnEnter", handleCloseButtonOnEnter)
		btn:HookScript("OnLeave", handleCloseButtonOnLeave)
	else
		btn:Size(18, 18)
		Disabled:SetVertexColor(0.3, 0.3, 0.3)
	end

	Normal:SetInside()
	Pushed:SetInside()
	Disabled:SetInside()

	Normal:SetTexCoord(0, 1, 0, 1)
	Pushed:SetTexCoord(0, 1, 0, 1)
	Disabled:SetTexCoord(0, 1, 0, 1)

	Normal:SetRotation(S.ArrowRotation[arrowDir])
	Pushed:SetRotation(S.ArrowRotation[arrowDir])
	Disabled:SetRotation(S.ArrowRotation[arrowDir])

	Normal:SetVertexColor(unpack(color or {1, 1, 1}))

	btn.isSkinned = true
end

function S:HandleRotateButton(btn)
	btn:SetTemplate()
	btn:Size(btn:GetWidth() - 14, btn:GetHeight() - 14)

	local normal, pushed, highlight = btn:GetNormalTexture(), btn:GetPushedTexture(), btn:GetHighlightTexture()

	normal:SetInside()
	normal:SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)

	pushed:SetAllPoints(normal)
	pushed:SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)

	highlight:SetAllPoints(normal)
	highlight:SetTexture(1, 1, 1, 0.3)
end

function S:HandleEditBox(frame)
	if frame.backdrop then return end

	local EditBoxName = frame.GetName and frame:GetName()

	for _, Region in pairs(S.Blizzard.Regions) do
		if EditBoxName and _G[EditBoxName..Region] then
			_G[EditBoxName..Region]:SetAlpha(0)
		end
		if frame[Region] then
			frame[Region]:SetAlpha(0)
		end
	end

	frame:CreateBackdrop()
	frame.backdrop:SetFrameLevel(frame:GetFrameLevel())

	if EditBoxName then
		if strfind(EditBoxName, "Silver") or strfind(EditBoxName, "Copper") then
			frame.backdrop:Point("BOTTOMRIGHT", -12, -2)
		end
	end
end

function S:HandleDropDownBox(frame, width)
	if frame.backdrop then return end

	local FrameName = frame.GetName and frame:GetName()

	local button = FrameName and _G[FrameName.."Button"] or frame.Button
	local text = FrameName and _G[FrameName.."Text"] or frame.Text

	frame:StripTextures()
	frame:CreateBackdrop()
	frame.backdrop:SetFrameLevel(frame:GetFrameLevel())
	frame.backdrop:Point("TOPLEFT", 12, -6)
	frame.backdrop:Point("BOTTOMRIGHT", -12, 6)

	if width then
		frame:Width(width)
	end

	if text then
		local justifyH = text:GetJustifyH()
		local right = justifyH == "RIGHT"
		local left = justifyH == "LEFT"

		local a, _, c, d, e = text:GetPoint()
		text:ClearAllPoints()

		if right then
			text:Point("RIGHT", button or frame.backdrop, "LEFT", (right and -3) or 0, 0)
		elseif left then
			text:Point("RIGHT", button or frame.backdrop, "LEFT", (left and -8) or -1, 0)
		else
			text:Point(a, frame.backdrop, c, (left and 10) or d, e - 3)
		end

		text:Width(frame:GetWidth() / 1.4)
	end

	if button then
		S:HandleNextPrevButton(button, nil, {1, 0.8, 0})
		button:ClearAllPoints()
		button:Point("TOPRIGHT", -14, -8)
		button:Size(16, 16)
	end

	if frame.Icon then
		frame.Icon:Point("LEFT", 23, 0)
	end
end

function S:HandleCheckBox(frame, noBackdrop, noReplaceTextures, forceSaturation)
	if frame.isSkinned then return end
	assert(frame, "does not exist.")

	frame:StripTextures()
	frame.forceSaturation = forceSaturation

	if noBackdrop then
		frame:SetTemplate()
		frame:Size(16)
	else
		frame:CreateBackdrop()
		frame.backdrop:SetInside(nil, 4, 4)
	end

	if not noReplaceTextures then
		if frame.SetCheckedTexture then
			if E.private.skins.checkBoxSkin then
				frame:SetCheckedTexture(E.Media.Textures.Melli)

				local checkedTexture = frame:GetCheckedTexture()
				checkedTexture:SetVertexColor(1, 0.82, 0, 0.8)
				checkedTexture:SetInside(frame.backdrop)
			else
				frame:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

				if noBackdrop then
					frame:GetCheckedTexture():SetInside(nil, -4, -4)
				end
			end
		end

		if frame.SetDisabledCheckedTexture then
			if E.private.skins.checkBoxSkin then
				frame:SetDisabledCheckedTexture(E.Media.Textures.Melli)

				local disabledCheckedTexture = frame:GetDisabledCheckedTexture()
				disabledCheckedTexture:SetVertexColor(0.6, 0.6, 0.6, 0.8)
				disabledCheckedTexture:SetInside(frame.backdrop)
			else
				frame:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")

				if noBackdrop then
					frame:GetDisabledCheckedTexture():SetInside(nil, -4, -4)
				end
			end
		end

		if frame.SetDisabledTexture then
			if E.private.skins.checkBoxSkin then
				frame:SetDisabledTexture(E.Media.Textures.Melli)

				local disabledTexture = frame:GetDisabledTexture()
				disabledTexture:SetVertexColor(0.6, 0.6, 0.6, 0.8)
				disabledTexture:SetInside(frame.backdrop)
			else
				frame:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")

				if noBackdrop then
					frame:GetDisabledTexture():SetInside(nil, -4, -4)
				end
			end
		end

		frame:HookScript("OnDisable", function(checkbox)
			if not checkbox.SetDisabledTexture then return end

			if checkbox:GetChecked() then
				if E.private.skins.checkBoxSkin then
					checkbox:SetDisabledTexture(E.Media.Textures.Melli)
				else
					checkbox:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
				end
			else
				checkbox:SetDisabledTexture("")
			end
		end)

		hooksecurefunc(frame, "SetNormalTexture", function(checkbox, texPath)
			if texPath ~= "" then checkbox:SetNormalTexture("") end
		end)
		hooksecurefunc(frame, "SetPushedTexture", function(checkbox, texPath)
			if texPath ~= "" then checkbox:SetPushedTexture("") end
		end)
		hooksecurefunc(frame, "SetHighlightTexture", function(checkbox, texPath)
			if texPath ~= "" then checkbox:SetHighlightTexture("") end
		end)
		hooksecurefunc(frame, "SetCheckedTexture", function(checkbox, texPath)
			if texPath == E.Media.Textures.Melli or texPath == "Interface\\Buttons\\UI-CheckBox-Check" then return end
			if E.private.skins.checkBoxSkin then
				checkbox:SetCheckedTexture(E.Media.Textures.Melli)
			else
				checkbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
			end
		end)
	end

	frame.isSkinned = true
end

function S:HandleColorSwatch(frame, size)
	if frame.isSkinned then return end

	frame:StripTextures()
	frame:CreateBackdrop()
	frame.backdrop:SetFrameLevel(frame:GetFrameLevel())

	if size then
		frame:Size(size)
	end

	local normalTexture = frame:GetNormalTexture()
	normalTexture:SetTexture(E.media.blankTex)
	normalTexture:ClearAllPoints()
	normalTexture:SetInside(frame.backdrop)

	frame.isSkinned = true
end

function S:HandleRadioButton(Button)
	if Button.isSkinned then return end

	Button:CreateBackdrop("Transparent")
	Button.backdrop:Point("TOPLEFT", 2, -2)
	Button.backdrop:Point("BOTTOMRIGHT", -2, 2)

	Button:SetNormalTexture("")
	Button:SetDisabledTexture("")
	Button:SetCheckedTexture(E.Media.Textures.Melli)
	Button:SetHighlightTexture(E.Media.Textures.Melli)
	Button:SetDisabledCheckedTexture(E.Media.Textures.Melli)

	local Checked, Highlight, DisabledChecked = Button:GetCheckedTexture(), Button:GetHighlightTexture(), Button:GetDisabledCheckedTexture()

	Checked:SetVertexColor(unpack(E.media.rgbvaluecolor))
	Checked:SetInside(Button.backdrop)

	Highlight:SetVertexColor(1, 1, 1, 0.3)
	Highlight:SetInside(Button.backdrop)

	DisabledChecked:SetVertexColor(0.6, 0.6, 0.5, 0.8)
	DisabledChecked:SetInside(Button.backdrop)

	hooksecurefunc(Button, "SetNormalTexture", function(f, t) if t ~= "" then f:SetNormalTexture("") end end)
	hooksecurefunc(Button, "SetPushedTexture", function(f, t) if t ~= "" then f:SetPushedTexture("") end end)
	hooksecurefunc(Button, "SetHighlightTexture", function(f, t) if t ~= "" then f:SetHighlightTexture("") end end)
	hooksecurefunc(Button, "SetDisabledTexture", function(f, t) if t ~= "" then f:SetDisabledTexture("") end end)
	hooksecurefunc(Button, "SetDisabledCheckedTexture", function(f, t) if t ~= "" then f:SetDisabledCheckedTexture("") end end)

	Button.isSkinned = true
end

function S:HandleIcon(icon, parent)
	parent = parent or icon:GetParent()

	icon:SetTexCoord(unpack(E.TexCoords))
	parent:CreateBackdrop()
	icon:SetParent(parent.backdrop)
	parent.backdrop:SetOutside(icon)
end

function S:HandleItemButton(b, shrinkIcon)
	if b.isSkinned then return end

	local icon = b.icon or b.IconTexture or b.iconTexture
	local texture
	if b:GetName() and _G[b:GetName().."IconTexture"] then
		icon = _G[b:GetName().."IconTexture"]
	elseif b:GetName() and _G[b:GetName().."Icon"] then
		icon = _G[b:GetName().."Icon"]
	end

	if icon and icon:GetTexture() then
		texture = icon:GetTexture()
	end

	b:StripTextures()
	b:CreateBackdrop("Default", true)
	b:StyleButton()

	if icon then
		icon:SetTexCoord(unpack(E.TexCoords))

		if shrinkIcon then
			b.backdrop:SetAllPoints()
			icon:SetInside(b)
		else
			b.backdrop:SetOutside(icon)
		end
		icon:SetParent(b.backdrop)

		if texture then
			icon:SetTexture(texture)
		end
	end

	b.isSkinned = true
end

function S:HandleCloseButton(f, point)
	f:StripTextures()

	if not f.Texture then
		f.Texture = f:CreateTexture(nil, "OVERLAY")
		f.Texture:Point("CENTER")
		f.Texture:SetTexture(E.Media.Textures.Close)
		f.Texture:Size(12, 12)
		f:HookScript("OnEnter", handleCloseButtonOnEnter)
		f:HookScript("OnLeave", handleCloseButtonOnLeave)
		f:SetHitRectInsets(6, 6, 7, 7)
	end

	if point then
		f:Point("TOPRIGHT", point, "TOPRIGHT", 2, 4)
	end
end

function S:HandleArrowButton(f, direction, invert)
	f:StripTextures()

	if not f.Texture then
		f.Texture = f:CreateTexture(nil, "OVERLAY")
		f.Texture:Point("CENTER")
		f.Texture:SetTexture(E.Media.Textures.ArrowUp)
		if invert then
			f.Texture:SetRotation(S.ArrowRotation[direction and "left" or "right"])
		else
			f.Texture:SetRotation(S.ArrowRotation[direction and "down" or "up"])
		end
		f.Texture:Size(24)
		f:HookScript("OnEnter", handleCloseButtonOnEnter)
		f:HookScript("OnLeave", handleCloseButtonOnLeave)
		f:SetHitRectInsets(6, 6, 7, 7)
	end
end

local sliderOnDisable = function(self) self:GetThumbTexture():SetVertexColor(0.6, 0.6, 0.6, 0.8) end
local sliderOnEnable = function(self) self:GetThumbTexture():SetVertexColor(1, 0.82, 0, 0.8) end

function S:HandleSliderFrame(frame)
	assert(frame)

	local orientation = frame:GetOrientation()

	frame:StripTextures()
	if not frame.backdrop then
		frame:CreateBackdrop()
		frame.backdrop:SetAllPoints()
	end

	hooksecurefunc(frame, "SetBackdrop", function(_, backdrop)
		if backdrop ~= nil then frame:SetBackdrop(nil) end
	end)

	frame:SetThumbTexture(E.Media.Textures.Melli)
	frame:GetThumbTexture():SetVertexColor(1, 0.82, 0, 0.8)
	frame:GetThumbTexture():Size(10)

	frame:HookScript("OnDisable", sliderOnDisable)
	frame:HookScript("OnEnable", sliderOnEnable)

	if orientation == "VERTICAL" then
		frame:Width(12)
	else
		frame:Height(12)

		for i = 1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region and region:IsObjectType("FontString") then
				local point, anchor, anchorPoint, x, y = region:GetPoint()
				if strfind(anchorPoint, "BOTTOM") then
					region:Point(point, anchor, anchorPoint, x, y - 4)
				end
			end
		end
	end
end

local controlButtons = {
	"ZoomInButton",
	"ZoomOutButton",
	"PanButton",
	"RotateLeftButton",
	"RotateRightButton",
	"RotateResetButton"
}

function S:HandleModelControlFrame(frame)
	local frameName = frame.GetName and frame:GetName()

	frame:StripTextures()
	frame:Size(123, 23)

	for _, object in pairs(controlButtons) do
		S:HandleButton(_G[frameName..object])
		_G[frameName..object.."Bg"]:Hide()
	end

	_G[frameName.."ZoomOutButton"]:Point("LEFT", _G[frameName.."ZoomInButton"], "RIGHT", 2, 0)
	_G[frameName.."PanButton"]:Point("LEFT", _G[frameName.."ZoomOutButton"], "RIGHT", 2, 0)
	_G[frameName.."RotateLeftButton"]:Point("LEFT", _G[frameName.."PanButton"], "RIGHT", 2, 0)
	_G[frameName.."RotateRightButton"]:Point("LEFT", _G[frameName.."RotateLeftButton"], "RIGHT", 2, 0)
	_G[frameName.."RotateResetButton"]:Point("LEFT", _G[frameName.."RotateRightButton"], "RIGHT", 2, 0)
end

function S:HandleIconSelectionFrame(frame, numIcons, buttonNameTemplate, frameNameOverride)
	assert(frame, "HandleIconSelectionFrame: frame argument missing")
	assert(numIcons and type(numIcons) == "number", "HandleIconSelectionFrame: numIcons argument missing or not a number")
	assert(buttonNameTemplate and type(buttonNameTemplate) == "string", "HandleIconSelectionFrame: buttonNameTemplate argument missing or not a string")

	local frameName = frameNameOverride or frame:GetName() --We need override in case Blizzard fucks up the naming (guild bank)
	local scrollFrame = _G[frameName.."ScrollFrame"]
	local scrollBar = _G[frameName.."ScrollFrameScrollBar"]
	local editBox = _G[frameName.."EditBox"]
	local okayButton = _G[frameName.."OkayButton"] or _G[frameName.."Okay"]
	local cancelButton = _G[frameName.."CancelButton"] or _G[frameName.."Cancel"]

	frame:StripTextures()
	frame:SetTemplate("Transparent")

	scrollFrame:StripTextures()
	scrollFrame:CreateBackdrop("Transparent")
	scrollFrame.backdrop:Point("TOPLEFT", _G[buttonNameTemplate.."1"], -4, 4)
	scrollFrame.backdrop:Point("BOTTOMRIGHT", _G[buttonNameTemplate..numIcons], 4, -4)

	S:HandleScrollBar(scrollBar)
	scrollBar:ClearAllPoints()
	scrollBar:Point("TOPRIGHT", scrollFrame.backdrop, 24, -18)
	scrollBar:Point("BOTTOMRIGHT", scrollFrame.backdrop, 0, 18)

	editBox:DisableDrawLayer("BACKGROUND")
	S:HandleEditBox(editBox)
	editBox:ClearAllPoints()
	editBox:Point("TOPLEFT", scrollFrame.backdrop, 1, 40)

	S:HandleButton(cancelButton)
	cancelButton:ClearAllPoints()
	cancelButton:Point("BOTTOMRIGHT", scrollFrame.backdrop, 0, -27)

	S:HandleButton(okayButton)

	for i = 1, numIcons do
		local button = _G[buttonNameTemplate..i]
		local icon = _G[button:GetName().."Icon"]

		button:StripTextures()
		button:SetTemplate(nil, true)
		button:StyleButton(nil, true)

		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))
	end
end

function S:HandleRoleButton(btn, size, role)
	btn:StripTextures()
	btn:CreateBackdrop()
	S:HandleFrameHighlight(btn, btn.backdrop)

	if size then
		btn:Size(size)
	end

	local tankTex = [[Interface\Icons\Ability_Defend]]
	local healerTex = [[Interface\Icons\SPELL_NATURE_HEALINGTOUCH]]
	local damagerTex = [[Interface\Icons\INV_Knife_1H_Common_B_01]]
	local leaderTex = [[Interface\Icons\Ability_Vehicle_LaunchPlayer]]

	local roleTexture
	if role then
		if role == "Tank" then
			roleTexture = tankTex
		elseif role == "Healer" then
			roleTexture = healerTex
		elseif role == "Damager" then
			roleTexture = damagerTex
		elseif role == "Leader" then
			roleTexture = leaderTex
		end
	else
		local btnName = btn:GetName()
		if btnName then
			if strfind(btnName, "Tank") then
				roleTexture = tankTex
			elseif strfind(btnName, "Healer") then
				roleTexture = healerTex
			elseif strfind(btnName, "DPS") or strfind(btnName, "Damager") then
				roleTexture = damagerTex
			elseif strfind(btnName, "Leader") then
				roleTexture = leaderTex
			end

			local roleText = _G[btnName.."Text"]
			if roleText then
				roleText:ClearAllPoints()
				roleText:Point("BOTTOM", btn, "TOP", 0, 3)
			end
		end
	end

	local icon = btn:GetNormalTexture()
	icon:SetTexture(roleTexture)
	icon:SetTexCoord(unpack(E.TexCoords))
	icon:SetInside(btn.backdrop)

	local checkbox = btn.checkButton or btn:GetChildren()
	if checkbox then
		S:HandleCheckBox(checkbox)
		checkbox:SetFrameLevel(checkbox:GetFrameLevel() + 2)
		checkbox:ClearAllPoints()
		checkbox:Point("BOTTOMLEFT", btn, -10, -10)
	end

	if btn.incentiveIcon then
		btn.incentiveIcon:StripTextures()
		btn.incentiveIcon:SetTemplate()
		btn.incentiveIcon:Size(20)
		btn.incentiveIcon:ClearAllPoints()
		btn.incentiveIcon:Point("TOPRIGHT", 10, 10)
		btn.incentiveIcon:SetFrameLevel(btn.incentiveIcon:GetFrameLevel() + 2)

		btn.incentiveIcon.texture:SetTexCoord(unpack(E.TexCoords))
		btn.incentiveIcon.texture:SetInside(btn.incentiveIcon)
	end
end

function S:ADDON_LOADED(_, addon)
	S:SkinAce3()

	if self.allowBypass[addon] then
		if self.addonCallbacks[addon] then
			--Fire events to the skins that rely on this addon
			for index, event in ipairs(self.addonCallbacks[addon].CallPriority) do
				self.addonCallbacks[addon][event] = nil
				self.addonCallbacks[addon].CallPriority[index] = nil
				E.callbacks:Fire(event)
			end
		end
		return
	end

	if not E.initialized then return end

	if self.addonCallbacks[addon] then
		for index, event in ipairs(self.addonCallbacks[addon].CallPriority) do
			self.addonCallbacks[addon][event] = nil
			self.addonCallbacks[addon].CallPriority[index] = nil
			E.callbacks:Fire(event)
		end
	end
end

local function SetPanelWindowInfo(frame, name, value, igroneUpdate)
	frame:SetAttribute(name, value)

	if not igroneUpdate and frame:IsShown() then
		UpdateUIPanelPositions(frame)
	end
end

local UI_PANEL_OFFSET = 7

function S:SetUIPanelWindowInfo(frame, name, value, offset, igroneUpdate)
	local frameName = frame and frame.GetName and frame:GetName()
	if not (frameName and UIPanelWindows[frameName]) then return end

	name = "UIPanelLayout-"..name

	if name == "UIPanelLayout-width" then
		value = E:Scale(value or (frame.backdrop and frame.backdrop:GetWidth() or frame:GetWidth())) + (offset or 0) + UI_PANEL_OFFSET
	end

	local valueChanged = frame:GetAttribute(name) ~= value

	if not frame:CanChangeAttribute() then
		local frameInfo = format("%s-%s", frameName, name)

		if self.uiPanelQueue[frameInfo] then
			if not valueChanged then
				self.uiPanelQueue[frameInfo][3] = nil
			else
				self.uiPanelQueue[frameInfo][3] = value
				self.uiPanelQueue[frameInfo][4] = igroneUpdate
			end
		elseif valueChanged then
			self.uiPanelQueue[frameInfo] = {frame, name, value, igroneUpdate}

			if not self.inCombat then
				self.inCombat = true
				S:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		end
	elseif valueChanged then
		SetPanelWindowInfo(frame, name, value, igroneUpdate)
	end
end

function S:SetBackdropHitRect(frame, backdrop, clampRect, attempt)
	if not frame then return end

	backdrop = backdrop or frame.backdrop
	if not backdrop then return end

	local left = frame:GetLeft()
	local bleft = backdrop:GetLeft()

	if not left or not bleft then
		if attempt ~= 10 then
			E:Delay(0.1, S.SetBackdropHitRect, S, frame, backdrop, clampRect, attempt and attempt + 1 or 1)
		end

		return
	end

	left = floor(left + 0.5)
	local right = floor(frame:GetRight() + 0.5)
	local top = floor(frame:GetTop() + 0.5)
	local bottom = floor(frame:GetBottom() + 0.5)

	bleft = floor(bleft + 0.5)
	local bright = floor(backdrop:GetRight() + 0.5)
	local btop = floor(backdrop:GetTop() + 0.5)
	local bbottom = floor(backdrop:GetBottom() + 0.5)

	left = bleft - left
	right = right - bright
	top = top - btop
	bottom = bbottom - bottom

	if not frame:CanChangeAttribute() then
		self.hitRectQueue[frame] = {left, right, top, bottom, clampRect}

		if not self.inCombat then
			self.inCombat = true
			S:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	else
		frame:SetHitRectInsets(left, right, top, bottom)

		if clampRect then
			frame:SetClampRectInsets(left, -right, -top, bottom)
		end
	end
end

function S:PLAYER_REGEN_ENABLED()
	self.inCombat = nil
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")

	for frameInfo, info in pairs(self.uiPanelQueue) do
		if info[3] then
			SetPanelWindowInfo(info[1], info[2], info[3], info[4])
		end
		self.uiPanelQueue[frameInfo] = nil
	end

	for frame, info in pairs(self.hitRectQueue) do
		frame:SetHitRectInsets(info[1], info[2], info[3], info[4])

		if info[5] then
			frame:SetClampRectInsets(info[1], info[2], info[3], info[4])
		end

		self.hitRectQueue[frame] = nil
	end
end

--Add callback for skin that relies on another addon.
--These events will be fired when the addon is loaded.
function S:AddCallbackForAddon(addonName, eventName, loadFunc, forceLoad, bypass)
	if not addonName or type(addonName) ~= "string" then
		E:Print("Invalid argument #1 to S:AddCallbackForAddon (string expected)")
		return
	elseif not eventName or type(eventName) ~= "string" then
		E:Print("Invalid argument #2 to S:AddCallbackForAddon (string expected)")
		return
	elseif not loadFunc or type(loadFunc) ~= "function" then
		E:Print("Invalid argument #3 to S:AddCallbackForAddon (function expected)")
		return
	end

	if bypass then
		self.allowBypass[addonName] = true
	end

	--Create an event registry for this addon, so that we can fire multiple events when this addon is loaded
	if not self.addonCallbacks[addonName] then
		self.addonCallbacks[addonName] = {["CallPriority"] = {}}
	end

	if self.addonCallbacks[addonName][eventName] or E.ModuleCallbacks[eventName] or E.InitialModuleCallbacks[eventName] then
		--Don't allow a registered callback to be overwritten
		E:Print("Invalid argument #2 to S:AddCallbackForAddon (event name:", eventName, "is already registered, please use a unique event name)")
		return
	end

	--Register loadFunc to be called when event is fired
	E.RegisterCallback(E, eventName, loadFunc)

	if forceLoad then
		E.callbacks:Fire(eventName)
	else
		--Insert eventName in this addons' registry
		self.addonCallbacks[addonName][eventName] = true
		self.addonCallbacks[addonName].CallPriority[#self.addonCallbacks[addonName].CallPriority + 1] = eventName
	end
end

--Add callback for skin that does not rely on a another addon.
--These events will be fired when the Skins module is initialized.
function S:AddCallback(eventName, loadFunc)
	if not eventName or type(eventName) ~= "string" then
		E:Print("Invalid argument #1 to S:AddCallback (string expected)")
		return
	elseif not loadFunc or type(loadFunc) ~= "function" then
		E:Print("Invalid argument #2 to S:AddCallback (function expected)")
		return
	end

	if self.nonAddonCallbacks[eventName] or E.ModuleCallbacks[eventName] or E.InitialModuleCallbacks[eventName] then
		--Don't allow a registered callback to be overwritten
		E:Print("Invalid argument #1 to S:AddCallback (event name:", eventName, "is already registered, please use a unique event name)")
		return
	end

	--Add event name to registry
	self.nonAddonCallbacks[eventName] = true
	self.nonAddonCallbacks.CallPriority[#self.nonAddonCallbacks.CallPriority + 1] = eventName

	--Register loadFunc to be called when event is fired
	E.RegisterCallback(E, eventName, loadFunc)
end

function S:SkinAce3()
	S:HookAce3(LibStub("AceGUI-3.0", true))
	S:Ace3_SkinTooltip(LibStub("AceConfigDialog-3.0", true))
	S:Ace3_SkinTooltip(E.Libs.AceConfigDialog, E.LibsMinor.AceConfigDialog)
end

function S:Initialize()
	self.Initialized = true
	self.db = E.private.skins

	self.uiPanelQueue = {}
	self.hitRectQueue = {}

	S:SkinAce3()

	--Fire event for all skins that doesn't rely on a Blizzard addon
	for index, event in ipairs(self.nonAddonCallbacks.CallPriority) do
		self.nonAddonCallbacks[event] = nil
		self.nonAddonCallbacks.CallPriority[index] = nil
		E.callbacks:Fire(event)
	end

	--Fire events for Blizzard addons that are already loaded
	for addon in pairs(self.addonCallbacks) do
		if IsAddOnLoaded(addon) then
			for index, event in ipairs(S.addonCallbacks[addon].CallPriority) do
				self.addonCallbacks[addon][event] = nil
				self.addonCallbacks[addon].CallPriority[index] = nil
				E.callbacks:Fire(event)
			end
		end
	end
end

S:RegisterEvent("ADDON_LOADED")

local function InitializeCallback()
	S:Initialize()
end

E:RegisterModule(S:GetName(), InitializeCallback)