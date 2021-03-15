local _G = _G
local gsub, type = gsub, type

local CreateFrame = CreateFrame
local GetAddOnMetadata = GetAddOnMetadata
local GetLocale = GetLocale
local GetTime = GetTime
local HideUIPanel = HideUIPanel
local IsAddOnLoaded = IsAddOnLoaded
local ReloadUI = ReloadUI
local GameMenuButtonLogout = GameMenuButtonLogout
local GameMenuButtonRatings = GameMenuButtonRatings
local GameMenuFrame = GameMenuFrame

BINDING_HEADER_ELVUI = GetAddOnMetadata(..., "Title")

local AceAddon, AceAddonMinor = LibStub("AceAddon-3.0")
local CallbackHandler = LibStub("CallbackHandler-1.0")

local AddOnName, Engine = ...
local E = AceAddon:NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")

-- Defaults
E.DF = {profile = {}, global = {}}
E.privateVars = {profile = {}}

E.Options = {
	type = "group",
	args = {},
	childGroups = "ElvUI_HiddenTree"
}

E.callbacks = E.callbacks or CallbackHandler:New(E)
E.locale = GetLocale()

Engine[1] = E
Engine[2] = {}
Engine[3] = E.privateVars.profile
Engine[4] = E.DF.profile
Engine[5] = E.DF.global
_G.ElvUI = Engine

E.oUF = Engine.oUF
E.ActionBars = E:NewModule("ActionBars", "AceHook-3.0", "AceEvent-3.0")
E.AFK = E:NewModule("AFK", "AceEvent-3.0", "AceTimer-3.0")
E.Auras = E:NewModule("Auras", "AceHook-3.0", "AceEvent-3.0")
E.Bags = E:NewModule("Bags", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")
E.Blizzard = E:NewModule("Blizzard", "AceEvent-3.0", "AceHook-3.0")
E.Chat = E:NewModule("Chat", "AceTimer-3.0", "AceHook-3.0", "AceEvent-3.0")
E.DataBars = E:NewModule("DataBars", "AceEvent-3.0")
E.DataTexts = E:NewModule("DataTexts", "AceTimer-3.0", "AceHook-3.0", "AceEvent-3.0")
E.DebugTools = E:NewModule("DebugTools", "AceEvent-3.0", "AceHook-3.0")
E.Distributor = E:NewModule("Distributor", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0")
E.Layout = E:NewModule("Layout", "AceEvent-3.0")
E.Minimap = E:NewModule("Minimap", "AceEvent-3.0")
E.Misc = E:NewModule("Misc", "AceEvent-3.0", "AceTimer-3.0")
E.ModuleCopy = E:NewModule("ModuleCopy", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0")
E.NamePlates = E:NewModule("NamePlates", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")
E.PluginInstaller = E:NewModule("PluginInstaller")
E.RaidBrowser = E:NewModule("RaidBrowser", "AceEvent-3.0", "AceHook-3.0")
E.RaidUtility = E:NewModule("RaidUtility", "AceEvent-3.0")
E.Skins = E:NewModule("Skins", "AceHook-3.0", "AceEvent-3.0")
E.Threat = E:NewModule("Threat", "AceEvent-3.0")
E.Tooltip = E:NewModule("Tooltip", "AceHook-3.0", "AceEvent-3.0")
E.TotemBar = E:NewModule("Totems", "AceEvent-3.0")
E.UnitFrames = E:NewModule("UnitFrames", "AceTimer-3.0", "AceEvent-3.0", "AceHook-3.0")
E.WorldMap = E:NewModule("WorldMap", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")

E.twoPixelsPlease = false

do -- this is different from E.locale because we need to convert for ace locale files
	local convert = {enGB = "enUS", esES = "esMX", itIT = "enUS"}
	local gameLocale = convert[E.locale] or E.locale or "enUS"

	function E:GetLocale()
		return gameLocale
	end
end

do
	E.Libs = {}
	E.LibsMinor = {}
	function E:AddLib(name, major, minor)
		if not name then return end

		-- in this case: `major` is the lib table and `minor` is the minor version
		if type(major) == "table" and type(minor) == "number" then
			E.Libs[name], E.LibsMinor[name] = major, minor
		else -- in this case: `major` is the lib name and `minor` is the silent switch
			E.Libs[name], E.LibsMinor[name] = LibStub(major, minor)
		end
	end

	E:AddLib("AceAddon", AceAddon, AceAddonMinor)
	E:AddLib("AceDB", "AceDB-3.0")
	E:AddLib("EP", "LibElvUIPlugin-1.0")
	E:AddLib("LSM", "LibSharedMedia-3.0")
	E:AddLib("ACL", "AceLocale-3.0-ElvUI")
	E:AddLib("LAB", "LibActionButton-1.0-ElvUI")
	E:AddLib("LAI", "LibAuraInfo-1.0-ElvUI", true)
	E:AddLib("LDB", "LibDataBroker-1.1")
	E:AddLib("DualSpec", "LibDualSpec-1.0")
	E:AddLib("SimpleSticky", "LibSimpleSticky-1.0")
	E:AddLib("SpellRange", "SpellRange-1.0")
	E:AddLib("ItemSearch", "LibItemSearch-1.2-ElvUI")
	E:AddLib("Compress", "LibCompress")
	E:AddLib("Base64", "LibBase64-1.0-ElvUI")
	E:AddLib("Masque", "Masque", true)
	E:AddLib("Translit", "LibTranslit-1.0")
	-- added on ElvUI_OptionsUI load: AceGUI, AceConfig, AceConfigDialog, AceConfigRegistry, AceDBOptions

	-- backwards compatible for plugins
	E.LSM = E.Libs.LSM
	E.Masque = E.Libs.Masque
end

do
	local a1, a2, a3 = "","([%(%)%.%%%+%-%*%?%[%^%$])","%%%1"
	function E:EscapeString(s) return gsub(s, a2, a3) end

	local a4, a5, a6, a7 = "|c[fF][fF]%x%x%x%x%x%x","|r","|T.-|t","^%s*"
	function E:StripString(s)
		return gsub(gsub(gsub(gsub(s, a4, a1), a5, a1), a6, a1), a7, a1)
	end
end

do
	DisableAddOn("ElvUI_VisualAuraTimers")
	DisableAddOn("ElvUI_ExtraActionBars")
	DisableAddOn("ElvUI_CastBarOverlay")
	DisableAddOn("ElvUI_EverySecondCounts")
	DisableAddOn("ElvUI_AuraBarsMovers")
	DisableAddOn("ElvUI_CustomTweaks")
	DisableAddOn("ElvUI_MinimapButtons")
	DisableAddOn("ElvUI_DataTextColors")
	DisableAddOn("ElvUI_ChannelAlerts")
end

function E:OnInitialize()
	if not ElvCharacterDB then
		ElvCharacterDB = {}
	end

	ElvCharacterData = nil --Depreciated
	ElvPrivateData = nil --Depreciated
	ElvData = nil --Depreciated

	E.db = E:CopyTable({}, E.DF.profile)
	E.global = E:CopyTable({}, E.DF.global)
	E.private = E:CopyTable({}, E.privateVars.profile)

	if ElvDB then
		if ElvDB.global then
			E:CopyTable(E.global, ElvDB.global)
		end

		local key = ElvDB.profileKeys and ElvDB.profileKeys[E.mynameRealm]
		if key and ElvDB.profiles and ElvDB.profiles[key] then
			E:CopyTable(E.db, ElvDB.profiles[key])
		end
	end

	if ElvPrivateDB then
		local key = ElvPrivateDB.profileKeys and ElvPrivateDB.profileKeys[E.mynameRealm]
		if key and ElvPrivateDB.profiles and ElvPrivateDB.profiles[key] then
			E:CopyTable(E.private, ElvPrivateDB.profiles[key])
		end
	end

	E.ScanTooltip = CreateFrame("GameTooltip", "ElvUI_ScanTooltip", UIParent, "GameTooltipTemplate")
	E.PixelMode = E.twoPixelsPlease or E.private.general.pixelPerfect -- keep this over `UIScale`
	E:UIScale(true)
	E:UpdateMedia()
	E:Contruct_StaticPopups()
	E:InitializeInitialModules()

	if IsAddOnLoaded("Tukui") then
		E:StaticPopup_Show("TUKUI_ELVUI_INCOMPATIBLE")
	end

	local GameMenuButton = CreateFrame("Button", "GameMenuButtonElvUI", GameMenuFrame, "GameMenuButtonTemplate")
	GameMenuButton:SetText(self.title)
	GameMenuButton:Size(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())
	GameMenuButton:Point("TOPLEFT", GameMenuButtonAddons, "BOTTOMLEFT", 0, -1)
	GameMenuButton:SetScript("OnClick", function()
		E:ToggleOptionsUI()
		HideUIPanel(GameMenuFrame)
	end)
	GameMenuFrame[AddOnName] = GameMenuButton

	hooksecurefunc("GameMenuFrame_UpdateVisibleButtons", self.PositionGameMenuButton)

	E.loadedtime = GetTime()
end

function E:PositionGameMenuButton()
	GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight() - 4)
	local _, relTo, _, _, offY = GameMenuButtonLogout:GetPoint()
	if relTo ~= GameMenuFrame[AddOnName] then
		GameMenuFrame[AddOnName]:ClearAllPoints()
		GameMenuFrame[AddOnName]:Point("TOPLEFT", relTo, "BOTTOMLEFT", 0, -1)
		GameMenuButtonLogout:ClearAllPoints()
		GameMenuButtonLogout:Point("TOPLEFT", GameMenuFrame[AddOnName], "BOTTOMLEFT", 0, offY)
	end
end

local LoadUI = CreateFrame("Frame")
LoadUI:RegisterEvent("PLAYER_LOGIN")
LoadUI:SetScript("OnEvent", function()
	E:Initialize()
end)

function E:ResetProfile()
	local key = ElvPrivateDB.profileKeys and ElvPrivateDB.profileKeys[E.mynameRealm]
	if key and ElvPrivateDB.profiles and ElvPrivateDB.profiles[key] then
		ElvPrivateDB.profiles[key] = nil
	end

	ElvCharacterDB = nil
	ReloadUI()
end

function E:OnProfileReset()
	E:StaticPopup_Show("RESET_PROFILE_PROMPT")
end