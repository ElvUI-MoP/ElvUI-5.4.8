local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs, unpack, select = pairs, unpack, select

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.transmogrify ~= true then return end

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
		"Head",
		"Shoulder",
		"Chest",
		"Waist",
		"Legs",
		"Feet",
		"Wrist",
		"Hands",
		"Back",
		"MainHand",
		"SecondaryHand"
	}

	for _, slot in pairs(slots) do
		local icon = _G["TransmogrifyFrame"..slot.."SlotIconTexture"]
		local popout = _G["TransmogrifyFrame" .. slot .. "SlotPopoutButton"]
		local slot = _G["TransmogrifyFrame"..slot.."Slot"]

		if slot then
			slot:StripTextures()
			slot:StyleButton(false)
			slot:SetFrameLevel(slot:GetFrameLevel() + 2)
			slot:CreateBackdrop("Default")
			slot.backdrop:SetAllPoints()

			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetInside()
		end

		if popout then
			popout:StripTextures()
			popout:SetTemplate()
			popout:HookScript("OnEnter", S.SetModifiedBackdrop)
			popout:HookScript("OnLeave", S.SetOriginalBackdrop)

			popout.icon = popout:CreateTexture(nil, "ARTWORK")
			popout.icon:Size(14)
			popout.icon:Point("CENTER")
			popout.icon:SetTexture([[Interface\Buttons\SquareButtonTextures]])

			if slot.verticalFlyout then
				popout:Size(27, 11)
				SquareButton_SetIcon(popout, "DOWN")
				popout:Point("TOP", slot, "BOTTOM", 0, 5)
			else
				popout:Size(11, 27)
				SquareButton_SetIcon(popout, "RIGHT")
				popout:Point("LEFT", slot, "RIGHT", -5, 0)
			end
		end
	end

	-- Confirmation Popup
	TransmogrifyConfirmationPopup:SetParent(UIParent)
	TransmogrifyConfirmationPopup:StripTextures()
	TransmogrifyConfirmationPopup:SetTemplate("Transparent")

	S:HandleButton(TransmogrifyConfirmationPopup.Button1)
	S:HandleButton(TransmogrifyConfirmationPopup.Button2)

	S:HandleItemButton(TransmogrifyConfirmationPopupItemFrame1, true)
	S:HandleItemButton(TransmogrifyConfirmationPopupItemFrame2, true)

	hooksecurefunc("TransmogrifyConfirmationPopup_SetItem", function(itemFrame, itemLink)
		local _, _, itemQuality = GetItemInfo(itemLink)
		local r, g, b = GetItemQualityColor(itemQuality or 1)
		
		itemFrame.backdrop:SetBackdropBorderColor(r, g, b)
	end)

	-- Control Frame
	TransmogrifyModelFrameControlFrame:StripTextures()
	TransmogrifyModelFrameControlFrame:Size(123, 23)

	local controlbuttons = {
		"TransmogrifyModelFrameControlFrameZoomInButton",
		"TransmogrifyModelFrameControlFrameZoomOutButton",
		"TransmogrifyModelFrameControlFramePanButton",
		"TransmogrifyModelFrameControlFrameRotateRightButton",
		"TransmogrifyModelFrameControlFrameRotateLeftButton",
		"TransmogrifyModelFrameControlFrameRotateResetButton"
	}

	for i = 1, #controlbuttons do
		S:HandleButton(_G[controlbuttons[i]])
		_G[controlbuttons[i].."Bg"]:Hide()
	end

	TransmogrifyModelFrameControlFrameZoomOutButton:Point("LEFT", "TransmogrifyModelFrameControlFrameZoomInButton", "RIGHT", 2, 0)
	TransmogrifyModelFrameControlFramePanButton:Point("LEFT", "TransmogrifyModelFrameControlFrameZoomOutButton", "RIGHT", 2, 0)
	TransmogrifyModelFrameControlFrameRotateRightButton:Point("LEFT", "TransmogrifyModelFrameControlFramePanButton", "RIGHT", 2, 0)
	TransmogrifyModelFrameControlFrameRotateLeftButton:Point("LEFT", "TransmogrifyModelFrameControlFrameRotateRightButton", "RIGHT", 2, 0)
	TransmogrifyModelFrameControlFrameRotateResetButton:Point("LEFT", "TransmogrifyModelFrameControlFrameRotateLeftButton", "RIGHT", 2, 0)
end

S:AddCallbackForAddon("Blizzard_ItemAlterationUI", "ItemAlterationUI", LoadSkin)