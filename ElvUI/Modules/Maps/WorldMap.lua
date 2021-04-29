local E, L, V, P, G = unpack(select(2, ...))
local M = E:GetModule("WorldMap")
local S = E:GetModule("Skins")

local find = string.find

local CreateFrame = CreateFrame
local GetCVarBool = GetCVarBool
local GetCursorPosition = GetCursorPosition
local GetPlayerMapPosition = GetPlayerMapPosition
local GetUnitSpeed = GetUnitSpeed
local SetUIPanelAttribute = SetUIPanelAttribute

local MOUSE_LABEL = MOUSE_LABEL
local PLAYER = PLAYER
local WORLDMAP_SETTINGS = WORLDMAP_SETTINGS

local INVERTED_POINTS = {
	TOP = "BOTTOM",
	TOPLEFT = "BOTTOMLEFT",
	TOPRIGHT = "BOTTOMRIGHT",
	BOTTOM = "TOP",
	BOTTOMLEFT = "TOPLEFT",
	BOTTOMRIGHT = "TOPRIGHT"
}

local t = 0
local function UpdateCoords(self, elapsed)
	t = t + elapsed
	if t < 0.03333 then return end
	t = 0

	local x, y = GetPlayerMapPosition("player")

	if self.playerCoords.x ~= x or self.playerCoords.y ~= y then
		if x ~= 0 or y ~= 0 then
			self.playerCoords.x = x
			self.playerCoords.y = y
			self.playerCoords:SetFormattedText("%s:   %.2f, %.2f", PLAYER, x * 100, y * 100)
		else
			self.playerCoords.x = nil
			self.playerCoords.y = nil
			self.playerCoords:SetFormattedText("%s:   %s", PLAYER, "N/A")
		end
	end

	if WorldMapDetailFrame:IsMouseOver() then
		local curX, curY = GetCursorPosition()

		if self.mouseCoords.x ~= curX or self.mouseCoords.y ~= curY then
			local scale = WorldMapDetailFrame:GetEffectiveScale()
			local width, height = WorldMapDetailFrame:GetSize()
			local centerX, centerY = WorldMapDetailFrame:GetCenter()
			local adjustedX = (curX / scale - (centerX - (width * 0.5))) / width
			local adjustedY = (centerY + (height * 0.5) - curY / scale) / height

			if adjustedX >= 0 and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1 then
				self.mouseCoords.x = curX
				self.mouseCoords.y = curY
				self.mouseCoords:SetFormattedText("%s:  %.2f, %.2f", MOUSE_LABEL, adjustedX * 100, adjustedY * 100)
			else
				self.mouseCoords.x = nil
				self.mouseCoords.y = nil
				self.mouseCoords:SetText("")
			end
		end
	elseif self.mouseCoords.x then
		self.mouseCoords.x = nil
		self.mouseCoords.y = nil
		self.mouseCoords:SetText("")
	end
end

function M:PositionCoords()
	if not self.coordsHolder then return end

	local db = E.global.general.WorldMapCoordinates
	local position = db.position

	local x = find(position, "RIGHT") and -5 or 5
	local y = find(position, "TOP") and -5 or 5

	self.coordsHolder.playerCoords:ClearAllPoints()
	self.coordsHolder.playerCoords:Point(position, WorldMapDetailFrame, position, x + db.xOffset, y + db.yOffset)

	self.coordsHolder.mouseCoords:ClearAllPoints()
	self.coordsHolder.mouseCoords:Point(position, self.coordsHolder.playerCoords, INVERTED_POINTS[position], 0, y)
end

function M:ToggleMapFramerate()
	if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE or WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE then
		SetUIPanelAttribute(WorldMapFrame, "area", "center")
		SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)

		WorldMapFrame:SetScale(1)
		WorldMapFrame:EnableKeyboard(false)
		WorldMapFrame:EnableMouse(false)
	else
		S:SetUIPanelWindowInfo(WorldMapFrame, "width", 591)
	end
end

function M:CheckMovement()
	if not WorldMapFrame:IsShown() then return end

	if GetUnitSpeed("player") ~= 0 and not WorldMapPositioningGuide:IsMouseOver() then
		WorldMapFrame:SetAlpha(E.global.general.mapAlphaWhenMoving)
		WorldMapBlobFrame:SetFillAlpha(128 * E.global.general.mapAlphaWhenMoving)
		WorldMapBlobFrame:SetBorderAlpha(192 * E.global.general.mapAlphaWhenMoving)
		WorldMapArchaeologyDigSites:SetFillAlpha(128 * E.global.general.mapAlphaWhenMoving)
		WorldMapArchaeologyDigSites:SetBorderAlpha(192 * E.global.general.mapAlphaWhenMoving)
	else
		WorldMapFrame:SetAlpha(1)
		WorldMapBlobFrame:SetFillAlpha(128)
		WorldMapBlobFrame:SetBorderAlpha(192)
		WorldMapArchaeologyDigSites:SetFillAlpha(128)
		WorldMapArchaeologyDigSites:SetBorderAlpha(192)
	end
end

function M:UpdateMapAlpha()
	if (not E.global.general.fadeMapWhenMoving or E.global.general.mapAlphaWhenMoving >= 1) and self.MovingTimer then
		self:CancelTimer(self.MovingTimer)
		self.MovingTimer = nil

		WorldMapFrame:SetAlpha(1)
		WorldMapBlobFrame:SetFillAlpha(128)
		WorldMapBlobFrame:SetBorderAlpha(192)
		WorldMapArchaeologyDigSites:SetFillAlpha(128)
		WorldMapArchaeologyDigSites:SetBorderAlpha(192)
	elseif E.global.general.fadeMapWhenMoving and E.global.general.mapAlphaWhenMoving < 1 and not self.MovingTimer then
		self.MovingTimer = self:ScheduleRepeatingTimer("CheckMovement", 0.1)
	end
end

function M:Initialize()
	M:UpdateMapAlpha()

	if not E.private.worldmap.enable then return end

	if E.global.general.WorldMapCoordinates.enable then
		local coordsHolder = CreateFrame("Frame", "ElvUI_CoordsHolder", WorldMapFrame)
		coordsHolder:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL + 100)
		coordsHolder:SetFrameStrata(WorldMapDetailFrame:GetFrameStrata())

		coordsHolder.playerCoords = coordsHolder:CreateFontString(nil, "OVERLAY")
		coordsHolder.playerCoords:SetTextColor(1, 1, 0)
		coordsHolder.playerCoords:SetFontObject(NumberFontNormal)
		coordsHolder.playerCoords:SetPoint("BOTTOMLEFT", WorldMapDetailFrame, "BOTTOMLEFT", 5, 5)
		coordsHolder.playerCoords:SetFormattedText("%s:   0, 0", PLAYER)

		coordsHolder.mouseCoords = coordsHolder:CreateFontString(nil, "OVERLAY")
		coordsHolder.mouseCoords:SetTextColor(1, 1, 0)
		coordsHolder.mouseCoords:SetFontObject(NumberFontNormal)
		coordsHolder.mouseCoords:SetPoint("BOTTOMLEFT", coordsHolder.playerCoords, "TOPLEFT", 0, 5)

		coordsHolder:SetScript("OnUpdate", UpdateCoords)

		self.coordsHolder = coordsHolder
		self:PositionCoords()
	end

	if E.global.general.smallerWorldMap then
		BlackoutWorld:SetTexture(nil)

		WorldMapFrame:SetParent(UIParent)
		WorldMapFrame.SetParent = E.noop

		if GetCVarBool("miniWorldMap") then
			S:SetUIPanelWindowInfo(WorldMapFrame, "width", 591)
		else
			ShowUIPanel(WorldMapFrame)
			self:ToggleMapFramerate()
			HideUIPanel(WorldMapFrame)
		end

		M:SecureHook("ToggleMapFramerate")

		DropDownList1:HookScript("OnShow", function(dropDown)
			local uiParentScale = UIParent:GetScale()

			if dropDown:GetScale() ~= uiParentScale then
				dropDown:SetScale(uiParentScale)
			end
		end)

		self:RawHook("WorldMapQuestPOI_OnLeave", function()
			WorldMapTooltip:Hide()
		end, true)
	end

	self.Initialized = true
end

local function InitializeCallback()
	M:Initialize()
end

E:RegisterInitialModule(M:GetName(), InitializeCallback)