local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local select, unpack = select, unpack;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.spellbook ~= true) then return; end

	SpellBookFrame:StripTextures(true);
	SpellBookFrame:SetTemplate("Transparent")
	SpellBookFrame:Width(460)

	SpellBookFrameInset:StripTextures(true);
	SpellBookSpellIconsFrame:StripTextures(true);
	SpellBookSideTabsFrame:StripTextures(true);
	SpellBookPageNavigationFrame:StripTextures(true);

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
			if(region:GetObjectType() == "Texture") then
				if(region ~= button.FlyoutArrow) then
					region:SetTexture(nil)
				end
			end
		end

		button:CreateBackdrop("Default", true)
		button.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() - 1)

		icon:SetTexCoord(unpack(E.TexCoords))
		button:Size(40)

		button.bg = CreateFrame("Frame", nil, button)
		button.bg:CreateBackdrop("Transparent", true);
		button.bg:Point("TOPLEFT", -7, 8);
		button.bg:Point("BOTTOMRIGHT", 170, -12);
		button.bg:SetFrameLevel(button.bg:GetFrameLevel() - 2)

		if(cooldown) then
			E:RegisterCooldown(cooldown);
		end
	end

	hooksecurefunc("SpellButton_UpdateButton", function(self)
		local name = self:GetName()
		local spellName = _G[name .. "SpellName"]
		local spellSubName = _G[name .. "SubSpellName"]
		local spellLevel = _G[name .. "RequiredLevelString"]
		local highlight = _G[name .. "Highlight"]

		if(highlight) then
			highlight:SetTexture(1, 1, 1, 0.3)
		end

		local r, g, b = spellName:GetTextColor()

		if(r < 0.8) then
			spellName:SetTextColor(0.6, 0.6, 0.6)

			if(spellSubName) then
				spellSubName:SetTextColor(0.6, 0.6, 0.6)
			end
		else
			if(spellSubName) then
				spellSubName:SetTextColor(1, 1, 1)
			end
		end

		if(spellSubName) then
			spellSubName:FontTemplate(nil, 12)
		end

		if(spellLevel) then
			spellLevel:SetTextColor(0.6, 0.6, 0.6)
		end
	end)

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

	--What Has Changed Frame
	local _, class = UnitClass("player");
	local classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class];
	local changedList = WHAT_HAS_CHANGED_DISPLAY[class];

	SpellBookWhatHasChanged:Point("TOPLEFT", -80, 5)
	SpellBookWhatHasChanged.ClassName:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
	SpellBookWhatHasChanged.ClassName:Point("TOP", 37, -30)

	if(changedList) then
		for i = 1, #changedList do
			local frame = SpellBook_GetWhatChangedItem(i);

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

	--Core Abilities Frame
	SpellBookCoreAbilitiesFrame:Point("TOPLEFT", -80, 5)

	SpellBookCoreAbilitiesFrame.SpecName:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
	SpellBookCoreAbilitiesFrame.SpecName:Point("TOP", 37, -30)

	hooksecurefunc("SpellBook_UpdateCoreAbilitiesTab", function()
		for i = 1, #SpellBookCoreAbilitiesFrame.Abilities do
			local button = SpellBookCoreAbilitiesFrame.Abilities[i]
			if(button and button.isSkinned ~= true) then
				if(button.highlightTexture) then
					hooksecurefunc(button.highlightTexture, "SetTexture", function(_, texOrR)
						if(texOrR == [[Interface\Buttons\ButtonHilight-Square]]) then
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
				button.bg:SetFrameLevel(button.bg:GetFrameLevel() - 1)

				button.isSkinned = true
			end

			if(button) then
				if(button.FutureTexture:IsShown()) then
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

			if(tab and tab.isSkinned ~= true) then
				tab:GetRegions():Hide()
				tab:CreateBackdrop("Default")
				tab.backdrop:SetAllPoints()

				tab:GetNormalTexture():SetInside()
				tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))

				tab:StyleButton(nil, true)

				if(i == 1) then
					tab:Point("TOPLEFT", SpellBookFrame, "TOPRIGHT", -1, -75)
				end

				tab.isSkinned = true
			end
		end
	end)

	--Skill Line Tabs
	local function SkinTab(tab)
		tab:StripTextures()
		tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		tab:GetNormalTexture():SetInside()

		tab.pushed = true;
		tab:CreateBackdrop("Default")
		tab.backdrop:SetAllPoints()
		tab:StyleButton(true)
		hooksecurefunc(tab:GetHighlightTexture(), "SetTexture", function(self, texPath)
			if(texPath ~= nil) then
				self:SetPushedTexture(nil);
			end
		end)

		hooksecurefunc(tab:GetCheckedTexture(), "SetTexture", function(self, texPath)
			if(texPath ~= nil) then
				self:SetHighlightTexture(nil);
			end
		end)

		local point, relatedTo, point2, x, y = tab:GetPoint()
		tab:Point(point, relatedTo, point2, 1, y)
	end

	for i = 1, MAX_SKILLLINE_TABS do
		local tab = _G["SpellBookSkillLineTab"..i]
		_G["SpellBookSkillLineTab"..i.."Flash"]:Kill()
		SkinTab(tab)
		tab:StyleButton(nil, true);
	end

	SpellBookSkillLineTab1:Point("TOPLEFT", SpellBookSideTabsFrame, "TOPRIGHT", -1, -40)

	--Bottom Tabs
	for i = 1, 5 do
		S:HandleTab(_G["SpellBookFrameTabButton"..i])
	end

	SpellBookFrameTabButton1:ClearAllPoints()
	SpellBookFrameTabButton1:Point("TOPLEFT", SpellBookFrame, "BOTTOMLEFT", 0, 2)

	-- Primary Professions
	PrimaryProfession1:Point("TOPLEFT", 10, -30)
	PrimaryProfession2:Point("TOPLEFT", 10, -130)

	for i = 1, 2 do
		local primaryProf = _G["PrimaryProfession"..i]
		local primaryBar = _G["PrimaryProfession"..i.."StatusBar"]
		local primaryRank = _G["PrimaryProfession"..i.."Rank"]
		local primaryUnlearn = _G["PrimaryProfession"..i.."UnlearnButton"]
		local primarySpellTop = _G["PrimaryProfession"..i.."SpellButtonTop"]
		local primarySpellBot = _G["PrimaryProfession"..i.."SpellButtonBottom"]
		local primaryMissing = _G["PrimaryProfession"..i.."Missing"]
		local primarySpellButtonTop = _G["PrimaryProfession"..i.."SpellButtonTop"]
		local primarySpellButtonTopTex = _G["PrimaryProfession"..i.."SpellButtonTopIconTexture"]
		local primarySpellButtonBot = _G["PrimaryProfession"..i.."SpellButtonBottom"]
		local primarySpellButtonBotTex = _G["PrimaryProfession"..i.."SpellButtonBottomIconTexture"]
		local cooldown1 = _G["PrimaryProfession"..i.."SpellButtonTopCooldown"]
		local cooldown2 = _G["PrimaryProfession"..i.."SpellButtonBottomCooldown"]

		primaryProf:CreateBackdrop("Transparent")
		primaryProf:Height(90)

		primaryBar:StripTextures()
		primaryBar:CreateBackdrop("Default")
		primaryBar:SetStatusBarTexture(E["media"].normTex)
		primaryBar:SetStatusBarColor(0.11, 0.50, 1.00)
		primaryBar:Size(180, 20)
		primaryBar:Point("TOPLEFT", 250, -10)

		primaryBar.rankText:ClearAllPoints()
		primaryBar.rankText:Point("CENTER", primaryBar)
		primaryBar.rankText:FontTemplate(nil, 12, "OUTLINE");

		primaryRank:Point("TOPLEFT", 118, -24)
		primaryRank:FontTemplate(nil, 12, "OUTLINE")
		primaryUnlearn:Point("RIGHT", primaryBar, "LEFT", -135, -10)

		primarySpellTop:Point("TOPRIGHT", primaryProf, "TOPRIGHT", -225, -45)
		primarySpellBot:Point("TOPLEFT", primarySpellTop, "BOTTOMLEFT", 135, 40)

		primaryMissing:SetTextColor(1, 0.80, 0.10)

		primaryProf.missingText:SetTextColor(1, 1, 1)
		primaryProf.missingText:FontTemplate(nil, 12, "OUTLINE")

		primarySpellButtonTop:StripTextures()
		primarySpellButtonTop:CreateBackdrop("Default", true)
		primarySpellButtonTop:GetHighlightTexture():Hide()
		primarySpellButtonTop:StyleButton(true)
		primarySpellButtonTop.pushed:SetAllPoints()
		primarySpellButtonTop.checked:SetAllPoints()
		primarySpellButtonTop:SetFrameLevel(primarySpellButtonTop:GetFrameLevel() + 2)

		primarySpellButtonTopTex:SetTexCoord(unpack(E.TexCoords))
		primarySpellButtonTopTex:SetAllPoints()

		primarySpellButtonBot:StripTextures()
		primarySpellButtonBot:CreateBackdrop("Default", true)
		primarySpellButtonBot:GetHighlightTexture():Hide()
		primarySpellButtonBot:StyleButton(true)
		primarySpellButtonBot.pushed:SetAllPoints()
		primarySpellButtonBot.checked:SetAllPoints()
		primarySpellButtonBot:SetFrameLevel(primarySpellButtonBot:GetFrameLevel() + 2)

		primarySpellButtonBotTex:SetTexCoord(unpack(E.TexCoords))
		primarySpellButtonTopTex:SetAllPoints()

		_G["PrimaryProfession"..i.."SpellButtonTopSubSpellName"]:SetTextColor(1, 1, 1)
		_G["PrimaryProfession"..i.."SpellButtonBottomSubSpellName"]:SetTextColor(1, 1, 1)

		_G["PrimaryProfession"..i.."IconBorder"]:Hide()
		_G["PrimaryProfession"..i.."Icon"]:SetTexCoord(unpack(E.TexCoords))

		if(cooldown1) then
			E:RegisterCooldown(cooldown1);
			cooldown1:SetAllPoints()
		end

		if(cooldown2) then
			E:RegisterCooldown(cooldown2);
			cooldown2:SetAllPoints()
		end
	end

	-- Secondary Professions
	for i = 1, 4 do
		local secondaryProf = _G["SecondaryProfession"..i]
		local secondaryBar = _G["SecondaryProfession"..i.."StatusBar"]
		local secondaryRank = _G["SecondaryProfession"..i.."Rank"]
		local spellButtonRight = _G["SecondaryProfession"..i.."SpellButtonRight"]
		local secondaryMissing =  _G["SecondaryProfession"..i.."Missing"]
		local secondarySpellButtonLeft = _G["SecondaryProfession"..i.."SpellButtonLeft"]
		local secondarySpellButtonLeftTex = _G["SecondaryProfession"..i.."SpellButtonLeftIconTexture"]
		local secondarySpellButtonRight = _G["SecondaryProfession"..i.."SpellButtonRight"]
		local secondarySpellButtonRightTex = _G["SecondaryProfession"..i.."SpellButtonRightIconTexture"]
		local cooldown1 = _G["SecondaryProfession"..i.."SpellButtonLeftCooldown"]
		local cooldown2 = _G["SecondaryProfession"..i.."SpellButtonRightCooldown"]

		secondaryProf:CreateBackdrop("Transparent")
		secondaryProf:Height(60)

		secondaryBar:StripTextures()
		secondaryBar:CreateBackdrop("Default")
		secondaryBar:SetStatusBarTexture(E["media"].normTex)
		secondaryBar:SetStatusBarColor(0.11, 0.50, 1.00)
		secondaryBar:Size(120, 18)
		secondaryBar:Point("TOPLEFT", 5, -35)

		secondaryBar.rankText:ClearAllPoints()
		secondaryBar.rankText:Point("CENTER", secondaryBar)
		secondaryBar.rankText:FontTemplate(nil, 12, "OUTLINE");

		secondaryRank:FontTemplate(nil, 12, "OUTLINE")

		spellButtonRight:Point("TOPRIGHT", -90, -10)

		secondaryMissing:SetTextColor(1, 0.80, 0.10)

		secondaryProf.missingText:SetTextColor(1, 1, 1)
		secondaryProf.missingText:FontTemplate(nil, 12, "OUTLINE")

		secondarySpellButtonLeft:StripTextures()
		secondarySpellButtonLeft:CreateBackdrop("Default", true)
		secondarySpellButtonLeft:GetHighlightTexture():Hide()
		secondarySpellButtonLeft:StyleButton(true)
		secondarySpellButtonLeft.pushed:SetAllPoints()
		secondarySpellButtonLeft.checked:SetAllPoints()
		secondarySpellButtonLeft:SetFrameLevel(secondarySpellButtonLeft:GetFrameLevel() + 2)
		secondarySpellButtonLeft:Point("TOPRIGHT", secondarySpellButtonRight, "TOPLEFT", -96, 0)

		secondarySpellButtonLeftTex:SetTexCoord(unpack(E.TexCoords))
		secondarySpellButtonLeftTex:SetAllPoints()

		secondarySpellButtonRight:StripTextures()
		secondarySpellButtonRight:CreateBackdrop("Default", true)
		secondarySpellButtonRight:GetHighlightTexture():Hide()
		secondarySpellButtonRight:StyleButton(true)
		secondarySpellButtonRight.pushed:SetAllPoints()
		secondarySpellButtonRight.checked:SetAllPoints()
		secondarySpellButtonRight:SetFrameLevel(secondarySpellButtonRight:GetFrameLevel() + 2)

		secondarySpellButtonRightTex:SetTexCoord(unpack(E.TexCoords))
		secondarySpellButtonRightTex:SetAllPoints()

		_G["SecondaryProfession"..i.."SpellButtonRightSubSpellName"]:SetTextColor(1, 1, 1)
		_G["SecondaryProfession"..i.."SpellButtonLeftSubSpellName"]:SetTextColor(1, 1, 1)

		if(cooldown1) then
			E:RegisterCooldown(cooldown1);
			cooldown1:SetAllPoints()
		end

		if(cooldown2) then
			E:RegisterCooldown(cooldown2);
			cooldown2:SetAllPoints()
		end
	end
end

S:AddCallback("Spellbook", LoadSkin);