local E, L, V, P, G = unpack(select(2, ...))
local M = E:GetModule("Minimap")
local A = E:GetModule("Auras")

local Astrolabe, AstrolabeMapMonitor
if DongleStub then
	Astrolabe = DongleStub("Astrolabe-1.0")
	AstrolabeMapMonitor = DongleStub("AstrolabeMapMonitor")
end

local _G = _G
local unpack = unpack
local format, match, utf8sub = string.format, string.match, string.utf8sub

local CloseAllWindows = CloseAllWindows
local CloseMenus = CloseMenus
local CreateFrame = CreateFrame
local GetMinimapZoneText = GetMinimapZoneText
local GetZonePVPInfo = GetZonePVPInfo
local GuildInstanceDifficulty = GuildInstanceDifficulty
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local IsShiftKeyDown = IsShiftKeyDown
local MainMenuMicroButton_SetNormal = MainMenuMicroButton_SetNormal
local Minimap_OnClick = Minimap_OnClick
local PlaySound = PlaySound
local ShowUIPanel, HideUIPanel = ShowUIPanel, HideUIPanel
local UIErrorsFrame = UIErrorsFrame
local ToggleDropDownMenu = ToggleDropDownMenu
local ToggleAchievementFrame = ToggleAchievementFrame
local ToggleCharacter = ToggleCharacter
local ToggleFrame = ToggleFrame
local ToggleFriendsFrame = ToggleFriendsFrame
local ToggleGuildFrame = ToggleGuildFrame
local ToggleHelpFrame = ToggleHelpFrame

local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", E.UIParent, "UIDropDownMenuTemplate")
local guildText = IsInGuild() and ACHIEVEMENTS_GUILD_TAB or LOOKINGFORGUILD
local menuList = {
	{text = CHARACTER_BUTTON, notCheckable = 1, func = function()
		ToggleCharacter("PaperDollFrame")
	end},
	{text = SPELLBOOK_ABILITIES_BUTTON, notCheckable = 1, func = function()
		ToggleFrame(SpellBookFrame)
	end},
	{text = TALENTS_BUTTON, notCheckable = 1, func = function()
		if not PlayerTalentFrame then
			TalentFrame_LoadUI()
		end
		if not GlyphFrame then
			GlyphFrame_LoadUI()
		end
		if not PlayerTalentFrame:IsShown() then
			ShowUIPanel(PlayerTalentFrame)
		else
			HideUIPanel(PlayerTalentFrame)
		end
	end},
	{text = MOUNTS_AND_PETS, notCheckable = 1, func = function()
		TogglePetJournal()
	end},
	{text = ACHIEVEMENT_BUTTON, notCheckable = 1, func = function()
		ToggleAchievementFrame()
	end},
	{text = QUESTLOG_BUTTON, notCheckable = 1, func = function()
		ToggleFrame(QuestLogFrame)
	end},
	{text = SOCIAL_BUTTON, notCheckable = 1, func = function()
		ToggleFriendsFrame(1)
	end},
	{text = L["Calendar"], notCheckable = 1, func = function()
		if not CalendarFrame then
			LoadAddOn("Blizzard_Calendar")
		end
		Calendar_Toggle()
	end},
	{text = L["Farm Mode"], notCheckable = 1, func = FarmMode},
	{text = BATTLEFIELD_MINIMAP, notCheckable = 1, func = function()
			ToggleBattlefieldMinimap()
	end},
	{text = TIMEMANAGER_TITLE, notCheckable = 1, func = function()
		ToggleTimeManager()
	end},
	{text = guildText, notCheckable = 1, func = function()
		ToggleGuildFrame()
	end},
	{text = PLAYER_V_PLAYER, notCheckable = 1, func = function()
		if UnitLevel("player") >= SHOW_PVP_LEVEL then
			TogglePVPUI()
		else
			UIErrorsFrame:AddMessage(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_PVP_LEVEL), 1, 0.1, 0.1)
		end
	end},
	{text = LFG_TITLE, notCheckable = 1, func = function()
		if UnitLevel("player") >= SHOW_LFD_LEVEL then
			ToggleLFDParentFrame()
		else
			UIErrorsFrame:AddMessage(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_LFD_LEVEL), 1, 0.1, 0.1)
		end
	end},
	{text = ENCOUNTER_JOURNAL, notCheckable = 1, func = function()
		if not IsAddOnLoaded("Blizzard_EncounterJournal") then EncounterJournal_LoadUI() end
		ToggleFrame(EncounterJournal)
	end},
	{text = HELP_BUTTON, notCheckable = 1, func = function()
		ToggleHelpFrame()
	end},
	{text = MAINMENU_BUTTON, notCheckable = 1, func = function()
		if not GameMenuFrame:IsShown() then
			if VideoOptionsFrame:IsShown() then
				VideoOptionsFrameCancel:Click()
			elseif AudioOptionsFrame:IsShown() then
				AudioOptionsFrameCancel:Click()
			elseif InterfaceOptionsFrame:IsShown() then
				InterfaceOptionsFrameCancel:Click()
			end
			CloseMenus()
			CloseAllWindows()
			PlaySound("igMainMenuOpen")
			ShowUIPanel(GameMenuFrame)
		else
			PlaySound("igMainMenuQuit")
			HideUIPanel(GameMenuFrame)
			MainMenuMicroButton_SetNormal()
		end
	end}
}

function M:Minimap_OnMouseUp(btn)
	local position = self:GetPoint()
	if btn == "MiddleButton" or (btn == "RightButton" and IsShiftKeyDown()) then
		if match(position, "LEFT") then
			EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
		else
			EasyMenu(menuList, menuFrame, "cursor", -160, 0, "MENU", 2)
		end
	elseif btn == "RightButton" then
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "cursor")
	else
		Minimap_OnClick(self)
	end
end

function M:GetLocTextColor()
	local pvpType = GetZonePVPInfo()
	if pvpType == "arena" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "friendly" then
		return 0.05, 0.85, 0.03
	elseif pvpType == "contested" then
		return 0.9, 0.85, 0.05
	elseif pvpType == "hostile" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "sanctuary" then
		return 0.035, 0.58, 0.84
	elseif pvpType == "combat" then
		return 0.84, 0.03, 0.03
	else
		return 0.9, 0.85, 0.05
	end
end

function M:Update_ZoneText()
	if E.db.general.minimap.locationText == "HIDE" or not E.private.general.minimap.enable then return end

	Minimap.location:FontTemplate(E.Libs.LSM:Fetch("font", E.db.general.minimap.locationFont), E.db.general.minimap.locationFontSize, E.db.general.minimap.locationFontOutline)
	Minimap.location:SetText(utf8sub(GetMinimapZoneText(), 1, 46))
	Minimap.location:SetTextColor(self:GetLocTextColor())
end

function M:Minimap_OnMouseWheel(d)
	local zoomLevel = Minimap:GetZoom()

	if d > 0 and zoomLevel < 5 then
		Minimap:SetZoom(zoomLevel + 1)
	elseif d < 0 and zoomLevel > 0 then
		Minimap:SetZoom(zoomLevel - 1)
	end
end

local isResetting
local function ResetZoom()
	Minimap:SetZoom(0)
	isResetting = nil
end

local function SetupZoomReset(self, zoomLevel)
	if not isResetting and zoomLevel > 0 and E.db.general.minimap.resetZoom.enable then
		isResetting = true
		E:Delay(E.db.general.minimap.resetZoom.time, ResetZoom)
	end
end

function M:CreateFarmModeMap()
	local fm = CreateFrame("Minimap", "FarmModeMap", E.UIParent)
	fm:Size(E.db.farmSize)
	fm:Point("TOP", E.UIParent, "TOP", 0, -120)
	fm:SetClampedToScreen(true)
	fm:CreateBackdrop()
	fm:EnableMouseWheel(true)
	fm:SetScript("OnMouseWheel", M.Minimap_OnMouseWheel)
	fm:SetScript("OnMouseUp", M.Minimap_OnMouseUp)
	fm:RegisterForDrag("LeftButton", "RightButton")
	fm:SetMovable(true)
	fm:SetScript("OnDragStart", function(self) self:StartMoving() end)
	fm:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	if AstrolabeMapMonitor then AstrolabeMapMonitor:MonitorWorldMap(fm) end
	fm:Hide()
	E.FrameLocks["FarmModeMap"] = true

	self.farmModeMap = fm

	fm:SetScript("OnShow", function()
		if BuffMover and not E:HasMoverBeenMoved("BuffMover") then
			BuffMover:ClearAllPoints()
			BuffMover:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -3, -3)
		end

		if DebuffMover and not E:HasMoverBeenMoved("DebuffMover") then
			DebuffMover:ClearAllPoints()
			DebuffMover:Point("TOPRIGHT", ElvUIPlayerBuffs, "BOTTOMRIGHT", 0, -3)
		end

		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetAllPoints(fm)

		if IsAddOnLoaded("Routes") then
			LibStub("AceAddon-3.0"):GetAddon("Routes"):ReparentMinimap(fm)
		end

		if IsAddOnLoaded("GatherMate2") then
			LibStub("AceAddon-3.0"):GetAddon("GatherMate2"):GetModule("Display"):ReparentMinimapPins(fm)
		end
		if Astrolabe then Astrolabe:SetTargetMinimap(FarmModeMap) end
	end)

	fm:SetScript("OnHide", function()
		if BuffMover and not E:HasMoverBeenMoved("BuffMover") then
			E:ResetMovers(L["Player Buffs"])
		end

		if DebuffMover and not E:HasMoverBeenMoved("DebuffMover") then
			E:ResetMovers(L["Player Debuffs"])
		end

		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetAllPoints(Minimap)

		if IsAddOnLoaded("Routes") then
			LibStub("AceAddon-3.0"):GetAddon("Routes"):ReparentMinimap(Minimap)
		end

		if IsAddOnLoaded("GatherMate2") then
			LibStub("AceAddon-3.0"):GetAddon("GatherMate2"):GetModule("Display"):ReparentMinimapPins(Minimap)
		end
		if Astrolabe then Astrolabe:SetTargetMinimap(Minimap) end
	end)
end

function M:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UpdateSettings()
end

function M:UpdateSettings()
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
	E.MinimapSize = E.private.general.minimap.enable and E.db.general.minimap.size or Minimap:GetWidth() + 10
	E.MinimapWidth, E.MinimapHeight = E.MinimapSize, E.MinimapSize

	if E.db.auras.consolidatedBuffs.enable then
		local numBuffs = E.db.auras.consolidatedBuffs.filter and 5 or 7
		E.ConsolidatedBuffsWidth = (E.MinimapHeight + (numBuffs*E.Border) + E.Border*2 - (E.Spacing*numBuffs)) / (numBuffs + 1)
	else
		E.ConsolidatedBuffsWidth = 0
	end

	if E.private.general.minimap.enable then
		Minimap:Size(E.MinimapSize, E.MinimapSize)
	end

	if LeftMiniPanel and RightMiniPanel then
		if E.db.datatexts.minimapPanels and E.private.general.minimap.enable then
			LeftMiniPanel:Show()
			RightMiniPanel:Show()
		else
			LeftMiniPanel:Hide()
			RightMiniPanel:Hide()
		end
	end

	if BottomMiniPanel then
		if E.db.datatexts.minimapBottom and E.private.general.minimap.enable then
			BottomMiniPanel:Show()
		else
			BottomMiniPanel:Hide()
		end
	end

	if BottomLeftMiniPanel then
		if E.db.datatexts.minimapBottomLeft and E.private.general.minimap.enable then
			BottomLeftMiniPanel:Show()
		else
			BottomLeftMiniPanel:Hide()
		end
	end

	if BottomRightMiniPanel then
		if E.db.datatexts.minimapBottomRight and E.private.general.minimap.enable then
			BottomRightMiniPanel:Show()
		else
			BottomRightMiniPanel:Hide()
		end
	end

	if TopMiniPanel then
		if E.db.datatexts.minimapTop and E.private.general.minimap.enable then
			TopMiniPanel:Show()
		else
			TopMiniPanel:Hide()
		end
	end

	if TopLeftMiniPanel then
		if E.db.datatexts.minimapTopLeft and E.private.general.minimap.enable then
			TopLeftMiniPanel:Show()
		else
			TopLeftMiniPanel:Hide()
		end
	end

	if TopRightMiniPanel then
		if E.db.datatexts.minimapTopRight and E.private.general.minimap.enable then
			TopRightMiniPanel:Show()
		else
			TopRightMiniPanel:Hide()
		end
	end

	if MMHolder then
		MMHolder:Width((Minimap:GetWidth() + E.Border + E.Spacing*3) + E.ConsolidatedBuffsWidth)

		if E.db.datatexts.minimapPanels then
			MMHolder:Height(Minimap:GetHeight() + (LeftMiniPanel and (LeftMiniPanel:GetHeight() + E.Border) or 24) + E.Spacing*3)
		else
			MMHolder:Height(Minimap:GetHeight() + E.Border + E.Spacing*3)
		end
	end

	if Minimap.location then
		Minimap.location:Width(E.MinimapSize)

		if E.db.general.minimap.locationText ~= "SHOW" or not E.private.general.minimap.enable then
			Minimap.location:Hide()
		else
			Minimap.location:Show()
		end
	end

	if MinimapMover then
		MinimapMover:Size(MMHolder:GetSize())
	end

	if ElvConfigToggle then
		if E.db.auras.consolidatedBuffs.enable and E.db.datatexts.minimapPanels and E.private.general.minimap.enable then
			ElvConfigToggle:Show()
			ElvConfigToggle:Width(E.ConsolidatedBuffsWidth)
		else
			ElvConfigToggle:Hide()
		end
	end

	if ElvUI_ConsolidatedBuffs then
		A:Update_ConsolidatedBuffsSettings()
	end

	--Stop here if ElvUI Minimap is disabled.
	if not E.private.general.minimap.enable then return end

	if GameTimeFrame then
		if E.db.general.minimap.icons.calendar.hide then
			GameTimeFrame:Hide()
		else
			local pos = E.db.general.minimap.icons.calendar.position or "TOPRIGHT"
			local scale = E.db.general.minimap.icons.calendar.scale or 1
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.calendar.xOffset or 0, E.db.general.minimap.icons.calendar.yOffset or 0)
			GameTimeFrame:SetScale(scale)
			GameTimeFrame:Show()
		end
	end

	if MiniMapMailFrame then
		local pos = E.db.general.minimap.icons.mail.position or "TOPRIGHT"
		local scale = E.db.general.minimap.icons.mail.scale or 1
		MiniMapMailFrame:ClearAllPoints()
		MiniMapMailFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.mail.xOffset or 3, E.db.general.minimap.icons.mail.yOffset or 4)
		MiniMapMailFrame:SetScale(scale)
	end

	if QueueStatusMinimapButton then
		local pos = E.db.general.minimap.icons.lfgEye.position or "BOTTOMRIGHT"
		local scale = E.db.general.minimap.icons.lfgEye.scale or 1
		QueueStatusMinimapButton:ClearAllPoints()
		QueueStatusMinimapButton:Point(pos, Minimap, pos, E.db.general.minimap.icons.lfgEye.xOffset or 3, E.db.general.minimap.icons.lfgEye.yOffset or 0)
		QueueStatusMinimapButton:SetScale(scale)
		QueueStatusFrame:SetScale(1/scale)
	end

	if MiniMapBattlefieldFrame then
		local pos = E.db.general.minimap.icons.battlefield.position or "BOTTOMRIGHT"
		local scale = E.db.general.minimap.icons.battlefield.scale or 1
		MiniMapBattlefieldFrame:ClearAllPoints()
		MiniMapBattlefieldFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.battlefield.xOffset or 3, E.db.general.minimap.icons.battlefield.yOffset or 0)
		MiniMapBattlefieldFrame:SetScale(scale)

		MiniMapBattlefieldIcon:SetTexCoord(unpack(E.TexCoords))
	end

	if MiniMapInstanceDifficulty and GuildInstanceDifficulty then
		local pos = E.db.general.minimap.icons.difficulty.position or "TOPLEFT"
		local scale = E.db.general.minimap.icons.difficulty.scale or 1
		local x = E.db.general.minimap.icons.difficulty.xOffset or 0
		local y = E.db.general.minimap.icons.difficulty.yOffset or 0
		MiniMapInstanceDifficulty:ClearAllPoints()
		MiniMapInstanceDifficulty:Point(pos, Minimap, pos, x, y)
		MiniMapInstanceDifficulty:SetScale(scale)
		GuildInstanceDifficulty:ClearAllPoints()
		GuildInstanceDifficulty:Point(pos, Minimap, pos, x, y)
		GuildInstanceDifficulty:SetScale(scale)
	end

	if MiniMapChallengeMode then
		local pos = E.db.general.minimap.icons.challengeMode.position or "TOPLEFT"
		local scale = E.db.general.minimap.icons.challengeMode.scale or 1
		MiniMapChallengeMode:ClearAllPoints()
		MiniMapChallengeMode:Point(pos, Minimap, pos, E.db.general.minimap.icons.challengeMode.xOffset or 8, E.db.general.minimap.icons.challengeMode.yOffset or -8)
		MiniMapChallengeMode:SetScale(scale)
	end

	if HelpOpenTicketButton then
		local pos = E.db.general.minimap.icons.ticket.position or "TOPRIGHT"
		local scale = E.db.general.minimap.icons.ticket.scale or 1
		local x = E.db.general.minimap.icons.ticket.xOffset or 0
		local y = E.db.general.minimap.icons.ticket.yOffset or 0
		HelpOpenTicketButton:ClearAllPoints()
		HelpOpenTicketButton:Point(pos, Minimap, pos, x, y)
		HelpOpenTicketButton:SetScale(scale)

		HelpOpenTicketButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		HelpOpenTicketButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
	end

	if MiniMapWorldMapButton then
		if E.db.general.minimap.icons.worldMap.hide then
			MiniMapWorldMapButton:Hide()
		else
			local pos = E.db.general.minimap.icons.worldMap.position or "TOPRIGHT"
			local scale = E.db.general.minimap.icons.worldMap.scale or 1
			local x = E.db.general.minimap.icons.worldMap.xOffset or 0
			local y = E.db.general.minimap.icons.worldMap.yOffset or 0

			MiniMapWorldMapButton:ClearAllPoints()
			MiniMapWorldMapButton:Point(pos, Minimap, pos, x, y)
			MiniMapWorldMapButton:SetScale(scale)
			MiniMapWorldMapButton:Show()

			MiniMapWorldMapButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			MiniMapWorldMapButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		end
	end
end

local function MinimapPostDrag()
	MinimapCluster:ClearAllPoints()
	MinimapCluster:SetAllPoints(Minimap)
	MinimapBackdrop:ClearAllPoints()
	MinimapBackdrop:SetAllPoints(Minimap)
end

function M:ADDON_LOADED(_, addon)
	if addon == "Blizzard_TimeManager" then
		TimeManagerClockButton:Kill()
	elseif addon == "Blizzard_FeedbackUI" then
		FeedbackUIButton:Kill()
	end
end

function M:Initialize()
	menuFrame:SetTemplate("Transparent", true)
	self:UpdateSettings()
	if not E.private.general.minimap.enable then
		Minimap:SetMaskTexture("Textures\\MinimapMask")
		return
	end

	--Support for other mods
	function GetMinimapShape()
		return "SQUARE"
	end

	Minimap:Size(E.db.general.minimap.size, E.db.general.minimap.size)

	local mmholder = CreateFrame("Frame", "MMHolder", Minimap)
	mmholder:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -3, -3)
	mmholder:Width((Minimap:GetWidth() + 29) + E.ConsolidatedBuffsWidth)
	mmholder:Height(Minimap:GetHeight() + 53)

	Minimap:ClearAllPoints()
	if E.db.auras.consolidatedBuffs.position == "LEFT" then
		Minimap:Point("TOPRIGHT", mmholder, "TOPRIGHT", -E.Border, -E.Border)
	else
		Minimap:Point("TOPLEFT", mmholder, "TOPLEFT", E.Border, -E.Border)
	end
	Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")
	Minimap:CreateBackdrop()
	Minimap:SetFrameLevel(Minimap:GetFrameLevel() + 2)
	Minimap:HookScript("OnEnter", function(self)
		if E.db.general.minimap.locationText ~= "MOUSEOVER" or not E.private.general.minimap.enable then return end
		self.location:Show()
	end)

	Minimap:HookScript("OnLeave", function(self)
		if E.db.general.minimap.locationText ~= "MOUSEOVER" or not E.private.general.minimap.enable then return end
		self.location:Hide()
	end)

	Minimap.location = Minimap:CreateFontString(nil, "OVERLAY")
	Minimap.location:FontTemplate(nil, nil, "OUTLINE")
	Minimap.location:Point("TOP", Minimap, "TOP", 0, -2)
	Minimap.location:SetJustifyH("CENTER")
	Minimap.location:SetJustifyV("MIDDLE")
	if E.db.general.minimap.locationText ~= "SHOW" or not E.private.general.minimap.enable then
		Minimap.location:Hide()
	end

	MinimapBorder:Hide()
	MinimapBorderTop:Hide()
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	MiniMapVoiceChatFrame:Hide()
	MinimapZoneTextButton:Hide()
	MiniMapMailBorder:Hide()
	QueueStatusMinimapButtonBorder:Hide()

	MiniMapTracking:Kill()
	MinimapNorthTag:Kill()

	QueueStatusFrame:SetClampedToScreen(true)

	MiniMapMailIcon:SetTexture(E.Media.Textures.Mail)

	MiniMapInstanceDifficulty:SetParent(Minimap)
	GuildInstanceDifficulty:SetParent(Minimap)
	MiniMapChallengeMode:SetParent(Minimap)
	HelpOpenTicketButton:SetParent(Minimap)

	for _, frame in pairs({"HelpOpenTicketButton", "MiniMapWorldMapButton"}) do
		local item = _G[frame]
		local normal, pushed = item:GetNormalTexture(), item:GetPushedTexture()

		item:StripTextures()
		item:CreateBackdrop()
		item:SetFrameStrata("MEDIUM")
		item:Size(28)
		item:StyleButton(nil, true)
		item.hover:SetAllPoints()

		if item == MiniMapWorldMapButton then
			normal:SetTexture("INTERFACE\\ICONS\\INV_Misc_Map02")
			normal:SetAllPoints()

			pushed:SetTexture("INTERFACE\\ICONS\\INV_Misc_Map02")
			pushed:SetAllPoints()
		elseif item == HelpOpenTicketButton then
			normal:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-Blizz")
			normal:Point("TOPLEFT", 2, -6)
			normal:Point("BOTTOMRIGHT", -2, 6)

			pushed:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-Blizz")
			pushed:Point("TOPLEFT", 2, -6)
			pushed:Point("BOTTOMRIGHT", -2, 6)
		end
	end

	--Hide the BlopRing on Minimap
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)

	if TimeManagerClockButton then
		TimeManagerClockButton:Kill()
	end

	if FeedbackUIButton then
		FeedbackUIButton:Kill()
	end

	E:CreateMover(MMHolder, "MinimapMover", L["Minimap"], nil, nil, MinimapPostDrag, nil, nil, "maps,minimap")

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", M.Minimap_OnMouseWheel)
	Minimap:SetScript("OnMouseUp", M.Minimap_OnMouseUp)

	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_INDOORS", "Update_ZoneText")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update_ZoneText")
	self:RegisterEvent("ADDON_LOADED")

	hooksecurefunc(Minimap, "SetZoom", SetupZoomReset)

	self:CreateFarmModeMap()

	self.Initialized = true
end

local function InitializeCallback()
	M:Initialize()
end

E:RegisterInitialModule(M:GetName(), InitializeCallback)