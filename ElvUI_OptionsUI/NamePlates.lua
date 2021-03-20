local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(select(2, ...))
local NP = E:GetModule("NamePlates")
local ACD = E.Libs.AceConfigDialog

local next, ipairs, pairs, type, tonumber, tostring = next, ipairs, pairs, type, tonumber, tostring
local tremove, tinsert, tconcat = tremove, tinsert, table.concat
local format, match, gsub, strsplit = string.format, string.match, string.gsub, strsplit

local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetInstanceInfo = GetInstanceInfo
local GetMapNameByID = GetMapNameByID
local GetRealZoneText = GetRealZoneText
local GetSpellInfo = GetSpellInfo
local GetSubZoneText = GetSubZoneText

local positionValues = {
	LEFT = L["Left"],
	RIGHT = L["Right"],
	TOPLEFT = L["Top Left"],
	TOPRIGHT = L["Top Right"],
	BOTTOMLEFT = L["Bottom Left"],
	BOTTOMRIGHT = L["Bottom Right"]
}

local textValues = {
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

local totemsColor = {
	earth = "|cff5cde23",
	fire = "|cffe64717",
	water = "|cff17bdff",
	air = "|cff9d47ff"
}

local raidTargetIcon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%s:0|t %s"

local selectedNameplateFilter
local carryFilterFrom, carryFilterTo

local function filterMatch(s, v)
	local m1, m2, m3, m4 = "^"..v.."$", "^"..v..",", ","..v.."$", ","..v..","
	return (match(s, m1) and m1) or (match(s, m2) and m2) or (match(s, m3) and m3) or (match(s, m4) and v..",")
end

local function filterPriority(auraType, unit, value, remove, movehere)
	if not auraType or not value then return end
	local filter = E.db.nameplates.units[unit] and E.db.nameplates.units[unit][auraType] and E.db.nameplates.units[unit][auraType].filters and E.db.nameplates.units[unit][auraType].filters.priority
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
		E.db.nameplates.units[unit][auraType].filters.priority = tconcat(tbl, ",")
	elseif found and remove then
		E.db.nameplates.units[unit][auraType].filters.priority = gsub(filter, found, "")
	elseif not found and not remove then
		E.db.nameplates.units[unit][auraType].filters.priority = (filter == "" and value) or (filter..","..value)
	end
end

local function UpdateInstanceDifficulty()
	if E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.party then
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.dungeonDifficulty = {
			order = 10,
			type = "group",
			name = L["DUNGEON_DIFFICULTY"],
			desc = L["Check these to only have the filter active in certain difficulties. If none are checked, it is active in all difficulties."],
			guiInline = true,
			get = function(info) return E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceDifficulty.dungeon[info[#info]] end,
			set = function(info, value)
				E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceDifficulty.dungeon[info[#info]] = value
				UpdateInstanceDifficulty()
				NP:ConfigureAll()
			end,
			args = {
				normal = {
					order = 1,
					type = "toggle",
					name = L["PLAYER_DIFFICULTY1"]
				},
				heroic = {
					order = 2,
					type = "toggle",
					name = L["PLAYER_DIFFICULTY2"]
				}
			}
		}
	else
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.dungeonDifficulty = nil
	end

	if E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.raid then
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.raidDifficulty = {
			order = 11,
			type = "group",
			name = L["Raid Difficulty"],
			desc = L["Check these to only have the filter active in certain difficulties. If none are checked, it is active in all difficulties."],
			guiInline = true,
			get = function(info) return E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceDifficulty.raid[info[#info]] end,
			set = function(info, value)
				E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceDifficulty.raid[info[#info]] = value
				UpdateInstanceDifficulty()
				NP:ConfigureAll()
			end,
			args = {
				lfr = {
					order = 1,
					type = "toggle",
					name = L["PLAYER_DIFFICULTY3"]
				},
				normal = {
					order = 2,
					type = "toggle",
					name = L["PLAYER_DIFFICULTY1"]
				},
				heroic = {
					order = 3,
					type = "toggle",
					name = L["PLAYER_DIFFICULTY2"]
				}
			}
		}
	else
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.raidDifficulty = nil
	end
end

local function UpdateStyleLists()
	if E.global.nameplates.filters[selectedNameplateFilter] and E.global.nameplates.filters[selectedNameplateFilter].triggers and E.global.nameplates.filters[selectedNameplateFilter].triggers.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.names.args.names = {
			order = 50,
			type = "group",
			name = "",
			guiInline = true,
			args = {}
		}
		if next(E.global.nameplates.filters[selectedNameplateFilter].triggers.names) then
			for name in pairs(E.global.nameplates.filters[selectedNameplateFilter].triggers.names) do
				E.Options.args.nameplate.args.filters.args.triggers.args.names.args.names.args[name] = {
					order = -1,
					type = "toggle",
					name = name,
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers and E.global.nameplates.filters[selectedNameplateFilter].triggers.names and E.global.nameplates.filters[selectedNameplateFilter].triggers.names[name]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.names[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end
	if E.global.nameplates.filters[selectedNameplateFilter] and E.global.nameplates.filters[selectedNameplateFilter].triggers.casting and E.global.nameplates.filters[selectedNameplateFilter].triggers.casting.spells then
		E.Options.args.nameplate.args.filters.args.triggers.args.casting.args.spells = {
			order = 50,
			type = "group",
			name = "",
			guiInline = true,
			args = {}
		}
		if next(E.global.nameplates.filters[selectedNameplateFilter].triggers.casting.spells) then
			local spell, spellName, notDisabled
			for name in pairs(E.global.nameplates.filters[selectedNameplateFilter].triggers.casting.spells) do
				spell = name
				if tonumber(spell) then
					spellName = GetSpellInfo(spell)
					notDisabled = (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					if spellName then
						if notDisabled then
							spell = format("|cFFffff00%s|r |cFFffffff(%d)|r", spellName, spell)
						else
							spell = format("%s (%d)", spellName, spell)
						end
					end
				end
				E.Options.args.nameplate.args.filters.args.triggers.args.casting.args.spells.args[name] = {
					order = -1,
					type = "toggle",
					name = spell,
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers and E.global.nameplates.filters[selectedNameplateFilter].triggers.casting.spells and E.global.nameplates.filters[selectedNameplateFilter].triggers.casting.spells[name]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.casting.spells[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end

	if E.global.nameplates.filters[selectedNameplateFilter] and E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns and E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.cooldowns.args.names = {
			order = 50,
			type = "group",
			name = "",
			guiInline = true,
			args = {}
		}
		if next(E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.names) then
			local spell, spellName, notDisabled
			for name in pairs(E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.names) do
				spell = name
				if tonumber(spell) then
					spellName = GetSpellInfo(spell)
					notDisabled = (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					if spellName then
						if notDisabled then
							spell = format("|cFFffff00%s|r |cFFffffff(%d)|r", spellName, spell)
						else
							spell = format("%s (%d)", spellName, spell)
						end
					end
				end
				E.Options.args.nameplate.args.filters.args.triggers.args.cooldowns.args.names.args[name] = {
					order = -1,
					type = "select",
					name = spell,
					values = {
						["DISABLED"] = L["DISABLE"],
						["ONCD"] = L["On Cooldown"],
						["OFFCD"] = L["Off Cooldown"]
					},
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers and E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.names and E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.names[name]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.names[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end

	if E.global.nameplates.filters[selectedNameplateFilter] and E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.buffs.args.names = {
			order = 50,
			type = "group",
			name = "",
			guiInline = true,
			args = {}
		}
		if next(E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.names) then
			local spell, spellName, notDisabled
			for name in pairs(E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.names) do
				spell = name
				if tonumber(spell) then
					spellName = GetSpellInfo(spell)
					notDisabled = (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					if spellName then
						if notDisabled then
							spell = format("|cFFffff00%s|r |cFFffffff(%d)|r", spellName, spell)
						else
							spell = format("%s (%d)", spellName, spell)
						end
					end
				end
				E.Options.args.nameplate.args.filters.args.triggers.args.buffs.args.names.args[name] = {
					order = -1,
					type = "toggle",
					name = spell,
					textWidth = true,
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers and E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.names and E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.names[name]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.names[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end

	if E.global.nameplates.filters[selectedNameplateFilter] and E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.debuffs.args.names = {
			order = 50,
			type = "group",
			name = "",
			guiInline = true,
			args = {}
		}
		if next(E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.names) then
			local spell, spellName, notDisabled
			for name in pairs(E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.names) do
				spell = name
				if tonumber(spell) then
					spellName = GetSpellInfo(spell)
					notDisabled = (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					if spellName then
						if notDisabled then
							spell = format("|cFFffff00%s|r |cFFffffff(%d)|r", spellName, spell)
						else
							spell = format("%s (%d)", spellName, spell)
						end
					end
				end
				E.Options.args.nameplate.args.filters.args.triggers.args.debuffs.args.names.args[name] = {
					textWidth = true,
					order = -1,
					type = "toggle",
					name = spell,
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers and E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.names and E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.names[name]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.names[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end

	if E.global.nameplates.filters[selectedNameplateFilter] and E.global.nameplates.filters[selectedNameplateFilter].triggers.totems then
		for totemSchool in pairs(G.nameplates.totemTypes) do
			local titemSchoolLoc, order

			if totemSchool == "fire" then
				titemSchoolLoc, order = BINDING_NAME_MULTICASTACTIONBUTTON10, 51
			elseif totemSchool == "earth" then
				titemSchoolLoc, order = BINDING_NAME_MULTICASTACTIONBUTTON1, 50
			elseif totemSchool == "water" then
				titemSchoolLoc, order = BINDING_NAME_MULTICASTACTIONBUTTON11, 52
			elseif totemSchool == "air" then
				titemSchoolLoc, order = BINDING_NAME_MULTICASTACTIONBUTTON12, 53
			elseif totemSchool == "other" then
				titemSchoolLoc, order = OTHER, 54
			end

			E.Options.args.nameplate.args.filters.args.triggers.args.totems.args[totemSchool] = {
				order = order,
				type = "group",
				name = (totemsColor[totemSchool] or "")..titemSchoolLoc,
				guiInline = true,
				disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].triggers.totems.enable end,
				args = {}
			}
		end

		for totem, data in pairs(NP.TriggerConditions.totems) do
			E.Options.args.nameplate.args.filters.args.triggers.args.totems.args[data[2]].args[totem] = {
				order = -1,
				type = "toggle",
				name = data[1],
				textWidth = true,
				get = function(info)
					return E.global.nameplates.filters[selectedNameplateFilter].triggers and E.global.nameplates.filters[selectedNameplateFilter].triggers.totems and E.global.nameplates.filters[selectedNameplateFilter].triggers.totems[totem]
				end,
				set = function(info, value)
					E.global.nameplates.filters[selectedNameplateFilter].triggers.totems[totem] = value
					NP:ConfigureAll()
				end
			}
		end
	end

	if E.global.nameplates.filters[selectedNameplateFilter] and E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits then
		for unitType in pairs(G.nameplates.uniqueUnitTypes) do
			local name, order

			if unitType == "pvp" then
				name, order = "PvP", 50
			elseif unitType == "pve" then
				name, order = "PvE", 51
			end

			E.Options.args.nameplate.args.filters.args.triggers.args.uniqueUnits.args[unitType] = {
				order = order,
				type = "group",
				name = name,
				guiInline = true,
				disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits.enable end,
				args = {}
			}
		end

		for unit, data in pairs(NP.TriggerConditions.uniqueUnits) do
			E.Options.args.nameplate.args.filters.args.triggers.args.uniqueUnits.args[data[2]].args[unit] = {
				textWidth = true,
				order = -1,
				type = "toggle",
				name = data[1],
				get = function(info)
					return E.global.nameplates.filters[selectedNameplateFilter].triggers and E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits and E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits[unit]
				end,
				set = function(info, value)
					E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits[unit] = value
					NP:ConfigureAll()
				end
			}
		end
	end
end

local function UpdateFilterGroup()
	if not selectedNameplateFilter or not E.global.nameplates.filters[selectedNameplateFilter] then
		E.Options.args.nameplate.args.filters.args.header = nil
		E.Options.args.nameplate.args.filters.args.actions = nil
		E.Options.args.nameplate.args.filters.args.triggers = nil
	end
	if selectedNameplateFilter and E.global.nameplates.filters[selectedNameplateFilter] then
		E.Options.args.nameplate.args.filters.args.triggers = {
			order = 5,
			type = "group",
			name = L["Triggers"],
			args = {
				enable = {
					order = 0,
					type = "toggle",
					name = L["ENABLE"],
					get = function(info)
						return (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					set = function(info, value)
						if not E.db.nameplates then E.db.nameplates = {} end
						if not E.db.nameplates.filters then E.db.nameplates.filters = {} end
						if not E.db.nameplates.filters[selectedNameplateFilter] then E.db.nameplates.filters[selectedNameplateFilter] = {} end
						if not E.db.nameplates.filters[selectedNameplateFilter].triggers then E.db.nameplates.filters[selectedNameplateFilter].triggers = {} end
						E.db.nameplates.filters[selectedNameplateFilter].triggers.enable = value
						UpdateStyleLists() --we need this to recolor the spellid based on wether or not the filter is disabled
						NP:ConfigureAll()
					end
				},
				priority = {
					order = 1,
					type = "range",
					name = L["Filter Priority"],
					desc = L["Lower numbers mean a higher priority. Filters are processed in order from 1 to 100."],
					min = 1, max = 100, step = 1,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers.priority or 1
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.priority = value
						NP:ConfigureAll()
					end
				},
				resetFilter = {
					order = 2,
					type = "execute",
					name = L["Clear Filter"],
					desc = L["Return filter to its default state."],
					func = function()
						local filter = {}
						if G.nameplates.filters[selectedNameplateFilter] then
							filter = E:CopyTable(filter, G.nameplates.filters[selectedNameplateFilter])
						end
						NP:StyleFilterCopyDefaults(filter)
						E.global.nameplates.filters[selectedNameplateFilter] = filter
						UpdateStyleLists()
						UpdateInstanceDifficulty()
						NP:ConfigureAll()
					end
				},
				spacer1 = {
					order = 3,
					type = "description",
					name = ""
				},
				names = {
					order = 4,
					type = "group",
					name = L["NAME"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						addName = {
							order = 1,
							type = "input",
							name = L["Add Name"],
							desc = L["Add a Name to the list."],
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.names[value] = true
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeName = {
							order = 2,
							type = "input",
							name = L["Remove Name"],
							desc = L["Remove a Name from the list."],
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.names[value] = nil
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						}
					}
				},
				targeting = {
					order = 5,
					type = "group",
					name = L["Targeting"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter]
						and E.db.nameplates.filters[selectedNameplateFilter].triggers
						and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						isTarget = {
							order = 1,
							type = "toggle",
							name = L["Is Targeted"],
							desc = L["If enabled then the filter will only activate when you are targeting the unit."]
						},
						notTarget = {
							order = 2,
							type = "toggle",
							name = L["Not Targeted"],
							desc = L["If enabled then the filter will only activate when you are not targeting the unit."]
						},
						requireTarget = {
							order = 3,
							type = "toggle",
							name = L["Require Target"],
							desc = L["If enabled then the filter will only activate when you have a target."]
						}
					}
				},
				casting = {
					order = 6,
					type = "group",
					name = L["Casting"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers.casting[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.casting[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						types = {
							order = 1,
							type = "group",
							name = "",
							guiInline = true,
							args = {
								isCasting = {
									order = 1,
									type = "toggle",
									name = L["Is Casting Anything"],
									desc = L["If enabled then the filter will activate if the unit is casting anything."]
								},
								notCasting = {
									order = 2,
									type = "toggle",
									name = L["Not Casting Anything"],
									desc = L["If enabled then the filter will activate if the unit is not casting anything."]
								},
								isChanneling = {
									order = 3,
									type = "toggle",
									customWidth = 200,
									name = L["Is Channeling Anything"],
									desc = L["If enabled then the filter will activate if the unit is channeling anything."]
								},
								notChanneling = {
									order = 4,
									type = "toggle",
									customWidth = 200,
									name = L["Not Channeling Anything"],
									desc = L["If enabled then the filter will activate if the unit is not channeling anything."]
								},
								spacer1 = {
									order = 5,
									type = "description",
									name = " ",
									width = "full"
								},
								interruptible = {
									order = 6,
									type = "toggle",
									name = L["Interruptible"],
									desc = L["If enabled then the filter will only activate if the unit is casting interruptible spells."]
								},
								notInterruptible = {
									order = 7,
									type = "toggle",
									name = L["Non-Interruptable"],
									desc = L["If enabled then the filter will only activate if the unit is casting not interruptible spells."]
								}
							}
						},
						addSpell = {
							order = 9,
							type = "input",
							name = L["Add Name"],
							get = function(info)
								return ""
							end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then return end

								E.global.nameplates.filters[selectedNameplateFilter].triggers.casting.spells[value] = true
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeSpell = {
							order = 5,
							type = "input",
							name = L["Remove Name"],
							get = function(info)
								return ""
							end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then return end

								E.global.nameplates.filters[selectedNameplateFilter].triggers.casting.spells[value] = nil
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						description1 = {
							order = 12,
							type = "description",
							name = L["You do not need to use Is Casting Anything or Is Channeling Anything for these spells to trigger."]
						},
						description2 = {
							order = 13,
							type = "description",
							name = L["If this list is empty, and if Interruptible is checked, then the filter will activate on any type of cast that can be interrupted."]
						},
						notSpell = {
							order = -2,
							type = "toggle",
							name = L["Not Spell"],
							desc = L["If enabled then the filter will only activate if the unit is not casting or channeling one of the selected spells."]
						}
					}
				},
				combat = {
					order = 7,
					type = "group",
					name = L["Unit Conditions"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						inCombat = {
							order = 1,
							type = "toggle",
							name = L["Player in Combat"],
							desc = L["If enabled then the filter will only activate when you are in combat."],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.inCombat
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.inCombat = value
								NP:ConfigureAll()
							end
						},
						outOfCombat = {
							order = 2,
							type = "toggle",
							name = L["Player Out of Combat"],
							desc = L["If enabled then the filter will only activate when you are out of combat."],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.outOfCombat
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.outOfCombat = value
								NP:ConfigureAll()
							end
						},
						isResting = {
							order = 3,
							type = "toggle",
							name = L["Player is Resting"],
							desc = L["If enabled then the filter will only activate when you are resting at an Inn."],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.isResting
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.isResting = value
								NP:ConfigureAll()
							end
						}
					}
				},
				role = {
					order = 8,
					type = "group",
					name = L["ROLE"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						tank = {
							order = 1,
							type = "toggle",
							name = L["TANK"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.role.tank
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.role.tank = value
								NP:ConfigureAll()
							end,
						},
						healer = {
							order = 2,
							type = "toggle",
							name = L["HEALER"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.role.healer
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.role.healer = value
								NP:ConfigureAll()
							end
						},
						damager = {
							order = 3,
							type = "toggle",
							name = L["DAMAGER"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.role.damager
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.role.damager = value
								NP:ConfigureAll()
							end
						}
					}
				},
				health = {
					order = 9,
					type = "group",
					name = L["Health Threshold"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["ENABLE"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.healthThreshold
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.healthThreshold = value
								NP:ConfigureAll()
							end
						},
						usePlayer = {
							order = 2,
							type = "toggle",
							name = L["Player Health"],
							desc = L["Enabling this will check your health amount."],
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].triggers.healthThreshold end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.healthUsePlayer
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.healthUsePlayer = value
								NP:ConfigureAll()
							end
						},
						spacer1 = {
							order = 3,
							type = "description",
							name = " "
						},
						underHealthThreshold = {
							order = 4,
							type = "range",
							name = L["Under Health Threshold"],
							desc = L["If this threshold is used then the health of the unit needs to be lower than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0, max = 1, step = 0.01,
							isPercent = true,
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].triggers.healthThreshold end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.underHealthThreshold or 0
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.underHealthThreshold = value
								NP:ConfigureAll()
							end
						},
						overHealthThreshold = {
							order = 5,
							type = "range",
							name = L["Over Health Threshold"],
							desc = L["If this threshold is used then the health of the unit needs to be higher than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0, max = 1, step = 0.01,
							isPercent = true,
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].triggers.healthThreshold end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.overHealthThreshold or 0
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.overHealthThreshold = value
								NP:ConfigureAll()
							end
						}
					}
				},
				power = {
					order = 10,
					type = "group",
					name = L["Power Threshold"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						powerThreshold = {
							order = 1,
							type = "toggle",
							name = L["ENABLE"],
							desc = L["Enabling this will check your power amount."],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.powerThreshold
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.powerThreshold = value
								NP:ConfigureAll()
							end
						},
						spacer1 = {
							order = 2,
							type = "description",
							name = " "
						},
						underPowerThreshold = {
							order = 3,
							type = "range",
							name = L["Under Power Threshold"],
							desc = L["If this threshold is used then the power of the unit needs to be lower than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0, max = 1, step = 0.01,
							isPercent = true,
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].triggers.powerThreshold end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.underPowerThreshold or 0
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.underPowerThreshold = value
								NP:ConfigureAll()
							end
						},
						overPowerThreshold = {
							order = 4,
							type = "range",
							name = L["Over Power Threshold"],
							desc = L["If this threshold is used then the power of the unit needs to be higher than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0, max = 1, step = 0.01,
							isPercent = true,
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].triggers.powerThreshold end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.overPowerThreshold or 0
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.overPowerThreshold = value
								NP:ConfigureAll()
							end
						}
					}
				},
				levels = {
					order = 11,
					type = "group",
					name = L["LEVEL"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["ENABLE"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.level
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.level = value
								NP:ConfigureAll()
							end
						},
						matchLevel = {
							order = 2,
							type = "toggle",
							name = L["Match Player Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit matches your own."],
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].triggers.level end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.mylevel
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.mylevel = value
								NP:ConfigureAll()
							end
						},
						spacer1 = {
							order = 3,
							type = "description",
							name = L["LEVEL_BOSS"],
						},
						minLevel = {
							order = 4,
							type = "range",
							name = L["Minimum Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit is equal to or higher than this value."],
							min = -1, max = MAX_PLAYER_LEVEL+3, step = 1,
							disabled = function() return not (E.global.nameplates.filters[selectedNameplateFilter].triggers.level and not E.global.nameplates.filters[selectedNameplateFilter].triggers.mylevel) end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.minlevel or 0
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.minlevel = value
								NP:ConfigureAll()
							end
						},
						maxLevel = {
							order = 5,
							type = "range",
							name = L["Maximum Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit is equal to or lower than this value."],
							min = -1, max = MAX_PLAYER_LEVEL+3, step = 1,
							disabled = function() return not (E.global.nameplates.filters[selectedNameplateFilter].triggers.level and not E.global.nameplates.filters[selectedNameplateFilter].triggers.mylevel) end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.maxlevel or 0
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.maxlevel = value
								NP:ConfigureAll()
							end
						},
						currentLevel = {
							order = 6,
							type = "range",
							name = L["Current Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit matches this value."],
							min = -1, max = MAX_PLAYER_LEVEL+3, step = 1,
							disabled = function() return not (E.global.nameplates.filters[selectedNameplateFilter].triggers.level and not E.global.nameplates.filters[selectedNameplateFilter].triggers.mylevel) end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.curlevel or 0
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.curlevel = value
								NP:ConfigureAll()
							end
						}
					}
				},
				cooldowns = {
					order = 12,
					type = "group",
					name = L["Cooldowns"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						mustHaveAll = {
							order = 1,
							type = "toggle",
							name = L["Require All"],
							desc = L["If enabled then it will require all cooldowns to activate the filter. Otherwise it will only require any one of the cooldowns to activate it."],
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns and E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.mustHaveAll
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.mustHaveAll = value
								NP:ConfigureAll()
							end
						},
						spacer1 = {
							order = 5,
							type = "description",
							name = " "
						},
						addCooldown = {
							order = 6,
							type = "input",
							name = L["Add Spell ID or Name"],
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.names[value] = "ONCD"
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeCooldown = {
							order = 7,
							type = "input",
							name = L["Remove Spell ID or Name"],
							desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.names[value] = nil
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						}
					}
				},
				buffs = {
					order = 13,
					type = "group",
					name = L["Buffs"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						mustHaveAll = {
							order = 1,
							type = "toggle",
							name = L["Require All"],
							desc = L["If enabled then it will require all auras to activate the filter. Otherwise it will only require any one of the auras to activate it."],
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.mustHaveAll
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.mustHaveAll = value
								NP:ConfigureAll()
							end
						},
						missing = {
							order = 2,
							type = "toggle",
							name = L["Missing"],
							desc = L["If enabled then it checks if auras are missing instead of being present on the unit."],
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.missing
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.missing = value
								NP:ConfigureAll()
							end
						},
						spacer1 = {
							order = 3,
							type = "description",
							name = " ",
							width = "full"
						},
						minTimeLeft = {
							order = 4,
							type = "range",
							name = L["Minimum Time Left"],
							desc = L["Apply this filter if a buff has remaining time greater than this. Set to zero to disable."],
							min = 0, max = 10800, step = 1,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.minTimeLeft
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.minTimeLeft = value
								NP:ConfigureAll()
							end
						},
						maxTimeLeft = {
							order = 5,
							type = "range",
							name = L["Maximum Time Left"],
							desc = L["Apply this filter if a buff has remaining time less than this. Set to zero to disable."],
							min = 0, max = 10800, step = 1,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.maxTimeLeft
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.maxTimeLeft = value
								NP:ConfigureAll()
							end
						},
						spacer2 = {
							order = 6,
							type = "description",
							name = " "
						},
						addBuff = {
							order = 7,
							type = "input",
							name = L["Add Spell ID or Name"],
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.names[value] = true
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeBuff = {
							order = 8,
							type = "input",
							name = L["Remove Spell ID or Name"],
							desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.names[value] = nil
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						}
					}
				},
				debuffs = {
					order = 14,
					type = "group",
					name = L["Debuffs"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						mustHaveAll = {
							order = 1,
							name = L["Require All"],
							desc = L["If enabled then it will require all auras to activate the filter. Otherwise it will only require any one of the auras to activate it."],
							type = "toggle",
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.mustHaveAll
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.mustHaveAll = value
								NP:ConfigureAll()
							end
						},
						missing = {
							order = 2,
							type = "toggle",
							name = L["Missing"],
							desc = L["If enabled then it checks if auras are missing instead of being present on the unit."],
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.missing
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.missing = value
								NP:ConfigureAll()
							end
						},
						spacer1 = {
							order = 3,
							type = "description",
							name = " "
						},
						minTimeLeft = {
							order = 4,
							type = "range",
							name = L["Minimum Time Left"],
							desc = L["Apply this filter if a debuff has remaining time greater than this. Set to zero to disable."],
							min = 0, max = 10800, step = 1,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.minTimeLeft
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.minTimeLeft = value
								NP:ConfigureAll()
							end
						},
						maxTimeLeft = {
							order = 5,
							type = "range",
							name = L["Maximum Time Left"],
							desc = L["Apply this filter if a debuff has remaining time less than this. Set to zero to disable."],
							min = 0, max = 10800, step = 1,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.maxTimeLeft
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.maxTimeLeft = value
								NP:ConfigureAll()
							end
						},
						spacer2 = {
							order = 6,
							type = "description",
							name = " "
						},
						addDebuff = {
							order = 7,
							type = "input",
							name = L["Add Spell ID or Name"],
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.names[value] = true
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeDebuff = {
							order = 8,
							type = "input",
							name = L["Remove Spell ID or Name"],
							desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.names[value] = nil
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						}
					}
				},
				nameplateType = {
					order = 15,
					type = "group",
					name = L["Unit Type"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						enable = {
							order = 0,
							type = "toggle",
							name = L["ENABLE"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType and E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.enable
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.enable = value
								NP:ConfigureAll()
							end
						},
						types = {
							order = 1,
							type = "group",
							name = "",
							guiInline = true,
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or not E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.enable end,
							args = {
								friendlyPlayer = {
									order = 1,
									type = "toggle",
									name = L["FRIENDLY_PLAYER"],
									get = function(info)
										return E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.friendlyPlayer
									end,
									set = function(info, value)
										E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.friendlyPlayer = value
										NP:ConfigureAll()
									end
								},
								friendlyNPC = {
									order = 2,
									type = "toggle",
									name = L["FRIENDLY_NPC"],
									get = function(info)
										return E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.friendlyNPC
									end,
									set = function(info, value)
										E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.friendlyNPC = value
										NP:ConfigureAll()
									end
								},
								enemyPlayer = {
									order = 3,
									type = "toggle",
									name = L["ENEMY_PLAYER"],
									get = function(info)
										return E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.enemyPlayer
									end,
									set = function(info, value)
										E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.enemyPlayer = value
										NP:ConfigureAll()
									end
								},
								enemyNPC = {
									order = 4,
									type = "toggle",
									name = L["ENEMY_NPC"],
									get = function(info)
										return E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.enemyNPC
									end,
									set = function(info, value)
										E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.enemyNPC = value
										NP:ConfigureAll()
									end
								}
							}
						}
					}
				},
				reactionType = {
					order = 16,
					type = "group",
					name = L["Reaction Type"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["ENABLE"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType and E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.enable
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.enable = value
								NP:ConfigureAll()
							end
						},
						types = {
							order = 2,
							type = "group",
							name = "",
							guiInline = true,
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or not E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.enable end,
							args = {
								tapped = {
									order = 1,
									type = "toggle",
									name = L["Tapped"],
									get = function(info)
										return E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.tapped
									end,
									set = function(info, value)
										E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.tapped = value
										NP:ConfigureAll()
									end
								},
								hostile = {
									order = 2,
									type = "toggle",
									name = L["FACTION_STANDING_LABEL2"],
									get = function(info)
										return E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.hostile
									end,
									set = function(info, value)
										E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.hostile = value
										NP:ConfigureAll()
									end
								},
								neutral = {
									order = 3,
									type = "toggle",
									name = L["FACTION_STANDING_LABEL4"],
									get = function(info)
										return E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.neutral
									end,
									set = function(info, value)
										E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.neutral = value
										NP:ConfigureAll()
									end
								},
								friendly = {
									order = 4,
									type = "toggle",
									name = L["FACTION_STANDING_LABEL5"],
									get = function(info)
										return E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.friendly
									end,
									set = function(info, value)
										E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.friendly = value
										NP:ConfigureAll()
									end
								}
							}
						}
					}
				},
				instanceType = {
					order = 17,
					type = "group",
					name = L["Instance Type"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						none = {
							order = 1,
							type = "toggle",
							name = L["NONE"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.none
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.none = value
								NP:ConfigureAll()
							end
						},
						scenario = {
							order = 2,
							type = "toggle",
							name = L["SCENARIOS"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.scenario
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.scenario = value
								NP:ConfigureAll()
							end
						},
						party = {
							order = 3,
							type = "toggle",
							name = L["DUNGEONS"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.party
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.party = value
								UpdateInstanceDifficulty()
								NP:ConfigureAll()
							end
						},
						raid = {
							order = 4,
							type = "toggle",
							name = L["RAID"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.raid
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.raid = value
								UpdateInstanceDifficulty()
								NP:ConfigureAll()
							end
						},
						arena = {
							order = 5,
							type = "toggle",
							name = L["ARENA"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.arena
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.arena = value
								NP:ConfigureAll()
							end
						},
						pvp = {
							order = 6,
							type = "toggle",
							name = L["BATTLEFIELDS"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.pvp
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.pvp = value
								NP:ConfigureAll()
							end
						}
					}
				},
				location = {
					order = 18,
					type = "group",
					name = L["Location"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers.location[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.location[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						mapIDEnabled = {
							order = 1,
							type = "toggle",
							name = L["Use Map ID or Name"],
							desc = L["If enabled, the style filter will only activate when you are in one of the maps specified in Map ID."],
							customWidth = 200
						},
						mapIDs = {
							order = 2,
							type = "input",
							name = L["Add Map ID"],
							get = function(info) return end,
							set = function(info, value)
								if strmatch(value, "^[%s%p]-$") then return end
								if E.global.nameplates.filters[selectedNameplateFilter].triggers.location.mapIDs[value] then return end

								E.global.nameplates.filters[selectedNameplateFilter].triggers.location.mapIDs[value] = true
								NP:ConfigureAll()
							end,
							disabled = function () return not E.global.nameplates.filters[selectedNameplateFilter].triggers.location.mapIDEnabled end
						},
						removeMapID = {
							order = 3,
							type = "select",
							name = L["Remove Map ID"],
							get = function(info) return end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.location.mapIDs[value] = nil
								NP:ConfigureAll()
							end,
							values = function()
								local vals = {}
								local ids = E.global.nameplates.filters[selectedNameplateFilter].triggers.location.mapIDs
								if not (ids and next(ids)) then return vals end

								for value in pairs(ids) do
									local info = tonumber(value)
									local mapName = GetMapNameByID(value)
									if info and mapName then
										info = "|cFF999999("..value..")|r "..mapName
									end
									vals[value] = info or value
								end
								return vals
							end,
							disabled = function()
								local ids = E.global.nameplates.filters[selectedNameplateFilter].triggers.location.mapIDs
								return not (E.global.nameplates.filters[selectedNameplateFilter].triggers.location.mapIDEnabled and ids and next(ids))
							end
						},
						instanceIDEnabled = {
							order = 4,
							type = "toggle",
							name = L["Use Instance ID or Name"],
							desc = L["If enabled, the style filter will only activate when you are in one of the instances specified in Instance ID."],
							customWidth = 200
						},
						instanceIDs = {
							order = 5,
							type = "input",
							name = L["Add Instance ID"],
							get = function(info) return end,
							set = function(info, value)
								if strmatch(value, "^[%s%p]-$") then return end

								if E.global.nameplates.filters[selectedNameplateFilter].triggers.location.instanceIDs[value] then return end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.location.instanceIDs[value] = true
								NP:ConfigureAll()
							end,
							disabled = function () return not E.global.nameplates.filters[selectedNameplateFilter].triggers.location.instanceIDEnabled end
						},
						removeInstanceID = {
							order = 6,
							type = "select",
							name = L["Remove Instance ID"],
							get = function(info) return end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.location.instanceIDs[value] = nil
								NP:ConfigureAll()
							end,
							values = function()
								local vals = {}
								local ids = E.global.nameplates.filters[selectedNameplateFilter].triggers.location.instanceIDs
								if not (ids and next(ids)) then return vals end

								for value in pairs(ids) do
									local name = tonumber(value) and GetRealZoneText(value)
									if name then
										name = "|cFF999999("..value..")|r "..name
									end
									vals[value] = name or value
								end
								return vals
							end,
							disabled = function()
								local ids = E.global.nameplates.filters[selectedNameplateFilter].triggers.location.instanceIDs
								return not (E.global.nameplates.filters[selectedNameplateFilter].triggers.location.instanceIDEnabled and ids and next(ids))
							end
						},
						zoneNamesEnabled = {
							order = 7,
							type = "toggle",
							name = L["Use Zone Names"],
							desc = L["If enabled, the style filter will only activate when you are in one of the zones specified in Add Zone Name."],
							customWidth = 200
						},
						zoneNames = {
							order = 8,
							type = "input",
							name = L["Add Zone Name"],
							get = function(info) return end,
							set = function(info, value)
							if strmatch(value, "^[%s%p]-$") then return end

							if E.global.nameplates.filters[selectedNameplateFilter].triggers.location.zoneNames[value] then return end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.location.zoneNames[value] = true
								NP:ConfigureAll()
							end,
							disabled = function () return not E.global.nameplates.filters[selectedNameplateFilter].triggers.location.zoneNamesEnabled end
						},
						removeZoneName = {
							order = 9,
							type = "select",
							name = L["Remove Zone Name"],
							get = function(info) return end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.location.zoneNames[value] = nil
								NP:ConfigureAll()
							end,
							values = function()
								local vals = {}
								local zone = E.global.nameplates.filters[selectedNameplateFilter].triggers.location.zoneNames
								if not (zone and next(zone)) then return vals end

								for value in pairs(zone) do vals[value] = value end
								return vals
							end,
							disabled = function()
								local zone = E.global.nameplates.filters[selectedNameplateFilter].triggers.location.zoneNames
								return not (E.global.nameplates.filters[selectedNameplateFilter].triggers.location.zoneNamesEnabled and zone and next(zone))
							end
						},
						subZoneNamesEnabled = {
							order = 10,
							type = "toggle",
							name = L["Use Subzone Names"],
							desc = L["If enabled, the style filter will only activate when you are in one of the subzones specified in Add Subzone Name."],
							customWidth = 200
						},
						subZoneNames = {
							order = 11,
							type = "input",
							name = L["Add Subzone Name"],
							get = function(info) return end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.location.subZoneNames[value] = true
								NP:ConfigureAll()
							end,
							disabled = function () return not E.global.nameplates.filters[selectedNameplateFilter].triggers.location.subZoneNamesEnabled end
						},
						removeSubZoneName = {
							order = 12,
							type = "select",
							name = L["Remove Subzone Name"],
							get = function(info) return end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.location.subZoneNames[value] = nil
								NP:ConfigureAll()
							end,
							values = function()
								local vals = {}
								local zone = E.global.nameplates.filters[selectedNameplateFilter].triggers.location.subZoneNames
								if not (zone and next(zone)) then return vals end

								for value in pairs(zone) do vals[value] = value end
								return vals
							end,
							disabled = function()
								local zone = E.global.nameplates.filters[selectedNameplateFilter].triggers.location.subZoneNames
								return not (E.global.nameplates.filters[selectedNameplateFilter].triggers.location.subZoneNamesEnabled and zone and next(zone))
							end
						},
						btns = {
							order = 13,
							type = "group",
							inline = true,
							name = L["Add Current"],
							args = {
								mapID = {
									order = 1,
									type = "execute",
									name = L["Map ID"],
									func = function()
										local mapID = GetCurrentMapAreaID()
										if not mapID then return end
										mapID = tostring(mapID)

										if E.global.nameplates.filters[selectedNameplateFilter].triggers.location.mapIDs[mapID] then return end
										E.global.nameplates.filters[selectedNameplateFilter].triggers.location.mapIDs[mapID] = true
										NP:ConfigureAll()
										E:Print(format(L["Added Map ID: %s"], GetMapNameByID(mapID).." ("..mapID..")"))
									end
								},
								instanceID = {
									order = 2,
									type = "execute",
									name = L["Instance ID"],
									func = function()
										local instanceName, _, _, _, _, _, _, instanceID = GetInstanceInfo()
										if not instanceID then return end
										instanceID = tostring(instanceID)

										if E.global.nameplates.filters[selectedNameplateFilter].triggers.location.instanceIDs[instanceID] then return end
										E.global.nameplates.filters[selectedNameplateFilter].triggers.location.instanceIDs[instanceID] = true
										NP:ConfigureAll()
										E:Print(format(L["Added Instance ID: %s"], instanceName.." ("..instanceID..")"))
									end
								},
								zoneName = {
									order = 3,
									type = "execute",
									name = L["Zone Name"],
									func = function()
										local zone = GetRealZoneText()
										if not zone then return end

										if E.global.nameplates.filters[selectedNameplateFilter].triggers.location.zoneNames[zone] then return end
										E.global.nameplates.filters[selectedNameplateFilter].triggers.location.zoneNames[zone] = true
										NP:ConfigureAll()
										E:Print(format(L["Added Zone Name: %s"], zone))
									end
								},
								subZoneName = {
									order = 4,
									type = "execute",
									name = L["Subzone Name"],
									func = function()
										local subZone = GetSubZoneText()
										if not subZone or subZone == "" then return end

										if E.global.nameplates.filters[selectedNameplateFilter].triggers.location.subZoneNames[subZone] then return end
										E.global.nameplates.filters[selectedNameplateFilter].triggers.location.subZoneNames[subZone] = true
										NP:ConfigureAll()
										E:Print(format(L["Added Subzone Name: %s"], subZone))
									end
								}
							}
						}
					}
				},
				raidTarget = {
					order = 19,
					type = "group",
					name = L["BINDING_HEADER_RAID_TARGET"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers.raidTarget[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.raidTarget[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						star = {
							order = 1,
							type = "toggle",
							name = format(raidTargetIcon, 1, L["RAID_TARGET_1"])
						},
						circle = {
							order = 2,
							type = "toggle",
							name = format(raidTargetIcon, 2, L["RAID_TARGET_2"])
						},
						diamond = {
							order = 3,
							type = "toggle",
							name = format(raidTargetIcon, 3, L["RAID_TARGET_3"])
						},
						triangle = {
							order = 4,
							type = "toggle",
							name = format(raidTargetIcon, 4, L["RAID_TARGET_4"])
						},
						moon = {
							order = 5,
							type = "toggle",
							name = format(raidTargetIcon, 5, L["RAID_TARGET_5"])
						},
						square = {
							order = 6,
							type = "toggle",
							name = format(raidTargetIcon, 6, L["RAID_TARGET_6"])
						},
						cross = {
							order = 7,
							type = "toggle",
							name = format(raidTargetIcon, 7, L["RAID_TARGET_7"])
						},
						skull = {
							order = 8,
							type = "toggle",
							name = format(raidTargetIcon, 8, L["RAID_TARGET_8"])
						}
					}
				},
				totems = {
					order = 20,
					type = "group",
					name = L["Totems"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers.totems[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.totems[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						enable = {
							order = 0,
							type = "toggle",
							name = L["ENABLE"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.totems and E.global.nameplates.filters[selectedNameplateFilter].triggers.totems.enable
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.totems.enable = value
								NP:ConfigureAll()
							end
						}
					}
				},
				uniqueUnits = {
					order = 21,
					type = "group",
					name = L["Unique Units"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						enable = {
							order = 0,
							type = "toggle",
							name = L["ENABLE"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits and E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits.enable
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits.enable = value
								NP:ConfigureAll()
							end
						}
					}
				}
			}
		}
		E.Options.args.nameplate.args.filters.args.actions = {
			order = 6,
			type = "group",
			name = L["Actions"],
			disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
			args = {
				hide = {
					order = 1,
					type = "toggle",
					name = L["Hide Frame"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].actions.hide
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].actions.hide = value
						NP:ConfigureAll()
					end
				},
				nameOnly = {
					order = 2,
					type = "toggle",
					name = L["Name Only"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].actions.nameOnly
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].actions.nameOnly = value
						NP:ConfigureAll()
					end,
					disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide end
				},
				icon = {
					order = 3,
					type = "toggle",
					name = L["Icon"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].actions.icon
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].actions.icon = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return E.global.nameplates.filters[selectedNameplateFilter].actions.hide or not (E.global.nameplates.filters[selectedNameplateFilter].triggers.totems.enable or E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits.enable)
					end
				},
				iconOnly = {
					order = 4,
					type = "toggle",
					name = L["Icon Only"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].actions.iconOnly
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].actions.iconOnly = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return E.global.nameplates.filters[selectedNameplateFilter].actions.hide or not (E.global.nameplates.filters[selectedNameplateFilter].triggers.totems.enable or E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits.enable)
					end
				},
				spacer1 = {
					order = 5,
					type = "description",
					name = " "
				},
				scale = {
					order = 6,
					type = "range",
					name = L["Scale"],
					disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide end,
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].actions.scale or 1
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].actions.scale = value
						NP:ConfigureAll()
					end,
					min = 0.35, max = 1.5, step = 0.01
				},
				alpha = {
					order = 7,
					type = "range",
					name = L["Alpha"],
					disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide end,
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].actions.alpha or -1
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].actions.alpha = value
						NP:ConfigureAll()
					end,
					min = -1, max = 100, step = 1
				},
				frameLevel = {
					order = 8,
					type = "range",
					name = L["Frame Level"],
					desc = L["NAMEPLATE_FRAMELEVEL_DESC"],
					min = 0, max = 10, step = 1,
					disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide end,
					get = function(info) return E.global.nameplates.filters[selectedNameplateFilter].actions.frameLevel or 0 end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].actions.frameLevel = value
						NP:ConfigureAll()
					end,
				},
				color = {
					order = 10,
					type = "group",
					name = L["COLOR"],
					guiInline = true,
					disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide end,
					args = {
						health = {
							order = 1,
							type = "toggle",
							name = L["HEALTH"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].actions.color.health
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].actions.color.health = value
								NP:ConfigureAll()
							end
						},
						healthColor = {
							order = 2,
							type = "color",
							name = L["Health Color"],
							hasAlpha = true,
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].actions.color.health end,
							get = function(info)
								local t = E.global.nameplates.filters[selectedNameplateFilter].actions.color.healthColor
								return t.r, t.g, t.b, t.a, 136/255, 255/255, 102/255, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplates.filters[selectedNameplateFilter].actions.color.healthColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end
						},
						spacer1 = {
							order = 3,
							type = "description",
							name = " ",
						},
						border = {
							order = 4,
							type = "toggle",
							name = L["Border"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].actions.color.border
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].actions.color.border = value
								NP:ConfigureAll()
							end
						},
						borderColor = {
							order = 5,
							type = "color",
							name = L["Border Color"],
							hasAlpha = true,
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].actions.color.border end,
							get = function(info)
								local t = E.global.nameplates.filters[selectedNameplateFilter].actions.color.borderColor
								return t.r, t.g, t.b, t.a, 0, 0, 0, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplates.filters[selectedNameplateFilter].actions.color.borderColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end
						},
						spacer2 = {
							order = 6,
							type = "description",
							name = " "
						},
						name = {
							order = 7,
							type = "toggle",
							name = L["NAME"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].actions.color.name
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].actions.color.name = value
								NP:ConfigureAll()
							end
						},
						nameColor = {
							order = 8,
							type = "color",
							name = L["Name Color"],
							hasAlpha = true,
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].actions.color.name end,
							get = function(info)
								local t = E.global.nameplates.filters[selectedNameplateFilter].actions.color.nameColor
								return t.r, t.g, t.b, t.a, 200/255, 200/255, 200/255, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplates.filters[selectedNameplateFilter].actions.color.nameColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end
						}
					}
				},
				texture = {
					order = 20,
					type = "group",
					name = L["Texture"],
					guiInline = true,
					disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["ENABLE"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].actions.texture.enable
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].actions.texture.enable = value
								NP:ConfigureAll()
							end
						},
						texture = {
							order = 2,
							type = "select",
							dialogControl = "LSM30_Statusbar",
							name = L["Texture"],
							values = AceGUIWidgetLSMlists.statusbar,
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].actions.texture.enable end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].actions.texture.texture
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].actions.texture.texture = value
								NP:ConfigureAll()
							end
						}
					}
				},
				flashing = {
					order = 30,
					type = "group",
					name = L["Flash"],
					guiInline = true,
					disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["ENABLE"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].actions.flash.enable
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].actions.flash.enable = value
								NP:ConfigureAll()
							end
						},
						speed = {
							order = 2,
							type = "range",
							name = L["SPEED"],
							disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide or not E.global.nameplates.filters[selectedNameplateFilter].actions.flash.enable end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].actions.flash.speed or 4
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].actions.flash.speed = value
								NP:ConfigureAll()
							end,
							min = 1, max = 10, step = 1
						},
						color = {
							order = 3,
							type = "color",
							name = L["COLOR"],
							hasAlpha = true,
							disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide or not E.global.nameplates.filters[selectedNameplateFilter].actions.flash.enable end,
							get = function(info)
								local t = E.global.nameplates.filters[selectedNameplateFilter].actions.flash.color
								return t.r, t.g, t.b, t.a, 104/255, 138/255, 217/255, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplates.filters[selectedNameplateFilter].actions.flash.color
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end
						}
					}
				}
			}
		}

		UpdateInstanceDifficulty()
		UpdateStyleLists()
	end
end

local ORDER = 100
local function GetUnitSettings(unit, name)
	local copyValues = {}
	for x, y in pairs(NP.db.units) do
		if type(y) == "table" and (x ~= unit) then
			copyValues[x] = L[x]
		end
	end
	local group = {
		order = ORDER,
		type = "group",
		name = name,
		childGroups = "tree",
		get = function(info) return E.db.nameplates.units[unit][info[#info]] end,
		set = function(info, value) E.db.nameplates.units[unit][info[#info]] = value NP:ConfigureAll() end,
		disabled = function() return not E.NamePlates.Initialized end,
		args = {
			copySettings = {
				order = -10,
				type = "select",
				name = L["Copy Settings From"],
				desc = L["Copy settings from another unit."],
				values = copyValues,
				get = function() return "" end,
				set = function(info, value)
					NP:CopySettings(value, unit)
					NP:ConfigureAll()
				end
			},
			defaultSettings = {
				order = -9,
				type = "execute",
				name = L["Default Settings"],
				desc = L["Set Settings to Default"],
				func = function(info)
					NP:ResetSettings(unit)
					NP:ConfigureAll()
				end
			},
			healthGroup = {
				order = 1,
				type = "group",
				name = L["HEALTH"],
				get = function(info) return E.db.nameplates.units[unit].health[info[#info]] end,
				set = function(info, value) E.db.nameplates.units[unit].health[info[#info]] = value NP:ConfigureAll() end,
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
						min = 4, max = 20, step = 1
					},
					width = {
						order = 3,
						type = "range",
						name = L["Width"],
						min = 50, max = 200, step = 1
					},
					textGroup = {
						order = 4,
						type = "group",
						name = L["Text"],
						guiInline = true,
						get = function(info)
							return E.db.nameplates.units[unit].health.text[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].health.text[info[#info]] = value
							NP:ConfigureAll()
						end,
						args = {
							enable = {
								order = 1,
								type = "toggle",
								name = L["ENABLE"]
							},
							format = {
								order = 2,
								type = "select",
								name = L["Format"],
								values = {
									["CURRENT"] = L["Current"],
									["CURRENT_MAX"] = L["Current / Max"],
									["CURRENT_PERCENT"] = L["Current - Percent"],
									["CURRENT_MAX_PERCENT"] = L["Current - Max | Percent"],
									["PERCENT"] = L["Percent"],
									["DEFICIT"] = L["Deficit"]
								},
								disabled = function() return not E.db.nameplates.units[unit].health.text.enable end
							},
							position = {
								order = 3,
								type = "select",
								name = L["Position"],
								values = {
									["CENTER"] = L["Center"],
									["TOPLEFT"] = L["Top Left"],
									["TOPRIGHT"] = L["Top Right"],
									["BOTTOMLEFT"] = L["Bottom Left"],
									["BOTTOMRIGHT"] = L["Bottom Right"]
								},
								disabled = function() return not E.db.nameplates.units[unit].health.text.enable end
							},
							parent = {
								order = 4,
								type = "select",
								name = L["Parent"],
								values = {
									["Nameplate"] = L["Nameplate"],
									["Health"] = L["HEALTH"]
								},
								disabled = function() return not E.db.nameplates.units[unit].health.text.enable end
							},
							xOffset = {
								order = 5,
								type = "range",
								name = L["X-Offset"],
								min = -100, max = 100, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].health.text.enable end
							},
							yOffset = {
								order = 6,
								type = "range",
								name = L["Y-Offset"],
								min = -100, max = 100, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].health.text.enable end
							},
							font = {
								order = 7,
								type = "select",
								name = L["Font"],
								dialogControl = "LSM30_Font",
								values = AceGUIWidgetLSMlists.font,
								disabled = function() return not E.db.nameplates.units[unit].health.text.enable end
							},
							fontSize = {
								order = 8,
								type = "range",
								name = L["FONT_SIZE"],
								min = 4, max = 32, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].health.text.enable end
							},
							fontOutline = {
								order = 9,
								type = "select",
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								values = C.Values.FontFlags,
								disabled = function() return not E.db.nameplates.units[unit].health.text.enable end
							}
						}
					}
				}
			},
			castGroup = {
				order = 2,
				type = "group",
				name = L["Cast Bar"],
				get = function(info) return E.db.nameplates.units[unit].castbar[info[#info]] end,
				set = function(info, value) E.db.nameplates.units[unit].castbar[info[#info]] = value NP:ConfigureAll() end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"]
					},
					width = {
						order = 2,
						type = "range",
						name = L["Width"],
						min = 50, max = 250, step = 1,
						disabled = function() return not E.db.nameplates.units[unit].castbar.enable end
					},
					height = {
						order = 3,
						type = "range",
						name = L["Height"],
						min = 4, max = 20, step = 1,
						disabled = function() return not E.db.nameplates.units[unit].castbar.enable end
					},
					xOffset = {
						order = 4,
						type = "range",
						name = L["X-Offset"],
						min = -100, max = 100, step = 1,
						disabled = function() return not E.db.nameplates.units[unit].castbar.enable end
					},
					yOffset = {
						order = 5,
						type = "range",
						name = L["Y-Offset"],
						min = -100, max = 100, step = 1,
						disabled = function() return not E.db.nameplates.units[unit].castbar.enable end
					},
					textGroup = {
						order = 6,
						type = "group",
						name = L["Text"],
						guiInline = true,
						get = function(info)
							return E.db.nameplates.units[unit].castbar[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].castbar[info[#info]] = value
							NP:ConfigureAll()
						end,
						disabled = function() return not E.db.nameplates.units[unit].castbar.enable end,
						args = {
							hideSpellName = {
								order = 1,
								type = "toggle",
								name = L["Hide Spell Name"]
							},
							hideTime = {
								order = 2,
								type = "toggle",
								name = L["Hide Time"]
							},
							spacer = {
								order = 3,
								type = "description",
								name = " "
							},
							textPosition = {
								order = 4,
								type = "select",
								name = L["Position"],
								values = {
									["ONBAR"] = L["Cast Bar"],
									["ABOVE"] = L["Above"],
									["BELOW"] = L["Below"]
								}
							},
							castTimeFormat = {
								order = 5,
								type = "select",
								name = L["Cast Time Format"],
								values = {
									["CURRENT"] = L["Current"],
									["CURRENTMAX"] = L["Current / Max"],
									["REMAINING"] = L["Remaining"],
									["REMAININGMAX"] = L["Remaining / Max"]
								}
							},
							channelTimeFormat = {
								order = 6,
								type = "select",
								name = L["Channel Time Format"],
								values = {
									["CURRENT"] = L["Current"],
									["CURRENTMAX"] = L["Current / Max"],
									["REMAINING"] = L["Remaining"],
									["REMAININGMAX"] = L["Remaining / Max"]
								}
							},
							font = {
								order = 7,
								type = "select",
								name = L["Font"],
								dialogControl = "LSM30_Font",
								values = AceGUIWidgetLSMlists.font
							},
							fontSize = {
								order = 8,
								type = "range",
								name = L["FONT_SIZE"],
								min = 4, max = 60, step = 1
							},
							fontOutline = {
								order = 9,
								type = "select",
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								values = C.Values.FontFlags
							}
						}
					},
					iconGroup = {
						order = 7,
						type = "group",
						name = L["Icon"],
						guiInline = true,
						get = function(info)
							return E.db.nameplates.units[unit].castbar[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].castbar[info[#info]] = value
							NP:ConfigureAll()
						end,
						args = {
							showIcon = {
								order = 1,
								type = "toggle",
								name = L["ENABLE"],
								disabled = function() return not E.db.nameplates.units[unit].castbar.enable end
							},
							iconSize = {
								order = 2,
								type = "range",
								name = L["Icon Size"],
								min = 4, max = 40, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].castbar.showIcon or not E.db.nameplates.units[unit].castbar.enable end
							},
							iconPosition = {
								order = 3,
								type = "select",
								name = L["Icon Position"],
								values = {
									["LEFT"] = L["Left"],
									["RIGHT"] = L["Right"]
								},
								disabled = function() return not E.db.nameplates.units[unit].castbar.showIcon or not E.db.nameplates.units[unit].castbar.enable end
							},
							iconOffsetX = {
								order = 4,
								type = "range",
								name = L["X-Offset"],
								min = -100, max = 100, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].castbar.showIcon or not E.db.nameplates.units[unit].castbar.enable end
							},
							iconOffsetY = {
								order = 5,
								type = "range",
								name = L["Y-Offset"],
								min = -100, max = 100, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].castbar.showIcon or not E.db.nameplates.units[unit].castbar.enable end
							}
						}
					}
				}
			},
			buffsGroup = {
				order = 3,
				type = "group",
				childGroups = "tab",
				name = L["Buffs"],
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
						get = function(info)
							return E.db.nameplates.units[unit].buffs[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].buffs[info[#info]] = value
							NP:ConfigureAll()
						end
					},
					generalGroup = {
						order = 2,
						type = "group",
						name = L["General"],
						get = function(info)
							return E.db.nameplates.units[unit].buffs[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].buffs[info[#info]] = value
							NP:ConfigureAll()
						end,
						args = {
							perrow = {
								order = 1,
								type = "range",
								name = L["Per Row"],
								min = 1, max = 20, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							numrows = {
								order = 2,
								type = "range",
								name = L["Num Rows"],
								min = 1, max = 10, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							size = {
								order = 3,
								type = "range",
								name = L["Icon Size"],
								min = 6, max = 60, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							spacing = {
								order = 4,
								type = "range",
								name = L["Spacing"],
								min = 0, max = 60, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							xOffset = {
								order = 5,
								type = "range",
								name = L["X-Offset"],
								min = -100, max = 100, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							yOffset = {
								order = 6,
								type = "range",
								name = L["Y-Offset"],
								min = -100, max = 100, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							anchorPoint = {
								order = 7,
								type = "select",
								name = L["Anchor Point"],
								desc = L["What point to anchor to the frame you set to attach to."],
								values = positionValues,
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							attachTo = {
								order = 8,
								type = "select",
								name = L["Attach To"],
								values = {
									["FRAME"] = L["Nameplate"]
								},
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							growthX = {
								order = 9,
								type = "select",
								name = L["Growth X-Direction"],
								values = {
									["LEFT"] = L["Left"],
									["RIGHT"] = L["Right"]
								},
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							growthY = {
								order = 10,
								type = "select",
								name = L["Growth Y-Direction"],
								values = {
									["UP"] = L["Up"],
									["DOWN"] = L["Down"]
								},
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							cooldownOrientation = {
								order = 11,
								type = "select",
								name = L["Cooldown Orientation"],
								values = {
									["VERTICAL"] = L["Vertical"],
									["HORIZONTAL"] = L["Horizontal"]
								},
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							reverseCooldown = {
								order = 12,
								type = "toggle",
								name = L["Reverse Cooldown"],
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							}
						}
					},
					font = {
						order = 3,
						type = "group",
						name = L["Font"],
						args = {
							duration = {
								order = 1,
								type = "group",
								name = L["Duration"],
								guiInline = true,
								get = function(info)
									return E.db.nameplates.units[unit].buffs[info[#info]]
								end,
								set = function(info, value)
									E.db.nameplates.units[unit].buffs[info[#info]] = value
									NP:ConfigureAll()
								end,
								args = {
									durationFont = {
										order = 1,
										type = "select",
										name = L["Font"],
										dialogControl = "LSM30_Font",
										values = AceGUIWidgetLSMlists.font,
										disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
									},
									durationFontSize = {
										order = 2,
										type = "range",
										name = L["FONT_SIZE"],
										min = 4, max = 20, step = 1, -- max 20 cause otherwise it looks weird
										disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
									},
									durationFontOutline = {
										order = 3,
										type = "select",
										name = L["Font Outline"],
										desc = L["Set the font outline."],
										values = C.Values.FontFlags,
										disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
									},
									durationPosition = {
										order = 4,
										type = "select",
										name = L["Position"],
										values = textValues,
										disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
									},
									durationXOffset = {
										order = 5,
										type = "range",
										name = L["X-Offset"],
										min = -100, max = 100, step = 1,
										disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
									},
									durationYOffset = {
										order = 6,
										type = "range",
										name = L["Y-Offset"],
										min = -100, max = 100, step = 1,
										disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
									}
								}
							},
							stacks = {
								order = 2,
								type = "group",
								name = L["Stack Counter"],
								guiInline = true,
								get = function(info, value)
									return E.db.nameplates.units[unit].buffs[info[#info]]
								end,
								set = function(info, value)
									E.db.nameplates.units[unit].buffs[info[#info]] = value
									NP:ConfigureAll()
								end,
								args = {
									countFont = {
										order = 1,
										type = "select",
										name = L["Font"],
										dialogControl = "LSM30_Font",
										values = AceGUIWidgetLSMlists.font,
										disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
									},
									countFontSize = {
										order = 2,
										type = "range",
										name = L["FONT_SIZE"],
										min = 4, max = 20, step = 1, -- max 20 cause otherwise it looks weird
										disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
									},
									countFontOutline = {
										order = 3,
										type = "select",
										name = L["Font Outline"],
										desc = L["Set the font outline."],
										values = C.Values.FontFlags,
										disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
									},
									countPosition = {
										order = 4,
										type = "select",
										name = L["Position"],
										values = textValues,
										disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
									},
									countXOffset = {
										order = 5,
										type = "range",
										name = L["X-Offset"],
										min = -100, max = 100, step = 1,
										disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
									},
									countYOffset = {
										order = 6,
										type = "range",
										name = L["Y-Offset"],
										min = -100, max = 100, step = 1,
										disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
									}
								}
							}
						}
					},
					filtersGroup = {
						order = 4,
						type = "group",
						name = L["FILTERS"],
						get = function(info)
							return E.db.nameplates.units[unit].buffs.filters[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].buffs.filters[info[#info]] = value
							NP:ConfigureAll()
						end,
						args = {
							minDuration = {
								order = 1,
								type = "range",
								name = L["Minimum Duration"],
								desc = L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							maxDuration = {
								order = 2,
								type = "range",
								name = L["Maximum Duration"],
								desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							jumpToFilter = {
								order = 3,
								type = "execute",
								name = L["Filters Page"],
								desc = L["Shortcut to global filters."],
								func = function() ACD:SelectGroup("ElvUI", "filters") end,
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							spacer1 = {
								order = 4,
								type = "description",
								name = " "
							},
							specialFilters = {
								order = 5,
								type = "select",
								sortByValue = true,
								name = L["Add Special Filter"],
								desc = L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."],
								values = function()
									local filters = {}
									local list = E.global.nameplates.specialFilters
									if not list then return end

									for filter in pairs(list) do
										filters[filter] = L[filter]
									end
									return filters
								end,
								set = function(info, value)
									filterPriority("buffs", unit, value)
									NP:ConfigureAll()
								end,
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							filter = {
								order = 6,
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
									filterPriority("buffs", unit, value)
									NP:ConfigureAll()
								end,
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							resetPriority = {
								order = 7,
								type = "execute",
								name = L["Reset Priority"],
								desc = L["Reset filter priority to the default state."],
								func = function()
									E.db.nameplates.units[unit].buffs.filters.priority = P.nameplates.units[unit].buffs.filters.priority
									NP:ConfigureAll()
								end,
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							filterPriority = {
								order = 8,
								type = "multiselect",
								name = L["Filter Priority"],
								dragdrop = true,
								dragOnLeave = E.noop, --keep this here
								dragOnEnter = function(info)
									carryFilterTo = info.obj.value
								end,
								dragOnMouseDown = function(info)
									carryFilterFrom, carryFilterTo = info.obj.value, nil
								end,
								dragOnMouseUp = function()
									filterPriority("buffs", unit, carryFilterTo, nil, carryFilterFrom) --add it in the new spot
									carryFilterFrom, carryFilterTo = nil, nil
								end,
								dragOnClick = function()
									filterPriority("buffs", unit, carryFilterFrom, true)
								end,
								stateSwitchGetText = C.StateSwitchGetText,
								values = function()
									local str = E.db.nameplates.units[unit].buffs.filters.priority
									if str == "" then return nil end
									return {strsplit(",", str)}
								end,
								get = function(_, value)
									local str = E.db.nameplates.units[unit].buffs.filters.priority
									if str == "" then return nil end
									local tbl = {strsplit(",", str)}
									return tbl[value]
								end,
								set = function()
									NP:ConfigureAll()
								end,
								disabled = function() return not E.db.nameplates.units[unit].buffs.enable end
							},
							spacer3 = {
								order = 9,
								type = "description",
								name = L["Use drag and drop to rearrange filter priority or right click to remove a filter."],
							}
						}
					}
				}
			},
			debuffsGroup = {
				order = 4,
				type = "group",
				name = L["Debuffs"],
				childGroups = "tab",
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
						get = function(info)
							return E.db.nameplates.units[unit].debuffs[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].debuffs[info[#info]] = value
							NP:ConfigureAll()
						end
					},
					generalGroup = {
						order = 2,
						type = "group",
						name = L["General"],
						get = function(info)
							return E.db.nameplates.units[unit].debuffs[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].debuffs[info[#info]] = value
							NP:ConfigureAll()
						end,
						args = {
							perrow = {
								order = 2,
								type = "range",
								name = L["Per Row"],
								min = 1, max = 20, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							numrows = {
								order = 3,
								type = "range",
								name = L["Num Rows"],
								min = 1, max = 10, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							size = {
								order = 4,
								type = "range",
								name = L["Icon Size"],
								min = 6, max = 60, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							spacing = {
								order = 5,
								type = "range",
								name = L["Spacing"],
								min = 0, max = 60, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							xOffset = {
								order = 6,
								type = "range",
								name = L["X-Offset"],
								min = -100, max = 100, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							yOffset = {
								order = 7,
								type = "range",
								name = L["Y-Offset"],
								min = -100, max = 100, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							anchorPoint = {
								order = 8,
								type = "select",
								name = L["Anchor Point"],
								desc = L["What point to anchor to the frame you set to attach to."],
								values = positionValues,
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							attachTo = {
								order = 9,
								type = "select",
								name = L["Attach To"],
								values = {
									["FRAME"] = L["Nameplate"],
									["BUFFS"] = L["Buffs"]
								},
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							growthX = {
								order = 10,
								type = "select",
								name = L["Growth X-Direction"],
								values = {
									["LEFT"] = L["Left"],
									["RIGHT"] = L["Right"]
								},
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							growthY = {
								order = 11,
								type = "select",
								name = L["Growth Y-Direction"],
								values = {
									["UP"] = L["Up"],
									["DOWN"] = L["Down"]
								},
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							cooldownOrientation = {
								order = 12,
								type = "select",
								name = L["Cooldown Orientation"],
								values = {
									["VERTICAL"] = L["Vertical"],
									["HORIZONTAL"] = L["Horizontal"]
								},
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							reverseCooldown = {
								order = 13,
								type = "toggle",
								name = L["Reverse Cooldown"],
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							}
						}
					},
					font = {
						order = 3,
						type = "group",
						name = L["Font"],
						args = {
							duration = {
								order = 1,
								type = "group",
								name = L["Duration"],
								guiInline = true,
								get = function(info)
									return E.db.nameplates.units[unit].debuffs[info[#info]]
								end,
								set = function(info, value)
									E.db.nameplates.units[unit].debuffs[info[#info]] = value
									NP:ConfigureAll()
								end,
								args = {
									durationFont = {
										order = 1,
										type = "select",
										name = L["Font"],
										dialogControl = "LSM30_Font",
										values = AceGUIWidgetLSMlists.font,
										disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
									},
									durationFontSize = {
										order = 2,
										type = "range",
										name = L["FONT_SIZE"],
										min = 4, max = 20, step = 1, -- max 20 cause otherwise it looks weird
										disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
									},
									durationFontOutline = {
										order = 3,
										type = "select",
										name = L["Font Outline"],
										desc = L["Set the font outline."],
										values = C.Values.FontFlags,
										disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
									},
									durationPosition = {
										order = 4,
										type = "select",
										name = L["Position"],
										values = textValues,
										disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
									},
									durationXOffset = {
										order = 5,
										type = "range",
										name = L["X-Offset"],
										min = -100, max = 100, step = 1,
										disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
									},
									durationYOffset = {
										order = 6,
										type = "range",
										name = L["Y-Offset"],
										min = -100, max = 100, step = 1,
										disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
									}
								}
							},
							stacks = {
								order = 2,
								type = "group",
								name = L["Stack Counter"],
								guiInline = true,
								get = function(info, value)
									return E.db.nameplates.units[unit].debuffs[info[#info]]
								end,
								set = function(info, value)
									E.db.nameplates.units[unit].debuffs[info[#info]] = value
									NP:ConfigureAll()
								end,
								args = {
									countFont = {
										order = 1,
										type = "select",
										name = L["Font"],
										dialogControl = "LSM30_Font",
										values = AceGUIWidgetLSMlists.font,
										disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
									},
									countFontSize = {
										order = 2,
										type = "range",
										name = L["FONT_SIZE"],
										min = 4, max = 20, step = 1, -- max 20 cause otherwise it looks weird
										disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
									},
									countFontOutline = {
										order = 3,
										type = "select",
										name = L["Font Outline"],
										desc = L["Set the font outline."],
										values = C.Values.FontFlags,
										disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
									},
									countPosition = {
										order = 4,
										type = "select",
										name = L["Position"],
										values = textValues,
										disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
									},
									countXOffset = {
										order = 5,
										type = "range",
										name = L["X-Offset"],
										min = -100, max = 100, step = 1,
										disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
									},
									countYOffset = {
										order = 6,
										type = "range",
										name = L["Y-Offset"],
										min = -100, max = 100, step = 1,
										disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
									}
								}
							}
						}
					},
					filtersGroup = {
						order = 5,
						type = "group",
						name = L["FILTERS"],
						get = function(info)
							return E.db.nameplates.units[unit].debuffs.filters[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].debuffs.filters[info[#info]] = value
							NP:ConfigureAll()
						end,
						args = {
							minDuration = {
								order = 1,
								type = "range",
								name = L["Minimum Duration"],
								desc = L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							maxDuration = {
								order = 2,
								type = "range",
								name = L["Maximum Duration"],
								desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1,
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							jumpToFilter = {
								order = 3,
								type = "execute",
								name = L["Filters Page"],
								desc = L["Shortcut to global filters."],
								func = function() ACD:SelectGroup("ElvUI", "filters") end,
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							spacer1 = {
								order = 4,
								type = "description",
								name = " "
							},
							specialFilters = {
								order = 5,
								type = "select",
								sortByValue = true,
								name = L["Add Special Filter"],
								desc = L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."],
								values = function()
									local filters = {}
									local list = E.global.nameplates.specialFilters
									if not list then return end

									for filter in pairs(list) do
										filters[filter] = L[filter]
									end
									return filters
								end,
								set = function(info, value)
									filterPriority("debuffs", unit, value)
									NP:ConfigureAll()
								end,
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							filter = {
								order = 6,
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
									filterPriority("debuffs", unit, value)
									NP:ConfigureAll()
								end,
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							resetPriority = {
								order = 7,
								type = "execute",
								name = L["Reset Priority"],
								desc = L["Reset filter priority to the default state."],
								func = function()
									E.db.nameplates.units[unit].debuffs.filters.priority = P.nameplates.units[unit].debuffs.filters.priority
									NP:ConfigureAll()
								end,
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							filterPriority = {
								order = 8,
								type = "multiselect",
								name = L["Filter Priority"],
								dragdrop = true,
								dragOnLeave = E.noop, --keep this here
								dragOnEnter = function(info)
									carryFilterTo = info.obj.value
								end,
								dragOnMouseDown = function(info)
									carryFilterFrom, carryFilterTo = info.obj.value, nil
								end,
								dragOnMouseUp = function()
									filterPriority("debuffs", unit, carryFilterTo, nil, carryFilterFrom) --add it in the new spot
									carryFilterFrom, carryFilterTo = nil, nil
								end,
								dragOnClick = function()
									filterPriority("debuffs", unit, carryFilterFrom, true)
								end,
								stateSwitchGetText = C.StateSwitchGetText,
								values = function()
									local str = E.db.nameplates.units[unit].debuffs.filters.priority
									if str == "" then return nil end
									return {strsplit(",", str)}
								end,
								get = function(_, value)
									local str = E.db.nameplates.units[unit].debuffs.filters.priority
									if str == "" then return nil end
									local tbl = {strsplit(",", str)}
									return tbl[value]
								end,
								set = function()
									NP:ConfigureAll()
								end,
								disabled = function() return not E.db.nameplates.units[unit].debuffs.enable end
							},
							spacer3 = {
								order = 9,
								type = "description",
								name = L["Use drag and drop to rearrange filter priority or right click to remove a filter."]
							}
						}
					}
				}
			},
			levelGroup = {
				order = 5,
				type = "group",
				name = L["LEVEL"],
				get = function(info)
					return E.db.nameplates.units[unit].level[info[#info]]
				end,
				set = function(info, value)
					E.db.nameplates.units[unit].level[info[#info]] = value
					NP:ConfigureAll()
				end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"]
					},
					spacer = {
						order = 2,
						type = "description",
						name = " "
					},
					font = {
						order = 3,
						type = "select",
						name = L["Font"],
						dialogControl = "LSM30_Font",
						values = AceGUIWidgetLSMlists.font,
						disabled = function() return not E.db.nameplates.units[unit].level.enable end
					},
					fontSize = {
						order = 4,
						type = "range",
						name = L["FONT_SIZE"],
						min = 4, max = 32, step = 1,
						disabled = function() return not E.db.nameplates.units[unit].level.enable end
					},
					fontOutline = {
						order = 5,
						type = "select",
						name = L["Font Outline"],
						desc = L["Set the font outline."],
						values = C.Values.FontFlags,
						disabled = function() return not E.db.nameplates.units[unit].level.enable end
					}
				}
			},
			nameGroup = {
				order = 6,
				type = "group",
				name = L["NAME"],
				get = function(info)
					return E.db.nameplates.units[unit].name[info[#info]]
				end,
				set = function(info, value)
					E.db.nameplates.units[unit].name[info[#info]] = value
					NP:ConfigureAll()
				end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"]
					},
					abbrev = {
						order = 2,
						type = "toggle",
						name = L["Abbreviation"],
						disabled = function() return not E.db.nameplates.units[unit].name.enable end
					},
					spacer = {
						order = 3,
						type = "description",
						name = " "
					},
					font = {
						order = 4,
						type = "select",
						name = L["Font"],
						dialogControl = "LSM30_Font",
						values = AceGUIWidgetLSMlists.font,
						disabled = function() return not E.db.nameplates.units[unit].name.enable end
					},
					fontSize = {
						order = 5,
						type = "range",
						name = L["FONT_SIZE"],
						min = 4, max = 32, step = 1,
						disabled = function() return not E.db.nameplates.units[unit].name.enable end
					},
					fontOutline = {
						order = 6,
						type = "select",
						name = L["Font Outline"],
						desc = L["Set the font outline."],
						values = C.Values.FontFlags,
						disabled = function() return not E.db.nameplates.units[unit].name.enable end
					}
				}
			},
			raidTargetIndicator = {
				order = 7,
				type = "group",
				name = L["Target Marker Icon"],
				get = function(info)
					return E.db.nameplates.units[unit].raidTargetIndicator[info[#info]]
				end,
				set = function(info, value)
					E.db.nameplates.units[unit].raidTargetIndicator[info[#info]] = value
					NP:ConfigureAll()
				end,
				args = {
					size = {
						order = 1,
						type = "range",
						name = L["Size"],
						min = 12, max = 64, step = 1
					},
					xOffset = {
						order = 2,
						type = "range",
						name = L["X-Offset"],
						min = -100, max = 100, step = 1
					},
					yOffset = {
						order = 3,
						type = "range",
						name = L["Y-Offset"],
						min = -100, max = 100, step = 1
					},
					position = {
						order = 4,
						type = "select",
						name = L["Icon Position"],
						values = {
							["TOP"] = L["Top"],
							["LEFT"] = L["Left"],
							["RIGHT"] = L["Right"],
							["CENTER"] = L["Center"],
							["BOTTOM"] = L["Bottom"]
						}
					}
				}
			}
		}
	}

	if unit == "FRIENDLY_PLAYER" or unit == "ENEMY_PLAYER" then
		group.args.pvpRole = {
			order = 7,
			type = "group",
			name = L["Role Icon"],
			get = function(info) return E.db.nameplates.units[unit].pvpRole[info[#info]] end,
			set = function(info, value) E.db.nameplates.units[unit].pvpRole[info[#info]] = value NP:PLAYER_ENTERING_WORLD() NP:ConfigureAll() end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"]
				},
				markHealers = {
					order = 2,
					type = "toggle",
					name = L["Healer Icon"],
					desc = L["Display a healer icon over known healers inside battlegrounds or arenas."],
					disabled = function() return not E.db.nameplates.units[unit].pvpRole.enable end
				},
				markTanks = {
					order = 3,
					type = "toggle",
					name = L["Tank Icon"],
					desc = L["Display a tank icon over known tanks inside battlegrounds or arenas."],
					disabled = function() return not E.db.nameplates.units[unit].pvpRole.enable end
				}
			}
		}
		if unit == "ENEMY_PLAYER" then
			group.args.comboPoints = {
				order = 8,
				type = "group",
				name = L["COMBO_POINTS"],
				get = function(info) return E.db.nameplates.units.ENEMY_PLAYER.comboPoints[info[#info]] end,
				set = function(info, value) E.db.nameplates.units.ENEMY_PLAYER.comboPoints[info[#info]] = value NP:UNIT_COMBO_POINTS() NP:ConfigureAll() end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"]
					},
					hideEmpty = {
						order = 2,
						type = "toggle",
						name = L["Hide Empty"],
						disabled = function() return not E.db.nameplates.units.ENEMY_PLAYER.comboPoints.enable end
					},
					spacer = {
						order = 3,
						type = "description",
						name = " "
					},
					width = {
						order = 4,
						type = "range",
						name = L["Width"],
						min = 4, max = 30, step = 1,
						disabled = function() return not E.db.nameplates.units.ENEMY_PLAYER.comboPoints.enable end
					},
					height = {
						order = 5,
						type = "range",
						name = L["Height"],
						min = 4, max = 30, step = 1,
						disabled = function() return not E.db.nameplates.units.ENEMY_PLAYER.comboPoints.enable end
					},
					spacing = {
						order = 6,
						type = "range",
						name = L["Spacing"],
						min = 1, max = 20, step = 1,
						disabled = function() return not E.db.nameplates.units.ENEMY_PLAYER.comboPoints.enable end
					},
					xOffset = {
						order = 7,
						type = "range",
						name = L["X-Offset"],
						min = -100, max = 100, step = 1,
						disabled = function() return not E.db.nameplates.units.ENEMY_PLAYER.comboPoints.enable end
					},
					yOffset = {
						order = 8,
						type = "range",
						name = L["Y-Offset"],
						min = -100, max = 100, step = 1,
						disabled = function() return not E.db.nameplates.units.ENEMY_PLAYER.comboPoints.enable end
					}
				}
			}
		end
		group.args.healthGroup.args.useClassColor = {
			order = 3.1,
			type = "toggle",
			name = L["Use Class Color"]
		}
		group.args.nameGroup.args.useClassColor = {
			order = 2,
			type = "toggle",
			name = L["Use Class Color"],
			disabled = function() return not E.db.nameplates.units[unit].name.enable end
		}
	elseif unit == "ENEMY_NPC" or unit == "FRIENDLY_NPC" then
		group.args.eliteIcon = {
			order = 7,
			type = "group",
			name = L["Elite Icon"],
			get = function(info) return E.db.nameplates.units[unit].eliteIcon[info[#info]] end,
			set = function(info, value) E.db.nameplates.units[unit].eliteIcon[info[#info]] = value NP:ConfigureAll() end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"]
				},
				spacer = {
					order = 2,
					type = "description",
					name = " "
				},
				size = {
					order = 3,
					type = "range",
					name = L["Size"],
					min = 12, max = 42, step = 1,
					disabled = function() return not E.db.nameplates.units[unit].eliteIcon.enable end
				},
				xOffset = {
					order = 4,
					type = "range",
					name = L["X-Offset"],
					min = -100, max = 100, step = 1,
					disabled = function() return not E.db.nameplates.units[unit].eliteIcon.enable end
				},
				yOffset = {
					order = 5,
					type = "range",
					name = L["Y-Offset"],
					min = -100, max = 100, step = 1,
					disabled = function() return not E.db.nameplates.units[unit].eliteIcon.enable end
				},
				position = {
					order = 6,
					type = "select",
					name = L["Position"],
					values = {
						["TOP"] = L["Top"],
						["LEFT"] = L["Left"],
						["RIGHT"] = L["Right"],
						["BOTTOM"] = L["Bottom"],
						["CENTER"] = L["Center"]
					},
					disabled = function() return not E.db.nameplates.units[unit].eliteIcon.enable end
				}
			}
		}
		group.args.iconFrame = {
			order = 8,
			type = "group",
			name = L["Icon Frame"],
			get = function(info) return E.db.nameplates.units[unit].iconFrame[info[#info]] end,
			set = function(info, value) E.db.nameplates.units[unit].iconFrame[info[#info]] = value NP:ConfigureAll() end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"]
				},
				size = {
					order = 2,
					type = "range",
					name = L["Size"],
					min = 8, max = 48, step = 1,
				},
				position = {
					order = 3,
					type = "select",
					name = L["Position"],
					values = {
						["CENTER"] = L["Center"],
						["TOPLEFT"] = L["Top Left"],
						["TOPRIGHT"] = L["Top Right"],
						["BOTTOMLEFT"] = L["Bottom Left"],
						["BOTTOMRIGHT"] = L["Bottom Right"]
					}
				},
				parent = {
					order = 4,
					type = "select",
					name = L["Parent"],
					values = {
						["Nameplate"] = L["Nameplate"],
						["Health"] = L["HEALTH"]
					}
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
				}
			}
		}
		if unit == "ENEMY_NPC" then
			group.args.comboPoints = {
				order = 8,
				type = "group",
				name = L["COMBO_POINTS"],
				get = function(info) return E.db.nameplates.units.ENEMY_NPC.comboPoints[info[#info]] end,
				set = function(info, value) E.db.nameplates.units.ENEMY_NPC.comboPoints[info[#info]] = value NP:UNIT_COMBO_POINTS() NP:ConfigureAll() end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"]
					},
					hideEmpty = {
						order = 2,
						type = "toggle",
						name = L["Hide Empty"],
						disabled = function() return not E.db.nameplates.units.ENEMY_NPC.comboPoints.enable end
					},
					spacer = {
						order = 3,
						type = "description",
						name = " "
					},
					width = {
						order = 4,
						type = "range",
						name = L["Width"],
						min = 4, max = 30, step = 1,
						disabled = function() return not E.db.nameplates.units.ENEMY_NPC.comboPoints.enable end
					},
					height = {
						order = 5,
						type = "range",
						name = L["Height"],
						min = 4, max = 30, step = 1,
						disabled = function() return not E.db.nameplates.units.ENEMY_NPC.comboPoints.enable end
					},
					spacing = {
						order = 6,
						type = "range",
						name = L["Spacing"],
						min = 1, max = 20, step = 1,
						disabled = function() return not E.db.nameplates.units.ENEMY_NPC.comboPoints.enable end
					},
					xOffset = {
						order = 7,
						type = "range",
						name = L["X-Offset"],
						min = -100, max = 100, step = 1,
						disabled = function() return not E.db.nameplates.units.ENEMY_NPC.comboPoints.enable end
					},
					yOffset = {
						order = 8,
						type = "range",
						name = L["Y-Offset"],
						min = -100, max = 100, step = 1,
						disabled = function() return not E.db.nameplates.units.ENEMY_NPC.comboPoints.enable end
					}
				}
			}
		end

		group.args.nameGroup.args.useReactionColor = {
			order = 2,
			type = "toggle",
			name = L["Use Reaction Color"],
			disabled = function() return not E.db.nameplates.units[unit].name.enable end
		}
	end

	ORDER = ORDER + 100

	return group
end

E.Options.args.nameplate = {
	order = 2,
	type = "group",
	name = L["NamePlates"],
	childGroups = "tab",
	get = function(info) return E.db.nameplates[info[#info]] end,
	set = function(info, value) E.db.nameplates[info[#info]] = value NP:ConfigureAll() end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["NAMEPLATE_DESC"]
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["ENABLE"],
			get = function(info)
				return E.private.nameplates[info[#info]]
			end,
			set = function(info, value)
				E.private.nameplates[info[#info]] = value
				E:StaticPopup_Show("PRIVATE_RL")
			end
		},
		generalGroup = {
			order = 3,
			type = "group",
			name = L["General"],
			childGroups = "tree",
			get = function(info)
				return E.db.nameplates[info[#info]]
			end,
			set = function(info, value)
				E.db.nameplates[info[#info]] = value
				NP:ConfigureAll()
			end,
			disabled = function() return not E.NamePlates.Initialized end,
			args = {
				motionType = {
					order = 1,
					type = "select",
					name = L["UNIT_NAMEPLATES_TYPES"],
					desc = L["Set to either stack nameplates vertically or allow them to overlap."],
					values = {
						["SPREADING"] = L["UNIT_NAMEPLATES_TYPE_3"],
						["STACKED"] = L["UNIT_NAMEPLATES_TYPE_2"],
						["OVERLAP"] = L["UNIT_NAMEPLATES_TYPE_1"]
					}
				},
				showEnemyCombat = {
					order = 2,
					type = "select",
					name = L["Enemy Combat Toggle"],
					desc = L["Control enemy nameplates toggling on or off when in combat."],
					values = {
						["DISABLED"] = L["DISABLE"],
						["TOGGLE_ON"] = L["Toggle On While In Combat"],
						["TOGGLE_OFF"] = L["Toggle Off While In Combat"]
					},
					set = function(info, value)
						E.db.nameplates[info[#info]] = value
						NP:PLAYER_REGEN_ENABLED()
					end
				},
				showFriendlyCombat = {
					order = 3,
					type = "select",
					name = L["Friendly Combat Toggle"],
					desc = L["Control friendly nameplates toggling on or off when in combat."],
					values = {
						["DISABLED"] = L["DISABLE"],
						["TOGGLE_ON"] = L["Toggle On While In Combat"],
						["TOGGLE_OFF"] = L["Toggle Off While In Combat"]
					},
					set = function(info, value)
						E.db.nameplates[info[#info]] = value
						NP:PLAYER_REGEN_ENABLED()
					end
				},
				statusbar = {
					order = 4,
					type = "select",
					dialogControl = "LSM30_Statusbar",
					name = L["StatusBar Texture"],
					values = AceGUIWidgetLSMlists.statusbar
				},
				lowHealthThreshold = {
					order = 5,
					type = "range",
					name = L["Low Health Threshold"],
					desc = L["Make the unitframe glow yellow when it is below this percent of health, it will glow red when the health value is half of this value."],
					isPercent = true,
					min = 0, max = 1, step = 0.01
				},
				resetFilters = {
					order = 6,
					type = "execute",
					name = L["Reset Aura Filters"],
					func = function()
						E:StaticPopup_Show("RESET_NP_AF") --reset nameplate aurafilters
					end
				},
				spacer = {
					order = 7,
					type = "description",
					name = " "
				},
				fadeIn = {
					order = 8,
					type = "toggle",
					name = L["Alpha Fading"]
				},
				smoothbars = {
					order = 9,
					type = "toggle",
					name = L["Smooth Bars"],
					desc = L["Bars will transition smoothly."],
					set = function(info, value)
						E.db.nameplates[info[#info]] = value
						NP:ConfigureAll()
					end
				},
				highlight = {
					order = 10,
					type = "toggle",
					name = L["Hover Highlight"]
				},
				nameColoredGlow = {
					order = 11,
					type = "toggle",
					name = L["Name Colored Glow"],
					desc = L["Use the Name Color of the unit for the Name Glow."],
					disabled = function() return not E.db.nameplates.highlight end
				},
				targetGroup = {
					order = 12,
					type = "group",
					name = L["TARGET"],
					disabled = function() return not E.NamePlates.Initialized end,
					args = {
						useTargetScale = {
							order = 1,
							type = "toggle",
							name = L["Use Target Scale"],
							desc = L["Enable/Disable the scaling of targetted nameplates."],
							get = function() return E.db.nameplates.useTargetScale end,
							set = function(_, value)
								E.db.nameplates.useTargetScale = value
								NP:ConfigureAll()
							end
						},
						targetScale = {
							order = 2,
							type = "range",
							isPercent = true,
							name = L["Target Scale"],
							desc = L["Scale of the nameplate that is targetted."],
							min = 0.3, max = 2, step = 0.01,
							get = function() return E.db.nameplates.targetScale end,
							set = function(_, value)
								E.db.nameplates.targetScale = value
								NP:ConfigureAll()
							end,
							disabled = function() return E.db.nameplates.useTargetScale ~= true end
						},
						nonTargetTransparency = {
							order = 3,
							type = "range",
							isPercent = true,
							name = L["Non-Target Alpha"],
							min = 0, max = 1, step = 0.01,
							get = function() return E.db.nameplates.nonTargetTransparency end,
							set = function(_, value)
								E.db.nameplates.nonTargetTransparency = value
								NP:ConfigureAll()
							end
						},
						spacer1 = {
							order = 4,
							type = "description",
							name = " "
						},
						alwaysShowTargetHealth = {
							order = 5,
							type = "toggle",
							name = L["Always Show Target Health"],
							get = function() return E.db.nameplates.alwaysShowTargetHealth end,
							set = function(_, value)
								E.db.nameplates.alwaysShowTargetHealth = value
								NP:ConfigureAll()
							end,
							customWidth = 200
						},
						glowStyle = {
							order = 6,
							type = "select",
							name = L["Target/Low Health Indicator"],
							customWidth = 225,
							values = {
								["none"] = L["NONE"],
								["style1"] = L["Border Glow"],
								["style2"] = L["Background Glow"],
								["style3"] = L["Top Arrow"],
								["style4"] = L["Side Arrows"],
								["style5"] = L["Border Glow"].." + "..L["Top Arrow"],
								["style6"] = L["Background Glow"].." + "..L["Top Arrow"],
								["style7"] = L["Border Glow"].." + "..L["Side Arrows"],
								["style8"] = L["Background Glow"].." + "..L["Side Arrows"]
							},
							get = function() return E.db.nameplates.glowStyle end,
							set = function(_, value)
								E.db.nameplates.glowStyle = value
								NP:ConfigureAll()
							end
						},
						arrowSize = {
							order = 7,
							type = "range",
							name = L["Arrow Size"],
							min = 20, max = 100, step = 1,
							get = function(_, value) return E.db.nameplates.arrowSize end,
							set = function(_, value)
								E.db.nameplates.arrowSize = value
								NP:ConfigureAll()
							end
						},
						arrowSpacing = {
							order = 8,
							type = "range",
							name = L["Arrow Spacing"],
							min = 0, max = 50, step = 1,
							get = function(_, value) return E.db.nameplates.arrowSpacing end,
							set = function(_, value)
								E.db.nameplates.arrowSpacing = value
								NP:ConfigureAll()
							end
						},
						arrow = {
							order = 9,
							type = "multiselect",
							name = L["Arrow Texture"],
							customWidth = 80,
							get = function(_, value) return E.db.nameplates.arrow == value end,
							set = function(_, value)
								E.db.nameplates.arrow = value
								NP:ConfigureAll()
							end
						}
					}
				},
				trivialGroup = {
					order = 13,
					type = "group",
					name = L["Trivial"],
					get = function(info)
						return E.db.nameplates[info[#info]]
					end,
					set = function(info, value)
						E.db.nameplates[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function() return not E.NamePlates.Initialized end,
					args = {
						trivial = {
							order = 1,
							type = "toggle",
							name = L["ENABLE"]
						},
						trivialWidth = {
							order = 2,
							type = "range",
							name = L["Width"],
							min = 30, max = 100, step = 1,
							disabled = function() return not E.db.nameplates.trivial end
						},
						trivialHeight = {
							order = 3,
							type = "range",
							name = L["Height"],
							min = 5, max = 20, step = 1,
							disabled = function() return not E.db.nameplates.trivial end
						}
					}
				},
				threatGroup = {
					order = 14,
					type = "group",
					name = L["Threat"],
					get = function(info)
						local t = E.db.nameplates.threat[info[#info]]
						local d = P.nameplates.threat[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.nameplates.threat[info[#info]]
						t.r, t.g, t.b = r, g, b
					end,
					args = {
						useThreatColor = {
							order = 1,
							type = "toggle",
							name = L["Use Threat Color"],
							get = function(info) return E.db.nameplates.threat.useThreatColor end,
							set = function(info, value) E.db.nameplates.threat.useThreatColor = value end
						},
						goodScale = {
							order = 2,
							type = "range",
							name = L["Good Scale"],
							get = function(info) return E.db.nameplates.threat[info[#info]] end,
							set = function(info, value) E.db.nameplates.threat[info[#info]] = value end,
							min = 0.3, max = 2, step = 0.01,
							isPercent = true
						},
						badScale = {
							order = 3,
							type = "range",
							name = L["Bad Scale"],
							get = function(info) return E.db.nameplates.threat[info[#info]] end,
							set = function(info, value) E.db.nameplates.threat[info[#info]] = value end,
							min = 0.3, max = 2, step = 0.01,
							isPercent = true
						}
					}
				},
				colorsGroup = {
					order = 15,
					type = "group",
					name = L["COLORS"],
					args = {
						general = {
							order = 1,
							type = "group",
							name = L["General"],
							guiInline = true,
							get = function(info)
								local t = E.db.nameplates.colors[info[#info]]
								local d = P.nameplates.colors[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.nameplates.colors[info[#info]]
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end,
							args = {
								glowColor = {
									order = 1,
									type = "color",
									name = L["Target Indicator Color"],
									hasAlpha = true
								}
							}
						},
						threat = {
							order = 2,
							type = "group",
							name = L["Threat"],
							guiInline = true,
							get = function(info)
								local t = E.db.nameplates.colors.threat[info[#info]]
								local d = P.nameplates.colors.threat[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.nameplates.colors.threat[info[#info]]
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end,
							args = {
								goodColor = {
									order = 1,
									type = "color",
									name = L["Good Color"],
									hasAlpha = false,
									disabled = function()
										return not E.db.nameplates.threat.useThreatColor
									end
								},
								goodTransition = {
									order = 2,
									type = "color",
									name = L["Good Transition Color"],
									hasAlpha = false,
									disabled = function()
										return not E.db.nameplates.threat.useThreatColor
									end
								},
								badTransition = {
									order = 3,
									type = "color",
									name = L["Bad Transition Color"],
									hasAlpha = false,
									disabled = function()
										return not E.db.nameplates.threat.useThreatColor
									end
								},
								badColor = {
									order = 4,
									type = "color",
									name = L["Bad Color"],
									hasAlpha = false,
									disabled = function()
										return not E.db.nameplates.threat.useThreatColor
									end
								}
							}
						},
						castGroup = {
							order = 3,
							type = "group",
							name = L["Cast Bar"],
							guiInline = true,
							get = function(info)
								local t = E.db.nameplates.colors[info[#info]]
								local d = P.nameplates.colors[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.nameplates.colors[info[#info]]
								t.r, t.g, t.b = r, g, b
								NP:ConfigureAll()
							end,
							args = {
								castColor = {
									order = 1,
									type = "color",
									name = L["Cast Color"],
									hasAlpha = false
								},
								castNoInterruptColor = {
									order = 2,
									type = "color",
									name = L["Cast No Interrupt Color"],
									hasAlpha = false
								},
								castbarDesaturate = {
									order = 3,
									type = "toggle",
									name = L["Desaturated Icon"],
									desc = L["Show the castbar icon desaturated if a spell is not interruptible."],
									get = function(info)
										return E.db.nameplates.colors[info[#info]]
									end,
									set = function(info, value)
										E.db.nameplates.colors[info[#info]] = value
										NP:ConfigureAll()
									end
								}
							}
						},
						reactions = {
							order = 5,
							type = "group",
							name = L["Reaction Colors"],
							guiInline = true,
							get = function(info)
								local t = E.db.nameplates.colors.reactions[info[#info]]
								local d = P.nameplates.colors.reactions[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.nameplates.colors.reactions[info[#info]]
								t.r, t.g, t.b = r, g, b
								NP:ConfigureAll()
							end,
							args = {
								friendlyPlayer = {
									order = 1,
									type = "color",
									name = L["FRIENDLY_PLAYER"],
									hasAlpha = false
								},
								bad = {
									order = 2,
									type = "color",
									name = L["ENEMY"],
									hasAlpha = false
								},
								neutral = {
									order = 3,
									type = "color",
									name = L["Neutral"],
									hasAlpha = false
								},
								good = {
									order = 4,
									type = "color",
									name = L["FRIENDLY_NPC"],
									hasAlpha = false
								},
								tapped = {
									order = 5,
									type = "color",
									name = L["Tapped"],
									hasAlpha = false
								}
							}
						},
						comboPoints = {
							order = 6,
							type = "group",
							name = L["COMBO_POINTS"],
							guiInline = true,
							args = {}
						}
					}
				},
				cutawayHealth = {
					order = 16,
					type = "group",
					name = L["Cutaway Bars"],
					args = {
						enabled = {
							order = 1,
							type = "toggle",
							name = L["ENABLE"],
							get = function(info) return E.db.nameplates.cutawayHealth end,
							set = function(info, value) E.db.nameplates.cutawayHealth = value end,
						},
						healthLength = {
							order = 2,
							type = "range",
							name = L["Health Length"],
							desc = L["How much time before the cutaway health starts to fade."],
							min = 0.1, max = 1, step = 0.1,
							get = function(info) return E.db.nameplates.cutawayHealthLength end,
							set = function(info, value) E.db.nameplates.cutawayHealthLength = value end,
							disabled = function() return not E.db.nameplates.cutawayHealth end
						},
						healthFadeOutTime = {
							order = 3,
							type = "range",
							name = L["Fade Out"],
							desc = L["How long the cutaway health will take to fade out."],
							min = 0.1, max = 1, step = 0.1,
							get = function(info) return E.db.nameplates.cutawayHealthFadeOutTime end,
							set = function(info, value) E.db.nameplates.cutawayHealthFadeOutTime = value end,
							disabled = function() return not E.db.nameplates.cutawayHealth end
						}
					}
				},
				clickThroughGroup = {
					order = 17,
					type = "group",
					name = L["Click Through"],
					get = function(info)
						return E.db.nameplates.clickThrough[info[#info]]
					end,
					set = function(info, value)
						E.db.nameplates.clickThrough[info[#info]] = value
						NP:ConfigureAll()
					end,
					args = {
						friendly = {
							order = 1,
							type = "toggle",
							name = L["Friendly"],
						},
						enemy = {
							order = 2,
							type = "toggle",
							name = L["ENEMY"]
						},
						trivial = {
							order = 3,
							type = "toggle",
							name = L["Trivial"],
							disabled = function() return not E.db.nameplates.trivial end
						}
					}
				},
				clickableRangeGroup = {
					order = 18,
					type = "group",
					name = L["Clickable Size"],
					args = {
						friendly = {
							order = 1,
							type = "group",
							guiInline = true,
							name = L["Friendly"],
							get = function(info)
								return E.db.nameplates.plateSize[info[#info]]
							end,
							set = function(info, value)
								E.db.nameplates.plateSize[info[#info]] = value
								NP:ConfigureAll()
							end,
							args = {
								friendlyWidth = {
									order = 1,
									type = "range",
									name = L["Clickable Width"],
									desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
									min = 50, max = 250, step = 1
								},
								friendlyHeight = {
									order = 2,
									type = "range",
									name = L["Clickable Height"],
									desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
									min = 10, max = 75, step = 1
								}
							}
						},
						enemy = {
							order = 2,
							type = "group",
							guiInline = true,
							name = L["ENEMY"],
							get = function(info)
								return E.db.nameplates.plateSize[info[#info]]
							end,
							set = function(info, value)
								E.db.nameplates.plateSize[info[#info]] = value
								NP:ConfigureAll()
							end,
							args = {
								enemyWidth = {
									order = 1,
									type = "range",
									name = L["Clickable Width"],
									desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
									min = 50, max = 250, step = 1
								},
								enemyHeight = {
									order = 2,
									type = "range",
									name = L["Clickable Height"],
									desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
									min = 10, max = 75, step = 1
								}
							}
						},
						trivial = {
							order = 3,
							type = "group",
							guiInline = true,
							name = L["Trivial"],
							get = function(info)
								return E.db.nameplates.plateSize[info[#info]]
							end,
							set = function(info, value)
								E.db.nameplates.plateSize[info[#info]] = value
								NP:ConfigureAll()
							end,
							disabled = function() return not E.db.nameplates.trivial end,
							args = {
								trivialWidth = {
									order = 1,
									type = "range",
									name = L["Clickable Width"],
									desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
									min = 30, max = 100, step = 1
								},
								trivialHeight = {
									order = 2,
									type = "range",
									name = L["Clickable Height"],
									desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
									min = 5, max = 20, step = 1
								}
							}
						}
					}
				}
			}
		},
		friendlyPlayerGroup = GetUnitSettings("FRIENDLY_PLAYER", L["FRIENDLY_PLAYER"]),
		friendlyNPCGroup = GetUnitSettings("FRIENDLY_NPC", L["FRIENDLY_NPC"]),
		enemyPlayerGroup = GetUnitSettings("ENEMY_PLAYER", L["ENEMY_PLAYER"]),
		enemyNPCGroup = GetUnitSettings("ENEMY_NPC", L["ENEMY_NPC"]),
		filters = {
			order = -99,
			type = "group",
			name = L["Style Filter"],
			childGroups = "tab",
			disabled = function()
				return not E.NamePlates.Initialized
			end,
			args = {
				addFilter = {
					order = 1,
					type = "input",
					name = L["Create Filter"],
					get = function(info)
						return ""
					end,
					set = function(info, value)
						if match(value, "^[%s%p]-$") then
							return
						end
						if E.global.nameplates.filters[value] then
							E:Print(L["Filter already exists!"])
							return
						end
						local filter = {}
						NP:StyleFilterCopyDefaults(filter)
						E.global.nameplates.filters[value] = filter
						UpdateFilterGroup()
						NP:ConfigureAll()
					end
				},
				selectFilter = {
					order = 2,
					type = "select",
					sortByValue = true,
					name = L["Select Filter"],
					get = function(info) return selectedNameplateFilter end,
					set = function(info, value) selectedNameplateFilter = value UpdateFilterGroup() end,
					values = function()
						local filters, priority, name = {}
						local list = E.global.nameplates.filters
						local profile = E.db.nameplates.filters
						if not list then return end
						for filter, content in pairs(list) do
							priority = (content.triggers and content.triggers.priority) or "?"
							name = (content.triggers and profile[filter] and profile[filter].triggers and profile[filter].triggers.enable and filter) or (content.triggers and format("|cFF666666%s|r", filter)) or filter
							filters[filter] = format("|cFFffff00(%s)|r %s", priority, name)
						end
						return filters
					end
				},
				removeFilter = {
					order = 3,
					type = "execute",
					name = L["Delete Filter"],
					desc = L["Delete a created filter, you cannot delete pre-existing filters, only custom ones."],
					confirm = true,
					confirmText = L["Delete Filter"],
					func = function()
						for profile in pairs(E.data.profiles) do
							if E.data.profiles[profile].nameplates and E.data.profiles[profile].nameplates.filters and E.data.profiles[profile].nameplates.filters[selectedNameplateFilter] then
								E.data.profiles[profile].nameplates.filters[selectedNameplateFilter] = nil
							end
						end
						E.global.nameplates.filters[selectedNameplateFilter] = nil
						selectedNameplateFilter = nil
						UpdateFilterGroup()
						NP:ConfigureAll()
					end,
					disabled = function() return G.nameplates.filters[selectedNameplateFilter] end,
					hidden = function() return selectedNameplateFilter == nil end
				}
			}
		}
	}
}

do -- target arrow textures
	local arrows = {}
	E.Options.args.nameplate.args.generalGroup.args.targetGroup.args.arrow.values = arrows

	for key, arrow in pairs(E.Media.Arrows) do
		arrows[key] = E:TextureString(arrow, ":32:32")
	end
end

for i = 1, 5 do
	E.Options.args.nameplate.args.generalGroup.args.colorsGroup.args.comboPoints.args["COMBO_POINTS"..i] = {
		order = i,
		type = "color",
		name = L["Combo Point"].." #"..i,
		get = function(info)
			local t = E.db.nameplates.colors.comboPoints[i]
			local d = P.nameplates.colors.comboPoints[i]
			return t.r, t.g, t.b, t.a, d.r, d.g, d.b
		end,
		set = function(info, r, g, b)
			local t = E.db.nameplates.colors.comboPoints[i]
			t.r, t.g, t.b = r, g, b
			NP:ConfigureAll()
		end
	}
end