local E, L, V, P, G = unpack(select(2, ...))
local UF = E:GetModule("UnitFrames")
local LSM = E.Libs.LSM

local assert, select, pairs, unpack = assert, select, pairs, unpack
local tinsert = tinsert

local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo

function UF:Construct_AuraWatch(frame)
	local auras = CreateFrame("Frame", nil, frame)
	auras:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 10)
	auras:SetInside(frame.Health)
	auras.presentAlpha = 1
	auras.missingAlpha = 0
	auras.strictMatching = true
	auras.icons = {}

	return auras
end

function UF:UpdateAuraWatchFromHeader(group, petOverride)
	assert(self[group], "Invalid group specified.")
	group = self[group]
	for i = 1, group:GetNumChildren() do
		local frame = select(i, group:GetChildren())
		if frame and frame.Health then
			UF:UpdateAuraWatch(frame, petOverride, group.db)
		elseif frame then
			for n = 1, frame:GetNumChildren() do
				local child = select(n, frame:GetChildren())
				if child and child.Health then
					UF:UpdateAuraWatch(child, petOverride, group.db)
				end
			end
		end
	end
end

local buffs = {}

function UF:UpdateAuraWatch(frame, petOverride, db)
	wipe(buffs)
	local auras = frame.AuraWatch
	db = db and db.buffIndicator or frame.db.buffIndicator

	if not db.enable then
		auras:Hide()
		return
	else
		auras:Show()
	end

	if frame.unit == "pet" and not petOverride then
		local petWatch = E.global.unitframe.buffwatch.PET or {}
		for _, value in pairs(petWatch) do
			tinsert(buffs, value)
		end
	else
		local buffWatch = not db.profileSpecific and (E.global.unitframe.buffwatch[E.myclass] or {}) or (E.db.unitframe.filters.buffwatch or {})
		for _, value in pairs(buffWatch) do
			tinsert(buffs, value)
		end
	end

	-- Clear Cache
	if auras.icons then
		for i = 1, #auras.icons do
			local matchFound = false
			for j = 1, #buffs do
				if buffs[j].id and buffs[j].id == auras.icons[i] then
					matchFound = true
					break
				end
			end

			if not matchFound then
				auras.icons[i]:Hide()
				auras.icons[i] = nil
			end
		end
	end

	local unitframeFont = LSM:Fetch("font", E.db.unitframe.font)

	for i = 1, #buffs do
		if buffs[i].id then
			local name, _, image = GetSpellInfo(buffs[i].id)

			if name then
				local button

				if not auras.icons[buffs[i].id] then
					button = CreateFrame("Frame", nil, auras)
				else
					button = auras.icons[buffs[i].id]
				end

				button.name = name
				button.image = image
				button.spellID = buffs[i].id
				button.anyUnit = buffs[i].anyUnit
				button.style = buffs[i].style
				button.onlyShowMissing = buffs[i].onlyShowMissing
				button.presentAlpha = button.onlyShowMissing and 0 or 1
				button.missingAlpha = button.onlyShowMissing and 1 or 0
				button.textThreshold = buffs[i].textThreshold or -1
				button.displayText = (not buffs[i].displayText and button.style == "timerOnly") or buffs[i].displayText
				button.size = (buffs[i].sizeOverride ~= nil and buffs[i].sizeOverride > 0 and buffs[i].sizeOverride or db.size)
				button.countFontSize = buffs[i].countFontSize

				button:Size(button.size)

				--Protect against missing .point value
				if not buffs[i].point then buffs[i].point = "TOPLEFT" end

				button:ClearAllPoints()
				button:Point(buffs[i].point or "TOPLEFT", frame.Health, buffs[i].point or "TOPLEFT", buffs[i].xOffset, buffs[i].yOffset)

				if not button.icon then
					button.icon = button:CreateTexture(nil, "BORDER")
					button.icon:SetAllPoints(button)
				end

				if not button.icon.border then
					button.icon.border = button:CreateTexture(nil, "BACKGROUND")
					button.icon.border:SetOutside(button.icon, 1, 1)
					button.icon.border:SetTexture(E.media.blankTex)
					button.icon.border:SetVertexColor(0, 0, 0)
				end

				if not button.cd then
					button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
					button.cd:SetAllPoints(button)
					button.cd:SetReverse(true)
					button.cd:SetFrameLevel(button:GetFrameLevel())
				end

				if not button.count then
					button.count = button:CreateFontString(nil, "OVERLAY")
				end

				local timer = button.cd.timer
				if (button.style == "coloredIcon" or button.style == "texturedIcon") and not button.icon:IsShown() then
					button.icon:Show()
					button.icon.border:Show()
				elseif button.style == "timerOnly" and button.icon:IsShown() then
					button.icon:Hide()
					button.icon.border:Hide()
				end

				if button.style == "timerOnly" then
					button.cd.hideText = nil
					if timer then
						timer.skipTextColor = true

						if timer.text then
							timer.text:SetTextColor(buffs[i].color.r, buffs[i].color.g, buffs[i].color.b)
						end
					end
				else
					button.cd.hideText = not buffs[i].displayText
					if timer then timer.skipTextColor = nil end

					if button.style == "coloredIcon" then
						button.icon:SetTexture(E.media.blankTex)
						if buffs[i].color then
							button.icon:SetVertexColor(buffs[i].color.r, buffs[i].color.g, buffs[i].color.b)
						else
							button.icon:SetVertexColor(0.8, 0.8, 0.8)
						end
					elseif button.style == "texturedIcon" then
						button.icon:SetTexture(button.image)
						button.icon:SetVertexColor(1, 1, 1)
						button.icon:SetTexCoord(unpack(E.TexCoords))
					end
				end

				button.cd.CooldownOverride = "unitframe"
				button.cd.skipScale = true
				E:RegisterCooldown(button.cd)
				button.cd.hideText = not button.displayText
				button.cd.textThreshold = buffs[i].textThreshold ~= -1 and buffs[i].textThreshold

				button.count:ClearAllPoints()
				button.count:Point("BOTTOMRIGHT", 1, 1)
				button.count:SetJustifyH("RIGHT")
				button.count:FontTemplate(unitframeFont, button.countFontSize, E.db.unitframe.fontOutline)

				if buffs[i].enabled then
					auras.icons[buffs[i].id] = button
					if auras.watched then
						auras.watched[buffs[i].id] = button
					end
				else
					auras.icons[buffs[i].id] = nil
					if auras.watched then
						auras.watched[buffs[i].id] = nil
					end

					button:Hide()
				end
			end
		end
	end

	if frame.AuraWatch.Update then
		frame.AuraWatch.Update(frame)
	end

	frame:UpdateElement("AuraWatch")
end