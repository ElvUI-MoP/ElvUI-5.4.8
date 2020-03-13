local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.archaeology ~= true then return end

	-- Main Frame
	ArchaeologyFrameInset:StripTextures(true)

	local ArchaeologyFrame = _G["ArchaeologyFrame"]
	ArchaeologyFrame:StripTextures(true)
	ArchaeologyFrame:SetTemplate("Transparent")
	ArchaeologyFrame:Width(500)

	S:HandleCloseButton(ArchaeologyFrameCloseButton)

	-- Status Rank Bar
	ArchaeologyFrameRankBar:StripTextures()
	ArchaeologyFrameRankBar:CreateBackdrop("Default")
	ArchaeologyFrameRankBar:SetStatusBarTexture(E.media.normTex)
	ArchaeologyFrameRankBar:SetStatusBarColor(0.22, 0.39, 0.84)
	ArchaeologyFrameRankBar:Size(332, 20)
	ArchaeologyFrameRankBar:ClearAllPoints()
	ArchaeologyFrameRankBar.ClearAllPoints = E.noop
	ArchaeologyFrameRankBar:Point("TOP", ArchaeologyFrame, "TOP", 0, -50)
	ArchaeologyFrameRankBar.SetPoint = E.noop

	-- Solve Rank Bar
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:StripTextures()
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:CreateBackdrop("Default")
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStatusBarTexture(E.media.normTex)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStatusBarColor(0.7, 0.2, 0)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:Width(460)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:Point("TOP", -15, -40)

	-- Help Button
	ArchaeologyFrameInfoButton:GetHighlightTexture():Kill()
	ArchaeologyFrameInfoButtonTexture:SetTexCoord(unpack(E.TexCoords))
	ArchaeologyFrameInfoButton:Point("TOPLEFT", 5, -5)

	-- Help Frame
	select(2, ArchaeologyFrameHelpPage:GetRegions()):SetTexture("")
	select(3, ArchaeologyFrameHelpPage:GetRegions()):SetTexture("")

	ArchaeologyFrameHelpPageDigTex:SetTexCoord(0.05, 0.885, 0.055, 0.9)
	ArchaeologyFrameHelpPageDigTex:Point("LEFT", -35, 0)

	ArchaeologyFrameHelpPage:CreateBackdrop("Transparent", true)
	ArchaeologyFrameHelpPage.backdrop:Point("TOPLEFT", -28, -235)
	ArchaeologyFrameHelpPage.backdrop:Point("BOTTOMRIGHT", -22, 37)

	ArchaeologyFrameHelpPageHelpScroll:CreateBackdrop("Transparent")
	ArchaeologyFrameHelpPageHelpScroll.backdrop:Point("TOPLEFT", -15, 30)
	ArchaeologyFrameHelpPageHelpScroll.backdrop:Point("BOTTOMRIGHT", 10, 37)

	ArchaeologyFrameHelpPageHelpScroll:ClearAllPoints()
	ArchaeologyFrameHelpPageHelpScroll:Point("TOP", ArchaeologyFrameHelpPage, -22, -60)

	ArchaeologyFrameHelpPageTitle:SetTextColor(1, 0.80, 0.10)
	ArchaeologyFrameHelpPageTitle:Point("TOP", -22, -40)

	ArchaeologyFrameHelpPageDigTitle:SetTextColor(1, 0.80, 0.10)
	ArchaeologyFrameHelpPageDigTitle:Point("TOP", ArchaeologyFrameHelpPageDigTex, 0, -10)

	ArchaeologyFrameHelpPageHelpScrollHelpText:SetTextColor(1, 1, 1)

	-- Artifact Page
	ArchaeologyFrameArtifactPage:CreateBackdrop("Transparent")
	ArchaeologyFrameArtifactPage.backdrop:Point("TOPLEFT", -45, -45)
	ArchaeologyFrameArtifactPage.backdrop:Point("BOTTOMRIGHT", 0, 95)

	ArchaeologyFrameArtifactPageHistoryScroll:ClearAllPoints()
	ArchaeologyFrameArtifactPageHistoryScroll:Point("BOTTOMLEFT", ArchaeologyFrameArtifactPageSolveFrame, -40, 70)

	ArchaeologyFrameArtifactPageHistoryScrollChildText:SetTextColor(1, 1, 1)

	select(2, ArchaeologyFrameArtifactPage:GetRegions()):SetTexture("")
	select(3, ArchaeologyFrameArtifactPage:GetRegions()):SetTexture("")

	ArchaeologyFrameArtifactPageHistoryTitle:SetAlpha(0)

	ArchaeologyFrameArtifactPageIcon.backdrop = CreateFrame("Frame", nil, ArchaeologyFrameArtifactPage)
	ArchaeologyFrameArtifactPageIcon.backdrop:SetTemplate("Default")
	ArchaeologyFrameArtifactPageIcon.backdrop:Point("TOPLEFT", ArchaeologyFrameArtifactPageIcon, "TOPLEFT", -1, 1)
	ArchaeologyFrameArtifactPageIcon.backdrop:Point("BOTTOMRIGHT", ArchaeologyFrameArtifactPageIcon, "BOTTOMRIGHT", 1, -1)

	ArchaeologyFrameArtifactPageIcon:SetTexCoord(unpack(E.TexCoords))
	ArchaeologyFrameArtifactPageIcon:SetParent(ArchaeologyFrameArtifactPageIcon.backdrop)
	ArchaeologyFrameArtifactPageIcon:SetDrawLayer("OVERLAY")
	ArchaeologyFrameArtifactPageIcon:Point("TOPLEFT", ArchaeologyFrameArtifactPage, "TOPLEFT", -40, -50)

	ArchaeologyFrameArtifactPage.glow:Kill()

	ArchaeologyFrameArtifactPageRaceBG:ClearAllPoints()
	ArchaeologyFrameArtifactPageRaceBG:Point("TOPRIGHT", ArchaeologyFrameArtifactPage, "TOPRIGHT", 10, -40)

	ArchaeologyFrameArtifactPageArtifactBG:ClearAllPoints()
	ArchaeologyFrameArtifactPageArtifactBG:Point("TOPRIGHT", ArchaeologyFrameArtifactPage, "TOPRIGHT", 0, -45)

	S:HandleButton(ArchaeologyFrameArtifactPageSolveFrameSolveButton, true)
	ArchaeologyFrameArtifactPageSolveFrameSolveButton:Point("BOTTOMRIGHT", 0, -10)

	S:HandleButton(ArchaeologyFrameArtifactPageBackButton, true)
	ArchaeologyFrameArtifactPageBackButton:Point("BOTTOMLEFT", ArchaeologyFrameArtifactPage, "BOTTOMLEFT", 350, 15)

	ArchaeologyFrameArtifactPageSolveFrameKeystone1:Point("BOTTOMLEFT", -25, -30)

	-- Summary Page
	select(2, ArchaeologyFrameSummaryPage:GetRegions()):SetTexture("")
	select(3, ArchaeologyFrameSummaryPage:GetRegions()):SetTexture("")

	ArchaeologyFrameSummaryPageRace1:Point("TOPLEFT", 15, -65)
	ArchaeologyFrameSummaryPageRace5:Point("TOPLEFT", ArchaeologyFrameSummaryPageRace1, "BOTTOMLEFT", 0, -42)
	ArchaeologyFrameSummaryPageRace9:Point("TOPLEFT", ArchaeologyFrameSummaryPageRace5, "BOTTOMLEFT", 0, -42)

	for i = 1, ARCHAEOLOGY_MAX_RACES do
		local frame = _G["ArchaeologyFrameSummaryPageRace"..i]

		if frame then
			frame:CreateBackdrop("Transparent", true)
			frame:HookScript("OnEnter", S.SetModifiedBackdrop)
			frame:HookScript("OnLeave", S.SetOriginalBackdrop)

			frame.raceName:ClearAllPoints()
			frame.raceName:Point("BOTTOM", frame, "BOTTOM", 0, -30)
			frame.raceName:SetTextColor(1, 1, 1)
		end
	end

	ArchaeologyFrameSummaryPageTitle:Point("TOP", ArchaeologyFrameSummaryPage, "TOP", -25, -42)
	ArchaeologyFrameSummaryPageTitle:SetTextColor(1, 0.80, 0.10)

	-- Completed Page
	for i = 1, ARCHAEOLOGY_MAX_COMPLETED_SHOWN do
		local artifact = _G["ArchaeologyFrameCompletedPageArtifact"..i]

		if artifact then
			artifact:SetTemplate("Transparent")
			artifact:StyleButton()

			artifact.icon.bg = CreateFrame("Frame", nil, artifact)
			artifact.icon.bg:SetTemplate()
			artifact.icon.bg:Point("TOPLEFT", artifact.icon, -1, 1)
			artifact.icon.bg:Point("BOTTOMRIGHT", artifact.icon, 1, -1)
			artifact.icon.bg:SetFrameLevel(artifact.icon.bg:GetFrameLevel() + 2)

			artifact.icon:SetTexCoord(unpack(E.TexCoords))
			artifact.icon:SetDrawLayer("OVERLAY")
			artifact.icon:Size(42)
			artifact.icon:SetParent(artifact.icon.bg)

			artifact.border:Kill()

			artifact.artifactName:SetTextColor(1, 0.80, 0.10)
			artifact.artifactSubText:SetTextColor(0.6, 0.6, 0.6)
		end
	end

	for i = 1, ArchaeologyFrameCompletedPage:GetNumRegions() do
		local region = select(i, ArchaeologyFrameCompletedPage:GetRegions())
		if region:GetObjectType() == "FontString" then
			region:SetTextColor(1, 1, 1)
			region:Point("LEFT", -10, 0)
		end
	end

	select(3, ArchaeologyFrameCompletedPage:GetRegions()):SetTexture("")
	select(4, ArchaeologyFrameCompletedPage:GetRegions()):SetTexture("")
	select(6, ArchaeologyFrameCompletedPage:GetRegions()):SetTexture("")
	select(7, ArchaeologyFrameCompletedPage:GetRegions()):SetTexture("")
	select(9, ArchaeologyFrameCompletedPage:GetRegions()):SetTexture("")
	select(10, ArchaeologyFrameCompletedPage:GetRegions()):SetTexture("")

	ArchaeologyFrameCompletedPage.infoText:SetTextColor(1, 1, 1)

	S:HandleButton(ArchaeologyFrameCompletedPageNextPageButton)

	S:HandleButton(ArchaeologyFrameCompletedPagePrevPageButton)
	ArchaeologyFrameCompletedPagePrevPageButton:ClearAllPoints()
	ArchaeologyFrameCompletedPagePrevPageButton:Point("LEFT", ArchaeologyFrameCompletedPagePageText, "RIGHT", 10, 0)

	ArchaeologyFrameCompletedPage.pageText:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPage.pageText:Point("BOTTOMRIGHT", -75, 15)

	ArchaeologyFrameCompletedPageArtifact1:Point("TOPLEFT", -10, -85)

	-- Summary / Complete Tabs
	ArchaeologyFrameSummarytButton:StripTextures()
	ArchaeologyFrameSummarytButton:SetTemplate("Transparent")
	ArchaeologyFrameSummarytButton:Size(45, 38)
	ArchaeologyFrameSummarytButton:StyleButton()
	ArchaeologyFrameSummarytButton:Point("TOPLEFT", ArchaeologyFrame, "TOPRIGHT", E.PixelMode and -1 or 1, -50)

	ArchaeologyFrameSummarytButton.icon = ArchaeologyFrameSummarytButton:CreateTexture(nil, "ARTWORK")
	ArchaeologyFrameSummarytButton.icon:SetTexture("Interface\\ARCHEOLOGY\\ARCH-RACE-TOLVIR")
	ArchaeologyFrameSummarytButton.icon:SetTexCoord(0, 0.58, 0.100, 0.33)
	ArchaeologyFrameSummarytButton.icon:Point("TOPLEFT", -5, -6)
	ArchaeologyFrameSummarytButton.icon:Point("BOTTOMRIGHT", 5, 6)

	ArchaeologyFrameCompletedButton:StripTextures()
	ArchaeologyFrameCompletedButton:SetTemplate("Transparent")
	ArchaeologyFrameCompletedButton:Size(45, 38)
	ArchaeologyFrameCompletedButton:StyleButton()
	ArchaeologyFrameCompletedButton:Point("TOPLEFT", ArchaeologyFrame, "TOPRIGHT", E.PixelMode and -1 or 1, -100)

	ArchaeologyFrameCompletedButton.icon = ArchaeologyFrameCompletedButton:CreateTexture(nil, "ARTWORK")
	ArchaeologyFrameCompletedButton.icon:SetTexture("Interface\\ARCHEOLOGY\\ARCH-RACE-TOLVIR")
	ArchaeologyFrameCompletedButton.icon:SetTexCoord(0, 0.58, 0.344, 0.68)
	ArchaeologyFrameCompletedButton.icon:Point("TOPLEFT", -3, -7)
	ArchaeologyFrameCompletedButton.icon:Point("BOTTOMRIGHT", 3, -18)

	hooksecurefunc("ArchaeologyFrame_OnTabClick", function(self)
		local archFrame = self:GetParent()
		archFrame.selectedTab = self:GetID()

		if archFrame.selectedTab ==  ARCHAEOLOGY_HELP_TAB or archFrame.selectedTab ==  ARCHAEOLOGY_SUMMARY_TAB then
			archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB].icon:SetDesaturated(false)
			archFrame["tab"..ARCHAEOLOGY_COMPLETED_TAB].icon:SetDesaturated(true)
		elseif archFrame.selectedTab ==  ARCHAEOLOGY_COMPLETED_TAB then
			archFrame["tab"..ARCHAEOLOGY_COMPLETED_TAB].icon:SetDesaturated(false)
			archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB].icon:SetDesaturated(true)
		end
	end)

	-- Filter Dropdown
	S:HandleDropDownBox(ArchaeologyFrameRaceFilter, 125)
	ArchaeologyFrameRaceFilter:Point("TOPRIGHT", -25, -3)

	-- Dig Site Progress Bar
	ArcheologyDigsiteProgressBar:StripTextures()
	ArcheologyDigsiteProgressBar:ClearAllPoints()
	ArcheologyDigsiteProgressBar:Point("TOP", UIParent, "TOP", 0, -400)

	ArcheologyDigsiteProgressBar.FillBar:StripTextures()
	ArcheologyDigsiteProgressBar.FillBar:CreateBackdrop("Default")
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarColor(0.7, 0.2, 0)
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarTexture(E.media.normTex)
	ArcheologyDigsiteProgressBar.FillBar:SetFrameLevel(ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetFrameLevel() + 2)
	E:RegisterStatusBar(ArcheologyDigsiteProgressBar.FillBar)

	ArcheologyDigsiteProgressBar.BarTitle:FontTemplate(nil, nil, "OUTLINE")

	UIPARENT_MANAGED_FRAME_POSITIONS["ArcheologyDigsiteProgressBar"] = nil
	E:CreateMover(ArcheologyDigsiteProgressBar, "DigSiteProgressBarMover", L["Archeology Progress Bar"])
end

S:AddCallbackForAddon("Blizzard_ArchaeologyUI", "Archaeology", LoadSkin)