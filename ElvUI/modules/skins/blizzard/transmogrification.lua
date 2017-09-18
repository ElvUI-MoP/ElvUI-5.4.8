local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local _G = _G;
local pairs, unpack, select = pairs, unpack, select;

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
		local popout = _G["TransmogrifyFrame" .. slot .. "SlotPopoutButton"];
		local slot = _G["TransmogrifyFrame"..slot.."Slot"]

		if(slot) then
			slot:StripTextures()
			slot:StyleButton(false)
			slot:SetFrameLevel(slot:GetFrameLevel() + 2)
			slot:CreateBackdrop("Default")
			slot.backdrop:SetAllPoints()

			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetInside()
		end

		if(popout) then
			popout:StripTextures();
			popout:SetTemplate();
			popout:HookScript("OnEnter", S.SetModifiedBackdrop);
			popout:HookScript("OnLeave", S.SetOriginalBackdrop);

			popout.icon = popout:CreateTexture(nil, "ARTWORK");
			popout.icon:Size(14);
			popout.icon:Point("CENTER");
			popout.icon:SetTexture([[Interface\Buttons\SquareButtonTextures]])

			if(slot.verticalFlyout) then
				popout:Size(27, 11);
				SquareButton_SetIcon(popout, "DOWN");
				popout:Point("TOP", slot, "BOTTOM", 0, 5);
			else
				popout:Size(11, 27);
				SquareButton_SetIcon(popout, "RIGHT");
				popout:Point("LEFT", slot, "RIGHT", -5, 0);
			end
		end
	end

	-- Control Frame
	TransmogrifyModelFrameControlFrame:StripTextures()

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
		_G[controlbuttons[i]]:StyleButton()
		_G[controlbuttons[i].."Bg"]:Hide()
	end
end

S:AddCallbackForAddon("Blizzard_ItemAlterationUI", "ItemAlterationUI", LoadSkin);