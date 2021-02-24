local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(select(2, ...))
local B = E:GetModule("Bags")

local _G = _G
local gsub, match = string.gsub, string.match

local GameTooltip = _G["GameTooltip"]

E.Options.args.bags = {
	order = 2,
	type = "group",
	name = L["BAGSLOT"],
	childGroups = "tab",
	get = function(info) return E.db.bags[info[#info]] end,
	set = function(info, value) E.db.bags[info[#info]] = value end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["BAGS_DESC"]
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["ENABLE"],
			desc = L["Enable/Disable the all-in-one bag."],
			get = function(info) return E.private.bags.enable end,
			set = function(info, value) E.private.bags.enable = value E:StaticPopup_Show("PRIVATE_RL") end
		},
		general = {
			order = 3,
			type = "group",
			name = L["General"],
			disabled = function() return not E.Bags.Initialized end,
			args = {
				strata = {
					order = 1,
					type = "select",
					name = L["Frame Strata"],
					set = function(info, value) E.db.bags[info[#info]] = value E:StaticPopup_Show("CONFIG_RL") end,
					values = C.Values.Strata
				},
				currencyFormat = {
					order = 2,
					type = "select",
					name = L["Currency Format"],
					desc = L["The display format of the currency icons that get displayed below the main bag. (You have to be watching a currency for this to display)"],
					values = {
						ICON = L["Icons Only"],
						ICON_TEXT = L["Icons and Text"],
						ICON_TEXT_ABBR = L["Icons and Text (Short)"]
					},
					set = function(info, value) E.db.bags[info[#info]] = value B:UpdateTokens() end
				},
				moneyFormat = {
					order = 3,
					type = "select",
					name = L["Money Format"],
					desc = L["The display format of the money text that is shown at the top of the main bag."],
					values = {
						SMART = L["Smart"],
						FULL = L["Full"],
						SHORT = L["SHORT"],
						SHORTINT = L["Short (Whole Numbers)"],
						CONDENSED = L["Condensed"],
						BLIZZARD = L["Blizzard Style"]
					},
					set = function(info, value) E.db.bags[info[#info]] = value B:UpdateGoldText() end
				},
				spacer = {
					order = 4,
					type = "description",
					name = ""
				},
				moneyCoins = {
					order = 5,
					type = "toggle",
					name = L["Show Coins"],
					desc = L["Use coin icons instead of colored text."],
					set = function(info, value) E.db.bags[info[#info]] = value B:UpdateGoldText() end
				},
				transparent = {
					order = 6,
					type = "toggle",
					name = L["Transparent Buttons"],
					set = function(info, value) E.db.bags[info[#info]] = value E:StaticPopup_Show("CONFIG_RL") end
				},
				questIcon = {
					order = 7,
					type = "toggle",
					name = L["Show Quest Icon"],
					desc = L["Display an exclamation mark on items that starts a quest."],
					set = function(info, value) E.db.bags[info[#info]] = value B:UpdateAllBagSlots() end
				},
				junkIcon = {
					order = 8,
					type = "toggle",
					name = L["Show Junk Icon"],
					desc = L["Display the junk icon on all grey items that can be vendored."],
					set = function(info, value) E.db.bags[info[#info]] = value B:UpdateAllBagSlots() end
				},
				junkDesaturate = {
					order = 9,
					type = "toggle",
					name = L["Desaturate Junk Items"],
					set = function(info, value) E.db.bags[info[#info]] = value B:UpdateAllBagSlots() end
				},
				newItemGlow = {
					order = 10,
					type = "toggle",
					name = L["Show New Item Glow"],
					desc = L["Display the New Item Glow"],
					set = function(info, value) E.db.bags[info[#info]] = value B:UpdateAllBagSlots() end
				},
				qualityColors = {
					order = 11,
					type = "toggle",
					name = L["Show Quality Color"],
					desc = L["Colors the border according to the Quality of the Item."],
					set = function(info, value) E.db.bags[info[#info]] = value B:UpdateAllBagSlots() end
				},
				showBindType = {
					order = 12,
					type = "toggle",
					name = L["Show Bind on Equip/Use Text"],
					set = function(info, value) E.db.bags[info[#info]] = value B:UpdateAllBagSlots() end
				},
				battlePetIcon = {
					order = 13,
					type = "toggle",
					name = L["Show Battle Pet Icon"],
					set = function(info, value) E.db.bags[info[#info]] = value B:UpdateAllBagSlots() end
				},
				upgradeIcon = {
					order = 14,
					type = "toggle",
					name = L["Show Upgrade Icon"],
					desc = L["Display the upgrade icon on items that WoW considers an upgrade for your character."],
					set = function(info, value) E.db.bags[info[#info]] = value B:UpdateAllBagSlots() end
				},
				clearSearchOnClose = {
 					order = 15,
					type = "toggle",
					name = L["Clear Search On Close"],
					set = function(info, value) E.db.bags[info[#info]] = value end
				},
				reverseSlots = {
					order = 16,
					type = "toggle",
					name = L["Reverse Bag Slots"],
					set = function(info, value) E.db.bags[info[#info]] = value B:UpdateAll() B:UpdateTokens() end
				},
				disableBagSort = {
 					order = 17,
					type = "toggle",
					name = L["Disable Bag Sort"],
					set = function(info, value) E.db.bags[info[#info]] = value B:ToggleSortButtonState(false) end
				},
				disableBankSort = {
					order = 18,
					type = "toggle",
					name = L["Disable Bank Sort"],
					set = function(info, value) E.db.bags[info[#info]] = value B:ToggleSortButtonState(true) end
				},
				sizeGroup = {
					order = 19,
					type = "group",
					name = L["Size"],
					args = {
						player = {
							order = 1,
							type = "group",
							name = L["BAGSLOT"],
							guiInline = true,
							set = function(info, value) E.db.bags[info[#info]] = value B:Layout() end,
							args = {
								bagSize = {
									order = 1,
									type = "range",
									name = L["Button Size"],
									desc = L["The size of the individual buttons on the bag frame."],
									min = 15, max = 45, step = 1
								},
								bagButtonSpacing = {
									order = 2,
									type = "range",
									name = L["Button Spacing"],
									min = -1, max = 20, step = 1
								},
								bagWidth = {
									order = 3,
									type = "range",
									name = L["Panel Width"],
									desc = L["Adjust the width of the bag frame."],
									min = 150, max = 1400, step = 1
								}
							}
						},
						bank = {
							order = 2,
							type = "group",
							name = L["Bank"],
							guiInline = true,
							set = function(info, value) E.db.bags[info[#info]] = value B:Layout(true) end,
							args = {
								bankSize = {
									order = 1,
									type = "range",
									name = L["Button Size"],
									desc = L["The size of the individual buttons on the bank frame."],
									min = 15, max = 45, step = 1
								},
								bankButtonSpacing = {
									order = 2,
									type = "range",
									name = L["Button Spacing"],
									min = -1, max = 20, step = 1
								},
								bankWidth = {
									order = 3,
									type = "range",
									name = L["Panel Width"],
									desc = L["Adjust the width of the bank frame."],
									min = 150, max = 1400, step = 1
								}
							}
						}
					}
				},
				split = {
					order = 20,
					type = "group",
					name = L["Split"],
					args = {
						splitbags = {
							order = 1,
							type = "group",
							name = L["PLAYER"],
							get = function(info) return E.db.bags.split[info[#info]] end,
							set = function(info, value) E.db.bags.split[info[#info]] = value B:Layout() end,
							disabled = function() return not E.db.bags.split.player end,
							guiInline = true,
							args = {
								player = {
									order = 1,
									type = "toggle",
									name = L["ENABLE"],
									disabled = false
								},
								bagSpacing = {
									order = 2,
									type = "range",
									name = L["Bag Spacing"],
									min = -2, max = 20, step = 1
								},
								spacer = {
									order = 3,
									type = "description",
									name = ""
								},
								bag1 = {
									order = 4,
									type = "toggle",
									name = L["Bag 1"]
								},
								bag2 = {
									order = 5,
									type = "toggle",
									name = L["Bag 2"]
								},
								bag3 = {
									order = 6,
									type = "toggle",
									name = L["Bag 3"]
								},
								bag4 = {
									order = 7,
									type = "toggle",
									name = L["Bag 4"]
								}
							}
						},
						splitbank = {
							order = 2,
							type = "group",
							name = L["Bank"],
							get = function(info) return E.db.bags.split[info[#info]] end,
							set = function(info, value) E.db.bags.split[info[#info]] = value B:Layout(true) end,
							disabled = function() return not E.db.bags.split.bank end,
							guiInline = true,
							args = {
								bank = {
									order = 1,
									type = "toggle",
									name = L["ENABLE"],
									disabled = false
								},
								bankSpacing = {
									order = 2,
									type = "range",
									name = L["Bank Spacing"],
									min = -2, max = 20, step = 1
								},
								spacer = {
									order = 3,
									type = "description",
									name = ""
								},
								bag5 = {
									order = 4,
									type = "toggle",
									name = L["Bank 1"]
								},
								bag6 = {
									order = 5,
									type = "toggle",
									name = L["Bank 2"]
								},
								bag7 = {
									order = 6,
									type = "toggle",
									name = L["Bank 3"]
								},
								bag8 = {
									order = 7,
									type = "toggle",
									name = L["Bank 4"]
								},
								bag9 = {
									order = 8,
									type = "toggle",
									name = L["Bank 5"]
								},
								bag10 = {
									order = 9,
									type = "toggle",
									name = L["Bank 6"]
								},
								bag11 = {
									order = 10,
									type = "toggle",
									name = L["Bank 7"]
								}
							}
						}
					}
				},
				countGroup = {
					order = 21,
					type = "group",
					name = L["Item Count"],
					args = {
						countFont = {
							order = 1,
							type = "select",
							dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
							set = function(info, value) E.db.bags.countFont = value B:UpdateCountDisplay() end
						},
						countFontSize = {
							order = 2,
							type = "range",
							name = L["FONT_SIZE"],
							min = 4, max = 22, step = 1,
							set = function(info, value) E.db.bags.countFontSize = value B:UpdateCountDisplay() end
						},
						countFontOutline = {
							order = 3,
							type = "select",
							name = L["Font Outline"],
							set = function(info, value) E.db.bags.countFontOutline = value B:UpdateCountDisplay() end,
							values = C.Values.FontFlags
						},
						countFontColor = {
							order = 4,
							type = "color",
							name = L["COLOR"],
							get = function(info)
								local t = E.db.bags[info[#info]]
								local d = P.bags[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.bags[info[#info]]
								t.r, t.g, t.b = r, g, b
								B:UpdateCountDisplay()
							end
						}
					}
				},
				itemLevelGroup = {
					order = 22,
					type = "group",
					name = L["Item Level"],
					args = {
						itemLevel = {
							order = 1,
							type = "toggle",
							name = L["Display Item Level"],
							desc = L["Displays item level on equippable items."],
							set = function(info, value) E.db.bags.itemLevel = value B:UpdateItemLevelDisplay() end
						},
						spacer = {
							order = 2,
							type = "description",
							name = ""
						},
						itemLevelFont = {
							order = 3,
							type = "select",
							dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
							disabled = function() return not E.db.bags.itemLevel end,
							set = function(info, value) E.db.bags.itemLevelFont = value B:UpdateItemLevelDisplay() end
						},
						itemLevelFontSize = {
							order = 4,
							type = "range",
							name = L["FONT_SIZE"],
							min = 6, max = 22, step = 1,
							disabled = function() return not E.db.bags.itemLevel end,
							set = function(info, value) E.db.bags.itemLevelFontSize = value B:UpdateItemLevelDisplay() end
						},
						itemLevelFontOutline = {
							order = 5,
							type = "select",
							name = L["Font Outline"],
							disabled = function() return not E.db.bags.itemLevel end,
							set = function(info, value) E.db.bags.itemLevelFontOutline = value B:UpdateItemLevelDisplay() end,
							values = C.Values.FontFlags
						},
						itemLevelCustomColorEnable = {
							order = 6,
							type = "toggle",
							name = L["Enable Custom Color"],
							disabled = function() return not E.db.bags.itemLevel end,
							set = function(info, value) E.db.bags.itemLevelCustomColorEnable = value B:UpdateItemLevelDisplay() end
						},
						itemLevelCustomColor = {
							order = 7,
							type = "color",
							name = L["Custom Color"],
							disabled = function() return not E.db.bags.itemLevel or not E.db.bags.itemLevelCustomColorEnable end,
							get = function(info)
								local t = E.db.bags.itemLevelCustomColor
								local d = P.bags.itemLevelCustomColor
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.bags.itemLevelCustomColor
								t.r, t.g, t.b = r, g, b
								B:UpdateItemLevelDisplay()
							end
						},
						itemLevelThreshold = {
							order = 8,
							type = "range",
							name = L["Item Level Threshold"],
							desc = L["The minimum item level required for it to be shown."],
							min = 1, max = 616, step = 1,
							disabled = function() return not E.db.bags.itemLevel end,
							set = function(info, value) E.db.bags.itemLevelThreshold = value B:UpdateItemLevelDisplay() end
						}
					}
				}
			}
		},
		colorGroup = {
			order = 4,
			type = "group",
			name = L["COLORS"],
			args = {
				profession = {
					order = 2,
					type = "group",
					name = L["Profession Bags"],
					guiInline = true,
					get = function(info)
						local t = E.db.bags.colors.profession[info[#info]]
						local d = P.bags.colors.profession[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.bags.colors.profession[info[#info]]
						t.r, t.g, t.b = r, g, b
						if not E.Bags.Initialized then return end
						B:UpdateBagColors("ProfessionColors", info[#info], r, g, b)
						B:UpdateAllBagSlots()
					end,
					args = {
						professionBagColors = {
							order = 1,
							type = "toggle",
							name = L["ENABLE"],
							get = function(info) return E.db.bags[info[#info]] end,
							set = function(info, value)
								E.db.bags[info[#info]] = value
								if not E.Bags.Initialized then return end
								B:UpdateAllBagSlots()
							end
						},
						professionBagColorsStyle = {
							order = 2,
							type = "select",
							name = L["Style"],
							values = {
								BACKDROP = L["Backdrop"],
								BORDER = L["Border"],
								BOTH = L["Both"]
							},
							get = function(info) return E.db.bags[info[#info]] end,
							set = function(info, value)
								E.db.bags[info[#info]] = value
								if not E.Bags.Initialized then return end
								B:UpdateAllBagSlots()
							end,
							disabled = function() return not E.db.bags.professionBagColors end
						},
						professionBagColorsMult = {
							order = 3,
							type = "range",
							name = L["Backdrop Multiplier"],
							min = 0.10, max = 0.75, step = 0.01,
							get = function(info) return E.db.bags[info[#info]] end,
							set = function(info, value)
								E.db.bags[info[#info]] = value
								if not E.Bags.Initialized then return end
								B:UpdateAllBagSlots()
							end,
							disabled = function() return not E.db.bags.professionBagColors or E.db.bags.professionBagColorsStyle == "BORDER" end
						},
						spacer = {
							order = 4,
							type = "description",
							name = ""
						},
						leatherworking = {
							order = 5,
							type = "color",
							name = L["Leatherworking"],
							disabled = function() return not E.db.bags.professionBagColors end
						},
						inscription = {
							order = 6,
							type = "color",
							name = L["INSCRIPTION"],
							disabled = function() return not E.db.bags.professionBagColors end
						},
						herbs = {
							order = 7,
							type = "color",
							name = L["Herbalism"],
							disabled = function() return not E.db.bags.professionBagColors end
						},
						enchanting = {
							order = 8,
							type = "color",
							name = L["Enchanting"],
							disabled = function() return not E.db.bags.professionBagColors end
						},
						engineering = {
							order = 9,
							type = "color",
							name = L["Engineering"],
							disabled = function() return not E.db.bags.professionBagColors end
						},
						gems = {
							order = 10,
							type = "color",
							name = L["Gems"],
							disabled = function() return not E.db.bags.professionBagColors end
						},
						mining = {
							order = 11,
							type = "color",
							name = L["Mining"],
							disabled = function() return not E.db.bags.professionBagColors end
						},
						fishing = {
							order = 12,
							type = "color",
							name = L["PROFESSIONS_FISHING"],
							disabled = function() return not E.db.bags.professionBagColors end
						},
						cooking = {
							order = 13,
							type = "color",
							name = L["PROFESSIONS_COOKING"],
							disabled = function() return not E.db.bags.professionBagColors end
						}
					}
				},
				items = {
					order = 3,
					type = "group",
					name = L["ITEMS"],
					guiInline = true,
					get = function(info)
						local t = E.db.bags.colors.items[info[#info]]
						local d = P.bags.colors.items[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.bags.colors.items[info[#info]]
						t.r, t.g, t.b = r, g, b
						if not E.Bags.Initialized then return end
						B:UpdateQuestColors("QuestColors", info[#info], r, g, b)
						B:UpdateAllBagSlots()
					end,
					args = {
						questItemColors = {
							order = 1,
							type = "toggle",
							name = L["ENABLE"],
							get = function(info) return E.db.bags[info[#info]] end,
							set = function(info, value)
								E.db.bags[info[#info]] = value
								if not E.Bags.Initialized then return end
								B:UpdateAllBagSlots()
							end
						},
						spacer = {
							order = 2,
							type = "description",
							name = ""
						},
						questStarter = {
							order = 3,
							type = "color",
							name = L["Quest Starter"],
							disabled = function() return not E.db.bags.questItemColors end
						},
						questItem = {
							order = 4,
							type = "color",
							name = L["ITEM_BIND_QUEST"],
							disabled = function() return not E.db.bags.questItemColors end
						}
					}
				}
			}
		},
		bagBar = {
			order = 5,
			type = "group",
			name = L["Bag-Bar"],
			get = function(info) return E.db.bags.bagBar[info[#info]] end,
			set = function(info, value) E.db.bags.bagBar[info[#info]] = value B:SizeAndPositionBagBar() end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"],
					desc = L["Enable/Disable the Bag-Bar."],
					get = function(info) return E.private.bags.bagBar end,
					set = function(info, value) E.private.bags.bagBar = value E:StaticPopup_Show("PRIVATE_RL") end
				},
				spacer = {
					order = 2,
					type = "description",
					name = ""
				},
				mouseover = {
					order = 3,
					type = "toggle",
					name = L["Mouse Over"],
					desc = L["The frame is not shown unless you mouse over the frame."],
					disabled = function() return not E.private.bags.bagBar end
				},
				showBackdrop = {
					order = 4,
					type = "toggle",
					name = L["Backdrop"],
					disabled = function() return not E.private.bags.bagBar end
				},
				transparent = {
					order = 5,
					type = "toggle",
					name = L["Transparent Backdrop"],
					disabled = function() return not E.private.bags.bagBar or not E.db.bags.bagBar.showBackdrop end
				},
				justBackpack = {
					order = 6,
					type = "toggle",
					name = L["Backpack Only"],
					disabled = function() return not E.private.bags.bagBar end
				},
				sortDirection = {
					order = 7,
					type = "select",
					name = L["Sort Direction"],
					desc = L["The direction that the bag frames will grow from the anchor."],
					values = {
						ASCENDING = L["Ascending"],
						DESCENDING = L["Descending"]
					},
					disabled = function() return not E.private.bags.bagBar end
				},
				size = {
					order = 8,
					type = "range",
					name = L["Button Size"],
					desc = L["Set the size of your bag buttons."],
					min = 24, max = 60, step = 1,
					disabled = function() return not E.private.bags.bagBar end
				},
				spacing = {
					order = 9,
					type = "range",
					name = L["Button Spacing"],
					desc = L["The spacing between buttons."],
					min = -1, max = 10, step = 1,
					disabled = function() return not E.private.bags.bagBar or E.db.bags.bagBar.justBackpack end
				},
				backdropSpacing = {
					order = 10,
					type = "range",
					name = L["Backdrop Spacing"],
					desc = L["The spacing between the backdrop and the buttons."],
					min = -1, max = 10, step = 1,
					disabled = function() return not E.private.bags.bagBar end
				},
				growthDirection = {
					order = 11,
					type = "select",
					name = L["Bar Direction"],
					desc = L["The direction that the bag frames be (Horizontal or Vertical)."],
					values = {
						VERTICAL = L["Vertical"],
						HORIZONTAL = L["Horizontal"]
					},
					disabled = function() return not E.private.bags.bagBar end
				},
				visibility = {
					order = 12,
					type = "input",
					name = L["Visibility State"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
					width = "full",
					multiline = true,
					set = function(info, value)
						if value and value:match("[\n\r]") then
							value = value:gsub("[\n\r]", "")
						end
						E.db.bags.bagBar.visibility = value
						B:SizeAndPositionBagBar()
					end,
					disabled = function() return not E.private.bags.bagBar end
				}
			}
		},
		vendorGrays = {
			order = 6,
			type = "group",
			name = L["Vendor Grays"],
			get = function(info) return E.db.bags.vendorGrays[info[#info]] end,
			set = function(info, value) E.db.bags.vendorGrays[info[#info]] = value B:UpdateSellFrameSettings() end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Auto Vendor Junk"],
					desc = L["Automatically vendor gray items when visiting a vendor."]
				},
				details = {
					order = 2,
					type = "toggle",
					name = L["Vendor Gray Detailed Report"],
					desc = L["Displays a detailed report of every item sold when enabled."]
				},
				progressBar = {
					order = 3,
					type = "toggle",
					name = L["Progress Bar"]
				},
				interval = {
					order = 4,
					type = "range",
					name = L["Sell Interval"],
					desc = L["Will attempt to sell another item in set interval after previous one was sold."],
					min = 0.1, max = 1, step = 0.1
				}
			}
		},
		bagSortingGroup = {
			order = 7,
			type = "group",
			name = L["Bag Sorting"],
			disabled = function() return not E.Bags.Initialized end,
			args = {
				sortInverted = {
					order = 1,
					type = "toggle",
					name = L["Sort Inverted"],
					desc = L["Direction the bag sorting will use to allocate the items."]
				},
				spacer = {
					order = 2,
					type = "description",
					name = " "
				},
				description = {
					order = 3,
					type = "description",
					name = L["Here you can add items or search terms that you want to be excluded from sorting. To remove an item just click on its name in the list."]
				},
				addEntryGroup = {
					order = 4,
					type = "group",
					name = L["Add Item or Search Syntax"],
					guiInline = true,
					args = {
						addEntryProfile = {
							order = 1,
							type = "input",
							name = L["Profile"],
							desc = L["Add an item or search syntax to the ignored list. Items matching the search syntax will be ignored."],
							get = function(info) return "" end,
							set = function(info, value)
								if value == "" or gsub(value, "%s+", "") == "" then return end --Don't allow empty entries
								--Store by itemID if possible
								local itemID = match(value, "item:(%d+)")
								E.db.bags.ignoredItems[(itemID or value)] = value
							end
						},
						spacer = {
							order = 2,
							type = "description",
							name = " ",
							width = "normal"
						},
						addEntryGlobal = {
							order = 3,
							type = "input",
							name = L["Global"],
							desc = L["Add an item or search syntax to the ignored list. Items matching the search syntax will be ignored."],
							get = function(info) return "" end,
							set = function(info, value)
								if value == "" or gsub(value, "%s+", "") == "" then return end --Don't allow empty entries
								--Store by itemID if possible
								local itemID = match(value, "item:(%d+)")
								E.global.bags.ignoredItems[(itemID or value)] = value
								--Remove from profile list if we just added the same item to global list
								if E.db.bags.ignoredItems[(itemID or value)] then
									E.db.bags.ignoredItems[(itemID or value)] = nil
								end
							end
						}
					}
				},
				ignoredEntriesProfile = {
					order = 5,
					type = "multiselect",
					name = L["Ignored Items and Search Syntax (Profile)"],
					values = function() return E.db.bags.ignoredItems end,
					get = function(info, value)	return E.db.bags.ignoredItems[value] end,
					set = function(info, value)
						E.db.bags.ignoredItems[value] = nil
						GameTooltip:Hide() --Make sure tooltip is properly hidden
					end
				},
				ignoredEntriesGlobal = {
					order = 6,
					type = "multiselect",
					name = L["Ignored Items and Search Syntax (Global)"],
					values = function() return E.global.bags.ignoredItems end,
					get = function(info, value)	return E.global.bags.ignoredItems[value] end,
					set = function(info, value)
						E.global.bags.ignoredItems[value] = nil
						GameTooltip:Hide() --Make sure tooltip is properly hidden
					end
				}
			}
		},
		search_syntax = {
			order = 8,
			type = "group",
			name = L["Search Syntax"],
			disabled = function() return not E.Bags.Initialized end,
			args = {
				text = {
					order = 1,
					type = "input",
					multiline = 26,
					width = "full",
					name = "",
					get = function(info) return L["SEARCH_SYNTAX_DESC"] end,
					set = E.noop
				}
			}
		}
	}
}