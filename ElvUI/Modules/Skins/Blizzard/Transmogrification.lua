local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs, unpack, select = pairs, unpack, select

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.transmogrify then return end

	TransmogrifyFrame:StripTextures()
	TransmogrifyFrame:SetTemplate("Transparent")

	TransmogrifyArtFrame:StripTextures()

	TransmogrifyFrameButtonFrame:StripTextures()

	select(2, TransmogrifyModelFrame:GetRegions()):Kill()
	TransmogrifyModelFrame:SetFrameLevel(TransmogrifyFrame:GetFrameLevel() + 2)
	TransmogrifyModelFrame:CreateBackdrop()

	TransmogrifyModelFrameLines:SetInside(TransmogrifyModelFrame.backdrop)
	TransmogrifyModelFrameMarbleBg:SetInside(TransmogrifyModelFrame.backdrop)

	S:HandleButton(TransmogrifyApplyButton, true)
	TransmogrifyApplyButton:Point("BOTTOMRIGHT", -4, 4)

	S:HandleCloseButton(TransmogrifyArtFrameCloseButton)

	local slots = {
		"HeadSlot", "ShoulderSlot", "ChestSlot", "WaistSlot",
		"LegsSlot", "FeetSlot", "WristSlot", "HandsSlot", "BackSlot",
		"MainHandSlot", "SecondaryHandSlot"
	}

	for _, slot in pairs(slots) do
		local button = _G["TransmogrifyFrame"..slot]
		local icon = _G["TransmogrifyFrame"..slot.."IconTexture"]
		local popout = _G["TransmogrifyFrame"..slot.."PopoutButton"]

		button:StripTextures()
		button:CreateBackdrop()
		button.backdrop:SetAllPoints()
		button:StyleButton()
		button:SetFrameLevel(button:GetFrameLevel() + 2)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		if popout then
			popout:StripTextures()
			popout:SetTemplate(nil, true)
			popout:HookScript("OnEnter", S.SetModifiedBackdrop)
			popout:HookScript("OnLeave", S.SetOriginalBackdrop)

			popout.icon = popout:CreateTexture(nil, "ARTWORK")
			popout.icon:Size(14)
			popout.icon:Point("CENTER")
			popout.icon:SetTexture(E.Media.Textures.ArrowUp)

			if button.verticalFlyout then
				popout:Size(27, 11)
				popout:Point("TOP", button, "BOTTOM", 0, 5)

				popout.icon:SetRotation(3.14)
			else
				popout:Size(11, 27)
				popout:Point("LEFT", button, "RIGHT", -5, 0)

				popout.icon:SetRotation(-1.57)
			end
		end
	end

	hooksecurefunc("EquipmentFlyoutPopoutButton_SetReversed", function(button, isReversed)
		local flyout = button:GetParent()
		if flyout:GetParent() ~= TransmogrifyFrame then return end

		button.icon:SetRotation(flyout.verticalFlyout and (isReversed and 0 or 3.14) or (isReversed and 1.57 or -1.57))
	end)

	-- Confirmation Popup
	TransmogrifyConfirmationPopup:SetParent(UIParent)
	TransmogrifyConfirmationPopup:StripTextures()
	TransmogrifyConfirmationPopup:SetTemplate("Transparent")

	S:HandleButton(TransmogrifyConfirmationPopup.Button1)
	S:HandleButton(TransmogrifyConfirmationPopup.Button2)

	S:HandleItemButton(TransmogrifyConfirmationPopupItemFrame1, true)
	S:HandleItemButton(TransmogrifyConfirmationPopupItemFrame2, true)

	hooksecurefunc("TransmogrifyConfirmationPopup_SetItem", function(frame, link)
		local r, g, b = GetItemQualityColor(select(3, GetItemInfo(link)) or 1)
		frame.backdrop:SetBackdropBorderColor(r, g, b)
	end)

	-- Control Frame
	S:HandleModelControlFrame(TransmogrifyModelFrameControlFrame)
end

S:AddCallbackForAddon("Blizzard_ItemAlterationUI", "ItemAlterationUI", LoadSkin)