local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(select(2, ...))
local UF = E:GetModule("UnitFrames")

local _G = _G
local select, pairs, ipairs = select, pairs, ipairs
local tremove, tinsert, tconcat, twipe = table.remove, table.insert, table.concat, table.wipe
local format, strmatch, gsub, strsplit = string.format, strmatch, string.gsub, strsplit

local GetScreenWidth = GetScreenWidth
local IsAddOnLoaded = IsAddOnLoaded

local ACD = E.Libs.AceConfigDialog

local positionValues = {
	TOP = L["Top"],
	LEFT = L["Left"],
	RIGHT = L["Right"],
	BOTTOM = L["Bottom"],
	CENTER = L["Center"],
	TOPLEFT = L["Top Left"],
	TOPRIGHT = L["Top Right"],
	BOTTOMLEFT = L["Bottom Left"],
	BOTTOMRIGHT = L["Bottom Right"]
}

local orientationValues = {
	--AUTOMATIC = L["Automatic"], not sure if i will use this yet
	LEFT = L["Left"],
	MIDDLE = L["Middle"],
	RIGHT = L["Right"]
}

local threatValues = {
	GLOW = L["Glow"],
	BORDERS = L["Borders"],
	HEALTHBORDER = L["Health Border"],
	INFOPANELBORDER = L["InfoPanel Border"],
	ICONTOPLEFT = L["Icon: TOPLEFT"],
	ICONTOPRIGHT = L["Icon: TOPRIGHT"],
	ICONBOTTOMLEFT = L["Icon: BOTTOMLEFT"],
	ICONBOTTOMRIGHT = L["Icon: BOTTOMRIGHT"],
	ICONLEFT = L["Icon: LEFT"],
	ICONRIGHT = L["Icon: RIGHT"],
	ICONTOP = L["Icon: TOP"],
	ICONBOTTOM = L["Icon: BOTTOM"],
	NONE = L["NONE"]
}

local petAnchors = {
	TOPLEFT = L["Top Left"],
	LEFT = L["Left"],
	BOTTOMLEFT = L["Bottom Left"],
	RIGHT = L["Right"],
	TOPRIGHT = L["Top Right"],
	BOTTOMRIGHT = L["Bottom Right"],
	TOP = L["Top"],
	BOTTOM = L["Bottom"]
}

local attachToValues = {
	Health = L["HEALTH"],
	Power = L["Power"],
	InfoPanel = L["Information Panel"],
	Frame = L["Frame"]
}

local smartAuraPositionValues = {
	DISABLED = L["DISABLE"],
	BUFFS_ON_DEBUFFS = L["Position Buffs on Debuffs"],
	DEBUFFS_ON_BUFFS = L["Position Debuffs on Buffs"],
	FLUID_BUFFS_ON_DEBUFFS = L["Fluid Position Buffs on Debuffs"],
	FLUID_DEBUFFS_ON_BUFFS = L["Fluid Position Debuffs on Buffs"]
}

local colorOverrideValues = {
	USE_DEFAULT = L["Use Default"],
	FORCE_ON = L["Force On"],
	FORCE_OFF = L["Force Off"]
}

local blendModeValues = {
	DISABLE = L["DISABLE"],
	BLEND = L["Blend"],
	ADD = L["Additive Blend"],
	ALPHAKEY = L["Alpha Key"]
}

local CUSTOMTEXT_CONFIGS = {}
local carryFilterFrom, carryFilterTo

local function filterMatch(s,v)
	local m1, m2, m3, m4 = "^"..v.."$", "^"..v..",", ","..v.."$", ","..v..","
	return (strmatch(s, m1) and m1) or (strmatch(s, m2) and m2) or (strmatch(s, m3) and m3) or (strmatch(s, m4) and v..",")
end

local function filterPriority(auraType, groupName, value, remove, movehere, friendState)
	if not auraType or not value then return end
	local filter = E.db.unitframe.units[groupName] and E.db.unitframe.units[groupName][auraType] and E.db.unitframe.units[groupName][auraType].priority
	if not filter then return end
	local found = filterMatch(filter, E:EscapeString(value))
	if found and movehere then
		local tbl, sv, sm = {strsplit(",", filter)}
		for i in ipairs(tbl) do
			if tbl[i] == value then sv = i elseif tbl[i] == movehere then sm = i end
			if sv and sm then break end
		end
		tremove(tbl, sm)
		tinsert(tbl, sv, movehere)
		E.db.unitframe.units[groupName][auraType].priority = tconcat(tbl,",")
	elseif found and friendState then
		local realValue = strmatch(value, "^Friendly:([^,]*)") or strmatch(value, "^Enemy:([^,]*)") or value
		local friend = filterMatch(filter, E:EscapeString("Friendly:"..realValue))
		local enemy = filterMatch(filter, E:EscapeString("Enemy:"..realValue))
		local default = filterMatch(filter, E:EscapeString(realValue))

		local state =
			(friend and (not enemy) and format("%s%s","Enemy:",realValue))					--[x] friend [ ] enemy: > enemy
		or	((not enemy and not friend) and format("%s%s","Friendly:",realValue))			--[ ] friend [ ] enemy: > friendly
		or	(enemy and (not friend) and default and format("%s%s","Friendly:",realValue))	--[ ] friend [x] enemy: (default exists) > friendly
		or	(enemy and (not friend) and strmatch(value, "^Enemy:") and realValue)			--[ ] friend [x] enemy: (no default) > realvalue
		or	(friend and enemy and realValue)												--[x] friend [x] enemy: > default

		if state then
			local stateFound = filterMatch(filter, E:EscapeString(state))
			if not stateFound then
				local tbl, sv = {strsplit(",", filter)}
				for i in ipairs(tbl) do
					if tbl[i] == value then sv = i break end
				end
				tinsert(tbl, sv, state)
				tremove(tbl, sv + 1)
				E.db.unitframe.units[groupName][auraType].priority = tconcat(tbl, ",")
			end
		end
	elseif found and remove then
		E.db.unitframe.units[groupName][auraType].priority = gsub(filter, found, "")
	elseif not found and not remove then
		E.db.unitframe.units[groupName][auraType].priority = (filter == "" and value) or (filter..","..value)
	end
end

-----------------------------------------------------------------------
-- OPTIONS TABLES
-----------------------------------------------------------------------
local function GetOptionsTable_AuraBars(updateFunc, groupName)
	local config = {
		type = "group",
		childGroups = "tab",
		name = L["Aura Bars"],
		get = function(info) return E.db.unitframe.units[groupName].aurabar[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].aurabar[info[#info]] = value updateFunc(UF, groupName) end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"]
			},
			configureButton1 = {
				order = 2,
				type = "execute",
				name = L["Coloring"],
				desc = L["This opens the UnitFrames Color settings. These settings affect all unitframes."],
				func = function() ACD:SelectGroup("ElvUI", "unitframe", "generalOptionsGroup", "allColorsGroup", "auraBars") end,
				disabled = function() return not E.db.unitframe.units[groupName].aurabar.enable end
			},
			configureButton2 = {
				order = 3,
				type = "execute",
				name = L["Coloring (Specific)"],
				desc = L["This opens the AuraBar Colors filter. These settings affect specific spells."],
				func = function() E:SetToFilterConfig("AuraBar Colors") end,
				disabled = function() return not E.db.unitframe.units[groupName].aurabar.enable end
			},
			generalGroup = {
				order = 4,
				type = "group",
				name = L["General"],
				get = function(info) return E.db.unitframe.units[groupName].aurabar[info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName].aurabar[info[#info]] = value updateFunc(UF, groupName) end,
				disabled = function() return not E.db.unitframe.units[groupName].aurabar.enable end,
				args = {
					anchorPoint = {
						order = 1,
						type = "select",
						name = L["Anchor Point"],
						desc = L["What point to anchor to the frame you set to attach to."],
						values = {
							ABOVE = L["Above"],
							BELOW = L["Below"]
						}
					},
					attachTo = {
						order = 2,
						type = "select",
						name = L["Attach To"],
						desc = L["The object you want to attach to."],
						values = {
							FRAME = L["Frame"],
							DEBUFFS = L["Debuffs"],
							BUFFS = L["Buffs"],
							DETACHED = L["Detach From Frame"]
						}
					},
					sortMethod = {
						order = 3,
						type = "select",
						name = L["Sort By"],
						desc = L["Method to sort by."],
						values = {
							TIME_REMAINING = L["Time Remaining"],
							DURATION = L["Duration"],
							NAME = L["NAME"],
							INDEX = L["Index"],
							PLAYER = L["PLAYER"]
						}
					},
					friendlyAuraType = {
						order = 4,
						type = "select",
						name = L["Friendly Aura Type"],
						desc = L["Set the type of auras to show when a unit is friendly."],
						values = {
							HARMFUL = L["Debuffs"],
							HELPFUL = L["Buffs"]
						}
					},
					enemyAuraType = {
						order = 5,
						type = "select",
						name = L["Enemy Aura Type"],
						desc = L["Set the type of auras to show when a unit is a foe."],
						values = {
							HARMFUL = L["Debuffs"],
							HELPFUL = L["Buffs"]
						}
					},
					sortDirection = {
						order = 6,
						type = "select",
						name = L["Sort Direction"],
						desc = L["Ascending or Descending order."],
						values = {
							ASCENDING = L["Ascending"],
							DESCENDING = L["Descending"]
						}
					},
					height = {
						order = 7,
						type = "range",
						name = L["Height"],
						min = 6, max = 40, step = 1
					},
					detachedWidth = {
						order = 8,
						type = "range",
						name = L["Detached Width"],
						hidden = function() return E.db.unitframe.units[groupName].aurabar.attachTo ~= "DETACHED" end,
						min = 50, max = 500, step = 1
					},
					maxBars = {
						order = 9,
						type = "range",
						name = L["Max Bars"],
						min = 1, max = 40, step = 1
					},
					yOffset = {
						order = 10,
						type = "range",
						name = L["Y-Offset"],
						min = -1, max = 100, step = 1,
						hidden = function() return E.db.unitframe.units[groupName].aurabar.attachTo == "DETACHED" end
					},
					spacing = {
						order = 11,
						type = "range",
						name = L["Spacing"],
						min = 0, softMax = 20, step = 1
					},
					clickThrough = {
						order = 12,
						type = "toggle",
						name = L["Click Through"],
						desc = L["Ignore mouse events."]
					}
				}
			},
			filters = {
				order = 500,
				type = "group",
				name = L["FILTERS"],
				disabled = function() return not E.db.unitframe.units[groupName].aurabar.enable end,
				args = {
					minDuration = {
						order = 1,
						type = "range",
						name = L["Minimum Duration"],
						desc = L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."],
						min = 0, max = 10800, step = 1
					},
					maxDuration = {
						order = 2,
						type = "range",
						name = L["Maximum Duration"],
						desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
						min = 0, max = 10800, step = 1
					},
					jumpToFilter = {
						order = 3,
						type = "execute",
						name = L["Filters Page"],
						desc = L["Shortcut to Filters section of the config."],
						func = function() ACD:SelectGroup("ElvUI", "filters") end
					},
					specialPriority = {
						order = 4,
						type = "select",
						sortByValue = true,
						name = L["Add Special Filter"],
						desc = L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."],
						values = function()
							local filters = {}
							local list = E.global.unitframe.specialFilters
							if not list then return end
							for filter in pairs(list) do
								filters[filter] = L[filter]
							end
							return filters
						end,
						set = function(info, value)
							filterPriority("aurabar", groupName, value)
							updateFunc(UF, groupName)
						end
					},
					priority = {
						order = 5,
						type = "select",
						name = L["Add Regular Filter"],
						desc = L["These filters use a list of spells to determine if an aura should be allowed or blocked. The content of these filters can be modified in the Filters section of the config."],
						values = function()
							local filters = {}
							local list = E.global.unitframe.aurafilters
							if not list then return end
							for filter in pairs(list) do
								filters[filter] = filter
							end
							return filters
						end,
						set = function(info, value)
							filterPriority("aurabar", groupName, value)
							updateFunc(UF, groupName)
						end
					},
					resetPriority = {
						order = 6,
						type = "execute",
						name = L["Reset Priority"],
						desc = L["Reset filter priority to the default state."],
						func = function()
							E.db.unitframe.units[groupName].aurabar.priority = P.unitframe.units[groupName].aurabar.priority
							updateFunc(UF, groupName)
						end
					},
					filterPriority = {
						order = 7,
						type = "multiselect",
						dragdrop = true,
						name = L["Filter Priority"],
						dragOnLeave = E.noop, --keep this here
						dragOnEnter = function(info)
							carryFilterTo = info.obj.value
						end,
						dragOnMouseDown = function(info)
							carryFilterFrom, carryFilterTo = info.obj.value, nil
						end,
						dragOnMouseUp = function(info)
							filterPriority("aurabar", groupName, carryFilterTo, nil, carryFilterFrom) --add it in the new spot
							carryFilterFrom, carryFilterTo = nil, nil
						end,
						dragOnClick = function(info)
							filterPriority("aurabar", groupName, carryFilterFrom, true)
						end,
						stateSwitchGetText = C.StateSwitchGetText,
						stateSwitchOnClick = function(info)
							filterPriority("aurabar", groupName, carryFilterFrom, nil, nil, true)
						end,
						values = function()
							local str = E.db.unitframe.units[groupName].aurabar.priority
							if str == "" then return nil end
							return {strsplit(",", str)}
						end,
						get = function(info, value)
							local str = E.db.unitframe.units[groupName].aurabar.priority
							if str == "" then return nil end
							local tbl = {strsplit(",", str)}
							return tbl[value]
						end,
						set = function(info)
							E.db.unitframe.units[groupName].aurabar[info[#info]] = nil -- this was being set when drag and drop was first added, setting it to nil to clear tester profiles of this variable
							updateFunc(UF, groupName)
						end
					},
					spacer1 = {
						order = 8,
						type = "description",
						fontSize = "medium",
						name = L["Use drag and drop to rearrange filter priority or right click to remove a filter."].."\n"..L["Use Shift+LeftClick to toggle between friendly or enemy or normal state. Normal state will allow the filter to be checked on all units. Friendly state is for friendly units only and enemy state is for enemy units."],
					}
				}
			}
		}
	}

	if groupName == "target" then
		config.args.generalGroup.args.attachTo.values.PLAYER_AURABARS = L["Player Frame Aura Bars"]
	end

	return config
end

local function GetOptionsTable_Auras(auraType, updateFunc, groupName, numUnits)
	local config = {
		type = "group",
		childGroups = "tab",
		name = auraType == "buffs" and L["Buffs"] or L["Debuffs"],
		get = function(info) return E.db.unitframe.units[groupName][auraType][info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName][auraType][info[#info]] = value updateFunc(UF, groupName, numUnits) end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"]
			},
			general = {
				order = 2,
				type = "group",
				name = L["General"],
				disabled = function() return not E.db.unitframe.units[groupName][auraType].enable end,
				args = {
					perrow = {
						order = 1,
						type = "range",
						name = L["Per Row"],
						min = 1, max = 20, step = 1
					},
					numrows = {
						order = 2,
						type = "range",
						name = L["Num Rows"],
						min = 1, max = 10, step = 1
					},
					sizeOverride = {
						order = 3,
						type = "range",
						name = L["Size Override"],
						desc = L["If not set to 0 then override the size of the aura icon to this."],
						min = 0, max = 60, step = 1
					},
					xOffset = {
						order = 4,
						type = "range",
						name = L["X-Offset"],
						min = -1000, max = 1000, step = 1
					},
					yOffset = {
						order = 5,
						type = "range",
						name = L["Y-Offset"],
						min = -1000, max = 1000, step = 1
					},
					spacing = {
						order = 6,
						type = "range",
						name = L["Spacing"],
						min = -1, max = 20, step = 1
					},
					attachTo = {
						order = 7,
						type = "select",
						name = L["Attach To"],
						desc = L["What to attach the buff anchor frame to."],
						values = {
							FRAME = L["Frame"],
							DEBUFFS = L["Debuffs"],
							HEALTH = L["HEALTH"],
							POWER = L["Power"]
						},
						disabled = function()
							local smartAuraPosition = E.db.unitframe.units[groupName].smartAuraPosition
							return (smartAuraPosition and (smartAuraPosition == "BUFFS_ON_DEBUFFS" or smartAuraPosition == "FLUID_BUFFS_ON_DEBUFFS"))
						end
					},
					anchorPoint = {
						order = 8,
						type = "select",
						name = L["Anchor Point"],
						desc = L["What point to anchor to the frame you set to attach to."],
						values = positionValues
					},
					sortMethod = {
						order = 9,
						type = "select",
						name = L["Sort By"],
						desc = L["Method to sort by."],
						values = {
							TIME_REMAINING = L["Time Remaining"],
							DURATION = L["Duration"],
							NAME = L["NAME"],
							INDEX = L["Index"],
							PLAYER = L["PLAYER"]
						}
					},
					sortDirection = {
						order = 10,
						type = "select",
						name = L["Sort Direction"],
						desc = L["Ascending or Descending order."],
						values = {
							ASCENDING = L["Ascending"],
							DESCENDING = L["Descending"]
						}
					},
					clickThrough = {
						order = 11,
						type = "toggle",
						name = L["Click Through"],
						desc = L["Ignore mouse events."]
					}
				}
			},
			stacks = {
				order = 3,
				type = "group",
				name = L["Stack Counter"],
				get = function(info, value) return E.db.unitframe.units[groupName][auraType][info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName][auraType][info[#info]] = value updateFunc(UF, groupName, numUnits) end,
				disabled = function() return not E.db.unitframe.units[groupName][auraType].enable end,
				args = {
					countFont = {
						order = 1,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Font"],
						values = _G.AceGUIWidgetLSMlists.font
					},
					countFontSize = {
						order = 2,
						type = "range",
						name = L["FONT_SIZE"],
						min = 4, max = 20, step = 1 -- max 20 cause otherwise it looks weird
					},
					countFontOutline = {
						order = 3,
						type = "select",
						name = L["Font Outline"],
						desc = L["Set the font outline."],
						values = C.Values.FontFlags
					}
				}
			},
			duration = {
				order = 4,
				type = "group",
				name = L["Duration"],
				get = function(info) return E.db.unitframe.units[groupName][auraType][info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName][auraType][info[#info]] = value updateFunc(UF, groupName, numUnits) end,
				disabled = function() return not E.db.unitframe.units[groupName][auraType].enable end,
				args = {
					cooldownShortcut = {
						order = 1,
						type = "execute",
						name = L["Cooldowns"],
						func = function() ACD:SelectGroup("ElvUI", "cooldown", "unitframe") end,
					},
					durationPosition = {
						order = 2,
						type = "select",
						name = L["Position"],
						values = positionValues
					}
				}
			},
			filters = {
				order = 5,
				type = "group",
				name = L["FILTERS"],
				disabled = function() return not E.db.unitframe.units[groupName][auraType].enable end,
				args = {
					minDuration = {
						order = 1,
						type = "range",
						name = L["Minimum Duration"],
						desc = L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."],
						min = 0, max = 10800, step = 1
					},
					maxDuration = {
						order = 2,
						type = "range",
						name = L["Maximum Duration"],
						desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
						min = 0, max = 10800, step = 1
					},
					jumpToFilter = {
						order = 3,
						type = "execute",
						name = L["Filters Page"],
						desc = L["Shortcut to Filters section of the config."],
						func = function() ACD:SelectGroup("ElvUI", "filters") end
					},
					specialPriority = {
						order = 4,
						type = "select",
						sortByValue = true,
						name = L["Add Special Filter"],
						desc = L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."],
						values = function()
							local filters = {}
							local list = E.global.unitframe.specialFilters
							if not list then return end
							for filter in pairs(list) do
								filters[filter] = L[filter]
							end
							return filters
						end,
						set = function(info, value)
							filterPriority(auraType, groupName, value)
							updateFunc(UF, groupName, numUnits)
						end
					},
					priority = {
						order = 5,
						type = "select",
						name = L["Add Regular Filter"],
						desc = L["These filters use a list of spells to determine if an aura should be allowed or blocked. The content of these filters can be modified in the Filters section of the config."],
						values = function()
							local filters = {}
							local list = E.global.unitframe.aurafilters
							if not list then return end
							for filter in pairs(list) do
								filters[filter] = filter
							end
							return filters
						end,
						set = function(info, value)
							filterPriority(auraType, groupName, value)
							updateFunc(UF, groupName, numUnits)
						end
					},
					resetPriority = {
						order = 6,
						type = "execute",
						name = L["Reset Priority"],
						desc = L["Reset filter priority to the default state."],
						func = function()
							E.db.unitframe.units[groupName][auraType].priority = P.unitframe.units[groupName][auraType].priority
							updateFunc(UF, groupName, numUnits)
						end
					},
					filterPriority = {
						order = 7,
						type = "multiselect",
						dragdrop = true,
						name = L["Filter Priority"],
						dragOnLeave = E.noop, --keep this here
						dragOnEnter = function(info)
							carryFilterTo = info.obj.value
						end,
						dragOnMouseDown = function(info)
							carryFilterFrom, carryFilterTo = info.obj.value, nil
						end,
						dragOnMouseUp = function(info)
							filterPriority(auraType, groupName, carryFilterTo, nil, carryFilterFrom) --add it in the new spot
							carryFilterFrom, carryFilterTo = nil, nil
						end,
						dragOnClick = function(info)
							filterPriority(auraType, groupName, carryFilterFrom, true)
						end,
						stateSwitchGetText = C.StateSwitchGetText,
						stateSwitchOnClick = function(info)
							filterPriority(auraType, groupName, carryFilterFrom, nil, nil, true)
						end,
						values = function()
							local str = E.db.unitframe.units[groupName][auraType].priority
							if str == "" then return nil end
							return {strsplit(",", str)}
						end,
						get = function(info, value)
							local str = E.db.unitframe.units[groupName][auraType].priority
							if str == "" then return nil end
							local tbl = {strsplit(",", str)}
							return tbl[value]
						end,
						set = function(info)
							E.db.unitframe.units[groupName][auraType][info[#info]] = nil -- this was being set when drag and drop was first added, setting it to nil to clear tester profiles of this variable
							updateFunc(UF, groupName, numUnits)
						end
					},
					spacer1 = {
						order = 8,
						type = "description",
						fontSize = "medium",
						name = L["Use drag and drop to rearrange filter priority or right click to remove a filter."].."\n"..L["Use Shift+LeftClick to toggle between friendly or enemy or normal state. Normal state will allow the filter to be checked on all units. Friendly state is for friendly units only and enemy state is for enemy units."],
					}
				}
			}
		}
	}

	if auraType == "debuffs" then
		config.args.general.args.attachTo.values = {
			FRAME = L["Frame"],
			BUFFS = L["Buffs"],
			HEALTH = L["HEALTH"],
			POWER = L["Power"]
		}
		config.args.general.args.attachTo.disabled = function()
			local smartAuraPosition = E.db.unitframe.units[groupName].smartAuraPosition
			return (smartAuraPosition and (smartAuraPosition == "DEBUFFS_ON_BUFFS" or smartAuraPosition == "FLUID_DEBUFFS_ON_BUFFS"))
		end
		config.args.general.args.desaturate = {
			order = 12,
			type = "toggle",
			name = L["Desaturated Icon"]
		}
	end

	return config
end

local function doApplyToAll(db, info, value)
	if not db then return end
	for _, spell in pairs(db) do
		if value ~= nil then
			spell[info[#info]] = value
		else
			return spell[info[#info]]
		end
	end
end

local function BuffIndicator_ApplyToAll(info, value, profile, pet)
	if profile then
		return doApplyToAll(E.db.unitframe.filters.buffwatch, info, value)
	elseif pet then
		return doApplyToAll(E.global.unitframe.buffwatch.PET, info, value)
	else
		return doApplyToAll(E.global.unitframe.buffwatch[E.myclass], info, value)
	end
end

local function GetOptionsTable_AuraWatch(updateFunc, groupName, numGroup)
	local config = {
		type = "group",
		name = L["Buff Indicator"],
		get = function(info) return E.db.unitframe.units[groupName].buffIndicator[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].buffIndicator[info[#info]] = value updateFunc(UF, groupName, numGroup) end,
		args = {
			enable = {
				order = 2,
				type = "toggle",
				name = L["ENABLE"]
			},
			size = {
				order = 3,
				type = "range",
				name = L["Size"],
				min = 6, max = 48, step = 1
			},
			profileSpecific = {
				order = 4,
				type = "toggle",
				name = L["Profile Specific"],
				desc = L["Use the profile specific filter Buff Indicator (Profile) instead of the global filter Buff Indicator."]
			},
			configureButton = {
				order = 6,
				type = "execute",
				name = L["Configure Auras"],
				func = function()
					if E.db.unitframe.units[groupName].buffIndicator.profileSpecific then
						E:SetToFilterConfig("Buff Indicator (Profile)")
					else
						E:SetToFilterConfig("Buff Indicator")
					end
				end
			},
			applyToAll = {
				order = 50,
				type = "group",
				name = "",
				guiInline = true,
				get = function(info)
					return BuffIndicator_ApplyToAll(info, nil, E.db.unitframe.units[groupName].buffIndicator.profileSpecific, groupName == "pet")
				end,
				set = function(info, value)
					BuffIndicator_ApplyToAll(info, value, E.db.unitframe.units[groupName].buffIndicator.profileSpecific, groupName == "pet")
					updateFunc(UF, groupName, numGroup)
					UF:UpdateAuraWatchFromHeader("raid")
					UF:UpdateAuraWatchFromHeader("raid40")
					UF:UpdateAuraWatchFromHeader("party")
					UF:UpdateAuraWatchFromHeader("raidpet", true)
				end,
				args = {
					header = {
						order = 1,
						type = "description",
						name = L["|cffFF0000Warning:|r Changing options in this section will apply to all Buff Indicator auras. To change only one Aura, please click Configure Auras and change that specific Auras settings. If Profile Specific is selected it will apply to that filter set."]
					},
					style = {
						order = 2,
						type = "select",
						name = L["Style"],
						values = {
							timerOnly = L["Timer Only"],
							coloredIcon = L["Colored Icon"],
							texturedIcon = L["Textured Icon"]
						}
					},
					textThreshold = {
						order = 3,
						type = "range",
						name = L["Text Threshold"],
						desc = L["At what point should the text be displayed. Set to -1 to disable."],
						min = -1, max = 60, step = 1
					},
					displayText = {
						order = 4,
						type = "toggle",
						name = L["Display Text"]
					}
				}
			}
		}
	}

	return config
end

local function GetOptionsTable_Castbar(hasTicks, updateFunc, groupName, numUnits)
	local config = {
		type = "group",
		childGroups = "tab",
		name = L["Castbar"],
		get = function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"]
			},
			generalGroup = {
				order = 2,
				type = "group",
				name = L["General"],
				get = function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
				disabled = function() return not E.db.unitframe.units[groupName].castbar.enable end,
				args = {
					matchsize = {
						order = 1,
						type = "execute",
						name = L["Match Frame Width"],
						func = function() E.db.unitframe.units[groupName].castbar.width = E.db.unitframe.units[groupName].width updateFunc(UF, groupName, numUnits) end
					},
					forceshow = {
						order = 2,
						type = "execute",
						name = L["SHOW"].." / "..L["HIDE"],
						func = function()
							local frameName = gsub("ElvUF_"..E:StringTitle(groupName), "t(arget)", "T%1")

							if groupName == "party" then
								local header = UF.headers[groupName]
								for i = 1, header:GetNumChildren() do
									local group = select(i, header:GetChildren())
									for j = 1, group:GetNumChildren() do
										--Party unitbutton
										local unitbutton = select(j, group:GetChildren())
										local castbar = unitbutton.Castbar
										if not castbar.oldHide then
											castbar.oldHide = castbar.Hide
											castbar.Hide = castbar.Show
											castbar:Show()
										else
											castbar.Hide = castbar.oldHide
											castbar.oldHide = nil
											castbar:Hide()
										end
									end
								end
							elseif numUnits then
								for i = 1, numUnits do
									local castbar = _G[frameName..i].Castbar
									if not castbar.oldHide then
										castbar.oldHide = castbar.Hide
										castbar.Hide = castbar.Show
										castbar:Show()
									else
										castbar.Hide = castbar.oldHide
										castbar.oldHide = nil
										castbar:Hide()
									end
								end
							else
								local castbar = _G[frameName].Castbar
								if not castbar.oldHide then
									castbar.oldHide = castbar.Hide
									castbar.Hide = castbar.Show
									castbar:Show()
								else
									castbar.Hide = castbar.oldHide
									castbar.oldHide = nil
									castbar:Hide()
								end
							end
						end
					},
					configureButton = {
						order = 3,
						type = "execute",
						name = L["Coloring"],
						desc = L["This opens the UnitFrames Color settings. These settings affect all unitframes."],
						func = function() ACD:SelectGroup("ElvUI", "unitframe", "generalOptionsGroup", "allColorsGroup", "castBars") end
					},
					width = {
						order = 4,
						type = "range",
						name = L["Width"],
						softMax = 600, min = 50, max = GetScreenWidth(), step = 1
					},
					height = {
						order = 5,
						type = "range",
						name = L["Height"],
						min = 5, max = 85, step = 1
					},
					timeToHold = {
						order = 6,
						type = "range",
						name = L["Time To Hold"],
						desc = L["How many seconds the castbar should stay visible after the cast failed or was interrupted."],
						min = 0, max = 10, step = .1
					},
					reverse = {
						order = 7,
						type = "toggle",
						name = L["Reverse"]
					},
					spark = {
						order = 8,
						type = "toggle",
						name = L["Spark"],
						desc = L["Display a spark texture at the end of the castbar statusbar to help show the differance between castbar and backdrop."]
					},
					latency = {
						order = 9,
						type = "toggle",
						name = L["Latency"],
						hidden = function() return groupName ~= "player" end
					},
					displayTarget = {
						order = 10,
						type = "toggle",
						name = L["Display Target"],
						desc = L["Display the target of current cast."]
					},
					format = {
						order = 11,
						type = "select",
						name = L["Format"],
						desc = L["Cast Time Format"],
						values = {
							CURRENTMAX = L["Current / Max"],
							CURRENT = L["Current"],
							REMAINING = L["Remaining"],
							REMAININGMAX = L["Remaining / Max"]
						}
					},
					overlayOnFrame = {
						order = 12,
						type = "select",
						name = L["Attach To"],
						desc = L["The object you want to attach to."],
						values = {
							Health = L["HEALTH"],
							Power = L["Power"],
							InfoPanel = L["Information Panel"],
							None = L["NONE"]
						}
					}
				}
			},
			textGroup = {
				order = 3,
				type = "group",
				name = L["Text"],
				get = function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
				disabled = function() return not E.db.unitframe.units[groupName].castbar.enable end,
				args = {
					hidetext = {
						order = 1,
						type = "toggle",
						name = L["Hide Text"],
						desc = L["Hide Castbar text. Useful if your power height is very low or if you use power offset."]
					},
					textColor = {
						order = 2,
						type = "color",
						name = L["COLOR"],
						hasAlpha = true,
						get = function(info)
							local c = E.db.unitframe.units[groupName].castbar.textColor
							local d = P.unitframe.units[groupName].castbar.textColor
							return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a
						end,
						set = function(info, r, g, b, a)
							local c = E.db.unitframe.units[groupName].castbar.textColor
							c.r, c.g, c.b, c.a = r, g, b, a
							updateFunc(UF, groupName, numUnits)
						end
					},
					textSettings = {
						order = 2,
						type = "group",
						name = L["Text Options"],
						guiInline = true,
						get = function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end,
						set = function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
						args = {
							xOffsetText = {
								order = 1,
								type = "range",
								name = L["X-Offset"],
								min = -500, max = 500, step = 1
							},
							yOffsetText = {
								order = 2,
								type = "range",
								name = L["Y-Offset"],
								min = -500, max = 500, step = 1
							},
							enable = {
								order = 3,
								type = "toggle",
								name = L["Custom Font"],
								get = function(info) return E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] end,
								set = function(info, value) E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
							},
							font = {
								order = 4,
								type = "select",
								dialogControl = "LSM30_Font",
								name = L["Font"],
								values = _G.AceGUIWidgetLSMlists.font,
								get = function(info) return E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] end,
								set = function(info, value) E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
								disabled = function() return not E.db.unitframe.units[groupName].castbar.customTextFont.enable end
							},
							fontSize = {
								order = 5,
								type = "range",
								name = L["Font Size"],
								min = 6, max = 64, step = 1,
								get = function(info) return E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] end,
								set = function(info, value) E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
								disabled = function() return not E.db.unitframe.units[groupName].castbar.customTextFont.enable end
							},
							fontStyle = {
								order = 6,
								type = "select",
								name = L["Font Outline"],
								values = C.Values.FontFlags,
								get = function(info) return E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] end,
								set = function(info, value) E.db.unitframe.units[groupName].castbar.customTextFont[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
								disabled = function() return not E.db.unitframe.units[groupName].castbar.customTextFont.enable end
							}
						}
					},
					timeSettings = {
						order = 3,
						type = "group",
						name = L["Time Options"],
						guiInline = true,
						get = function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end,
						set = function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
						args = {
							xOffsetTime = {
								order = 1,
								type = "range",
								name = L["X-Offset"],
								min = -500, max = 500, step = 1
							},
							yOffsetTime = {
								order = 2,
								type = "range",
								name = L["Y-Offset"],
								min = -500, max = 500, step = 1
							},
							enable = {
								order = 3,
								type = "toggle",
								name = L["Custom Font"],
								get = function(info) return E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] end,
								set = function(info, value) E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
							},
							font = {
								order = 4,
								type = "select",
								dialogControl = "LSM30_Font",
								name = L["Font"],
								values = _G.AceGUIWidgetLSMlists.font,
								get = function(info) return E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] end,
								set = function(info, value) E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
								disabled = function() return not E.db.unitframe.units[groupName].castbar.customTimeFont.enable end
							},
							fontSize = {
								order = 5,
								type = "range",
								name = L["Font Size"],
								min = 6, max = 64, step = 1,
								get = function(info) return E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] end,
								set = function(info, value) E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
								disabled = function() return not E.db.unitframe.units[groupName].castbar.customTimeFont.enable end
							},
							fontStyle = {
								order = 6,
								type = "select",
								name = L["Font Outline"],
								values = C.Values.FontFlags,
								get = function(info) return E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] end,
								set = function(info, value) E.db.unitframe.units[groupName].castbar.customTimeFont[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
								disabled = function() return not E.db.unitframe.units[groupName].castbar.customTimeFont.enable end
							}
						}
					}
				}
			},
			iconSettings = {
				order = 4,
				type = "group",
				name = L["Icon"],
				get = function(info) return E.db.unitframe.units[groupName].castbar[info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName].castbar[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
				disabled = function() return not E.db.unitframe.units[groupName].castbar.enable end,
				args = {
					icon = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"]
					},
					iconAttached = {
						order = 2,
						type = "toggle",
						name = L["Icon Inside Castbar"],
						desc = L["Display the castbar icon inside the castbar."],
						disabled = function() return not E.db.unitframe.units[groupName].castbar.icon end
					},
					spacer = {
						order = 3,
						type = "description",
						name = ""
					},
					iconSize = {
						order = 4,
						type = "range",
						name = L["Icon Size"],
						desc = L["This dictates the size of the icon when it is not attached to the castbar."],
						min = 8, max = 150, step = 1,
						disabled = function() return not E.db.unitframe.units[groupName].castbar.icon or E.db.unitframe.units[groupName].castbar.iconAttached end
					},
					iconXOffset = {
						order = 5,
						type = "range",
						name = L["X-Offset"],
						min = -500, max = 500, step = 1,
						disabled = function() return not E.db.unitframe.units[groupName].castbar.icon or E.db.unitframe.units[groupName].castbar.iconAttached end
					},
					iconYOffset = {
						order = 6,
						type = "range",
						name = L["Y-Offset"],
						min = -500, max = 500, step = 1,
						disabled = function() return not E.db.unitframe.units[groupName].castbar.icon or E.db.unitframe.units[groupName].castbar.iconAttached end
					},
					iconAttachedTo = {
						order = 7,
						type = "select",
						name = L["Attach To"],
						desc = L["The object you want to attach to."],
						disabled = function() return not E.db.unitframe.units[groupName].castbar.icon or E.db.unitframe.units[groupName].castbar.iconAttached end,
						values = {
							Frame = L["Frame"],
							Castbar = L["Castbar"]
						}
					},
					iconPosition = {
						order = 8,
						type = "select",
						name = L["Position"],
						values = positionValues,
						disabled = function() return not E.db.unitframe.units[groupName].castbar.icon or E.db.unitframe.units[groupName].castbar.iconAttached end
					}
				}
			},
			strataAndLevel = {
				order = 6,
				type = "group",
				name = L["Strata and Level"],
				get = function(info) return E.db.unitframe.units[groupName].castbar.strataAndLevel[info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName].castbar.strataAndLevel[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
				disabled = function() return not E.db.unitframe.units[groupName].castbar.enable end,
				args = {
					useCustomStrata = {
						order = 1,
						type = "toggle",
						name = L["Use Custom Strata"]
					},
					frameStrata = {
						order = 2,
						type = "select",
						name = L["Frame Strata"],
						values = C.Values.Strata,
						disabled = function() return not E.db.unitframe.units[groupName].castbar.strataAndLevel.useCustomStrata end
					},
					spacer = {
						order = 3,
						type = "description",
						name = ""
					},
					useCustomLevel = {
						order = 4,
						type = "toggle",
						name = L["Use Custom Level"]
					},
					frameLevel = {
						order = 5,
						type = "range",
						name = L["Frame Level"],
						min = 2, max = 128, step = 1,
						disabled = function() return not E.db.unitframe.units[groupName].castbar.strataAndLevel.useCustomLevel end
					}
				}
			},
			customColor = {
				order = 7,
				type = "group",
				name = L["Custom Color"],
				get = function(info)
					if info.type == "color" then
						local c = E.db.unitframe.units[groupName].castbar.customColor[info[#info]]
						local d = P.unitframe.units[groupName].castbar.customColor[info[#info]]
						return c.r, c.g, c.b, c.a, d.r, d.g, d.b, 1.0
					else
						return E.db.unitframe.units[groupName].castbar.customColor[info[#info]]
					end
				end,
				set = function(info, ...)
					if info.type == "color" then
						local r, g, b, a = ...
						local c = E.db.unitframe.units[groupName].castbar.customColor[info[#info]]
						c.r, c.g, c.b, c.a = r, g, b, a
					else
						local value = ...
						E.db.unitframe.units[groupName].castbar.customColor[info[#info]] = value
					end
					updateFunc(UF, groupName, numUnits)
				end,
				disabled = function() return not E.db.unitframe.units[groupName].castbar.enable end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
					},
					transparent = {
						order = 2,
						type = "toggle",
						name = L["Transparent"],
						desc = L["Make textures transparent."],
						disabled = function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end
					},
					invertColors = {
						order = 3,
						type = "toggle",
						name = L["Invert Colors"],
						desc = L["Invert foreground and background colors."],
						disabled = function()
							return not E.db.unitframe.units[groupName].castbar.customColor.enable
							or not E.db.unitframe.units[groupName].castbar.customColor.transparent
						end
					},
					spacer1 = {
						order = 4,
						type = "description",
						name = ""
					},
					useClassColor = {
						order = 5,
						type = "toggle",
						name = L["Class Color"],
						desc = L["Color castbar by the class of the unit's class."],
						disabled = function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end
					},
					useReactionColor = {
						order = 6,
						type = "toggle",
						name = L["Reaction Color"],
						desc = L["Color castbar by the reaction of the unit to the player."],
						disabled = function() return not E.db.unitframe.units[groupName].castbar.customColor.enable or (groupName == "player" or groupName == "pet") end
					},
					useCustomBackdrop = {
						order = 7,
						type = "toggle",
						name = L["Custom Backdrop"],
						desc = L["Use the custom backdrop color instead of a multiple of the main color."],
						disabled = function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end
					},
					spacer2 = {
						order = 8,
						type = "description",
						name = ""
					},
					colorBackdrop = {
						order = 9,
						type = "color",
						name = L["Custom Backdrop"],
						desc = L["Use the custom backdrop color instead of a multiple of the main color."],
						hasAlpha = true,
						disabled = function()
							return not E.db.unitframe.units[groupName].castbar.customColor.enable
							or not E.db.unitframe.units[groupName].castbar.customColor.useCustomBackdrop
						end
					},
					color = {
						order = 10,
						type = "color",
						name = L["Interruptible"],
						disabled = function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end
					},
					colorNoInterrupt = {
						order = 11,
						type = "color",
						name = L["Non-Interruptible"],
						disabled = function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end
					},
					spacer3 = {
						order = 12,
						type = "description",
						name = ""
					},
					colorInterrupted = {
						order = 13,
						type = "color",
						name = L["Interrupted"],
						disabled = function() return not E.db.unitframe.units[groupName].castbar.customColor.enable end
					}
				}
			}
		}
	}

	if groupName == "party" then
		config.args.positionsGroup = {
			order = 5,
			type = "group",
			name = L["Position"],
			get = function(info) return E.db.unitframe.units[groupName].castbar.positionsGroup[info[#info]] end,
			set = function(info, value) E.db.unitframe.units[groupName].castbar.positionsGroup[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
			disabled = function() return not E.db.unitframe.units[groupName].castbar.enable end,
			args = {
				anchorPoint = {
					order = 1,
					type = "select",
					name = L["Anchor Point"],
					desc = L["What point to anchor to the frame you set to attach to."],
					values = positionValues
				},
				xOffset = {
					order = 2,
					type = "range",
					name = L["X-Offset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1
				},
				yOffset = {
					order = 3,
					type = "range",
					name = L["Y-Offset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1
				}
			}
		}
	end

	if hasTicks then
		config.args.ticks = {
			order = 5,
			type = "group",
			name = L["Ticks"],
			disabled = function() return not E.db.unitframe.units[groupName].castbar.enable end,
			args = {
				ticks = {
					order = 1,
					type = "toggle",
					name = L["Ticks"],
					desc = L["Display tick marks on the castbar for channelled spells. This will adjust automatically for spells like Drain Soul and add additional ticks based on haste."]
				},
				tickColor = {
					order = 2,
					type = "color",
					name = L["COLOR"],
					hasAlpha = true,
					get = function(info)
						local c = E.db.unitframe.units[groupName].castbar.tickColor
						local d = P.unitframe.units[groupName].castbar.tickColor
						return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a
					end,
					set = function(info, r, g, b, a)
						local c = E.db.unitframe.units[groupName].castbar.tickColor
						c.r, c.g, c.b, c.a = r, g, b, a
						updateFunc(UF, groupName, numUnits)
					end,
					disabled = function() return not E.db.unitframe.units[groupName].castbar.ticks end
				},
				tickWidth = {
					order = 3,
					type = "range",
					name = L["Width"],
					min = 1, max = 20, step = 1,
					disabled = function() return not E.db.unitframe.units[groupName].castbar.ticks end
				}
			}
		}
	end

	return config
end

local function GetOptionsTable_Cutaway(updateFunc, groupName, numGroup)
	local config = {
		type = "group",
		childGroups = "tab",
		name = L["Cutaway Bars"],
		args = {
			health = {
				order = 1,
				type = "group",
				guiInline = true,
				name = L["HEALTH"],
				get = function(info) return E.db.unitframe.units[groupName].cutaway.health[info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName].cutaway.health[info[#info]] = value updateFunc(UF, groupName, numGroup) end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"]
					},
					lengthBeforeFade = {
						order = 2,
						type = "range",
						name = L["Fade Out Delay"],
						desc = L["How much time before the cutaway health starts to fade."],
						min = 0.1, max = 1, step = 0.1,
						disabled = function() return not E.db.unitframe.units[groupName].cutaway.health.enabled end
					},
					fadeOutTime = {
						order = 3,
						type = "range",
						name = L["Fade Out"],
						desc = L["How long the cutaway health will take to fade out."],
						min = 0.1, max = 1, step = 0.1,
						disabled = function() return not E.db.unitframe.units[groupName].cutaway.health.enabled end
					}
				}
			}
		}
	}
	if E.db.unitframe.units[groupName].cutaway.power then
		config.args.power = {
			order = 2,
			type = "group",
			name = L["Power"],
			guiInline = true,
			get = function(info) return E.db.unitframe.units[groupName].cutaway.power[info[#info]] end,
			set = function(info, value) E.db.unitframe.units[groupName].cutaway.power[info[#info]] = value updateFunc(UF, groupName, numGroup) end,
			args = {
				enabled = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"]
				},
				lengthBeforeFade = {
					order = 2,
					type = "range",
					name = L["Fade Out Delay"],
					desc = L["How much time before the cutaway power starts to fade."],
					min = 0.1, max = 1, step = 0.1,
					disabled = function() return not E.db.unitframe.units[groupName].cutaway.power.enabled end
				},
				fadeOutTime = {
					type = "range",
					order = 3,
					name = L["Fade Out"],
					desc = L["How long the cutaway power will take to fade out."],
					min = 0.1, max = 1, step = 0.1,
					disabled = function() return not E.db.unitframe.units[groupName].cutaway.power.enabled end
				}
			}
		}
	end

	return config
end

local individual = {
	player = true,
	target = true,
	targettarget = true,
	targettargettarget = true,
	focus = true,
	focustarget = true,
	pet = true,
	pettarget = true
}

local function UpdateCustomTextGroup(unit)
	if unit == "party" or unit:find("raid") then
		for i = 1, UF[unit]:GetNumChildren() do
			local child = select(i, UF[unit]:GetChildren())

			for x = 1, child:GetNumChildren() do
				local subchild = select(x, child:GetChildren())
				UF:Configure_CustomTexts(subchild)
				subchild:UpdateTags()
			end
		end
	elseif unit == "boss" or unit == "arena" then
		for i = 1, 5 do
			UF:Configure_CustomTexts(UF[unit..i])
			UF[unit..i]:UpdateTags()
		end
	else
		UF:Configure_CustomTexts(UF[unit])
		UF[unit]:UpdateTags()
	end
end

local function CreateCustomTextGroup(unit, objectName)
	if not E.private.unitframe.enable then return end
	local group = individual[unit] and "individualUnits" or "groupUnits"
	if not E.Options.args.unitframe.args[group].args[unit] then
		return
	elseif E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName] then
		E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName].hidden = false -- Re-show existing custom texts which belong to current profile and were previously hidden
		tinsert(CUSTOMTEXT_CONFIGS, E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName]) --Register this custom text config to be hidden again on profile change
		return
	end

	E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName] = {
		order = -1,
		type = "group",
		name = objectName,
		get = function(info) return E.db.unitframe.units[unit].customTexts[objectName][info[#info]] end,
		set = function(info, value)
			E.db.unitframe.units[unit].customTexts[objectName][info[#info]] = value

			UpdateCustomTextGroup(unit)
		end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"]
			},
			delete = {
				order = 2,
				type = "execute",
				name = L["DELETE"],
				func = function()
					E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName] = nil
					E.db.unitframe.units[unit].customTexts[objectName] = nil

					UpdateCustomTextGroup(unit)
				end
			},
			attachTextTo = {
				order = 3,
				type = "select",
				name = L["Attach Text To"],
				desc = L["The object you want to attach to."],
				values = attachToValues
			},
			font = {
				order = 4,
				type = "select", dialogControl = "LSM30_Font",
				name = L["Font"],
				values = AceGUIWidgetLSMlists.font
			},
			size = {
				order = 5,
				type = "range",
				name = L["FONT_SIZE"],
				min = 4, max = 32, step = 1
			},
			fontOutline = {
				order = 6,
				type = "select",
				name = L["Font Outline"],
				desc = L["Set the font outline."],
				values = C.Values.FontFlags
			},
			xOffset = {
				order = 7,
				type = "range",
				name = L["X-Offset"],
				min = -400, max = 400, step = 1
			},
			yOffset = {
				order = 8,
				type = "range",
				name = L["Y-Offset"],
				min = -400, max = 400, step = 1
			},
			justifyH = {
				order = 9,
				type = "select",
				name = L["JustifyH"],
				desc = L["Sets the font instance's horizontal text alignment style."],
				values = {
					CENTER = L["Center"],
					LEFT = L["Left"],
					RIGHT = L["Right"]
				}
			},
			text_format = {
				order = 10,
				type = "input",
				name = L["Text Format"],
				desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
				width = "full"
			}
		}
	}

	if unit == "player" then
		if E.myclass == "DRUID" and UF.player.AdditionalPower and UF.player.EclipseBar then
			E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName].args.attachTextTo.values = {AdditionalPower = L["Additional Power"], EclipseBar = L["Eclipse Power"], Health = L["HEALTH"], Power = L["Power"], InfoPanel = L["Information Panel"], Frame = L["Frame"]}
		elseif E.myclass == "WARLOCK" and UF.player.DemonicFury then
			E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName].args.attachTextTo.values = {DemonicFury = L["DEMONIC_FURY"], Health = L["HEALTH"], Power = L["Power"], InfoPanel = L["Information Panel"], Frame = L["Frame"]}
		else
			E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName].args.attachTextTo.values = attachToValues
		end
	else
		E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName].args.attachTextTo.values = attachToValues
	end

	tinsert(CUSTOMTEXT_CONFIGS, E.Options.args.unitframe.args[group].args[unit].args.customText.args[objectName]) --Register this custom text config to be hidden on profile change
end

local function GetOptionsTable_CustomText(updateFunc, groupName, numUnits)
	local config = {
		type = "group",
		childGroups = "tab",
		name = L["Custom Texts"],
		args = {
			createCustomText = {
				order = 2,
				type = "input",
				name = L["Create Custom Text"],
				width = "full",
				get = function() return "" end,
				set = function(info, textName)
					for object in pairs(E.db.unitframe.units[groupName]) do
						if object:lower() == textName:lower() then
							E:Print(L["The name you have selected is already in use by another element."])
							return
						end
					end

					if not E.db.unitframe.units[groupName].customTexts then
						E.db.unitframe.units[groupName].customTexts = {}
					end

					local frameName = "ElvUF_"..E:StringTitle(groupName)
					if E.db.unitframe.units[groupName].customTexts[textName] or (_G[frameName] and _G[frameName].customTexts and _G[frameName].customTexts[textName] or _G[frameName.."Group1UnitButton1"] and _G[frameName.."Group1UnitButton1"].customTexts and _G[frameName.."Group1UnitButton1"][textName]) then
						E:Print(L["The name you have selected is already in use by another element."])
						return
					end

					E.db.unitframe.units[groupName].customTexts[textName] = {
						["text_format"] = strmatch(textName, "^%[") and textName or "",
						["size"] = E.db.unitframe.fontSize,
						["font"] = E.db.unitframe.font,
						["xOffset"] = 0,
						["yOffset"] = 0,
						["justifyH"] = "CENTER",
						["fontOutline"] = E.db.unitframe.fontOutline,
						["attachTextTo"] = "Health"
					}

					CreateCustomTextGroup(groupName, textName)
					updateFunc(UF, groupName, numUnits)

					E.Libs.AceConfigDialog:SelectGroup("ElvUI", "unitframe", individual[groupName] and "individualUnits" or "groupUnits", groupName, "customText", textName)
				end
			}
		}
	}

	return config
end

local function GetOptionsTable_Fader(updateFunc, groupName, numUnits)
	local config = {
		type = "group",
		name = L["Fader"],
		get = function(info) return E.db.unitframe.units[groupName].fader[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].fader[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
		args = {
			enable = {
				order = 2,
				type = "toggle",
				name = L["ENABLE"]
			},
			range = {
				order = 3,
				type = "toggle",
				name = L["Range"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable end,
				hidden = function() return groupName == "player" end
			},
			hover = {
				order = 4,
				type = "toggle",
				name = L["Hover"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end
			},
			combat = {
				order = 5,
				type = "toggle",
				name = L["COMBAT"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end
			},
			unittarget = {
				order = 6,
				type = "toggle",
				name = L["Unit Target"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end,
				hidden = function() return groupName == "player" end
			},
			playertarget = {
				order = 7,
				type = "toggle",
				name = (groupName == "player" and L["TARGET"]) or L["Player Target"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end
			},
			focus = {
				order = 8,
				type = "toggle",
				name = L["Focus"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end
			},
			health = {
				order = 9,
				type = "toggle",
				name = L["HEALTH"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end
			},
			power = {
				order = 10,
				type = "toggle",
				name = L["Power"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end
			},
			vehicle = {
				order = 11,
				type = "toggle",
				name = L["Vehicle"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end
			},
			casting = {
				order = 12,
				type = "toggle",
				name = L["Casting"],
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end
			},
			spacer = {
				order = 13,
				type = "description",
				name = " ",
				width = "full"
			},
			delay = {
				order = 14,
				type = "range",
				name = L["Fade Out Delay"],
				min = 0, max = 3, step = 0.01,
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable or E.db.unitframe.units[groupName].fader.range end
			},
			smooth = {
				order = 15,
				type = "range",
				name = L["Smooth"],
				min = 0, max = 1, step = 0.01,
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable end
			},
			minAlpha = {
				order = 16,
				type = "range",
				name = L["Min Alpha"],
				min = 0, max = 1, step = 0.01,
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable end
			},
			maxAlpha = {
				order = 17,
				type = "range",
				name = L["Max Alpha"],
				min = 0, max = 1, step = 0.01,
				disabled = function() return not E.db.unitframe.units[groupName].fader.enable end
			}
		}
	}

	return config
end

local function GetOptionsTable_Health(isGroupFrame, updateFunc, groupName, numUnits)
	local config = {
		type = "group",
		name = L["HEALTH"],
		get = function(info) return E.db.unitframe.units[groupName].health[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].health[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
		args = {
			reverseFill = {
				order = 1,
				type = "toggle",
				name = L["Reverse Fill"]
			},
			attachTextTo = {
				order = 3,
				type = "select",
				name = L["Attach Text To"],
				desc = L["The object you want to attach to."],
				values = attachToValues
			},
			colorOverride = {
				order = 4,
				type = "select",
				name = L["Class Color Override"],
				desc = L["Override the default class color setting."],
				values = colorOverrideValues,
				get = function(info) return E.db.unitframe.units[groupName][info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName][info[#info]] = value updateFunc(UF, groupName, numUnits) end
			},
			configureButton = {
				order = 5,
				type = "execute",
				name = L["Coloring"],
				desc = L["This opens the UnitFrames Color settings. These settings affect all unitframes."],
				func = function() ACD:SelectGroup("ElvUI", "unitframe", "generalOptionsGroup", "allColorsGroup", "healthGroup") end
			},
			textGroup = {
				order = 8,
				type = "group",
				name = L["Text Options"],
				guiInline = true,
				args = {
					position = {
						order = 1,
						type = "select",
						name = L["Position"],
						values = positionValues
					},
					xOffset = {
						order = 2,
						type = "range",
						name = L["X-Offset"],
						desc = L["Offset position for text."],
						min = -300, max = 300, step = 1
					},
					yOffset = {
						order = 3,
						type = "range",
						name = L["Y-Offset"],
						desc = L["Offset position for text."],
						min = -300, max = 300, step = 1
					},
					text_format = {
						order = 4,
						type = "input",
						name = L["Text Format"],
						desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
						width = "full"
					}
				}
			}
		}
	}

	if isGroupFrame then
		config.args.orientation = {
			order = 6,
			type = "select",
			name = L["Statusbar Fill Orientation"],
			desc = L["Direction the health bar moves when gaining/losing health."],
			values = {
				HORIZONTAL = L["Horizontal"],
				VERTICAL = L["Vertical"]
			}
		}
	end

	if groupName == "pet" or groupName == "raidpet" then
		config.args.colorPetByUnitClass = {
			order = 2,
			type = "toggle",
			name = L["Color by Unit Class"]
		}
	end

	return config
end

local function GetOptionsTable_HealPrediction(updateFunc, groupName, numGroup, subGroup)
	local config = {
		type = "group",
		name = L["Heal Prediction"],
		desc = L["Show an incoming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."],
		get = function(info)
			if subGroup then
				return E.db.unitframe.units[groupName][subGroup].healPrediction[info[#info]]
			else
				return E.db.unitframe.units[groupName].healPrediction[info[#info]]
			end
		end,
		set = function(info, value)
			if subGroup then
				E.db.unitframe.units[groupName][subGroup].healPrediction[info[#info]] = value updateFunc(UF, groupName, numGroup)
			else
				E.db.unitframe.units[groupName].healPrediction[info[#info]] = value updateFunc(UF, groupName, numGroup)
			end
		end,
		guiInline = subGroup and true or false,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"]
			},
			showOverAbsorbs = {
				order = 2,
				type = "toggle",
				name = L["Show Over Absorbs"],
				disabled = function()
					if subGroup then
						return not E.db.unitframe.units[groupName][subGroup].healPrediction.enable
					else
						return not E.db.unitframe.units[groupName].healPrediction.enable
					end
				end
			},
			showAbsorbAmount = {
				order = 3,
				type = "toggle",
				name = L["Show Absorb Amount"],
				disabled = function()
					if subGroup then
						return not E.db.unitframe.units[groupName][subGroup].healPrediction.enable or not E.db.unitframe.units[groupName][subGroup].healPrediction.showOverAbsorbs
					else
						return not E.db.unitframe.units[groupName].healPrediction.enable or not E.db.unitframe.units[groupName].healPrediction.showOverAbsorbs
					end
				end
			},
			colors = {
				order = 4,
				type = "execute",
				name = L["COLORS"],
				func = function() ACD:SelectGroup("ElvUI", "unitframe", "generalOptionsGroup", "allColorsGroup", "healPrediction") end,
				disabled = function() return not E.UnitFrames.Initialized end
			}
		}
	}

	return config
end

local function GetOptionsTable_InformationPanel(updateFunc, groupName, numUnits)
	local config = {
		type = "group",
		name = L["Information Panel"],
		get = function(info) return E.db.unitframe.units[groupName].infoPanel[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].infoPanel[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
		args = {
			enable = {
				order = 2,
				type = "toggle",
				name = L["ENABLE"]
			},
			transparent = {
				order = 3,
				type = "toggle",
				name = L["Transparent"]
			},
			height = {
				order = 4,
				type = "range",
				name = L["Height"],
				min = 4, max = 30, step = 1
			}
		}
	}

	return config
end

local function GetOptionsTable_Name(updateFunc, groupName, numUnits, subGroup)
	local config = {
		type = "group",
		name = L["NAME"],
		get = function(info)
			if subGroup then
				return E.db.unitframe.units[groupName][subGroup].name[info[#info]]
			else
				return E.db.unitframe.units[groupName].name[info[#info]]
			end
		end,
		set = function(info, value)
			if subGroup then
				E.db.unitframe.units[groupName][subGroup].name[info[#info]] = value updateFunc(UF, groupName, numUnits)
			else
				E.db.unitframe.units[groupName].name[info[#info]] = value updateFunc(UF, groupName, numUnits)
			end
		end,
		guiInline = subGroup and true or false,
		args = {
			position = {
				order = 1,
				type = "select",
				name = L["Position"],
				values = positionValues
			},
			xOffset = {
				order = 2,
				type = "range",
				name = L["X-Offset"],
				desc = L["Offset position for text."],
				min = -300, max = 300, step = 1
			},
			yOffset = {
				order = 3,
				type = "range",
				name = L["Y-Offset"],
				desc = L["Offset position for text."],
				min = -300, max = 300, step = 1
			},
			attachTextTo = {
				order = 4,
				type = "select",
				name = L["Attach Text To"],
				desc = L["The object you want to attach to."],
				values = attachToValues
			},
			text_format = {
				order = 5,
				type = "input",
				name = L["Text Format"],
				desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
				width = "full"
			}
		}
	}

	return config
end

local function GetOptionsTable_PhaseIndicator(updateFunc, groupName, numGroup)
	local config = {
		type = "group",
		name = L["Phase Indicator"],
		get = function(info) return E.db.unitframe.units[groupName].phaseIndicator[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].phaseIndicator[info[#info]] = value updateFunc(UF, groupName, numGroup) end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"]
			},
			scale = {
				order = 2,
				type = "range",
				name = L["Scale"],
				isPercent = true,
				min = 0.5, max = 1.5, step = 0.01,
				disabled = function() return not E.db.unitframe.units[groupName].phaseIndicator.enable end
			},
			color = {
				order = 3,
				type = "color",
				name = L["COLOR"],
				get = function(info)
					local t = E.db.unitframe.units[groupName].phaseIndicator[info[#info]]
					local d = P.unitframe.units[groupName].phaseIndicator[info[#info]]
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					local t = E.db.unitframe.units[groupName].phaseIndicator[info[#info]]
					t.r, t.g, t.b = r, g, b
					updateFunc(UF, groupName)
				end,
				disabled = function() return not E.db.unitframe.units[groupName].phaseIndicator.enable end
			},
			anchorPoint = {
				order = 4,
				type = "select",
				name = L["Anchor Point"],
				values = positionValues,
				disabled = function() return not E.db.unitframe.units[groupName].phaseIndicator.enable end
			},
			xOffset = {
				order = 5,
				type = "range",
				name = L["X-Offset"],
				min = -100, max = 100, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].phaseIndicator.enable end
			},
			yOffset = {
				order = 6,
				type = "range",
				name = L["Y-Offset"],
				min = -100, max = 100, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].phaseIndicator.enable end
			}
		}
	}

	return config
end

local function GetOptionsTable_Portrait(updateFunc, groupName, numUnits)
	local config = {
		type = "group",
		name = L["Portrait"],
		get = function(info) return E.db.unitframe.units[groupName].portrait[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].portrait[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
		args = {
			warning = {
				order = 1,
				type = "description",
				fontSize = "medium",
				width = "full",
				name = function() return (E.db.unitframe.units[groupName].orientation == "MIDDLE" and L["Overlay mode is forced when the Frame Orientation is set to Middle."]) or "" end
			},
			enable = {
				order = 2,
				type = "toggle",
				name = L["ENABLE"],
				desc = L["If you have a lot of 3D Portraits active then it will likely have a big impact on your FPS. Disable some portraits if you experience FPS issues."],
				confirmText = L["If you have a lot of 3D Portraits active then it will likely have a big impact on your FPS. Disable some portraits if you experience FPS issues."],
				confirm = function() return not E.db.unitframe.units[groupName].portrait.enable end
			},
			spacer = {
				order = 3,
				type = "description",
				name = ""
			},
			overlay = {
				order = 4,
				type = "toggle",
				name = L["Overlay"],
				desc = L["The Portrait will overlay the Healthbar. This will be automatically happen if the Frame Orientation is set to Middle."],
				get = function(info) return (E.db.unitframe.units[groupName].orientation == "MIDDLE") or E.db.unitframe.units[groupName].portrait[info[#info]] end,
				disabled = function() return not E.db.unitframe.units[groupName].portrait.enable or E.db.unitframe.units[groupName].orientation == "MIDDLE" end
			},
			fullOverlay = {
				order = 5,
				type = "toggle",
				name = L["Full Overlay"],
				desc = L["This option allows the overlay to span the whole health, including the background."],
				disabled = function() return not E.db.unitframe.units[groupName].portrait.enable or (not E.db.unitframe.units[groupName].portrait.overlay and E.db.unitframe.units[groupName].orientation ~= "MIDDLE") end
			},
			style = {
				order = 6,
				type = "select",
				name = L["Style"],
				desc = L["Select the display method of the portrait."],
				values = {
					["2D"] = L["2D"],
					["3D"] = L["3D"]
				},
				disabled = function() return not E.db.unitframe.units[groupName].portrait.enable end
			},
			width = {
				order = 7,
				type = "range",
				name = L["Width"],
				min = 15, max = 150, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].portrait.enable or E.db.unitframe.units[groupName].orientation == "MIDDLE" or E.db.unitframe.units[groupName].portrait.overlay end
			},
			overlayAlpha = {
				order = 8,
				type = "range",
				name = L["Overlay Alpha"],
				desc = L["Set the alpha level of portrait when frame is overlayed."],
				min = 0.01, max = 1, step = 0.01,
				disabled = function() return not E.db.unitframe.units[groupName].portrait.enable or (not E.db.unitframe.units[groupName].portrait.overlay and E.db.unitframe.units[groupName].orientation ~= "MIDDLE") end
			},
			rotation = {
				order = 9,
				type = "range",
				name = L["Model Rotation"],
				min = 0, max = 360, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].portrait.enable or E.db.unitframe.units[groupName].portrait.style ~= "3D" end
			},
			camDistanceScale = {
				order = 10,
				type = "range",
				name = L["Camera Distance Scale"],
				desc = L["How far away the portrait is from the camera."],
				min = 0.01, max = 4, step = 0.01,
				disabled = function() return not E.db.unitframe.units[groupName].portrait.enable or E.db.unitframe.units[groupName].portrait.style ~= "3D" end
			},
			xOffset = {
				order = 11,
				type = "range",
				name = L["X-Offset"],
				desc = L["Position the Model horizontally."],
				min = -1, max = 1, step = 0.01,
				disabled = function() return not E.db.unitframe.units[groupName].portrait.enable or E.db.unitframe.units[groupName].portrait.style ~= "3D" end
			},
			yOffset = {
				order = 12,
				type = "range",
				name = L["Y-Offset"],
				desc = L["Position the Model vertically."],
				min = -1, max = 1, step = 0.01,
				disabled = function() return not E.db.unitframe.units[groupName].portrait.enable or E.db.unitframe.units[groupName].portrait.style ~= "3D" end
			}
		}
	}

	return config
end

local function GetOptionsTable_Power(hasDetatchOption, updateFunc, groupName, numUnits, hasStrataLevel)
	local config = {
		type = "group",
		name = L["Power"],
		get = function(info) return E.db.unitframe.units[groupName].power[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].power[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
		args = {
			enable = {
				order = 2,
				type = "toggle",
				name = L["ENABLE"]
			},
			attachTextTo = {
				order = 3,
				type = "select",
				name = L["Attach Text To"],
				desc = L["The object you want to attach to."],
				values = attachToValues
			},
			width = {
				order = 4,
				type = "select",
				name = L["Style"],
				values = {
					fill = L["Filled"],
					spaced = L["Spaced"],
					inset = L["Inset"],
					offset = L["Offset"]
				},
				set = function(info, value)
					E.db.unitframe.units[groupName].power[info[#info]] = value

					local frameName = gsub("ElvUF_"..E:StringTitle(groupName), "t(arget)", "T%1")

					if numUnits then
						for i = 1, numUnits do
							local frame = _G[frameName..i]
							if frame and frame.Power then
								local min, max = frame.Power:GetMinMaxValues()
								frame.Power:SetMinMaxValues(min, max + 500)
								frame.Power:SetValue(1)
								frame.Power:SetValue(0)
							end
						end
					else
						local frame = _G[frameName]
						if frame then
							if frame.Power then
								local min, max = frame.Power:GetMinMaxValues()
								frame.Power:SetMinMaxValues(min, max + 500)
								frame.Power:SetValue(1)
								frame.Power:SetValue(0)
							else
								for i = 1, frame:GetNumChildren() do
									local child = select(i, frame:GetChildren())
									if child and child.Power then
										local min, max = child.Power:GetMinMaxValues()
										child.Power:SetMinMaxValues(min, max + 500)
										child.Power:SetValue(1)
										child.Power:SetValue(0)
									end
								end
							end
						end
					end

					updateFunc(UF, groupName, numUnits)
				end
			},
			height = {
				order = 5,
				type = "range",
				name = L["Height"],
				min = ((E.db.unitframe.thinBorders or E.PixelMode) and 3 or 7), max = 50, step = 1,
				hidden = function() return E.db.unitframe.units[groupName].power.width == "offset" end
			},
			offset = {
				order = 6,
				type = "range",
				name = L["Offset"],
				desc = L["Offset of the powerbar to the healthbar, set to 0 to disable."],
				min = 0, max = 20, step = 1,
				hidden = function() return E.db.unitframe.units[groupName].power.width ~= "offset" end
			},
			reverseFill = {
				order = 7,
				type = "toggle",
				name = L["Reverse Fill"]
			},
			configureButton = {
				order = 8,
				type = "execute",
				name = L["Coloring"],
				desc = L["This opens the UnitFrames Color settings. These settings affect all unitframes."],
				func = function() ACD:SelectGroup("ElvUI", "unitframe", "generalOptionsGroup", "allColorsGroup", "powerGroup") end,
			},
			textGroup = {
				type = "group",
				name = L["Text Options"],
				guiInline = true,
				args = {
					position = {
						order = 1,
						type = "select",
						name = L["Position"],
						values = positionValues
					},
					xOffset = {
						order = 2,
						type = "range",
						name = L["X-Offset"],
						desc = L["Offset position for text."],
						min = -300, max = 300, step = 1
					},
					yOffset = {
						order = 3,
						type = "range",
						name = L["Y-Offset"],
						desc = L["Offset position for text."],
						min = -300, max = 300, step = 1
					},
					text_format = {
						order = 4,
						type = "input",
						name = L["Text Format"],
						desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
						width = "full"
					}
				}
			}
		}
	}

	if hasDetatchOption then
		config.args.detachFromFrame = {
			order = 90,
			type = "toggle",
			name = L["Detach From Frame"]
		}
		config.args.autoHide = {
			order = 91,
			type = "toggle",
			name = L["Auto Hide"],
			hidden = function() return not E.db.unitframe.units[groupName].power.detachFromFrame end
		}
		config.args.detachedWidth = {
			order = 92,
			type = "range",
			name = L["Detached Width"],
			hidden = function() return not E.db.unitframe.units[groupName].power.detachFromFrame end,
			min = 15, max = 1000, step = 1
		}
		config.args.parent = {
			order = 93,
			type = "select",
			name = L["Parent"],
			desc = L["Choose UIPARENT to prevent it from hiding with the unitframe."],
			hidden = function() return not E.db.unitframe.units[groupName].power.detachFromFrame end,
			values = {
				FRAME = L["Frame"],
				UIPARENT = "UIPARENT"
			}
		}
	end

	if hasStrataLevel then
		config.args.strataAndLevel = {
			order = 100,
			type = "group",
			name = L["Strata and Level"],
			get = function(info) return E.db.unitframe.units[groupName].power.strataAndLevel[info[#info]] end,
			set = function(info, value) E.db.unitframe.units[groupName].power.strataAndLevel[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
			guiInline = true,
			args = {
				useCustomStrata = {
					order = 1,
					type = "toggle",
					name = L["Use Custom Strata"]
				},
				frameStrata = {
					order = 2,
					type = "select",
					name = L["Frame Strata"],
					values = C.Values.Strata
				},
				spacer = {
					order = 3,
					type = "description",
					name = ""
				},
				useCustomLevel = {
					order = 4,
					type = "toggle",
					name = L["Use Custom Level"]
				},
				frameLevel = {
					order = 5,
					type = "range",
					name = L["Frame Level"],
					min = 2, max = 128, step = 1
				}
			}
		}
	end

	return config
end

local function GetOptionsTable_PVPIcon(updateFunc, groupName, numGroup)
	local config = {
		type = "group",
		name = L["PvP Icon"],
		get = function(info) return E.db.unitframe.units[groupName].pvpIcon[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].pvpIcon[info[#info]] = value updateFunc(UF, groupName, numGroup) end,
		args = {
			enable = {
				order = 2,
				type = "toggle",
				name = L["ENABLE"]
			},
			scale = {
				order = 3,
				type = "range",
				name = L["Scale"],
				isPercent = true,
				min = 0.1, max = 2, step = 0.01
			},
			spacer = {
				order = 4,
				type = "description",
				name = " "
			},
			anchorPoint = {
				order = 5,
				type = "select",
				name = L["Anchor Point"],
				values = positionValues
			},
			xOffset = {
				order = 6,
				type = "range",
				name = L["X-Offset"],
				min = -100, max = 100, step = 1
			},
			yOffset = {
				order = 7,
				type = "range",
				name = L["Y-Offset"],
				min = -100, max = 100, step = 1
			}
		}
	}

	return config
end

local function GetOptionsTable_RaidDebuff(updateFunc, groupName)
	local config = {
		type = "group",
		name = L["RaidDebuff Indicator"],
		get = function(info) return E.db.unitframe.units[groupName].rdebuffs[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].rdebuffs[info[#info]] = value updateFunc(UF, groupName) end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"]
			},
			showDispellableDebuff = {
				order = 2,
				type = "toggle",
				name = L["Show Dispellable Debuffs"]
			},
			onlyMatchSpellID = {
				order = 3,
				type = "toggle",
				name = L["Only Match SpellID"],
				desc = L["When enabled it will only show spells that were added to the filter using a spell ID and not a name."]
			},
			size = {
				order = 4,
				type = "range",
				name = L["Size"],
				min = 8, max = 100, step = 1
			},
			xOffset = {
				order = 5,
				type = "range",
				name = L["X-Offset"],
				min = -300, max = 300, step = 1
			},
			yOffset = {
				order = 6,
				type = "range",
				name = L["Y-Offset"],
				min = -300, max = 300, step = 1
			},
			font = {
				order = 7,
				type = "select", dialogControl = "LSM30_Font",
				name = L["Font"],
				values = AceGUIWidgetLSMlists.font
			},
			fontSize = {
				order = 8,
				type = "range",
				name = L["FONT_SIZE"],
				min = 7, max = 22, step = 1
			},
			fontOutline = {
				order = 9,
				type = "select",
				name = L["Font Outline"],
				values = C.Values.FontFlags
			},
			configureButton = {
				order = 10,
				type = "execute",
				name = L["Configure Auras"],
				func = function() E:SetToFilterConfig("RaidDebuffs") end
			},
			duration = {
				order = 11,
				type = "group",
				guiInline = true,
				name = L["Duration Text"],
				get = function(info) return E.db.unitframe.units[groupName].rdebuffs.duration[info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName].rdebuffs.duration[info[#info]] = value updateFunc(UF, groupName) end,
				args = {
					position = {
						order = 1,
						type = "select",
						name = L["Position"],
						values = positionValues
					},
					xOffset = {
						order = 2,
						type = "range",
						name = L["X-Offset"],
						min = -10, max = 10, step = 1
					},
					yOffset = {
						order = 3,
						type = "range",
						name = L["Y-Offset"],
						min = -10, max = 10, step = 1
					},
					color = {
						order = 4,
						type = "color",
						name = L["COLOR"],
						hasAlpha = true,
						get = function(info)
							local c = E.db.unitframe.units.raid.rdebuffs.duration.color
							local d = P.unitframe.units.raid.rdebuffs.duration.color
							return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a
						end,
						set = function(info, r, g, b, a)
							local c = E.db.unitframe.units.raid.rdebuffs.duration.color
							c.r, c.g, c.b, c.a = r, g, b, a
							UF:CreateAndUpdateHeaderGroup("raid")
						end
					}
				}
			},
			stack = {
				order = 12,
				type = "group",
				guiInline = true,
				name = L["Stack Counter"],
				get = function(info) return E.db.unitframe.units[groupName].rdebuffs.stack[info[#info]] end,
				set = function(info, value) E.db.unitframe.units[groupName].rdebuffs.stack[info[#info]] = value updateFunc(UF, groupName) end,
				args = {
					position = {
						order = 1,
						type = "select",
						name = L["Position"],
						values = positionValues
					},
					xOffset = {
						order = 2,
						type = "range",
						name = L["X-Offset"],
						min = -10, max = 10, step = 1
					},
					yOffset = {
						order = 3,
						type = "range",
						name = L["Y-Offset"],
						min = -10, max = 10, step = 1
					},
					color = {
						order = 4,
						type = "color",
						name = L["COLOR"],
						hasAlpha = true,
						get = function(info)
							local c = E.db.unitframe.units[groupName].rdebuffs.stack.color
							local d = P.unitframe.units[groupName].rdebuffs.stack.color
							return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a
						end,
						set = function(info, r, g, b, a)
							local c = E.db.unitframe.units[groupName].rdebuffs.stack.color
							c.r, c.g, c.b, c.a = r, g, b, a
							updateFunc(UF, groupName)
						end
					}
				}
			}
		}
	}

	return config
end

local function GetOptionsTable_RaidIcon(updateFunc, groupName, numUnits, subGroup)
	local config = {
		type = "group",
		name = L["Target Marker Icon"],
		get = function(info)
			if subGroup then
				return E.db.unitframe.units[groupName][subGroup].raidicon[info[#info]]
			else
				return E.db.unitframe.units[groupName].raidicon[info[#info]]
			end
		end,
		set = function(info, value)
			if subGroup then
				E.db.unitframe.units[groupName][subGroup].raidicon[info[#info]] = value updateFunc(UF, groupName, numUnits)
			else
				E.db.unitframe.units[groupName].raidicon[info[#info]] = value updateFunc(UF, groupName, numUnits)
			end
		end,
		guiInline = subGroup and true or false,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
			},
			attachTo = {
				order = 2,
				type = "select",
				name = L["Position"],
				values = positionValues,
				disabled = function()
					if subGroup then
						return not E.db.unitframe.units[groupName][subGroup].raidicon.enable
					else
						return not E.db.unitframe.units[groupName].raidicon.enable
					end
				end
			},
			attachToObject = {
				order = 3,
				type = "select",
				name = L["Attach To"],
				desc = L["The object you want to attach to."],
				values = attachToValues,
				disabled = function()
					if subGroup then
						return not E.db.unitframe.units[groupName][subGroup].raidicon.enable
					else
						return not E.db.unitframe.units[groupName].raidicon.enable
					end
				end
			},
			size = {
				order = 4,
				type = "range",
				name = L["Size"],
				min = 8, max = 60, step = 1,
				disabled = function()
					if subGroup then
						return not E.db.unitframe.units[groupName][subGroup].raidicon.enable
					else
						return not E.db.unitframe.units[groupName].raidicon.enable
					end
				end
			},
			xOffset = {
				order = 5,
				type = "range",
				name = L["X-Offset"],
				min = -300, max = 300, step = 1,
				disabled = function()
					if subGroup then
						return not E.db.unitframe.units[groupName][subGroup].raidicon.enable
					else
						return not E.db.unitframe.units[groupName].raidicon.enable
					end
				end
			},
			yOffset = {
				order = 6,
				type = "range",
				name = L["Y-Offset"],
				min = -300, max = 300, step = 1,
				disabled = function()
					if subGroup then
						return not E.db.unitframe.units[groupName][subGroup].raidicon.enable
					else
						return not E.db.unitframe.units[groupName].raidicon.enable
					end
				end
			}
		}
	}

	return config
end

local function GetOptionsTable_RoleIcons(updateFunc, groupName, numGroup)
	local config = {
		type = "group",
		name = L["Role Icon"],
		get = function(info) return E.db.unitframe.units[groupName].roleIcon[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].roleIcon[info[#info]] = value updateFunc(UF, groupName, numGroup) end,
		args = {
			enable = {
				order = 2,
				type = "toggle",
				name = L["ENABLE"]
			},
			position = {
				order = 3,
				type = "select",
				name = L["Position"],
				values = positionValues
			},
			attachTo = {
				order = 4,
				type = "select",
				name = L["Attach To"],
				desc = L["The object you want to attach to."],
				values = attachToValues
			},
			xOffset = {
				order = 5,
				type = "range",
				name = L["X-Offset"],
				min = -300, max = 300, step = 1
			},
			yOffset = {
				order = 6,
				type = "range",
				name = L["Y-Offset"],
				min = -300, max = 300, step = 1
			},
			size = {
				order = 7,
				type = "range",
				name = L["Size"],
				min = 4, max = 100, step = 1
			},
			tank = {
				order = 8,
				type = "toggle",
				name = L["Show For Tanks"]
			},
			healer = {
				order = 9,
				type = "toggle",
				name = L["Show For Healers"]
			},
			damager = {
				order = 10,
				type = "toggle",
				name = L["Show For DPS"]
			},
			combatHide = {
				order = 11,
				type = "toggle",
				name = L["Hide In Combat"]
			}
		}
	}

	return config
end

local function GetOptionsTable_RaidRoleIcons(updateFunc, groupName, numGroup)
	local config = {
		type = "group",
		name = L["RL / ML Icons"],
		get = function(info) return E.db.unitframe.units[groupName].raidRoleIcons[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].raidRoleIcons[info[#info]] = value updateFunc(UF, groupName, numGroup) end,
		args = {
			enable = {
				order = 2,
				type = "toggle",
				name = L["ENABLE"]
			},
			position = {
				order = 3,
				type = "select",
				name = L["Position"],
				values = {
					LEFT = L["Left"],
					RIGHT = L["Right"],
					TOPLEFT = L["Top Left"],
					TOPRIGHT = L["Top Right"]
				},
				disabled = function() return not E.db.unitframe.units[groupName].raidRoleIcons.enable end
			},
			xOffset = {
				order = 4,
				type = "range",
				name = L["X-Offset"],
				min = -300, max = 300, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].raidRoleIcons.enable end
			},
			yOffset = {
				order = 5,
				type = "range",
				name = L["Y-Offset"],
				min = -300, max = 300, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].raidRoleIcons.enable end
			}
		}
	}

	return config
end

local function GetOptionsTable_ReadyCheckIcon(updateFunc, groupName)
	local config = {
		type = "group",
		name = L["Ready Check Icon"],
		get = function(info) return E.db.unitframe.units[groupName].readycheckIcon[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].readycheckIcon[info[#info]] = value updateFunc(UF, groupName) end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"]
			},
			position = {
				order = 2,
				type = "select",
				name = L["Position"],
				values = positionValues,
				disabled = function() return not E.db.unitframe.units[groupName].readycheckIcon.enable end
			},
			attachTo = {
				order = 3,
				type = "select",
				name = L["Attach To"],
				desc = L["The object you want to attach to."],
				values = attachToValues,
				disabled = function() return not E.db.unitframe.units[groupName].readycheckIcon.enable end
			},
			size = {
				order = 4,
				type = "range",
				name = L["Size"],
				min = 8, max = 60, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].readycheckIcon.enable end
			},
			xOffset = {
				order = 5,
				type = "range",
				name = L["X-Offset"],
				min = -300, max = 300, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].readycheckIcon.enable end
			},
			yOffset = {
				order = 6,
				type = "range",
				name = L["Y-Offset"],
				min = -300, max = 300, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].readycheckIcon.enable end
			}
		}
	}

	return config
end

local function GetOptionsTable_ResurrectIcon(updateFunc, groupName, numUnits)
	local config = {
		type = "group",
		name = L["Resurrect Icon"],
		get = function(info) return E.db.unitframe.units[groupName].resurrectIcon[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].resurrectIcon[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
		args = {
			enable = {
				order = 2,
				type = "toggle",
				name = L["ENABLE"]
			},
			attachTo = {
				order = 3,
				type = "select",
				name = L["Position"],
				values = positionValues,
				disabled = function() return not E.db.unitframe.units[groupName].resurrectIcon.enable end
			},
			attachToObject = {
				order = 4,
				type = "select",
				name = L["Attach To"],
				desc = L["The object you want to attach to."],
				values = attachToValues,
				disabled = function() return not E.db.unitframe.units[groupName].resurrectIcon.enable end
			},
			size = {
				order = 5,
				type = "range",
				name = L["Size"],
				min = 8, max = 60, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].resurrectIcon.enable end
			},
			xOffset = {
				order = 6,
				type = "range",
				name = L["X-Offset"],
				min = -300, max = 300, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].resurrectIcon.enable end
			},
			yOffset = {
				order = 7,
				type = "range",
				name = L["Y-Offset"],
				min = -300, max = 300, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].resurrectIcon.enable end
			}
		}
	}

	return config
end

local function GetOptionsTable_ClassBar(updateFunc, groupName, numUnits)
	local config = {
		type = "group",
		name = L["Classbar"],
		get = function(info) return E.db.unitframe.units[groupName].classbar[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].classbar[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"]
			},
			spacer = {
				order = 2,
				type = "description",
				name = ""
			},
			height = {
				order = 3,
				type = "range",
				name = L["Height"],
				min = 2, max = 30, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].classbar.enable end
			},
			fill = {
				order = 4,
				type = "select",
				name = L["Fill"],
				values = {
					fill = L["Filled"],
					spaced = L["Spaced"]
				},
				disabled = function() return not E.db.unitframe.units[groupName].classbar.enable end
			}
		}
	}

	if groupName == "party" or groupName == "raid" or groupName == "raid40" or groupName == "boss" then
		config.name = L["Alternative Power"]
		config.args.altPowerColor = {
			order = 5,
			type = "color",
			name = L["COLOR"],
			get = function(info)
				local t = E.db.unitframe.units[groupName].classbar[info[#info]]
				local d = P.unitframe.units[groupName].classbar[info[#info]]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b
			end,
			set = function(info, r, g, b)
				local t = E.db.unitframe.units[groupName].classbar[info[#info]]
				t.r, t.g, t.b = r, g, b
				UF:Update_AllFrames()
			end,
			disabled = function() return not E.db.unitframe.units[groupName].classbar.enable end
		}
		config.args.altPowerTextFormat = {
			order = 6,
			type = "input",
			name = L["Text Format"],
			desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
			width = "full",
			disabled = function() return not E.db.unitframe.units[groupName].classbar.enable end
		}
	elseif groupName == "player" then
		config.args.height.max = (E.db.unitframe.units[groupName].classbar.detachFromFrame and 300 or 30)
		config.args.autoHide = {
			order = 5,
			type = "toggle",
			name = L["Auto Hide"],
			disabled = function() return not E.db.unitframe.units[groupName].classbar.enable end
		}
		config.args.detachGroup = {
			order = 6,
			type = "group",
			name = L["Detach From Frame"],
			get = function(info) return E.db.unitframe.units.player.classbar[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.player.classbar[info[#info]] = value UF:CreateAndUpdateUF("player") end,
			guiInline = true,
			args = {
				detachFromFrame = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"],
					width = "full",
					set = function(info, value)
						E.Options.args.unitframe.args.individualUnits.args.player.args.classbar.args.height.max = (value and 300) or 30
						E.db.unitframe.units.player.classbar[info[#info]] = value
						UF:CreateAndUpdateUF("player")
					end,
					disabled = function() return not E.db.unitframe.units.player.classbar.enable end
				},
				detachedWidth = {
					order = 2,
					type = "range",
					name = L["Detached Width"],
					min = ((E.db.unitframe.thinBorders or E.PixelMode) and 3 or 7), max = 800, step = 1,
					disabled = function() return not E.db.unitframe.units.player.classbar.enable or not E.db.unitframe.units.player.classbar.detachFromFrame end
				},
				orientation = {
					order = 3,
					type = "select",
					name = L["Frame Orientation"],
					values = {
						HORIZONTAL = L["Horizontal"],
						VERTICAL = L["Vertical"]
					},
					disabled = function()
						return E.db.unitframe.units.player.classbar.fill and (E.db.unitframe.units.player.classbar.fill == "fill")
						or not E.db.unitframe.units.player.classbar.detachFromFrame
						or not E.db.unitframe.units.player.classbar.enable
					end
				},
				verticalOrientation = {
					order = 4,
					type = "toggle",
					name = L["Vertical Fill Direction"],
					disabled = function() return not E.db.unitframe.units.player.classbar.enable or not E.db.unitframe.units.player.classbar.detachFromFrame end
				},
				spacing = {
					order = 5,
					type = "range",
					name = L["Spacing"],
					min = ((E.db.unitframe.thinBorders or E.PixelMode) and -1 or -4), max = 20, step = 1,
					disabled = function()
						return E.db.unitframe.units.player.classbar.fill and (E.db.unitframe.units.player.classbar.fill == "fill")
						or not E.db.unitframe.units.player.classbar.detachFromFrame
						or not E.db.unitframe.units.player.classbar.enable
					end
				},
				parent = {
					order = 6,
					type = "select",
					name = L["Parent"],
					desc = L["Choose UIPARENT to prevent it from hiding with the unitframe."],
					values = {
						FRAME = L["Frame"],
						UIPARENT = "UIPARENT"
					},
					disabled = function() return not E.db.unitframe.units.player.classbar.enable or not E.db.unitframe.units.player.classbar.detachFromFrame end
				}
			}
		}
		config.args.strataAndLevel = {
			order = 7,
			type = "group",
			name = L["Strata and Level"],
			get = function(info) return E.db.unitframe.units.player.classbar.strataAndLevel[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.player.classbar.strataAndLevel[info[#info]] = value UF:CreateAndUpdateUF("player") end,
			guiInline = true,
			disabled = function() return not E.db.unitframe.units.player.classbar.detachFromFrame end,
			hidden = function() return not E.db.unitframe.units.player.classbar.detachFromFrame end,
			args = {
				useCustomStrata = {
					order = 1,
					type = "toggle",
					name = L["Use Custom Strata"],
					disabled = function() return not E.db.unitframe.units.player.classbar.enable end
				},
				frameStrata = {
					order = 2,
					type = "select",
					name = L["Frame Strata"],
					values = C.Values.Strata,
					disabled = function() return not E.db.unitframe.units.player.classbar.enable end
				},
				spacer = {
					order = 3,
					type = "description",
					name = ""
				},
				useCustomLevel = {
					order = 4,
					type = "toggle",
					name = L["Use Custom Level"],
					disabled = function() return not E.db.unitframe.units.player.classbar.enable end
				},
				frameLevel = {
					order = 5,
					type = "range",
					name = L["Frame Level"],
					min = 2, max = 128, step = 1,
					disabled = function() return not E.db.unitframe.units.player.classbar.enable end
				}
			}
		}
	end

	return config
end

local function GetOptionsTable_ComboBar(updateFunc, groupName)
	local config = {
		type = "group",
		name = L["COMBO_POINTS"],
		get = function(info) return E.db.unitframe.units[groupName].combobar[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].combobar[info[#info]] = value updateFunc(UF, groupName) end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"]
			},
			height = {
				order = 2,
				type = "range",
				name = L["Height"],
				min = ((E.db.unitframe.thinBorders or E.PixelMode) and 3 or 7),
				max = (E.db.unitframe.units[groupName].combobar.detachFromFrame and 300 or 30),
				step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].combobar.enable end
			},
			fill = {
				order = 3,
				type = "select",
				name = L["Fill"],
				values = {
					fill = L["Filled"],
					spaced = L["Spaced"]
				},
				disabled = function() return not E.db.unitframe.units[groupName].combobar.enable end
			},
			autoHide = {
				order = 4,
				type = "toggle",
				name = L["Auto Hide"],
				disabled = function() return not E.db.unitframe.units[groupName].combobar.enable end
			},
			detachGroup = {
				order = 5,
				type = "group",
				name = L["Detach From Frame"],
				get = function(info) return E.db.unitframe.units[groupName].combobar[info[#info]] end,
				set = function(info, value)
					E.db.unitframe.units[groupName].combobar[info[#info]] = value
					updateFunc(UF, groupName)
				end,
				guiInline = true,
				args = {
					detachFromFrame = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
						width = "full",
						set = function(info, value)
							if value == true then
								E.Options.args.unitframe.args.individualUnits.args.target.args.combobar.args.height.max = 300
							else
								E.Options.args.unitframe.args.individualUnits.args.target.args.combobar.args.height.max = 30
							end
							E.db.unitframe.units[groupName].combobar[info[#info]] = value
							updateFunc(UF, groupName)
						end,
						disabled = function() return not E.db.unitframe.units[groupName].combobar.enable end
					},
					detachedWidth = {
						order = 2,
						type = "range",
						name = L["Detached Width"],
						disabled = function() return not E.db.unitframe.units[groupName].combobar.detachFromFrame or not E.db.unitframe.units[groupName].combobar.enable end,
						min = ((E.db.unitframe.thinBorders or E.PixelMode) and 3 or 7), max = 800, step = 1
					},
					spacing = {
						order = 3,
						type = "range",
						name = L["Spacing"],
						min = ((E.db.unitframe.thinBorders or E.PixelMode) and -1 or -4), max = 20, step = 1,
						disabled = function()
							return (E.db.unitframe.units[groupName].combobar.fill and (E.db.unitframe.units[groupName].combobar.fill == "fill"))
							or not E.db.unitframe.units[groupName].combobar.detachFromFrame
							or not E.db.unitframe.units[groupName].combobar.enable
						end
					},
					orientation = {
						order = 4,
						type = "select",
						name = L["Frame Orientation"],
						values = {
							HORIZONTAL = L["Horizontal"],
							VERTICAL = L["Vertical"]
						},
						disabled = function()
							return (E.db.unitframe.units[groupName].combobar.fill and (E.db.unitframe.units[groupName].combobar.fill == "fill"))
							or not E.db.unitframe.units[groupName].combobar.detachFromFrame
							or not E.db.unitframe.units[groupName].combobar.enable
						end
					},
					parent = {
						order = 5,
						type = "select",
						name = L["Parent"],
						desc = L["Choose UIPARENT to prevent it from hiding with the unitframe."],
						disabled = function() return not E.db.unitframe.units[groupName].combobar.detachFromFrame or not E.db.unitframe.units[groupName].combobar.enable end,
						values = {
							FRAME = L["Frame"],
							UIPARENT = "UIPARENT"
						}
					},
					strataAndLevel = {
						order = 6,
						type = "group",
						name = L["Strata and Level"],
						get = function(info) return E.db.unitframe.units[groupName].combobar.strataAndLevel[info[#info]] end,
						set = function(info, value) E.db.unitframe.units[groupName].combobar.strataAndLevel[info[#info]] = value updateFunc(UF, groupName) end,
						guiInline = true,
						disabled = function() return not E.db.unitframe.units[groupName].combobar.detachFromFrame end,
						hidden = function() return not E.db.unitframe.units[groupName].combobar.detachFromFrame end,
						args = {
							useCustomStrata = {
								order = 1,
								type = "toggle",
								name = L["Use Custom Strata"],
								disabled = function() return not E.db.unitframe.units[groupName].combobar.enable end
							},
							frameStrata = {
								order = 2,
								type = "select",
								name = L["Frame Strata"],
								values = C.Values.Strata,
								disabled = function() return not E.db.unitframe.units[groupName].combobar.enable end
							},
							spacer = {
								order = 3,
								type = "description",
								name = ""
							},
							useCustomLevel = {
								order = 4,
								type = "toggle",
								name = L["Use Custom Level"],
								disabled = function() return not E.db.unitframe.units[groupName].combobar.enable end
							},
							frameLevel = {
								order = 5,
								type = "range",
								name = L["Frame Level"],
								min = 2, max = 128, step = 1,
								disabled = function() return not E.db.unitframe.units[groupName].combobar.enable end
							}
						}
					}
				}
			}
		}
	}

	return config
end

local function GetOptionsTable_CombatIconGroup(updateFunc, groupName, numUnits)
	local config = {
		type = "group",
		name = L["Combat Icon"],
		get = function(info) return E.db.unitframe.units[groupName].CombatIcon[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].CombatIcon[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"]
			},
			defaultColor = {
				order = 2,
				type = "toggle",
				name = L["Default Color"]
			},
			color = {
				order = 3,
				type = "color",
				name = L["COLOR"],
				hasAlpha = true,
				disabled = function()
					return E.db.unitframe.units[groupName].CombatIcon.defaultColor
				end,
				get = function()
					local c = E.db.unitframe.units[groupName].CombatIcon.color
					local d = P.unitframe.units[groupName].CombatIcon.color
					return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a
				end,
				set = function(_, r, g, b, a)
					local c = E.db.unitframe.units[groupName].CombatIcon.color
					c.r, c.g, c.b, c.a = r, g, b, a
					updateFunc(UF, groupName, numUnits)
				end
			},
			size = {
				order = 4,
				type = "range",
				name = L["Size"],
				min = 10, max = 60, step = 1
			},
			xOffset = {
				order = 5,
				type = "range",
				name = L["X-Offset"],
				min = -100, max = 100, step = 1
			},
			yOffset = {
				order = 6,
				type = "range",
				name = L["Y-Offset"],
				min = -100, max = 100, step = 1
			},
			spacer2 = {
				order = 7,
				type = "description",
				name = " "
			},
			anchorPoint = {
				order = 8,
				type = "select",
				name = L["Anchor Point"],
				values = positionValues
			},
			texture = {
				order = 9,
				type = "select",
				sortByValue = true,
				name = L["Texture"],
				values = {
					CUSTOM = L["CUSTOM"],
					DEFAULT = L["DEFAULT"],
					COMBAT = E:TextureString(E.Media.Textures.Combat, ":14"),
					PLATINUM = [[|TInterface\Challenges\ChallengeMode_Medal_Platinum:14|t]],
					ATTACK = [[|TInterface\CURSOR\Attack:14|t]],
					ALERT = [[|TInterface\DialogFrame\UI-Dialog-Icon-AlertNew:14|t]],
					ALERT2 = [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:14|t]],
					ARTHAS =[[|TInterface\LFGFRAME\UI-LFR-PORTRAIT:14|t]],
					SKULL = [[|TInterface\LootFrame\LootPanel-Icon:14|t]]
				}
			},
			customTexture = {
				order = 10,
				type = "input",
				customWidth = 250,
				name = L["Custom Texture"],
				disabled = function()
					return E.db.unitframe.units[groupName].CombatIcon.texture ~= "CUSTOM"
				end,
				set = function(_, value)
					E.db.unitframe.units[groupName].CombatIcon.customTexture = (value and (not value:match("^%s-$")) and value) or nil
					updateFunc(UF, groupName, numUnits)
				end
			}
		}
	}

	return config
end

local function GetOptionsTable_StrataAndFrameLevel(updateFunc, groupName, numUnits)
	local config = {
		type = "group",
		name = L["Strata and Level"],
		get = function(info) return E.db.unitframe.units[groupName].strataAndLevel[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].strataAndLevel[info[#info]] = value updateFunc(UF, groupName, numUnits) end,
		args = {
			useCustomStrata = {
				order = 1,
				type = "toggle",
				name = L["Use Custom Strata"]
			},
			frameStrata = {
				order = 2,
				type = "select",
				name = L["Frame Strata"],
				values = C.Values.Strata,
				disabled = function() return not E.db.unitframe.units[groupName].strataAndLevel.useCustomStrata end
			},
			spacer = {
				order = 3,
				type = "description",
				name = ""
			},
			useCustomLevel = {
				order = 4,
				type = "toggle",
				name = L["Use Custom Level"]
			},
			frameLevel = {
				order = 5,
				type = "range",
				name = L["Frame Level"],
				min = 2, max = 128, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].strataAndLevel.useCustomLevel end
			}
		}
	}

	return config
end

local function GetOptionsTable_GPS(updateFunc, groupName)
	local config = {
		type = "group",
		name = L["GPS Arrow"],
		get = function(info) return E.db.unitframe.units[groupName].GPSArrow[info[#info]] end,
		set = function(info, value) E.db.unitframe.units[groupName].GPSArrow[info[#info]] = value updateFunc(UF, groupName) end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"]
			},
			spacer = {
				order = 2,
				type = "description",
				name = ""
			},
			onMouseOver = {
				order = 3,
				type = "toggle",
				name = L["Mouseover"],
				desc = L["Only show when you are mousing over a frame."],
				disabled = function() return not E.db.unitframe.units[groupName].GPSArrow.enable end
			},
			outOfRange = {
				order = 4,
				type = "toggle",
				name = L["Out of Range"],
				desc = L["Only show when the unit is not in range."],
				disabled = function() return not E.db.unitframe.units[groupName].GPSArrow.enable end
			},
			color = {
				order = 5,
				type = "color",
				name = L["COLOR"],
				get = function(info)
					local t = E.db.unitframe.units[groupName].GPSArrow[info[#info]]
					local d = P.unitframe.units[groupName].GPSArrow[info[#info]]
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					local t = E.db.unitframe.units[groupName].GPSArrow[info[#info]]
					t.r, t.g, t.b = r, g, b
					updateFunc(UF, groupName)
				end,
				disabled = function() return not E.db.unitframe.units[groupName].GPSArrow.enable end
			},
			size = {
				order = 6,
				type = "range",
				name = L["Size"],
				min = 8, max = 60, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].GPSArrow.enable end
			},
			xOffset = {
				order = 7,
				type = "range",
				name = L["X-Offset"],
				min = -300, max = 300, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].GPSArrow.enable end
			},
			yOffset = {
				order = 8,
				type = "range",
				name = L["Y-Offset"],
				min = -300, max = 300, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName].GPSArrow.enable end
			}
		}
	}

	return config
end

local function GetOptionsTable_GeneralGroup(updateFunc, groupName, numUnits)
	local config = {
		order = 1,
		type = "group",
		name = L["General"],
		args = {
			orientation = {
				order = 1,
				type = "select",
				name = L["Frame Orientation"],
				desc = L["Set the orientation of the UnitFrame."],
				values = orientationValues
			},
			disableMouseoverGlow = {
				order = 4,
				type = "toggle",
				name = L["Block Mouseover Glow"],
				desc = L["Forces Mouseover Glow to be disabled for these frames"]
			},
			disableTargetGlow = {
				order = 5,
				type = "toggle",
				name = L["Block Target Glow"],
				desc = L["Forces Target Glow to be disabled for these frames"]
			},
			disableFocusGlow = {
				order = 6,
				type = "toggle",
				name = L["Block Focus Glow"],
				desc = L["Forces Focus Glow to be disabled for these frames"]
			},
			positionsGroup = {
				order = 9,
				type = "group",
				name = L["Size and Positions"],
				inline = true,
				set = function(info, value) E.db.unitframe.units[groupName][info[#info]] = value updateFunc(UF, groupName, numUnits) end,
				args = {
					width = {
						order = 1,
						type = "range",
						name = L["Width"],
						min = 50, max = 1000, step = 1
					},
					height = {
						order = 2,
						type = "range",
						name = L["Height"],
						min = 10, max = 500, step = 1
					}
				}
			}
		}
	}

	if groupName ~= "party" and groupName ~= "raid" and groupName ~= "raid40" and groupName ~= "raidpet" and groupName ~= "assist" and groupName ~= "tank" then
		config.args.smartAuraPosition = {
			order = 2,
			type = "select",
			name = L["Smart Aura Position"],
			desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
			values = smartAuraPositionValues
		}
	end

	if groupName ~= "arena" then
		config.args.threatStyle = {
			order = 3,
			type = "select",
			name = L["Threat Display Mode"],
			values = threatValues
		}
	end

	if groupName ~= "tank" and groupName ~= "assist" and groupName ~= "raidpet" then
		config.args.hideonnpc = {
			order = 7,
			type = "toggle",
			name = L["Text Toggle On NPC"],
			desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
			get = function() return E.db.unitframe.units[groupName].power.hideonnpc end,
			set = function(_, value) E.db.unitframe.units[groupName].power.hideonnpc = value updateFunc(UF, groupName, numUnits) end
		}
	end

	if groupName == "party" or groupName == "raid" or groupName == "raid40" or groupName == "raidpet" then
		config.args.positionsGroup.args.spacer = {
			order = 3,
			type = "description",
			name = ""
		}
		config.args.positionsGroup.args.growthDirection = {
			order = 4,
			type = "select",
			name = L["Growth Direction"],
			desc = L["Growth direction from the first unitframe."],
			values = C.Values.GrowthDirection
		}
		config.args.positionsGroup.args.numGroups = {
			order = 5,
			type = "range",
			name = L["Number of Groups"],
			min = 1, max = 8, step = 1,
			set = function(info, value)
				E.db.unitframe.units[groupName][info[#info]] = value
				updateFunc(UF, groupName, numUnits)
				if UF[groupName].isForced then
					UF:HeaderConfig(UF[groupName])
					UF:HeaderConfig(UF[groupName], true)
				end
			end
		}
		config.args.positionsGroup.args.groupsPerRowCol = {
			order = 6,
			type = "range",
			name = L["Groups Per Row/Column"],
			min = 1, max = 8, step = 1,
			set = function(info, value)
				E.db.unitframe.units[groupName][info[#info]] = value
				updateFunc(UF, groupName, numUnits)
				if UF[groupName].isForced then
					UF:HeaderConfig(UF[groupName])
					UF:HeaderConfig(UF[groupName], true)
				end
			end
		}
		config.args.positionsGroup.args.horizontalSpacing = {
			order = 7,
			type = "range",
			name = L["Horizontal Spacing"],
			min = -1, max = 50, step = 1
		}
		config.args.positionsGroup.args.verticalSpacing = {
			order = 8,
			type = "range",
			name = L["Vertical Spacing"],
			min = -1, max = 50, step = 1
		}
		config.args.positionsGroup.args.groupSpacing = {
			order = 9,
			type = "range",
			name = L["Group Spacing"],
			desc = L["Additional spacing between each individual group."],
			min = 0, softMax = 50, step = 1
		}
		config.args.visibilityGroup = {
			order = 10,
			type = "group",
			name = L["Visibility"],
			inline = true,
			set = function(info, value) E.db.unitframe.units[groupName][info[#info]] = value updateFunc(UF, groupName, numUnits) end,
			args = {}
		}
		if groupName ~= "raidpet" then
			config.args.visibilityGroup.args.showPlayer = {
				order = 1,
				type = "toggle",
				name = L["Display Player"],
				desc = L["When true, the header includes the player when not in a raid."]
			}
		end
		config.args.visibilityGroup.args.defaults = {
			order = 2,
			type = "execute",
			name = L["Restore Defaults"],
			func = function()
				E.db.unitframe.units[groupName].visibility = P.unitframe.units[groupName].visibility
				updateFunc(UF, groupName, numUnits)
			end
		}
		config.args.visibilityGroup.args.visibility = {
			order = 3,
			type = "input",
			name = L["Visibility"],
			desc = L["VISIBILITY_DESC"],
			width = "full"
		}
		config.args.sortingGroup = {
			order = 11,
			type = "group",
			name = L["Grouping & Sorting"],
			inline = true,
			set = function(info, value) E.db.unitframe.units[groupName][info[#info]] = value updateFunc(UF, groupName, numUnits) end,
			args = {}
		}
		config.args.sortingGroup.args.raidWideSorting = {
			order = 1,
			type = "toggle",
			name = L["Raid-Wide Sorting"],
			desc = L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."]
		}
		config.args.sortingGroup.args.invertGroupingOrder = {
			order = 2,
			type = "toggle",
			name = L["Invert Grouping Order"],
			desc = L["Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from."],
			disabled = function() return not E.db.unitframe.units[groupName].raidWideSorting end
		}
		config.args.sortingGroup.args.startFromCenter = {
			order = 3,
			type = "toggle",
			name = L["Start Near Center"],
			desc = L["The initial group will start near the center and grow out."],
			disabled = function() return not E.db.unitframe.units[groupName].raidWideSorting end
		}
		config.args.sortingGroup.args.groupBy = {
			order = 4,
			type = "select",
			name = L["Group By"],
			desc = L["Set the order that the group will sort."],
			values = groupName == "raidpet" and {NAME = L["Owners Name"], PETNAME = L["Pet Name"], GROUP = L["GROUP"]} or {CLASS = L["CLASS"], ROLE = L["Role"], NAME = L["NAME"], GROUP = L["GROUP"], INDEX = L["Index"]}
		}
		config.args.sortingGroup.args.sortDir = {
			order = 5,
			type = "select",
			name = L["Sort Direction"],
			desc = L["Defines the sort order of the selected sort method."],
			values = {
				ASC = L["Ascending"],
				DESC = L["Descending"]
			}
		}
		config.args.sortingGroup.args.sortMethod = {
			order = 5,
			type = "select",
			name = L["Sort Method"],
			values = {
				NAME = L["NAME"],
				INDEX = L["Index"]
			},
			disabled = function() return E.db.unitframe.units[groupName].groupBy == "INDEX" or E.db.unitframe.units[groupName].groupBy == "NAME" end
		}
		if groupName ~= "raidpet" then
			config.args.sortingGroup.args.roleSetup = {
				order = 6,
				type = "group",
				name = L["Role Order"],
				inline = true,
				disabled = function() return E.db.unitframe.units[groupName].groupBy ~= "ROLE" end,
				args = {}
			}
			config.args.sortingGroup.args.roleSetup.args.ROLE1 = {
				order = 1,
				type = "select",
				name = " ",
				customWidth = 160,
				values = {
					TANK = L["TANK"],
					HEALER = L["HEALER"],
					DAMAGER = L["DAMAGER"]
				}
			}
			config.args.sortingGroup.args.roleSetup.args.ROLE2 = {
				order = 2,
				type = "select",
				name = " ",
				customWidth = 160,
				values = {
					TANK = L["TANK"],
					HEALER = L["HEALER"],
					DAMAGER = L["DAMAGER"]
				}
			}
			config.args.sortingGroup.args.roleSetup.args.ROLE3 = {
				order = 3,
				type = "select",
				name = " ",
				customWidth = 160,
				values = {
					TANK = L["TANK"],
					HEALER = L["HEALER"],
					DAMAGER = L["DAMAGER"]
				}
			}
			config.args.sortingGroup.args.classSetup = {
				order = 7,
				type = "group",
				name = L["Class Order"],
				inline = true,
				hidden = groupName == "raidpet",
				disabled = function() return E.db.unitframe.units[groupName].groupBy ~= "CLASS" end,
				args = {}
			}
			local classTable = {}
			for i = 1, GetNumClasses() do
				local classDisplayName, classTag = GetClassInfo(i)
				classTable[classTag] = classDisplayName
				config.args.sortingGroup.args.classSetup.args["CLASS"..i] = {
					order = i,
					type = "select",
					name = " ",
					customWidth = 160,
					values = classTable
				}
			end
		end
	else
		config.args.positionsGroup.args.width.set = function(info, value)
			if E.db.unitframe.units[groupName].castbar and E.db.unitframe.units[groupName].castbar.width == E.db.unitframe.units[groupName][info[#info]] then
				E.db.unitframe.units[groupName].castbar.width = value
			end
			E.db.unitframe.units[groupName][info[#info]] = value
			updateFunc(UF, groupName, numUnits)
		end

		if groupName == "boss" or groupName == "arena" then
			config.args.positionsGroup.args.spacing = {
				order = 3,
				type = "range",
				name = L["Spacing"],
				min = ((E.db.unitframe.thinBorders or E.PixelMode) and -1 or -4), max = 400, step = 1
			}
			config.args.positionsGroup.args.growthDirection = {
				order = 4,
				type = "select",
				name = L["Growth Direction"],
				values = {
					UP = L["Bottom to Top"],
					DOWN = L["Top to Bottom"],
					LEFT = L["Right to Left"],
					RIGHT = L["Left to Right"]
				}
			}
		end

		if groupName == "tank" or groupName == "assist" then
			config.args.positionsGroup.args.verticalSpacing = {
				order = 3,
				type = "range",
				name = L["Vertical Spacing"],
				min = 0, max = 100, step = 1
			}
		end
	end

	if (groupName == "target" or groupName == "boss" or groupName == "tank" or groupName == "arena" or groupName == "assist") and not IsAddOnLoaded("Clique") then
		config.args.middleClickFocus = {
			order = 8,
			type = "toggle",
			name = L["Middle Click - Set Focus"],
			desc = L["Middle clicking the unit frame will cause your focus to match the unit."]
		}
	end

	return config
end

local filterList = {}
local function modifierList()
	wipe(filterList)

	filterList.NONE = L["NONE"]
	filterList.Blacklist = L["Blacklist"]
	filterList.Whitelist = L["Whitelist"]

	local list = E.global.unitframe.aurafilters
	if list then
		for filter in pairs(list) do
			if not G.unitframe.aurafilters[filter] then
				filterList[filter] = filter
			end
		end
	end

	return filterList
end

E.Options.args.unitframe = {
	order = 2,
	type = "group",
	name = L["UnitFrames"],
	childGroups = "tab",
	get = function(info) return E.db.unitframe[info[#info]] end,
	set = function(info, value) E.db.unitframe[info[#info]] = value end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["UNITFRAME_DESC"],
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["ENABLE"],
			get = function(info) return E.private.unitframe.enable end,
			set = function(info, value) E.private.unitframe.enable = value E:StaticPopup_Show("PRIVATE_RL") end
		},
		generalOptionsGroup = {
			order = 3,
			type = "group",
			name = L["General"],
			childGroups = "tab",
			disabled = function() return not E.UnitFrames.Initialized end,
			args = {
				generalGroup = {
					order = 2,
					type = "group",
					name = L["General"],
					disabled = function() return not E.UnitFrames.Initialized end,
					args = {
						resetFilters = {
							order = 1,
							type = "execute",
							name = L["Reset Aura Filters"],
							func = function(info)
								E:StaticPopup_Show("RESET_UF_AF") --reset unitframe aurafilters
							end
						},
						borderOptions = {
							order = 2,
							type = "execute",
							name = L["Border Options"],
							func = function() ACD:SelectGroup("ElvUI", "general", "media") end
						},
						targetOnMouseDown = {
							order = 3,
							type = "toggle",
							name = L["Target On Mouse-Down"],
							desc = L["Target units on mouse down rather than mouse up. \n\n|cffFF0000Warning: If you are using the addon Clique you may have to adjust your Clique settings when changing this."]
						},
						targetSound = {
							order = 4,
							type = "toggle",
							name = L["Targeting Sound"],
							desc = L["Enable a sound if you select a unit."]
						},
						effectiveGroup = {
							order = 5,
							type = "group",
							guiInline = true,
							name = L["Effective Updates"],
							args = {
								warning = {
									order = 1,
									type = "description",
									fontSize = "medium",
									name = L["|cffFF0000Warning:|r This causes updates to happen at a fraction of a second."].."\n"..
									L["Enabling this has the potential to make updates faster, though setting a speed value that is too high may cause it to actually run slower than the default scheme, which use Blizzard events only with no update loops provided."]
								},
								effectiveHealth = {
									order = 2,
									type = "toggle",
									name = L["HEALTH"],
									get = function(info) return E.global.unitframe[info[#info]] end,
									set = function(info, value) E.global.unitframe[info[#info]] = value UF:Update_AllFrames() end
								},
								effectivePower = {
									order = 3,
									type = "toggle",
									name = L["Power"],
									get = function(info) return E.global.unitframe[info[#info]] end,
									set = function(info, value) E.global.unitframe[info[#info]] = value UF:Update_AllFrames() end
								},
								effectiveAura = {
									order = 4,
									type = "toggle",
									name = L["Aura"],
									get = function(info) return E.global.unitframe[info[#info]] end,
									set = function(info, value) E.global.unitframe[info[#info]] = value UF:Update_AllFrames() end
								},
								spacer1 = {
									order = 5,
									type = "description",
									name = " ",
									width = "full"
								},
								effectiveHealthSpeed = {
									order = 6,
									type = "range",
									name = L["Health Speed"],
									min = 0.1, max = 0.5, step = 0.05,
									disabled = function() return not E.global.unitframe.effectiveHealth end,
									get = function(info) return E.global.unitframe[info[#info]] end,
									set = function(info, value) E.global.unitframe[info[#info]] = value UF:Update_AllFrames() end
								},
								effectivePowerSpeed = {
									order = 7,
									type = "range",
									name = L["Power Speed"],
									min = 0.1, max = 0.5, step = 0.05,
									disabled = function() return not E.global.unitframe.effectivePower end,
									get = function(info) return E.global.unitframe[info[#info]] end,
									set = function(info, value) E.global.unitframe[info[#info]] = value UF:Update_AllFrames() end
								},
								effectiveAuraSpeed = {
									order = 8,
									type = "range",
									name = L["Aura Speed"],
									min = 0.1, max = 0.5, step = 0.05,
									disabled = function() return not E.global.unitframe.effectiveAura end,
									get = function(info) return E.global.unitframe[info[#info]] end,
									set = function(info, value) E.global.unitframe[info[#info]] = value UF:Update_AllFrames() end
								}
							}
						},
						modifiers = {
							order = 6,
							type = "group",
							name = L["Filter Modifiers"],
							guiInline = true,
							get = function(info) return E.db.unitframe.modifiers[info[#info]] end,
							set = function(info, value) E.db.unitframe.modifiers[info[#info]] = value end,
							args = {
								warning = {
									order = 1,
									type = "description",
									fontSize = "medium",
									name = L["You need to hold this modifier down in order to blacklist an aura by right-clicking the icon. Set to None to disable the blacklist functionality."]
								},
								SHIFT = {
									order = 2,
									type = "select",
									name = L["SHIFT_KEY"],
									values = modifierList
								},
								ALT = {
									order = 3,
									type = "select",
									name = L["ALT_KEY"],
									values = modifierList
								},
								CTRL = {
									order = 4,
									type = "select",
									name = L["CTRL_KEY"],
									values = modifierList
								}
							}
						},
						barGroup = {
							order = 7,
							type = "group",
							guiInline = true,
							name = L["Bars"],
							args = {
								smoothbars = {
									order = 1,
									type = "toggle",
									name = L["Smooth Bars"],
									desc = L["Bars will transition smoothly."],
									set = function(info, value) E.db.unitframe[info[#info]] = value UF:Update_AllFrames() end
								},
								statusbar = {
									order = 3,
									type = "select", dialogControl = "LSM30_Statusbar",
									name = L["StatusBar Texture"],
									desc = L["Main statusbar texture."],
									values = AceGUIWidgetLSMlists.statusbar,
									set = function(info, value) E.db.unitframe[info[#info]] = value UF:Update_StatusBars() end
								}
							}
						},
						fontGroup = {
							order = 8,
							type = "group",
							guiInline = true,
							name = L["Fonts"],
							args = {
								font = {
									order = 4,
									type = "select", dialogControl = "LSM30_Font",
									name = L["Default Font"],
									desc = L["The font that the unitframes will use."],
									values = AceGUIWidgetLSMlists.font,
									set = function(info, value) E.db.unitframe[info[#info]] = value UF:Update_FontStrings() end
								},
								fontSize = {
									order = 5,
									type = "range",
									name = L["FONT_SIZE"],
									desc = L["Set the font size for unitframes."],
									min = 4, max = 32, step = 1,
									set = function(info, value) E.db.unitframe[info[#info]] = value UF:Update_FontStrings() end
								},
								fontOutline = {
									order = 6,
									type = "select",
									name = L["Font Outline"],
									desc = L["Set the font outline."],
									values = C.Values.FontFlags,
									set = function(info, value) E.db.unitframe[info[#info]] = value UF:Update_FontStrings() end
								}
							}
						}
					}
				},
				frameGlowGroup = {
					order = 3,
					type = "group",
					childGroups = "tree",
					name = L["Frame Glow"],
					disabled = function() return not E.UnitFrames.Initialized end,
					args = {
						mainGlow = {
							order = 2,
							type = "group",
							guiInline = true,
							name = L["Mouseover Glow"],
							get = function(info)
								local t = E.db.unitframe.colors.frameGlow.mainGlow[info[#info]]
								if type(t) == "boolean" then return t end
								local d = P.unitframe.colors.frameGlow.mainGlow[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.frameGlow.mainGlow[info[#info]]
								if type(t) == "boolean" then
									E.db.unitframe.colors.frameGlow.mainGlow[info[#info]] = r
								else
									t.r, t.g, t.b, t.a = r, g, b, a
								end
								UF:FrameGlow_UpdateFrames()
							end,
							disabled = function() return not E.db.unitframe.colors.frameGlow.mainGlow.enable end,
							args = {
								enable = {
									order = 1,
									type = "toggle",
									name = L["ENABLE"],
									disabled = false
								},
								spacer = {
									order = 2,
									type = "description",
									name = ""
								},
								class = {
									order = 3,
									type = "toggle",
									name = L["Use Class Color"],
									desc = L["Alpha channel is taken from the color option."]
								},
								color = {
									order = 4,
									type = "color",
									name = L["COLOR"],
									hasAlpha = true,
									disabled = function() return not E.db.unitframe.colors.frameGlow.mainGlow.enable or E.db.unitframe.colors.frameGlow.mainGlow.class end
								}
							}
						},
						targetGlow = {
							order = 3,
							type = "group",
							guiInline = true,
							name = L["Targeted Glow"],
							get = function(info)
								local t = E.db.unitframe.colors.frameGlow.targetGlow[info[#info]]
								if type(t) == "boolean" then return t end
								local d = P.unitframe.colors.frameGlow.targetGlow[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.frameGlow.targetGlow[info[#info]]
								if type(t) == "boolean" then
									E.db.unitframe.colors.frameGlow.targetGlow[info[#info]] = r
								else
									t.r, t.g, t.b, t.a = r, g, b, a
								end
								UF:FrameGlow_UpdateFrames()
							end,
							disabled = function() return not E.db.unitframe.colors.frameGlow.targetGlow.enable end,
							args = {
								enable = {
									order = 1,
									type = "toggle",
									name = L["ENABLE"],
									disabled = false
								},
								spacer = {
									order = 2,
									type = "description",
									name = ""
								},
								class = {
									order = 3,
									type = "toggle",
									name = L["Use Class Color"],
									desc = L["Alpha channel is taken from the color option."]
								},
								color = {
									order = 4,
									type = "color",
									name = L["COLOR"],
									hasAlpha = true,
									disabled = function() return not E.db.unitframe.colors.frameGlow.targetGlow.enable or E.db.unitframe.colors.frameGlow.targetGlow.class end
								}
							}
						},
						focusGlow = {
							order = 4,
							type = "group",
							guiInline = true,
							name = L["Focused Glow"],
							get = function(info)
								local t = E.db.unitframe.colors.frameGlow.focusGlow[info[#info]]
								if type(t) == "boolean" then return t end
								local d = P.unitframe.colors.frameGlow.focusGlow[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.frameGlow.focusGlow[info[#info]]
								if type(t) == "boolean" then
									E.db.unitframe.colors.frameGlow.focusGlow[info[#info]] = r
								else
									t.r, t.g, t.b, t.a = r, g, b, a
								end
								UF:FrameGlow_UpdateFrames()
							end,
							disabled = function() return not E.db.unitframe.colors.frameGlow.focusGlow.enable end,
							args = {
								enable = {
									order = 1,
									type = "toggle",
									name = L["ENABLE"],
									disabled = false
								},
								spacer = {
									order = 2,
									type = "description",
									name = ""
								},
								class = {
									order = 3,
									type = "toggle",
									name = L["Use Class Color"],
									desc = L["Alpha channel is taken from the color option."]
								},
								color = {
									order = 4,
									type = "color",
									name = L["COLOR"],
									hasAlpha = true
								}
							}
						},
						mouseoverGlow = {
							order = 5,
							type = "group",
							guiInline = true,
							name = L["Mouseover Highlight"],
							get = function(info)
								local t = E.db.unitframe.colors.frameGlow.mouseoverGlow[info[#info]]
								if type(t) == "boolean" then return t end
								local d = P.unitframe.colors.frameGlow.mouseoverGlow[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.frameGlow.mouseoverGlow[info[#info]]
								if type(t) == "boolean" then
									E.db.unitframe.colors.frameGlow.mouseoverGlow[info[#info]] = r
								else
									t.r, t.g, t.b, t.a = r, g, b, a
								end
								UF:FrameGlow_UpdateFrames()
							end,
							disabled = function() return not E.db.unitframe.colors.frameGlow.mouseoverGlow.enable end,
							args = {
								enable = {
									order = 1,
									type = "toggle",
									name = L["ENABLE"],
									disabled = false
								},
								texture = {
									order = 2,
									type = "select",
									dialogControl = "LSM30_Statusbar",
									name = L["Texture"],
									values = AceGUIWidgetLSMlists.statusbar,
									get = function(info)
										return E.db.unitframe.colors.frameGlow.mouseoverGlow[info[#info]]
									end,
									set = function(info, value)
										E.db.unitframe.colors.frameGlow.mouseoverGlow[info[#info]] = value
										UF:FrameGlow_UpdateFrames()
									end
								},
								spacer = {
									order = 3,
									type = "description",
									name = ""
								},
								class = {
									order = 4,
									type = "toggle",
									name = L["Use Class Color"],
									desc = L["Alpha channel is taken from the color option."]
								},
								color = {
									order = 5,
									type = "color",
									name = L["COLOR"],
									hasAlpha = true,
									disabled = function() return not E.db.unitframe.colors.frameGlow.mouseoverGlow.enable or E.db.unitframe.colors.frameGlow.mouseoverGlow.class end
								}
							}
						}
					}
				},
				allColorsGroup = {
					order = 4,
					type = "group",
					name = L["COLORS"],
					get = function(info) return E.db.unitframe.colors[info[#info]] end,
					set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end,
					disabled = function() return not E.UnitFrames.Initialized end,
					args = {
						healthGroup = {
							order = 1,
							type = "group",
							name = L["HEALTH"],
							get = function(info)
								local t = E.db.unitframe.colors[info[#info]]
								local d = P.unitframe.colors[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.unitframe.colors[info[#info]]
								t.r, t.g, t.b = r, g, b
								UF:Update_AllFrames()
							end,
							args = {
								colorhealthbyvalue = {
									order = 2,
									type = "toggle",
									name = L["Health By Value"],
									desc = L["Color health by amount remaining."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end
								},
								healthclass = {
									order = 3,
									type = "toggle",
									name = L["Class Health"],
									desc = L["Color health by classcolor or reaction."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end
								},
								forcehealthreaction = {
									order = 4,
									type = "toggle",
									name = L["Force Reaction Color"],
									desc = L["Forces reaction color instead of class color on units controlled by players."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end,
									disabled = function() return not E.db.unitframe.colors.healthclass end
								},
								transparentHealth = {
									order = 6,
									type = "toggle",
									name = L["Transparent"],
									desc = L["Make textures transparent."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end
								},
								spacer1 = {
									order = 7,
									type = "description",
									name = " ",
									width = "full"
								},
								customhealthbackdrop = {
									order = 8,
									type = "toggle",
									name = L["Custom Backdrop"],
									desc = L["Use the custom backdrop color instead of a multiple of the main color."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end
								},
								health_backdrop = {
									order = 9,
									type = "color",
									name = L["Health Backdrop"],
									disabled = function() return not E.db.unitframe.colors.customhealthbackdrop end
								},
								spacer2 = {
									order = 10,
									type = "description",
									name = " ",
									width = "full"
								},
								useDeadBackdrop = {
									order = 11,
									type = "toggle",
									name = L["Use Dead Backdrop"],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end
								},
								health_backdrop_dead = {
									order = 12,
									type = "color",
									name = L["Custom Dead Backdrop"],
									desc = L["Use this backdrop color for units that are dead or ghosts."],
									customWidth = 250,
									disabled = function() return not E.db.unitframe.colors.useDeadBackdrop end
								},
								spacer3 = {
									order = 13,
									type = "description",
									name = " ",
									width = "full"
								},
								classbackdrop = {
									order = 14,
									type = "toggle",
									name = L["Class Backdrop"],
									desc = L["Color the health backdrop by class or reaction."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end,
									disabled = function() return E.db.unitframe.colors.customhealthbackdrop end
								},
								healthMultiplier = {
									order = 15,
									type = "range",
									name = L["Health Backdrop Multiplier"],
									min = 0, softMax = 0.75, max = 1, step = .01,
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end,
									disabled = function() return E.db.unitframe.colors.customhealthbackdrop end
								},
								spacer4 = {
									order = 16,
									type = "description",
									name = " ",
									width = "full"
								},
								tapped = {
									order = 17,
									type = "color",
									name = L["Tapped"]
								},
								health = {
									order = 18,
									type = "color",
									name = L["HEALTH"]
								},
								disconnected = {
									order = 19,
									type = "color",
									name = L["Disconnected"]
								}
							}
						},
						powerGroup = {
							order = 2,
							type = "group",
							name = L["Powers"],
							get = function(info)
								local t = E.db.unitframe.colors.power[info[#info]]
								local d = P.unitframe.colors.power[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.unitframe.colors.power[info[#info]]
								t.r, t.g, t.b = r, g, b
								UF:Update_AllFrames()
							end,
							args = {
								transparentPower = {
									order = 1,
									type = "toggle",
									name = L["Transparent"],
									desc = L["Make textures transparent."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end
								},
								invertPower = {
									order = 2,
									type = "toggle",
									name = L["Invert Colors"],
									desc = L["Invert foreground and background colors."],
									disabled = function() return not E.db.unitframe.colors.transparentPower end,
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end,
								},
								powerclass = {
									order = 3,
									type = "toggle",
									name = L["Class Power"],
									desc = L["Color power by classcolor or reaction."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end
								},
								spacer2 = {
									order = 4,
									type = "description",
									name = " ",
									width = "full"
								},
								custompowerbackdrop = {
									order = 5,
									type = "toggle",
									name = L["Custom Backdrop"],
									desc = L["Use the custom backdrop color instead of a multiple of the main color."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end,
								},
								power_backdrop = {
									order = 6,
									type = "color",
									name = L["Custom Backdrop"],
									desc = L["Use the custom backdrop color instead of a multiple of the main color."],
									disabled = function() return not E.db.unitframe.colors.custompowerbackdrop end,
									get = function(info)
										local t = E.db.unitframe.colors[info[#info]]
										local d = P.unitframe.colors[info[#info]]
										return t.r, t.g, t.b, t.a, d.r, d.g, d.b
									end,
									set = function(info, r, g, b)
										local t = E.db.unitframe.colors[info[#info]]
										t.r, t.g, t.b = r, g, b
										UF:Update_AllFrames()
									end,
								},
								spacer3 = {
									order = 7,
									type = "description",
									name = " ",
									width = "full"
								},
								MANA = {
									order = 8,
									type = "color",
									name = L["MANA"]
								},
								RAGE = {
									order = 9,
									type = "color",
									name = L["RAGE"]
								},
								FOCUS = {
									order = 10,
									type = "color",
									name = L["FOCUS"]
								},
								ENERGY = {
									order = 11,
									type = "color",
									name = L["ENERGY"]
								},
								RUNIC_POWER = {
									order = 12,
									type = "color",
									name = L["RUNIC_POWER"]
								}
							}
						},
						castBars = {
							order = 3,
							type = "group",
							name = L["Castbar"],
							get = function(info)
								local t = E.db.unitframe.colors[info[#info]]
								local d = P.unitframe.colors[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.unitframe.colors[info[#info]]
								t.r, t.g, t.b = r, g, b
								UF:Update_AllFrames()
							end,
							args = {
								transparentCastbar = {
									order = 1,
									type = "toggle",
									name = L["Transparent"],
									desc = L["Make textures transparent."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end
								},
								invertCastbar = {
									order = 2,
									type = "toggle",
									name = L["Invert Colors"],
									desc = L["Invert foreground and background colors."],
									disabled = function() return not E.db.unitframe.colors.transparentCastbar end,
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end
								},
								castClassColor = {
									order = 3,
									type = "toggle",
									name = L["Class Castbars"],
									desc = L["Color castbars by the class of player units."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end
								},
								castReactionColor = {
									order = 4,
									type = "toggle",
									name = L["Reaction Castbars"],
									desc = L["Color castbars by the reaction type of non-player units."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end
								},
								spacer1 = {
									order = 5,
									type = "description",
									name = " ",
									width = "full"
								},
								customcastbarbackdrop = {
									order = 6,
									type = "toggle",
									name = L["Custom Backdrop"],
									desc = L["Use the custom backdrop color instead of a multiple of the main color."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end
								},
								castbar_backdrop = {
									order = 7,
									type = "color",
									name = L["Custom Backdrop"],
									desc = L["Use the custom backdrop color instead of a multiple of the main color."],
									disabled = function() return not E.db.unitframe.colors.customcastbarbackdrop end
								},
								spacer2 = {
									order = 8,
									type = "description",
									name = " ",
									width = "full"
								},
								castColor = {
									order = 9,
									type = "color",
									name = L["Interruptable"]
								},
								castNoInterrupt = {
									order = 10,
									type = "color",
									name = L["Non-Interruptable"]
								},
								castInterruptedColor = {
									order = 11,
									type = "color",
									name = L["INTERRUPTED"]
								}
							}
						},
						auras = {
							order = 4,
							type = "group",
							name = L["Auras"],
							args = {
								auraByType = {
									order = 1,
									type = "toggle",
									name = L["By Type"]
								}
							}
						},
						auraBars = {
							order = 5,
							type = "group",
							name = L["Aura Bars"],
							args = {
								transparentAurabars = {
									order = 1,
									type = "toggle",
									name = L["Transparent"],
									desc = L["Make textures transparent."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end
								},
								invertAurabars = {
									order = 2,
									type = "toggle",
									name = L["Invert Colors"],
									desc = L["Invert foreground and background colors."],
									disabled = function() return not E.db.unitframe.colors.transparentAurabars end,
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end
								},
								auraBarByType = {
									order = 3,
									type = "toggle",
									name = L["By Type"],
									desc = L["Color aurabar debuffs by type."]
								},
								auraBarTurtle = {
									order = 4,
									type = "toggle",
									name = L["Color Turtle Buffs"],
									desc = L["Color all buffs that reduce the unit's incoming damage."]
								},
								spacer1 = {
									order = 5,
									type = "description",
									name = " ",
									width = "full"
								},
								customaurabarbackdrop = {
									order = 6,
									type = "toggle",
									name = L["Custom Backdrop"],
									desc = L["Use the custom backdrop color instead of a multiple of the main color."],
									get = function(info) return E.db.unitframe.colors[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end,
								},
								aurabar_backdrop = {
									order = 7,
									type = "color",
									name = L["Custom Backdrop"],
									desc = L["Use the custom backdrop color instead of a multiple of the main color."],
									disabled = function() return not E.db.unitframe.colors.customaurabarbackdrop end,
									get = function(info)
										local t = E.db.unitframe.colors[info[#info]]
										local d = P.unitframe.colors[info[#info]]
										return t.r, t.g, t.b, t.a, d.r, d.g, d.b
									end,
									set = function(info, r, g, b)
										local t = E.db.unitframe.colors[info[#info]]
										t.r, t.g, t.b = r, g, b
										UF:Update_AllFrames()
									end,
								},
								spacer2 = {
									order = 8,
									type = "description",
									name = " ",
									width = "full"
								},
								BUFFS = {
									order = 9,
									type = "color",
									name = L["Buffs"],
									get = function(info)
										local t = E.db.unitframe.colors.auraBarBuff
										local d = P.unitframe.colors.auraBarBuff
										return t.r, t.g, t.b, t.a, d.r, d.g, d.b
									end,
									set = function(info, r, g, b)
										if E:CheckClassColor(r, g, b) then
											local classColor = E:ClassColor(E.myclass, true)
											r, g, b = classColor.r, classColor.g, classColor.b
										end

										local t = E.db.unitframe.colors.auraBarBuff
										t.r, t.g, t.b = r, g, b

										UF:Update_AllFrames()
									end
								},
								DEBUFFS = {
									order = 10,
									type = "color",
									name = L["Debuffs"],
									get = function(info)
										local t = E.db.unitframe.colors.auraBarDebuff
										local d = P.unitframe.colors.auraBarDebuff
										return t.r, t.g, t.b, t.a, d.r, d.g, d.b
									end,
									set = function(info, r, g, b)
										local t = E.db.unitframe.colors.auraBarDebuff
										t.r, t.g, t.b = r, g, b
										UF:Update_AllFrames()
									end
								},
								auraBarTurtleColor = {
									order = 11,
									type = "color",
									name = L["Turtle Color"],
									get = function(info)
										local t = E.db.unitframe.colors.auraBarTurtleColor
										local d = P.unitframe.colors.auraBarTurtleColor
										return t.r, t.g, t.b, t.a, d.r, d.g, d.b
									end,
									set = function(info, r, g, b)
										local t = E.db.unitframe.colors.auraBarTurtleColor
										t.r, t.g, t.b = r, g, b
										UF:Update_AllFrames()
									end
								}
							}
						},
						reactionGroup = {
							order = 6,
							type = "group",
							name = L["Reactions"],
							get = function(info)
								local t = E.db.unitframe.colors.reaction[info[#info]]
								local d = P.unitframe.colors.reaction[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.unitframe.colors.reaction[info[#info]]
								t.r, t.g, t.b = r, g, b
								UF:Update_AllFrames()
							end,
							args = {
								BAD = {
									order = 1,
									type = "color",
									name = L["Bad"]
								},
								NEUTRAL = {
									order = 2,
									type = "color",
									name = L["Neutral"]
								},
								GOOD = {
									order = 3,
									type = "color",
									name = L["Good"]
								}
							}
						},
						healPrediction = {
							order = 7,
							type = "group",
							name = L["Heal Prediction"],
							get = function(info)
								local t = E.db.unitframe.colors.healPrediction[info[#info]]
								local d = P.unitframe.colors.healPrediction[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.healPrediction[info[#info]]
								t.r, t.g, t.b, t.a = r, g, b, a
								UF:Update_AllFrames()
							end,
							args = {
								personal = {
									order = 1,
									type = "color",
									name = L["Personal"],
									hasAlpha = true
								},
								others = {
									order = 2,
									type = "color",
									name = L["Others"],
									hasAlpha = true
								},
								absorbs = {
									order = 3,
									type = "color",
									name = L["Absorbs"],
									hasAlpha = true
								},
								healAbsorbs = {
									order = 4,
									type = "color",
									name = L["Heal Absorbs"],
									hasAlpha = true
								},
								overabsorbs = {
									order = 5,
									type = "color",
									name = L["Over Absorbs"],
									hasAlpha = true
								},
								overhealabsorbs = {
									order = 6,
									type = "color",
									name = L["Over Heal Absorbs"],
									hasAlpha = true
								},
								maxOverflow = {
									order = 7,
									type = "range",
									name = L["Max Overflow"],
									desc = L["Max amount of overflow allowed to extend past the end of the health bar."],
									isPercent = true,
									min = 0, max = 1, step = 0.01,
									get = function(info) return E.db.unitframe.colors.healPrediction.maxOverflow end,
									set = function(info, value) E.db.unitframe.colors.healPrediction.maxOverflow = value UF:Update_AllFrames() end
								}
							}
						},
						debuffHighlight = {
							order = 8,
							type = "group",
							name = L["Debuff Highlighting"],
							get = function(info)
								local t = E.db.unitframe.colors.debuffHighlight[info[#info]]
								local d = P.unitframe.colors.debuffHighlight[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.debuffHighlight[info[#info]]
								t.r, t.g, t.b, t.a = r, g, b, a
								UF:Update_AllFrames()
							end,
							args = {
								debuffHighlighting = {
									order = 1,
									type = "select",
									name = L["Debuff Highlighting"],
									desc = L["Color the unit healthbar if there is a debuff that can be dispelled by you."],
									get = function(info) return E.db.unitframe[info[#info]] end,
									set = function(info, value) E.db.unitframe[info[#info]] = value end,
									values = {
										NONE = L["NONE"],
										GLOW = L["Glow"],
										FILL = L["Fill"]
									}
								},
								blendMode = {
									order = 2,
									type = "select",
									name = L["Blend Mode"],
									values = blendModeValues,
									get = function(info) return E.db.unitframe.colors.debuffHighlight[info[#info]] end,
									set = function(info, value) E.db.unitframe.colors.debuffHighlight[info[#info]] = value UF:Update_AllFrames() end
								},
								spacer1 = {
									order = 3,
									type = "description",
									name = " ",
									width = "full"
								},
								Magic = {
									order = 4,
									type = "color",
									name = L["ENCOUNTER_JOURNAL_SECTION_FLAG7"],
									hasAlpha = true
								},
								Curse = {
									order = 5,
									type = "color",
									name = L["ENCOUNTER_JOURNAL_SECTION_FLAG8"],
									hasAlpha = true
								},
								Disease = {
									order = 6,
									type = "color",
									name = L["ENCOUNTER_JOURNAL_SECTION_FLAG10"],
									hasAlpha = true
								},
								Poison = {
									order = 7,
									type = "color",
									name = L["ENCOUNTER_JOURNAL_SECTION_FLAG9"],
									hasAlpha = true
								}
							}
						}
					}
				},
				disabledBlizzardFrames = {
					order = 4,
					type = "group",
					name = L["Disabled Blizzard Frames"],
					get = function(info) return E.private.unitframe.disabledBlizzardFrames[info[#info]] end,
					set = function(info, value) E.private.unitframe.disabledBlizzardFrames[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end,
					args = {
						player = {
							order = 1,
							type = "toggle",
							name = L["PLAYER"],
							desc = L["Disables the player and pet unitframes."]
						},
						target = {
							order = 2,
							type = "toggle",
							name = L["TARGET"],
							desc = L["Disables the target and target of target unitframes."]
						},
						focus = {
							order = 3,
							type = "toggle",
							name = L["FOCUS"],
							desc = L["Disables the focus and target of focus unitframes."]
						},
						boss = {
							order = 4,
							type = "toggle",
							name = L["BOSS"]
						},
						arena = {
							order = 5,
							type = "toggle",
							name = L["ARENA"]
						},
						party = {
							order = 6,
							type = "toggle",
							name = L["PARTY"]
						},
						raid = {
							order = 7,
							type = "toggle",
							name = L["RAID"]
						}
					}
				},
				raidDebuffIndicator = {
					order = 5,
					type = "group",
					name = L["RaidDebuff Indicator"],
					disabled = function() return not E.UnitFrames.Initialized end,
					args = {
						instanceFilter = {
							order = 2,
							type = "select",
							name = L["Dungeon & Raid Filter"],
							values = function()
								local filters = {}
								local list = E.global.unitframe.aurafilters
								if not list then return end
								for filter in pairs(list) do
									filters[filter] = filter
								end

								return filters
							end,
							get = function(info) return E.global.unitframe.raidDebuffIndicator.instanceFilter end,
							set = function(info, value) E.global.unitframe.raidDebuffIndicator.instanceFilter = value UF:UpdateAllHeaders() end
						},
						otherFilter = {
							order = 3,
							type = "select",
							name = L["Other Filter"],
							values = function()
								local filters = {}
								local list = E.global.unitframe.aurafilters
								if not list then return end
								for filter in pairs(list) do
									filters[filter] = filter
								end

								return filters
							end,
							get = function(info) return E.global.unitframe.raidDebuffIndicator.otherFilter end,
							set = function(info, value) E.global.unitframe.raidDebuffIndicator.otherFilter = value UF:UpdateAllHeaders() end
						}
					}
				}
			}
		},
		individualUnits = {
			order = 4,
			type = "group",
			childGroups = "tab",
			name = L["Individual Units"],
			args = {}
		},
		groupUnits = {
			order = 5,
			type = "group",
			childGroups = "tab",
			name = L["Group Units"],
			args = {}
		}
	}
}

--Player
E.Options.args.unitframe.args.individualUnits.args.player = {
	order = 3,
	type = "group",
	name = L["PLAYER"],
	get = function(info) return E.db.unitframe.units.player[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.player[info[#info]] = value UF:CreateAndUpdateUF("player") end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(info, value)
				E.db.unitframe.units.player[info[#info]] = value
				UF:CreateAndUpdateUF("player")
			end
		},
		showAuras = {
			order = 2,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				if UF.player.forceShowAuras then
					UF.player.forceShowAuras = nil
				else
					UF.player.forceShowAuras = true
				end

				UF:CreateAndUpdateUF("player")
			end
		},
		resetSettings = {
			order = 3,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show("RESET_UF_UNIT", L["PLAYER"], nil, {unit="player", mover="Player Frame"}) end
		},
		copyFrom = {
			order = 4,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF.units,
			set = function(info, value) UF:MergeUnitSettings(value, "player") E:RefreshGUI() end,
			confirm = true
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, "player"),
		RestIcon = {
			type = "group",
			name = L["Rest Icon"],
			get = function(info) return E.db.unitframe.units.player.RestIcon[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.player.RestIcon[info[#info]] = value UF:CreateAndUpdateUF("player") end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"]
				},
				defaultColor = {
					order = 2,
					type = "toggle",
					name = L["Default Color"]
				},
				color = {
					order = 3,
					type = "color",
					name = L["COLOR"],
					hasAlpha = true,
					disabled = function()
						return E.db.unitframe.units.player.RestIcon.defaultColor
					end,
					get = function()
						local c = E.db.unitframe.units.player.RestIcon.color
						local d = P.unitframe.units.player.RestIcon.color
						return c.r, c.g, c.b, c.a, d.r, d.g, d.b, d.a
					end,
					set = function(_, r, g, b, a)
						local c = E.db.unitframe.units.player.RestIcon.color
						c.r, c.g, c.b, c.a = r, g, b, a
						UF:CreateAndUpdateUF("player")
					end
				},
				size = {
					order = 4,
					type = "range",
					name = L["Size"],
					min = 10, max = 60, step = 1
				},
				xOffset = {
					order = 5,
					type = "range",
					name = L["X-Offset"],
					min = -100, max = 100, step = 1
				},
				yOffset = {
					order = 6,
					type = "range",
					name = L["Y-Offset"],
					min = -100, max = 100, step = 1
				},
				spacer2 = {
					order = 7,
					type = "description",
					name = " "
				},
				anchorPoint = {
					order = 8,
					type = "select",
					name = L["Anchor Point"],
					values = positionValues
				},
				texture = {
					order = 9,
					type = "select",
					sortByValue = true,
					name = L["Texture"],
					values = {
						CUSTOM = L["CUSTOM"],
						DEFAULT = L["DEFAULT"],
						RESTING0 = E:TextureString(E.Media.RestIcons.Resting0, ":14"),
						RESTING1 = E:TextureString(E.Media.RestIcons.Resting1, ":14"),
						RESTING2 = E:TextureString(E.Media.RestIcons.Resting2, ":14")
					}
				},
				customTexture = {
					order = 10,
					type = "input",
					customWidth = 250,
					name = L["Custom Texture"],
					disabled = function()
						return E.db.unitframe.units.player.RestIcon.texture ~= "CUSTOM"
					end,
					set = function(_, value)
						E.db.unitframe.units.player.RestIcon.customTexture = (value and (not value:match("^%s-$")) and value) or nil
						UF:CreateAndUpdateUF("player")
					end
				}
			}
		},
		pvpText = {
			type = "group",
			name = L["PvP Text"],
			get = function(info) return E.db.unitframe.units.player.pvp[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.player.pvp[info[#info]] = value UF:CreateAndUpdateUF("player") end,
			args = {
				position = {
					order = 2,
					type = "select",
					name = L["Position"],
					values = positionValues
				},
				text_format = {
					order = 100,
					type = "input",
					name = L["Text Format"],
					desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
					width = "full"
				}
			}
		},
		stagger = {
			type = "group",
			name = L["Stagger Bar"],
			get = function(info) return E.db.unitframe.units.player.stagger[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.player.stagger[info[#info]] = value UF:CreateAndUpdateUF("player") end,
			hidden = E.myclass ~= "MONK",
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"]
				},
				autoHide = {
					order = 2,
					type = "toggle",
					name = L["Auto Hide"],
					disabled = function() return not E.db.unitframe.units.player.stagger.enable end
				},
				width = {
					order = 3,
					type = "range",
					name = L["Width"],
					min = 5, max = 50, step = 1,
					disabled = function() return not E.db.unitframe.units.player.stagger.enable end
				},
				staggerTextFormat = {
					order = 4,
					type = "input",
					name = L["Text Format"],
					desc = L["Controls the text displayed. Tags are available in the Available Tags section of the config."],
					width = "full",
					disabled = function() return not E.db.unitframe.units.player.stagger.enable end
				}
			}
		},
		aurabar = GetOptionsTable_AuraBars(UF.CreateAndUpdateUF, "player"),
		buffs = GetOptionsTable_Auras("buffs", UF.CreateAndUpdateUF, "player"),
		castbar = GetOptionsTable_Castbar(true, UF.CreateAndUpdateUF, "player"),
		CombatIcon = GetOptionsTable_CombatIconGroup(UF.CreateAndUpdateUF, "player"),
		classbar = GetOptionsTable_ClassBar(UF.CreateAndUpdateUF, "player"),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, "player"),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, "player"),
		debuffs = GetOptionsTable_Auras("debuffs", UF.CreateAndUpdateUF, "player"),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, "player"),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, "player"),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, "player"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, "player"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, "player"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, "player"),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, "player", nil, true),
		pvpIcon = GetOptionsTable_PVPIcon(UF.CreateAndUpdateUF, "player"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, "player"),
		raidRoleIcons = GetOptionsTable_RaidRoleIcons(UF.CreateAndUpdateUF, "player"),
		resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateUF, "player"),
		strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, "player")
	}
}

--Target
E.Options.args.unitframe.args.individualUnits.args.target = {
	order = 4,
	type = "group",
	name = L["TARGET"],
	get = function(info) return E.db.unitframe.units.target[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.target[info[#info]] = value UF:CreateAndUpdateUF("target") end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"]
		},
		showAuras = {
			order = 2,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				if UF.target.forceShowAuras then
					UF.target.forceShowAuras = nil
				else
					UF.target.forceShowAuras = true
				end

				UF:CreateAndUpdateUF("target")
			end
		},
		resetSettings = {
			order = 3,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show("RESET_UF_UNIT", L["TARGET"], nil, {unit="target", mover="Target Frame"}) end
		},
		copyFrom = {
			order = 4,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF.units,
			set = function(info, value) UF:MergeUnitSettings(value, "target") E:RefreshGUI() end,
			confirm = true
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, "target"),
		aurabar = GetOptionsTable_AuraBars(UF.CreateAndUpdateUF, "target"),
		buffs = GetOptionsTable_Auras("buffs", UF.CreateAndUpdateUF, "target"),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUF, "target"),
		CombatIcon = GetOptionsTable_CombatIconGroup(UF.CreateAndUpdateUF, "target"),
		combobar = GetOptionsTable_ComboBar(UF.CreateAndUpdateUF, "target"),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, "target"),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, "target"),
		debuffs = GetOptionsTable_Auras("debuffs", UF.CreateAndUpdateUF, "target"),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, "target"),
		GPSArrow = GetOptionsTable_GPS(UF.CreateAndUpdateUF, "target"),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, "target"),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, "target"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, "target"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, "target"),
		phaseIndicator = GetOptionsTable_PhaseIndicator(UF.CreateAndUpdateUF, "target"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, "target"),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, "target", nil, true),
		pvpIcon = GetOptionsTable_PVPIcon(UF.CreateAndUpdateUF, "target"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, "target"),
		raidRoleIcons = GetOptionsTable_RaidRoleIcons(UF.CreateAndUpdateUF, "target"),
		resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateUF, "target"),
		strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, "target")
	}
}

--TargetTarget
E.Options.args.unitframe.args.individualUnits.args.targettarget = {
	order = 5,
	type = "group",
	name = L["TargetTarget"],
	get = function(info) return E.db.unitframe.units.targettarget[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.targettarget[info[#info]] = value UF:CreateAndUpdateUF("targettarget") end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"]
		},
		showAuras = {
			order = 2,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				if UF.targettarget.forceShowAuras then
					UF.targettarget.forceShowAuras = nil
				else
					UF.targettarget.forceShowAuras = true
				end

				UF:CreateAndUpdateUF("targettarget")
			end
		},
		resetSettings = {
			order = 3,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show("RESET_UF_UNIT", L["TargetTarget"], nil, {unit="targettarget", mover="TargetTarget Frame"}) end
		},
		copyFrom = {
			order = 4,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF.units,
			set = function(info, value) UF:MergeUnitSettings(value, "targettarget") E:RefreshGUI() end,
			confirm = true
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, "targettarget"),
		buffs = GetOptionsTable_Auras("buffs", UF.CreateAndUpdateUF, "targettarget"),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, "targettarget"),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, "targettarget"),
		debuffs = GetOptionsTable_Auras("debuffs", UF.CreateAndUpdateUF, "targettarget"),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, "targettarget"),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, "targettarget"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, "targettarget"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, "targettarget"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, "targettarget"),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, "targettarget"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, "targettarget"),
		strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, "targettarget")
	}
}

--TargetTargetTarget
E.Options.args.unitframe.args.individualUnits.args.targettargettarget = {
	order = 6,
	type = "group",
	name = L["TargetTargetTarget"],
	get = function(info) return E.db.unitframe.units.targettargettarget[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.targettargettarget[info[#info]] = value UF:CreateAndUpdateUF("targettargettarget") end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"]
		},
		showAuras = {
			order = 2,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				if UF.targettargettarget.forceShowAuras then
					UF.targettargettarget.forceShowAuras = nil
				else
					UF.targettargettarget.forceShowAuras = true
				end

				UF:CreateAndUpdateUF("targettargettarget")
			end
		},
		resetSettings = {
			order = 3,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show("RESET_UF_UNIT", L["TargetTargetTarget"], nil, {unit="targettargettarget", mover="TargetTargetTarget Frame"}) end
		},
		copyFrom = {
			order = 4,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF.units,
			set = function(info, value) UF:MergeUnitSettings(value, "targettargettarget") E:RefreshGUI() end,
			confirm = true
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, "targettargettarget"),
		buffs = GetOptionsTable_Auras("buffs", UF.CreateAndUpdateUF, "targettargettarget"),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, "targettargettarget"),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, "targettargettarget"),
		debuffs = GetOptionsTable_Auras("debuffs", UF.CreateAndUpdateUF, "targettargettarget"),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, "targettargettarget"),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, "targettargettarget"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, "targettargettarget"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, "targettargettarget"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, "targettargettarget"),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, "targettargettarget"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, "targettargettarget"),
		strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, "targettargettarget")
	}
}

--Focus
E.Options.args.unitframe.args.individualUnits.args.focus = {
	order = 7,
	type = "group",
	name = L["Focus"],
	get = function(info) return E.db.unitframe.units.focus[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.focus[info[#info]] = value UF:CreateAndUpdateUF("focus") end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"]
		},
		showAuras = {
			order = 2,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				if UF.focus.forceShowAuras then
					UF.focus.forceShowAuras = nil
				else
					UF.focus.forceShowAuras = true
				end

				UF:CreateAndUpdateUF("focus")
			end
		},
		resetSettings = {
			order = 3,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show("RESET_UF_UNIT", L["Focus"], nil, {unit="focus", mover="Focus Frame"}) end
		},
		copyFrom = {
			order = 4,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF.units,
			set = function(info, value) UF:MergeUnitSettings(value, "focus") E:RefreshGUI() end,
			confirm = true
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, "focus"),
		aurabar = GetOptionsTable_AuraBars(UF.CreateAndUpdateUF, "focus"),
		buffs = GetOptionsTable_Auras("buffs", UF.CreateAndUpdateUF, "focus"),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUF, "focus"),
		CombatIcon = GetOptionsTable_CombatIconGroup(UF.CreateAndUpdateUF, "focus"),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, "focus"),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, "focus"),
		debuffs = GetOptionsTable_Auras("debuffs", UF.CreateAndUpdateUF, "focus"),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, "focus"),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, "focus"),
		GPSArrow = GetOptionsTable_GPS(UF.CreateAndUpdateUF, "focus"),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, "focus"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, "focus"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, "focus"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, "focus"),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, "focus"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, "focus"),
		strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, "focus")
	}
}

--Focus Target
E.Options.args.unitframe.args.individualUnits.args.focustarget = {
	order = 8,
	type = "group",
	name = L["FocusTarget"],
	get = function(info) return E.db.unitframe.units.focustarget[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.focustarget[info[#info]] = value UF:CreateAndUpdateUF("focustarget") end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			order = 2,
			type = "toggle",
			name = L["ENABLE"]
		},
		showAuras = {
			order = 2,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				if UF.focustarget.forceShowAuras then
					UF.focustarget.forceShowAuras = nil
				else
					UF.focustarget.forceShowAuras = true
				end

				UF:CreateAndUpdateUF("focustarget")
			end
		},
		resetSettings = {
			order = 3,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show("RESET_UF_UNIT", L["FocusTarget"], nil, {unit="focustarget", mover="FocusTarget Frame"}) end
		},
		copyFrom = {
			order = 4,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF.units,
			set = function(info, value) UF:MergeUnitSettings(value, "focustarget") E:RefreshGUI() end,
			confirm = true
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, "focustarget"),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, "focustarget"),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, "focustarget"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, "focustarget"),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, "focustarget"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, "focustarget"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, "focustarget"),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, "focustarget"),
		buffs = GetOptionsTable_Auras("buffs", UF.CreateAndUpdateUF, "focustarget"),
		debuffs = GetOptionsTable_Auras("debuffs", UF.CreateAndUpdateUF, "focustarget"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, "focustarget"),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, "focustarget"),
		strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, "focustarget")
	}
}

--Pet
E.Options.args.unitframe.args.individualUnits.args.pet = {
	order = 9,
	type = "group",
	name = L["PET"],
	get = function(info) return E.db.unitframe.units.pet[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.pet[info[#info]] = value UF:CreateAndUpdateUF("pet") end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"]
		},
		showAuras = {
			order = 2,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				if UF.pet.forceShowAuras then
					UF.pet.forceShowAuras = nil
				else
					UF.pet.forceShowAuras = true
				end

				UF:CreateAndUpdateUF("pet")
			end
		},
		resetSettings = {
			order = 3,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show("RESET_UF_UNIT", L["PET"], nil, {unit="pet", mover="Pet Frame"}) end
		},
		copyFrom = {
			order = 4,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF.units,
			set = function(info, value) UF:MergeUnitSettings(value, "pet") E:RefreshGUI() end,
			confirm = true
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, "pet"),
		buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateUF, "pet"),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUF, "pet"),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, "pet"),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, "pet"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, "pet"),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, "pet"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, "pet"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, "pet"),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, "pet"),
		buffs = GetOptionsTable_Auras("buffs", UF.CreateAndUpdateUF, "pet"),
		debuffs = GetOptionsTable_Auras("debuffs", UF.CreateAndUpdateUF, "pet"),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUF, "pet"),
		aurabar = GetOptionsTable_AuraBars(UF.CreateAndUpdateUF, "pet"),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, "pet"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, "pet"),
		strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, "pet")
	}
}

--Pet Target
E.Options.args.unitframe.args.individualUnits.args.pettarget = {
	order = 10,
	type = "group",
	name = L["PetTarget"],
	get = function(info) return E.db.unitframe.units.pettarget[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.pettarget[info[#info]] = value UF:CreateAndUpdateUF("pettarget") end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"]
		},
		showAuras = {
			order = 2,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				if UF.pettarget.forceShowAuras then
					UF.pettarget.forceShowAuras = nil
				else
					UF.pettarget.forceShowAuras = true
				end

				UF:CreateAndUpdateUF("pettarget")
			end
		},
		resetSettings = {
			order = 3,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show("RESET_UF_UNIT", L["PetTarget"], nil, {unit="pettarget", mover="PetTarget Frame"}) end
		},
		copyFrom = {
			order = 4,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF.units,
			set = function(info, value) UF:MergeUnitSettings(value, "pettarget") E:RefreshGUI() end,
			confirm = true
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUF, "pettarget"),
		buffs = GetOptionsTable_Auras("buffs", UF.CreateAndUpdateUF, "pettarget"),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, "pettarget"),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUF, "pettarget"),
		debuffs = GetOptionsTable_Auras("debuffs", UF.CreateAndUpdateUF, "pettarget"),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUF, "pettarget"),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, "pettarget"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, "pettarget"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, "pettarget"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, "pettarget"),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, "pettarget"),
		strataAndLevel = GetOptionsTable_StrataAndFrameLevel(UF.CreateAndUpdateUF, "pettarget")
	}
}

--Boss
E.Options.args.unitframe.args.groupUnits.args.boss = {
	order = 1000,
	type = "group",
	name = L["BOSS"],
	get = function(info) return E.db.unitframe.units.boss[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.boss[info[#info]] = value UF:CreateAndUpdateUFGroup("boss", MAX_BOSS_FRAMES) end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"]
		},
		displayFrames = {
			order = 2,
			type = "execute",
			name = L["Display Frames"],
			desc = L["Force the frames to show, they will act as if they are the player frame."],
			func = function() UF:ToggleForceShowGroupFrames("boss", MAX_BOSS_FRAMES) end
		},
		resetSettings = {
			order = 3,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show("RESET_UF_UNIT", L["BOSS"], nil, {unit="boss", mover="Boss Frames"}) end
		},
		copyFrom = {
			order = 4,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				arena = L["ARENA"]
			},
			set = function(info, value) UF:MergeUnitSettings(value, "boss") E:RefreshGUI() end,
			confirm = true
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		buffs = GetOptionsTable_Auras("buffs", UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		classbar = GetOptionsTable_ClassBar(UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		debuffs = GetOptionsTable_Auras("debuffs", UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES)
	}
}

--Arena
E.Options.args.unitframe.args.groupUnits.args.arena = {
	order = 1000,
	type = "group",
	name = L["ARENA"],
	get = function(info) return E.db.unitframe.units.arena[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.arena[info[#info]] = value UF:CreateAndUpdateUFGroup("arena", 5) end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"]
		},
		displayFrames = {
			order = 2,
			type = "execute",
			name = L["Display Frames"],
			desc = L["Force the frames to show, they will act as if they are the player frame."],
			func = function() UF:ToggleForceShowGroupFrames("arena", 5) end
		},
		resetSettings = {
			order = 3,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show("RESET_UF_UNIT", L["ARENA"], nil, {unit="arena", mover="Arena Frames"}) end
		},
		copyFrom = {
			order = 4,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				boss = L["BOSS"]
			},
			set = function(info, value) UF:MergeUnitSettings(value, "arena") E:RefreshGUI() end,
			confirm = true
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateUFGroup, "arena", 5),
		pvpTrinket = {
			type = "group",
			name = L["PVP Trinket"],
			get = function(info) return E.db.unitframe.units.arena.pvpTrinket[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.arena.pvpTrinket[info[#info]] = value UF:CreateAndUpdateUFGroup("arena", 5) end,
			args = {
				enable = {
					order = 2,
					type = "toggle",
					name = L["ENABLE"]
				},
				position = {
					order = 3,
					type = "select",
					name = L["Position"],
					values = {
						LEFT = L["Left"],
						RIGHT = L["Right"]
					}
				},
				size = {
					order = 4,
					type = "range",
					name = L["Size"],
					min = 10, max = 60, step = 1
				},
				xOffset = {
					order = 5,
					type = "range",
					name = L["X-Offset"],
					min = -60, max = 60, step = 1
				},
				yOffset = {
					order = 6,
					type = "range",
					name = L["Y-Offset"],
					min = -60, max = 60, step = 1
				}
			}
		},
		pvpSpecIcon = {
			type = "group",
			name = L["Spec Icon"],
			get = function(info) return E.db.unitframe.units.arena.pvpSpecIcon[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.arena.pvpSpecIcon[info[#info]] = value UF:CreateAndUpdateUFGroup("arena", 5) end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"],
					desc = L["Display icon on arena frame indicating the units talent specialization or the units faction if inside a battleground."]
				},
				width = {
					order = 2,
					type = "range",
					name = L["Size Override"],
					min = 0, max = 150, step = 1,
					disabled = function() return not E.db.unitframe.units.arena.pvpSpecIcon.enable end
				}
			}
		},
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateUFGroup, "arena", 5),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUFGroup, "arena", 5),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUFGroup, "arena", 5),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUFGroup, "arena", 5),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateUFGroup, "arena", 5),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUFGroup, "arena", 5),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUFGroup, "arena", 5),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateUFGroup, "arena", 5),
		buffs = GetOptionsTable_Auras("buffs", UF.CreateAndUpdateUFGroup, "arena", 5),
		debuffs = GetOptionsTable_Auras("debuffs", UF.CreateAndUpdateUFGroup, "arena", 5),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUFGroup, "arena", 5),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateUFGroup, "arena", 5)
	}
}

--Party
E.Options.args.unitframe.args.groupUnits.args.party = {
	order = 9,
	type = "group",
	name = L["PARTY"],
	get = function(info) return E.db.unitframe.units.party[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.party[info[#info]] = value UF:CreateAndUpdateHeaderGroup("party") end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"]
		},
		configureToggle = {
			order = 2,
			type = "execute",
			name = L["Display Frames"],
			func = function()
				UF:HeaderConfig(ElvUF_Party, ElvUF_Party.forceShow ~= true or nil)
			end
		},
		resetSettings = {
			order = 3,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show("RESET_UF_UNIT", L["PARTY"], nil, {unit="party", mover="Party Frames"}) end
		},
		copyFrom = {
			order = 4,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				raid = L["RAID"],
				raid40 = L["Raid-40"]
			},
			set = function(info, value) UF:MergeUnitSettings(value, "party", true) E:RefreshGUI() end,
			confirm = true
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateHeaderGroup, "party"),
		petsGroup = {
			type = "group",
			name = L["Party Pets"],
			get = function(info) return E.db.unitframe.units.party.petsGroup[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.party.petsGroup[info[#info]] = value UF:CreateAndUpdateHeaderGroup("party") end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"]
				},
				anchorPoint = {
					order = 2,
					type = "select",
					name = L["Anchor Point"],
					desc = L["What point to anchor to the frame you set to attach to."],
					values = petAnchors
				},
				threatStyle = {
					order = 3,
					type = "select",
					name = L["Threat Display Mode"],
					values = {
						GLOW = L["Glow"],
						BORDERS = L["Borders"],
						HEALTHBORDER = L["Health Border"],
						ICONTOPLEFT = L["Icon: TOPLEFT"],
						ICONTOPRIGHT = L["Icon: TOPRIGHT"],
						ICONBOTTOMLEFT = L["Icon: BOTTOMLEFT"],
						ICONBOTTOMRIGHT = L["Icon: BOTTOMRIGHT"],
						ICONLEFT = L["Icon: LEFT"],
						ICONRIGHT = L["Icon: RIGHT"],
						ICONTOP = L["Icon: TOP"],
						ICONBOTTOM = L["Icon: BOTTOM"],
						NONE = L["NONE"]
					}
				},
				width = {
					order = 4,
					type = "range",
					name = L["Width"],
					min = 10, max = 500, step = 1
				},
				height = {
					order = 5,
					type = "range",
					name = L["Height"],
					min = 5, max = 500, step = 1
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["X-Offset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["Y-Offset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1
				},
				colorPetByUnitClass = {
					order = 8,
					type = "toggle",
					name = L["Color by Unit Class"]
				},
				name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, "party", nil, "petsGroup"),
				raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, "party", nil, "petsGroup"),
				healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, "party", nil, "petsGroup")
			}
		},
		targetsGroup = {
			type = "group",
			name = L["Party Targets"],
			get = function(info) return E.db.unitframe.units.party.targetsGroup[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.party.targetsGroup[info[#info]] = value UF:CreateAndUpdateHeaderGroup("party") end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"]
				},
				anchorPoint = {
					order = 2,
					type = "select",
					name = L["Anchor Point"],
					desc = L["What point to anchor to the frame you set to attach to."],
					values = petAnchors
				},
				threatStyle = {
					order = 3,
					type = "select",
					name = L["Threat Display Mode"],
					values = {
						GLOW = L["Glow"],
						BORDERS = L["Borders"],
						HEALTHBORDER = L["Health Border"],
						ICONTOPLEFT = L["Icon: TOPLEFT"],
						ICONTOPRIGHT = L["Icon: TOPRIGHT"],
						ICONBOTTOMLEFT = L["Icon: BOTTOMLEFT"],
						ICONBOTTOMRIGHT = L["Icon: BOTTOMRIGHT"],
						ICONLEFT = L["Icon: LEFT"],
						ICONRIGHT = L["Icon: RIGHT"],
						ICONTOP = L["Icon: TOP"],
						ICONBOTTOM = L["Icon: BOTTOM"],
						NONE = L["NONE"]
					}
				},
				width = {
					order = 4,
					type = "range",
					name = L["Width"],
					min = 10, max = 500, step = 1
				},
				height = {
					order = 5,
					type = "range",
					name = L["Height"],
					min = 5, max = 500, step = 1
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["X-Offset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["Y-Offset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1
				},
				name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, "party", nil, "targetsGroup"),
				raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, "party", nil, "targetsGroup")
			}
		},
		buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, "party"),
		buffs = GetOptionsTable_Auras("buffs", UF.CreateAndUpdateHeaderGroup, "party"),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateHeaderGroup, "party", 5),
		classbar = GetOptionsTable_ClassBar(UF.CreateAndUpdateHeaderGroup, "party"),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, "party"),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateHeaderGroup, "party"),
		debuffs = GetOptionsTable_Auras("debuffs", UF.CreateAndUpdateHeaderGroup, "party"),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateHeaderGroup, "party"),
		GPSArrow = GetOptionsTable_GPS(UF.CreateAndUpdateHeaderGroup, "party"),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, "party"),
		health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, "party"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateHeaderGroup, "party"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, "party"),
		phaseIndicator = GetOptionsTable_PhaseIndicator(UF.CreateAndUpdateHeaderGroup, "party"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, "party"),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateHeaderGroup, "party"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, "party"),
		raidRoleIcons = GetOptionsTable_RaidRoleIcons(UF.CreateAndUpdateHeaderGroup, "party"),
		roleIcon = GetOptionsTable_RoleIcons(UF.CreateAndUpdateHeaderGroup, "party"),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, "party"),
		readycheckIcon = GetOptionsTable_ReadyCheckIcon(UF.CreateAndUpdateHeaderGroup, "party"),
		resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateHeaderGroup, "party")
	}
}
E.Options.args.unitframe.args.groupUnits.args.party.args.petsGroup.args.name.args.attachTextTo = nil
E.Options.args.unitframe.args.groupUnits.args.party.args.petsGroup.args.raidicon.args.attachToObject.values = {Health = L["HEALTH"], Frame = L["Frame"]}
E.Options.args.unitframe.args.groupUnits.args.party.args.targetsGroup.args.name.args.attachTextTo = nil
E.Options.args.unitframe.args.groupUnits.args.party.args.targetsGroup.args.raidicon.args.attachToObject.values = {Health = L["HEALTH"], Frame = L["Frame"]}

--Raid
E.Options.args.unitframe.args.groupUnits.args.raid = {
	order = 10,
	type = "group",
	name = L["RAID"],
	get = function(info) return E.db.unitframe.units.raid[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.raid[info[#info]] = value UF:CreateAndUpdateHeaderGroup("raid") end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"]
		},
		configureToggle = {
			order = 2,
			type = "execute",
			name = L["Display Frames"],
			func = function()
				UF:HeaderConfig(ElvUF_Raid, ElvUF_Raid.forceShow ~= true or nil)
			end
		},
		resetSettings = {
			order = 3,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show("RESET_UF_UNIT", L["RAID"], nil, {unit = "raid", mover="Raid Frames"}) end
		},
		copyFrom = {
			order = 4,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				party = L["PARTY"],
				raid40 = L["Raid-40"]
			},
			set = function(info, value) UF:MergeUnitSettings(value, "raid", true) E:RefreshGUI() end,
			confirm = true
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateHeaderGroup, "raid"),
		buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, "raid"),
		buffs = GetOptionsTable_Auras("buffs", UF.CreateAndUpdateHeaderGroup, "raid"),
		classbar = GetOptionsTable_ClassBar(UF.CreateAndUpdateHeaderGroup, "raid"),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, "raid"),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateHeaderGroup, "raid"),
		debuffs = GetOptionsTable_Auras("debuffs", UF.CreateAndUpdateHeaderGroup, "raid"),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateHeaderGroup, "raid"),
		GPSArrow = GetOptionsTable_GPS(UF.CreateAndUpdateHeaderGroup, "raid"),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, "raid"),
		health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, "raid"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateHeaderGroup, "raid"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, "raid"),
		phaseIndicator = GetOptionsTable_PhaseIndicator(UF.CreateAndUpdateHeaderGroup, "raid"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, "raid"),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateHeaderGroup, "raid"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, "raid"),
		raidRoleIcons = GetOptionsTable_RaidRoleIcons(UF.CreateAndUpdateHeaderGroup, "raid"),
		roleIcon = GetOptionsTable_RoleIcons(UF.CreateAndUpdateHeaderGroup, "raid"),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, "raid"),
		readycheckIcon = GetOptionsTable_ReadyCheckIcon(UF.CreateAndUpdateHeaderGroup, "raid"),
		resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateHeaderGroup, "raid")
	}
}

--Raid-40
E.Options.args.unitframe.args.groupUnits.args.raid40 = {
	order = 11,
	type = "group",
	name = L["Raid-40"],
	get = function(info) return E.db.unitframe.units.raid40[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.raid40[info[#info]] = value UF:CreateAndUpdateHeaderGroup("raid40") end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"]
		},
		configureToggle = {
			order = 2,
			type = "execute",
			name = L["Display Frames"],
			func = function()
				UF:HeaderConfig(ElvUF_Raid40, ElvUF_Raid40.forceShow ~= true or nil)
			end
		},
		resetSettings = {
			order = 3,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show("RESET_UF_UNIT", L["Raid-40"], nil, {unit="raid40", mover="Raid Frames"}) end
		},
		copyFrom = {
			order = 4,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				party = L["PARTY"],
				raid = L["RAID"]
			},
			set = function(info, value) UF:MergeUnitSettings(value, "raid40", true) E:RefreshGUI() end,
			confirm = true
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateHeaderGroup, "raid40"),
		buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, "raid40"),
		buffs = GetOptionsTable_Auras("buffs", UF.CreateAndUpdateHeaderGroup, "raid40"),
		classbar = GetOptionsTable_ClassBar(UF.CreateAndUpdateHeaderGroup, "raid40"),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, "raid40"),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateHeaderGroup, "raid40"),
		debuffs = GetOptionsTable_Auras("debuffs", UF.CreateAndUpdateHeaderGroup, "raid40"),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateHeaderGroup, "raid40"),
		GPSArrow = GetOptionsTable_GPS(UF.CreateAndUpdateHeaderGroup, "raid40"),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, "raid40"),
		health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, "raid40"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateHeaderGroup, "raid40"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, "raid40"),
		phaseIndicator = GetOptionsTable_PhaseIndicator(UF.CreateAndUpdateHeaderGroup, "raid40"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, "raid40"),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateHeaderGroup, "raid40"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, "raid40"),
		raidRoleIcons = GetOptionsTable_RaidRoleIcons(UF.CreateAndUpdateHeaderGroup, "raid40"),
		roleIcon = GetOptionsTable_RoleIcons(UF.CreateAndUpdateHeaderGroup, "raid40"),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, "raid40"),
		readycheckIcon = GetOptionsTable_ReadyCheckIcon(UF.CreateAndUpdateHeaderGroup, "raid40"),
		resurrectIcon = GetOptionsTable_ResurrectIcon(UF.CreateAndUpdateHeaderGroup, "raid40")
	}
}

--Raid Pet
E.Options.args.unitframe.args.groupUnits.args.raidpet = {
	order = 12,
	type = "group",
	name = L["Raid Pet"],
	get = function(info) return E.db.unitframe.units.raidpet[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.raidpet[info[#info]] = value UF:CreateAndUpdateHeaderGroup("raidpet") end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"]
		},
		configureToggle = {
			order = 2,
			type = "execute",
			name = L["Display Frames"],
			func = function()
				UF:HeaderConfig(ElvUF_Raidpet, ElvUF_Raidpet.forceShow ~= true or nil)
			end
		},
		resetSettings = {
			order = 3,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show("RESET_UF_UNIT", L["Raid Pet"], nil, {unit="raidpet", mover="Raid Pet Frames"}) end
		},
		copyFrom = {
			order = 4,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				party = L["PARTY"],
				raid = L["RAID"]
			},
			set = function(info, value) UF:MergeUnitSettings(value, "raidpet", true) E:RefreshGUI() end,
			confirm = true
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateHeaderGroup, "raidpet"),
		buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, "raidpet"),
		buffs = GetOptionsTable_Auras("buffs", UF.CreateAndUpdateHeaderGroup, "raidpet"),
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, "raidpet"),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateHeaderGroup, "raidpet"),
		debuffs = GetOptionsTable_Auras("debuffs", UF.CreateAndUpdateHeaderGroup, "raidpet"),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateHeaderGroup, "raidpet"),
		healPredction = GetOptionsTable_HealPrediction(UF.CreateAndUpdateHeaderGroup, "raidpet"),
		health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, "raidpet"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, "raidpet"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, "raidpet"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, "raidpet"),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, "raidpet")
	}
}
E.Options.args.unitframe.args.groupUnits.args.raidpet.args.health.args.attachTextTo.values = {Health = L["HEALTH"], Frame = L["Frame"]}
E.Options.args.unitframe.args.groupUnits.args.raidpet.args.name.args.attachTextTo.values = {Health = L["HEALTH"], Frame = L["Frame"]}
E.Options.args.unitframe.args.groupUnits.args.raidpet.args.raidicon.args.attachToObject.values = {Health = L["HEALTH"], Frame = L["Frame"]}

--Tank
E.Options.args.unitframe.args.groupUnits.args.tank = {
	order = 13,
	type = "group",
	name = L["TANK"],
	get = function(info) return E.db.unitframe.units.tank[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.tank[info[#info]] = value UF:CreateAndUpdateHeaderGroup("tank") end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"]
		},
		resetSettings = {
			order = 2,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show("RESET_UF_UNIT", L["TANK"], nil, {unit="tank"}) end
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateHeaderGroup, "tank"),
		targetsGroup = {
			order = 4,
			type = "group",
			name = L["Tank Target"],
			get = function(info) return E.db.unitframe.units.tank.targetsGroup[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.tank.targetsGroup[info[#info]] = value UF:CreateAndUpdateHeaderGroup("tank") end,
			args = {
				enable = {
					order = 2,
					type = "toggle",
					name = L["ENABLE"]
				},
				width = {
					order = 3,
					type = "range",
					name = L["Width"],
					min = 10, max = 500, step = 1
				},
				height = {
					order = 4,
					type = "range",
					name = L["Height"],
					min = 5, max = 500, step = 1
				},
				anchorPoint = {
					order = 5,
					type = "select",
					name = L["Anchor Point"],
					desc = L["What point to anchor to the frame you set to attach to."],
					values = petAnchors
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["X-Offset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["Y-Offset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1
				},
				name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, "tank", nil, "targetsGroup"),
				raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, "tank", nil, "targetsGroup")
			}
		},
		buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, "tank"),
		buffs = GetOptionsTable_Auras("buffs", UF.CreateAndUpdateHeaderGroup, "tank"),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateHeaderGroup, "tank"),
		debuffs = GetOptionsTable_Auras("debuffs", UF.CreateAndUpdateHeaderGroup, "tank"),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateHeaderGroup, "tank"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, "tank"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, "tank"),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, "tank")
	}
}
E.Options.args.unitframe.args.groupUnits.args.tank.args.name.args.attachTextTo.values = {Health = L["HEALTH"], Frame = L["Frame"]}
E.Options.args.unitframe.args.groupUnits.args.tank.args.raidicon.args.attachToObject.values = {Health = L["HEALTH"], Frame = L["Frame"]}
E.Options.args.unitframe.args.groupUnits.args.tank.args.targetsGroup.args.name.args.attachTextTo.values = {Health = L["HEALTH"], Frame = L["Frame"]}
E.Options.args.unitframe.args.groupUnits.args.tank.args.targetsGroup.args.raidicon.args.attachToObject.values = {Health = L["HEALTH"], Frame = L["Frame"]}

--Assist
E.Options.args.unitframe.args.groupUnits.args.assist = {
	order = 14,
	type = "group",
	name = L["Assist"],
	get = function(info) return E.db.unitframe.units.assist[info[#info]] end,
	set = function(info, value) E.db.unitframe.units.assist[info[#info]] = value UF:CreateAndUpdateHeaderGroup("assist") end,
	disabled = function() return not E.UnitFrames.Initialized end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"]
		},
		resetSettings = {
			order = 2,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info) E:StaticPopup_Show("RESET_UF_UNIT", L["Assist"], nil, {unit="assist"}) end
		},
		generalGroup = GetOptionsTable_GeneralGroup(UF.CreateAndUpdateHeaderGroup, "assist"),
		targetsGroup = {
			order = 4,
			type = "group",
			name = L["Assist Target"],
			get = function(info) return E.db.unitframe.units.assist.targetsGroup[info[#info]] end,
			set = function(info, value) E.db.unitframe.units.assist.targetsGroup[info[#info]] = value UF:CreateAndUpdateHeaderGroup("assist") end,
			args = {
				enable = {
					order = 2,
					type = "toggle",
					name = L["ENABLE"]
				},
				width = {
					order = 3,
					type = "range",
					name = L["Width"],
					min = 10, max = 500, step = 1
				},
				height = {
					order = 4,
					type = "range",
					name = L["Height"],
					min = 5, max = 500, step = 1
				},
				anchorPoint = {
					order = 5,
					type = "select",
					name = L["Anchor Point"],
					desc = L["What point to anchor to the frame you set to attach to."],
					values = petAnchors
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["X-Offset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["Y-Offset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1
				},
				name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, "assist", nil, "targetsGroup"),
				raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, "assist", nil, "targetsGroup")
			}
		},
		buffIndicator = GetOptionsTable_AuraWatch(UF.CreateAndUpdateHeaderGroup, "assist"),
		buffs = GetOptionsTable_Auras("buffs", UF.CreateAndUpdateHeaderGroup, "assist"),
		cutaway = GetOptionsTable_Cutaway(UF.CreateAndUpdateHeaderGroup, "assist"),
		debuffs = GetOptionsTable_Auras("debuffs", UF.CreateAndUpdateHeaderGroup, "assist"),
		fader = GetOptionsTable_Fader(UF.CreateAndUpdateHeaderGroup, "assist"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, "assist"),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, "assist"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, "assist")
	}
}
E.Options.args.unitframe.args.groupUnits.args.assist.args.name.args.attachTextTo.values = {Health = L["HEALTH"], Frame = L["Frame"]}
E.Options.args.unitframe.args.groupUnits.args.assist.args.raidicon.args.attachToObject.values = {Health = L["HEALTH"], Frame = L["Frame"]}
E.Options.args.unitframe.args.groupUnits.args.assist.args.targetsGroup.args.name.args.attachTextTo.values = {Health = L["HEALTH"], Frame = L["Frame"]}
E.Options.args.unitframe.args.groupUnits.args.assist.args.targetsGroup.args.raidicon.args.attachToObject.values = {Health = L["HEALTH"], Frame = L["Frame"]}

--MORE COLORING STUFF YAY
E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup = {
	order = -10,
	type = "group",
	name = L["Class Resources"],
	get = function(info)
		local t = E.db.unitframe.colors.classResources[info[#info]]
		local d = P.unitframe.colors.classResources[info[#info]]
		return t.r, t.g, t.b, t.a, d.r, d.g, d.b
	end,
	set = function(info, r, g, b)
		local t = E.db.unitframe.colors.classResources[info[#info]]
		t.r, t.g, t.b = r, g, b
		UF:Update_AllFrames()
	end,
	args = {
		customclasspowerbackdrop = {
			order = 0.1,
			type = "toggle",
			name = L["Custom Backdrop"],
			desc = L["Use the custom backdrop color instead of a multiple of the main color."],
			get = function(info) return E.db.unitframe.colors[info[#info]] end,
			set = function(info, value) E.db.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end
		},
		classpower_backdrop = {
			order = 0.2,
			type = "color",
			name = L["Custom Backdrop"],
			disabled = function() return not E.db.unitframe.colors.customclasspowerbackdrop end,
			get = function(info)
				local t = E.db.unitframe.colors[info[#info]]
				local d = P.unitframe.colors[info[#info]]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b
			end,
			set = function(info, r, g, b)
				local t = E.db.unitframe.colors[info[#info]]
				t.r, t.g, t.b = r, g, b
				UF:Update_AllFrames()
			end,
		},
		spacer2 = {
			order = 0.3,
			type = "description",
			name = " ",
			width = "full"
		}
	}
}

for i = 1, 5 do
	E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args["combo"..i] = {
		order = i + 2,
		type = "color",
		name = L["Combo Point"].." #"..i,
		get = function(info)
			local t = E.db.unitframe.colors.classResources.comboPoints[i]
			local d = P.unitframe.colors.classResources.comboPoints[i]
			return t.r, t.g, t.b, t.a, d.r, d.g, d.b
		end,
		set = function(info, r, g, b)
			local t = E.db.unitframe.colors.classResources.comboPoints[i]
			t.r, t.g, t.b = r, g, b
			UF:Update_AllFrames()
		end
	}
end

if P.unitframe.colors.classResources[E.myclass] then
	E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args.spacer3 = {
		order = 10,
		type = "description",
		name = " ",
		width = "full"
	}

	local ORDER = 20
	if E.myclass == "PALADIN" then
		E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args[E.myclass] = {
			order = ORDER,
			type = "color",
			name = L["HOLY_POWER"]
		}
	elseif E.myclass == "MAGE" then
		E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args[E.myclass] = {
			order = ORDER,
			type = "color",
			name = L["Arcane Charges"]
		}
	elseif E.myclass == "ROGUE" then
		for i = 1, 5 do
			E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args["resource"..i] = {
				order = ORDER + i,
				type = "color",
				name = L["Anticipation"].." #"..i,
				get = function(info)
					local t = E.db.unitframe.colors.classResources.ROGUE[i]
					local d = P.unitframe.colors.classResources.ROGUE[i]
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					local t = E.db.unitframe.colors.classResources.ROGUE[i]
					t.r, t.g, t.b = r, g, b
					UF:Update_AllFrames()
				end
			}
		end
	elseif E.myclass == "PRIEST" then
		E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args[E.myclass] = {
			order = ORDER,
			type = "color",
			name = L["SHADOW_ORBS"]
		}
	elseif E.myclass == "WARLOCK" then
		local names = {
			[1] = L["SOUL_SHARDS"],
			[2] = L["DEMONIC_FURY"],
			[3] = L["BURNING_EMBERS"]
		}
		for i = 1, 3 do
			E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args["resource"..i] = {
				type = "color",
				name = names[i],
				order = ORDER + i,
				get = function(info)
					local t = E.db.unitframe.colors.classResources.WARLOCK[i]
					local d = P.unitframe.colors.classResources.WARLOCK[i]
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					local t = E.db.unitframe.colors.classResources.WARLOCK[i]
					t.r, t.g, t.b = r, g, b
					UF:Update_AllFrames()
				end
			}
		end
	elseif E.myclass == "MONK" then
		for i = 1, 5 do
			E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args["resource"..i] = {
				order = ORDER + i,
				type = "color",
				name = L["CHI_POWER"].." #"..i,
				get = function(info)
					local t = E.db.unitframe.colors.classResources.MONK[i]
					local d = P.unitframe.colors.classResources.MONK[i]
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					local t = E.db.unitframe.colors.classResources.MONK[i]
					t.r, t.g, t.b = r, g, b
					UF:Update_AllFrames()
				end
			}
		end
	elseif E.myclass == "DRUID" then
		local names = {
			[1] = L["BALANCE_NEGATIVE_ENERGY"],
			[2] = L["BALANCE_POSITIVE_ENERGY"]
		}
		for i = 1, 2 do
			E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args["resource"..i] = {
				order = ORDER + i,
				type = "color",
				name = names[i],
				get = function(info)
					local t = E.db.unitframe.colors.classResources.DRUID[i]
					local d = P.unitframe.colors.classResources.DRUID[i]
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					local t = E.db.unitframe.colors.classResources.DRUID[i]
					t.r, t.g, t.b = r, g, b
					UF:Update_AllFrames()
				end
			}
		end
	elseif E.myclass == "DEATHKNIGHT" then
		local names = {
			[1] = L["COMBAT_TEXT_RUNE_BLOOD"],
			[2] = L["COMBAT_TEXT_RUNE_UNHOLY"],
			[3] = L["COMBAT_TEXT_RUNE_FROST"],
			[4] = L["COMBAT_TEXT_RUNE_DEATH"]
		}
		for i = 1, 4 do
			E.Options.args.unitframe.args.generalOptionsGroup.args.allColorsGroup.args.classResourceGroup.args["resource"..i] = {
				order = ORDER + i,
				type = "color",
				name = names[i],
				get = function(info)
					local t = E.db.unitframe.colors.classResources.DEATHKNIGHT[i]
					local d = P.unitframe.colors.classResources.DEATHKNIGHT[i]
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					local t = E.db.unitframe.colors.classResources.DEATHKNIGHT[i]
					t.r, t.g, t.b = r, g, b
					UF:Update_AllFrames()
				end
			}
		end
	end
end

--Custom Texts
function E:RefreshCustomTextsConfigs()
	--Hide any custom texts that don't belong to current profile
	for _, customText in pairs(CUSTOMTEXT_CONFIGS) do
		customText.hidden = true
	end
	twipe(CUSTOMTEXT_CONFIGS)

	for unit in pairs(E.db.unitframe.units) do
		if E.db.unitframe.units[unit].customTexts then
			for objectName in pairs(E.db.unitframe.units[unit].customTexts) do
				CreateCustomTextGroup(unit, objectName)
			end
		end
	end
end
E:RefreshCustomTextsConfigs()