local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G
local unpack, select = unpack, select;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.help ~= true) then return; end

	local frames = {
		"HelpFrameLeftInset",
		"HelpFrameMainInset",
		"HelpFrameKnowledgebase"
	}

	for i = 1, #frames do
		_G[frames[i]]:StripTextures(true)
		_G[frames[i]]:CreateBackdrop("Transparent")
	end

	local buttons = {
		"HelpFrameOpenTicketHelpItemRestoration",
		"HelpFrameAccountSecurityOpenTicket",
		"HelpFrameOpenTicketHelpOpenTicket",
		"HelpFrameKnowledgebaseSearchButton",
		"HelpFrameOpenTicketHelpTopIssues",
		"HelpFrameKnowledgebaseNavBarHomeButton",
		"HelpFrameCharacterStuckStuck",
		"HelpFrameButton16",
		"HelpFrameSubmitSuggestionSubmit",
		"GMChatOpenLog",
		"HelpFrameTicketSubmit",
		"HelpFrameTicketCancel",
		"HelpFrameReportBugSubmit"
	}

	for i = 1, #buttons do
		_G[buttons[i]]:StripTextures(true)
		S:HandleButton(_G[buttons[i]], true)

		if _G[buttons[i]].text then
			_G[buttons[i]].text:ClearAllPoints()
			_G[buttons[i]].text:SetPoint("CENTER")
			_G[buttons[i]].text:SetJustifyH("CENTER")
		end
	end

	HelpFrameHeader:StripTextures(true)

	HelpFrameKnowledgebaseErrorFrame:StripTextures(true)
	HelpFrameKnowledgebaseErrorFrame:CreateBackdrop("Default")
	
	HelpFrameReportBugScrollFrame:StripTextures()
	HelpFrameReportBugScrollFrame:CreateBackdrop("Transparent")
	HelpFrameReportBugScrollFrame.backdrop:Point("TOPLEFT", -4, 4)
	HelpFrameReportBugScrollFrame.backdrop:Point("BOTTOMRIGHT", 6, -4)

	for i = 1, HelpFrameReportBug:GetNumChildren() do
		local child = select(i, HelpFrameReportBug:GetChildren())
		if(not child:GetName()) then
			child:StripTextures()
		end
	end

	S:HandleScrollBar(HelpFrameReportBugScrollFrameScrollBar)
	S:HandleScrollBar(HelpFrameTicketScrollFrameScrollBar)

	HelpFrameTicketScrollFrame:StripTextures()
	HelpFrameTicketScrollFrame:CreateBackdrop("Transparent")
	HelpFrameTicketScrollFrame.backdrop:Point("TOPLEFT", -4, 4)
	HelpFrameTicketScrollFrame.backdrop:Point("BOTTOMRIGHT", 6, -4)

	for i = 1, HelpFrameTicket:GetNumChildren() do
		local child = select(i, HelpFrameTicket:GetChildren())
		if(not child:GetName()) then
			child:StripTextures()
		end
	end

	HelpFrameSubmitSuggestionScrollFrame:StripTextures()
	HelpFrameSubmitSuggestionScrollFrame:CreateBackdrop("Transparent")
	HelpFrameSubmitSuggestionScrollFrame.backdrop:Point("TOPLEFT", -4, 4)
	HelpFrameSubmitSuggestionScrollFrame.backdrop:Point("BOTTOMRIGHT", 6, -4)

	for i = 1, HelpFrameSubmitSuggestion:GetNumChildren() do
		local child = select(i, HelpFrameSubmitSuggestion:GetChildren())
		if(not child:GetName()) then
			child:StripTextures()
		end
	end

	S:HandleScrollBar(HelpFrameSubmitSuggestionScrollFrameScrollBar)
	S:HandleScrollBar(HelpFrameKnowledgebaseScrollFrame2ScrollBar)

	for i = 1, 6 do
		local button = _G["HelpFrameButton"..i]
		S:HandleButton(button, true)
		button.text:ClearAllPoints()
		button.text:SetPoint("CENTER")
		button.text:SetJustifyH("CENTER")
	end

	-- skin table options
	for i = 1, HelpFrameKnowledgebaseScrollFrameScrollChild:GetNumChildren() do
		local button = _G["HelpFrameKnowledgebaseScrollFrameButton"..i]
		button:StripTextures(true)
		S:HandleButton(button, true)
	end

	-- skin misc items
	HelpFrameKnowledgebaseSearchBox:ClearAllPoints()
	HelpFrameKnowledgebaseSearchBox:Point("TOPLEFT", HelpFrameMainInset, "TOPLEFT", 13, -10)

	HelpFrame:StripTextures(true)
	HelpFrame:CreateBackdrop("Transparent")

	S:HandleEditBox(HelpFrameKnowledgebaseSearchBox)
	S:HandleScrollBar(HelpFrameKnowledgebaseScrollFrameScrollBar, 5)
	S:HandleCloseButton(HelpFrameCloseButton, HelpFrame.backdrop)
	S:HandleCloseButton(HelpFrameKnowledgebaseErrorFrameCloseButton, HelpFrameKnowledgebaseErrorFrame.backdrop)

	--Hearth Stone Button
	HelpFrameCharacterStuckHearthstone:SetTemplate("Default", true)
	HelpFrameCharacterStuckHearthstone:GetHighlightTexture():Hide()
	HelpFrameCharacterStuckHearthstone.IconTexture:SetInside()
	HelpFrameCharacterStuckHearthstone.IconTexture:SetTexCoord(unpack(E.TexCoords))

	S:HandleButton(HelpFrameGM_ResponseNeedMoreHelp)
	S:HandleButton(HelpFrameGM_ResponseCancel)

	for i = 1, HelpFrameGM_Response:GetNumChildren() do
		local child = select(i, HelpFrameGM_Response:GetChildren())
		if child and child:GetObjectType() == "Frame" and not child:GetName() then
			child:SetTemplate("Default")
		end
	end

	--NavBar
	HelpFrameKnowledgebaseNavBarOverlay:Kill()
	HelpFrameKnowledgebaseNavBar:StripTextures()

	local function navButtonFrameLevel(self)
		for i = 1, #self.navList do
			local navButton = self.navList[i];
			local lastNav = self.navList[i-1];
			if(navButton and lastNav) then
				navButton:SetFrameLevel(lastNav:GetFrameLevel() - 2);
				navButton:ClearAllPoints();
				navButton:Point("LEFT", lastNav, "RIGHT", 1, 0);
			end
		end
	end

	hooksecurefunc("NavBar_AddButton", function(self)
		if(self:GetParent():GetName() == "EncounterJournal") then return; end

		local navButton = self.navList[#self.navList];

		if(not navButton.skinned) then
			S:HandleButton(navButton, true);
			navButton.skinned = true;

			navButton:HookScript("OnClick", function()
				navButtonFrameLevel(self);
			end)
		end

		navButtonFrameLevel(self);
	end)
end

S:AddCallback("Help", LoadSkin);