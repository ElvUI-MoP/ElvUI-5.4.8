local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(select(2, ...))
local A = E:GetModule("Auras")
local M = E:GetModule("Minimap")

local format = string.format

local function GetAuraOptions()
	local auraOptions = {
		size = {
			order = 1,
			type = "range",
			name = L["Size"],
			desc = L["Set the size of the individual auras."],
			min = 16, max = 60, step = 2
		},
		durationFontSize = {
			order = 2,
			type = "range",
			name = L["Duration Font Size"],
			min = 4, max = 32, step = 1,
		},
		countFontSize = {
			order = 3,
			type = "range",
			name = L["Count Font Size"],
			min = 4, max = 32, step = 1,
		},
		growthDirection = {
			order = 4,
			type = "select",
			name = L["Growth Direction"],
			desc = L["The direction the auras will grow and then the direction they will grow after they reach the wrap after limit."],
			values = {
				DOWN_RIGHT = format(L["%s and then %s"], L["Down"], L["Right"]),
				DOWN_LEFT = format(L["%s and then %s"], L["Down"], L["Left"]),
				UP_RIGHT = format(L["%s and then %s"], L["Up"], L["Right"]),
				UP_LEFT = format(L["%s and then %s"], L["Up"], L["Left"]),
				RIGHT_DOWN = format(L["%s and then %s"], L["Right"], L["Down"]),
				RIGHT_UP = format(L["%s and then %s"], L["Right"], L["Up"]),
				LEFT_DOWN = format(L["%s and then %s"], L["Left"], L["Down"]),
				LEFT_UP = format(L["%s and then %s"], L["Left"], L["Up"])
			}
		},
		wrapAfter = {
			order = 5,
			type = "range",
			name = L["Wrap After"],
			desc = L["Begin a new row or column after this many auras."],
			min = 1, max = 32, step = 1
		},
		maxWraps = {
			order = 6,
			type = "range",
			name = L["Max Wraps"],
			desc = L["Limit the number of rows or columns."],
			min = 1, max = 32, step = 1
		},
		horizontalSpacing = {
			order = 7,
			type = "range",
			name = L["Horizontal Spacing"],
			min = -1, max = 50, step = 1
		},
		verticalSpacing = {
			order = 8,
			type = "range",
			name = L["Vertical Spacing"],
			min = -1, max = 50, step = 1
		},
		sortMethod = {
			order = 9,
			type = "select",
			name = L["Sort Method"],
			desc = L["Defines how the group is sorted."],
			values = {
				["INDEX"] = L["Index"],
				["TIME"] = L["Time"],
				["NAME"] = L["NAME"]
			}
		},
		sortDir = {
			order = 10,
			type = "select",
			name = L["Sort Direction"],
			desc = L["Defines the sort order of the selected sort method."],
			values = {
				["+"] = L["Ascending"],
				["-"] = L["Descending"]
			}
		},
		seperateOwn = {
			order = 11,
			type = "select",
			name = L["Seperate"],
			desc = L["Indicate whether buffs you cast yourself should be separated before or after."],
			values = {
				[-1] = L["Other's First"],
				[0] = L["No Sorting"],
				[1] = L["Your Auras First"]
			}
		}
	}

	return auraOptions
end

E.Options.args.auras = {
	order = 2,
	type = "group",
	name = L["BUFFOPTIONS_LABEL"],
	childGroups = "tab",
	get = function(info) return E.private.auras[info[#info]] end,
	set = function(info, value)
		E.private.auras[info[#info]] = value
		E:StaticPopup_Show("PRIVATE_RL")
	end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["AURAS_DESC"]
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["ENABLE"]
		},
		disableBlizzard = {
			order = 3,
			type = "toggle",
			name = L["Disabled Blizzard"]
		},
		buffsHeader = {
			order = 4,
			type = "toggle",
			name = L["Buffs"]
		},
		debuffsHeader = {
			order = 5,
			type = "toggle",
			name = L["Debuffs"]
		},
		general = {
			order = 4,
			type = "group",
			name = L["General"],
			get = function(info) return E.db.auras[info[#info]] end,
			set = function(info, value) E.db.auras[info[#info]] = value A:UpdateHeader(A.BuffFrame) A:UpdateHeader(A.DebuffFrame) end,
			args = {
				fadeThreshold = {
					order = 1,
					type = "range",
					name = L["Fade Threshold"],
					desc = L["Threshold before the icon will fade out and back in. Set to -1 to disable."],
					min = -1, max = 30, step = 1
				},
				showDuration = {
					order = 2,
					type = "toggle",
					name = L["Duration Enable"],
				},
				font = {
					order = 3,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font
				},
				fontOutline = {
					order = 4,
					type = "select",
					name = L["Font Outline"],
					desc = L["Set the font outline."],
					values = C.Values.FontFlags
				},
				timeXOffset = {
					order = 5,
					type = "range",
					name = L["Time xOffset"],
					min = -60, max = 60, step = 1
				},
				timeYOffset = {
					order = 6,
					type = "range",
					name = L["Time yOffset"],
					min = -60, max = 60, step = 1
				},
				countXOffset = {
					order = 7,
					type = "range",
					name = L["Count xOffset"],
					min = -60, max = 60, step = 1
				},
				countYOffset = {
					order = 8,
					type = "range",
					name = L["Count yOffset"],
					min = -60, max = 60, step = 1
				},
				statusBar = {
					order = 9,
					type = "group",
					name = L["Statusbar"],
					guiInline = true,
					args = {
						barShow = {
							order = 1,
							type = "toggle",
							name = L["ENABLE"]
						},
						spacer = {
							order = 2,
							type = "description",
							name = ""
						},
						barTexture = {
							order = 3,
							type = "select",
							dialogControl = "LSM30_Statusbar",
							name = L["Texture"],
							values = AceGUIWidgetLSMlists.statusbar,
							disabled = function() return not E.db.auras.barShow end
						},
						barWidth = {
							order = 4,
							type = "range",
							name = L["Width"],
							min = 1, max = 10, step = 1,
							disabled = function() return not E.db.auras.barShow end
						},
						barHeight = {
							order = 5,
							type = "range",
							name = L["Height"],
							min = 1, max = 10, step = 1,
							disabled = function() return not E.db.auras.barShow end
						},
						barSpacing = {
							order = 6,
							type = "range",
							name = L["Spacing"],
							min = -10, max = 10, step = 1,
							disabled = function() return not E.db.auras.barShow end
						},
						barPosition = {
							order = 7,
							type = "select",
							name = L["Position"],
							values = {
								["TOP"] = L["Top"],
								["BOTTOM"] = L["Bottom"],
								["LEFT"] = L["Left"],
								["RIGHT"] = L["Right"]
							},
							disabled = function() return not E.db.auras.barShow end
						},
						barNoDuration = {
							order = 8,
							type = "toggle",
							name = L["No Duration"]
						},
						barColorGradient = {
							order = 9,
							type = "toggle",
							name = L["Color by Value"],
							disabled = function() return not E.db.auras.barShow end
						},
						barColor = {
							order = 10,
							type = "color",
							name = L["COLOR"],
							hasAlpha = false,
							get = function(info)
								local t = E.db.auras.barColor
								local d = P.auras.barColor
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b)
								local t = E.db.auras.barColor
								t.r, t.g, t.b = r, g, b
								A:UpdateHeader(ElvUIPlayerBuffs)
								A:UpdateHeader(ElvUIPlayerDebuffs)
							end,
							disabled = function() return not E.db.auras.barShow or (E.db.auras.barColorGradient or not E.db.auras.barShow) end
						}
					}
				},
				masque = {
					order = 11,
					type = "group",
					guiInline = true,
					name = L["Masque Support"],
					get = function(info) return E.private.auras.masque[info[#info]] end,
					set = function(info, value) E.private.auras.masque[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end,
					disabled = function() return not E.private.auras.enable end,
					args = {
						buffs = {
							order = 1,
							type = "toggle",
							name = L["Buffs"],
							desc = L["Allow Masque to handle the skinning of this element."]
						},
						debuffs = {
							order = 2,
							type = "toggle",
							name = L["Debuffs"],
							desc = L["Allow Masque to handle the skinning of this element."]
						},
						consolidatedBuffs = {
							order = 3,
							type = "toggle",
							name = L["Consolidated Buffs"],
							desc = L["Allow Masque to handle the skinning of this element."]
						}
					}
				}
			}
		},
		buffs = {
			order = 5,
			type = "group",
			name = L["Buffs"],
			get = function(info) return E.db.auras.buffs[info[#info]] end,
			set = function(info, value) E.db.auras.buffs[info[#info]] = value A:UpdateHeader(A.BuffFrame) end,
			disabled = function() return not E.private.auras.buffsHeader end,
			args = GetAuraOptions()
		},
		debuffs = {
			order = 6,
			type = "group",
			name = L["Debuffs"],
			get = function(info) return E.db.auras.debuffs[info[#info]] end,
			set = function(info, value) E.db.auras.debuffs[info[#info]] = value A:UpdateHeader(A.DebuffFrame) end,
			disabled = function() return not E.private.auras.debuffsHeader end,
			args = GetAuraOptions()
		},
		consolidatedBuffs = {
			order = 7,
			type = "group",
			name = L["Consolidated Buffs"],
			disabled = function() return (E.private.general.minimap.enable ~= true or E.private.auras.disableBlizzard ~= true) end,
			get = function(info) return E.db.auras.consolidatedBuffs[info[#info]] end,
			set = function(info, value) E.db.auras.consolidatedBuffs[info[#info]] = value M:UpdateSettings() end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"],
					set = function(info, value)
						E.db.auras.consolidatedBuffs[info[#info]] = value
						M:UpdateSettings()
						A:UpdateHeader(ElvUIPlayerBuffs)
					end,
					desc = L["Display the consolidated buffs bar."]
				},
				filter = {
					order = 2,
					type = "toggle",
					name = L["Filter Consolidated"],
					desc = L["Only show consolidated icons on the consolidated bar that your class/spec is interested in. This is useful for raid leading."]
				},
				durations = {
					order = 3,
					type = "toggle",
					name = L["Remaining Time"]
				},
				reverseStyle = {
					order = 4,
					type = "toggle",
					name = L["Reverse Style"],
					desc = L["When enabled active buff icons will light up instead of becoming darker, while inactive buff icons will become darker instead of being lit up."]
				},
				position = {
					order = 5,
					type = "select",
					name = L["Position"],
					set = function(info, value) E.db.auras.consolidatedBuffs[ info[#info] ] = value A:UpdatePosition() end,
					values = {
						["LEFT"] = L["Left"],
						["RIGHT"] = L["Right"]
					}
				},
				font = {
					order = 6,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font
				},
				fontSize = {
					order = 7,
					type = "range",
					name = L["FONT_SIZE"],
					min = 4, max = 22, step = 1
				},
				fontOutline = {
					order = 8,
					type = "select",
					name = L["Font Outline"],
					desc = L["Set the font outline."],
					values = C.Values.FontFlags
				}
			}
		}
	}
}