local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(select(2, ...))
local DT = E:GetModule("DataTexts")
local Layout = E:GetModule("Layout")
local Chat = E:GetModule("Chat")
local Minimap = E:GetModule("Minimap")

local _G = _G
local pairs = pairs

local HideLeftChat = HideLeftChat
local HideRightChat = HideRightChat

local datatexts = {}

function DT:PanelLayoutOptions()
	for name, data in pairs(DT.RegisteredDataTexts) do
		datatexts[name] = data.localizedName or L[name]
	end
	datatexts[""] = L["NONE"]

	local order
	local table = E.Options.args.datatexts.args.panels.args
	for pointLoc, tab in pairs(P.datatexts.panels) do
		if not _G[pointLoc] then table[pointLoc] = nil return end
		if type(tab) == "table" then
			if pointLoc:find("Chat") then
				order = 15
			else
				order = 20
			end
			table[pointLoc] = {
				order = order,
				type = "group",
				name = L[pointLoc] or pointLoc,
				args = {}
			}
			for option in pairs(tab) do
				table[pointLoc].args[option] = {
					type = "select",
					name = L[option] or option:upper(),
					values = datatexts,
					get = function(info) return E.db.datatexts.panels[pointLoc][info[#info]] end,
					set = function(info, value) E.db.datatexts.panels[pointLoc][info[#info]] = value DT:LoadDataTexts() end
				}
			end
		elseif type(tab) == "string" then
			table.smallPanels.args[pointLoc] = {
				type = "select",
				name = L[pointLoc] or pointLoc,
				values = datatexts,
				get = function(info) return E.db.datatexts.panels[pointLoc] end,
				set = function(info, value) E.db.datatexts.panels[pointLoc] = value DT:LoadDataTexts() end
			}
		end
	end
end

local function CreateCustomCurrencyOptions(currencyID)
	local currency = E.global.datatexts.customCurrencies[currencyID]
	if currency then
		E.Options.args.datatexts.args.customCurrency.args.currencies.args[currency.NAME] = {
			order = 1,
			type = "group",
			name = currency.NAME,
			guiInline = false,
			args = {
				removeDT = {
					order = 1,
					type = "execute",
					name = DELETE,
					func = function()
						DT:RemoveCustomCurrency(currency.NAME)
						E.Options.args.datatexts.args.customCurrency.args.currencies.args[currency.NAME] = nil
						DT.RegisteredDataTexts[currency.NAME] = nil
						E.global.datatexts.customCurrencies[currencyID] = nil
						datatexts[currency.NAME] = nil
						DT:PanelLayoutOptions()
						DT:LoadDataTexts()
					end,
				},
				spacer = {
					order = 2,
					type = "description",
					name = "\n",
				},
				displayStyle = {
					order = 3,
					type = "select",
					name = L["Display Style"],
					get = function(info) return E.global.datatexts.customCurrencies[currencyID].DISPLAY_STYLE end,
					set = function(info, value)
						E.global.datatexts.customCurrencies[currencyID].DISPLAY_STYLE = value
						DT:UpdateCustomCurrencySettings(currency.NAME, "DISPLAY_STYLE", value)
						DT:LoadDataTexts()
					end,
					values = {
						["ICON"] = L["Icons Only"],
						["ICON_TEXT"] = L["Icons and Text"],
						["ICON_TEXT_ABBR"] = L["Icons and Text (Short)"]
					}
				},
				showMax = {
					order = 4,
					type = "toggle",
					name = L["Current / Max"],
					get = function(info) return E.global.datatexts.customCurrencies[currencyID].SHOW_MAX end,
					set = function(info, value)
						E.global.datatexts.customCurrencies[currencyID].SHOW_MAX = value
						DT:UpdateCustomCurrencySettings(currency.NAME, "SHOW_MAX", value)
						DT:LoadDataTexts()
					end
				},
				useTooltip = {
					order = 5,
					type = "toggle",
					name = L["Use Tooltip"],
					get = function(info) return E.global.datatexts.customCurrencies[currencyID].USE_TOOLTIP end,
					set = function(info, value)
						E.global.datatexts.customCurrencies[currencyID].USE_TOOLTIP = value
						DT:UpdateCustomCurrencySettings(currency.NAME, "USE_TOOLTIP", value)
					end,
				},
				displayInMainTooltip = {
					order = 6,
					type = "toggle",
					name = L["Display In Main Tooltip"],
					desc = L["If enabled, then this currency will be displayed in the main Currencies datatext tooltip."],
					get = function(info) return E.global.datatexts.customCurrencies[currencyID].DISPLAY_IN_MAIN_TOOLTIP end,
					set = function(info, value)
						E.global.datatexts.customCurrencies[currencyID].DISPLAY_IN_MAIN_TOOLTIP = value
						DT:UpdateCustomCurrencySettings(currency.NAME, "DISPLAY_IN_MAIN_TOOLTIP", value)
					end
				}
			}
		}
	end
end

local function SetupCustomCurrencies()
	--Create options for all stored custom currency datatexts
	for currencyID in pairs(E.global.datatexts.customCurrencies) do
		CreateCustomCurrencyOptions(currencyID)
	end
end

E.Options.args.datatexts = {
	order = 2,
	type = "group",
	name = L["DataTexts"],
	childGroups = "tab",
	get = function(info) return E.db.datatexts[info[#info]] end,
	set = function(info, value) E.db.datatexts[info[#info]] = value DT:LoadDataTexts() end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["DATATEXT_DESC"]
		},
		spacer = {
			order = 2,
			type = "description",
			name = ""
		},
		general = {
			order = 3,
			type = "group",
			name = L["General"],
			args = {
				generalGroup = {
					order = 2,
					type = "group",
					guiInline = true,
					name = L["General"],
					args = {
						battleground = {
							order = 1,
							type = "toggle",
							name = L["Battleground Texts"],
							desc = L["When inside a battleground display personal scoreboard information on the main datatext bars."]
						},
						panelTransparency = {
							order = 2,
							name = L["Panel Transparency"],
							type = "toggle",
							set = function(info, value)
								E.db.datatexts[info[#info]] = value
								Layout:SetDataPanelStyle()
							end
						},
						panelBackdrop = {
							order = 3,
							type = "toggle",
							name = L["Backdrop"],
							set = function(info, value)
								E.db.datatexts[info[#info]] = value
								Layout:SetDataPanelStyle()
							end
						},
						noCombatClick = {
							order = 4,
							type = "toggle",
							name = L["Block Combat Click"],
							desc = L["Blocks all click events while in combat."]
						},
						noCombatHover = {
							order = 5,
							type = "toggle",
							name = L["Block Combat Hover"],
							desc = L["Blocks datatext tooltip from showing in combat."]
						},
						goldFormat = {
							order = 6,
							type = "select",
							name = L["Gold Format"],
							desc = L["The display format of the money text that is shown in the gold datatext and its tooltip."],
							values = {
								["SMART"] = L["Smart"],
								["FULL"] = L["Full"],
								["SHORT"] = L["SHORT"],
								["SHORTINT"] = L["Short (Whole Numbers)"],
								["CONDENSED"] = L["Condensed"],
								["BLIZZARD"] = L["Blizzard Style"]
							}
						},
						goldCoins = {
							order = 7,
							type = "toggle",
							name = L["Show Coins"],
							desc = L["Use coin icons instead of colored text."]
						}
					}
				},
				fontGroup = {
					order = 3,
					type = "group",
					guiInline = true,
					name = L["Fonts"],
					args = {
						font = {
							order = 1,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font
						},
						fontSize = {
							order = 2,
							type = "range",
							name = L["FONT_SIZE"],
							min = 4, max = 22, step = 1
						},
						fontOutline = {
							order = 3,
							type = "select",
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							values = C.Values.FontFlags
						},
						wordWrap = {
							order = 4,
							type = "toggle",
							name = L["Word Wrap"]
						}
					}
				}
			}
		},
		panels = {
			order = 4,
			type = "group",
			name = L["Panels"],
			args = {
				leftChatPanel = {
					order = 2,
					type = "toggle",
					name = L["Datatext Panel (Left)"],
					desc = L["Display data panels below the chat, used for datatexts."],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						if E.db.LeftChatPanelFaded then
							E.db.LeftChatPanelFaded = true
							HideLeftChat()
						end
						Chat:UpdateAnchors()
						Layout:ToggleChatPanels()
					end
				},
				rightChatPanel = {
					order = 3,
					type = "toggle",
					name = L["Datatext Panel (Right)"],
					desc = L["Display data panels below the chat, used for datatexts."],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						if E.db.RightChatPanelFaded then
							E.db.RightChatPanelFaded = true
							HideRightChat()
						end
						Chat:UpdateAnchors()
						Layout:ToggleChatPanels()
					end
				},
				minimapPanels = {
					order = 4,
					type = "toggle",
					name = L["Minimap Panels"],
					desc = L["Display minimap panels below the minimap, used for datatexts."],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end
				},
				minimapTop = {
					order = 5,
					type = "toggle",
					name = L["TopMiniPanel"],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end
				},
				minimapTopLeft = {
					order = 6,
					type = "toggle",
					name = L["TopLeftMiniPanel"],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end
				},
				minimapTopRight = {
					order = 7,
					type = "toggle",
					name = L["TopRightMiniPanel"],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end
				},
				minimapBottom = {
					order = 8,
					type = "toggle",
					name = L["BottomMiniPanel"],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end
				},
				minimapBottomLeft = {
					order = 9,
					type = "toggle",
					name = L["BottomLeftMiniPanel"],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end
				},
				minimapBottomRight = {
					order = 10,
					type = "toggle",
					name = L["BottomRightMiniPanel"],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end
				},
				spacer = {
					order = 11,
					type = "description",
					name = "\n"
				},
				smallPanels = {
					order = 12,
					type = "group",
					name = L["Small Panels"],
					args = {}
				}
			}
		},
		time = {
			order = 5,
			type = "group",
			name = L["Time"],
			args = {
				timeFormat = {
					order = 2,
					type = "select",
					name = L["Time Format"],
					values = {
						[""] = L["NONE"],
						["%I:%M"] = "03:27",
						["%I:%M:%S"] = "03:27:32",
						["%I:%M %p"] = "03:27 PM",
						["%I:%M:%S %p"] = "03:27:32 PM",
						["%H:%M"] = "15:27",
						["%H:%M:%S"] = "15:27:32"
					}
				},
				dateFormat = {
					order = 3,
					type = "select",
					name = L["Date Format"],
					values = {
						[""] = L["NONE"],
						["%d/%m/%y "] = "DD/MM/YY",
						["%m/%d/%y "] = "MM/DD/YY",
						["%y/%m/%d "] = "YY/MM/DD",
						["%d.%m.%y "] = "DD.MM.YY",
						["%m.%d.%y "] = "MM.DD.YY",
						["%y.%m.%d "] = "YY.MM.DD"
					}
				},
				localTime = {
					order = 4,
					type = "toggle",
					name = L["Local Time"],
					desc = L["If not set to true then the server time will be displayed instead."]
				}
			}
		},
		friends = {
			order = 6,
			type = "group",
			name = L["FRIENDS"],
			args = {
				description = {
					order = 2,
					type = "description",
					name = L["Hide specific sections in the datatext tooltip."]
				},
				hideGroup = {
					order = 3,
					type = "group",
					guiInline = true,
					name = L["HIDE"],
					args = {
						hideAFK = {
							order = 1,
							type = "toggle",
							name = L["AFK"],
							get = function(info) return E.db.datatexts.friends.hideAFK end,
							set = function(info, value) E.db.datatexts.friends.hideAFK = value DT:LoadDataTexts() end
						},
						hideDND = {
							order = 2,
							type = "toggle",
							name = L["DND"],
							get = function(info) return E.db.datatexts.friends.hideDND end,
							set = function(info, value) E.db.datatexts.friends.hideDND = value DT:LoadDataTexts() end
						}
					}
				}
			}
		},
		currencies = {
			order = 7,
			type = "group",
			name = L["CURRENCY"],
			args = {
				displayedCurrency = {
					order = 2,
					type = "select",
					name = L["Displayed Currency"],
					width = "double",
					get = function(info) return E.db.datatexts.currencies.displayedCurrency end,
					set = function(info, value) E.db.datatexts.currencies.displayedCurrency = value DT:LoadDataTexts() end,
					values = function() return DT:Currencies_GetCurrencyList() end
				},
				displayStyle = {
					order = 3,
					type = "select",
					name = L["Currency Format"],
					get = function(info) return E.db.datatexts.currencies.displayStyle end,
					set = function(info, value) E.db.datatexts.currencies.displayStyle = value DT:LoadDataTexts() end,
					disabled = function() return (E.db.datatexts.currencies.displayedCurrency == "GOLD") end,
					values = {
						["ICON"] = L["Icons Only"],
						["ICON_TEXT"] = L["Icons and Text"],
						["ICON_TEXT_ABBR"] = L["Icons and Text (Short)"]
					}
				}
			}
		},
		customCurrency = {
			order = 8,
			type = "group",
			name = L["Custom Currency"],
			args = {
				description = {
					order = 2,
					type = "description",
					name = L["This allows you to create a new datatext which will track the currency with the supplied currency ID. The datatext can be added to a panel immediately after creation."]
				},
				addCustomCurrency = {
					order = 3,
					type = "input",
					name = L["Add Currency ID"],
					desc = "http://www.wowhead.com/currencies",
					get = function() return "" end,
					set = function(info, value)
						local currencyID = tonumber(value)
						if not currencyID then return end
						DT:RegisterCustomCurrencyDT(currencyID)
						CreateCustomCurrencyOptions(currencyID)
						DT:PanelLayoutOptions()
						DT:LoadDataTexts()
					end
				},
				spacer = {
					order = 4,
					type = "description",
					name = "\n"
				},
				currencies = {
					order = 5,
					type = "group",
					name = L["Custom Currencies"],
					args = {}
				}
			}
		}
	}
}

DT:PanelLayoutOptions()
SetupCustomCurrencies()