local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(select(2, ...))
local A = E:GetModule("Auras")
local M = E:GetModule("Minimap")

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
		cooldownShortcut = {
			order = 6,
			type = "execute",
			name = L["Cooldown Text"],
			func = function() E.Libs.AceConfigDialog:SelectGroup("ElvUI", "cooldown", "auras") end
		},
		buffs = {
			order = 7,
			type = "group",
			name = L["Buffs"],
			get = function(info) return E.db.auras.buffs[info[#info]] end,
			set = function(info, value) E.db.auras.buffs[info[#info]] = value A:UpdateHeader(A.BuffFrame) end,
			disabled = function() return not E.private.auras.enable or not E.private.auras.buffsHeader end,
			args = {
				growthDirection = {
					order = 1,
					type = "select",
					name = L["Growth Direction"],
					desc = L["The direction the auras will grow and then the direction they will grow after they reach the wrap after limit."],
					values = C.Values.GrowthDirection
				},
				sortMethod = {
					order = 2,
					type = "select",
					name = L["Sort Method"],
					desc = L["Defines how the group is sorted."],
					values = {
						INDEX = L["Index"],
						TIME = L["Time"],
						NAME = L["NAME"]
					}
				},
				sortDir = {
					order = 3,
					type = "select",
					name = L["Sort Direction"],
					desc = L["Defines the sort order of the selected sort method."],
					values = {
						["+"] = L["Ascending"],
						["-"] = L["Descending"]
					}
				},
				seperateOwn = {
					order = 4,
					type = "select",
					name = L["Seperate"],
					desc = L["Indicate whether buffs you cast yourself should be separated before or after."],
					values = {
						[-1] = L["Other's First"],
						[0] = L["No Sorting"],
						[1] = L["Your Auras First"]
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
				fadeThreshold = {
					order = 9,
					type = "range",
					name = L["Fade Threshold"],
					desc = L["Threshold before the icon will fade out and back in. Set to -1 to disable."],
					min = -1, max = 30, step = 1
				},
				size = {
					order = 10,
					type = "range",
					name = L["Size"],
					desc = L["Set the size of the individual auras."],
					min = 16, max = 60, step = 2
				},
				showDuration = {
					order = 11,
					type = "toggle",
					name = L["Duration Enable"]
				},
				masque = {
					order = 12,
					type = "toggle",
					name = L["Masque Support"],
					desc = L["Allow Masque to handle the skinning of this element."],
					get = function() return E.private.auras.masque.buffs end,
					set = function(_, value) E.private.auras.masque.buffs = value E:StaticPopup_Show("PRIVATE_RL") end,
					disabled = function() return not E.private.auras.enable or not E.private.auras.buffsHeader or not E.Masque end
				},
				timeGroup = {
					order = 13,
					type = "group",
					name = L["Time"],
					guiInline = true,
					args = {
						timeFont = {
							order = 1,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font
						},
						timeFontSize = {
							order = 2,
							type = "range",
							name = L["Font Size"],
							min = 4, max = 32, step = 1
						},
						timeFontOutline = {
							order = 3,
							type = "select",
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							values = C.Values.FontFlags
						},
						spacer = {
							order = 4,
							type = "description",
							name = ""
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
						}
					}
				},
				countGroup = {
					order = 14,
					type = "group",
					name = L["Count"],
					guiInline = true,
					args = {
						countFont = {
							order = 1,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font
						},
						countFontSize = {
							order = 2,
							type = "range",
							name = L["Font Size"],
							min = 4, max = 32, step = 1
						},
						countFontOutline = {
							order = 3,
							type = "select",
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							values = C.Values.FontFlags
						},
						spacer = {
							order = 4,
							type = "description",
							name = ""
						},
						countXOffset = {
							order = 5,
							type = "range",
							name = L["Time xOffset"],
							min = -60, max = 60, step = 1
						},
						countYOffset = {
							order = 6,
							type = "range",
							name = L["Time yOffset"],
							min = -60, max = 60, step = 1
						}
					}
				},
				statusBar = {
					order = 15,
					type = "group",
					name = L["Status Bar"],
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
							disabled = function() return not E.db.auras.buffs.barShow end
						},
						barSize = {
							order = 4,
							type = "range",
							name = L["Size"],
							min = 1, max = 10, step = 1,
							disabled = function() return not E.db.auras.buffs.barShow end
						},
						barSpacing = {
							order = 5,
							type = "range",
							name = L["Spacing"],
							min = -10, max = 10, step = 1,
							disabled = function() return not E.db.auras.buffs.barShow end
						},
						barPosition = {
							order = 6,
							type = "select",
							name = L["Position"],
							values = {
								TOP = L["Top"],
								BOTTOM = L["Bottom"],
								LEFT = L["Left"],
								RIGHT = L["Right"]
							},
							disabled = function() return not E.db.auras.buffs.barShow end
						},
						barNoDuration = {
							order = 7,
							type = "toggle",
							name = L["No Duration"],
							disabled = function() return not E.db.auras.buffs.barShow end
						},
						barColorGradient = {
							order = 8,
							type = "toggle",
							name = L["Color by Value"],
							disabled = function() return not E.db.auras.buffs.barShow end
						},
						barColor = {
							order = 9,
							type = "color",
							name = L["COLOR"],
							hasAlpha = false,
							get = function()
								local t = E.db.auras.buffs.barColor
								local d = P.auras.buffs.barColor
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(_, r, g, b)
								local t = E.db.auras.buffs.barColor
								t.r, t.g, t.b = r, g, b
								A:UpdateHeader(A.BuffFrame)
							end,
							disabled = function() return not E.db.auras.buffs.barShow or E.db.auras.buffs.barColorGradient end
						}
					}
				}
			}
		},
		debuffs = {
			order = 8,
			type = "group",
			name = L["Debuffs"],
			get = function(info) return E.db.auras.debuffs[info[#info]] end,
			set = function(info, value) E.db.auras.debuffs[info[#info]] = value A:UpdateHeader(A.DebuffFrame) end,
			disabled = function() return not E.private.auras.enable or not E.private.auras.debuffsHeader end,
			args = {
				growthDirection = {
					order = 1,
					type = "select",
					name = L["Growth Direction"],
					desc = L["The direction the auras will grow and then the direction they will grow after they reach the wrap after limit."],
					values = C.Values.GrowthDirection
				},
				sortMethod = {
					order = 2,
					type = "select",
					name = L["Sort Method"],
					desc = L["Defines how the group is sorted."],
					values = {
						INDEX = L["Index"],
						TIME = L["Time"],
						NAME = L["NAME"]
					}
				},
				sortDir = {
					order = 3,
					type = "select",
					name = L["Sort Direction"],
					desc = L["Defines the sort order of the selected sort method."],
					values = {
						["+"] = L["Ascending"],
						["-"] = L["Descending"]
					}
				},
				seperateOwn = {
					order = 4,
					type = "select",
					name = L["Seperate"],
					desc = L["Indicate whether buffs you cast yourself should be separated before or after."],
					values = {
						[-1] = L["Other's First"],
						[0] = L["No Sorting"],
						[1] = L["Your Auras First"]
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
				fadeThreshold = {
					order = 9,
					type = "range",
					name = L["Fade Threshold"],
					desc = L["Threshold before the icon will fade out and back in. Set to -1 to disable."],
					min = -1, max = 30, step = 1
				},
				size = {
					order = 10,
					type = "range",
					name = L["Size"],
					desc = L["Set the size of the individual auras."],
					min = 16, max = 60, step = 2
				},
				showDuration = {
					order = 11,
					type = "toggle",
					name = L["Duration Enable"]
				},
				masque = {
					order = 12,
					type = "toggle",
					name = L["Masque Support"],
					desc = L["Allow Masque to handle the skinning of this element."],
					get = function() return E.private.auras.masque.debuffs end,
					set = function(_, value) E.private.auras.masque.debuffs = value E:StaticPopup_Show("PRIVATE_RL") end,
					disabled = function() return not E.private.auras.enable or not E.private.auras.debuffsHeader or not E.Masque end
				},
				timeGroup = {
					order = 13,
					type = "group",
					name = L["Time"],
					guiInline = true,
					args = {
						timeFont = {
							order = 1,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font
						},
						timeFontSize = {
							order = 2,
							type = "range",
							name = L["Font Size"],
							min = 4, max = 32, step = 1
						},
						timeFontOutline = {
							order = 3,
							type = "select",
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							values = C.Values.FontFlags
						},
						spacer = {
							order = 4,
							type = "description",
							name = ""
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
						}
					}
				},
				countGroup = {
					order = 14,
					type = "group",
					name = L["Count"],
					guiInline = true,
					args = {
						countFont = {
							order = 1,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font
						},
						countFontSize = {
							order = 2,
							type = "range",
							name = L["Font Size"],
							min = 4, max = 32, step = 1
						},
						countFontOutline = {
							order = 3,
							type = "select",
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							values = C.Values.FontFlags
						},
						spacer = {
							order = 4,
							type = "description",
							name = ""
						},
						countXOffset = {
							order = 5,
							type = "range",
							name = L["Time xOffset"],
							min = -60, max = 60, step = 1
						},
						countYOffset = {
							order = 6,
							type = "range",
							name = L["Time yOffset"],
							min = -60, max = 60, step = 1
						}
					}
				},
				statusBar = {
					order = 15,
					type = "group",
					name = L["Status Bar"],
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
							disabled = function() return not E.db.auras.debuffs.barShow end
						},
						barSize = {
							order = 4,
							type = "range",
							name = L["Size"],
							min = 1, max = 10, step = 1,
							disabled = function() return not E.db.auras.debuffs.barShow end
						},
						barSpacing = {
							order = 5,
							type = "range",
							name = L["Spacing"],
							min = -10, max = 10, step = 1,
							disabled = function() return not E.db.auras.debuffs.barShow end
						},
						barPosition = {
							order = 6,
							type = "select",
							name = L["Position"],
							values = {
								TOP = L["Top"],
								BOTTOM = L["Bottom"],
								LEFT = L["Left"],
								RIGHT = L["Right"]
							},
							disabled = function() return not E.db.auras.debuffs.barShow end
						},
						barNoDuration = {
							order = 7,
							type = "toggle",
							name = L["No Duration"],
							disabled = function() return not E.db.auras.debuffs.barShow end
						},
						barColorGradient = {
							order = 8,
							type = "toggle",
							name = L["Color by Value"],
							disabled = function() return not E.db.auras.debuffs.barShow end
						},
						barColor = {
							order = 9,
							type = "color",
							name = L["COLOR"],
							hasAlpha = false,
							get = function()
								local t = E.db.auras.debuffs.barColor
								local d = P.auras.debuffs.barColor
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(_, r, g, b)
								local t = E.db.auras.debuffs.barColor
								t.r, t.g, t.b = r, g, b
								A:UpdateHeader(A.DebuffFrame)
							end,
							disabled = function() return not E.db.auras.debuffs.barShow or E.db.auras.debuffs.barColorGradient end
						}
					}
				}
			}
		},
		consolidatedBuffs = {
			order = 9,
			type = "group",
			name = L["Consolidated Buffs"],
			get = function(info) return E.db.auras.consolidatedBuffs[info[#info]] end,
			set = function(info, value) E.db.auras.consolidatedBuffs[info[#info]] = value M:UpdateSettings() end,
			disabled = function() return not E.private.auras.disableBlizzard end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"],
					desc = L["Display the consolidated buffs bar."],
					set = function(info, value)
						E.db.auras.consolidatedBuffs[info[#info]] = value
						M:UpdateSettings()
						A:UpdateHeader(A.BuffFrame)
					end
				},
				spacer = {
					order = 2,
					type = "description",
					name = ""
				},
				filter = {
					order = 3,
					type = "toggle",
					name = L["Filter Consolidated"],
					desc = L["Only show consolidated icons on the consolidated bar that your class/spec is interested in. This is useful for raid leading."],
					disabled = function() return not E.db.auras.consolidatedBuffs.enable end
				},
				durations = {
					order = 4,
					type = "toggle",
					name = L["Remaining Time"],
					disabled = function() return not E.db.auras.consolidatedBuffs.enable end
				},
				reverseStyle = {
					order = 5,
					type = "toggle",
					name = L["Reverse Style"],
					desc = L["When enabled active buff icons will light up instead of becoming darker, while inactive buff icons will become darker instead of being lit up."],
					disabled = function() return not E.db.auras.consolidatedBuffs.enable end
				},
				masque = {
					order = 6,
					type = "toggle",
					name = L["Masque Support"],
					desc = L["Allow Masque to handle the skinning of this element."],
					get = function() return E.private.auras.masque.consolidatedBuffs end,
					set = function(_, value) E.private.auras.masque.consolidatedBuffs = value E:StaticPopup_Show("PRIVATE_RL") end,
					disabled = function() return not E.Masque or not E.db.auras.consolidatedBuffs.enable end
				},
				position = {
					order = 7,
					type = "select",
					name = L["Position"],
					set = function(info, value) E.db.auras.consolidatedBuffs[info[#info]] = value A:UpdatePosition() end,
					values = {
						LEFT = L["Left"],
						RIGHT = L["Right"]
					},
					disabled = function() return not E.db.auras.consolidatedBuffs.enable end
				},
				font = {
					order = 8,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
					disabled = function() return not E.db.auras.consolidatedBuffs.enable end
				},
				fontSize = {
					order = 9,
					type = "range",
					name = L["FONT_SIZE"],
					min = 4, max = 22, step = 1,
					disabled = function() return not E.db.auras.consolidatedBuffs.enable end
				},
				fontOutline = {
					order = 10,
					type = "select",
					name = L["Font Outline"],
					desc = L["Set the font outline."],
					values = C.Values.FontFlags,
					disabled = function() return not E.db.auras.consolidatedBuffs.enable end
				}
			}
		}
	}
}