local E, L, V, P, G = unpack(select(2, ...))
local CH = E:GetModule("Chat")
local LO = E:GetModule("Layout")
local Skins = E:GetModule("Skins")
local LibBase64 = E.Libs.Base64
local LSM = E.Libs.LSM

local _G = _G
local time, difftime = time, difftime
local pairs, ipairs, unpack, select, tostring, pcall, next, tonumber, type = pairs, ipairs, unpack, select, tostring, pcall, next, tonumber, type
local tinsert, tremove, tconcat, wipe = table.insert, table.remove, table.concat, table.wipe
local gsub, strfind, gmatch, format = string.gsub, string.find, string.gmatch, string.format
local strlower, strmatch, strsub, strlen, strupper = strlower, strmatch, strsub, strlen, strupper

local BetterDate = BetterDate
local BNGetNumFriendInvites = BNGetNumFriendInvites
local ChatEdit_ActivateChat = ChatEdit_ActivateChat
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local ChatEdit_ParseText = ChatEdit_ParseText
local ChatEdit_SetLastTellTarget = ChatEdit_SetLastTellTarget
local ChatFrame_ConfigEventHandler = ChatFrame_ConfigEventHandler
local ChatFrame_GetMobileEmbeddedTexture = ChatFrame_GetMobileEmbeddedTexture
local ChatFrame_SendTell = ChatFrame_SendTell
local ChatFrame_SystemEventHandler = ChatFrame_SystemEventHandler
local ChatHistory_GetAccessID = ChatHistory_GetAccessID
local Chat_GetChatCategory = Chat_GetChatCategory
local CreateFrame = CreateFrame
local FCFManager_ShouldSuppressMessage = FCFManager_ShouldSuppressMessage
local FCFManager_ShouldSuppressMessageFlash = FCFManager_ShouldSuppressMessageFlash
local FCFTab_UpdateAlpha = FCFTab_UpdateAlpha
local FCF_Close = FCF_Close
local FCF_GetChatWindowInfo = FCF_GetChatWindowInfo
local FCF_GetCurrentChatFrame = FCF_GetCurrentChatFrame
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions
local FCF_SetLocked = FCF_SetLocked
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local FCF_StartAlertFlash = FCF_StartAlertFlash
local FloatingChatFrame_OnEvent = FloatingChatFrame_OnEvent
local GetChannelName = GetChannelName
local GetCVar = GetCVar
local GetGuildRosterMOTD = GetGuildRosterMOTD
local GetMouseFocus = GetMouseFocus
local GetNumGroupMembers = GetNumGroupMembers
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local GetRaidRosterInfo = GetRaidRosterInfo
local GMChatFrame_IsGM = GMChatFrame_IsGM
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsInInstance, IsInRaid, IsInGroup = IsInInstance, IsInRaid, IsInGroup
local IsMouseButtonDown = IsMouseButtonDown
local IsShiftKeyDown = IsShiftKeyDown
local PlaySoundFile = PlaySoundFile
local RemoveExtraSpaces = RemoveExtraSpaces
local ScrollFrameTemplate_OnMouseWheel = ScrollFrameTemplate_OnMouseWheel
local StaticPopup_Visible = StaticPopup_Visible
local ToggleFrame = ToggleFrame
local UnitExists, UnitIsUnit = UnitExists, UnitIsUnit
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitName = UnitName
local NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS
local AFK = AFK
local BN_INLINE_TOAST_BROADCAST = BN_INLINE_TOAST_BROADCAST
local BN_INLINE_TOAST_BROADCAST_INFORM = BN_INLINE_TOAST_BROADCAST_INFORM
local BN_INLINE_TOAST_CONVERSATION = BN_INLINE_TOAST_CONVERSATION
local BN_INLINE_TOAST_FRIEND_PENDING = BN_INLINE_TOAST_FRIEND_PENDING
local CHAT_BN_CONVERSATION_GET_LINK = CHAT_BN_CONVERSATION_GET_LINK
local CHAT_BN_CONVERSATION_LIST = CHAT_BN_CONVERSATION_LIST
local CHAT_FILTERED = CHAT_FILTERED
local CHAT_IGNORED = CHAT_IGNORED
local CHAT_RESTRICTED = CHAT_RESTRICTED
local DND = DND
local ERR_CHAT_PLAYER_NOT_FOUND_S = ERR_CHAT_PLAYER_NOT_FOUND_S
local ERR_FRIEND_OFFLINE_S = ERR_FRIEND_OFFLINE_S
local ERR_FRIEND_ONLINE_SS = ERR_FRIEND_ONLINE_SS
local MAX_WOW_CHAT_CHANNELS = MAX_WOW_CHAT_CHANNELS
local PLAYER_LIST_DELIMITER = PLAYER_LIST_DELIMITER
local RAID_WARNING = RAID_WARNING
local CHAT_MSG_BLOCK_CHAT_CHANNEL_INVITE = CHAT_MSG_BLOCK_CHAT_CHANNEL_INVITE
local PET_BATTLE_COMBAT_LOG = PET_BATTLE_COMBAT_LOG

CH.ClassNames = {}
CH.Keywords = {}
CH.Smileys = {}

local lfgRoles = {}
local throttle = {}

local PLAYER_REALM = E:ShortenRealm(E.myrealm)
local PLAYER_NAME = format("%s-%s", E.myname, PLAYER_REALM)

local DEFAULT_STRINGS = {
	GUILD = L["G"],
	PARTY = L["P"],
	RAID = L["R"],
	OFFICER = L["O"],
	PARTY_LEADER = L["PL"],
	RAID_LEADER = L["RL"],
	INSTANCE_CHAT = L["I"],
	INSTANCE_CHAT_LEADER = L["IL"],
	PET_BATTLE_COMBAT_LOG = PET_BATTLE_COMBAT_LOG
}

local hyperlinkTypes = {
	achievement = true,
	currency = true,
	enchant = true,
	glyph = true,
	instancelock = true,
	item = true,
	quest = true,
	spell = true,
	talent = true,
	unit = true
}

local tabTexs = {
	"",
	"Selected",
	"Highlight"
}

local historyTypes = { -- the events set on the chats are still in FindURL_Events, this is used to ignore some types only
	CHAT_MSG_WHISPER = "WHISPER",
	CHAT_MSG_WHISPER_INFORM = "WHISPER",
	CHAT_MSG_BN_WHISPER = "WHISPER",
	CHAT_MSG_BN_WHISPER_INFORM = "WHISPER",
	CHAT_MSG_GUILD = "GUILD",
	CHAT_MSG_GUILD_ACHIEVEMENT = "GUILD",
	CHAT_MSG_OFFICER = "OFFICER",
	CHAT_MSG_PARTY = "PARTY",
	CHAT_MSG_PARTY_LEADER = "PARTY",
	CHAT_MSG_RAID = "RAID",
	CHAT_MSG_RAID_LEADER = "RAID",
	CHAT_MSG_RAID_WARNING = "RAID",
	CHAT_MSG_INSTANCE_CHAT = "INSTANCE",
	CHAT_MSG_INSTANCE_CHAT_LEADER = "INSTANCE",
	CHAT_MSG_CHANNEL = "CHANNEL",
	CHAT_MSG_SAY = "SAY",
	CHAT_MSG_YELL = "YELL",
	CHAT_MSG_EMOTE = "EMOTE"  -- this never worked, check it sometime.
}

function CH:RemoveSmiley(key)
	if key and (type(key) == "string") then
		CH.Smileys[key] = nil
	end
end

function CH:AddSmiley(key, texture)
	if key and (type(key) == "string" and not strfind(key, ":%%", 1, true)) and texture then
		CH.Smileys[key] = texture
	end
end

local rolePaths = {
	TANK = E:TextureString(E.Media.Textures.Tank, ":15:15:0:0:64:64:2:56:2:56"),
	HEALER = E:TextureString(E.Media.Textures.Healer, ":15:15:0:0:64:64:2:56:2:56"),
	DAMAGER = E:TextureString(E.Media.Textures.DPS, ":15:15")
}

local specialChatIcons
do --this can save some main file locals
--	local x = ":16:16"
	local y = ":13:25"
--	local ElvMelon		= E:TextureString(E.Media.ChatLogos.ElvMelon, y)
--	local ElvRainbow	= E:TextureString(E.Media.ChatLogos.ElvRainbow, y)
--	local ElvRed		= E:TextureString(E.Media.ChatLogos.ElvRed, y)
	local ElvOrange		= E:TextureString(E.Media.ChatLogos.ElvOrange, y)
--	local ElvYellow		= E:TextureString(E.Media.ChatLogos.ElvYellow, y)
--	local ElvGreen		= E:TextureString(E.Media.ChatLogos.ElvGreen, y)
--	local ElvBlue		= E:TextureString(E.Media.ChatLogos.ElvBlue, y)
	local ElvPurple		= E:TextureString(E.Media.ChatLogos.ElvPurple, y)
--	local ElvPink		= E:TextureString(E.Media.ChatLogos.ElvPink, y)
--	local Bathrobe		= E:TextureString(E.Media.ChatLogos.Bathrobe, x)
--	local MrHankey		= E:TextureString(E.Media.ChatLogos.MrHankey, x)
--	local Rainbow		= E:TextureString(E.Media.ChatLogos.Rainbow, x)
	specialChatIcons = {
		["[EN]".."Evermoon"] = {
			["Insane"] = ElvOrange,
		}
	}
end

local function ChatFrame_OnMouseScroll(frame, delta)
	local numScrollMessages = CH.db.numScrollMessages or 3
	if delta < 0 then
		if IsShiftKeyDown() then
			frame:ScrollToBottom()
		elseif IsAltKeyDown() then
			frame:ScrollDown()
		else
			for _ = 1, numScrollMessages do
				frame:ScrollDown()
			end
		end
	elseif delta > 0 then
		if IsShiftKeyDown() then
			frame:ScrollToTop()
		elseif IsAltKeyDown() then
			frame:ScrollUp()
		else
			for _ = 1, numScrollMessages do
				frame:ScrollUp()
			end
		end

		if CH.db.scrollDownInterval ~= 0 then
			if frame.ScrollTimer then
				CH:CancelTimer(frame.ScrollTimer, true)
			end

			frame.ScrollTimer = CH:ScheduleTimer("ScrollToBottom", CH.db.scrollDownInterval, frame)
		end
	end
end

function CH:GetGroupDistribution()
	local inInstance, kind = IsInInstance()
	if inInstance and (kind == "pvp") then return "/bg " end
	if IsInRaid() then return "/ra " end
	if IsInGroup() then return "/p " end
	return "/s "
end

function CH:InsertEmotions(msg)
	for word in gmatch(msg, "%s-%S+%s*") do
		word = strtrim(word)
		local pattern = E:EscapeString(word)
		local emoji = CH.Smileys[pattern]
		if emoji and strmatch(msg, "[%s%p]-"..pattern.."[%s%p]*") then
			local base64 = LibBase64:Encode(word) -- btw keep `|h|cFFffffff|r|h` as it is
			msg = gsub(msg, "([%s%p]-)"..pattern.."([%s%p]*)", (base64 and ("%1|Helvmoji:%%"..base64.."|h|cFFffffff|r|h") or "%1")..emoji.."%2")
		end
	end

	return msg
end

function CH:GetSmileyReplacementText(msg)
	if not msg or not CH.db.emotionIcons or strfind(msg, "/run") or strfind(msg, "/dump") or strfind(msg, "/script") then return msg end
	local outstr = ""
	local origlen = strlen(msg)
	local startpos = 1
	local endpos, _

	while startpos <= origlen do
		local pos = strfind(msg, "|H", startpos, true)
		endpos = pos or origlen
		outstr = outstr..CH:InsertEmotions(strsub(msg,startpos,endpos)) --run replacement on this bit
		startpos = endpos + 1
		if pos ~= nil then
			_, endpos = strfind(msg, "|h.-|h", startpos)
			endpos = endpos or origlen
			if startpos < endpos then
				outstr = outstr..strsub(msg,startpos,endpos) --don't run replacement on this bit
				startpos = endpos + 1
			end
		end
	end

	return outstr
end

function CH:StyleChat(frame)
	local name = frame:GetName()

	_G[name.."TabText"]:FontTemplate(LSM:Fetch("font", CH.db.tabFont), CH.db.tabFontSize, CH.db.tabFontOutline)

	if frame.styled then return end

	frame:SetFrameLevel(4)
	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:SetClampedToScreen(false)
	frame:StripTextures(true)

	_G[name.."ButtonFrame"]:Kill()

	local id = frame:GetID()
	local tab = _G[name.."Tab"]
	local editbox = _G[name.."EditBox"]

	--Character count
	local charCount = editbox:CreateFontString()
	charCount:FontTemplate()
	charCount:SetTextColor(190, 190, 190, 0.4)
	charCount:Point("TOPRIGHT", editbox, "TOPRIGHT", -5, 0)
	charCount:Point("BOTTOMRIGHT", editbox, "BOTTOMRIGHT", -5, 0)
	charCount:SetJustifyH("CENTER")
	charCount:Width(40)
	editbox.characterCount = charCount

	for _, texName in ipairs(tabTexs) do
		_G[name.."Tab"..texName.."Left"]:SetTexture()
		_G[name.."Tab"..texName.."Middle"]:SetTexture()
		_G[name.."Tab"..texName.."Right"]:SetTexture()
	end

	tab:SetHitRectInsets(0, 0, 11, 1)

	tab.glow:Point("BOTTOMLEFT", 8, 2)
	tab.glow:Point("BOTTOMRIGHT", -8, 2)

	hooksecurefunc(tab, "SetAlpha", function(t, alpha)
		if alpha ~= 1 and (not t.isDocked or GeneralDockManager.selected:GetID() == t:GetID()) then
			t:SetAlpha(1)
		elseif alpha < 0.6 then
			t:SetAlpha(0.6)
		end
	end)

	tab.text = _G[name.."TabText"]

	if tab.conversationIcon then
		tab.text:Point("LEFT", tab.leftTexture, "RIGHT", 10, -5)

		tab.conversationIcon:ClearAllPoints()
		tab.conversationIcon:Point("RIGHT", tab.text, "LEFT", -1, 0)
	end

	local function OnTextChanged(editBox)
		local text = editBox:GetText()
		local len = strlen(text)
		local MIN_REPEAT_CHARACTERS = CH.db.numAllowedCombatRepeat

		if MIN_REPEAT_CHARACTERS ~= 0 and InCombatLockdown() then
			if len > MIN_REPEAT_CHARACTERS then
				local repeatChar = true
				for i = 1, MIN_REPEAT_CHARACTERS do
					if strsub(text, -i, -i) ~= strsub(text, (-1 - i), (-1 - i)) then
						repeatChar = false
						break
					end
				end
				if repeatChar then
					editBox:Hide()
					return
				end
			end
		end

		if len == 4 then
			if text == "/tt " then
				local Name, Realm = UnitName("target")
				if Name then
					Name = gsub(Name, "%s", "")

					if Realm and Realm ~= "" then
						Name = format("%s-%s", Name, E:ShortenRealm(Realm))
					end
				end

				if Name then
					ChatFrame_SendTell(Name, editBox.chatFrame)
				else
					UIErrorsFrame:AddMessage(E.InfoColor..L["Invalid Target"])
				end
			elseif text == "/gr " then
				editBox:SetText(CH:GetGroupDistribution()..strsub(text, 5))
				ChatEdit_ParseText(editBox, 0)
			end
		end

		editbox.characterCount:SetText(len > 0 and (255 - len) or "")
	end

	--Work around broken SetAltArrowKeyMode API. Code from Prat
	local function OnArrowPressed(editBox, key)
		if (not editBox.historyLines) or #editBox.historyLines == 0 then return end

		if key == "DOWN" then
			editBox.historyIndex = editBox.historyIndex - 1

			if editBox.historyIndex < 1 then
				editBox.historyIndex = 0
				editBox:SetText("")
				return
			end
		elseif key == "UP" then
			editBox.historyIndex = editBox.historyIndex + 1

			if editBox.historyIndex > #editBox.historyLines then
				editBox.historyIndex = #editBox.historyLines
			end
		else
			return
		end

		editBox:SetText(strtrim(editBox.historyLines[#editBox.historyLines - (editBox.historyIndex - 1)]))
	end

	local a, b, c = select(6, editbox:GetRegions())
	a:Kill()
	b:Kill()
	c:Kill()
	_G[name.."EditBoxFocusLeft"]:Kill()
	_G[name.."EditBoxFocusMid"]:Kill()
	_G[name.."EditBoxFocusRight"]:Kill()

	editbox:SetTemplate("Default", true)
	editbox:SetAltArrowKeyMode(CH.db.useAltKey)
	editbox:SetAllPoints(LeftChatDataPanel)
	editbox:HookScript("OnTextChanged", OnTextChanged)
	self:SecureHook(editbox, "AddHistoryLine", "ChatEdit_AddHistory")

	--Work around broken SetAltArrowKeyMode API
	editbox.historyLines = ElvCharacterDB.ChatEditHistory
	editbox.historyIndex = 0
	editbox:HookScript("OnArrowPressed", OnArrowPressed)
	editbox:Hide()

	editbox:HookScript("OnEditFocusGained", function(editBox)
		if not LeftChatPanel:IsShown() then
			LeftChatPanel.editboxforced = true
			LeftChatToggleButton:GetScript("OnEnter")(LeftChatToggleButton)
			editBox:Show()
		end
	end)

	editbox:HookScript("OnEditFocusLost", function(editBox)
		if LeftChatPanel.editboxforced then
			LeftChatPanel.editboxforced = nil

			if LeftChatPanel:IsShown() then
				LeftChatToggleButton:GetScript("OnLeave")(LeftChatToggleButton)
				editBox:Hide()
			end
		end

		editBox.historyIndex = 0
	end)

	for _, text in ipairs(editbox.historyLines) do
		editbox:AddHistoryLine(text)
	end

	--copy chat button
	local copyButton = CreateFrame("Frame", format("CopyChatButton%d", id), frame)
	copyButton:EnableMouse(true)
	copyButton:SetAlpha(0.35)
	copyButton:Size(20, 22)
	copyButton:Point("TOPRIGHT", 0, id == 2 and -7 or -2)
	copyButton:SetFrameLevel(frame:GetFrameLevel() + 5)
	frame.copyButton = copyButton

	local copyTexture = frame.copyButton:CreateTexture(nil, "OVERLAY")
	copyTexture:SetInside()
	copyTexture:SetTexture(E.Media.Textures.Copy)
	copyButton.texture = copyTexture

	copyButton:SetScript("OnMouseUp", function(_, btn)
		if btn == "RightButton" and id == 1 then
			ToggleFrame(ChatMenu)
		else
			CH:CopyChat(frame)
		end
	end)

	copyButton:SetScript("OnEnter", function(button) button:SetAlpha(1) end)
	copyButton:SetScript("OnLeave", function(button)
		if _G[button:GetParent():GetName().."TabText"]:IsShown() then
			button:SetAlpha(0.35)
		else
			button:SetAlpha(0)
		end
	end)

	frame.styled = true
end

function CH:AddMessage(msg, infoR, infoG, infoB, infoID, accessID, typeID, isHistory, historyTime)
	local historyTimestamp --we need to extend the arguments on AddMessage so we can properly handle times without overriding
	if isHistory == "ElvUI_ChatHistory" then historyTimestamp = historyTime end

	if CH.db.timeStampFormat and CH.db.timeStampFormat ~= "NONE" then
		local timeStamp = BetterDate(CH.db.timeStampFormat, historyTimestamp or time())
		timeStamp = gsub(timeStamp, " ", "")
		timeStamp = gsub(timeStamp, "AM", " AM")
		timeStamp = gsub(timeStamp, "PM", " PM")
		if CH.db.useCustomTimeColor then
			local color = CH.db.customTimeColor
			local hexColor = E:RGBToHex(color.r, color.g, color.b)
			msg = format("%s[%s]|r %s", hexColor, timeStamp, msg)
		else
			msg = format("[%s] %s", timeStamp, msg)
		end
	end

	self.OldAddMessage(self, msg, infoR, infoG, infoB, infoID, accessID, typeID)
end

function CH:UpdateSettings()
	for _, frameName in ipairs(CHAT_FRAMES) do
		_G[frameName.."EditBox"]:SetAltArrowKeyMode(CH.db.useAltKey)
	end
end

local removeIconFromLine
do
	local raidIconFunc = function(x) x = x ~= "" and _G["RAID_TARGET_"..x] return x and ("{"..strlower(x).."}") or "" end
	local stripTextureFunc = function(w, x, y) if x == "" then return (w ~= "" and w) or (y ~= "" and y) or "" end end
	local hyperLinkFunc = function(w, x, y) if w ~= "" then return end
		local emoji = (x ~= "" and x) and strmatch(x, "elvmoji:%%(.+)")
		return (emoji and LibBase64:Decode(emoji)) or y
	end
	removeIconFromLine = function(text)
		text = gsub(text, "|TInterface\\TargetingFrame\\UI%-RaidTargetingIcon_(%d+):0|t", raidIconFunc) --converts raid icons into {star} etc, if possible.
		text = gsub(text, "(%s?)(|?)|T.-|t(%s?)", stripTextureFunc) --strip any other texture out but keep a single space from the side(s).
		text = gsub(text, "(|?)|H(.-)|h(.-)|h", hyperLinkFunc) --strip hyperlink data only keeping the actual text.
		return text
	end
end

local function colorizeLine(text, r, g, b)
	local hexCode = E:RGBToHex(r, g, b)
	local hexReplacement = format("|r%s", hexCode)

	text = gsub(text, "|r", hexReplacement) -- If the message contains color strings then we need to add message color hex code after every "|r"
	text = format("%s%s|r", hexCode, text) -- Add message color

	return text
end

local copyLines = {}
function CH:GetLines(...)
	local index = 1
	wipe(copyLines)
	for i = select("#", ...), 1, -1 do
		local region = select(i, ...)
		if region:GetObjectType() == "FontString" then
			local message = tostring(region:GetText())
			local r, g, b = region:GetTextColor()

			--Remove icons
			message = removeIconFromLine(message)

			--Add text color
			message = colorizeLine(message, r, g, b)

			copyLines[index] = message
			index = index + 1
		end
	end

	return index - 1
end

function CH:CopyChat(frame)
	if not CopyChatFrame:IsShown() then
		local _, fontSize = FCF_GetChatWindowInfo(frame:GetID())
		if fontSize < 10 then fontSize = 12 end
		FCF_SetChatWindowFontSize(frame, frame, 0.01)
		CopyChatFrame:Show()
		local lineCt = CH:GetLines(frame:GetRegions())
		local text = tconcat(copyLines, " \n", 1, lineCt)
		FCF_SetChatWindowFontSize(frame, frame, fontSize)
		CopyChatFrameEditBox:SetText(text)
	else
		CopyChatFrame:Hide()
	end
end

function CH:OnEnter(frame)
	_G[frame:GetName().."Text"]:Show()

	if frame.conversationIcon then
		frame.conversationIcon:Show()
	end
end

function CH:OnLeave(frame)
	_G[frame:GetName().."Text"]:Hide()

	if frame.conversationIcon then
		frame.conversationIcon:Hide()
	end
end

function CH:UpdateDockState()
	if self.db.lockPositions then
		FCF_SetLocked(ChatFrame1, 1)
		GeneralDockManager:SetParent(LeftChatPanel)
		GeneralDockManagerOverflowButton:ClearAllPoints()
		GeneralDockManagerOverflowButton:Point("BOTTOMRIGHT", LeftChatTab, "BOTTOMRIGHT", -2, 2)
	else
		GeneralDockManager:SetParent(UIParent)
		GeneralDockManagerOverflowButton:ClearAllPoints()
		GeneralDockManagerOverflowButton:Point("BOTTOMRIGHT", GeneralDockManager, 0, -1)
	end
end

function CH:SetupChatTabs(frame, hook)
	if hook and (not CH.hooks or not CH.hooks[frame] or not CH.hooks[frame].OnEnter) then
		CH:HookScript(frame, "OnEnter")
		CH:HookScript(frame, "OnLeave")
	elseif not hook and CH.hooks and CH.hooks[frame] and CH.hooks[frame].OnEnter then
		CH:Unhook(frame, "OnEnter")
		CH:Unhook(frame, "OnLeave")
	end

	if not hook then
		_G[frame:GetName().."Text"]:Show()

		if frame.owner and frame.owner.button and GetMouseFocus() ~= frame.owner.button then
			frame.owner.button:SetAlpha(0.35)
		end
		if frame.conversationIcon then
			frame.conversationIcon:Show()
		end
	elseif GetMouseFocus() ~= frame then
		_G[frame:GetName().."Text"]:Hide()

		if frame.owner and frame.owner.button and GetMouseFocus() ~= frame.owner.button then
			frame.owner.button:SetAlpha(0)
		end

		if frame.conversationIcon then
			frame.conversationIcon:Hide()
		end
	end
end

function CH:UpdateAnchors()
	for _, frameName in ipairs(CHAT_FRAMES) do
		local frame = _G[frameName.."EditBox"]

		frame:ClearAllPoints()
		if not E.db.datatexts.leftChatPanel and CH.db.editBoxPosition == "BELOW_CHAT" then
			frame:Point("TOPLEFT", ChatFrame1, "BOTTOMLEFT", -4, -4)
			frame:Point("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 7, -LeftChatTab:GetHeight() - 4)
		elseif CH.db.editBoxPosition == "BELOW_CHAT" then
			frame:SetAllPoints(LeftChatDataPanel)
		else
			frame:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -1, 3)
			frame:Point("TOPRIGHT", ChatFrame1, "TOPRIGHT", 4, LeftChatTab:GetHeight() + 3)
		end
	end

	CH:PositionChat(true)
end

local function FindRightChatID()
	local rightChatID

	for id, frameName in ipairs(CHAT_FRAMES) do
		local chat = _G[frameName]

		if E:FramesOverlap(chat, RightChatPanel) and not E:FramesOverlap(chat, LeftChatPanel) then
			rightChatID = id
			break
		end
	end

	return rightChatID
end

function CH:UpdateChatTabs()
	local fadeUndockedTabs = CH.db.fadeUndockedTabs
	local fadeTabsNoBackdrop = CH.db.fadeTabsNoBackdrop

	for id, frameName in ipairs(CHAT_FRAMES) do
		local chat = _G[frameName]
		local tab = _G[format("%sTab", frameName)]

		if chat:IsShown() and not (id > NUM_CHAT_WINDOWS) and (id == self.RightChatWindowID) then
			if CH.db.panelBackdrop == "HIDEBOTH" or CH.db.panelBackdrop == "LEFT" then
				CH:SetupChatTabs(tab, fadeTabsNoBackdrop and true or false)
			else
				CH:SetupChatTabs(tab, false)
			end
		elseif not chat.isDocked and chat:IsShown() then
			tab:SetParent(RightChatPanel)
			chat:SetParent(RightChatPanel)
			CH:SetupChatTabs(tab, fadeUndockedTabs and true or false)
		else
			if CH.db.panelBackdrop == "HIDEBOTH" or CH.db.panelBackdrop == "RIGHT" then
				CH:SetupChatTabs(tab, fadeTabsNoBackdrop and true or false)
			else
				CH:SetupChatTabs(tab, false)
			end
		end
	end
end

function CH:RefreshToggleButtons()
	LeftChatToggleButton:SetAlpha(E.db.LeftChatPanelFaded and E.db.chat.fadeChatToggles and 0 or 1)
	RightChatToggleButton:SetAlpha(E.db.RightChatPanelFaded and E.db.chat.fadeChatToggles and 0 or 1)
end

function CH:PositionChat(override)
	if (InCombatLockdown() and not override and CH.initialMove) or (IsMouseButtonDown("LeftButton") and not override) then return end
	if not RightChatPanel or not LeftChatPanel then return end
	if not CH.db.lockPositions or not E.private.chat.enable then return end

	RightChatPanel:Size(CH.db.separateSizes and CH.db.panelWidthRight or CH.db.panelWidth, CH.db.separateSizes and CH.db.panelHeightRight or CH.db.panelHeight)
	LeftChatPanel:Size(CH.db.panelWidth, CH.db.panelHeight)

	self.RightChatWindowID = FindRightChatID()

	local fadeUndockedTabs = CH.db.fadeUndockedTabs
	local fadeTabsNoBackdrop = CH.db.fadeTabsNoBackdrop

	for id, frameName in ipairs(CHAT_FRAMES) do
		local BASE_OFFSET = 57 + E.Spacing*3

		local chat = _G[frameName]
		local tab = _G[format("%sTab", frameName)]

		tab.isDocked = chat.isDocked
		tab.owner = chat

		if chat:IsShown() and not (id > NUM_CHAT_WINDOWS) and id == self.RightChatWindowID then
			chat:ClearAllPoints()
			if E.db.datatexts.rightChatPanel then
				chat:Point("BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 1, 4)
			else
				BASE_OFFSET = BASE_OFFSET - 24
				chat:Point("BOTTOMLEFT", RightChatDataPanel, "BOTTOMLEFT", 1, 2)
			end
			if id ~= 2 then
				chat:Size((CH.db.separateSizes and CH.db.panelWidthRight or CH.db.panelWidth) - 11, (CH.db.separateSizes and CH.db.panelHeightRight or CH.db.panelHeight) - BASE_OFFSET)
			else
				chat:Size(CH.db.panelWidth - 11, (CH.db.panelHeight - BASE_OFFSET) - CombatLogQuickButtonFrame_Custom:GetHeight())
			end

			--Pass a 2nd argument which prevents an infinite loop in our ON_FCF_SavePositionAndDimensions function
			if chat:GetLeft() then
				FCF_SavePositionAndDimensions(chat, true)
			end

			tab:SetParent(RightChatPanel)
			chat:SetParent(RightChatPanel)

			if chat:IsMovable() then
				chat:SetUserPlaced(true)
			end
			if CH.db.panelBackdrop == "HIDEBOTH" or CH.db.panelBackdrop == "LEFT" then
				CH:SetupChatTabs(tab, fadeTabsNoBackdrop and true or false)
			else
				CH:SetupChatTabs(tab, false)
			end
		elseif not chat.isDocked and chat:IsShown() then
			tab:SetParent(UIParent)
			chat:SetParent(UIParent)
			CH:SetupChatTabs(tab, fadeUndockedTabs and true or false)
		else
			if id ~= 2 and not (id > NUM_CHAT_WINDOWS) then
				chat:ClearAllPoints()
				if E.db.datatexts.leftChatPanel then
					chat:Point("BOTTOMLEFT", LeftChatToggleButton, "TOPLEFT", 1, 4)
				else
					BASE_OFFSET = BASE_OFFSET - 24
					chat:Point("BOTTOMLEFT", LeftChatToggleButton, "BOTTOMLEFT", 1, 2)
				end
				chat:Size(CH.db.panelWidth - 11, (CH.db.panelHeight - BASE_OFFSET))

				--Pass a 2nd argument which prevents an infinite loop in our ON_FCF_SavePositionAndDimensions function
				if chat:GetLeft() then
					FCF_SavePositionAndDimensions(chat, true)
				end
			end
			chat:SetParent(LeftChatPanel)
			if id > 2 then
				tab:SetParent(GeneralDockManagerScrollFrameChild)
			else
				tab:SetParent(GeneralDockManager)
			end
			if chat:IsMovable() then
				chat:SetUserPlaced(true)
			end

			if CH.db.panelBackdrop == "HIDEBOTH" or CH.db.panelBackdrop == "RIGHT" then
				CH:SetupChatTabs(tab, fadeTabsNoBackdrop and true or false)
			else
				CH:SetupChatTabs(tab, false)
			end
		end
	end

	LO:RepositionChatDataPanels()

	self.initialMove = true
end

function CH:Panels_ColorUpdate()
	local panelColor = CH.db.panelColor
	LeftChatPanel.backdrop:SetBackdropColor(panelColor.r, panelColor.g, panelColor.b, panelColor.a)
	RightChatPanel.backdrop:SetBackdropColor(panelColor.r, panelColor.g, panelColor.b, panelColor.a)
end

function CH:UpdateChatTabColors()
	for _, frameName in ipairs(CHAT_FRAMES) do
		local tab = _G[format("%sTab", frameName)]

		CH:FCFTab_UpdateColors(tab, tab.selected)
	end
end
E.valueColorUpdateFuncs[CH.UpdateChatTabColors] = true

function CH:ScrollToBottom(frame)
	frame:ScrollToBottom()

	CH:CancelTimer(frame.ScrollTimer, true)
end

function CH:PrintURL(url)
	return "|cFFFFFFFF[|Hurl:"..url.."|h"..url.."|h]|r "
end

function CH:FindURL(event, msg, author, ...)
	if not CH.db.url then
		msg = CH:CheckKeyword(msg, author)
		msg = CH:GetSmileyReplacementText(msg)
		return false, msg, author, ...
	end

	local text, tag = msg, strmatch(msg, "{(.-)}")
	if tag and ICON_TAG_LIST[strlower(tag)] then
		text = gsub(gsub(text, "(%S)({.-})", "%1 %2"), "({.-})(%S)", "%1 %2")
	end

	text = gsub(gsub(text, "(%S)(|c.-|H.-|h.-|h|r)", "%1 %2"), "(|c.-|H.-|h.-|h|r)(%S)", "%1 %2")
	-- http://example.com
	local newMsg, found = gsub(text, "(%a+)://(%S+)%s?", CH:PrintURL("%1://%2"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg, author)), author, ... end
	-- www.example.com
	newMsg, found = gsub(text, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", CH:PrintURL("www.%1.%2"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg, author)), author, ... end
	-- example@example.com
	newMsg, found = gsub(text, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", CH:PrintURL("%1@%2%3%4"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg, author)), author, ... end
	-- IP address with port 1.1.1.1:1
	newMsg, found = gsub(text, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)(:%d+)%s?", CH:PrintURL("%1.%2.%3.%4%5"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg, author)), author, ... end
	-- IP address 1.1.1.1
	newMsg, found = gsub(text, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?", CH:PrintURL("%1.%2.%3.%4"))
	if found > 0 then return false, CH:GetSmileyReplacementText(CH:CheckKeyword(newMsg, author)), author, ... end

	msg = CH:CheckKeyword(msg, author)
	msg = CH:GetSmileyReplacementText(msg)

	return false, msg, author, ...
end

function CH:SetChatEditBoxMessage(message)
	local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
	local editBoxText = ChatFrameEditBox:GetText()

	if not ChatFrameEditBox:IsShown() then
		ChatEdit_ActivateChat(ChatFrameEditBox)
	end

	if editBoxText and editBoxText ~= "" then
		ChatFrameEditBox:SetText("")
	end

	ChatFrameEditBox:Insert(message)
	ChatFrameEditBox:HighlightText()
end

local function HyperLinkedURL(data)
	if strsub(data, 1, 3) == "url" then
		local currentLink = strsub(data, 5)
		if currentLink and currentLink ~= "" then
			CH:SetChatEditBoxMessage(currentLink)
		end
	end
end

local SetHyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(data, ...)
	if strsub(data, 1, 3) == "url" then
		HyperLinkedURL(data)
	else
		SetHyperlink(self, data, ...)
	end
end

local hyperLinkEntered
function CH:OnHyperlinkEnter(frame, refString)
	if InCombatLockdown() then return end
	local linkToken = strmatch(refString, "^([^:]+)")
	if hyperlinkTypes[linkToken] then
		GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(refString)
		GameTooltip:Show()
		hyperLinkEntered = frame
	end
end

function CH:OnHyperlinkLeave()
	if hyperLinkEntered then
		hyperLinkEntered = nil
		GameTooltip:Hide()
	end
end

function CH:OnMessageScrollChanged(frame)
	if hyperLinkEntered == frame then
		hyperLinkEntered = nil
		GameTooltip:Hide()
	end
end

function CH:ToggleHyperlink(enable)
	for _, frameName in ipairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		local hooked = CH.hooks and CH.hooks[frame] and CH.hooks[frame].OnHyperlinkEnter
		if enable and not hooked then
			CH:HookScript(frame, "OnHyperlinkEnter")
			CH:HookScript(frame, "OnHyperlinkLeave")
			CH:HookScript(frame, "OnMessageScrollChanged")
		elseif not enable and hooked then
			CH:Unhook(frame, "OnHyperlinkEnter")
			CH:Unhook(frame, "OnHyperlinkLeave")
			CH:Unhook(frame, "OnMessageScrollChanged")
		end
	end
end

function CH:DisableChatThrottle()
	wipe(throttle)
end

function CH:ShortChannel()
	return format("|Hchannel:%s|h[%s]|h", self, DEFAULT_STRINGS[strupper(self)] or gsub(self, "channel:", ""))
end

function CH:HandleShortChannels(msg)
	msg = gsub(msg, "|Hchannel:(.-)|h%[(.-)%]|h", CH.ShortChannel)
	msg = gsub(msg, "CHANNEL:", "")
	msg = gsub(msg, "^(.-|h) "..L["whispers"], "%1")
	msg = gsub(msg, "^(.-|h) "..L["says"], "%1")
	msg = gsub(msg, "^(.-|h) "..L["yells"], "%1")
	msg = gsub(msg, "<"..AFK..">", "[|cffFF0000"..AFK.."|r] ")
	msg = gsub(msg, "<"..DND..">", "[|cffE7E716"..DND.."|r] ")
	msg = gsub(msg, "%[BN_CONVERSATION:", "%[".."")
	msg = gsub(msg, "^%["..RAID_WARNING.."%]", "["..L["RW"].."]")

	return msg
end

--Copied from FrameXML ChatFrame.lua and modified to add CUSTOM_CLASS_COLORS
function CH:GetColoredName(event, _, arg2, _, _, _, _, _, arg8, _, _, _, arg12)
	local chatType = strsub(event, 10)
	local subType = strsub(chatType, 1, 7)
	if subType == "WHISPER" then
		chatType = "WHISPER"
	elseif subType == "CHANNEL" then
		chatType = "CHANNEL"..arg8
	end

	--ambiguate guild chat names
	arg2 = Ambiguate(arg2, (chatType == "GUILD" and "guild") or "none")

	local info = ChatTypeInfo[chatType]
	if info and info.colorNameByClass and arg12 then
		local _, englishClass = GetPlayerInfoByGUID(arg12)

		if englishClass then
			local classColorTable = E:ClassColor(englishClass)
			if not classColorTable then
				return arg2
			end
			return format("\124cff%.2x%.2x%.2x", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255)..arg2.."\124r"
		end
	end

	return arg2
end

local function GetChatIcons(sender)
	for realm in pairs(specialChatIcons) do
		for character, texture in pairs(specialChatIcons[realm]) do
			if (realm == PLAYER_REALM and sender == character) or sender == character.."-"..realm then
				return texture
			end
		end
	end
end

function CH:ChatFrame_MessageEventHandler(frame, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, isHistory, historyTime, historyName)
	-- ElvUI Chat History Note: isHistory, historyTime and historyName are passed from CH:DisplayChatHistory() and need to be on the end to prevent issues in other addons that listen on ChatFrame_MessageEventHandler.
	-- we also send isHistory and historyTime into CH:AddMessage so that we don't have to override the timestamp.
	if strsub(event, 1, 8) == "CHAT_MSG" then
		local notChatHistory, historySavedName --we need to extend the arguments on CH.ChatFrame_MessageEventHandler so we can properly handle saved names without overriding
		if isHistory == "ElvUI_ChatHistory" then
			historySavedName = historyName
		else
			notChatHistory = true
		end

		local chatType = strsub(event, 10)
		local info = ChatTypeInfo[chatType]

		local chatFilters = ChatFrame_GetMessageEventFilters(event)
		if chatFilters then
			for _, filterFunc in next, chatFilters do
				local filter, newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12, newarg13, newarg14 = filterFunc(frame, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
				if filter then
					return true
				elseif newarg1 then
					arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14 = newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12, newarg13, newarg14
				end
			end
		end

		local _, _, englishClass, _, _, _, name, realm = pcall(GetPlayerInfoByGUID, arg12)
		local nameWithRealm = strmatch(realm ~= "" and realm or E.myrealm, "%s*(%S+)$")
		if name and name ~= "" then
			nameWithRealm = name.."-"..nameWithRealm
			CH.ClassNames[strlower(name)] = englishClass
			CH.ClassNames[strlower(nameWithRealm)] = englishClass
		end

		local coloredName = historySavedName or CH:GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)

		local channelLength = strlen(arg4)
		local infoType = chatType
		if (strsub(chatType, 1, 7) == "CHANNEL") and (chatType ~= "CHANNEL_LIST") and ((arg1 ~= "INVITE") or (chatType ~= "CHANNEL_NOTICE_USER")) then
			if arg1 == "WRONG_PASSWORD" then
				local staticPopup = _G[StaticPopup_Visible("CHAT_CHANNEL_PASSWORD") or ""]
				if staticPopup and strupper(staticPopup.data) == strupper(arg9) then
					-- Don't display invalid password messages if we're going to prompt for a password (bug 102312)
					return
				end
			end

			local found = 0
			for index, value in pairs(frame.channelList) do
				if channelLength > strlen(value) then
					-- arg9 is the channel name without the number in front...
					if ((arg7 > 0) and (frame.zoneChannelList[index] == arg7)) or (strupper(value) == strupper(arg9)) then
						found = 1
						infoType = "CHANNEL"..arg8
						info = ChatTypeInfo[infoType]
						if (chatType == "CHANNEL_NOTICE") and (arg1 == "YOU_LEFT") then
							frame.channelList[index] = nil
							frame.zoneChannelList[index] = nil
						end
						break
					end
				end
			end
			if (found == 0) or not info then
				return true
			end
		end

		local chatGroup = Chat_GetChatCategory(chatType)
		local chatTarget
		if chatGroup == "CHANNEL" or chatGroup == "BN_CONVERSATION" then
			chatTarget = tostring(arg8)
		elseif chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" then
			if not strsub(arg2, 1, 2) == "|K" then
				chatTarget = strupper(arg2)
			else
				chatTarget = arg2
			end
		end

		if FCFManager_ShouldSuppressMessage(frame, chatGroup, chatTarget) then
			return true
		end

		if chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" then
			if frame.privateMessageList and not frame.privateMessageList[strlower(arg2)] then
				return true
			elseif frame.excludePrivateMessageList and frame.excludePrivateMessageList[strlower(arg2)]
				and (chatGroup == "WHISPER" and GetCVar("whisperMode") ~= "popout_and_inline") or (chatGroup == "BN_WHISPER" and GetCVar("bnWhisperMode") ~= "popout_and_inline") then
				return true
			end
		elseif chatGroup == "BN_CONVERSATION" then
			if frame.bnConversationList and not frame.bnConversationList[arg8] then
				return true
			elseif frame.excludeBNConversationList and frame.excludeBNConversationList[arg8] and GetCVar("conversationMode") ~= "popout_and_inline" then
				return true
			end
		end

		if frame.privateMessageList then
			-- Dedicated BN whisper windows need online/offline messages for only that player
			if (chatGroup == "BN_INLINE_TOAST_ALERT" or chatGroup == "BN_WHISPER_PLAYER_OFFLINE") and not frame.privateMessageList[strlower(arg2)] then
				return true
			end

			-- HACK to put certain system messages into dedicated whisper windows
			if chatGroup == "SYSTEM" then
				local matchFound = false
				local message = strlower(arg1)
				for playerName in pairs(frame.privateMessageList) do
					local playerNotFoundMsg = strlower(format(ERR_CHAT_PLAYER_NOT_FOUND_S, playerName))
					local charOnlineMsg = strlower(format(ERR_FRIEND_ONLINE_SS, playerName, playerName))
					local charOfflineMsg = strlower(format(ERR_FRIEND_OFFLINE_S, playerName))
					if message == playerNotFoundMsg or message == charOnlineMsg or message == charOfflineMsg then
						matchFound = true
						break
					end
				end

				if not matchFound then
					return true
				end
			end
		end

		if chatType == "SYSTEM" or chatType == "SKILL" or chatType == "LOOT" or chatType == "CURRENCY" or chatType == "MONEY"
		or chatType == "OPENING" or chatType == "TRADESKILLS" or chatType == "PET_INFO" or chatType == "TARGETICONS" or chatType == "BN_WHISPER_PLAYER_OFFLINE" then
			frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
		elseif strsub(chatType, 1, 7) == "COMBAT_" then
			frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
		elseif strsub(chatType, 1, 6) == "SPELL_" then
			frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
		elseif strsub(chatType, 1, 10) == "BG_SYSTEM_" then
			frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
		elseif strsub(chatType, 1, 11) == "ACHIEVEMENT" then
			frame:AddMessage(format(arg1, "|Hplayer:"..arg2.."|h".."["..coloredName.."]".."|h"), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
		elseif strsub(chatType, 1, 18) == "GUILD_ACHIEVEMENT" then
			frame:AddMessage(format(arg1, "|Hplayer:"..arg2.."|h".."["..coloredName.."]".."|h"), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
		elseif chatType == "IGNORED" then
			frame:AddMessage(format(CHAT_IGNORED, arg2), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
		elseif chatType == "FILTERED" then
			frame:AddMessage(format(CHAT_FILTERED, arg2), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
		elseif chatType == "RESTRICTED" then
			frame:AddMessage(CHAT_RESTRICTED, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
		elseif chatType == "CHANNEL_LIST" then
			if channelLength > 0 then
				frame:AddMessage(format(_G["CHAT_"..chatType.."_GET"]..arg1, tonumber(arg8), arg4), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
			else
				frame:AddMessage(arg1, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
			end
		elseif chatType == "CHANNEL_NOTICE_USER" then
			local globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"]
			if not globalstring then
				globalstring = _G["CHAT_"..arg1.."_NOTICE"]
			end

			if strlen(arg5) > 0 then
				-- TWO users in this notice (E.G. x kicked y)
				frame:AddMessage(format(globalstring, arg8, arg4, arg2, arg5), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
			elseif arg1 == "INVITE" then
				frame:AddMessage(format(globalstring, arg4, arg2), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
			else
				frame:AddMessage(format(globalstring, arg8, arg4, arg2), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
			end
			if arg1 == "INVITE" and GetCVarBool("blockChannelInvites") then
				frame:AddMessage(CHAT_MSG_BLOCK_CHAT_CHANNEL_INVITE, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
			end
		elseif chatType == "CHANNEL_NOTICE" then
			if arg1 == "NOT_IN_LFG" then return end

			local globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"]
			if not globalstring then
				globalstring = _G["CHAT_"..arg1.."_NOTICE"]
			end
			if arg10 > 0 then
				arg4 = arg4.." "..arg10
			end

			local accessID = ChatHistory_GetAccessID(Chat_GetChatCategory(chatType), arg8)
			local typeID = ChatHistory_GetAccessID(infoType, arg8, arg12)
			frame:AddMessage(format(globalstring, arg8, arg4), info.r, info.g, info.b, info.id, accessID, typeID, isHistory, historyTime)
		elseif chatType == "BN_CONVERSATION_NOTICE" then
			local channelLink = format(CHAT_BN_CONVERSATION_GET_LINK, arg8, MAX_WOW_CHAT_CHANNELS + arg8)
			local playerLink = format("|HBNplayer:%s:%s:%s:%s:%s|h[%s]|h", arg2, arg13, arg11, Chat_GetChatCategory(chatType), arg8, arg2)
			local message = format(_G["CHAT_CONVERSATION_"..arg1.."_NOTICE"], channelLink, playerLink)

			local accessID = ChatHistory_GetAccessID(Chat_GetChatCategory(chatType), arg8)
			local typeID = ChatHistory_GetAccessID(infoType, arg8, arg12)
			frame:AddMessage(message, info.r, info.g, info.b, info.id, accessID, typeID, isHistory, historyTime)
		elseif chatType == "BN_CONVERSATION_LIST" then
			local channelLink = format(CHAT_BN_CONVERSATION_GET_LINK, arg8, MAX_WOW_CHAT_CHANNELS + arg8)
			local message = format(CHAT_BN_CONVERSATION_LIST, channelLink, arg1)
			frame:AddMessage(message, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
		elseif chatType == "BN_INLINE_TOAST_ALERT" then
			if arg1 == "FRIEND_OFFLINE" and not BNet_ShouldProcessOfflineEvents() then
				return true
			end
			local globalstring = _G["BN_INLINE_TOAST_"..arg1]
			local message
			if arg1 == "FRIEND_REQUEST" then
				message = globalstring
			elseif arg1 == "FRIEND_PENDING" then
				message = format(BN_INLINE_TOAST_FRIEND_PENDING, BNGetNumFriendInvites())
			elseif arg1 == "FRIEND_REMOVED" or arg1 == "BATTLETAG_FRIEND_REMOVED" then
				message = format(globalstring, arg2)
			elseif arg1 == "FRIEND_ONLINE" or arg1 == "FRIEND_OFFLINE" then
				local _, toonName, client = BNGetToonInfo(arg13)
				if toonName and toonName ~= "" and client and client ~= "" then
					local toonNameText = BNet_GetClientEmbeddedTexture(client, 14)..toonName
					local playerLink = format("|HBNplayer:%s:%s:%s:%s:%s|h[%s] (%s)|h", arg2, arg13, arg11, Chat_GetChatCategory(chatType), 0, arg2, toonNameText)
					message = format(globalstring, playerLink)
				else
					local playerLink = format("|HBNplayer:%s:%s:%s:%s:%s|h[%s]|h", arg2, arg13, arg11, Chat_GetChatCategory(chatType), 0, arg2)
					message = format(globalstring, playerLink)
				end
			else
				local playerLink = format("|HBNplayer:%s:%s:%s:%s:%s|h[%s]|h", arg2, arg13, arg11, Chat_GetChatCategory(chatType), 0, arg2)
				message = format(globalstring, playerLink)
			end
			frame:AddMessage(message, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
		elseif chatType == "BN_INLINE_TOAST_BROADCAST" then
			if arg1 ~= "" then
				arg1 = RemoveExtraSpaces(arg1)
				local playerLink = format("|HBNplayer:%s:%s:%s:%s:%s|h[%s]|h", arg2, arg13, arg11, Chat_GetChatCategory(chatType), 0, arg2)
				frame:AddMessage(format(BN_INLINE_TOAST_BROADCAST, playerLink, arg1), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
			end
		elseif chatType == "BN_INLINE_TOAST_BROADCAST_INFORM" then
			if arg1 ~= "" then
				arg1 = RemoveExtraSpaces(arg1)
				frame:AddMessage(BN_INLINE_TOAST_BROADCAST_INFORM, info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
			end
		elseif chatType == "BN_INLINE_TOAST_CONVERSATION" then
			frame:AddMessage(format(BN_INLINE_TOAST_CONVERSATION, arg1), info.r, info.g, info.b, info.id, nil, nil, isHistory, historyTime)
		else
			local body
			local _, fontHeight = FCF_GetChatWindowInfo(frame:GetID())

			if fontHeight == 0 then
				--fontHeight will be 0 if it's still at the default (14)
				fontHeight = 14
			end

			-- Add AFK/DND flags
			local pflag = GetChatIcons(arg2)
			if arg6 ~= "" then
				if arg6 == "GM" then
					--If it was a whisper, dispatch it to the GMChat addon.
					if chatType == "WHISPER" then return end

					--Add Blizzard Icon, this was sent by a GM
					pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t "
				elseif arg6 == "DEV" then
					--Add Blizzard Icon, this was sent by a Dev
					pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t "
				elseif arg6 == "DND" or arg6 == "AFK" then
					pflag = (pflag or "").._G["CHAT_FLAG_"..arg6]
				else
					pflag = _G["CHAT_FLAG_"..arg6]
				end
			else
				if pflag == true then
					pflag = ""
				end

				if lfgRoles[arg2] and (chatType == "PARTY_LEADER" or chatType == "PARTY" or chatType == "RAID" or chatType == "RAID_LEADER" or chatType == "INSTANCE_CHAT" or chatType == "INSTANCE_CHAT_LEADER") then
					pflag = lfgRoles[arg2]..(pflag or "")
				end
			end

			pflag = pflag or ""

			if chatType == "WHISPER_INFORM" and GMChatFrame_IsGM and GMChatFrame_IsGM(arg2) then return end

			local showLink = 1
			if strsub(chatType, 1, 7) == "MONSTER" or strsub(chatType, 1, 9) == "RAID_BOSS" then
				showLink = nil
			else
				arg1 = gsub(arg1, "%%", "%%%%")
			end

			-- Search for icon links and replace them with texture links.
			local term
			for tag in gmatch(arg1, "%b{}") do
				term = strlower(gsub(tag, "[{}]", ""))
				if ICON_TAG_LIST[term] and ICON_LIST[ICON_TAG_LIST[term]] then
					arg1 = gsub(arg1, tag, ICON_LIST[ICON_TAG_LIST[term]].."0|t")
				elseif GROUP_TAG_LIST[term] then
					local groupIndex = GROUP_TAG_LIST[term]
					local groupList = "["
					for i = 1, GetNumGroupMembers() do
						local playerName, _, subgroup, _, _, classFileName = GetRaidRosterInfo(i)
						if playerName and subgroup == groupIndex then
							local classColorTable = E:ClassColor(classFileName)
							if classColorTable then
								playerName = format("\124cff%.2x%.2x%.2x%s\124r", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255, playerName)
							end
							groupList = groupList..(groupList == "[" and "" or PLAYER_LIST_DELIMITER)..playerName
						end
					end
					groupList = groupList.."]"
					arg1 = gsub(arg1, tag, groupList)
				end
			end

			--Remove groups of many spaces
			arg1 = RemoveExtraSpaces(arg1)

			local playerLink

			if chatType ~= "BN_WHISPER" and chatType ~= "BN_WHISPER_INFORM" and chatType ~= "BN_CONVERSATION" then
				playerLink = "|Hplayer:"..arg2..":"..arg11..":"..chatGroup..(chatTarget and ":"..chatTarget or "").."|h"
			else
				playerLink = "|HBNplayer:"..arg2..":"..arg13..":"..arg11..":"..chatGroup..(chatTarget and ":"..chatTarget or "").."|h"
			end

			local message = arg1
			if arg14 then --isMobile
				message = ChatFrame_GetMobileEmbeddedTexture(info.r, info.g, info.b)..message
			end

			if (strlen(arg3) > 0) and (arg3 ~= frame.defaultLanguage) then
				local languageHeader = "["..arg3.."] "
				if showLink and (strlen(arg2) > 0) then
					body = format(_G["CHAT_"..chatType.."_GET"]..languageHeader..message, pflag..playerLink.."["..coloredName.."]".."|h")
				else
					body = format(_G["CHAT_"..chatType.."_GET"]..languageHeader..message, pflag..arg2)
				end
			else
				if not showLink or strlen(arg2) == 0 then
					if chatType == "TEXT_EMOTE" then
						body = message
					else
						body = format(_G["CHAT_"..chatType.."_GET"]..message, pflag..arg2, arg2)
					end
				else
					if chatType == "EMOTE" then
						body = format(_G["CHAT_"..chatType.."_GET"]..message, pflag..playerLink..coloredName.."|h")
					elseif chatType == "TEXT_EMOTE" then
						body = gsub(message, arg2, pflag..playerLink..coloredName.."|h", 1)
					else
						body = format(_G["CHAT_"..chatType.."_GET"]..message, pflag..playerLink.."["..coloredName.."]".."|h")
					end
				end
			end

			-- Add Channel
			arg4 = gsub(arg4, "%s%-%s.*", "")
			if chatGroup == "BN_CONVERSATION" then
				body = format(CHAT_BN_CONVERSATION_GET_LINK, MAX_WOW_CHAT_CHANNELS + arg8, MAX_WOW_CHAT_CHANNELS + arg8)..body
			elseif channelLength > 0 then
				body = "|Hchannel:channel:"..arg8.."|h["..arg4.."]|h "..body
			end

			if CH.db.shortChannels and (chatType ~= "EMOTE" and chatType ~= "TEXT_EMOTE") then
				body = CH:HandleShortChannels(body)
			end

			local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget)
			local typeID = ChatHistory_GetAccessID(infoType, chatTarget, arg12 == "" and arg13 or arg12)

			local notMyName = not (arg2 == E.myname or arg2 == PLAYER_NAME)
			-- Support private servers with custom realm name at character's 'name-realm'
			local myCustomName = false
			for _, customRealm in pairs(E.privateServerRealms) do
				local customRealmName = format("%s-%s", E.myname, customRealm)
				if arg2 == customRealmName then
					myCustomName = true
				end
			end

			
			if notChatHistory and notMyName and not myCustomName and not CH.SoundTimer and (not CH.db.noAlertInCombat or not InCombatLockdown()) then
				local channels = chatGroup ~= "WHISPER" and chatGroup or (chatType == "WHISPER" or chatType == "BN_WHISPER") and "WHISPER"
				local alertType = CH.db.channelAlerts[channels]

				if alertType and alertType ~= "None" then
					CH.SoundTimer = E:Delay(5, CH.ThrottleSound)
					PlaySoundFile(LSM:Fetch("sound", alertType), "Master")
				end
			end

			frame:AddMessage(body, info.r, info.g, info.b, info.id, accessID, typeID, isHistory, historyTime)

			if notChatHistory and (chatType == "WHISPER" or chatType == "BN_WHISPER") then
				ChatEdit_SetLastTellTarget(arg2, chatType)
			end
		end

		if notChatHistory and not frame:IsShown() then
			if (frame == DEFAULT_CHAT_FRAME and info.flashTabOnGeneral) or (frame ~= DEFAULT_CHAT_FRAME and info.flashTab) then
				if not CHAT_OPTIONS.HIDE_FRAME_ALERTS or chatType == "WHISPER" or chatType == "BN_WHISPER" then
					if not (chatType == "BN_CONVERSATION" and BNIsSelf(arg13)) then
						if not FCFManager_ShouldSuppressMessageFlash(frame, chatGroup, chatTarget) then
							FCF_StartAlertFlash(frame)
						end
					end
				end
			end
		end

		return true
	end
end

function CH:ChatFrame_ConfigEventHandler(...)
	return ChatFrame_ConfigEventHandler(...)
end

function CH:ChatFrame_SystemEventHandler(frame, event, message, ...)
	return ChatFrame_SystemEventHandler(frame, event, message, ...)
end

function CH:ChatFrame_OnEvent(...)
	if CH:ChatFrame_ConfigEventHandler(...) then return end
	if CH:ChatFrame_SystemEventHandler(...) then return end
	if CH:ChatFrame_MessageEventHandler(...) then return end
end

function CH:FloatingChatFrame_OnEvent(...)
	CH:ChatFrame_OnEvent(...)
	FloatingChatFrame_OnEvent(...)
end

local function FloatingChatFrameOnEvent(...)
	CH:FloatingChatFrame_OnEvent(...)
end

function CH:SetupChat()
	if not E.private.chat.enable then return end

	for id, frameName in ipairs(CHAT_FRAMES) do
		local frame = _G[frameName]

		CH:StyleChat(frame)
		FCFTab_UpdateAlpha(frame)

		local _, fontSize = FCF_GetChatWindowInfo(id)
		frame:FontTemplate(LSM:Fetch("font", CH.db.font), fontSize, CH.db.fontOutline)
		frame:SetTimeVisible(CH.db.inactivityTimer)
		frame:SetFading(CH.db.fade)

		if CH.db.maxLines ~= frame:GetMaxLines() then
			frame:SetMaxLines(CH.db.maxLines)
		end

		if id ~= 2 and not frame.OldAddMessage then
			--Don't add timestamps to combat log, they don't work.
			--This usually taints, but LibChatAnims should make sure it doesn't.
			frame.OldAddMessage = frame.AddMessage
			frame.AddMessage = CH.AddMessage
		end

		if not frame.scriptsSet then
			frame:SetScript("OnMouseWheel", ChatFrame_OnMouseScroll)

			if id ~= 2 then
				frame:SetScript("OnEvent", FloatingChatFrameOnEvent)
			end

			hooksecurefunc(frame, "SetScript", function(f, script, func)
				if script == "OnMouseWheel" and func ~= ChatFrame_OnMouseScroll then
					f:SetScript(script, ChatFrame_OnMouseScroll)
				end
			end)
			frame.scriptsSet = true
		end
	end

	CH:ToggleHyperlink(CH.db.hyperlinkHover)

	CH:UpdateDockState()
	CH:PositionChat(true)

	if not CH.HookSecured then
		CH:SecureHook("FCF_OpenTemporaryWindow", "SetupChat")
		CH.HookSecured = true
	end
end

local function PrepareMessage(author, message)
	if author and author ~= "" and message and message ~= "" then
		return strupper(author)..message
	end
end

function CH:ChatThrottleHandler(arg1, arg2, when)
	local msg = PrepareMessage(arg1, arg2)
	if msg then
		for message, object in pairs(throttle) do
			if difftime(when, object.time) >= CH.db.throttleInterval then
				throttle[message] = nil
			end
		end

		if not throttle[msg] then
			throttle[msg] = {time = time(), count = 1}
		else
			throttle[msg].count = throttle[msg].count + 1
		end
	end
end

function CH:ChatThrottleBlockFlag(author, message, when)
	local notMyName = not (author == E.myname or author == PLAYER_NAME)
	-- Support private servers with custom realm name at character's 'name-realm'
	local myCustomName = false
	for _, customRealm in pairs(E.privateServerRealms) do
		local customRealmName = format("%s-%s", E.myname, customRealm)
		if author == customRealmName then
			myCustomName = true
		end
	end

	local msg = notMyName and not myCustomName and (CH.db.throttleInterval ~= 0) and PrepareMessage(author, message)
	local object = msg and throttle[msg]

	return object and object.time and object.count and object.count > 1 and (difftime(when, object.time) <= CH.db.throttleInterval), object
end

function CH:ChatThrottleIntervalHandler(event, message, author, ...)
	local blockFlag, blockObject = CH:ChatThrottleBlockFlag(author, message, time())

	if blockFlag then
		return true
	else
		if blockObject then blockObject.time = time() end
		return CH:FindURL(event, message, author, ...)
	end
end

function CH:CHAT_MSG_CHANNEL(event, message, author, ...)
	return CH:ChatThrottleIntervalHandler(event, message, author, ...)
end

function CH:CHAT_MSG_YELL(event, message, author, ...)
	return CH:ChatThrottleIntervalHandler(event, message, author, ...)
end

function CH:CHAT_MSG_SAY(event, message, author, ...)
	return CH:ChatThrottleIntervalHandler(event, message, author, ...)
end

function CH:ThrottleSound()
	CH.SoundTimer = nil
end

local protectLinks = {}
function CH:CheckKeyword(message, author)
	local letInCombat = not CH.db.noAlertInCombat or not InCombatLockdown()
	local notMyName = not (author == E.myname or author == PLAYER_NAME)
	-- Support private servers with custom realm name at character's 'name-realm'
	local myCustomName = false
	for _, customRealm in pairs(E.privateServerRealms) do
		local customRealmName = format("%s-%s", E.myname, customRealm)
		if author == customRealmName then
			myCustomName = true
		end
	end

	local letSound = not CH.SoundTimer and notMyName and not myCustomName and CH.db.keywordSound ~= "None" and letInCombat

	for hyperLink in gmatch(message, "|%x+|H.-|h.-|h|r") do
		protectLinks[hyperLink] = gsub(hyperLink,"%s","|s")

		if letSound then
			for keyword in pairs(CH.Keywords) do
				if hyperLink == keyword then
					CH.SoundTimer = E:Delay(5, CH.ThrottleSound)
					PlaySoundFile(LSM:Fetch("sound", CH.db.keywordSound), "Master")
					letSound = false -- dont let a second sound fire below
					break
				end
			end
		end
	end

	for hyperLink, tempLink in pairs(protectLinks) do
		message = gsub(message, E:EscapeString(hyperLink), tempLink)
	end

	local rebuiltString
	local isFirstWord = true
	for word in gmatch(message, "%s-%S+%s*") do
		if not next(protectLinks) or not protectLinks[gsub(gsub(word,"%s",""),"|s"," ")] then
			local tempWord = gsub(word, "[%s%p]", "")
			local lowerCaseWord = strlower(tempWord)

			for keyword in pairs(CH.Keywords) do
				if lowerCaseWord == strlower(keyword) then
					word = gsub(word, tempWord, format("%s%s|r", E.media.hexvaluecolor, tempWord))
					if letSound then -- dont break because it's recoloring all found
						CH.SoundTimer = E:Delay(5, CH.ThrottleSound)
						PlaySoundFile(LSM:Fetch("sound", CH.db.keywordSound), "Master")
						letSound = false -- but dont let additional hits call the sound
					end
				end
			end

			if CH.db.classColorMentionsChat then
				tempWord = gsub(word,"^[%s%p]-([^%s%p]+)([%-]?[^%s%p]-)[%s%p]*$","%1%2")
				lowerCaseWord = strlower(tempWord)

				local classMatch = CH.ClassNames[lowerCaseWord]
				local wordMatch = classMatch and lowerCaseWord

				if wordMatch and not E.global.chat.classColorMentionExcludedNames[wordMatch] then
					local classColorTable = E:ClassColor(classMatch)
					if classColorTable then
						word = gsub(word, gsub(tempWord, "%-","%%-"), format("\124cff%.2x%.2x%.2x%s\124r", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255, tempWord))
					end
				end
			end
		end

		if isFirstWord then
			rebuiltString = word
			isFirstWord = false
		else
			rebuiltString = rebuiltString..word
		end
	end

	for hyperLink, tempLink in pairs(protectLinks) do
		rebuiltString = gsub(rebuiltString, E:EscapeString(tempLink), hyperLink)
		protectLinks[hyperLink] = nil
	end

	return rebuiltString
end

function CH:AddLines(lines, ...)
	for i = select("#", ...), 1, -1 do
		local x = select(i, ...)
		if x:IsObjectType("FontString") and not x:GetName() then
			tinsert(lines, x:GetText())
		end
	end
end

function CH:ChatEdit_OnEnterPressed(editBox)
	local chatType = editBox:GetAttribute("chatType")
	local chatFrame = chatType and editBox:GetParent()
	if chatFrame and (not chatFrame.isTemporary) and (ChatTypeInfo[chatType].sticky == 1) then
		if not CH.db.sticky then chatType = "SAY" end
		editBox:SetAttribute("chatType", chatType)
	end
end

function CH:SetChatFont(dropDown, chatFrame, fontSize)
	if not chatFrame then chatFrame = FCF_GetCurrentChatFrame() end
	if not fontSize then fontSize = dropDown.value end

	chatFrame:FontTemplate(LSM:Fetch("font", CH.db.font), fontSize, CH.db.fontOutline)
end

CH.SecureSlashCMD = {
	"^/assist",
	"^/camp",
	"^/cancelaura",
	"^/cancelform",
	"^/cast",
	"^/castsequence",
	"^/equip",
	"^/exit",
	"^/logout",
	"^/reload",
	"^/rl",
	"^/startattack",
	"^/stopattack",
	"^/tar",
	"^/target",
	"^/use"
}

function CH:ChatEdit_AddHistory(_, line) -- editBox, line
	line = line and strtrim(line)

	if line and strlen(line) > 0 then
		for _, command in next, CH.SecureSlashCMD do
			if strmatch(line, command) then
				return
			end
		end

		for index, text in pairs(ElvCharacterDB.ChatEditHistory) do
			if text == line then
				tremove(ElvCharacterDB.ChatEditHistory, index)
				break
			end
		end

		tinsert(ElvCharacterDB.ChatEditHistory, line)

		if #ElvCharacterDB.ChatEditHistory > CH.db.editboxHistorySize then
			tremove(ElvCharacterDB.ChatEditHistory, 1)
		end
	end
end

function CH:UpdateChatKeywords()
	wipe(CH.Keywords)

	local keywords = CH.db.keywords
	keywords = gsub(keywords,",%s",",")

	for stringValue in gmatch(keywords, "[^,]+") do
		if stringValue ~= "" then
			CH.Keywords[stringValue] = true
		end
	end
end

function CH:PET_BATTLE_CLOSE()
	if not CH.db.autoClosePetBattleLog then return end

	-- closing a chat tab (or window) in combat = chat tab (or window) goofs..
	-- might have something to do with HideUIPanel inside of FCF_Close
	if InCombatLockdown() then
		CH:RegisterEvent("PLAYER_REGEN_ENABLED", "PET_BATTLE_CLOSE")
		return
	else -- we can take this off once it goes through once
		CH:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	for _, frameName in ipairs(CHAT_FRAMES) do
		local chat = _G[frameName]
		if chat then
			local text = _G[frameName.."Tab"]:GetText()
			if text and strmatch(text, DEFAULT_STRINGS.PET_BATTLE_COMBAT_LOG) then
				FCF_Close(chat)
				break -- we found it, dont gotta keep lookin'
			end
		end
	end
end

function CH:FCF_Close()
	-- clear these off when it's closed, used by FCFTab_UpdateColors
	for _, frameName in ipairs(CHAT_FRAMES) do
		local tab = _G[format("%sTab", frameName)]

		tab.whisperName = nil
		tab.classColor = nil
	end
end

function CH:UpdateFading()
	for _, frameName in ipairs(CHAT_FRAMES) do
		local frame = _G[frameName]

		frame:SetTimeVisible(CH.db.inactivityTimer)
		frame:SetFading(CH.db.fade)
	end
end

function CH:DisplayChatHistory()
	local data = ElvCharacterDB.ChatHistoryLog
	if not (data and next(data)) then return end

	CH.SoundTimer = true
	for _, chat in ipairs(CHAT_FRAMES) do
		for _, d in ipairs(data) do
			if type(d) == "table" then
				for _, messageType in ipairs(_G[chat].messageTypeList) do
					local historyType, skip = historyTypes[d[50]]
					if historyType then -- let others go by..
						if not CH.db.showHistory[historyType] then skip = true end -- but kill ignored ones
					end
					if not skip and gsub(strsub(d[50],10),"_INFORM","") == messageType then
						CH:ChatFrame_MessageEventHandler(_G[chat],d[50],d[1],d[2],d[3],d[4],d[5],d[6],d[7],d[8],d[9],d[10],d[11],d[12],d[13],d[14],"ElvUI_ChatHistory",d[51],d[52])
					end
				end
			end
		end
	end
	CH.SoundTimer = nil
end

tremove(ChatTypeGroup.GUILD, 2)
function CH:DelayGuildMOTD()
	local delay, checks, delayFrame = 0, 0, CreateFrame("Frame")
	tinsert(ChatTypeGroup.GUILD, 2, "GUILD_MOTD")

	delayFrame:SetScript("OnUpdate", function(df, elapsed)
		delay = delay + elapsed
		if delay < 5 then return end

		local msg = GetGuildRosterMOTD()
		if msg and strlen(msg) > 0 then
			for _, frame in ipairs(CHAT_FRAMES) do
				local chat = _G[frame]
				if chat:IsEventRegistered("CHAT_MSG_GUILD") then
					CH:ChatFrame_SystemEventHandler(chat, "GUILD_MOTD", msg)
					chat:RegisterEvent("GUILD_MOTD")
				end
			end

			df:SetScript("OnUpdate", nil)
		else -- 5 seconds can be too fast for the API response. let's try once every 5 seconds (max 5 checks).
			delay, checks = 0, checks + 1
			if checks >= 5 then
				df:SetScript("OnUpdate", nil)
			end
		end
	end)
end

function CH:SaveChatHistory(event, ...)
	local historyType = historyTypes[event]
	if historyType then -- let others go by..
		if not CH.db.showHistory[historyType] then return end -- but kill ignored ones
	end

	if CH.db.throttleInterval ~= 0 and (event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" or event == "CHAT_MSG_CHANNEL") then
		local message, author = ...
		local when = time()

		CH:ChatThrottleHandler(author, message, when)

		if CH:ChatThrottleBlockFlag(author, message, when) then
			return
		end
	end

	if not CH.db.chatHistory then return end
	local data = ElvCharacterDB.ChatHistoryLog
	if not data then return end

	local tempHistory = {}
	for i = 1, select("#", ...) do
		tempHistory[i] = select(i, ...) or false
	end

	if #tempHistory > 0 then
		tempHistory[50] = event
		tempHistory[51] = time()
		tempHistory[52] = CH:GetColoredName(event, ...)

		tinsert(data, tempHistory)
		while #data >= CH.db.historySize do
			tremove(data, 1)
		end
	end
end

function CH:FCF_SetWindowAlpha(frame, alpha)
	frame.oldAlpha = alpha or 1
end

function CH:CheckLFGRoles()
	local isInGroup, isInRaid = IsInGroup(), IsInRaid()

	if not isInGroup or not CH.db.lfgIcons then return end

	wipe(lfgRoles)

	local playerRole = UnitGroupRolesAssigned("player")
	if playerRole then
		for _, myName in pairs({E.myname, PLAYER_NAME}) do
			lfgRoles[myName] = rolePaths[playerRole]
		end

		-- Support private servers with custom realm names in character 'name-realm'
		for _, customRealm in pairs(E.privateServerRealms) do
			local myCustomNameRealm = format("%s-%s", E.myname, customRealm)
			lfgRoles[myCustomNameRealm] = rolePaths[playerRole]
		end
	end

	local unit = (isInRaid and "raid" or "party")
	for i = 1, GetNumGroupMembers() do
		if UnitExists(unit..i) and not UnitIsUnit(unit..i, "player") then
			local role = UnitGroupRolesAssigned(unit..i)
			local name, realm = UnitName(unit..i)

			if role and name then
				local name1 = name.."-"..PLAYER_REALM
				local name2 = (realm and realm ~= "" and name.."-"..realm)

				for _, otherName in pairs({name, name1, name2}) do
					lfgRoles[otherName] = rolePaths[role]
				end

				-- Support private servers with custom realm names in character 'name-realm'
				for _, customRealm in pairs(E.privateServerRealms) do
					local customNameRealm = format("%s-%s", name, customRealm)
					lfgRoles[customNameRealm] = rolePaths[role]
				end
			end
		end
	end
end

function CH:ON_FCF_SavePositionAndDimensions(_, noLoop)
	if not noLoop then
		CH:PositionChat()
	end

	if not CH.db.lockPositions then
		CH:UpdateChatTabs() --It was not done in PositionChat, so do it now
	end
end

local FindURL_Events = {
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_BN_INLINE_TOAST_BROADCAST",
	"CHAT_MSG_GUILD_ACHIEVEMENT",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_TEXT_EMOTE",
	"CHAT_MSG_AFK",
	"CHAT_MSG_DND"
}

function CH:DefaultSmileys()
	local x = ":16:16"
	if next(CH.Smileys) then
		wipe(CH.Smileys)
	end

	-- new keys
	CH:AddSmiley(":angry:", E:TextureString(E.Media.ChatEmojis.Angry, x))
	CH:AddSmiley(":blush:", E:TextureString(E.Media.ChatEmojis.Blush, x))
	CH:AddSmiley(":broken_heart:", E:TextureString(E.Media.ChatEmojis.BrokenHeart, x))
	CH:AddSmiley(":call_me:", E:TextureString(E.Media.ChatEmojis.CallMe, x))
	CH:AddSmiley(":cry:", E:TextureString(E.Media.ChatEmojis.Cry, x))
	CH:AddSmiley(":facepalm:", E:TextureString(E.Media.ChatEmojis.Facepalm, x))
	CH:AddSmiley(":grin:", E:TextureString(E.Media.ChatEmojis.Grin, x))
	CH:AddSmiley(":heart:", E:TextureString(E.Media.ChatEmojis.Heart, x))
	CH:AddSmiley(":heart_eyes:", E:TextureString(E.Media.ChatEmojis.HeartEyes, x))
	CH:AddSmiley(":joy:", E:TextureString(E.Media.ChatEmojis.Joy, x))
	CH:AddSmiley(":kappa:", E:TextureString(E.Media.ChatEmojis.Kappa, x))
	CH:AddSmiley(":middle_finger:", E:TextureString(E.Media.ChatEmojis.MiddleFinger, x))
	CH:AddSmiley(":murloc:", E:TextureString(E.Media.ChatEmojis.Murloc, x))
	CH:AddSmiley(":ok_hand:", E:TextureString(E.Media.ChatEmojis.OkHand, x))
	CH:AddSmiley(":open_mouth:", E:TextureString(E.Media.ChatEmojis.OpenMouth, x))
	CH:AddSmiley(":poop:", E:TextureString(E.Media.ChatEmojis.Poop, x))
	CH:AddSmiley(":rage:", E:TextureString(E.Media.ChatEmojis.Rage, x))
	CH:AddSmiley(":sadkitty:", E:TextureString(E.Media.ChatEmojis.SadKitty, x))
	CH:AddSmiley(":scream:", E:TextureString(E.Media.ChatEmojis.Scream, x))
	CH:AddSmiley(":scream_cat:", E:TextureString(E.Media.ChatEmojis.ScreamCat, x))
	CH:AddSmiley(":slight_frown:", E:TextureString(E.Media.ChatEmojis.SlightFrown, x))
	CH:AddSmiley(":smile:", E:TextureString(E.Media.ChatEmojis.Smile, x))
	CH:AddSmiley(":smirk:", E:TextureString(E.Media.ChatEmojis.Smirk, x))
	CH:AddSmiley(":sob:", E:TextureString(E.Media.ChatEmojis.Sob, x))
	CH:AddSmiley(":sunglasses:", E:TextureString(E.Media.ChatEmojis.Sunglasses, x))
	CH:AddSmiley(":thinking:", E:TextureString(E.Media.ChatEmojis.Thinking, x))
	CH:AddSmiley(":thumbs_up:", E:TextureString(E.Media.ChatEmojis.ThumbsUp, x))
	CH:AddSmiley(":semi_colon:", E:TextureString(E.Media.ChatEmojis.SemiColon, x))
	CH:AddSmiley(":wink:", E:TextureString(E.Media.ChatEmojis.Wink, x))
	CH:AddSmiley(":zzz:", E:TextureString(E.Media.ChatEmojis.ZZZ, x))
	CH:AddSmiley(":stuck_out_tongue:", E:TextureString(E.Media.ChatEmojis.StuckOutTongue, x))
	CH:AddSmiley(":stuck_out_tongue_closed_eyes:", E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes, x))

	-- Darth's keys
	CH:AddSmiley(":meaw:", E:TextureString(E.Media.ChatEmojis.Meaw, x))

	-- Simpy's keys
	CH:AddSmiley(">:%(", E:TextureString(E.Media.ChatEmojis.Rage, x))
	CH:AddSmiley(":%$", E:TextureString(E.Media.ChatEmojis.Blush, x))
	CH:AddSmiley("<\\3", E:TextureString(E.Media.ChatEmojis.BrokenHeart, x))
	CH:AddSmiley(":\'%)", E:TextureString(E.Media.ChatEmojis.Joy, x))
	CH:AddSmiley(";\'%)", E:TextureString(E.Media.ChatEmojis.Joy, x))
	CH:AddSmiley(",,!,,", E:TextureString(E.Media.ChatEmojis.MiddleFinger, x))
	CH:AddSmiley("D:<", E:TextureString(E.Media.ChatEmojis.Rage, x))
	CH:AddSmiley(":o3", E:TextureString(E.Media.ChatEmojis.ScreamCat, x))
	CH:AddSmiley("XP", E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes, x))
	CH:AddSmiley("8%-%)", E:TextureString(E.Media.ChatEmojis.Sunglasses, x))
	CH:AddSmiley("8%)", E:TextureString(E.Media.ChatEmojis.Sunglasses, x))
	CH:AddSmiley(":%+1:", E:TextureString(E.Media.ChatEmojis.ThumbsUp, x))
	CH:AddSmiley(":;:", E:TextureString(E.Media.ChatEmojis.SemiColon, x))
	CH:AddSmiley(";o;", E:TextureString(E.Media.ChatEmojis.Sob, x))

	-- old keys
	CH:AddSmiley(":%-@", E:TextureString(E.Media.ChatEmojis.Angry, x))
	CH:AddSmiley(":@", E:TextureString(E.Media.ChatEmojis.Angry, x))
	CH:AddSmiley(":%-%)", E:TextureString(E.Media.ChatEmojis.Smile, x))
	CH:AddSmiley(":%)", E:TextureString(E.Media.ChatEmojis.Smile, x))
	CH:AddSmiley(":D", E:TextureString(E.Media.ChatEmojis.Grin, x))
	CH:AddSmiley(":%-D", E:TextureString(E.Media.ChatEmojis.Grin, x))
	CH:AddSmiley(";%-D", E:TextureString(E.Media.ChatEmojis.Grin, x))
	CH:AddSmiley(";D", E:TextureString(E.Media.ChatEmojis.Grin, x))
	CH:AddSmiley("=D", E:TextureString(E.Media.ChatEmojis.Grin, x))
	CH:AddSmiley("xD", E:TextureString(E.Media.ChatEmojis.Grin, x))
	CH:AddSmiley("XD", E:TextureString(E.Media.ChatEmojis.Grin, x))
	CH:AddSmiley(":%-%(", E:TextureString(E.Media.ChatEmojis.SlightFrown, x))
	CH:AddSmiley(":%(", E:TextureString(E.Media.ChatEmojis.SlightFrown, x))
	CH:AddSmiley(":o", E:TextureString(E.Media.ChatEmojis.OpenMouth, x))
	CH:AddSmiley(":%-o", E:TextureString(E.Media.ChatEmojis.OpenMouth, x))
	CH:AddSmiley(":%-O", E:TextureString(E.Media.ChatEmojis.OpenMouth, x))
	CH:AddSmiley(":O", E:TextureString(E.Media.ChatEmojis.OpenMouth, x))
	CH:AddSmiley(":%-0", E:TextureString(E.Media.ChatEmojis.OpenMouth, x))
	CH:AddSmiley(":P", E:TextureString(E.Media.ChatEmojis.StuckOutTongue, x))
	CH:AddSmiley(":%-P", E:TextureString(E.Media.ChatEmojis.StuckOutTongue, x))
	CH:AddSmiley(":p", E:TextureString(E.Media.ChatEmojis.StuckOutTongue, x))
	CH:AddSmiley(":%-p", E:TextureString(E.Media.ChatEmojis.StuckOutTongue, x))
	CH:AddSmiley("=P", E:TextureString(E.Media.ChatEmojis.StuckOutTongue, x))
	CH:AddSmiley("=p", E:TextureString(E.Media.ChatEmojis.StuckOutTongue, x))
	CH:AddSmiley(";%-p", E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes, x))
	CH:AddSmiley(";p", E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes, x))
	CH:AddSmiley(";P", E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes, x))
	CH:AddSmiley(";%-P", E:TextureString(E.Media.ChatEmojis.StuckOutTongueClosedEyes, x))
	CH:AddSmiley(";%-%)", E:TextureString(E.Media.ChatEmojis.Wink, x))
	CH:AddSmiley(";%)", E:TextureString(E.Media.ChatEmojis.Wink, x))
	CH:AddSmiley(":S", E:TextureString(E.Media.ChatEmojis.Smirk, x))
	CH:AddSmiley(":%-S", E:TextureString(E.Media.ChatEmojis.Smirk, x))
	CH:AddSmiley(":,%(", E:TextureString(E.Media.ChatEmojis.Cry, x))
	CH:AddSmiley(":,%-%(", E:TextureString(E.Media.ChatEmojis.Cry, x))
	CH:AddSmiley(":\'%(", E:TextureString(E.Media.ChatEmojis.Cry, x))
	CH:AddSmiley(":\'%-%(", E:TextureString(E.Media.ChatEmojis.Cry, x))
	CH:AddSmiley(":F", E:TextureString(E.Media.ChatEmojis.MiddleFinger, x))
	CH:AddSmiley("<3", E:TextureString(E.Media.ChatEmojis.Heart, x))
	CH:AddSmiley("</3", E:TextureString(E.Media.ChatEmojis.BrokenHeart, x))
end

function CH:BuildCopyChatFrame()
	local frame = CreateFrame("Frame", "CopyChatFrame", E.UIParent)
	tinsert(UISpecialFrames, "CopyChatFrame")
	frame:SetTemplate("Transparent")
	frame:Size(700, 200)
	frame:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 3)
	frame:Hide()
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetResizable(true)
	frame:SetMinResize(350, 100)
	frame:SetScript("OnMouseDown", function(copyChat, button)
		if button == "LeftButton" and not copyChat.isMoving then
			copyChat:StartMoving()
			copyChat.isMoving = true
		elseif button == "RightButton" and not copyChat.isSizing then
			copyChat:StartSizing()
			copyChat.isSizing = true
		end
	end)
	frame:SetScript("OnMouseUp", function(copyChat, button)
		if button == "LeftButton" and copyChat.isMoving then
			copyChat:StopMovingOrSizing()
			copyChat.isMoving = false
		elseif button == "RightButton" and copyChat.isSizing then
			copyChat:StopMovingOrSizing()
			copyChat.isSizing = false
		end
	end)
	frame:SetScript("OnHide", function(copyChat)
		if copyChat.isMoving or copyChat.isSizing then
			copyChat:StopMovingOrSizing()
			copyChat.isMoving = false
			copyChat.isSizing = false
		end
	end)
	frame:SetFrameStrata("DIALOG")

	local scrollArea = CreateFrame("ScrollFrame", "CopyChatScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scrollArea:Point("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollArea:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)
	Skins:HandleScrollBar(CopyChatScrollFrameScrollBar)
	scrollArea:SetScript("OnSizeChanged", function(scroll)
		CopyChatFrameEditBox:Width(scroll:GetWidth())
		CopyChatFrameEditBox:Height(scroll:GetHeight())
	end)
	scrollArea:HookScript("OnVerticalScroll", function(scroll, offset)
		CopyChatFrameEditBox:SetHitRectInsets(0, 0, offset, (CopyChatFrameEditBox:GetHeight() - offset - scroll:GetHeight()))
	end)

	local editBox = CreateFrame("EditBox", "CopyChatFrameEditBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:Width(scrollArea:GetWidth())
	editBox:Height(200)
	editBox:SetScript("OnEscapePressed", function() CopyChatFrame:Hide() end)
	scrollArea:SetScrollChild(editBox)
	editBox:SetScript("OnTextChanged", function(_, userInput)
		if userInput then return end
		local _, Max = CopyChatScrollFrameScrollBar:GetMinMaxValues()
		for _ = 1, Max do
			ScrollFrameTemplate_OnMouseWheel(CopyChatScrollFrame, -1)
		end
	end)

	local close = CreateFrame("Button", "CopyChatFrameCloseButton", frame, "UIPanelCloseButton")
	close:Point("TOPRIGHT")
	close:SetFrameLevel(close:GetFrameLevel() + 1)
	close:EnableMouse(true)
	Skins:HandleCloseButton(close)
end

CH.TabStyles = {
	NONE	= "%s",
	ARROW	= "%s>|r%s%s<|r",
	ARROW1	= "%s>|r %s %s<|r",
	ARROW2	= "%s<|r%s%s>|r",
	ARROW3	= "%s<|r %s %s>|r",
	BOX		= "%s[|r%s%s]|r",
	BOX1	= "%s[|r %s %s]|r",
	CURLY	= "%s{|r%s%s}|r",
	CURLY1	= "%s{|r %s %s}|r",
	CURVE	= "%s(|r%s%s)|r",
	CURVE1	= "%s(|r %s %s)|r"
}

function CH:FCFTab_UpdateColors(tab, selected)
	local chat = _G[format("ChatFrame%s", tab:GetID())]

	tab.selected = selected

	local whisper = tab.conversationIcon and chat.chatTarget

	if whisper and not tab.whisperName then
		tab.whisperName = gsub(E:StripMyRealm(chat.name), "([%S]-)%-[%S]+", "%1|cFF999999*|r")
	end

	if selected and chat.isDocked then
		if CH.db.tabSelector ~= "NONE" then
			local color = CH.db.tabSelectorColor
			local hexColor = E:RGBToHex(color.r, color.g, color.b)
			tab:SetFormattedText(CH.TabStyles[CH.db.tabSelector] or CH.TabStyles.ARROW1, hexColor, tab.whisperName or chat.name, hexColor)
		else
			tab:SetText(tab.whisperName or chat.name)
		end

		if CH.db.tabSelectedTextEnabled and not whisper then
			local color = CH.db.tabSelectedTextColor
			tab:GetFontString():SetTextColor(color.r, color.g, color.b)
			return
		end
	else
		tab:SetText(tab.whisperName or chat.name)
	end

	if whisper then
		local classMatch = CH.ClassNames[strlower(chat.name)]
		if classMatch then tab.classColor = E:ClassColor(classMatch) end

		if tab.classColor then
			tab:GetFontString():SetTextColor(tab.classColor.r, tab.classColor.g, tab.classColor.b)
		end
	else
		tab:GetFontString():SetTextColor(unpack(E.media.rgbvaluecolor))
	end
end

function CH:ResetEditboxHistory()
	wipe(ElvCharacterDB.ChatEditHistory)
end

function CH:ResetHistory()
	wipe(ElvCharacterDB.ChatHistoryLog)
end

function CH:Initialize()
	if ElvCharacterDB.ChatHistory then ElvCharacterDB.ChatHistory = nil end --Depreciated
	if ElvCharacterDB.ChatLog then ElvCharacterDB.ChatLog = nil end --Depreciated

	CH:DelayGuildMOTD() -- Keep this before `is Chat Enabled` check

	if not E.private.chat.enable then return end

	CH.Initialized = true
	CH.db = E.db.chat

	if not ElvCharacterDB.ChatEditHistory then ElvCharacterDB.ChatEditHistory = {} end
	if not ElvCharacterDB.ChatHistoryLog or not CH.db.chatHistory then ElvCharacterDB.ChatHistoryLog = {} end

	FriendsMicroButton:Kill()
	ChatFrameMenuButton:Kill()

	CH:SetupChat()
	CH:DefaultSmileys()
	CH:UpdateChatKeywords()
	CH:UpdateFading()
	CH:CheckLFGRoles()
	CH:UpdateAnchors()
	CH:Panels_ColorUpdate()

	CH:SecureHook("ChatEdit_OnEnterPressed")
	CH:SecureHook("FCF_Close")
	CH:SecureHook("FCF_SetWindowAlpha")
	CH:SecureHook("FCFTab_UpdateColors")
	CH:SecureHook("FCF_SetChatWindowFontSize", "SetChatFont")
	CH:SecureHook("FCF_SavePositionAndDimensions", "ON_FCF_SavePositionAndDimensions")
	CH:RegisterEvent("UPDATE_CHAT_WINDOWS", "SetupChat")
	CH:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS", "SetupChat")
	CH:RegisterEvent("GROUP_ROSTER_UPDATE", "CheckLFGRoles")
	CH:RegisterEvent("PET_BATTLE_CLOSE")

	if WIM then
		WIM.RegisterWidgetTrigger("chat_display", "whisper,chat,w2w,demo", "OnHyperlinkClick", function(self) CH.clickedframe = self end)
		WIM.RegisterItemRefHandler("url", HyperLinkedURL)
	end
	if not CH.db.lockPositions then CH:UpdateChatTabs() end --It was not done in PositionChat, so do it now

	for _, event in ipairs(FindURL_Events) do
		ChatFrame_AddMessageEventFilter(event, CH[event] or CH.FindURL)
		local nType = strsub(event, 10)
		if nType ~= "AFK" and nType ~= "DND" then
			CH:RegisterEvent(event, "SaveChatHistory")
		end
	end

	if CH.db.chatHistory then CH:DisplayChatHistory() end
	CH:BuildCopyChatFrame()

	-- Editbox Backdrop Color
	hooksecurefunc("ChatEdit_UpdateHeader", function(editbox)
		local chatType = editbox:GetAttribute("chatType")
		if not chatType then return end

		local chanTarget = editbox:GetAttribute("channelTarget")
		local chanName = chanTarget and GetChannelName(chanTarget)

		--Increase inset on right side to make room for character count text
		local insetLeft, insetRight, insetTop, insetBottom = editbox:GetTextInsets()
		editbox:SetTextInsets(insetLeft, insetRight + 30, insetTop, insetBottom)

		if chanName and (chatType == "CHANNEL") then
			if chanName == 0 then
				editbox:SetBackdropBorderColor(unpack(E.media.bordercolor))
			else
				local info = ChatTypeInfo[chatType..chanName]
				editbox:SetBackdropBorderColor(info.r, info.g, info.b)
			end
		else
			local info = ChatTypeInfo[chatType]
			editbox:SetBackdropBorderColor(info.r, info.g, info.b)
		end
	end)

	GeneralDockManagerOverflowButton:Size(17)
	GeneralDockManagerOverflowButtonList:SetTemplate("Transparent")
	hooksecurefunc(GeneralDockManagerScrollFrame, "SetPoint", function(self, point, anchor, attachTo, x, y)
		if anchor == GeneralDockManagerOverflowButton and x == 0 and y == 0 then
			self:Point(point, anchor, attachTo, -2, -4)
		end
	end)

	CombatLogQuickButtonFrame_Custom:StripTextures()
	CombatLogQuickButtonFrame_Custom:CreateBackdrop("Default", true)
	CombatLogQuickButtonFrame_Custom.backdrop:Point("TOPLEFT", 0, -1)
	CombatLogQuickButtonFrame_Custom.backdrop:Point("BOTTOMRIGHT", -22, 1)

	CombatLogQuickButtonFrame_CustomProgressBar:StripTextures()
	CombatLogQuickButtonFrame_CustomProgressBar:SetStatusBarTexture(E.media.normTex)
	CombatLogQuickButtonFrame_CustomProgressBar:SetStatusBarColor(0.31, 0.31, 0.31)
	CombatLogQuickButtonFrame_CustomProgressBar:ClearAllPoints()
	CombatLogQuickButtonFrame_CustomProgressBar:SetInside(CombatLogQuickButtonFrame_Custom.backdrop)

	Skins:HandleNextPrevButton(CombatLogQuickButtonFrame_CustomAdditionalFilterButton)
	CombatLogQuickButtonFrame_CustomAdditionalFilterButton:Size(22)
	CombatLogQuickButtonFrame_CustomAdditionalFilterButton:Point("TOPRIGHT", CombatLogQuickButtonFrame_Custom, "TOPRIGHT", 2, -1)
	CombatLogQuickButtonFrame_CustomAdditionalFilterButton:SetHitRectInsets(0, 0, 0, 0)
	CombatLogQuickButtonFrame_CustomAdditionalFilterButton:RegisterForClicks("AnyUp")
end

local function InitializeCallback()
	CH:Initialize()
end

E:RegisterModule(CH:GetName(), InitializeCallback)