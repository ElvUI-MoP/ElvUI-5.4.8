local _G = _G
local loadstring, pcall, print, tostring, type, select = loadstring, pcall, print, tostring, type, select
local find, format, match = string.find, string.format, string.match
local tconcat = table.concat

local UIParentLoadAddOn = UIParentLoadAddOn
local GetMouseFocus = GetMouseFocus
local FrameStackTooltip_Toggle = FrameStackTooltip_Toggle
local SlashCmdList = SlashCmdList
local tostringall = tostringall

local oldAddMessage

local function printNoTimestamp(...)
	if oldAddMessage or DEFAULT_CHAT_FRAME.OldAddMessage then
		if not oldAddMessage then
			oldAddMessage = DEFAULT_CHAT_FRAME.OldAddMessage
		end

		if select("#", ...) > 1 then
			oldAddMessage(DEFAULT_CHAT_FRAME, tconcat({tostringall(...)}, ", "))
		else
			oldAddMessage(DEFAULT_CHAT_FRAME, ...)
		end
	elseif CHAT_TIMESTAMP_FORMAT then
		local tsformat = CHAT_TIMESTAMP_FORMAT
		CHAT_TIMESTAMP_FORMAT = nil
		print(...)
		CHAT_TIMESTAMP_FORMAT = tsformat
	else
		print(...)
	end
end

local function updateCopyChat()
	if CopyChatFrame and CopyChatFrame:IsShown() then
		CopyChatFrame:Hide()
		ElvUI[1]:GetModule("Chat"):CopyChat(DEFAULT_CHAT_FRAME)
	end
end

local function getObject(objName)
	local obj

	if objName == "" then
		obj = GetMouseFocus()
	else
		obj = _G[objName]

		if not obj then
			local pass

			if find(objName, "^[%.:]([A-z0-9_]+)") then
				local _obj = GetMouseFocus()

				if _obj and _obj ~= WorldFrame then
					local res = match(objName, "^[%.:]([A-z0-9_]+)")

					if res and _obj[res] and _obj:GetName() then
						objName = format("%s%s", _obj:GetName(), objName)
					end

					pass = true
				end
			elseif find(objName, "[%.()%[%]'\"]") then
				pass = true
			end

			if pass then
				local success, ret = pcall(loadstring(format("return %s", objName)))
				if success then
					ret = ret == "string" and _G[ret] or ret

					if type(ret) == "table" and ret.GetName then
						obj = ret
					end
				end
			end
		end
	end

	if obj then
		return obj ~= WorldFrame and obj or nil
	else
		printNoTimestamp(format("Object |cffFFD100%s|r not found!", objName))
	end
end

SLASH_FRAME1 = "/frame"
SlashCmdList.FRAME = function(frame)
	frame = getObject(frame)
	if not frame then return end

	local parent = frame:GetParent()
	local parentName = parent and parent.GetName and parent:GetName()

	printNoTimestamp("|cffCC0000----------------------------")

	printNoTimestamp(format("|cffaaaaaaName|r: |cffFFD100%s|r", frame:GetName() or "nil"))
	printNoTimestamp(format("|cffaaaaaaObjectType|r: |cffFFD100%s|r", frame:GetObjectType()))
	printNoTimestamp(format("|cffaaaaaaParent|r: |cffFFD100%s|r", parentName or (parent and tostring(parent)) or "nil"))
	printNoTimestamp(format("|cffaaaaaaSize|r: |cffFFD100%.0f, %.0f|r", frame:GetWidth(), frame:GetHeight()))

	if frame.GetScale then
		printNoTimestamp(format("|cffaaaaaaScale|r: |cffFFD100%s|r", frame:GetScale()))
	end

	if frame.GetFrameStrata then
		printNoTimestamp(format("|cffaaaaaaStrata|r: |cffFFD100%s|r", frame:GetFrameStrata()))
		printNoTimestamp(format("|cffaaaaaaFrameLevel|r: |cffFFD100%d|r", frame:GetFrameLevel()))
	else
		printNoTimestamp(format("|cffaaaaaaDrawLayer|r: |cffFFD100%s|r", frame:GetDrawLayer()))
	end

	local point, relativeTo, relativePoint, x, y, relativeName
	for i = 1, frame:GetNumPoints() do
		point, relativeTo, relativePoint, x, y = frame:GetPoint(i)
		relativeName = relativeTo and relativeTo.GetName and (relativeTo:GetName() or tostring(relativeTo)) or "nil"

		if point == relativePoint and relativeTo == parent then
			printNoTimestamp(format("|cffaaaaaaPoint %d|r: |cffFFD100\"%s\"|r, %.0f, %.0f", i, point, x, y))
		else
			printNoTimestamp(format("|cffaaaaaaPoint %d|r: |cffFFD100\"%s\"|r, %s, |cffFFD100\"%s\"|r, %.0f, %.0f", i, point, relativeName, relativePoint, x, y))
		end
	end

	printNoTimestamp("|cffCC0000----------------------------")

	updateCopyChat()
end

SLASH_FRAMELIST1 = "/framelist"
SlashCmdList.FRAMELIST = function(showHidden)
	if not FrameStackTooltip then
		UIParentLoadAddOn("Blizzard_DebugTools")
	end

	local isPreviouslyShown = FrameStackTooltip:IsShown()
	if not isPreviouslyShown then
		if showHidden == "true" then
			FrameStackTooltip_Toggle(true)
		else
			FrameStackTooltip_Toggle()
		end
	end

	printNoTimestamp("|cffCC0000----------------------------|r")
	for i = 2, FrameStackTooltip:NumLines() do
		local text = _G["FrameStackTooltipTextLeft"..i]:GetText()
		if text and text ~= "" then
			printNoTimestamp(text)
		end
	end
	printNoTimestamp("|cffCC0000----------------------------|r")

	updateCopyChat()

	if not isPreviouslyShown then
		FrameStackTooltip_Toggle()
	end
end

SLASH_TEXLIST1 = "/texlist"
SlashCmdList.TEXLIST = function(frame)
	frame = getObject(frame)
	if not (frame and frame.GetNumRegions) then return end

	printNoTimestamp("|cffCC0000----------------------------|r")
	printNoTimestamp(format("Texture List of |cffFFD100%s|r", frame:GetName() or "nil"))
	local region, texture, name
	for i = 1, frame:GetNumRegions() do
		region = select(i, frame:GetRegions())
		if region.IsObjectType and region:IsObjectType("Texture") and region:GetTexture() then
			texture = region:GetTexture() or "nil"
			name = region:GetName() or "nil"

			printNoTimestamp(format("|cffaaaaaa%s|r |cffFFD100%s|r %s %s", texture, name, region:GetDrawLayer()))
		end
	end
	printNoTimestamp("|cffCC0000----------------------------|r")

	updateCopyChat()
end

SLASH_REGLIST1 = "/reglist"
SlashCmdList.REGLIST = function(frame)
	frame = getObject(frame)
	if not (frame and frame.GetNumRegions) then return end

	printNoTimestamp("|cffCC0000----------------------------|r")
	printNoTimestamp(format("Region List of |cffFFD100%s|r", frame:GetName() or "nil"))
	local region, objType, name, layer, subLayer
	for i = 1, frame:GetNumRegions() do
		region = select(i, frame:GetRegions())
		objType, name = region:GetObjectType(), region:GetName()
		layer, subLayer = region:GetDrawLayer()
		printNoTimestamp(format("%s |cffaaaaaaType:|r |cffFFD100%s|r |cffaaaaaaName:|r |cffFFD100%s|r |cffaaaaaaLayer:|r |cffFFD100%s|r |cffaaaaaaSubLayer:|r |cffFFD100%s|r", i, objType, name or "nil", layer, subLayer or "nil"))
	end
	printNoTimestamp("|cffCC0000----------------------------|r")

	updateCopyChat()
end

SLASH_CHILDLIST1 = "/childlist"
SlashCmdList.CHILDLIST = function(frame)
	frame = getObject(frame)
	if not (frame and frame.GetNumChildren) then return end

	printNoTimestamp("|cffCC0000----------------------------|r")
	printNoTimestamp(format("Child List of |cffFFD100%s|r", frame:GetName() or "nil"))
	local obj, objType, name, strata, level
	for i = 1, frame:GetNumChildren() do
		obj = select(i, frame:GetChildren())
		objType, name, strata, level = obj:GetObjectType(), obj:GetName(), obj:GetFrameStrata(), obj:GetFrameLevel()
		printNoTimestamp(format("%s |cffaaaaaaType:|r |cffFFD100%s|r |cffaaaaaaName:|r |cffFFD100%s|r |cffaaaaaaStrata:|r |cffFFD100%s|r |cffaaaaaaLevel:|r |cffFFD100%s|r", i, objType, name or "nil", strata, level))
	end
	printNoTimestamp("|cffCC0000----------------------------|r")

	updateCopyChat()
end

SLASH_GETPOINT1 = "/getpoint"
SlashCmdList.GETPOINT = function(frame)
	frame = getObject(frame)
	if not frame then return end

	local parent = frame:GetParent()
	local point, relativeTo, relativePoint, x, y, relativeName

	printNoTimestamp("|cffCC0000----------------------------|r")
	printNoTimestamp(format("Points List of |cffFFD100%s|r", frame:GetName() or "nil"))
	for i = 1, frame:GetNumPoints() do
		point, relativeTo, relativePoint, x, y = frame:GetPoint(i)
		relativeName = relativeTo and relativeTo.GetName and (relativeTo:GetName() or tostring(relativeTo)) or "nil"

		if point == relativePoint and relativeTo == parent then
			printNoTimestamp(format("|cffaaaaaaPoint %d|r: |cffFFD100\"%s\"|r, %.0f, %.0f", i, point, x, y))
		else
			printNoTimestamp(format("|cffaaaaaaPoint %d|r: |cffFFD100\"%s\"|r, %s, |cffFFD100\"%s\"|r, %.0f, %.0f", i, point, relativeName, relativePoint, x, y))
		end
	end
	printNoTimestamp("|cffCC0000----------------------------|r")

	updateCopyChat()
end