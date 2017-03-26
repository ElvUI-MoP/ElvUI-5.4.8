local E, L, V, P, G = unpack(ElvUI);
local AB = E:GetModule("ActionBars");
local group;

local points = {
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
}

local function BuildABConfig()
	for i = 1, 6 do
		local name = L["Bar "] .. i;
		group["bar" .. i] = {
			order = 200,
			name = name,
			type = "group",
			guiInline = false,
			disabled = function() return not E.private.actionbar.enable; end,
			get = function(info) return E.db.actionbar["bar" .. i][ info[#info] ]; end,
			set = function(info, value) E.db.actionbar["bar" .. i][ info[#info] ] = value; AB:PositionAndSizeBar("bar" .. i); end,
			args = {
				info = {
					order = 1,
					type = "header",
					name = name
				},
				enabled = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value)
						E.db.actionbar["bar" .. i][ info[#info] ] = value;
						AB:PositionAndSizeBar("bar" .. i);
					end
				},
				restorePosition = {
					order = 3,
					type = "execute",
					name = L["Restore Bar"],
					desc = L["Restore the actionbars default settings"],
					func = function() E:CopyTable(E.db.actionbar["bar" .. i], P.actionbar["bar" .. i]); E:ResetMovers(L["Bar " .. i]); AB:PositionAndSizeBar("bar" .. i); end,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				},
				spacer = {
					order = 4,
					type = "description",
					name = " ",
				},
				point = {
					order = 5,
					type = "select",
					name = L["Anchor Point"],
					desc = L["The first button anchors itself to this point on the bar."],
 					values = points,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				},
				backdrop = {
					order = 6,
					type = "toggle",
					name = L["Backdrop"],
					desc = L["Toggles the display of the actionbars backdrop."],
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				},
				flyoutDirection = {
 					order = 7,
 					type = "select",
 					name = L["Flyout Direction"],
 					set = function(info, value) E.db.actionbar["bar"..i][ info[#info] ] = value; AB:PositionAndSizeBar("bar"..i); AB:UpdateButtonSettingsForBar("bar"..i) end,
 					values = {
 						["UP"] = L["Up"],
 						["DOWN"] = L["Down"],
 						["LEFT"] = L["Left"],
 						["RIGHT"] = L["Right"],
 						["AUTOMATIC"] = L["Automatic"]
 					},
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				},
				showGrid = {
					order = 8,
					type = "toggle",
					name = L["Show Empty Buttons"],
					set = function(info, value) E.db.actionbar["bar" .. i][ info[#info] ] = value; AB:UpdateButtonSettingsForBar("bar"..i); end,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				},
				mouseover = {
					order = 9,
					type = "toggle",
					name = L["Mouse Over"],
					desc = L["The frame is not shown unless you mouse over the frame."],
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				},
				inheritGlobalFade = {
 					order = 10,
					type = "toggle",
					name = L["Inherit Global Fade"],
					desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."],
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				},
				buttons = {
					order = 11,
					type = "range",
					name = L["Buttons"],
					desc = L["The amount of buttons to display."],
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				},
				buttonsPerRow = {
					order = 12,
					type = "range",
					name = L["Buttons Per Row"],
					desc = L["The amount of buttons to display per row."],
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				},
				buttonsize = {
					order = 13,
					type = "range",
					name = L["Button Size"],
					desc = L["The size of the action buttons."],
					min = 15, max = 60, step = 1,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				},
				buttonspacing = {
					order = 14,
					type = "range",
					name = L["Button Spacing"],
					desc = L["The spacing between buttons."],
					min = -1, max = 10, step = 1,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				},
				backdropSpacing = {
					order = 15,
					type = "range",
					name = L["Backdrop Spacing"],
					desc = L["The spacing between the backdrop and the buttons."],
					min = 0, max = 10, step = 1,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				},
				heightMult = {
					order = 16,
					type = "range",
					name = L["Height Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				},
				widthMult = {
					order = 17,
					type = "range",
					name = L["Width Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				},
				alpha = {
					order = 18,
					type = "range",
					name = L["Alpha"],
					isPercent = true,
					min = 0, max = 1, step = 0.01,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				},
				paging = {
					order = 19,
					type = "input",
					name = L["Action Paging"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to page differently.\n Example: [combat] 2;"],
					width = "full",
					multiline = true,
					get = function(info) return E.db.actionbar["bar" .. i]["paging"][E.myclass]; end,
					set = function(info, value)
						if(not E.db.actionbar["bar" .. i]["paging"][E.myclass]) then
							E.db.actionbar["bar" .. i]["paging"][E.myclass] = {};
						end
						E.db.actionbar["bar" .. i]["paging"][E.myclass] = value;
						AB:UpdateButtonSettings();
					end,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				},
				visibility = {
					order = 20,
					type = "input",
					name = L["Visibility State"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: [combat] show;hide"],
					width = "full",
					multiline = true,
					set = function(info, value)
						E.db.actionbar["bar" ..i]["visibility"] = value;
						AB:UpdateButtonSettings();
					end,
					disabled = function() return not E.db.actionbar["bar" .. i].enabled; end
				}
			}
		};

		if(i == 6) then
			group["bar" .. i].args.enabled.set = function(info, value)
				E.db.actionbar["bar"..i].enabled = value;
				AB:PositionAndSizeBar("bar6");
				AB:UpdateBar1Paging();
				AB:PositionAndSizeBar("bar1");
			end
		end
	end

	group["barPet"] = {
		order = 300,
		name = L["Pet Bar"],
		type = "group",
		guiInline = false,
		disabled = function() return not E.private.actionbar.enable end,
		get = function(info) return E.db.actionbar["barPet"][ info[#info] ] end,
		set = function(info, value) E.db.actionbar["barPet"][ info[#info] ] = value; AB:PositionAndSizeBarPet() end,
		args = {
			info = {
				order = 1,
				type = "header",
				name = L["Pet Bar"]
			},
			enabled = {
				order = 2,
				type = "toggle",
				name = L["Enable"]
			},
			restorePosition = {
				order = 3,
				type = "execute",
				name = L["Restore Bar"],
				desc = L["Restore the actionbars default settings"],
				func = function() E:CopyTable(E.db.actionbar["barPet"], P.actionbar["barPet"]); E:ResetMovers(L["Pet Bar"]); AB:PositionAndSizeBarPet() end,
				disabled = function() return not E.db.actionbar.barPet.enabled; end
			},
			point = {
				order = 4,
				type = "select",
				name = L["Anchor Point"],
				desc = L["The first button anchors itself to this point on the bar."],
				values = points,
				disabled = function() return not E.db.actionbar.barPet.enabled; end
			},
			backdrop = {
				order = 5,
				type = "toggle",
				name = L["Backdrop"],
				desc = L["Toggles the display of the actionbars backdrop."],
				disabled = function() return not E.db.actionbar.barPet.enabled; end
			},
			mouseover = {
				order = 6,
				name = L["Mouse Over"],
				desc = L["The frame is not shown unless you mouse over the frame."],
				type = "toggle",
				disabled = function() return not E.db.actionbar.barPet.enabled; end
			},
			inheritGlobalFade = {
 				order = 7,
				type = "toggle",
				name = L["Inherit Global Fade"],
				desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."],
				disabled = function() return not E.db.actionbar.barPet.enabled; end
			},
			buttons = {
				order = 8,
				type = "range",
				name = L["Buttons"],
				desc = L["The amount of buttons to display."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
				disabled = function() return not E.db.actionbar.barPet.enabled; end
			},
			buttonsPerRow = {
				order = 9,
				type = "range",
				name = L["Buttons Per Row"],
				desc = L["The amount of buttons to display per row."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
				disabled = function() return not E.db.actionbar.barPet.enabled; end
			},
			buttonsize = {
				order = 10,
				type = "range",
				name = L["Button Size"],
				desc = L["The size of the action buttons."],
				min = 15, max = 60, step = 1,
				disabled = function() return not E.db.actionbar.barPet.enabled; end
			},
			buttonspacing = {
				order = 11,
				type = "range",
				name = L["Button Spacing"],
				desc = L["The spacing between buttons."],
				min = -1, max = 10, step = 1,
				disabled = function() return not E.db.actionbar.barPet.enabled; end
			},
			backdropSpacing = {
				order = 12,
				type = "range",
				name = L["Backdrop Spacing"],
				desc = L["The spacing between the backdrop and the buttons."],
				min = 0, max = 10, step = 1,
				disabled = function() return not E.db.actionbar.barPet.enabled; end
			},
			heightMult = {
				order = 13,
				type = "range",
				name = L["Height Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
				disabled = function() return not E.db.actionbar.barPet.enabled; end
			},
			widthMult = {
				order = 14,
				type = "range",
				name = L["Width Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
				disabled = function() return not E.db.actionbar.barPet.enabled; end
			},
			alpha = {
				order = 15,
				type = "range",
				name = L["Alpha"],
				isPercent = true,
				min = 0, max = 1, step = 0.01,
				disabled = function() return not E.db.actionbar.barPet.enabled; end
			},
			visibility = {
				type = "input",
				order = 16,
				name = L["Visibility State"],
				desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: [combat] show;hide"],
				width = "full",
				multiline = true,
				set = function(info, value)
					E.db.actionbar["barPet"]["visibility"] = value;
					AB:UpdateButtonSettings()
				end,
				disabled = function() return not E.db.actionbar.barPet.enabled; end
			}
		}
	}
	group["stanceBar"] = {
		order = 400,
		name = L["Stance Bar"],
		type = "group",
		guiInline = false,
		disabled = function() return not E.private.actionbar.enable end,
		get = function(info) return E.db.actionbar["stanceBar"][ info[#info] ] end,
		set = function(info, value) E.db.actionbar["stanceBar"][ info[#info] ] = value; AB:PositionAndSizeBarShapeShift() end,
		args = {
			info = {
				order = 1,
				type = "header",
				name = L["Stance Bar"]
			},
			enabled = {
				order = 2,
				type = "toggle",
				name = L["Enable"]
			},
			restorePosition = {
				order = 3,
				type = "execute",
				name = L["Restore Bar"],
				desc = L["Restore the actionbars default settings"],
				func = function() E:CopyTable(E.db.actionbar["stanceBar"], P.actionbar["stanceBar"]); E:ResetMovers(L["Stance Bar"]); AB:PositionAndSizeBarShapeShift() end,
				disabled = function() return not E.db.actionbar.stanceBar.enabled; end
			},
			point = {
				order = 4,
				type = "select",
				name = L["Anchor Point"],
				desc = L["The first button anchors itself to this point on the bar."],
				values = points,
				disabled = function() return not E.db.actionbar.stanceBar.enabled; end
			},
			backdrop = {
				order = 5,
				type = "toggle",
				name = L["Backdrop"],
				desc = L["Toggles the display of the actionbars backdrop."],
				disabled = function() return not E.db.actionbar.stanceBar.enabled; end
			},
			mouseover = {
				order = 6,
				type = "toggle",
				name = L["Mouse Over"],
				desc = L["The frame is not shown unless you mouse over the frame."],
				disabled = function() return not E.db.actionbar.stanceBar.enabled; end
			},
			inheritGlobalFade = {
 				order = 8,
				type = "toggle",
				name = L["Inherit Global Fade"],
				desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."],
				disabled = function() return not E.db.actionbar.stanceBar.enabled; end
			},
			buttons = {
				order = 9,
				type = "range",
				name = L["Buttons"],
				desc = L["The amount of buttons to display."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
				disabled = function() return not E.db.actionbar.stanceBar.enabled; end
			},
			buttonsPerRow = {
				order = 10,
				type = "range",
				name = L["Buttons Per Row"],
				desc = L["The amount of buttons to display per row."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
				disabled = function() return not E.db.actionbar.stanceBar.enabled; end
			},
			buttonsize = {
				order = 11,
				type = "range",
				name = L["Button Size"],
				desc = L["The size of the action buttons."],
				min = 15, max = 60, step = 1,
				disabled = function() return not E.db.actionbar.stanceBar.enabled; end
			},
			buttonspacing = {
				order = 12,
				type = "range",
				name = L["Button Spacing"],
				desc = L["The spacing between buttons."],
				min = -1, max = 10, step = 1,
				disabled = function() return not E.db.actionbar.stanceBar.enabled; end
			},
			backdropSpacing = {
				order = 13,
				type = "range",
				name = L["Backdrop Spacing"],
				desc = L["The spacing between the backdrop and the buttons."],
				min = 0, max = 10, step = 1,
				disabled = function() return not E.db.actionbar.stanceBar.enabled; end
			},
			heightMult = {
				order = 14,
				type = "range",
				name = L["Height Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
				disabled = function() return not E.db.actionbar.stanceBar.enabled; end
			},
			widthMult = {
				order = 15,
				type = "range",
				name = L["Width Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
				disabled = function() return not E.db.actionbar.stanceBar.enabled; end
			},
			alpha = {
				order = 16,
				type = "range",
				name = L["Alpha"],
				isPercent = true,
				min = 0, max = 1, step = 0.01,
				disabled = function() return not E.db.actionbar.stanceBar.enabled; end
			},
			style = {
				order = 17,
				type = "select",
				name = L["Style"],
				desc = L["This setting will be updated upon changing stances."],
				values = {
					["darkenInactive"] = L["Darken Inactive"],
					["classic"] = L["Classic"]
				},
				disabled = function() return not E.db.actionbar.stanceBar.enabled; end
			}
		}
	}
end

E.Options.args.actionbar = {
	type = "group",
	name = L["ActionBars"],
	childGroups = "tree",
	get = function(info) return E.db.actionbar[ info[#info] ] end,
	set = function(info, value) E.db.actionbar[ info[#info] ] = value; AB:UpdateButtonSettings() end,
	args = {
		info = {
			order = 1,
			type = "header",
			name = L["ActionBars"]
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.actionbar[ info[#info] ] end,
			set = function(info, value) E.private.actionbar[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
		},
		toggleKeybind = {
			order = 3,
			type = "execute",
			name = L["Keybind Mode"],
			func = function() AB:ActivateBindMode(); E:ToggleConfig(); GameTooltip:Hide(); end,
			disabled = function() return not E.private.actionbar.enable; end
		},
		spacer = {
			order = 4,
			type = "description",
			name = ""
		},
		macrotext = {
			order = 5,
			type = "toggle",
			name = L["Macro Text"],
			desc = L["Display macro names on action buttons."],
			disabled = function() return not E.private.actionbar.enable; end
		},
		hotkeytext = {
			order = 6,
			type = "toggle",
			name = L["Keybind Text"],
			desc = L["Display bind names on action buttons."],
			disabled = function() return not E.private.actionbar.enable; end
		},
		selfcast = {
			order = 7,
			type = "toggle",
			name = L["Self Cast"],
			desc = L["Self cast on right click."],
			disabled = function() return not E.private.actionbar.enable; end
		},
		keyDown = {
			order = 8,
			type = "toggle",
			name = L["Key Down"],
			desc = L["Action button keybinds will respond on key down, rather than on key up"],
			disabled = function() return not E.private.actionbar.enable; end
		},
		lockActionBars = {
			order = 9,
			type = "toggle",
			name = LOCK_ACTIONBAR_TEXT,
			desc = L["If you unlock actionbars then trying to move a spell might instantly cast it if you cast spells on key press instead of key release."],
			set = function(info, value)
				E.db.actionbar[ info[#info] ] = value;
				AB:UpdateButtonSettings()
				SetCVar("lockActionBars", (value == true and 1 or 0))
				LOCK_ACTIONBAR = (value == true and "1" or "0")
			end,
			disabled = function() return not E.private.actionbar.enable; end
		},
		movementModifier = {
			order = 10,
			type = "select",
			name = PICKUP_ACTION_KEY_TEXT,
			desc = OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN,
			disabled = function() return not E.private.actionbar.enable; end,
			values = {
				["NONE"] = NONE,
				["SHIFT"] = SHIFT_KEY,
				["ALT"] = ALT_KEY,
				["CTRL"] = CTRL_KEY
			}
		},
		globalFadeAlpha = {
 			order = 11,
			type = "range",
			name = L["Global Fade Transparency"],
			desc = L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."],
			min = 0, max = 1, step = 0.01,
			isPercent = true,
			set = function(info, value) E.db.actionbar[ info[#info] ] = value; AB.fadeParent:SetAlpha(1-value); end,
			disabled = function() return not E.private.actionbar.enable; end
		},
		colorGroup = {
			order = 12,
			type = "group",
			name = L["Colors"],
			guiInline = true,
			get = function(info)
				local t = E.db.actionbar[ info[#info] ]
				local d = P.actionbar[ info[#info] ]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b
			end,
			set = function(info, r, g, b)
				E.db.actionbar[ info[#info] ] = {}
				local t = E.db.actionbar[ info[#info] ]
				t.r, t.g, t.b = r, g, b
				AB:UpdateButtonSettings();
			end,
			args = {
				noRangeColor = {
					order = 1,
					type = "color",
					name = L["Out of Range"],
					desc = L["Color of the actionbutton when out of range."],
					disabled = function() return not E.private.actionbar.enable; end
				},
				noPowerColor = {
					order = 2,
					type = "color",
					name = L["Out of Power"],
					desc = L["Color of the actionbutton when out of power (Mana, Rage, Focus, Holy Power)."],
					disabled = function() return not E.private.actionbar.enable; end
				},
				usableColor = {
					order = 3,
					type = "color",
					name = L["Usable"],
					desc = L["Color of the actionbutton when usable."],
					disabled = function() return not E.private.actionbar.enable; end
				},
				notUsableColor = {
					order = 4,
					type = "color",
					name = L["Not Usable"],
					desc = L["Color of the actionbutton when not usable."],
					disabled = function() return not E.private.actionbar.enable; end
				}
			}
		},
		fontGroup = {
			order = 13,
			type = "group",
			guiInline = true,
			disabled = function() return not E.private.actionbar.enable end,
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
					name = L["Font Size"],
					min = 6, max = 22, step = 1
				},
				fontOutline = {
					order = 3,
					type = "select",
					name = L["Font Outline"],
					desc = L["Set the font outline."],
					values = {
						["NONE"] = L["None"],
						["OUTLINE"] = "OUTLINE",
						["MONOCHROME"] = (not E.isMacClient) and "MONOCHROME" or nil,
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE",
					}
				},
				fontColor = {
					order = 4,
					type = "color",
					name = L["Keybind Color"],
					get = function(info)
						local t = E.db.actionbar[ info[#info] ]
						local d = P.actionbar[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						E.db.actionbar[ info[#info] ] = {}
						local t = E.db.actionbar[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						AB:UpdateButtonSettings();
					end
				}
			}
		},
		microbar = {
			type = "group",
			name = L["Micro Bar"],
			disabled = function() return not E.private.actionbar.enable; end,
			get = function(info) return E.db.actionbar.microbar[ info[#info] ] end,
			set = function(info, value) E.db.actionbar.microbar[ info[#info] ] = value; AB:UpdateMicroPositionDimensions() end,
			args = {
				info = {
					order = 1,
					type = "header",
					name = L["Micro Bar"]
				},
				enabled = {
					order = 2,
					type = "toggle",
					name = L["Enable"]
				},
				restoreMicrobar = {
					order = 3,
					type = "execute",
					name = L["Restore Defaults"],
					func = function() E:CopyTable(E.db.actionbar["microbar"], P.actionbar["microbar"]); E:ResetMovers(L["Micro Bar"]); AB:UpdateMicroPositionDimensions(); end
				},
				general = {
					order = 4,
					type = "group",
					name = L["General"],
					guiInline = true,
					disabled = function() return not E.db.actionbar.microbar.enabled; end,
					args = {
						buttonsPerRow = {
							order = 1,
							type = "range",
							name = L["Buttons Per Row"],
							desc = L["The amount of buttons to display per row."],
							min = 1, max = 12, step = 1
						},
						xOffset = {
							order = 2,
							type = "range",
							name = L["xOffset"],
							min = 0, max = 60, step = 1
						},
						yOffset = {
							order = 3,
							type = "range",
							name = L["yOffset"],
							min = 0, max = 60, step = 1
						},
						alpha = {
							order = 4,
							type = "range",
							name = L["Alpha"],
							desc = L["Change the alpha level of the frame."],
							min = 0, max = 1, step = 0.1
						},
						mouseover = {
							order = 5,
							type = "toggle",
							name = L["Mouse Over"],
							desc = L["The frame is not shown unless you mouse over the frame."]
						}
					}
				}
			}
		},
		extraActionButton = {
			type = "group",
			name = L["Boss Button"],
			disabled = function() return not E.private.actionbar.enable; end,
			get = function(info) return E.db.actionbar.extraActionButton[ info[#info] ] end,
			args = {
				info = {
					order = 1,
					type = "header",
					name = L["Boss Button"]
				},
				alpha = {
					order = 2,
					type = "range",
					name = L["Alpha"],
					desc = L["Change the alpha level of the frame."],
					isPercent = true,
					min = 0, max = 1, step = 0.01,
					set = function(info, value) E.db.actionbar.extraActionButton[ info[#info] ] = value; AB:Extra_SetAlpha() end
				},
				scale = {
					order = 3,
					type = "range",
					name = L["Scale"],
					isPercent = true,
					min = 0.2, max = 2, step = 0.01,
					set = function(info, value) E.db.actionbar.extraActionButton[ info[#info] ] = value; AB:Extra_SetScale() end
				}
			}
		}
	}
}
group = E.Options.args.actionbar.args
BuildABConfig()