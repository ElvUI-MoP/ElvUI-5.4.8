local E, _, V, P, G = unpack(ElvUI)
local _, L = unpack(select(2, ...))

E.Options.args.skins = {
	order = 2,
	type = "group",
	name = L["Skins"],
	childGroups = "tab",
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["SKINS_DESC"]
		},
		general = {
			order = 2,
			type = "group",
			name = L["General"],
			guiInline = true,
			args = {
				blizzardEnable = {
					order = 1,
					type = "toggle",
					name = L["Blizzard"],
					get = function(info) return E.private.skins.blizzard.enable end,
					set = function(info, value) E.private.skins.blizzard.enable = value E:StaticPopup_Show("PRIVATE_RL") end
				},
				ace3 = {
					order = 2,
					type = "toggle",
					name = "Ace3",
					get = function(info) return E.private.skins.ace3.enable end,
					set = function(info, value) E.private.skins.ace3.enable = value E:StaticPopup_Show("PRIVATE_RL") end
				},
				checkBoxSkin = {
					order = 3,
					type = "toggle",
					name = L["CheckBox Skin"],
					get = function(info) return E.private.skins.checkBoxSkin end,
					set = function(info, value) E.private.skins.checkBoxSkin = value E:StaticPopup_Show("PRIVATE_RL") end,
					disabled = function() return not E.private.skins.ace3.enable and not E.private.skins.blizzard.enable end
				},
				cleanBossButton = {
					order = 4,
					type = "toggle",
					name = L["Clean Boss Button"],
					get = function(info) return E.private.skins.cleanBossButton end,
					set = function(info, value) E.private.skins.cleanBossButton = value E:StaticPopup_Show("PRIVATE_RL") end
				}
			}
		},
		blizzard = {
			order = 100,
			type = "group",
			name = "Blizzard",
			get = function(info) return E.private.skins.blizzard[info[#info]] end,
			set = function(info, value) E.private.skins.blizzard[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end,
			disabled = function() return not E.private.skins.blizzard.enable end,
			guiInline = true,
			args = {
				achievement = {
					type = "toggle",
					name = L["ACHIEVEMENTS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				alertframes = {
					type = "toggle",
					name = L["Alert Frames"],
					desc = L["TOGGLESKIN_DESC"]
				},
				archaeology = {
					type = "toggle",
					name = L["PROFESSIONS_ARCHAEOLOGY"],
					desc = L["TOGGLESKIN_DESC"]
				},
				auctionhouse = {
					type = "toggle",
					name = L["AUCTIONS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				bags = {
					type = "toggle",
					name = L["Bags"],
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() return E.private.bags.enable or not E.private.skins.blizzard.enable end
				},
				barber = {
					type = "toggle",
					name = L["BARBERSHOP"],
					desc = L["TOGGLESKIN_DESC"]
				},
				bgmap = {
					type = "toggle",
					name = L["BG Map"],
					desc = L["TOGGLESKIN_DESC"]
				},
				bgscore = {
					type = "toggle",
					name = L["BG Score"],
					desc = L["TOGGLESKIN_DESC"]
				},
				binding = {
					type = "toggle",
					name = L["KEY_BINDINGS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				BlizzardOptions = {
					type = "toggle",
					name = L["INTERFACE_OPTIONS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				bmah = {
					type = "toggle",
					name = L["BLACK_MARKET_AUCTION_HOUSE"],
					desc = L["TOGGLESKIN_DESC"]
				},
				calendar = {
					type = "toggle",
					name = L["Calendar"],
					desc = L["TOGGLESKIN_DESC"]
				},
				character = {
					type = "toggle",
					name = L["Character Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				encounterjournal = {
					type = "toggle",
					name = L["ENCOUNTER_JOURNAL"],
					desc = L["TOGGLESKIN_DESC"]
				},
				debug = {
					type = "toggle",
					name = L["Debug Tools"],
					desc = L["TOGGLESKIN_DESC"]
				},
				dressingroom = {
					type = "toggle",
					name = L["DRESSUP_FRAME"],
					desc = L["TOGGLESKIN_DESC"]
				},
				friends = {
					type = "toggle",
					name = L["FRIENDS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				gbank = {
					type = "toggle",
					name = L["GUILD_BANK"],
					desc = L["TOGGLESKIN_DESC"]
				},
				gossip = {
					type = "toggle",
					name = L["Gossip Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				gmchat = {
					type = "toggle",
					name = L["GM Chat"],
					desc = L["TOGGLESKIN_DESC"]
				},
				guildcontrol = {
					type = "toggle",
					name = L["GUILDCONTROL"],
					desc = L["TOGGLESKIN_DESC"]
				},
				guildregistrar = {
					type = "toggle",
					name = L["Guild Registrar"],
					desc = L["TOGGLESKIN_DESC"]
				},
				guild = {
					type = "toggle",
					name = L["GUILD"],
					desc = L["TOGGLESKIN_DESC"]
				},
				help = {
					type = "toggle",
					name = L["Help Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				inspect = {
					type = "toggle",
					name = L["INSPECT"],
					desc = L["TOGGLESKIN_DESC"]
				},
				itemText = {
					type = "toggle",
					name = L["Item Text Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				itemUpgrade = {
					type = "toggle",
					name = L["ITEM_UPGRADE"],
					desc = L["TOGGLESKIN_DESC"]
				},
				lfguild = {
					type = "toggle",
					name = L["LF Guild Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				lfg = {
					type = "toggle",
					name = L["LFG_TITLE"],
					desc = L["TOGGLESKIN_DESC"]
				},
				loot = {
					type = "toggle",
					name = L["Loot Frames"],
					desc = L["TOGGLESKIN_DESC"]
				},
				lootHistory = {
					type = "toggle",
					name = L["Loot History"],
					desc = L["TOGGLESKIN_DESC"]
				},
				lootRoll = {
					type = "toggle",
					name = L["Loot Roll"],
					desc = L["TOGGLESKIN_DESC"]
				},
				losscontrol = {
					type = "toggle",
					name = L["LOSS_OF_CONTROL"],
					desc = L["TOGGLESKIN_DESC"]
				},
				macro = {
					type = "toggle",
					name = L["MACROS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				mail = {
					type = "toggle",
					name = L["MAIL_LABEL"],
					desc = L["TOGGLESKIN_DESC"]
				},
				merchant = {
					type = "toggle",
					name = L["MERCHANT"],
					desc = L["TOGGLESKIN_DESC"]
				},
				misc = {
					type = "toggle",
					name = L["Misc Frames"],
					desc = L["TOGGLESKIN_DESC"]
				},
				mirrorTimers = {
					type = "toggle",
					name = L["Mirror Timers"],
					desc = L["TOGGLESKIN_DESC"]
				},
				movepad = {
					type = "toggle",
					name = L["Move Pad"],
					desc = L["TOGGLESKIN_DESC"]
				},
				nonraid = {
					type = "toggle",
					name = L["Raid Info"],
					desc = L["TOGGLESKIN_DESC"]
				},
				mounts = {
					type = "toggle",
					name = L["MOUNTS_AND_PETS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				petbattleui = {
					type = "toggle",
					name = L["PET_BATTLE_PVP_QUEUE"],
					desc = L["TOGGLESKIN_DESC"]
				},
				petition = {
					type = "toggle",
					name = L["Petition Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				pvp = {
					type = "toggle",
					name = L["PvP Frames"],
					desc = L["TOGGLESKIN_DESC"]
				},
				quest = {
					type = "toggle",
					name = L["Quest Frames"],
					desc = L["TOGGLESKIN_DESC"]
				},
				raid = {
					type = "toggle",
					name = L["Raid Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				RaidManager = {
					type = "toggle",
					name = L["RAID_CONTROL"],
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() return (E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.raid and E.private.unitframe.disabledBlizzardFrames.party) or not E.private.skins.blizzard.enable end
				},
				reforge = {
					type = "toggle",
					name = L["REFORGE"],
					desc = L["TOGGLESKIN_DESC"]
				},
				socket = {
					type = "toggle",
					name = L["Socket Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				spellbook = {
					type = "toggle",
					name = L["SPELLBOOK"],
					desc = L["TOGGLESKIN_DESC"]
				},
				stable = {
					type = "toggle",
					name = L["Stable"],
					desc = L["TOGGLESKIN_DESC"]
				},
				tabard = {
					type = "toggle",
					name = L["Tabard Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				talent = {
					type = "toggle",
					name = L["TALENTS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				taxi = {
					type = "toggle",
					name = L["FLIGHT_MAP"],
					desc = L["TOGGLESKIN_DESC"]
				},
				timemanager = {
					type = "toggle",
					name = L["TIMEMANAGER_TITLE"],
					desc = L["TOGGLESKIN_DESC"]
				},
				tooltip = {
					type = "toggle",
					name = L["Tooltip"],
					desc = L["TOGGLESKIN_DESC"]
				},
				trade = {
					type = "toggle",
					name = L["TRADE"],
					desc = L["TOGGLESKIN_DESC"]
				},
				tradeskill = {
					type = "toggle",
					name = L["TRADESKILLS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				trainer = {
					type = "toggle",
					name = L["Trainer Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				transmogrify = {
					type = "toggle",
					name = L["TRANSMOGRIFY"],
					desc = L["TOGGLESKIN_DESC"]
				},
				tutorial = {
					type = "toggle",
					name = L["Tutorials"],
					desc = L["TOGGLESKIN_DESC"]
				},
				voidstorage = {
					type = "toggle",
					name = L["VOID_STORAGE"],
					desc = L["TOGGLESKIN_DESC"]
				},
				watchframe = {
					type = "toggle",
					name = L["Objective Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				worldmap = {
					type = "toggle",
					name = L["WORLD_MAP"],
					desc = L["TOGGLESKIN_DESC"]
				},
				WorldStateFrame = {
					type = "toggle",
					name = L["World State Frame"],
					desc = L["TOGGLESKIN_DESC"]
				}
			}
		}
	}
}