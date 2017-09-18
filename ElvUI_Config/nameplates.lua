local E, L, V, P, G = unpack(ElvUI);
local NP = E:GetModule("NamePlates");

local selectedFilter;
local filters;

local ACD = LibStub("AceConfigDialog-3.0-ElvUI");

local positionValues = {
	TOPLEFT = "TOPLEFT",
	LEFT = "LEFT",
	BOTTOMLEFT = "BOTTOMLEFT",
	RIGHT = "RIGHT",
	TOPRIGHT = "TOPRIGHT",
	BOTTOMRIGHT = "BOTTOMRIGHT",
	CENTER = "CENTER",
	TOP = "TOP",
	BOTTOM = "BOTTOM"
};

local function UpdateFilterGroup()
	if not selectedFilter or not E.global["nameplates"]["filter"][selectedFilter] then
		E.Options.args.nameplate.args.generalGroup.args.filters.args.filterGroup = nil
		return
	end

	E.Options.args.nameplate.args.generalGroup.args.filters.args.filterGroup = {
		type = "group",
		name = selectedFilter,
		guiInline = true,
		order = -10,
		get = function(info) return E.global["nameplates"]["filter"][selectedFilter][ info[#info] ] end,
		set = function(info, value) E.global["nameplates"]["filter"][selectedFilter][ info[#info] ] = value; NP:ForEachPlate("CheckFilter"); NP:ConfigureAll(); UpdateFilterGroup() end,
		args = {
			enable = {
				type = "toggle",
				order = 1,
				name = L["Enable"],
				desc = L["Use this filter."],
			},
			hide = {
				type = "toggle",
				order = 2,
				name = L["Hide"],
				desc = L["Prevent any nameplate with this unit name from showing."],
			},
			customColor = {
				type = "toggle",
				order = 3,
				name = L["Custom Color"],
				desc = L["Disable threat coloring for this plate and use the custom color."],
			},
			color = {
				type = "color",
				order = 4,
				name = L["Color"],
				get = function(info)
					local t = E.global["nameplates"]["filter"][selectedFilter][ info[#info] ]
					if t then
						return t.r, t.g, t.b, t.a
					end
				end,
				set = function(info, r, g, b)
					E.global["nameplates"]["filter"][selectedFilter][ info[#info] ] = {}
					local t = E.global["nameplates"]["filter"][selectedFilter][ info[#info] ]
					if t then
						t.r, t.g, t.b = r, g, b
						UpdateFilterGroup()
						NP:ForEachPlate("CheckFilter")
						NP:ConfigureAll()
					end
				end
			},
			customScale = {
				type = "range",
				name = L["Custom Scale"],
				desc = L["Set the scale of the nameplate."],
				min = 0.67, max = 2, step = 0.01
			}
		}
	}
end

local ORDER = 100;
local function GetUnitSettings(unit, name)
	local copyValues = {};
	for x, y in pairs(NP.db.units) do
		if(type(y) == "table" and x ~= unit) then
			copyValues[x] = L[x];
		end
	end
	local group = {
		order = ORDER,
		type = "group",
		name = name,
		childGroups = "tab",
		get = function(info) return E.db.nameplates.units[unit][ info[#info] ]; end,
		set = function(info, value) E.db.nameplates.units[unit][ info[#info] ] = value; NP:ConfigureAll(); end,
		disabled = function() return not E.NamePlates end,
		args = {
			copySettings = {
				order = -10,
				type = "select",
				name = L["Copy Settings From"],
				desc = L["Copy settings from another unit."],
				values = copyValues,
				get = function() return ""; end,
				set = function(info, value)
					NP:CopySettings(value, unit);
					NP:ConfigureAll();
				end
			},
			defaultSettings = {
				order = -9,
				type = "execute",
				name = L["Default Settings"],
				desc = L["Set Settings to Default"],
				func = function(info, value)
					NP:ResetSettings(unit);
					NP:ConfigureAll();
				end
			},
			healthGroup = {
				order = 1,
				name = L["Health"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].healthbar[ info[#info] ]; end,
				set = function(info, value) E.db.nameplates.units[unit].healthbar[ info[#info] ] = value; NP:ConfigureAll(); end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["Health"]
					},
					enable = {
						order = 2,
						type = "toggle",
						name = L["Enable"]
					},
					height = {
						order = 3,
						type = "range",
						name = L["Height"],
						min = 4, max = 20, step = 1
					},
					width = {
						order = 4,
						type = "range",
						name = L["Width"],
						min = 50, max = 200, step = 1
					},
					textGroup = {
						order = 5,
						type = "group",
						name = L["Text"],
						guiInline = true,
						get = function(info) return E.db.nameplates.units[unit].healthbar.text[ info[#info] ]; end,
						set = function(info, value) E.db.nameplates.units[unit].healthbar.text[ info[#info] ] = value; NP:ConfigureAll(); end,
						args = {
							enable = {
								order = 1,
								type = "toggle",
								name = L["Enable"]
							},
							format = {
								order = 2,
								name = L["Format"],
								type = "select",
								values = {
									["CURRENT"] = L["Current"],
									["CURRENT_MAX"] = L["Current / Max"],
									["CURRENT_PERCENT"] =  L["Current - Percent"],
									["CURRENT_MAX_PERCENT"] = L["Current - Max | Percent"],
									["PERCENT"] = L["Percent"],
									["DEFICIT"] = L["Deficit"]
								}
							}
						}
					}
				}
			},
			castGroup = {
				order = 2,
				name = L["Cast Bar"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].castbar[ info[#info] ]; end,
				set = function(info, value) E.db.nameplates.units[unit].castbar[ info[#info] ] = value; NP:ConfigureAll(); end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["Cast Bar"]
					},
					hideSpellName = {
						order = 2,
						type = "toggle",
						name = L["Hide Spell Name"]
					},
					hideTime = {
						order = 3,
						type = "toggle",
						name = L["Hide Time"]
					},
					height = {
						order = 4,
						type = "range",
						name = L["Height"],
						min = 4, max = 20, step = 1
					},
					castTimeFormat = {
						order = 5,
						type = "select",
						name = L["Cast Time Format"],
						values = {
							["CURRENT"] = L["Current"],
							["CURRENT_MAX"] = L["Current / Max"],
							["REMAINING"] = L["Remaining"]
						}
					},
					channelTimeFormat = {
						order = 6,
						type = "select",
						name = L["Channel Time Format"],
						values = {
							["CURRENT"] = L["Current"],
							["CURRENT_MAX"] = L["Current / Max"],
							["REMAINING"] = L["Remaining"]
						}
					},
					offset = {
						order = 7,
						type = "range",
						name = L["Offset"],
						min = 0, max = 30, step = 1
					}
				}
			},
			buffsGroup = {
				order = 3,
				name = L["Buffs"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].buffs.filters[ info[#info] ]; end,
				set = function(info, value) E.db.nameplates.units[unit].buffs.filters[ info[#info] ] = value; NP:ConfigureAll(); end,
				disabled = function() return not E.db.nameplates.units[unit].healthbar.enable; end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["Buffs"]
					},
					enable = {
						order = 2,
						type = "toggle",
						name = L["Enable"],
						get = function(info) return E.db.nameplates.units[unit].buffs[ info[#info] ]; end,
						set = function(info, value) E.db.nameplates.units[unit].buffs[ info[#info] ] = value; NP:ConfigureAll(); end
					},
					numAuras = {
						order = 3,
						type = "range",
						name = L["# Displayed Auras"],
						desc = L["Controls how many auras are displayed, this will also affect the size of the auras."],
						min = 1, max = 8, step = 1,
						get = function(info) return E.db.nameplates.units[unit].buffs[ info[#info] ]; end,
						set = function(info, value) E.db.nameplates.units[unit].buffs[ info[#info] ] = value; NP:ConfigureAll(); end
					},
					baseHeight = {
						order = 4,
						type = "range",
						name = L["Icon Base Height"],
						desc = L["Base Height for the Aura Icon"],
						min = 6, max = 60, step = 1,
						get = function(info) return E.db.nameplates.units[unit].buffs[ info[#info] ]; end,
						set = function(info, value) E.db.nameplates.units[unit].buffs[ info[#info] ] = value; NP:ConfigureAll(); end
					},
					filtersGroup = {
						name = L["Filters"],
						order = 5,
						type = "group",
						guiInline = true,
						args = {
							personal = {
								order = 1,
								type = "toggle",
								name = L["Personal Auras"]
							},
							maxDuration = {
								order = 2,
								type = "range",
								name = L["Maximum Duration"],
								min = 5, max = 3000, step = 1
							},
							filter = {
								order = 3,
								type = "select",
								name = L["Filter"],
								values = function()
									local filters = {}
									filters[""] = NONE
									for filter in pairs(E.global.unitframe["aurafilters"]) do
										filters[filter] = filter
									end
									return filters
								end
							}
						}
					}
				}
			},
			debuffsGroup = {
				order = 4,
				name = L["Debuffs"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].debuffs.filters[ info[#info] ]; end,
				set = function(info, value) E.db.nameplates.units[unit].debuffs.filters[ info[#info] ] = value; NP:ConfigureAll(); end,
				disabled = function() return not E.db.nameplates.units[unit].healthbar.enable; end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["Debuffs"]
					},
					enable = {
						order = 2,
						type = "toggle",
						name = L["Enable"],
						get = function(info) return E.db.nameplates.units[unit].debuffs[ info[#info] ]; end,
						set = function(info, value) E.db.nameplates.units[unit].debuffs[ info[#info] ] = value; NP:ConfigureAll(); end
					},
					numAuras = {
						order = 3,
						type = "range",
						name = L["# Displayed Auras"],
						desc = L["Controls how many auras are displayed, this will also affect the size of the auras."],
						min = 1, max = 8, step = 1,
						get = function(info) return E.db.nameplates.units[unit].debuffs[ info[#info] ]; end,
						set = function(info, value) E.db.nameplates.units[unit].debuffs[ info[#info] ] = value; NP:ConfigureAll(); end
					},
					baseHeight = {
						order = 4,
						type = "range",
						name = L["Icon Base Height"],
						desc = L["Base Height for the Aura Icon"],
						min = 6, max = 60, step = 1,
						get = function(info) return E.db.nameplates.units[unit].debuffs[ info[#info] ]; end,
						set = function(info, value) E.db.nameplates.units[unit].debuffs[ info[#info] ] = value; NP:ConfigureAll(); end
					},
					filtersGroup = {
						order = 5,
						type = "group",
						name = L["Filters"],
						guiInline = true,
						args = {
							personal = {
								order = 1,
								type = "toggle",
								name = L["Personal Auras"]
							},
							maxDuration = {
								order = 2,
								type = "range",
								name = L["Maximum Duration"],
								min = 5, max = 3000, step = 1
							},
							filter = {
								order = 3,
								type = "select",
								name = L["Filter"],
								values = function()
									local filters = {}
									filters[""] = NONE
									for filter in pairs(E.global.unitframe["aurafilters"]) do
										filters[filter] = filter
									end
									return filters
								end
							}
						}
					}
				}
			},
			levelGroup = {
				order = 5,
				name = LEVEL,
				type = "group",
				args = {
					header = {
						order = 1,
						type = "header",
						name = LEVEL
					},
					enable = {
						order = 2,
						name = L["Enable"],
						type = "toggle",
						get = function(info) return E.db.nameplates.units[unit].showLevel; end,
						set = function(info, value) E.db.nameplates.units[unit].showLevel = value; NP:ConfigureAll(); end
					}
				}
			},
			nameGroup = {
				order = 6,
				name = L["Name"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].name[ info[#info] ]; end,
				set = function(info, value) E.db.nameplates.units[unit].name[ info[#info] ] = value; NP:ConfigureAll(); end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["Name"]
					},
					enable = {
						order = 2,
						name = L["Enable"],
						type = "toggle",
						get = function(info) return E.db.nameplates.units[unit].showName; end,
						set = function(info, value) E.db.nameplates.units[unit].showName = value; NP:ConfigureAll(); end
					}
				}
			}
		}
	};

	if(unit == "FRIENDLY_PLAYER" or unit == "ENEMY_PLAYER") then
		if unit == "ENEMY_PLAYER" then
			group.args.markHealers = {
				order = 1,
				type = "toggle",
				name = L["Healer Icon"],
				desc = L["Display a healer icon over known healers inside battlegrounds or arenas."],
				set = function(info, value) E.db.nameplates.units.ENEMY_PLAYER[ info[#info] ] = value; NP:PLAYER_ENTERING_WORLD(); NP:ConfigureAll() end,
			}
		end
		group.args.healthGroup.args.useClassColor = {
			order = 4.5,
			type = "toggle",
			name = L["Use Class Color"]
		};
		group.args.nameGroup.args.useClassColor = {
			order = 3,
			type = "toggle",
			name = L["Use Class Color"]
		};
	elseif(unit == "ENEMY_NPC" or unit == "FRIENDLY_NPC") then
		group.args.eliteIcon = {
			order = 7,
			name = L["Elite Icon"],
			type = "group",
			get = function(info) return E.db.nameplates.units[unit].eliteIcon[ info[#info] ]; end,
			set = function(info, value) E.db.nameplates.units[unit].eliteIcon[ info[#info] ] = value; NP:ConfigureAll(); end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Elite Icon"]
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"]
				},
				position = {
					order = 3,
					type = "select",
					name = L["Position"],
					values = {
						["LEFT"] = L["Left"],
						["RIGHT"] = L["Right"],
						["TOP"] = L["Top"],
						["BOTTOM"] = L["Bottom"],
						["CENTER"] = L["Center"]
					}
				},
				size = {
					order = 4,
					type = "range",
					name = L["Size"],
					min = 12, max = 42, step = 1
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
		};
	end

	ORDER = ORDER + 100;
	return group;
end

E.Options.args.nameplate = {
	type = "group",
	name = L["NamePlates"],
	childGroups = "tree",
	get = function(info) return E.db.nameplates[ info[#info] ] end,
	set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:ConfigureAll(); end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.nameplates[ info[#info] ]; end,
			set = function(info, value) E.private.nameplates[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end
		},
		intro = {
			order = 2,
			type = "description",
			name = L["NAMEPLATE_DESC"]
		},
		header = {
			order = 3,
			type = "header",
			name = L["Shortcuts"]
		},
		spacer1 = {
			order = 4,
			type = "description",
			name = " "
		},
		generalShortcut = {
			order = 5,
			type = "execute",
			name = L["General"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "general") end,
			disabled = function() return not E.NamePlates end
		},
		fontsShortcut = {
			order = 6,
			type = "execute",
			name = L["Fonts"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "fontGroup") end,
			disabled = function() return not E.NamePlates end
		},
		threatShortcut = {
			order = 7,
			type = "execute",
			name = L["Threat"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "threatGroup") end,
			disabled = function() return not E.NamePlates end
		},
		spacer2 = {
			order = 8,
			type = "description",
			name = " "
		},
		castBarShortcut = {
			order = 9,
			type = "execute",
			name = L["Cast Bar"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "castGroup") end,
			disabled = function() return not E.NamePlates end
		},
		reactionShortcut = {
			order = 10,
			type = "execute",
			name = L["Reaction Colors"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "reactions") end,
			disabled = function() return not E.NamePlates end
		},
		filtersShortcut = {
			order = 11,
			type = "execute",
			name = FILTERS,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "filters") end,
			disabled = function() return not E.NamePlates end
		},
		spacer3 = {
			order = 12,
			type = "description",
			name = " "
		},
		friendlyPlayerShortcut = {
			order = 13,
			type = "execute",
			name = L["Friendly Player Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "friendlyPlayerGroup") end,
			disabled = function() return not E.NamePlates end
		},
		enemyPlayerShortcut = {
			order = 14,
			type = "execute",
			name = L["Enemy Player Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "enemyPlayerGroup") end,
			disabled = function() return not E.NamePlates end
		},
		friendlyNPCShortcut = {
			order = 15,
			type = "execute",
			name = L["Friendly NPC Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "friendlyNPCGroup") end,
			disabled = function() return not E.NamePlates end
		},
		spacer4 = {
			order = 16,
			type = "description",
			name = " "
		},
		enemyNPCShortcut = {
			order = 17,
			type = "execute",
			name = L["Enemy NPC Frames"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "enemyNPCGroup") end,
			disabled = function() return not E.NamePlates end
		},
		generalGroup = {
			order = 20,
			type = "group",
			name = L["General Options"],
			childGroups = "tab",
			disabled = function() return not E.NamePlates end,
			args = {
				general = {
					order = 1,
					type = "group",
					name = L["General"],
					args = {
						header = {
							order = 1,
							type = "header",
							name = L["General"]
						},
						statusbar = {
							order = 2,
							type = "select",
							dialogControl = "LSM30_Statusbar",
							name = L["StatusBar Texture"],
							values = AceGUIWidgetLSMlists.statusbar,
						},
						motionType = {
							order = 3,
							type = "select",
							name = UNIT_NAMEPLATES_TYPES,
							desc = L["Set to either stack nameplates vertically or allow them to overlap."],
							values = {
								["STACKED"] = UNIT_NAMEPLATES_TYPE_2,
								["OVERLAP"] = UNIT_NAMEPLATES_TYPE_1
							}
						},
						useTargetGlow = {
							order = 4,
							type = "toggle",
							name = L["Use Target Glow"],
						},
						useTargetScale = {
							order = 5,
							type = "toggle",
							name = L["Use Target Scale"],
							desc = L["Enable/Disable the scaling of targetted nameplates."],
						},
						targetScale = {
							order = 6,
							type = "range",
							name = L["Target Scale"],
							desc = L["Scale of the nameplate that is targetted."],
							min = 0.3, max = 2, step = 0.01,
							isPercent = true,
							disabled = function() return E.db.nameplates.useTargetScale ~= true end,
						},
						nonTargetTransparency = {
							order = 7,
							type = "range",
							name = L["Non-Target Transparency"],
							desc = L["Set the transparency level of nameplates that are not the target nameplate."],
							min = 0, max = 1, step = 0.01,
							isPercent = true,
						},
						lowHealthThreshold = {
							order = 8,
							type = "range",
							name = L["Low Health Threshold"],
							desc = L["Make the unitframe glow yellow when it is below this percent of health, it will glow red when the health value is half of this value."],
							isPercent = true,
							min = 0, max = 1, step = 0.01,
						},
						showEnemyCombat = {
							order = 9,
							type = "select",
							name = L["Enemy Combat Toggle"],
							desc = L["Control enemy nameplates toggling on or off when in combat."],
							values = {
								["DISABLED"] = L["Disabled"],
								["TOGGLE_ON"] = L["Toggle On While In Combat"],
								["TOGGLE_OFF"] = L["Toggle Off While In Combat"],
							},
							set = function(info, value)
								E.db.nameplates[ info[#info] ] = value;
								NP:PLAYER_REGEN_ENABLED();
							end,
						},
						showFriendlyCombat = {
							order = 10,
							type = "select",
							name = L["Friendly Combat Toggle"],
							desc = L["Control friendly nameplates toggling on or off when in combat."],
							values = {
								["DISABLED"] = L["Disabled"],
								["TOGGLE_ON"] = L["Toggle On While In Combat"],
								["TOGGLE_OFF"] = L["Toggle Off While In Combat"],
							},
							set = function(info, value)
								E.db.nameplates[ info[#info] ] = value;
								NP:PLAYER_REGEN_ENABLED();
							end
						}
					}
				},
				fontGroup = {
					order = 2,
					type = "group",
					name = L["Fonts"],
					args = {
						header = {
							order = 1,
							type = "header",
							name = L["Fonts"]
						},
						font = {
							order = 2,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font
						},
						fontSize = {
							order = 3,
							type = "range",
							name = L["Font Size"],
							min = 4, max = 34, step = 1,
						},
						fontOutline = {
							order = 4,
							type = "select",
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							values = {
								["NONE"] = L["None"],
								["OUTLINE"] = "OUTLINE",
								["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
								["THICKOUTLINE"] = "THICKOUTLINE"
							}
						}
					}
				},
				threatGroup = {
					order = 3,
					type = "group",
					name = L["Threat"],
					get = function(info)
						local t = E.db.nameplates.threat[ info[#info] ];
						local d = P.nameplates.threat[info[#info]];
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
					end,
					set = function(info, r, g, b)
						local t = E.db.nameplates.threat[ info[#info] ];
						t.r, t.g, t.b = r, g, b;
					end,
					args = {
						header = {
							order = 1,
							type = "header",
							name = L["Threat"]
						},
						useThreatColor = {
							order = 2,
							type = "toggle",
							name = L["Use Threat Color"],
							get = function(info) return E.db.nameplates.threat.useThreatColor; end,
							set = function(info, value) E.db.nameplates.threat.useThreatColor = value; end
						},
						goodColor = {
							order = 3,
							type = "color",
							name = L["Good Color"],
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor; end
						},
						badColor = {
							order = 4,
							type = "color",
							name = L["Bad Color"],
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor; end
						},
						goodTransition = {
							order = 5,
							type = "color",
							name = L["Good Transition Color"],
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor; end
						},
						badTransition = {
							order = 6,
							type = "color",
							name = L["Bad Transition Color"],
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor; end
						},
						beingTankedByTank = {
							order = 7,
							type = "toggle",
							name = L["Color Tanked"],
							desc = L["Use Tanked Color when a nameplate is being effectively tanked by another tank."],
							get = function(info) return E.db.nameplates.threat[ info[#info] ]; end,
							set = function(info, value) E.db.nameplates.threat[ info[#info] ] = value; end,
							disabled = function() return not E.db.nameplates.threat.useThreatColor; end
						},
						beingTankedByTankColor = {
							order = 8,
							type = "color",
							name = L["Tanked Color"],
							hasAlpha = false,
							disabled = function() return (not E.db.nameplates.threat.beingTankedByTank or not E.db.nameplates.threat.useThreatColor); end
						},
						goodScale = {
							order = 9,
							type = "range",
							name = L["Good Scale"],
							get = function(info) return E.db.nameplates.threat[ info[#info] ]; end,
							set = function(info, value) E.db.nameplates.threat[ info[#info] ] = value; end,
							min = 0.3, max = 2, step = 0.01,
							isPercent = true
						},
						badScale = {
							order = 10,
							type = "range",
							name = L["Bad Scale"],
							get = function(info) return E.db.nameplates.threat[ info[#info] ]; end,
							set = function(info, value) E.db.nameplates.threat[ info[#info] ] = value; end,
							min = 0.3, max = 2, step = 0.01,
							isPercent = true
						}
					}
				},
				castGroup = {
					order = 4,
					type = "group",
					name = L["Cast Bar"],
					get = function(info)
						local t = E.db.nameplates[ info[#info] ];
						local d = P.nameplates[info[#info]];
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
					end,
					set = function(info, r, g, b)
						local t = E.db.nameplates[ info[#info] ];
						t.r, t.g, t.b = r, g, b;
						NP:ForEachPlate("ConfigureElement_CastBar");
					end,
					args = {
						header = {
							order = 1,
							type = "header",
							name = L["Cast Bar"]
						},
						castColor = {
							order = 2,
							type = "color",
							name = L["Cast Color"],
							hasAlpha = false
						},
						castNoInterruptColor = {
							order = 3,
							type = "color",
							name = L["Cast No Interrupt Color"],
							hasAlpha = false
						}
					}
				},
				reactions = {
					order = 5,
					type = "group",
					name = L["Reaction Colors"],
					get = function(info)
						local t = E.db.nameplates.reactions[ info[#info] ];
						local d = P.nameplates.reactions[info[#info]];
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
					end,
					set = function(info, r, g, b)
						local t = E.db.nameplates.reactions[ info[#info] ];
						t.r, t.g, t.b = r, g, b;
						NP:ConfigureAll();
					end,
					args = {
						header = {
							order = 1,
							type = "header",
							name = L["Reaction Colors"]
						},
						friendlyPlayer = {
							order = 2,
							type = "color",
							name = L["Friendly Player"],
							hasAlpha = false
						},
						good = {
							order = 3,
							type = "color",
							name = L["Friendly NPC"],
							hasAlpha = false
						},
						neutral = {
							order = 4,
							type = "color",
							name = L["Neutral"],
							hasAlpha = false
						},
						bad = {
							order = 5,
							type = "color",
							name = L["Enemy"],
							hasAlpha = false
						},
						tapped = {
							order = 6,
							type = "color",
							name = L["Tagged NPC"],
							hasAlpha = false
						}
					}
				},
				filters = {
					order = 6,
					type = "group",
					name = L["Filters"],
					args = {
						header = {
							order = 1,
							type = "header",
							name = L["Filters"]
						},
						addname = {
							order = 2,
							type = "input",
							name = L["Add Name"],
							get = function(info) return "" end,
							set = function(info, value)
								if E.global["nameplates"]["filter"][value] then
									E:Print(L["Filter already exists!"])
									return
								end

								E.global["nameplates"]["filter"][value] = {
									["enable"] = true,
									["hide"] = false,
									["customColor"] = false,
									["customScale"] = 1,
									["color"] = {r = 104/255, g = 138/255, b = 217/255}
								}
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						deletename = {
							order = 3,
							type = "input",
							name = L["Remove Name"],
							get = function(info) return "" end,
							set = function(info, value)
								if G["nameplates"]["filter"][value] then
									E.global["nameplates"]["filter"][value].enable = false;
									E:Print(L["You can't remove a default name from the filter, disabling the name."])
								else
									E.global["nameplates"]["filter"][value] = nil;
									E.Options.args.nameplate.args.generalGroup.args.filters.args.filterGroup = nil;
								end
								UpdateFilterGroup()
								NP:ConfigureAll();
							end
						},
						selectFilter = {
							order = 4,
							type = "select",
							name = L["Select Filter"],
							get = function(info) return selectedFilter end,
							set = function(info, value) selectedFilter = value; UpdateFilterGroup() end,
							values = function()
								filters = {}
								for filter in pairs(E.global["nameplates"]["filter"]) do
									filters[filter] = filter
								end
								return filters
							end
						}
					}
				}
			}
		},
		friendlyPlayerGroup = GetUnitSettings("FRIENDLY_PLAYER", L["Friendly Player Frames"]),
		enemyPlayerGroup = GetUnitSettings("ENEMY_PLAYER", L["Enemy Player Frames"]),
		friendlyNPCGroup = GetUnitSettings("FRIENDLY_NPC", L["Friendly NPC Frames"]),
		enemyNPCGroup = GetUnitSettings("ENEMY_NPC", L["Enemy NPC Frames"])
	}
};