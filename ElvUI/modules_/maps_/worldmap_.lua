local E, L, V, P, G = unpack(select(2, ...))
local M = E:NewModule("WorldMap", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")
E.WorldMap = M

local find, format = string.find, string.format

local CreateFrame = CreateFrame
local GetPlayerMapPosition = GetPlayerMapPosition
local InCombatLockdown = InCombatLockdown
local SetUIPanelAttribute = SetUIPanelAttribute
local GetCursorPosition = GetCursorPosition
local PLAYER = PLAYER
local MOUSE_LABEL = MOUSE_LABEL
local WORLDMAP_FULLMAP_SIZE = WORLDMAP_FULLMAP_SIZE
local WORLDMAP_WINDOWED_SIZE = WORLDMAP_WINDOWED_SIZE
local WORLDMAP_QUESTLIST_SIZE = WORLDMAP_QUESTLIST_SIZE

local INVERTED_POINTS = {
	["TOPLEFT"] = "BOTTOMLEFT",
	["TOPRIGHT"] = "BOTTOMRIGHT",
	["BOTTOMLEFT"] = "TOPLEFT",
	["BOTTOMRIGHT"] = "TOPRIGHT",
	["TOP"] = "BOTTOM",
	["BOTTOM"] = "TOP"
}

local tooltips = {
	WorldMapTooltip,
	WorldMapCompareTooltip1,
	WorldMapCompareTooltip2,
	WorldMapCompareTooltip3
}

function M:SetLargeWorldMap()
	if InCombatLockdown() then return end

	WorldMapFrame:SetParent(E.UIParent)
	WorldMapFrame:EnableKeyboard(false)
	WorldMapFrame:EnableMouse(true)
	if not WorldMapFrame.questMap then
		WorldMapFrame:SetScale(1)
	end

	for _, tt in pairs(tooltips) do
		if _G[tt] then _G[tt]:SetFrameStrata("TOOLTIP") end
	end

	if WorldMapFrame:GetAttribute("UIPanelLayout-area") ~= "center" then
		SetUIPanelAttribute(WorldMapFrame, "area", "center")
	end

	if WorldMapFrame:GetAttribute("UIPanelLayout-allowOtherPanels") ~= true then
		SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
	end

	WorldMapFrame:ClearAllPoints()
	WorldMapFrame:Point("CENTER", UIParent, "CENTER", 0, 60)
	WorldMapFrame:SetSize(1002, 668)

	WorldMapFrameSizeUpButton:Hide()
	WorldMapFrameSizeDownButton:Show()
end

function M:SetSmallWorldMap()
	if InCombatLockdown() then return end

	WorldMapFrameSizeUpButton:Show()
	WorldMapFrameSizeDownButton:Hide()
end

function M:PLAYER_REGEN_ENABLED()
	WorldMapFrameSizeDownButton:Enable()
	WorldMapFrameSizeUpButton:Enable()
	WorldMapShowDropDownButton:Enable()
	WorldMapTrackQuest:Enable()

	if WorldMapFrame.questMap then
		WatchFrame.showObjectives = WatchFrame.oldShowObjectives or true
		WorldMapBlobFrame.Show = WorldMapBlobFrame:Show()
		WorldMapPOIFrame.Show = WorldMapPOIFrame:Show()
		WorldMapBlobFrame:Show()
		WorldMapPOIFrame:Show()

		WatchFrame_Update()
	end
end

function M:PLAYER_REGEN_DISABLED()
	WorldMapFrameSizeDownButton:Disable()
	WorldMapFrameSizeUpButton:Disable()
	WorldMapShowDropDownButton:Disable()
	WorldMapTrackQuest:Disable()

	if WorldMapFrame.questMap then
		if WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE then
			WorldMapFrame_SetFullMapView()
		end

		WatchFrame.oldShowObjectives = WatchFrame.showObjectives
		WatchFrame.showObjectives = nil
		WorldMapBlobFrame:Hide()
		WorldMapPOIFrame:Hide()

		WorldMapBlobFrame.Show = E.noop
		WorldMapPOIFrame.Show = E.noop

		WatchFrame_Update()
	end
end

function M:UpdateCoords()
	if not WorldMapFrame:IsShown() then return end

	local x, y = GetPlayerMapPosition("player")
	x = x and E:Round(100 * x, 2) or 0
	y = y and E:Round(100 * y, 2) or 0

	if x ~= 0 and y ~= 0 then
		CoordsHolder.playerCoords:SetText(PLAYER..":   "..format("%.2f, %.2f", x, y))
	else
		CoordsHolder.playerCoords:SetText("")
	end

	local scale = WorldMapDetailFrame:GetEffectiveScale()
	local width = WorldMapDetailFrame:GetWidth()
	local height = WorldMapDetailFrame:GetHeight()
	local centerX, centerY = WorldMapDetailFrame:GetCenter()
	x, y = GetCursorPosition()
	local adjustedX = (x / scale - (centerX - (width / 2))) / width
	local adjustedY = (centerY + (height / 2) - y / scale) / height

	if adjustedX >= 0 and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1 then
		adjustedX = E:Round(100 * adjustedX, 2)
		adjustedY = E:Round(100 * adjustedY, 2)
		CoordsHolder.mouseCoords:SetText(MOUSE_LABEL .. ":  " .. format("%.2f, %.2f", adjustedX, adjustedY))
	else
		CoordsHolder.mouseCoords:SetText("")
	end
end

function M:PositionCoords()
	local db = E.global.general.WorldMapCoordinates
	local position = db.position
	local xOffset = db.xOffset
	local yOffset = db.yOffset

	local x, y = 5, 5
	if find(position, "RIGHT") then x = -5 end
	if find(position, "TOP") then y = -5 end

	CoordsHolder.playerCoords:ClearAllPoints()
	CoordsHolder.playerCoords:Point(position, WorldMapDetailFrame, position, x + xOffset, y + yOffset)

	CoordsHolder.mouseCoords:ClearAllPoints()
	CoordsHolder.mouseCoords:Point(position, CoordsHolder.playerCoords, INVERTED_POINTS[position], 0, y)
end

function M:Initialize()
	if E.global.general.WorldMapCoordinates.enable then
		local CoordsHolder = CreateFrame("Frame", "CoordsHolder", WorldMapFrame)
		CoordsHolder:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() + 1)
		CoordsHolder:SetFrameStrata(WorldMapDetailFrame:GetFrameStrata())

		CoordsHolder.playerCoords = CoordsHolder:CreateFontString(nil, "OVERLAY")
		CoordsHolder.playerCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.playerCoords:SetFontObject(NumberFontNormal)
		CoordsHolder.playerCoords:SetText(PLAYER..":   0, 0")

		CoordsHolder.mouseCoords = CoordsHolder:CreateFontString(nil, "OVERLAY")
		CoordsHolder.mouseCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.mouseCoords:SetFontObject(NumberFontNormal)
		CoordsHolder.mouseCoords:SetText(MOUSE_LABEL..":   0, 0")

		CoordsHolder:SetScript("OnUpdate", self.UpdateCoords)

		self:PositionCoords()
	end

	if E.global.general.smallerWorldMap then
		BlackoutWorld:SetTexture(nil)
		self:SecureHook("WorldMap_ToggleSizeDown", "SetSmallWorldMap")
		self:SecureHook("WorldMap_ToggleSizeUp", "SetLargeWorldMap")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")

		if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
			self:SetLargeWorldMap()
		elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
			self:SetSmallWorldMap()
		elseif WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE then
			self:SetLargeWorldMap()
			WorldMapFrame.questMap = true
		end

		DropDownList1:HookScript("OnShow", function()
			if DropDownList1:GetScale() ~= UIParent:GetScale() then
				DropDownList1:SetScale(UIParent:GetScale())
			end
		end)
	end
end

local function InitializeCallback()
	M:Initialize()
end

E:RegisterInitialModule(M:GetName(), InitializeCallback)