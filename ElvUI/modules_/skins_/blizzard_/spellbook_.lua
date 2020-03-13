local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local select, unpack = select, unpack

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.spellbook ~= true then return end

	local SpellBookFrame = _G["SpellBookFrame"]
	SpellBookFrame:StripTextures(true)
	SpellBookFrame:SetTemplate("Transparent")
	SpellBookFrame:Width(460)

	SpellBookFrameInset:StripTextures(true)
	SpellBookSpellIconsFrame:StripTextures(true)
	SpellBookSideTabsFrame:StripTextures(true)
	SpellBookPageNavigationFrame:StripTextures(true)

	SpellBookPageText:SetTextColor(1, 1, 1)
	SpellBookPageText:Point("BOTTOMRIGHT", SpellBookFrame, "BOTTOMRIGHT", -90, 15)

	S:HandleNextPrevButton(SpellBookPrevPageButton)
	SpellBookPrevPageButton:Point("BOTTOMRIGHT", SpellBookFrame, "BOTTOMRIGHT", -45, 10)

	S:HandleNextPrevButton(SpellBookNextPageButton)
	SpellBookNextPageButton:Point("BOTTOMRIGHT", SpellBookPageNavigationFrame, "BOTTOMRIGHT", -10, 10)

	SpellBookFrameTutorialButton:Hide()

	S:HandleCloseButton(SpellBookFrameCloseButton)

	-- Spell Buttons
	for i = 1, SPELLS_PER_PAGE do
		local button = _G["SpellButton"..i]
		local icon = _G["SpellButton"..i.."IconTexture"]
		local cooldown = _G["SpellButton"..i.."Cooldown"]

		for i = 1, button:GetNumRegions() do
			local region = select(i, button:GetRegions())
			if region:GetObjectType() == "Texture" then
				if region ~= button.FlyoutArrow then
					region:SetTexture(nil)
				end
			end
		end

		button:CreateBackdrop("Default", true)
		button.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() - 1)

		icon:SetTexCoord(unpack(E.TexCoords))

		button.bg = CreateFrame("Frame", nil, button)
		button.bg:CreateBackdrop("Transparent", true)
		button.bg:Point("TOPLEFT", -7, 8)
		button.bg:Point("BOTTOMRIGHT", 170, -12)
		button.bg:SetFrameLevel(button.bg:GetFrameLevel() - 2)

		E:RegisterCooldown(cooldown)
	end

	SpellButton1:Point("TOPLEFT", SpellBookSpellIconsFrame, "TOPLEFT", 15, -75)
	SpellButton2:Point("TOPLEFT", SpellButton1, "TOPLEFT", 225, 0)
	SpellButton3:Point("TOPLEFT", SpellButton1, "BOTTOMLEFT", 0, -27)
	SpellButton4:Point("TOPLEFT", SpellButton3, "TOPLEFT", 225, 0)
	SpellButton5:Point("TOPLEFT", SpellButton3, "BOTTOMLEFT", 0, -27)
	SpellButton6:Point("TOPLEFT", SpellButton5, "TOPLEFT", 225, 0)
	SpellButton7:Point("TOPLEFT", SpellButton5, "BOTTOMLEFT", 0, -27)
	SpellButton8:Point("TOPLEFT", SpellButton7, "TOPLEFT", 225, 0)
	SpellButton9:Point("TOPLEFT", SpellButton7, "BOTTOMLEFT", 0, -27)
	SpellButton10:Point("TOPLEFT", SpellButton9, "TOPLEFT", 225, 0)
	SpellButton11:Point("TOPLEFT", SpellButton9, "BOTTOMLEFT", 0, -27)
	SpellButton12:Point("TOPLEFT", SpellButton11, "TOPLEFT", 225, 0)

	hooksecurefunc("SpellButton_UpdateButton", function(self)
		local name = self:GetName()
		local spellName = _G[name .. "SpellName"]
		local spellSubName = _G[name .. "SubSpellName"]
		local spellLevel = _G[name .. "RequiredLevelString"]
		local highlight = _G[name .. "Highlight"]

		if highlight then
			highlight:SetTexture(1, 1, 1, 0.3)
		end

		local r, g, b = spellName:GetTextColor()

		if r < 0.8 then
			spellName:SetTextColor(0.6, 0.6, 0.6)

			if spellSubName then
				spellSubName:SetTextColor(0.6, 0.6, 0.6)
			end
		else
			if spellSubName then
				spellSubName:SetTextColor(1, 1, 1)
			end
		end

		if spellLevel then
			spellLevel:SetTextColor(0.6, 0.6, 0.6)
		end
	end)

	-- What Has Changed Frame
	local _, class = UnitClass("player")
	local classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
	local changedList = WHAT_HAS_CHANGED_DISPLAY[class]

	SpellBookWhatHasChanged:Point("TOPLEFT", -80, 5)
	SpellBookWhatHasChanged.ClassName:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
	SpellBookWhatHasChanged.ClassName:Point("TOP", 37, -30)

	if changedList then
		for i = 1, #changedList do
			local frame = SpellBook_GetWhatChangedItem(i)

			frame:StripTextures()
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point("TOPLEFT", -25, 25)
			frame.backdrop:Point("BOTTOMRIGHT", 23, -37)

			frame:SetTextColor(1, 1, 1)
			frame.Number:SetTextColor(1, 0.80, 0.10)
			frame.Number:Point("TOPLEFT", -15, 18)
			frame.Title:SetTextColor(1, 0.80, 0.10)
		end
	end

	-- Core Abilities Frame
	SpellBookCoreAbilitiesFrame:Point("TOPLEFT", -80, 5)

	SpellBookCoreAbilitiesFrame.SpecName:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
	SpellBookCoreAbilitiesFrame.SpecName:Point("TOP", 37, -30)

	hooksecurefunc("SpellBook_UpdateCoreAbilitiesTab", function()
		for i = 1, #SpellBookCoreAbilitiesFrame.Abilities do
			local button = SpellBookCoreAbilitiesFrame.Abilities[i]
			if button and button.isSkinned ~= true then
				if button.highlightTexture then
					hooksecurefunc(button.highlightTexture, "SetTexture", function(_, texOrR)
						if texOrR == [[Interface\Buttons\ButtonHilight-Square]] then
							button.highlightTexture:SetTexture(1, 1, 1, 0.3)
							button.highlightTexture:SetInside()
						end
					end)
				end

				button:CreateBackdrop()
				button.backdrop:SetAllPoints()
				button:StyleButton()

				button.EmptySlot:SetAlpha(0)
				button.ActiveTexture:SetAlpha(0)
				button.FutureTexture:SetAlpha(0)

				button.iconTexture:SetTexCoord(unpack(E.TexCoords))
				button.iconTexture:SetInside()

				button.Name:Point("TOPLEFT", 50, 0)

				button.bg = CreateFrame("Frame", nil, button)
				button.bg:SetTemplate("Transparent")
				button.bg:Point("TOPLEFT", -5, 5)
				button.bg:Point("BOTTOMRIGHT", 380, -20)
				button.bg:SetFrameLevel(button.bg:GetFrameLevel() - 2)

				button.isSkinned = true
			end

			if button then
				if button.FutureTexture:IsShown() then
					button.iconTexture:SetDesaturated(true)
					button.Name:SetTextColor(0.6, 0.6, 0.6)
					button.InfoText:SetTextColor(0.6, 0.6, 0.6)
					button.RequiredLevel:SetTextColor(0.6, 0.6, 0.6)
				else
					button.iconTexture:SetDesaturated(false)
					button.Name:SetTextColor(1, 0.80, 0.10)
					button.InfoText:SetTextColor(1, 1, 1)
					button.RequiredLevel:SetTextColor(0.8, 0.8, 0.8)
				end
			end
		end

		for i = 1, #SpellBookCoreAbilitiesFrame.SpecTabs do
			local tab = SpellBookCoreAbilitiesFrame.SpecTabs[i]

			if tab and tab.isSkinned ~= true then
				tab:GetRegions():Hide()
				tab:SetTemplate()

				tab:GetNormalTexture():SetInside()
				tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))

				tab:StyleButton(nil, true)

				if i == 1 then
					tab:Point("TOPLEFT", SpellBookFrame, "TOPRIGHT", E.PixelMode and -1 or 1, -75)
				end

				tab.isSkinned = true
			end
		end
	end)

	-- Skill Line Tabs
	for i = 1, MAX_SKILLLINE_TABS do
		local tab = _G["SpellBookSkillLineTab"..i]
		local flash = _G["SpellBookSkillLineTab"..i.."Flash"]

		tab:StripTextures()
		tab:SetTemplate()
		tab:StyleButton(nil, true)
		tab.pushed = true

		tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		tab:GetNormalTexture():SetInside()

		if i == 1 then
			tab:Point("TOPLEFT", SpellBookSideTabsFrame, "TOPRIGHT", E.PixelMode and -1 or 1, -40)
		end

		hooksecurefunc(tab:GetHighlightTexture(), "SetTexture", function(self, texPath)
			if texPath ~= nil then
				self:SetPushedTexture(nil)
			end
		end)

		hooksecurefunc(tab:GetCheckedTexture(), "SetTexture", function(self, texPath)
			if texPath ~= nil then
				self:SetHighlightTexture(nil)
			end
		end)

		flash:Kill()
	end

	-- Bottom Tabs
	for i = 1, 5 do
		local tab = _G["SpellBookFrameTabButton"..i]

		S:HandleTab(tab)

		if i == 1 then
			tab:ClearAllPoints()
			tab:Point("TOPLEFT", SpellBookFrame, "BOTTOMLEFT", 0, 2)
		end
	end

	-- Primary Professions
	for i = 1, 2 do
		local primary = _G["PrimaryProfession"..i]

		primary:StripTextures()
		primary:CreateBackdrop("Transparent")
		primary:Height(90)

		if i == 1 then
			primary:Point("TOPLEFT", 10, -30)
		elseif i == 2 then
			primary:Point("TOPLEFT", 10, -130)
		end

		primary.icon:SetTexCoord(unpack(E.TexCoords))

		primary.missingHeader:SetTextColor(1, 0.80, 0.10)

		primary.missingText:SetTextColor(1, 1, 1)
		primary.missingText:FontTemplate(nil, 12, "OUTLINE")

		primary.statusBar:StripTextures()
		primary.statusBar:CreateBackdrop("Default")
		primary.statusBar:SetStatusBarTexture(E.media.normTex)
		primary.statusBar:SetStatusBarColor(0.22, 0.39, 0.84)
		primary.statusBar:Size(180, 20)
		primary.statusBar:Point("TOPLEFT", 250, -10)

		primary.statusBar.rankText:Point("CENTER")
		primary.statusBar.rankText:FontTemplate(nil, 12, "OUTLINE")

		primary.rank:Point("TOPLEFT", 120, -23)
		primary.unlearn:Point("RIGHT", primary.statusBar, "LEFT", -135, -10)

		primary.button1:StripTextures()
		primary.button1:CreateBackdrop("Default")
		primary.button1:Point("TOPLEFT", primary.button2, "BOTTOMLEFT", 135, 40)
		primary.button1:GetHighlightTexture():Hide()
		primary.button1:StyleButton(true)
		primary.button1.pushed:SetAllPoints()
		primary.button1.checked:SetAllPoints()
		primary.button1:SetFrameLevel(primary.button1:GetFrameLevel() + 2)

		primary.button1.iconTexture:SetTexCoord(unpack(E.TexCoords))
		primary.button1.iconTexture:SetAllPoints()

		primary.button1.subSpellString:SetTextColor(1, 1, 1)

		primary.button1.cooldown:SetAllPoints()
		E:RegisterCooldown(primary.button1.cooldown)

		primary.button2:StripTextures()
		primary.button2:CreateBackdrop("Default")
		primary.button2:Point("TOPRIGHT", primary, "TOPRIGHT", -235, -45)
		primary.button2:GetHighlightTexture():Hide()
		primary.button2:StyleButton(true)
		primary.button2.pushed:SetAllPoints()
		primary.button2.checked:SetAllPoints()
		primary.button2:SetFrameLevel(primary.button2:GetFrameLevel() + 2)

		primary.button2.iconTexture:SetTexCoord(unpack(E.TexCoords))
		primary.button2.iconTexture:SetAllPoints()

		primary.button2.subSpellString:SetTextColor(1, 1, 1)

		primary.button2.cooldown:SetAllPoints()
		E:RegisterCooldown(primary.button2.cooldown)
	end

	-- Secondary Professions
	for i = 1, 4 do
		local secondary = _G["SecondaryProfession"..i]

		secondary:CreateBackdrop("Transparent")
		secondary:Height(60)

		secondary.statusBar:StripTextures()
		secondary.statusBar:CreateBackdrop("Default")
		secondary.statusBar:SetStatusBarTexture(E.media.normTex)
		secondary.statusBar:SetStatusBarColor(0.22, 0.39, 0.84)
		secondary.statusBar:Size(120, 18)
		secondary.statusBar:Point("TOPLEFT", 5, -35)

		secondary.statusBar.rankText:Point("CENTER")
		secondary.statusBar.rankText:FontTemplate(nil, 12, "OUTLINE")

		secondary.missingHeader:SetTextColor(1, 0.80, 0.10)

		secondary.missingText:SetTextColor(1, 1, 1)
		secondary.missingText:FontTemplate(nil, 12, "OUTLINE")

		secondary.button1:StripTextures()
		secondary.button1:CreateBackdrop("Default", true)
		secondary.button1:Point("TOPRIGHT", -90, -10)
		secondary.button1:GetHighlightTexture():Hide()
		secondary.button1:StyleButton(true)
		secondary.button1.pushed:SetAllPoints()
		secondary.button1.checked:SetAllPoints()
		secondary.button1:SetFrameLevel(secondary.button1:GetFrameLevel() + 2)
		secondary.button1:Point("TOPRIGHT", secondary, "TOPRIGHT", -100, -10)

		secondary.button1.iconTexture:SetTexCoord(unpack(E.TexCoords))
		secondary.button1.iconTexture:SetAllPoints()

		secondary.button1.subSpellString:SetTextColor(1, 1, 1)

		secondary.button1.cooldown:SetAllPoints()
		E:RegisterCooldown(secondary.button1.cooldown)

		secondary.button2:StripTextures()
		secondary.button2:CreateBackdrop("Default", true)
		secondary.button2:GetHighlightTexture():Hide()
		secondary.button2:StyleButton(true)
		secondary.button2.pushed:SetAllPoints()
		secondary.button2.checked:SetAllPoints()
		secondary.button2:SetFrameLevel(secondary.button2:GetFrameLevel() + 2)
		secondary.button2:Point("TOPRIGHT", secondary.button1, "TOPLEFT", -95, 0)

		secondary.button2.iconTexture:SetTexCoord(unpack(E.TexCoords))
		secondary.button2.iconTexture:SetAllPoints()

		secondary.button2.subSpellString:SetTextColor(1, 1, 1)

		secondary.button2.cooldown:SetAllPoints()
		E:RegisterCooldown(secondary.button2.cooldown)
	end
end

S:AddCallback("Spellbook", LoadSkin)