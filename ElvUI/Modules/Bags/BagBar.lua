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
	E:UIFrameFadeIn(ElvUIBags, 0.2, ElvUIBags:GetAlpha(), 1)
end

local function OnLeave()
	if not E.db.bags.bagBar.mouseover then return end
	E:UIFrameFadeOut(ElvUIBags, 0.2, ElvUIBags:GetAlpha(), 0)
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
	if not ElvUIBags then return end

	local bagBarSize = E.db.bags.bagBar.size
	local buttonSpacing = E.db.bags.bagBar.spacing
	local growthDirection = E.db.bags.bagBar.growthDirection
	local sortDirection = E.db.bags.bagBar.sortDirection
	local showBackdrop = E.db.bags.bagBar.showBackdrop
	local backdropSpacing = showBackdrop and (E.db.bags.bagBar.backdropSpacing + E.Border) or 0

	local visibility = E.db.bags.bagBar.visibility
	if visibility and visibility:match("[\n\r]") then
		visibility = visibility:gsub("[\n\r]", "")
	end

	RegisterStateDriver(ElvUIBags, "visibility", visibility)

	ElvUIBags:SetAlpha(E.db.bags.bagBar.mouseover and 0 or 1)
	ElvUIBags.backdrop:SetShown(showBackdrop)
	ElvUIBags.backdrop:SetTemplate(E.db.bags.bagBar.transparent and "Transparent" or "Default")

	for i = 1, #ElvUIBags.buttons do
		local button = ElvUIBags.buttons[i]
		local prevButton = ElvUIBags.buttons[i - 1]

		button:Size(bagBarSize)
		button:ClearAllPoints()

		_G[button:GetName().."Count"]:SetShown(GetCVarBool("displayFreeBagSlots"))

		if growthDirection == "HORIZONTAL" and sortDirection == "ASCENDING" then
			if i == 1 then
				button:Point("LEFT", ElvUIBags, "LEFT", backdropSpacing, 0)
			elseif prevButton then
				button:Point("LEFT", prevButton, "RIGHT", buttonSpacing, 0)
			end
		elseif growthDirection == "VERTICAL" and sortDirection == "ASCENDING" then
			if i == 1 then
				button:Point("TOP", ElvUIBags, "TOP", 0, -backdropSpacing)
			elseif prevButton then
				button:Point("TOP", prevButton, "BOTTOM", 0, -buttonSpacing)
			end
		elseif growthDirection == "HORIZONTAL" and sortDirection == "DESCENDING" then
			if i == 1 then
				button:Point("RIGHT", ElvUIBags, "RIGHT", -backdropSpacing, 0)
			elseif prevButton then
				button:Point("RIGHT", prevButton, "LEFT", -buttonSpacing, 0)
			end
		else
			if i == 1 then
				button:Point("BOTTOM", ElvUIBags, "BOTTOM", 0, backdropSpacing)
			elseif prevButton then
				button:Point("BOTTOM", prevButton, "TOP", 0, buttonSpacing)
			end
		end
	end

	if growthDirection == "HORIZONTAL" then
		ElvUIBags:Width(bagBarSize * (NUM_BAG_FRAMES + 1) + buttonSpacing * (NUM_BAG_FRAMES) + (backdropSpacing or E.Spacing) * 2)
		ElvUIBags:Height(bagBarSize + backdropSpacing * 2)
	else
		ElvUIBags:Height(bagBarSize * (NUM_BAG_FRAMES + 1) + buttonSpacing * (NUM_BAG_FRAMES) + backdropSpacing * 2)
		ElvUIBags:Width(bagBarSize + backdropSpacing * 2)
	end
end

function B:LoadBagBar()
	if not E.private.bags.bagBar then return end

	local ElvUIBags = CreateFrame("Frame", "ElvUIBags", E.UIParent)
	ElvUIBags:Point("TOPRIGHT", RightChatPanel, "TOPLEFT", -4, 0)
	ElvUIBags:CreateBackdrop()
	ElvUIBags.backdrop:SetAllPoints()
	ElvUIBags:EnableMouse(true)
	ElvUIBags:SetScript("OnEnter", OnEnter)
	ElvUIBags:SetScript("OnLeave", OnLeave)
	ElvUIBags.buttons = {}

	MainMenuBarBackpackButton:SetParent(ElvUIBags)
	MainMenuBarBackpackButton:ClearAllPoints()

	MainMenuBarBackpackButtonCount:FontTemplate(nil, 12)
	MainMenuBarBackpackButtonCount:ClearAllPoints()
	MainMenuBarBackpackButtonCount:Point("BOTTOMRIGHT", MainMenuBarBackpackButton, "BOTTOMRIGHT", -1, 4)

	MainMenuBarBackpackButton:HookScript("OnEnter", OnEnter)
	MainMenuBarBackpackButton:HookScript("OnLeave", OnLeave)

	tinsert(ElvUIBags.buttons, MainMenuBarBackpackButton)
	B:SkinBag(MainMenuBarBackpackButton)

	for i = 0, NUM_BAG_FRAMES - 1 do
		local slot = _G["CharacterBag"..i.."Slot"]

		slot:SetParent(ElvUIBags)
		slot:HookScript("OnEnter", OnEnter)
		slot:HookScript("OnLeave", OnLeave)

		B:SkinBag(slot)
		tinsert(ElvUIBags.buttons, slot)
	end

	B:SizeAndPositionBagBar()
	E:CreateMover(ElvUIBags, "BagsMover", L["Bags"], nil, nil, nil, nil, nil, "bags,general")
end