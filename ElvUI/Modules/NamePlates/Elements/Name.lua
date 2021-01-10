local E, L, V, P, G = unpack(select(2, ...))
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

local format, gmatch, gsub, match = string.format, gmatch, gsub, string.match
local utf8lower, utf8sub = string.utf8lower, string.utf8sub

local UNKNOWN = UNKNOWN
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST

local function abbrev(name)
	local letters, lastWord = "", match(name, ".+%s(.+)$")
	if lastWord then
		for word in gmatch(name, ".-%s") do
			local firstLetter = utf8sub(gsub(word, "^[%s%p]*", ""), 1, 1)
			if firstLetter ~= utf8lower(firstLetter) then
				letters = format("%s%s. ", letters, firstLetter)
			end
		end
		name = format("%s%s", letters, lastWord)
	end
	return name
end

function NP:Update_Name(frame, triggered)
	if not triggered then
		if not self.db.units[frame.UnitType].name.enable then return end
	end

	local name = frame.Name
	local nameText = frame.UnitName or UNKNOWN
	name:SetText(self.db.units[frame.UnitType].name.abbrev and abbrev(nameText) or nameText)

	if not triggered then
		name:ClearAllPoints()
		if self.db.units[frame.UnitType].health.enable or (self.db.alwaysShowTargetHealth and frame.isTarget) then
			if frame.UnitTrivial and NP.db.trivial then
				name:SetJustifyH("CENTER")
				name:SetPoint("BOTTOM", frame.Health, "TOP", 0, E.Border*2)
			else
				name:SetJustifyH("LEFT")
				name:SetPoint("BOTTOMLEFT", frame.Health, "TOPLEFT", 0, E.Border*2)
				name:SetPoint("BOTTOMRIGHT", frame.Level, "BOTTOMLEFT")
			end
		else
			name:SetJustifyH("CENTER")
			name:SetPoint("TOP", frame)
		end
	end

	local class = frame.UnitClass
	local reactionType = frame.UnitReaction

	local r, g, b = 1, 1, 1
	local classColor, useClassColor, useReactionColor

	if class then
		classColor = E:ClassColor(class) or PRIEST_COLOR
		useClassColor = self.db.units[frame.UnitType].name and self.db.units[frame.UnitType].name.useClassColor
	end
	if reactionType then
		useReactionColor = self.db.units[frame.UnitType].name and self.db.units[frame.UnitType].name.useReactionColor
	end

	local db = self.db.colors

	if useClassColor and (frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "ENEMY_PLAYER") then
		if class and classColor then
			r, g, b = classColor.r, classColor.g, classColor.b
		end
	elseif triggered or (not self.db.units[frame.UnitType].health.enable and not frame.isTarget) or (useReactionColor and (frame.UnitType == "FRIENDLY_NPC" or frame.UnitType == "ENEMY_NPC")) then
		if reactionType and reactionType == 1 then
			r, g, b = db.reactions.tapped.r, db.reactions.tapped.g, db.reactions.tapped.b
		elseif reactionType and reactionType == 4 then
			r, g, b = db.reactions.neutral.r, db.reactions.neutral.g, db.reactions.neutral.b
		elseif reactionType and reactionType > 4 then
			if frame.UnitType == "FRIENDLY_PLAYER" then
				r, g, b = db.reactions.friendlyPlayer.r, db.reactions.friendlyPlayer.g, db.reactions.friendlyPlayer.b
			else
				r, g, b = db.reactions.good.r, db.reactions.good.g, db.reactions.good.b
			end
		else
			r, g, b = db.reactions.bad.r, db.reactions.bad.g, db.reactions.bad.b
		end
	end

	-- if for some reason the values failed just default to white
	if not (r and g and b) then
		r, g, b = 1, 1, 1
	end

	if triggered or (r ~= frame.Name.r or g ~= frame.Name.g or b ~= frame.Name.b) then
		name:SetTextColor(r, g, b)

		if not triggered then
			frame.Name.r, frame.Name.g, frame.Name.b = r, g, b
		end
	end

	if self.db.nameColoredGlow then
		name.NameOnlyGlow:SetVertexColor(r - 0.1, g - 0.1, b - 0.1, 1)
	else
		name.NameOnlyGlow:SetVertexColor(db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a)
	end
end

function NP:Configure_Name(frame)
	local db = self.db.units[frame.UnitType].name

	frame.Name:FontTemplate(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
end

function NP:Configure_NameOnlyGlow(frame)
	local name = frame.Name
	name.NameOnlyGlow:ClearAllPoints()
	name.NameOnlyGlow:SetPoint("TOPLEFT", frame.IconOnlyChanged and frame.IconFrame or name, -20, 8)
	name.NameOnlyGlow:SetPoint("BOTTOMRIGHT", frame.IconOnlyChanged and frame.IconFrame or name, 20, -8)
end

function NP:Construct_Name(frame)
	local name = frame:CreateFontString(nil, "OVERLAY")
	name:SetJustifyV("BOTTOM")
	name:SetWordWrap(false)

	local g = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	g:SetTexture(E.Media.Textures.Spark)
	g:Hide()
	g:SetPoint("TOPLEFT", name, -20, 8)
	g:SetPoint("BOTTOMRIGHT", name, 20, -8)

	name.NameOnlyGlow = g

	return name
end