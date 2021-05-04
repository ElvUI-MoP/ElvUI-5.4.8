local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(select(2, ...))
local WM = E:GetModule("WorldMap")
local MM = E:GetModule("Minimap")

local positionValues = {
	TOP = L["Top"],
	LEFT = L["Left"],
	RIGHT = L["Right"],
	BOTTOM = L["Bottom"],
	TOPLEFT = L["Top Left"],
	TOPRIGHT = L["Top Right"],
	BOTTOMLEFT = L["Bottom Left"],
	BOTTOMRIGHT = L["Bottom Right"]
}

E.Options.args.maps = {
	order = 2,
	type = "group",
	name = L["Maps"],
	childGroups = "tab",
	args = {
		worldMap = {
			order = 1,
			type = "group",
			name = L["WORLD_MAP"],
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"],
					get = function(info) return E.private.worldmap[info[#info]] end,
					set = function(info, value) E.private.worldmap[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end
				},
				generalGroup = {
					order = 2,
					type = "group",
					name = L["General"],
					guiInline = true,
					args = {
						smallerWorldMap = {
							order = 1,
							type = "toggle",
							name = L["Smaller World Map"],
							desc = L["Make the world map smaller."],
							get = function(info) return E.global.general.smallerWorldMap end,
							set = function(info, value) E.global.general.smallerWorldMap = value E:StaticPopup_Show("GLOBAL_RL") end,
							disabled = function() return not WM.Initialized end
						},
						fadeMapWhenMoving = {
							order = 2,
							type = "toggle",
							name = L["MAP_FADE_TEXT"],
							get = function(info) return E.global.general.fadeMapWhenMoving end,
							set = function(info, value) E.global.general.fadeMapWhenMoving = value WM:UpdateMapAlpha() end
						},
						mapAlphaWhenMoving = {
							order = 3,
							type = "range",
							name = L["Map Opacity When Moving"],
							isPercent = true,
							min = 0, max = 1, step = 0.01,
							get = function(info) return E.global.general.mapAlphaWhenMoving end,
							set = function(info, value) E.global.general.mapAlphaWhenMoving = value WM:UpdateMapAlpha() end,
							disabled = function() return not E.global.general.fadeMapWhenMoving end
						}
					}
				},
				spacer = {
					order = 3,
					type = "description",
					name = "\n"
				},
				coordinatesGroup = {
					order = 4,
					type = "group",
					name = L["World Map Coordinates"],
					guiInline = true,
					disabled = function() return not WM.Initialized end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["ENABLE"],
							desc = L["Puts coordinates on the world map."],
							get = function(info) return E.global.general.WorldMapCoordinates.enable end,
							set = function(info, value) E.global.general.WorldMapCoordinates.enable = value E:StaticPopup_Show("GLOBAL_RL") end
						},
						spacer = {
							order = 2,
							type = "description",
							name = " "
						},
						position = {
							order = 3,
							type = "select",
							name = L["Position"],
							get = function(info) return E.global.general.WorldMapCoordinates.position end,
							set = function(info, value) E.global.general.WorldMapCoordinates.position = value WM:PositionCoords() end,
							disabled = function() return not E.global.general.WorldMapCoordinates.enable end,
							values = {
								TOP = L["Top"],
								BOTTOM = L["Bottom"],
								TOPLEFT = L["Top Left"],
								TOPRIGHT = L["Top Right"],
								BOTTOMLEFT = L["Bottom Left"],
								BOTTOMRIGHT = L["Bottom Right"]
							}
						},
						xOffset = {
							order = 4,
							type = "range",
							name = L["X-Offset"],
							get = function(info) return E.global.general.WorldMapCoordinates.xOffset end,
							set = function(info, value) E.global.general.WorldMapCoordinates.xOffset = value WM:PositionCoords() end,
							disabled = function() return not E.global.general.WorldMapCoordinates.enable end,
							min = -200, max = 200, step = 1
						},
						yOffset = {
							order = 5,
							type = "range",
							name = L["Y-Offset"],
							get = function(info) return E.global.general.WorldMapCoordinates.yOffset end,
							set = function(info, value) E.global.general.WorldMapCoordinates.yOffset = value WM:PositionCoords() end,
							disabled = function() return not E.global.general.WorldMapCoordinates.enable end,
							min = -200, max = 200, step = 1
						}
					}
				}
			}
		},
		minimap = {
			order = 2,
			type = "group",
			name = L["MINIMAP_LABEL"],
			get = function(info) return E.db.general.minimap[info[#info]] end,
			childGroups = "tab",
			args = {
				generalGroup = {
					order = 2,
					type = "group",
					name = L["General"],
					guiInline = true,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["ENABLE"],
							desc = L["Enable/Disable the minimap. |cffFF0000Warning: This will prevent you from seeing the consolidated buffs bar, and prevent you from seeing the minimap datatexts.|r"],
							get = function(info) return E.private.general.minimap[info[#info]] end,
							set = function(info, value) E.private.general.minimap[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end
						},
						size = {
							order = 2,
							type = "range",
							name = L["Size"],
							desc = L["Adjust the size of the minimap."],
							min = 120, max = 500, step = 1,
							get = function(info) return E.db.general.minimap[info[#info]] end,
							set = function(info, value) E.db.general.minimap[info[#info]] = value MM:UpdateSettings() end,
							disabled = function() return not E.private.general.minimap.enable end
						}
					}
				},
				locationTextGroup = {
					order = 3,
					type = "group",
					name = L["Location Text"],
					args = {
						locationText = {
							order = 2,
							type = "select",
							name = L["Location Text"],
							desc = L["Change settings for the display of the location text that is on the minimap."],
							get = function(info) return E.db.general.minimap.locationText end,
							set = function(info, value) E.db.general.minimap.locationText = value MM:UpdateSettings() MM:Update_ZoneText() end,
							values = {
								MOUSEOVER = L["Minimap Mouseover"],
								SHOW = L["Always Display"],
								HIDE = L["HIDE"]
							},
							disabled = function() return not E.private.general.minimap.enable end
						},
						spacer = {
							order = 3,
							type = "description",
							name = "\n"
						},
						locationFont = {
							order = 4,
							type = "select",
							dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
							set = function(info, value) E.db.general.minimap.locationFont = value MM:Update_ZoneText() end,
							disabled = function() return not E.private.general.minimap.enable end
						},
						locationFontSize = {
							order = 5,
							type = "range",
							name = L["FONT_SIZE"],
							min = 6, max = 36, step = 1,
							set = function(info, value) E.db.general.minimap.locationFontSize = value MM:Update_ZoneText() end,
							disabled = function() return not E.private.general.minimap.enable end
						},
						locationFontOutline = {
							order = 6,
							type = "select",
							name = L["Font Outline"],
							set = function(info, value) E.db.general.minimap.locationFontOutline = value MM:Update_ZoneText() end,
							disabled = function() return not E.private.general.minimap.enable end,
							values = C.Values.FontFlags
						}
					}
				},
				zoomResetGroup = {
					order = 4,
					type = "group",
					name = L["Reset Zoom"],
					args = {
						enableZoomReset = {
							order = 2,
							type = "toggle",
							name = L["Reset Zoom"],
							get = function(info) return E.db.general.minimap.resetZoom.enable end,
							set = function(info, value) E.db.general.minimap.resetZoom.enable = value MM:UpdateSettings() end,
							disabled = function() return not E.private.general.minimap.enable end
						},
						zoomResetTime = {
							order = 3,
							type = "range",
							name = L["Seconds"],
							min = 1, max = 15, step = 1,
							get = function(info) return E.db.general.minimap.resetZoom.time end,
							set = function(info, value) E.db.general.minimap.resetZoom.time = value MM:UpdateSettings() end,
							disabled = function() return (not E.db.general.minimap.resetZoom.enable or not E.private.general.minimap.enable) end
						}
					}
				},
				icons = {
					order = 5,
					type = "group",
					name = L["Minimap Buttons"],
					args = {
						calendar = {
							order = 1,
							type = "group",
							name = L["Calendar"],
							get = function(info) return E.db.general.minimap.icons.calendar[info[#info]] end,
							set = function(info, value) E.db.general.minimap.icons.calendar[info[#info]] = value MM:UpdateSettings() end,
							disabled = function() return not E.private.general.minimap.enable end,
							args = {
								hide = {
									order = 2,
									type = "toggle",
									name = L["HIDE"],
									width = "full"
								},
								spacer = {
									order = 3,
									type = "description",
									name = "",
									width = "full"
								},
								position = {
									order = 4,
									type = "select",
									name = L["Position"],
									values = positionValues,
									disabled = function() return E.db.general.minimap.icons.calendar.hide end
								},
								scale = {
									order = 5,
									type = "range",
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05,
									disabled = function() return E.db.general.minimap.icons.calendar.hide end
								},
								xOffset = {
									order = 6,
									type = "range",
									name = L["X-Offset"],
									min = -50, max = 50, step = 1,
									disabled = function() return E.db.general.minimap.icons.calendar.hide end
								},
								yOffset = {
									order = 7,
									type = "range",
									name = L["Y-Offset"],
									min = -50, max = 50, step = 1,
									disabled = function() return E.db.general.minimap.icons.calendar.hide end
								}
							}
						},
						worldMap = {
							order = 2,
							type = "group",
							name = L["WORLD_MAP"],
							get = function(info) return E.db.general.minimap.icons.worldMap[info[#info]] end,
							set = function(info, value) E.db.general.minimap.icons.worldMap[info[#info]] = value MM:UpdateSettings() end,
							disabled = function() return not E.private.general.minimap.enable end,
							args = {
								hide = {
									order = 2,
									type = "toggle",
									name = L["HIDE"],
									width = "full"
								},
								position = {
									order = 3,
									type = "select",
									name = L["Position"],
									values = positionValues,
									disabled = function() return E.db.general.minimap.icons.worldMap.hide end
								},
								scale = {
									order = 4,
									type = "range",
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05,
									disabled = function() return E.db.general.minimap.icons.worldMap.hide end
								},
								xOffset = {
									order = 5,
									type = "range",
									name = L["X-Offset"],
									min = -50, max = 50, step = 1,
									disabled = function() return E.db.general.minimap.icons.worldMap.hide end
								},
								yOffset = {
									order = 6,
									type = "range",
									name = L["Y-Offset"],
									min = -50, max = 50, step = 1,
									disabled = function() return E.db.general.minimap.icons.worldMap.hide end
								}
							}
						},
						mail = {
							order = 3,
							type = "group",
							name = L["MAIL_LABEL"],
							get = function(info) return E.db.general.minimap.icons.mail[info[#info]] end,
							set = function(info, value) E.db.general.minimap.icons.mail[info[#info]] = value MM:UpdateSettings() end,
							disabled = function() return not E.private.general.minimap.enable end,
							args = {
								position = {
									order = 1,
									type = "select",
									name = L["Position"],
									values = positionValues
								},
								texture = {
									order = 2,
									type = "select",
									name = L["Texture"],
									values = {}
								},
								spacer = {
									order = 3,
									type = "description",
									name = ""
								},
								scale = {
									order = 4,
									type = "range",
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05
								},
								xOffset = {
									order = 5,
									type = "range",
									name = L["X-Offset"],
									min = -50, max = 50, step = 1
								},
								yOffset = {
									order = 6,
									type = "range",
									name = L["Y-Offset"],
									min = -50, max = 50, step = 1
								}
							}
						},
						lfgEye = {
							order = 4,
							type = "group",
							name = L["LFG Queue"],
							get = function(info) return E.db.general.minimap.icons.lfgEye[info[#info]] end,
							set = function(info, value) E.db.general.minimap.icons.lfgEye[info[#info]] = value MM:UpdateSettings() end,
							disabled = function() return not E.private.general.minimap.enable end,
							args = {
								position = {
									order = 2,
									type = "select",
									name = L["Position"],
									values = positionValues
								},
								scale = {
									order = 3,
									type = "range",
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05
								},
								xOffset = {
									order = 4,
									type = "range",
									name = L["X-Offset"],
									min = -50, max = 50, step = 1
								},
								yOffset = {
									order = 5,
									type = "range",
									name = L["Y-Offset"],
									min = -50, max = 50, step = 1
								}
							}
						},
						difficulty = {
							order = 6,
							type = "group",
							name = L["Instance Difficulty"],
							get = function(info) return E.db.general.minimap.icons.difficulty[info[#info]] end,
							set = function(info, value) E.db.general.minimap.icons.difficulty[info[#info]] = value MM:UpdateSettings() end,
							disabled = function() return not E.private.general.minimap.enable end,
							args = {
								position = {
									order = 2,
									type = "select",
									name = L["Position"],
									values = positionValues
								},
								scale = {
									order = 3,
									type = "range",
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05
								},
								xOffset = {
									order = 4,
									type = "range",
									name = L["X-Offset"],
									min = -50, max = 50, step = 1
								},
								yOffset = {
									order = 5,
									type = "range",
									name = L["Y-Offset"],
									min = -50, max = 50, step = 1
								}
							}
						},
						challengeMode = {
							order = 7,
							type = "group",
							name = L["CHALLENGE_MODE"],
							get = function(info) return E.db.general.minimap.icons.challengeMode[info[#info]] end,
							set = function(info, value) E.db.general.minimap.icons.challengeMode[info[#info]] = value MM:UpdateSettings() end,
							args = {
								position = {
									order = 1,
									type = "select",
									name = L["Position"],
									disabled = function() return not E.private.general.minimap.enable end,
									values = positionValues
								},
								scale = {
									order = 2,
									type = "range",
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05,
									disabled = function() return not E.private.general.minimap.enable end
								},
								xOffset = {
									order = 3,
									type = "range",
									name = L["X-Offset"],
									min = -50, max = 50, step = 1,
									disabled = function() return not E.private.general.minimap.enable end
								},
								yOffset = {
									order = 4,
									type = "range",
									name = L["Y-Offset"],
									min = -50, max = 50, step = 1,
									disabled = function() return not E.private.general.minimap.enable end
								}
							}
						},
						ticket = {
							order = 8,
							type = "group",
							name = L["Open Ticket"],
							get = function(info) return E.db.general.minimap.icons.ticket[info[#info]] end,
							set = function(info, value) E.db.general.minimap.icons.ticket[info[#info]] = value MM:UpdateSettings() end,
							disabled = function() return not E.private.general.minimap.enable end,
							args = {
								position = {
									order = 2,
									type = "select",
									name = L["Position"],
									values = positionValues
								},
								scale = {
									order = 3,
									type = "range",
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05
								},
								xOffset = {
									order = 4,
									type = "range",
									name = L["X-Offset"],
									min = -50, max = 50, step = 1
								},
								yOffset = {
									order = 5,
									type = "range",
									name = L["Y-Offset"],
									min = -50, max = 50, step = 1
								}
							}
						}
					}
				}
			}
		}
	}
}

do -- mail icons
	local mail = {}
	E.Options.args.maps.args.minimap.args.icons.args.mail.args.texture.values = mail

	for key, icon in pairs(E.Media.MailIcons) do
		mail[key] = E:TextureString(icon, ":14:14")
	end
end