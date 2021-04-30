local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.archaeology then return end

	-- Main Frame
	ArchaeologyFrameInset:StripTextures(true)

	ArchaeologyFrame:StripTextures(true)
	ArchaeologyFrame:SetTemplate("Transparent")
	ArchaeologyFrame:Width(500)

	S:HandleCloseButton(ArchaeologyFrameCloseButton)

	-- Status Rank Bar
	ArchaeologyFrameRankBar:StripTextures()
	ArchaeologyFrameRankBar:CreateBackdrop()
	ArchaeologyFrameRankBar:SetStatusBarTexture(E.media.normTex)
	ArchaeologyFrameRankBar:SetStatusBarColor(0.22, 0.39, 0.84)
	ArchaeologyFrameRankBar:Size(332, 20)
	ArchaeologyFrameRankBar:ClearAllPoints()
	ArchaeologyFrameRankBar.ClearAllPoints = E.noop
	ArchaeologyFrameRankBar:Point("TOP", ArchaeologyFrame, 0, -50)
	ArchaeologyFrameRankBar.SetPoint = E.noop

	-- Solve Rank Bar
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:StripTextures()
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:CreateBackdrop()
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

	ArchaeologyFrameHelpPage:CreateBackdrop("Transparent")
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
	ArchaeologyFrameArtifactPageIcon.backdrop:SetTemplate()
	ArchaeologyFrameArtifactPageIcon.backdrop:Point("TOPLEFT", ArchaeologyFrameArtifactPageIcon, -1, 1)
	ArchaeologyFrameArtifactPageIcon.backdrop:Point("BOTTOMRIGHT", ArchaeologyFrameArtifactPageIcon, 1, -1)

	ArchaeologyFrameArtifactPageIcon:SetTexCoord(unpack(E.TexCoords))
	ArchaeologyFrameArtifactPageIcon:SetParent(ArchaeologyFrameArtifactPageIcon.backdrop)
	ArchaeologyFrameArtifactPageIcon:SetDrawLayer("OVERLAY")
	ArchaeologyFrameArtifactPageIcon:Point("TOPLEFT", ArchaeologyFrameArtifactPage, -40, -50)

	ArchaeologyFrameArtifactPage.glow:Kill()

	ArchaeologyFrameArtifactPageRaceBG:ClearAllPoints()
	ArchaeologyFrameArtifactPageRaceBG:Point("TOPRIGHT", ArchaeologyFrameArtifactPage, 10, -40)

	ArchaeologyFrameArtifactPageArtifactBG:ClearAllPoints()
	ArchaeologyFrameArtifactPageArtifactBG:Point("TOPRIGHT", ArchaeologyFrameArtifactPage, 0, -45)

	S:HandleButton(ArchaeologyFrameArtifactPageSolveFrameSolveButton, true)
	ArchaeologyFrameArtifactPageSolveFrameSolveButton:Point("BOTTOMRIGHT", 0, -10)

	S:HandleButton(ArchaeologyFrameArtifactPageBackButton, true)
	ArchaeologyFrameArtifactPageBackButton:Point("BOTTOMLEFT", ArchaeologyFrameArtifactPage, 350, 15)

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
			frame:CreateBackdrop("Transparent")
			frame:HookScript("OnEnter", S.SetModifiedBackdrop)
			frame:HookScript("OnLeave", S.SetOriginalBackdrop)

			frame.raceName:ClearAllPoints()
			frame.raceName:Point("BOTTOM", frame, 0, -30)
			frame.raceName:SetTextColor(1, 1, 1)
		end
	end

	ArchaeologyFrameSummaryPageTitle:Point("TOP", ArchaeologyFrameSummaryPage, -25, -42)
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

		if region.IsObjectType and region:IsObjectType("FontString") then
			region:SetTextColor(1, 1, 1)
			region:Point("LEFT", -10, 0)
		elseif region.IsObjectType and region:IsObjectType("Texture") and region:GetTexture() then
			region:SetTexture("")
		end
	end

	ArchaeologyFrameCompletedPage.infoText:SetTextColor(1, 1, 1)

	S:HandleNextPrevButton(ArchaeologyFrameCompletedPageNextPageButton)
	ArchaeologyFrameCompletedPageNextPageButton:Size(24)

	S:HandleNextPrevButton(ArchaeologyFrameCompletedPagePrevPageButton)
	ArchaeologyFrameCompletedPagePrevPageButton:Size(24)
	ArchaeologyFrameCompletedPagePrevPageButton:Point("LEFT", ArchaeologyFrameCompletedPage.pageText, "RIGHT", 10, 0)

	ArchaeologyFrameCompletedPage.pageText:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPage.pageText:Point("BOTTOMRIGHT", -75, 15)

	ArchaeologyFrameCompletedPageArtifact1:Point("TOPLEFT", -10, -85)

	-- Side Tabs
	for _, tab in pairs({ArchaeologyFrame.tab1, ArchaeologyFrame.tab2}) do
		tab:StripTextures()
		tab:SetTemplate("Transparent")
		tab:StyleButton()
		tab:Size(44, 38)

		tab.icon = tab:CreateTexture(nil, "ARTWORK")
		tab.icon:SetTexture([[Interface\ARCHEOLOGY\ARCH-RACE-TOLVIR]])
	end

	ArchaeologyFrame.tab1:Point("TOPLEFT", ArchaeologyFrame, "TOPRIGHT", E.PixelMode and -1 or 1, -30)

	ArchaeologyFrame.tab1.icon:SetTexCoord(0, 0.58, 0.100, 0.33)
	ArchaeologyFrame.tab1.icon:Point("TOPLEFT", -5, -6)
	ArchaeologyFrame.tab1.icon:Point("BOTTOMRIGHT", 5, 6)

	ArchaeologyFrame.tab2:Point("TOPLEFT", ArchaeologyFrame, "TOPRIGHT", E.PixelMode and -1 or 1, -80)

	ArchaeologyFrame.tab2.icon:SetTexCoord(0, 0.58, 0.344, 0.68)
	ArchaeologyFrame.tab2.icon:Point("TOPLEFT", -3, -7)
	ArchaeologyFrame.tab2.icon:Point("BOTTOMRIGHT", 3, -18)

	hooksecurefunc("ArchaeologyFrame_OnTabClick", function(tab)
		local id = tab:GetID()

		ArchaeologyFrame.tab1.icon:SetDesaturated(id ~= ARCHAEOLOGY_HELP_TAB and id ~= ARCHAEOLOGY_SUMMARY_TAB)
		ArchaeologyFrame.tab2.icon:SetDesaturated(id ~= ARCHAEOLOGY_COMPLETED_TAB)
	end)

	-- Filter Dropdown
	S:HandleDropDownBox(ArchaeologyFrameRaceFilter, 185)
	ArchaeologyFrameRaceFilter:Point("TOPRIGHT", -25, -3)

	-- Dig Site Progress Bar
	ArcheologyDigsiteProgressBar:StripTextures()
	ArcheologyDigsiteProgressBar:ClearAllPoints()
	ArcheologyDigsiteProgressBar:Point("TOP", UIParent, "TOP", 0, -400)

	ArcheologyDigsiteProgressBar.BarTitle:FontTemplate(nil, nil, "OUTLINE")

	ArcheologyDigsiteProgressBar.FillBar:StripTextures()
	ArcheologyDigsiteProgressBar.FillBar:CreateBackdrop("Transparent")
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarTexture(E.media.normTex)
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarColor(1, 0.8, 0.2)
	ArcheologyDigsiteProgressBar.FillBar:SetFrameLevel(ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetFrameLevel() + 2)
	E:RegisterStatusBar(ArcheologyDigsiteProgressBar.FillBar)

	UIPARENT_MANAGED_FRAME_POSITIONS.ArcheologyDigsiteProgressBar = nil
	E:CreateMover(ArcheologyDigsiteProgressBar, "DigSiteProgressBarMover", L["Archeology Progress Bar"])
end

S:AddCallbackForAddon("Blizzard_ArchaeologyUI", "Archaeology", LoadSkin)