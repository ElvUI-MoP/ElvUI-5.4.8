local E, L, V, P, G = unpack(select(2, ...))
local B = E:GetModule("Bags")

local _G = _G
local unpack = unpack
local tinsert = tinsert

local CreateFrame = CreateFrame
local GetCVarBool = GetCVarBool
local RegisterStateDriver = RegisterStateDriver
local NUM_BAG_FRAMES = NUM_BAG_FRAMES

local function OnEnter()
	if not E.db.bags.bagBar.mouseover then return end
	E:UIFrameFadeIn(B.BagBar, 0.2, B.BagBar:GetAlpha(), 1)
end

local function OnLeave()
	if not E.db.bags.bagBar.mouseover then return end
	E:UIFrameFadeOut(B.BagBar, 0.2, B.BagBar:GetAlpha(), 0)
end

function B:SkinBag(bag)
	local icon = _G[bag:GetName().."IconTexture"]
	bag.oldTex = icon:GetTexture()

	bag:StripTextures()
	bag:SetTemplate("Default", true)
	bag:StyleButton(nil, true)

	icon:SetInside()
	icon:SetTexture(bag.oldTex)
	icon:SetTexCoord(unpack(E.TexCoords))
end

function B:SizeAndPositionBagBar()
	if not B.BagBar then return end

	local bagBarSize = E.db.bags.bagBar.size
	local buttonSpacing = E.db.bags.bagBar.spacing
	local growthDirection = E.db.bags.bagBar.growthDirection
	local sortDirection = E.db.bags.bagBar.sortDirection
	local showBackdrop = E.db.bags.bagBar.showBackdrop
	local backdropSpacing = showBackdrop and (E.db.bags.bagBar.backdropSpacing + E.Border) or 0
	local justBackpack = E.private.bags.enable and E.db.bags.bagBar.justBackpack

	local visibility = E.db.bags.bagBar.visibility
	if visibility and visibility:match("[\n\r]") then
		visibility = visibility:gsub("[\n\r]", "")
	end

	RegisterStateDriver(B.BagBar, "visibility", visibility)

	B.BagBar:SetAlpha(E.db.bags.bagBar.mouseover and 0 or 1)
	B.BagBar.backdrop:SetShown(showBackdrop)
	B.BagBar.backdrop:SetTemplate(E.db.bags.bagBar.transparent and "Transparent" or "Default")

	for i, button in ipairs(B.BagBar.buttons) do
		local prevButton = B.BagBar.buttons[i - 1]

		button:Size(bagBarSize)
		button:ClearAllPoints()
		button:SetShown(i == 1 and justBackpack or not justBackpack)

		_G[button:GetName().."Count"]:SetShown(GetCVarBool("displayFreeBagSlots"))

		if growthDirection == "HORIZONTAL" and sortDirection == "ASCENDING" then
			if i == 1 then
				button:Point("LEFT", B.BagBar, "LEFT", backdropSpacing, 0)
			elseif prevButton then
				button:Point("LEFT", prevButton, "RIGHT", buttonSpacing, 0)
			end
		elseif growthDirection == "VERTICAL" and sortDirection == "ASCENDING" then
			if i == 1 then
				button:Point("TOP", B.BagBar, "TOP", 0, -backdropSpacing)
			elseif prevButton then
				button:Point("TOP", prevButton, "BOTTOM", 0, -buttonSpacing)
			end
		elseif growthDirection == "HORIZONTAL" and sortDirection == "DESCENDING" then
			if i == 1 then
				button:Point("RIGHT", B.BagBar, "RIGHT", -backdropSpacing, 0)
			elseif prevButton then
				button:Point("RIGHT", prevButton, "LEFT", -buttonSpacing, 0)
			end
		else
			if i == 1 then
				button:Point("BOTTOM", B.BagBar, "BOTTOM", 0, backdropSpacing)
			elseif prevButton then
				button:Point("BOTTOM", prevButton, "TOP", 0, buttonSpacing)
			end
		end
	end

	local width, height = bagBarSize * (NUM_BAG_FRAMES + 1) + buttonSpacing * (NUM_BAG_FRAMES) + backdropSpacing * 2, bagBarSize + backdropSpacing * 2
	B.BagBar:Width(justBackpack and height or (growthDirection == "HORIZONTAL" and width or height))
	B.BagBar:Height(justBackpack and height or (growthDirection == "HORIZONTAL" and height or width))
end

function B:LoadBagBar()
	if not E.private.bags.bagBar then return end

	B.BagBar = CreateFrame("Frame", "ElvUIBags", E.UIParent)
	B.BagBar:Point("TOPRIGHT", RightChatPanel, "TOPLEFT", -4, 0)
	B.BagBar:CreateBackdrop()
	B.BagBar.backdrop:SetAllPoints()
	B.BagBar:EnableMouse(true)
	B.BagBar:SetScript("OnEnter", OnEnter)
	B.BagBar:SetScript("OnLeave", OnLeave)
	B.BagBar.buttons = {}

	MainMenuBarBackpackButton:SetParent(B.BagBar)
	MainMenuBarBackpackButton:ClearAllPoints()

	MainMenuBarBackpackButtonCount:FontTemplate(nil, 12)
	MainMenuBarBackpackButtonCount:ClearAllPoints()
	MainMenuBarBackpackButtonCount:Point("BOTTOMRIGHT", MainMenuBarBackpackButton, "BOTTOMRIGHT", -1, 4)

	MainMenuBarBackpackButton:HookScript("OnEnter", OnEnter)
	MainMenuBarBackpackButton:HookScript("OnLeave", OnLeave)

	tinsert(B.BagBar.buttons, MainMenuBarBackpackButton)
	B:SkinBag(MainMenuBarBackpackButton)

	for i = 0, NUM_BAG_FRAMES - 1 do
		local slot = _G["CharacterBag"..i.."Slot"]

		slot:SetParent(B.BagBar)
		slot:HookScript("OnEnter", OnEnter)
		slot:HookScript("OnLeave", OnLeave)

		B:SkinBag(slot)
		tinsert(B.BagBar.buttons, slot)
	end

	B:SizeAndPositionBagBar()
	E:CreateMover(B.BagBar, "BagsMover", L["Bags"], nil, nil, nil, nil, nil, "bags,general")
end