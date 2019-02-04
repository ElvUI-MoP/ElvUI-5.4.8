local E, L, V, P, G = unpack(select(2, ...))
local M = E:GetModule("Misc")
local CH = E:GetModule("Chat")

local select, unpack, type = select, unpack, type
local strlower, format = strlower, string.format

local Ambiguate = Ambiguate
local CreateFrame = CreateFrame
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

--Message caches
local messageToGUID = {}
local messageToSender = {}

function M:UpdateBubbleBorder()
	if not self.text then return end

	if E.private.general.chatBubbles == "backdrop" then
		if E.PixelMode then
			self:SetBackdropBorderColor(self.text:GetTextColor())
		else
			local r, g, b = self.text:GetTextColor()
			self.bordertop:SetTexture(r, g, b)
			self.borderbottom:SetTexture(r, g, b)
			self.borderleft:SetTexture(r, g, b)
			self.borderright:SetTexture(r, g, b)
		end
	end

	local text = self.text:GetText()
	if self.Name then
		self.Name:SetText("") --Always reset it
		if text and E.private.general.chatBubbleName then
			M:AddChatBubbleName(self, messageToGUID[text], messageToSender[text])
		end
	end

	if E.private.chat.enable and E.private.general.classColorMentionsSpeech then
		local classColorTable, lowerCaseWord, isFirstWord, rebuiltString, tempWord, wordMatch, classMatch
		if text and text:match("%s-%S+%s*") then
			for word in text:gmatch("%s-%S+%s*") do
				tempWord = word:gsub("^[%s%p]-([^%s%p]+)([%-]?[^%s%p]-)[%s%p]*$","%1%2")
				lowerCaseWord = tempWord:lower()

				classMatch = CH.ClassNames[lowerCaseWord]
				wordMatch = classMatch and lowerCaseWord

				if(wordMatch and not E.global.chat.classColorMentionExcludedNames[wordMatch]) then
					classColorTable = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classMatch] or RAID_CLASS_COLORS[classMatch]
					word = word:gsub(tempWord:gsub("%-","%%-"), format("\124cff%.2x%.2x%.2x%s\124r", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255, tempWord))
				end

				if not isFirstWord then
					rebuiltString = word
					isFirstWord = true
				else
					rebuiltString = format("%s%s", rebuiltString, word)
				end
			end

			if rebuiltString ~= nil then
				self.text:SetText(rebuiltString)
			end
		end
	end
end

function M:AddChatBubbleName(chatBubble, guid, name)
	if not name then return end

	local defaultColor, color = "ffffffff"
	if guid ~= nil and guid ~= "" then
		local _, class = GetPlayerInfoByGUID(guid)
		if class then
			color = (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] and CUSTOM_CLASS_COLORS[class].colorStr) or (RAID_CLASS_COLORS[class] and RAID_CLASS_COLORS[class].colorStr)
		end
	else
		color = defaultColor
	end

	chatBubble.Name:SetFormattedText("|c%s%s|r", color, name)
end

function M:SkinBubble(frame)
	local mult = E.mult * UIParent:GetScale()
	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:IsObjectType("Texture") then
			region:SetTexture(nil)
		elseif region:IsObjectType("FontString") then
			frame.text = region
		end
	end

	local name = frame:CreateFontString(nil, "BORDER")
	if E.private.general.chatBubbles == "backdrop" then
		name:SetPoint("TOPLEFT", 5, E.PixelMode and 15 or 18)
	else
		name:SetPoint("TOPLEFT", 5, 6)
	end
	--name:SetPoint("TOPLEFT", 5, 5)
	name:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -5, -5)
	name:SetJustifyH("LEFT")
	name:FontTemplate(E.Libs.LSM:Fetch("font", E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize * 0.85, E.private.general.chatBubbleFontOutline)
	frame.Name = name

	if E.private.general.chatBubbles == "backdrop" then
		if E.PixelMode then
			frame:SetBackdrop({
				bgFile = E.media.blankTex,
				edgeFile = E.media.blankTex,
				tile = false, tileSize = 0, edgeSize = mult,
				insets = {left = 0, right = 0, top = 0, bottom = 0}
			})
			frame:SetBackdropColor(unpack(E.media.backdropfadecolor))
			frame:SetBackdropBorderColor(0, 0, 0)
		else
			frame:SetBackdrop(nil)
		end

		local r, g, b = frame.text:GetTextColor()
		if not E.PixelMode then
			frame.backdrop = frame:CreateTexture(nil, "ARTWORK")
			frame.backdrop:SetAllPoints(frame)
			frame.backdrop:SetTexture(unpack(E.media.backdropfadecolor))
			frame.backdrop:SetDrawLayer("ARTWORK", -8)

			frame.bordertop = frame:CreateTexture(nil, "ARTWORK")
			frame.bordertop:SetPoint("TOPLEFT", frame, "TOPLEFT", -mult*2, mult*2)
			frame.bordertop:SetPoint("TOPRIGHT", frame, "TOPRIGHT", mult*2, mult*2)
			frame.bordertop:SetHeight(mult)
			frame.bordertop:SetTexture(r, g, b)
			frame.bordertop:SetDrawLayer("ARTWORK", -6)

			frame.bordertop.backdrop = frame:CreateTexture(nil, "ARTWORK")
			frame.bordertop.backdrop:SetPoint("TOPLEFT", frame.bordertop, "TOPLEFT", -mult, mult)
			frame.bordertop.backdrop:SetPoint("TOPRIGHT", frame.bordertop, "TOPRIGHT", mult, mult)
			frame.bordertop.backdrop:SetHeight(mult * 3)
			frame.bordertop.backdrop:SetTexture(0, 0, 0)
			frame.bordertop.backdrop:SetDrawLayer("ARTWORK", -7)

			frame.borderbottom = frame:CreateTexture(nil, "ARTWORK")
			frame.borderbottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -mult*2, -mult*2)
			frame.borderbottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", mult*2, -mult*2)
			frame.borderbottom:SetHeight(mult)
			frame.borderbottom:SetTexture(r, g, b)
			frame.borderbottom:SetDrawLayer("ARTWORK", -6)

			frame.borderbottom.backdrop = frame:CreateTexture(nil, "ARTWORK")
			frame.borderbottom.backdrop:SetPoint("BOTTOMLEFT", frame.borderbottom, "BOTTOMLEFT", -mult, -mult)
			frame.borderbottom.backdrop:SetPoint("BOTTOMRIGHT", frame.borderbottom, "BOTTOMRIGHT", mult, -mult)
			frame.borderbottom.backdrop:SetHeight(mult * 3)
			frame.borderbottom.backdrop:SetTexture(0, 0, 0)
			frame.borderbottom.backdrop:SetDrawLayer("ARTWORK", -7)

			frame.borderleft = frame:CreateTexture(nil, "ARTWORK")
			frame.borderleft:SetPoint("TOPLEFT", frame, "TOPLEFT", -mult*2, mult*2)
			frame.borderleft:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", mult*2, -mult*2)
			frame.borderleft:SetWidth(mult)
			frame.borderleft:SetTexture(r, g, b)
			frame.borderleft:SetDrawLayer("ARTWORK", -6)

			frame.borderleft.backdrop = frame:CreateTexture(nil, "ARTWORK")
			frame.borderleft.backdrop:SetPoint("TOPLEFT", frame.borderleft, "TOPLEFT", -mult, mult)
			frame.borderleft.backdrop:SetPoint("BOTTOMLEFT", frame.borderleft, "BOTTOMLEFT", -mult, -mult)
			frame.borderleft.backdrop:SetWidth(mult * 3)
			frame.borderleft.backdrop:SetTexture(0, 0, 0)
			frame.borderleft.backdrop:SetDrawLayer("ARTWORK", -7)

			frame.borderright = frame:CreateTexture(nil, "ARTWORK")
			frame.borderright:SetPoint("TOPRIGHT", frame, "TOPRIGHT", mult*2, mult*2)
			frame.borderright:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -mult*2, -mult*2)
			frame.borderright:SetWidth(mult)
			frame.borderright:SetTexture(r, g, b)
			frame.borderright:SetDrawLayer("ARTWORK", -6)

			frame.borderright.backdrop = frame:CreateTexture(nil, "ARTWORK")
			frame.borderright.backdrop:SetPoint("TOPRIGHT", frame.borderright, "TOPRIGHT", mult, mult)
			frame.borderright.backdrop:SetPoint("BOTTOMRIGHT", frame.borderright, "BOTTOMRIGHT", mult, -mult)
			frame.borderright.backdrop:SetWidth(mult * 3)
			frame.borderright.backdrop:SetTexture(0, 0, 0)
			frame.borderright.backdrop:SetDrawLayer("ARTWORK", -7)
		end
		frame.text:FontTemplate(E.Libs.LSM:Fetch("font", E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize, E.private.general.chatBubbleFontOutline)
	elseif E.private.general.chatBubbles == "backdrop_noborder" then
		frame:SetBackdrop(nil)
		frame.backdrop = frame:CreateTexture(nil, "ARTWORK")
		frame.backdrop:SetInside(frame, 4, 4)
		frame.backdrop:SetTexture(unpack(E.media.backdropfadecolor))
		frame.backdrop:SetDrawLayer("ARTWORK", -8)
		frame.text:FontTemplate(E.Libs.LSM:Fetch("font", E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize, E.private.general.chatBubbleFontOutline)
		frame:SetClampedToScreen(false)
	elseif E.private.general.chatBubbles == "nobackdrop" then
		frame:SetBackdrop(nil)
		frame.text:FontTemplate(E.Libs.LSM:Fetch("font", E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize, E.private.general.chatBubbleFontOutline)
		frame:SetClampedToScreen(false)
		frame.Name:Hide()
	end

	frame:HookScript("OnShow", M.UpdateBubbleBorder)
	frame:SetFrameStrata("DIALOG")
	M.UpdateBubbleBorder(frame)

	frame.isSkinnedElvUI = true
end

local function ChatBubble_OnEvent(self, event, msg, sender, _, _, _, _, _, _, _, _, _, guid)
	if not E.private.general.chatBubbleName then return end

	messageToGUID[msg] = guid
	messageToSender[msg] = Ambiguate(sender, "none")
end

function M:IsChatBubble(frame)
	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if(region.GetTexture and region:GetTexture() and type(region:GetTexture() == "string") and strlower(region:GetTexture()) == [[interface\tooltips\chatbubble-background]]) then return true end
	end
	return false
end

local numChildren = 0
local function ChatBubble_OnUpdate(self, elapsed)
	if not M.BubbleFrame then return end
	if not M.BubbleFrame.lastupdate then
		M.BubbleFrame.lastupdate = -2 -- wait 2 seconds before hooking frames
	end

	M.BubbleFrame.lastupdate = M.BubbleFrame.lastupdate + elapsed
	if M.BubbleFrame.lastupdate < .1 then return end
	M.BubbleFrame.lastupdate = 0

	local count = WorldFrame:GetNumChildren()
	if count ~= numChildren then
		for i = numChildren + 1, count do
			local frame = select(i, WorldFrame:GetChildren())

			if M:IsChatBubble(frame) then
				if not frame.isSkinnedElvUI then
					M:SkinBubble(frame)
				end
			end
		end
		numChildren = count
	end
end

function M:ToggleChatBubbleScript()
	if E.private.general.chatBubbles ~= "disabled" then
		M.BubbleFrame:SetScript("OnEvent", ChatBubble_OnEvent)
		M.BubbleFrame:SetScript("OnUpdate", ChatBubble_OnUpdate)
	else
		M.BubbleFrame:SetScript("OnEvent", nil)
		M.BubbleFrame:SetScript("OnUpdate", nil)
		--Clear caches
		wipe(messageToGUID)
		wipe(messageToSender)
	end
end

function M:LoadChatBubbles()
	self.BubbleFrame = CreateFrame("Frame")

	self.BubbleFrame:RegisterEvent("CHAT_MSG_SAY")
	self.BubbleFrame:RegisterEvent("CHAT_MSG_YELL")
	self.BubbleFrame:RegisterEvent("CHAT_MSG_PARTY")
	self.BubbleFrame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
	self.BubbleFrame:RegisterEvent("CHAT_MSG_MONSTER_SAY")
	self.BubbleFrame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
end