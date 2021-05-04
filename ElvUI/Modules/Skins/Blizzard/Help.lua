local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local select = select

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.help then return end

	local frames = {
		"HelpFrameLeftInset",
		"HelpFrameMainInset",
		"HelpFrameKnowledgebase"
	}

	for i = 1, #frames do
		local frame = _G[frames[i]]

		frame:StripTextures(true)
		frame:CreateBackdrop("Transparent")
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
		local button = _G[buttons[i]]

		button:StripTextures(true)
		S:HandleButton(button, true)

		if button.text then
			button.text:ClearAllPoints()
			button.text:Point("CENTER")
			button.text:SetJustifyH("CENTER")
		end
	end

	HelpFrameHeader:StripTextures(true)

	HelpFrame:StripTextures(true)
	HelpFrame:CreateBackdrop("Transparent")

	S:HandleCloseButton(HelpFrameCloseButton, HelpFrame.backdrop)

	for i = 1, 6 do
		local button = _G["HelpFrameButton"..i]

		S:HandleButton(button, true)
		button.text:ClearAllPoints()
		button.text:Point("CENTER")
		button.text:SetJustifyH("CENTER")
	end

	-- Knowledgebase
	HelpFrameKnowledgebaseErrorFrame:StripTextures(true)
	HelpFrameKnowledgebaseErrorFrame:CreateBackdrop()

	S:HandleScrollBar(HelpFrameKnowledgebaseScrollFrame2ScrollBar)

	S:HandleEditBox(HelpFrameKnowledgebaseSearchBox)
	HelpFrameKnowledgebaseSearchBox:ClearAllPoints()
	HelpFrameKnowledgebaseSearchBox:Point("TOPLEFT", HelpFrameMainInset, "TOPLEFT", 13, -10)

	S:HandleScrollBar(HelpFrameKnowledgebaseScrollFrameScrollBar)

	for i = 1, HelpFrameKnowledgebaseScrollFrameScrollChild:GetNumChildren() do
		S:HandleButton(_G["HelpFrameKnowledgebaseScrollFrameButton"..i])
	end

	S:HandleCloseButton(HelpFrameKnowledgebaseErrorFrameCloseButton, HelpFrameKnowledgebaseErrorFrame.backdrop)

	for _, frame in pairs({"HelpFrameReportBug", "HelpFrameTicket", "HelpFrameSubmitSuggestion"}) do
		local scrollFrame = _G[frame.."ScrollFrame"]
		local scrollBar = _G[frame.."ScrollFrameScrollBar"]

		for i = 1, _G[frame]:GetNumChildren() do
			local child = select(i, _G[frame]:GetChildren())

			if not child:GetName() then
				child:StripTextures()
			end
		end

		scrollFrame:StripTextures()
		scrollFrame:CreateBackdrop("Transparent")
		scrollFrame.backdrop:Point("TOPLEFT", -4, 4)
		scrollFrame.backdrop:Point("BOTTOMRIGHT", 6, -4)

		S:HandleScrollBar(scrollBar)
	end

	-- Hearthstone Button
	S:HandleItemButton(HelpFrameCharacterStuckHearthstone, true)
	HelpFrameCharacterStuckHearthstone:GetHighlightTexture():SetTexture(1, 1, 1, 0.3)
	HelpFrameCharacterStuckHearthstone.SetHighlightTexture = E.noop

	E:RegisterCooldown(HelpFrameCharacterStuckHearthstoneCooldown)

	S:HandleButton(HelpFrameGM_ResponseNeedMoreHelp)
	S:HandleButton(HelpFrameGM_ResponseCancel)

	for i = 1, HelpFrameGM_Response:GetNumChildren() do
		local child = select(i, HelpFrameGM_Response:GetChildren())
		if child and child:GetObjectType() == "Frame" and not child:GetName() then
			child:SetTemplate()
		end
	end

	-- NavBar
	HelpFrameKnowledgebaseNavBarOverlay:Kill()
	HelpFrameKnowledgebaseNavBar:StripTextures()
	HelpFrameKnowledgebaseNavBar:SetTemplate()

	local function navButtonFrameLevel(self)
		for i = 1, #self.navList do
			local navButton = self.navList[i]
			local lastNav = self.navList[i - 1]

			if navButton and lastNav then
				navButton:SetFrameLevel(lastNav:GetFrameLevel() + 2)
				navButton:ClearAllPoints()
				navButton:Point("LEFT", lastNav, "RIGHT", 1, 0)
			end
		end
	end

	hooksecurefunc("NavBar_AddButton", function(self)
		if self:GetParent():GetName() == "HelpFrameKnowledgebase" then
			local navButton = self.navList[#self.navList]

			if navButton and not navButton.isSkinned then
				S:HandleButton(navButton, true)

				navButton:HookScript("OnClick", function()
					navButtonFrameLevel(self)
				end)

				navButton.isSkinned = true
			end

			navButtonFrameLevel(self)
		end
	end)
end

S:AddCallback("Help", LoadSkin)