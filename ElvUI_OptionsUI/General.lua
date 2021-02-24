local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(select(2, ...))
local Misc = E:GetModule("Misc")
local Layout = E:GetModule("Layout")
local Totems = E:GetModule("Totems")
local Blizzard = E:GetModule("Blizzard")
local Threat = E:GetModule("Threat")
local AFK = E:GetModule("AFK")

local _G = _G

local FCF_GetNumActiveChatFrames = FCF_GetNumActiveChatFrames

local function GetChatWindowInfo()
	local ChatTabInfo = {}
	for i = 1, FCF_GetNumActiveChatFrames() do
		ChatTabInfo["ChatFrame"..i] = _G["ChatFrame"..i.."Tab"]:GetText()
	end

	return ChatTabInfo
end

E.Options.args.general = {
	order = 1,
	type = "group",
	name = L["General"],
	childGroups = "tab",
	get = function(info) return E.db.general[info[#info]] end,
	set = function(info, value) E.db.general[info[#info]] = value end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["ELVUI_DESC"]
		},
		general = {
			order = 2,
			type = "group",
			name = L["General"],
			args = {
				general = {
					order = 1,
					type = "group",
					name = L["General"],
					guiInline = true,
					args = {
						loginmessage = {
							order = 1,
							type = "toggle",
							name = L["Login Message"]
						},
						taintLog = {
							order = 2,
							type = "toggle",
							name = L["Log Taints"],
							desc = L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."]
						},
						eyefinity = {
							order = 3,
							type = "toggle",
							name = L["Multi-Monitor Support"],
							desc = L["Attempt to support eyefinity/nvidia surround."],
							get = function() return E.global.general.eyefinity end,
							set = function(_, value) E.global.general.eyefinity = value E:StaticPopup_Show("GLOBAL_RL") end
						},
						ignoreVersionPopup = {
							order = 4,
							type = "toggle",
							name = L["Ignore Version Popup"],
							get = function() return E.global.general.ignoreVersionPopup end,
							set = function(_, value) E.global.general.ignoreVersionPopup = value end
						},
						ignoreScalePopup = {
							order = 5,
							type = "toggle",
							name = L["Ignore UI Scale Popup"],
							desc = L["This will prevent the UI Scale Popup from being shown when changing the game window size."],
							get = function() return E.global.general.ignoreScalePopup end,
							set = function(_, value) E.global.general.ignoreScalePopup = value end
						},
						locale = {
							order = 6,
							type = "select",
							name = L["LANGUAGE"],
							get = function() return E.global.general.locale end,
							set = function(_, value)
								E.global.general.locale = value
								E:StaticPopup_Show("CONFIG_RL")
							end,
							values = {
								deDE = "Deutsch",
								enUS = "English",
								esMX = "Español",
								frFR = "Français",
								ptBR = "Português",
								ruRU = "Русский",
								zhCN = "简体中文",
								zhTW = "正體中文",
								koKR = "한국어"
							}
						},
						messageRedirect = {
							order = 7,
							type = "select",
							name = L["Chat Output"],
							desc = L["This selects the Chat Frame to use as the output of ElvUI messages."],
							values = GetChatWindowInfo()
						},
						numberPrefixStyle = {
							order = 8,
							type = "select",
							name = L["Unit Prefix Style"],
							desc = L["The unit prefixes you want to use when values are shortened in ElvUI. This is mostly used on UnitFrames."],
							set = function(_, value)
								E.db.general.numberPrefixStyle = value
								E:BuildPrefixValues()
								E:StaticPopup_Show("CONFIG_RL")
							end,
							values = {
								TCHINESE = "萬, 億",
								CHINESE = "万, 亿",
								ENGLISH = "K, M, B",
								GERMAN = "Tsd, Mio, Mrd",
								KOREAN = "천, 만, 억",
								METRIC = "k, M, G"
							}
						},
						decimalLength = {
							order = 9,
							type = "range",
							name = L["Decimal Length"],
							desc = L["Controls the amount of decimals used in values displayed on elements like NamePlates and UnitFrames."],
							min = 0, max = 4, step = 1,
							set = function(_, value)
								E.db.general.decimalLength = value
								E:BuildPrefixValues()
								E:StaticPopup_Show("CONFIG_RL")
							end
						}
					}
				},
				cosmetic = {
					order = 2,
					type = "group",
					name = L["Cosmetic"],
					guiInline = true,
					args = {
						bottomPanel = {
							order = 1,
							type = "toggle",
							name = L["Bottom Panel"],
							desc = L["Display a panel across the bottom of the screen. This is for cosmetic only."],
							set = function(_, value) E.db.general.bottomPanel = value Layout:BottomPanelVisibility() end
						},
						topPanel = {
							order = 2,
							type = "toggle",
							name = L["Top Panel"],
							desc = L["Display a panel across the top of the screen. This is for cosmetic only."],
							set = function(_, value) E.db.general.topPanel = value Layout:TopPanelVisibility() end
						},
						afk = {
							order = 3,
							type = "toggle",
							name = L["AFK Mode"],
							desc = L["When you go AFK display the AFK screen."],
							set = function(_, value) E.db.general.afk = value AFK:Toggle() end
						},
						smoothingAmount = {
							order = 4,
							type = "range",
							isPercent = true,
							name = L["Smoothing Amount"],
							desc = L["Controls the speed at which smoothed bars will be updated."],
							min = 0.1, max = 0.8, softMax = 0.75, softMin = 0.25, step = 0.01,
							set = function(_, value)
								E.db.general.smoothingAmount = value
								E:SetSmoothingAmount(value)
							end
						}
					}
				},
				automation = {
					order = 3,
					type = "group",
					name = L["Automation"],
					guiInline = true,
					args = {
						interruptAnnounce = {
							order = 1,
							type = "select",
							name = L["Announce Interrupts"],
							desc = L["Announce when you interrupt a spell to the specified chat channel."],
							values = {
								NONE = L["NONE"],
								SAY = L["SAY"],
								PARTY = L["Party Only"],
								RAID = L["Party / Raid"],
								RAID_ONLY = L["Raid Only"],
								EMOTE = L["EMOTE"]
							},
							set = function(info, value)
								E.db.general[info[#info]] = value
								if value == "NONE" then
									Misc:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
								else
									Misc:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
								end
							end
						},
						autoRepair = {
							order = 2,
							type = "select",
							name = L["Auto Repair"],
							desc = L["Automatically repair using the following method when visiting a merchant."],
							values = {
								NONE = L["NONE"],
								GUILD = L["GUILD"],
								PLAYER = L["PLAYER"]
							}
						},
						autoTrackReputation = {
							order = 3,
							type = "toggle",
							name = L["Auto Track Reputation"]
						},
						autoAcceptInvite = {
							order = 4,
							type = "toggle",
							name = L["Accept Invites"],
							desc = L["Automatically accept invites from guild/friends."]
						}
					}
				},
				scaling = {
					order = 4,
					type = "group",
					name = L["UI_SCALE"],
					guiInline = true,
					args = {
						UIScale = {
							order = 1,
							type = "range",
							name = L["UI_SCALE"],
							min = 0.1, max = 1.25, step = 0.0000000000000001,
							softMin = 0.40, softMax = 1.15, bigStep = 0.01,
							get = function() return E.global.general.UIScale end,
							set = function(_, value)
								E.global.general.UIScale = value
								if not IsMouseButtonDown() then
									E:StaticPopup_Show("UISCALE_CHANGE")
								end
							end
						},
						ScaleSmall = {
							order = 2,
							type = "execute",
							name = L["Small"],
							customWidth = 100,
							func = function()
								E.global.general.UIScale = 0.6
								E:StaticPopup_Show("UISCALE_CHANGE")
							end
						},
						ScaleMedium = {
							order = 3,
							type = "execute",
							name = L["Medium"],
							customWidth = 100,
							func = function()
								E.global.general.UIScale = 0.7
								E:StaticPopup_Show("UISCALE_CHANGE")
							end
						},
						ScaleLarge = {
							order = 4,
							type = "execute",
							name = L["Large"],
							customWidth = 100,
							func = function()
								E.global.general.UIScale = 0.8
								E:StaticPopup_Show("UISCALE_CHANGE")
							end
						},
						AutoScale = {
							order = 5,
							type = "execute",
							name = L["Auto Scale"],
							customWidth = 100,
							func = function()
								E.global.general.UIScale = E:PixelBestSize()
								E:StaticPopup_Show("UISCALE_CHANGE")
							end
						}
					}
				},
				totems = {
					order = 5,
					type = "group",
					name = L["Class Totems"],
					guiInline = true,
					get = function(info) return E.db.general.totems[info[#info]] end,
					set = function(info, value) E.db.general.totems[info[#info]] = value Totems:PositionAndSize() end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["ENABLE"],
							set = function(info, value) E.db.general.totems[info[#info]] = value Totems:ToggleEnable() end
						},
						spacer = {
							order = 2,
							type = "description",
							name = ""
						},
						size = {
							order = 3,
							type = "range",
							name = L["Button Size"],
							min = 24, max = 60, step = 1,
							disabled = function() return not E.db.general.totems.enable end
						},
						spacing = {
							order = 4,
							type = "range",
							name = L["Button Spacing"],
							min = 1, max = 10, step = 1,
							disabled = function() return not E.db.general.totems.enable end
						},
						sortDirection = {
							order = 5,
							type = "select",
							name = L["Sort Direction"],
							values = {
								ASCENDING = L["Ascending"],
								DESCENDING = L["Descending"]
							},
							disabled = function() return not E.db.general.totems.enable end
						},
						growthDirection = {
							order = 6,
							type = "select",
							name = L["Bar Direction"],
							values = {
								VERTICAL = L["Vertical"],
								HORIZONTAL = L["Horizontal"]
							},
							disabled = function() return not E.db.general.totems.enable end
						}
					}
				}
			}
		},
		media = {
			order = 3,
			type = "group",
			name = L["Media"],
			get = function(info) return E.db.general[info[#info]] end,
			set = function(info, value) E.db.general[info[#info]] = value end,
			args = {
				fontGroup = {
					order = 1,
					type = "group",
					name = L["Fonts"],
					guiInline = true,
					args = {
						main = {
							order = 1,
							type = "group",
							name = L["General"],
							set = function(info, value) E.db.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() end,
							args = {
								font = {
									order = 1,
									type = "select", dialogControl = "LSM30_Font",
									name = L["Default Font"],
									desc = L["The font that the core of the UI will use."],
									values = AceGUIWidgetLSMlists.font
								},
								fontSize = {
									order = 2,
									type = "range",
									name = L["FONT_SIZE"],
									desc = L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"],
									min = 4, max = 32, step = 1
								},
								fontStyle = {
									order = 3,
									type = "select",
									name = L["Font Outline"],
									values = C.Values.FontFlags
								},
								applyFontToAll = {
									order = 4,
									type = "execute",
									name = L["Apply Font To All"],
									desc = L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."],
									func = function() E:StaticPopup_Show("APPLY_FONT_WARNING") end
								}
							}
						},
						blizzard = {
							order = 2,
							type = "group",
							name = L["Blizzard"],
							get = function(info) return E.private.general[info[#info]] end,
							set = function(info, value) E.private.general[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end,
							args = {
								replaceBlizzFonts = {
									order = 1,
									type = "toggle",
									name = L["Replace Blizzard Fonts"],
									desc = L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI Options. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."]
								},
								spacer = {
									order = 2,
									type = "description",
									name = ""
								},
								replaceCombatFont = {
									order = 3,
									type = "toggle",
									name = L["Replace Combat Font"]
								},
								dmgfont = {
									order = 4,
									type = "select", dialogControl = "LSM30_Font",
									name = L["CombatText Font"],
									desc = L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
									values = AceGUIWidgetLSMlists.font,
									set = function(info, value) E.private.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() E:StaticPopup_Show("PRIVATE_RL") end,
									disabled = function() return not E.private.general.replaceCombatFont end
								},
								replaceNameFont = {
									order = 5,
									type = "toggle",
									name = L["Replace Name Font"]
								},
								namefont = {
									order = 6,
									type = "select", dialogControl = "LSM30_Font",
									name = L["Name Font"],
									desc = L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
									values = AceGUIWidgetLSMlists.font,
									set = function(info, value) E.private.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() E:StaticPopup_Show("PRIVATE_RL") end,
									disabled = function() return not E.private.general.replaceNameFont end
								}
							}
						}
					}
				},
				textureGroup = {
					order = 2,
					type = "group",
					name = L["Textures"],
					guiInline = true,
					get = function(info) return E.private.general[info[#info]] end,
					args = {
						normTex = {
							order = 1,
							type = "select", dialogControl = "LSM30_Statusbar",
							name = L["Primary Texture"],
							desc = L["The texture that will be used mainly for statusbars."],
							values = AceGUIWidgetLSMlists.statusbar,
							set = function(info, value)
								local previousValue = E.private.general[info[#info]]
								E.private.general[info[#info]] = value

								if E.db.unitframe.statusbar == previousValue then
									E.db.unitframe.statusbar = value
									E:UpdateAll(true)
								else
									E:UpdateMedia()
									E:UpdateStatusBars()
								end
							end
						},
						glossTex = {
							order = 2,
							type = "select", dialogControl = "LSM30_Statusbar",
							name = L["Secondary Texture"],
							desc = L["This texture will get used on objects like chat windows and dropdown menus."],
							values = AceGUIWidgetLSMlists.statusbar,
							set = function(info, value)
								E.private.general[info[#info]] = value
								E:UpdateMedia()
								E:UpdateFrameTemplates()
							end
						},
						applyTextureToAll = {
							order = 3,
							type = "execute",
							name = L["Apply Texture To All"],
							desc = L["Applies the primary texture to all statusbars."],
							func = function()
								local texture = E.private.general.normTex
								E.db.unitframe.statusbar = texture
								E.db.nameplates.statusbar = texture
								E:UpdateAll(true)
							end
						}
					}
				},
				bordersGroup = {
					order = 3,
					type = "group",
					name = L["Borders"],
					guiInline = true,
					args = {
						uiThinBorders = {
							order = 1,
							type = "toggle",
							name = L["Thin Borders"],
							desc = L["The Thin Border Theme option will change the overall apperance of your UI. Using Thin Border Theme is a slight performance increase over the traditional layout."],
							get = function() return E.private.general.pixelPerfect end,
							set = function(_, value) E.private.general.pixelPerfect = value E:StaticPopup_Show("PRIVATE_RL") end
						},
						ufThinBorders = {
							order = 2,
							type = "toggle",
							name = L["Unitframe Thin Borders"],
							desc = L["Use thin borders on certain unitframe elements."],
							get = function() return E.db.unitframe.thinBorders end,
							set = function(_, value) E.db.unitframe.thinBorders = value E:StaticPopup_Show("CONFIG_RL") end,
							disabled = function() return E.private.general.pixelPerfect end
						},
						npThinBorders = {
							order = 3,
							type = "toggle",
							name = L["Nameplate Thin Borders"],
							desc = L["Use thin borders on certain nameplate elements."],
							get = function() return E.db.nameplates.thinBorders end,
							set = function(_, value) E.db.nameplates.thinBorders = value E:StaticPopup_Show("CONFIG_RL") end
						},
						cropIcon = {
							order = 4,
							type = "toggle",
							tristate = true,
							name = L["Crop Icons"],
							desc = L["This is for Customized Icons in your Interface/Icons folder."],
							get = function(info)
								local value = E.db.general[info[#info]]
								if value == 2 then return true
								elseif value == 1 then return nil
								else return false end
							end,
							set = function(info, value)
								E.db.general[info[#info]] = (value and 2) or (value == nil and 1) or 0
								E:StaticPopup_Show("CONFIG_RL")
							end
						}
					}
				},
				colorsGroup = {
					order = 4,
					type = "group",
					name = L["COLORS"],
					guiInline = true,
					get = function(info)
						local t = E.db.general[info[#info]]
						local d = P.general[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
					end,
					set = function(info, r, g, b, a)
						local setting = info[#info]
						local t = E.db.general[setting]
						t.r, t.g, t.b, t.a = r, g, b, a
						E:UpdateMedia()
						if setting == "bordercolor" then
							E:UpdateBorderColors()
						elseif setting == "backdropcolor" or setting == "backdropfadecolor" then
							E:UpdateBackdropColors()
						end
					end,
					args = {
						backdropcolor = {
							order = 1,
							type = "color",
							name = L["Backdrop Color"],
							desc = L["Main backdrop color of the UI."],
							hasAlpha = false
						},
						backdropfadecolor = {
							order = 2,
							type = "color",
							name = L["Backdrop Faded Color"],
							desc = L["Backdrop color of transparent frames"],
							hasAlpha = true
						},
						valuecolor = {
							order = 3,
							type = "color",
							name = L["Value Color"],
							desc = L["Color some texts use."],
							hasAlpha = false
						},
						spacer = {
							order = 4,
							type = "description",
							name = ""
						},
						bordercolor = {
							order = 5,
							type = "color",
							name = L["Border Color"],
							desc = L["Main border color of the UI."],
							hasAlpha = false
						},
						ufBorderColors = {
							order = 6,
							type = "color",
							name = L["Unitframes Border Color"],
							get = function()
								local t = E.db.unitframe.colors.borderColor
								local d = P.unitframe.colors.borderColor
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(_, r, g, b)
								local t = E.db.unitframe.colors.borderColor
								t.r, t.g, t.b = r, g, b
								E:UpdateMedia()
								E:UpdateBorderColors()
							end
						}
					}
				}
			}
		},
		threatGroup = {
			order = 4,
			type = "group",
			name = L["Threat"],
			get = function(info) return E.db.general.threat[info[#info]] end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"],
					set = function(_, value) E.db.general.threat.enable = value Threat:ToggleEnable() end
				},
				position = {
					order = 2,
					type = "select",
					name = L["Position"],
					desc = L["Adjust the position of the threat bar to either the left or right datatext panels."],
					values = {
						LEFTCHAT = L["Left Chat"],
						RIGHTCHAT = L["Right Chat"]
					},
					set = function(_, value) E.db.general.threat.position = value Threat:UpdatePosition() end,
					disabled = function() return not E.db.general.threat.enable end
				},
				spacer = {
					order = 3,
					type = "description",
					name = ""
				},
				textfont = {
					order = 4,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
					set = function(_, value) E.db.general.threat.textfont = value Threat:UpdatePosition() end,
					disabled = function() return not E.db.general.threat.enable end
				},
				textSize = {
					order = 5,
					type = "range",
					name = L["FONT_SIZE"],
					min = 6, max = 22, step = 1,
					set = function(_, value) E.db.general.threat.textSize = value Threat:UpdatePosition() end,
					disabled = function() return not E.db.general.threat.enable end
				},
				textOutline = {
					order = 6,
					type = "select",
					name = L["Font Outline"],
					desc = L["Set the font outline."],
					values = C.Values.FontFlags,
					set = function(_, value) E.db.general.threat.textOutline = value Threat:UpdatePosition() end,
					disabled = function() return not E.db.general.threat.enable end
				}
			}
		},
		alternativePowerGroup = {
			order = 5,
			type = "group",
			name = L["Alternative Power"],
			get = function(info) return E.db.general.altPowerBar[info[#info]] end,
			set = function(info, value)
				E.db.general.altPowerBar[info[#info]] = value
				Blizzard:UpdateAltPowerBarSettings()
			end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"],
					desc = L["Replace Blizzard's Alternative Power Bar"],
					width = "full",
					set = function(info, value)
						E.db.general.altPowerBar[info[#info]] = value
						E:StaticPopup_Show("CONFIG_RL")
					end
				},
				width = {
					order = 2,
					type = "range",
					name = L["Width"],
					min = 50, max = 1000, step = 1
				},
				height = {
					order = 3,
					type = "range",
					name = L["Height"],
					min = 5, max = 100, step = 1
				},
				statusBarGroup = {
					order = 4,
					type = "group",
					name = L["Status Bar"],
					guiInline = true,
					get = function(info)
						return E.db.general.altPowerBar[info[#info]]
					end,
					set = function(info, value)
						E.db.general.altPowerBar[info[#info]] = value
						Blizzard:UpdateAltPowerBarColors()
						Blizzard:UpdateAltPowerBarSettings()
					end,
					args = {
						statusBar = {
							order = 1,
							type = "select",
							dialogControl = "LSM30_Statusbar",
							name = L["StatusBar Texture"],
							values = AceGUIWidgetLSMlists.statusbar
						},
						smoothbars = {
							order = 2,
							type = "toggle",
							name = L["Smooth Bars"],
							desc = L["Bars will transition smoothly."]
						},
						statusBarColorGradient = {
							order = 3,
							type = "toggle",
							name = L["Color Gradient"]
						},
						statusBarColor = {
							order = 4,
							type = "color",
							name = L["COLOR"],
							get = function(info)
								local t = E.db.general.altPowerBar[info[#info]]
								local d = P.general.altPowerBar[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.general.altPowerBar[info[#info]]
								t.r, t.g, t.b = r, g, b
								Blizzard:UpdateAltPowerBarColors()
							end,
							disabled = function()
								return E.db.general.altPowerBar.statusBarColorGradient
							end
						}
					}
				},
				textGroup = {
					order = 5,
					type = "group",
					name = L["Text"],
					guiInline = true,
					get = function(info)
						return E.db.general.altPowerBar[info[#info]]
					end,
					set = function(info, value)
						E.db.general.altPowerBar[info[#info]] = value
						Blizzard:UpdateAltPowerBarSettings()
					end,
					args = {
						textFormat = {
							order = 1,
							type = "select",
							name = L["Text Format"],
							sortByValue = true,
							customWidth = 250,
							values = {
								NONE = L["NONE"],
								NAME = L["NAME"],
								NAMEPERC = L["Name: Percent"],
								NAMECURMAX = L["Name: Current / Max"],
								NAMECURMAXPERC = L["Name: Current / Max - Percent"],
								PERCENT = L["Percent"],
								CURMAX = L["Current / Max"],
								CURMAXPERC = L["Current / Max - Percent"]
							}
						},
						spacer = {
							order = 2,
							type = "description",
							name = ""
						},
						font = {
							order = 3,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font
						},
						fontSize = {
							order = 4,
							type = "range",
							name = L["FONT_SIZE"],
							min = 6, max = 22, step = 1
						},
						fontOutline = {
							order = 5,
							type = "select",
							name = L["Font Outline"],
							values = C.Values.FontFlags
						}
					}
				}
			}
		},
		blizzUIImprovements = {
			order = 6,
			type = "group",
			name = L["BlizzUI Improvements"],
			get = function(info) return E.db.general[info[#info]] end,
			set = function(info, value) E.db.general[info[#info]] = value end,
			args = {
				general = {
					order = 1,
					type = "group",
					name = L["General"],
					guiInline = true,
					args = {
						hideErrorFrame = {
							order = 1,
							type = "toggle",
							name = L["Hide Error Text"],
							desc = L["Hides the red error text at the top of the screen while in combat."]
						},
						enhancedPvpMessages = {
							order = 2,
							type = "toggle",
							name = L["Enhanced PVP Messages"],
							desc = L["Display battleground messages in the middle of the screen."]
						},
						lfrEnhancement = {
							order = 3,
							type = "toggle",
							name = L["Enhance Raid Browser"],
							desc = L["Enhance the raid browser frame by adding item level and talent spec information, also add average item level of group information to tooltips."],
							get = function(info) return E.private.general.lfrEnhancement end,
							set = function(info, value) E.private.general.lfrEnhancement = value E:StaticPopup_Show("PRIVATE_RL") end
						},
						showMissingTalentAlert = {
							order = 4,
							type = "toggle",
							name = L["Missing Talent Alert"],
							desc = L["Show an alert frame if you have unspend talent points."],
							get = function(info) return E.global.general.showMissingTalentAlert end,
							set = function(info, value) E.global.general.showMissingTalentAlert = value E:StaticPopup_Show("GLOBAL_RL") end
						},
						raidUtility = {
							order = 5,
							type = "toggle",
							name = L["RAID_CONTROL"],
							desc = L["Enables the ElvUI Raid Control panel."],
							get = function(info) return E.private.general.raidUtility end,
							set = function(info, value) E.private.general.raidUtility = value E:StaticPopup_Show("PRIVATE_RL") end
						},
						resurrectSound = {
							order = 6,
							type = "toggle",
							name = L["Resurrect Sound"],
							desc = L["Enable to hear sound if you receive a resurrect."]
						},
						questRewardMostValueIcon = {
							order = 7,
							type = "toggle",
							name = L["Mark Quest Reward"],
							desc = L["Marks the most valuable quest reward with a gold coin."]
						},
						spacer = {
							order = 8,
							type = "description",
							name = ""
						},
						vehicleSeatIndicatorSize = {
							order = 9,
							type = "range",
							name = L["Vehicle Seat Indicator Size"],
							min = 64, max = 128, step = 4,
							set = function(_, value) E.db.general.vehicleSeatIndicatorSize = value Blizzard:UpdateVehicleFrame() end
						},
						durabilityScale = {
							order = 10,
							type = "range",
							name = L["Durability Scale"],
							min = 0.5, max = 8, step = 0.5,
							set = function(_, value) E.db.general.durabilityScale = value E:StaticPopup_Show("CONFIG_RL") end
						}
					}
				},
				lootGroup = {
					order = 2,
					type = "group",
					name = L["LOOT"],
					guiInline = true,
					args = {
						loot = {
							order = 1,
							type = "toggle",
							name = L["LOOT"],
							desc = L["Enable/Disable the loot frame."],
							get = function() return E.private.general.loot end,
							set = function(_, value) E.private.general.loot = value E:StaticPopup_Show("PRIVATE_RL") end
						},
						lootRoll = {
							order = 2,
							type = "toggle",
							name = L["Loot Roll"],
							desc = L["Enable/Disable the loot roll frame."],
							get = function() return E.private.general.lootRoll end,
							set = function(_, value) E.private.general.lootRoll = value E:StaticPopup_Show("PRIVATE_RL") end
						},
						autoRoll = {
							order = 3,
							type = "toggle",
							name = L["Auto Greed/DE"],
							desc = L["Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level."],
							get = function() return E.db.general.autoRoll end,
							set = function(_, value) E.db.general.autoRoll = value end,
							disabled = function() return not E.private.general.lootRoll end
						}
					}
				},
				itemLevelInfo = {
					order = 3,
					type = "group",
					name = L["Item Level"],
					guiInline = true,
					get = function(info) return E.db.general.itemLevel[info[#info]] end,
					args = {
						displayCharacterInfo = {
							order = 1,
							type = "toggle",
							name = L["Display Character Info"],
							desc = L["Shows item level of each item, enchants, and gems on the character page."],
							set = function(_, value)
								E.db.general.itemLevel.displayCharacterInfo = value
								Misc:ToggleItemLevelInfo()
							end
						},
						displayInspectInfo = {
							order = 2,
							type = "toggle",
							name = L["Display Inspect Info"],
							desc = L["Shows item level of each item, enchants, and gems when inspecting another player."],
							set = function(_, value)
								E.db.general.itemLevel.displayInspectInfo = value
								Misc:ToggleItemLevelInfo()
							end
						},
						spacer = {
							order = 3,
							type = "description",
							name = ""
						},
						itemLevelFont = {
							order = 4,
							type = "select",
							name = L["Font"],
							dialogControl = "LSM30_Font",
							values = AceGUIWidgetLSMlists.font,
							set = function(info, value)
								E.db.general.itemLevel[info[#info]] = value
								Misc:UpdateInspectPageFonts("Character")
								Misc:UpdateInspectPageFonts("Inspect")
							end,
							disabled = function() return not E.db.general.itemLevel.displayCharacterInfo and not E.db.general.itemLevel.displayInspectInfo end
						},
						itemLevelFontSize = {
							order = 5,
							type = "range",
							name = L["FONT_SIZE"],
							min = 4, max = 40, step = 1,
							set = function(info, value)
								E.db.general.itemLevel[info[#info]] = value
								Misc:UpdateInspectPageFonts("Character")
								Misc:UpdateInspectPageFonts("Inspect")
							end,
							disabled = function() return not E.db.general.itemLevel.displayCharacterInfo and not E.db.general.itemLevel.displayInspectInfo end
						},
						itemLevelFontOutline = {
							order = 6,
							type = "select",
							name = L["Font Outline"],
							values = C.Values.FontFlags,
							set = function(info, value)
								E.db.general.itemLevel[info[#info]] = value
								Misc:UpdateInspectPageFonts("Character")
								Misc:UpdateInspectPageFonts("Inspect")
							end,
							disabled = function() return not E.db.general.itemLevel.displayCharacterInfo and not E.db.general.itemLevel.displayInspectInfo end
						}
					}
				},
				chatBubblesGroup = {
					order = 4,
					type = "group",
					guiInline = true,
					name = L["Chat Bubbles"],
					get = function(info) return E.private.general[info[#info]] end,
					set = function(info, value) E.private.general[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end,
					args = {
						chatBubbles = {
							order = 1,
							type = "select",
							name = L["Chat Bubbles Style"],
							desc = L["Skin the blizzard chat bubbles."],
							values = {
								backdrop = L["Skin Backdrop"],
								nobackdrop = L["Remove Backdrop"],
								backdrop_noborder = L["Skin Backdrop (No Borders)"],
								disabled = L["DISABLE"]
							}
						},
						chatBubbleFont = {
							order = 2,
							type = "select",
							name = L["Font"],
							dialogControl = "LSM30_Font",
							values = AceGUIWidgetLSMlists.font,
							disabled = function() return E.private.general.chatBubbles == "disabled" end
						},
						chatBubbleFontSize = {
							order = 3,
							type = "range",
							name = L["FONT_SIZE"],
							min = 4, max = 32, step = 1,
							disabled = function() return E.private.general.chatBubbles == "disabled" end
						},
						chatBubbleFontOutline = {
							order = 4,
							type = "select",
							name = L["Font Outline"],
							disabled = function() return E.private.general.chatBubbles == "disabled" end,
							values = C.Values.FontFlags
						},
						chatBubbleName = {
							order = 5,
							type = "toggle",
							name = L["Chat Bubble Names"],
							desc = L["Display the name of the unit on the chat bubble."],
							disabled = function() return E.private.general.chatBubbles == "disabled" or E.private.general.chatBubbles == "nobackdrop" end
						}
					}
				},
				objectiveFrameGroup = {
					order = 5,
					type = "group",
					guiInline = true,
					name = L["Objective Frame"],
					get = function(info) return E.db.general[info[#info]] end,
					args = {
						watchFrameAutoHide = {
							order = 1,
							type = "toggle",
							name = L["Auto Hide"],
							desc = L["Automatically hide the objective frame during boss or arena fights."],
							set = function(info, value) E.db.general.watchFrameAutoHide = value Blizzard:SetObjectiveFrameAutoHide() end
						},
						watchFrameHeight = {
							order = 2,
							type = "range",
							name = L["Objective Frame Height"],
							desc = L["Height of the objective tracker. Increase size to be able to see more objectives."],
							min = 400, max = E.screenheight, step = 1,
							set = function(info, value) E.db.general.watchFrameHeight = value Blizzard:SetWatchFrameHeight() end
						}
					}
				}
			}
		}
	}
}