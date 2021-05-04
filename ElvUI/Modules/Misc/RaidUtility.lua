local E, L, V, P, G = unpack(select(2, ...))
local RU = E:GetModule("RaidUtility")
local S = E:GetModule("Skins")

local _G = _G
local ipairs, next = ipairs, next
local tinsert, twipe, tsort = table.insert, table.wipe, table.sort
local find = string.find

local CreateFrame = CreateFrame
local IsInInstance = IsInInstance
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local InCombatLockdown = InCombatLockdown
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local InitiateRolePoll = InitiateRolePoll
local DoReadyCheck = DoReadyCheck
local ToggleFriendsFrame = ToggleFriendsFrame
local GetNumGroupMembers = GetNumGroupMembers
local GetTexCoordsForRole = GetTexCoordsForRole
local GetRaidRosterInfo = GetRaidRosterInfo
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST

local PANEL_HEIGHT = 125

-- Check if We are Raid Leader or Raid Officer
local function CheckRaidStatus()
	local inInstance, instanceType = IsInInstance()
	if ((IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and not (inInstance and (instanceType == "pvp" or instanceType == "arena")) then
		return true
	else
		return false
	end
end

-- Function to create buttons in this module
function RU:CreateUtilButton(name, parent, template, width, height, point, relativeto, point2, xOfs, yOfs, text, texture)
	local button = CreateFrame("Button", name, parent, template)
	button:Width(width)
	button:Height(height)
	button:Point(point, relativeto, point2, xOfs, yOfs)
	S:HandleButton(button)

	if text then
		button.text = button:CreateFontString(nil, "OVERLAY", button)
		button.text:FontTemplate()
		button.text:Point("CENTER")
		button.text:SetJustifyH("CENTER")
		button.text:SetText(text)
		button:SetFontString(button.text)
	elseif texture then
		button.texture = button:CreateTexture(nil, "OVERLAY", nil)
		button.texture:SetTexture(texture)
		button.texture:Point("TOPLEFT", button, "TOPLEFT", E.mult, -E.mult)
		button.texture:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", -E.mult, E.mult)
	end
end

function RU:ToggleRaidUtil(event)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "ToggleRaidUtil")
		return
	end

	if CheckRaidStatus() then
		if RaidUtilityPanel.toggled == true then
			RaidUtility_ShowButton:Hide()
			RaidUtilityPanel:Show()
		else
			RaidUtility_ShowButton:Show()
			RaidUtilityPanel:Hide()
		end
	else
		RaidUtility_ShowButton:Hide()
		RaidUtilityPanel:Hide()
	end

	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", "ToggleRaidUtil")
	end
end

local function sortColoredNames(a, b)
	return a:sub(11) < b:sub(11)
end

local roleIconRoster = {}
local function onEnter(self)
	twipe(roleIconRoster)

	for i = 1, NUM_RAID_GROUPS do
		roleIconRoster[i] = {}
	end

	local role = self.role
	local point = E:GetScreenQuadrant(RaidUtility_ShowButton)
	local bottom = point and find(point, "BOTTOM")
	local left = point and find(point, "LEFT")

	local anchor1 = (bottom and left and "BOTTOMLEFT") or (bottom and "BOTTOMRIGHT") or (left and "TOPLEFT") or "TOPRIGHT"
	local anchor2 = (bottom and left and "BOTTOMRIGHT") or (bottom and "BOTTOMLEFT") or (left and "TOPRIGHT") or "TOPLEFT"
	local anchorX = left and 2 or -2

	GameTooltip:SetOwner(E.UIParent, "ANCHOR_NONE")
	GameTooltip:Point(anchor1, self, anchor2, anchorX, 0)
	GameTooltip:SetText(_G["INLINE_"..role.."_ICON"].._G[role])

	local name, group, class, groupRole, color, coloredName, _
	for i = 1, GetNumGroupMembers() do
		name, _, group, _, _, class, _, _, _, _, _, groupRole = GetRaidRosterInfo(i)
		if name and groupRole == role then
			color = E:ClassColor(class, true) or PRIEST_COLOR
			coloredName = ("|cff%02x%02x%02x%s"):format(color.r * 255, color.g * 255, color.b * 255, name:gsub("%-.+", "*"))
			tinsert(roleIconRoster[group], coloredName)
		end
	end

	for groupIdx, list in ipairs(roleIconRoster) do
		tsort(list, sortColoredNames)
		for _, playerName in ipairs(list) do
			GameTooltip:AddLine(("[%d] %s"):format(groupIdx, playerName), 1, 1, 1)
		end
		roleIconRoster[groupIdx] = nil
	end

	GameTooltip:Show()
end

local function RaidUtility_PositionRoleIcons()
	local point = E:GetScreenQuadrant(RaidUtility_ShowButton)
	local left = point and find(point, "LEFT")
	RaidUtilityRoleIcons:ClearAllPoints()
	if left then
		RaidUtilityRoleIcons:SetPoint("LEFT", RaidUtilityPanel, "RIGHT", -1, 0)
	else
		RaidUtilityRoleIcons:SetPoint("RIGHT", RaidUtilityPanel, "LEFT", 1, 0)
	end
end

local iconCount = {}
local function UpdateIcons(self)
	local raid = IsInRaid()
	local party --= IsInGroup()
	local role

	if not (raid or party) then
		self:Hide()
		return
	else
		self:Show()
		RaidUtility_PositionRoleIcons()
	end

	twipe(iconCount)

	for i = 1, GetNumGroupMembers() do
		role = UnitGroupRolesAssigned((raid and "raid" or "party")..i)
		if role and role ~= "NONE" then
			iconCount[role] = (iconCount[role] or 0) + 1
		end
	end

	if (not raid) and party then -- only need this party (we believe)
		role = E:GetPlayerRole()
		if role then
			iconCount[role] = (iconCount[role] or 0) + 1
		end
	end

	for raidRole, icon in next, RaidUtilityRoleIcons.icons do
		icon.count:SetText(iconCount[raidRole] or 0)
	end
end

function RU:Initialize()
	if not E.private.general.raidUtility then return end

	self.Initialized = true

	-- Create main frame
	local RaidUtilityPanel = CreateFrame("Frame", "RaidUtilityPanel", E.UIParent, "SecureHandlerClickTemplate")
	RaidUtilityPanel:SetTemplate("Transparent")
	RaidUtilityPanel:Width(230)
	RaidUtilityPanel:Height(PANEL_HEIGHT)
	RaidUtilityPanel:Point("TOP", E.UIParent, "TOP", -400, 1)
	RaidUtilityPanel:SetFrameLevel(3)
	RaidUtilityPanel.toggled = false
	RaidUtilityPanel:SetFrameStrata("HIGH")
	E.FrameLocks.RaidUtilityPanel = true

	-- Show Button
	self:CreateUtilButton("RaidUtility_ShowButton", E.UIParent, "UIMenuButtonStretchTemplate, SecureHandlerClickTemplate", 136, 18, "TOP", E.UIParent, "TOP", -400, 2, RAID_CONTROL, nil)
	RaidUtility_ShowButton:SetFrameRef("RaidUtilityPanel", RaidUtilityPanel)
	RaidUtility_ShowButton:SetAttribute("_onclick", ([=[
		local raidUtil = self:GetFrameRef("RaidUtilityPanel")
		local closeButton = raidUtil:GetFrameRef("RaidUtility_CloseButton")

		self:Hide();
		raidUtil:Show();

		local point = self:GetPoint();
		local raidUtilPoint, closeButtonPoint, yOffset

		if(string.find(point, "BOTTOM")) then
			raidUtilPoint = "BOTTOM"
			closeButtonPoint = "TOP"
			yOffset = 1
		else
			raidUtilPoint = "TOP"
			closeButtonPoint = "BOTTOM"
			yOffset = -1
		end

		yOffset = yOffset * (tonumber(%d))

		raidUtil:ClearAllPoints()
		closeButton:ClearAllPoints()
		raidUtil:SetPoint(raidUtilPoint, self, raidUtilPoint)
		closeButton:SetPoint(raidUtilPoint, raidUtil, closeButtonPoint, 0, yOffset)
	]=]):format(-E.Border + E.Spacing * 3))
	RaidUtility_ShowButton:SetScript("OnMouseUp", function()
		RaidUtilityPanel.toggled = true
		RaidUtility_PositionRoleIcons()
	end)
	RaidUtility_ShowButton:SetMovable(true)
	RaidUtility_ShowButton:SetClampedToScreen(true)
	RaidUtility_ShowButton:SetClampRectInsets(0, 0, -1, 1)
	RaidUtility_ShowButton:RegisterForDrag("RightButton")
	RaidUtility_ShowButton:SetFrameStrata("TOOLTIP")
	RaidUtility_ShowButton:SetScript("OnDragStart", function(self)
		if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
		self:StartMoving()
	end)

	E.FrameLocks.RaidUtility_ShowButton = true

	RaidUtility_ShowButton:SetScript("OnDragStop", function(self)
		if InCombatLockdown() then return end
		self:StopMovingOrSizing()
		local point = self:GetPoint()
		local xOffset = self:GetCenter()
		local screenWidth = E.UIParent:GetWidth() / 2
		xOffset = xOffset - screenWidth
		self:ClearAllPoints()
		if find(point, "BOTTOM") then
			self:Point("BOTTOM", E.UIParent, "BOTTOM", xOffset, -1)
		else
			self:Point("TOP", E.UIParent, "TOP", xOffset, 1)
		end
	end)

	-- Close Button
	self:CreateUtilButton("RaidUtility_CloseButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate, SecureHandlerClickTemplate", 136, 18, "TOP", RaidUtilityPanel, "BOTTOM", 0, -1, CLOSE, nil)
	RaidUtility_CloseButton:SetFrameRef("RaidUtility_ShowButton", RaidUtility_ShowButton)
	RaidUtility_CloseButton:SetAttribute("_onclick", [=[self:GetParent():Hide(); self:GetFrameRef("RaidUtility_ShowButton"):Show();]=])
	RaidUtility_CloseButton:SetScript("OnMouseUp", function() RaidUtilityPanel.toggled = false end)
	RaidUtilityPanel:SetFrameRef("RaidUtility_CloseButton", RaidUtility_CloseButton)

	-- Role Icons
	local RoleIcons = CreateFrame("Frame", "RaidUtilityRoleIcons", RaidUtilityPanel)
	RoleIcons:SetPoint("LEFT", RaidUtilityPanel, "RIGHT", -1, 0)
	RoleIcons:SetSize(36, PANEL_HEIGHT)
	RoleIcons:SetTemplate("Transparent")
	RoleIcons:RegisterEvent("PLAYER_ENTERING_WORLD")
	RoleIcons:RegisterEvent("GROUP_ROSTER_UPDATE")
	RoleIcons:SetScript("OnEvent", UpdateIcons)

	RoleIcons.icons = {}

	local roles = {"TANK", "HEALER", "DAMAGER"}
	for i, role in ipairs(roles) do
		local frame = CreateFrame("Frame", "$parent_"..role, RoleIcons)
		if i == 1 then
			frame:Point("BOTTOM", 0, 4)
		else
			frame:Point("BOTTOM", _G["RaidUtilityRoleIcons_"..roles[i - 1]], "TOP", 0, 4)
		end
		frame:SetSize(28, 28)

		local texture = frame:CreateTexture(nil, "OVERLAY")
		texture:SetTexture(E.Media.Textures.RoleIcons)
		local texA, texB, texC, texD = GetTexCoordsForRole(role)
		texture:SetTexCoord(texA, texB, texC, texD)
		texture:Point("TOPLEFT", frame, "TOPLEFT", -2, 2)
		texture:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
		frame.texture = texture

		local count = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		count:Point("BOTTOMRIGHT", -2, 2)
		count:SetText(0)
		frame.count = count

		frame.role = role
		frame:SetScript("OnEnter", onEnter)
		frame:SetScript("OnLeave", GameTooltip_Hide)

		RoleIcons.icons[role] = frame
	end

	-- Disband Raid button
	self:CreateUtilButton("DisbandRaidButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", RaidUtilityPanel, "TOP", 0, -5, L["Disband Group"], nil)
	DisbandRaidButton:SetScript("OnMouseUp", function()
		if CheckRaidStatus() then
			E:StaticPopup_Show("DISBAND_RAID")
		end
	end)

	-- Role Check button
	self:CreateUtilButton("RoleCheckButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", DisbandRaidButton, "BOTTOM", 0, -5, ROLE_POLL, nil)
	RoleCheckButton:SetScript("OnMouseUp", function()
		if CheckRaidStatus() then
			InitiateRolePoll()
		end
	end)

	-- Ready Check button
	self:CreateUtilButton("ReadyCheckButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RoleCheckButton:GetWidth() * 0.86, 18, "TOPLEFT", RoleCheckButton, "BOTTOMLEFT", 0, -5, READY_CHECK, nil)
	ReadyCheckButton:SetScript("OnMouseUp", function()
		if CheckRaidStatus() then
			DoReadyCheck()
		end
	end)

	ReadyCheckButton:SetScript("OnEvent", function(btn)
		if not (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
			btn:Disable()
		else
			btn:Enable()
		end
	end)

	ReadyCheckButton:RegisterEvent("GROUP_ROSTER_UPDATE")
	ReadyCheckButton:RegisterEvent("PLAYER_ENTERING_WORLD")

	-- Convert Group button
	self:CreateUtilButton("ConvertGroupButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOPLEFT", ReadyCheckButton, "BOTTOMLEFT", 0, -5, UnitInRaid("player") and CONVERT_TO_PARTY or CONVERT_TO_RAID)
	ConvertGroupButton:SetScript("OnMouseUp", function()
		if UnitInRaid("player") then
			ConvertToParty()
		elseif UnitInParty("player") then
			ConvertToRaid()
		end
	end)

	ConvertGroupButton:SetScript("OnEvent", function(btn)
		if not UnitIsGroupLeader("player") then
			btn:Disable()
		else
			btn:Enable()
		end
		if UnitInRaid("player") then
			btn:SetText(CONVERT_TO_PARTY)
		elseif UnitInParty("player") then
			btn:SetText(CONVERT_TO_RAID)
		end
	end)

	ConvertGroupButton:RegisterEvent("GROUP_ROSTER_UPDATE")
	ConvertGroupButton:RegisterEvent("PLAYER_ENTERING_WORLD")

	-- Raid Control Panel
	self:CreateUtilButton("RaidControlButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RoleCheckButton:GetWidth(), 18, "TOP", ConvertGroupButton, "BOTTOM", 0, -5, L["Raid Menu"], nil)
	RaidControlButton:SetScript("OnMouseUp", function()
		if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
		ToggleFriendsFrame(4)
	end)

	if CompactRaidFrameManager then
		-- Reposition/Resize and Reuse the World Marker Button
		S:HandleNextPrevButton(CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton, "right")
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:ClearAllPoints()
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:Point("TOPRIGHT", RoleCheckButton, "BOTTOMRIGHT", 0, -5)
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetParent("RaidUtilityPanel")
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:Height(18)
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:Width(RoleCheckButton:GetWidth() * 0.12)

		-- Put other stuff back
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:Point("TOPLEFT", CompactRaidFrameManagerDisplayFrameLeaderOptions, "TOPLEFT", 20, -3)
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:Point("TOPLEFT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll, "BOTTOMLEFT", 0, -1)
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:Width(169)
		CompactRaidFrameManagerDisplayFrameLockedModeToggle:Width(84)
	else
		E:StaticPopup_Show("WARNING_BLIZZARD_ADDONS")
	end

	-- Automatically show/hide the frame if we have RaidLeader or RaidOfficer
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "ToggleRaidUtil")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ToggleRaidUtil")
end

local function InitializeCallback()
	RU:Initialize()
end

E:RegisterInitialModule(RU:GetName(), InitializeCallback)