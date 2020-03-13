local E, L, V, P, G = unpack(ElvUI)

local ITEM_UPGRADE, LFG_TITLE, LOSS_OF_CONTROL = ITEM_UPGRADE, LFG_TITLE, LOSS_OF_CONTROL
local MOUNTS_AND_PETS, PET_BATTLE_PVP_QUEUE, TIMEMANAGER_TITLE = MOUNTS_AND_PETS, PET_BATTLE_PVP_QUEUE, TIMEMANAGER_TITLE
local ACHIEVEMENTS, AUCTIONS, BARBERSHOP, KEY_BINDING, GUILDCONTROL = ACHIEVEMENTS, AUCTIONS, BARBERSHOP, KEY_BINDING, GUILDCONTROL
local REFORGE, SPELLBOOK, GUILD, STABLES, TALENTS = REFORGE, SPELLBOOK, GUILD, STABLES, TALENTS
local ENCOUNTER_JOURNAL, DRESSUP_FRAME, FRIENDS, GUILD_BANK = ENCOUNTER_JOURNAL, DRESSUP_FRAME, FRIENDS, GUILD_BANK
local TRADE, TRADESKILLS, INSPECT, MACROS, MAIL_LABEL, MERCHANT = TRADE, TRADESKILLS, INSPECT, MACROS, MAIL_LABEL, MERCHANT
local RAID_CONTROL, TRANSMOGRIFY, VOID_STORAGE, WORLD_MAP = RAID_CONTROL, TRANSMOGRIFY, VOID_STORAGE, WORLD_MAP
local PROFESSIONS_ARCHAEOLOGY, INTERFACE_OPTIONS, BLACK_MARKET_AUCTION_HOUSE = PROFESSIONS_ARCHAEOLOGY, INTERFACE_OPTIONS, BLACK_MARKET_AUCTION_HOUSE

E.Options.args.skins = {
	type = "group",
	name = L["Skins"],
	childGroups = "tree",
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["SKINS_DESC"]
		},
		blizzardEnable = {
			order = 2,
			type = "toggle",
			name = "Blizzard",
			get = function(info) return E.private.skins.blizzard.enable end,
			set = function(info, value) E.private.skins.blizzard.enable = value E:StaticPopup_Show("PRIVATE_RL") end
		},
		ace3 = {
			order = 3,
			type = "toggle",
			name = "Ace3",
			get = function(info) return E.private.skins.ace3.enable end,
			set = function(info, value) E.private.skins.ace3.enable = value E:StaticPopup_Show("PRIVATE_RL") end
		},
		checkBoxSkin = {
			order = 4,
			type = "toggle",
			name = L["CheckBox Skin"],
			get = function(info) return E.private.skins.checkBoxSkin end,
			set = function(info, value) E.private.skins.checkBoxSkin = value E:StaticPopup_Show("PRIVATE_RL") end,
			disabled = function() return not E.private.skins.ace3.enable end
		},
		blizzard = {
			order = 100,
			type = "group",
			name = "Blizzard",
			get = function(info) return E.private.skins.blizzard[ info[#info] ] end,
			set = function(info, value) E.private.skins.blizzard[ info[#info] ] = value E:StaticPopup_Show("CONFIG_RL") end,
			disabled = function() return not E.private.skins.blizzard.enable end,
			guiInline = true,
			args = {
				achievement = {
					type = "toggle",
					name = ACHIEVEMENTS,
					desc = L["TOGGLESKIN_DESC"]
				},
				alertframes = {
					type = "toggle",
					name = L["Alert Frames"],
					desc = L["TOGGLESKIN_DESC"]
				},
				archaeology = {
					type = "toggle",
					name = PROFESSIONS_ARCHAEOLOGY,
					desc = L["TOGGLESKIN_DESC"]
				},
				auctionhouse = {
					type = "toggle",
					name = AUCTIONS,
					desc = L["TOGGLESKIN_DESC"]
				},
				bags = {
					type = "toggle",
					name = L["Bags"],
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() return E.private.bags.enable end
				},
				barber = {
					type = "toggle",
					name = BARBERSHOP,
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
					name = KEY_BINDING,
					desc = L["TOGGLESKIN_DESC"]
				},
				BlizzardOptions = {
					type = "toggle",
					name = INTERFACE_OPTIONS,
					desc = L["TOGGLESKIN_DESC"]
				},
				bmah = {
					type = "toggle",
					name = BLACK_MARKET_AUCTION_HOUSE,
					desc = L["TOGGLESKIN_DESC"]
				},
				calendar = {
					type = "toggle",
					name = L["Calendar Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				character = {
					type = "toggle",
					name = L["Character Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				encounterjournal = {
					type = "toggle",
					name = ENCOUNTER_JOURNAL,
					desc = L["TOGGLESKIN_DESC"]
				},
				debug = {
					type = "toggle",
					name = L["Debug Tools"],
					desc = L["TOGGLESKIN_DESC"]
				},
				dressingroom = {
					type = "toggle",
					name = DRESSUP_FRAME,
					desc = L["TOGGLESKIN_DESC"]
				},
				friends = {
					type = "toggle",
					name = FRIENDS,
					desc = L["TOGGLESKIN_DESC"]
				},
				gbank = {
					type = "toggle",
					name = GUILD_BANK,
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
				greeting = {
					type = "toggle",
					name = L["Greeting Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				guildcontrol = {
					type = "toggle",
					name = GUILDCONTROL,
					desc = L["TOGGLESKIN_DESC"]
				},
				guildregistrar = {
					type = "toggle",
					name = L["Guild Registrar"],
					desc = L["TOGGLESKIN_DESC"]
				},
				help = {
					type = "toggle",
					name = L["Help Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				inspect = {
					type = "toggle",
					name = INSPECT,
					desc = L["TOGGLESKIN_DESC"]
				},
				itemUpgrade = {
					type = "toggle",
					name = ITEM_UPGRADE,
					desc = L["TOGGLESKIN_DESC"]
				},
				lfguild = {
					type = "toggle",
					name = L["LF Guild Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				lfg = {
					type = "toggle",
					name = LFG_TITLE,
					desc = L["TOGGLESKIN_DESC"]
				},
				loot = {
					type = "toggle",
					name = L["Loot Frames"],
					desc = L["TOGGLESKIN_DESC"]
				},
				lootRoll = {
					type = "toggle",
					name = L["Loot Roll"],
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() return E.private.general.lootRoll end
				},
				losscontrol = {
					type = "toggle",
					name = LOSS_OF_CONTROL,
					desc = L["TOGGLESKIN_DESC"]
				},
				macro = {
					type = "toggle",
					name = MACROS,
					desc = L["TOGGLESKIN_DESC"]
				},
				mail = {
					type = "toggle",
					name = MAIL_LABEL,
					desc = L["TOGGLESKIN_DESC"]
				},
				merchant = {
					type = "toggle",
					name = MERCHANT,
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
					name = MOUNTS_AND_PETS,
					desc = L["TOGGLESKIN_DESC"]
				},
				petbattleui = {
					type = "toggle",
					name = PET_BATTLE_PVP_QUEUE,
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
					name = RAID_CONTROL,
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() return E.private["unitframe"]["disabledBlizzardFrames"].raid and E.private["unitframe"]["disabledBlizzardFrames"].party end
				},
				reforge = {
					type = "toggle",
					name = REFORGE,
					desc = L["TOGGLESKIN_DESC"]
				},
				socket = {
					type = "toggle",
					name = L["Socket Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				spellbook = {
					type = "toggle",
					name = SPELLBOOK,
					desc = L["TOGGLESKIN_DESC"]
				},
				guild = {
					type = "toggle",
					name = GUILD,
					desc = L["TOGGLESKIN_DESC"]
				},
				stable = {
					type = "toggle",
					name = STABLES,
					desc = L["TOGGLESKIN_DESC"]
				},
				tabard = {
					type = "toggle",
					name = L["Tabard Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				talent = {
					type = "toggle",
					name = TALENTS,
					desc = L["TOGGLESKIN_DESC"]
				},
				taxi = {
					type = "toggle",
					name = L["Taxi Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				tooltip = {
					type = "toggle",
					name = L["Tooltip"],
					desc = L["TOGGLESKIN_DESC"],
				},
				timemanager = {
					type = "toggle",
					name = TIMEMANAGER_TITLE,
					desc = L["TOGGLESKIN_DESC"]
				},
				transmogrify = {
					type = "toggle",
					name = TRANSMOGRIFY,
					desc = L["TOGGLESKIN_DESC"]
				},
				trade = {
					type = "toggle",
					name = TRADE,
					desc = L["TOGGLESKIN_DESC"]
				},
				tradeskill = {
					type = "toggle",
					name = TRADESKILLS,
					desc = L["TOGGLESKIN_DESC"]
				},
				trainer = {
					type = "toggle",
					name = L["Trainer Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				tutorial = {
					type = "toggle",
					name = L["Tutorial Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				voidstorage = {
					type = "toggle",
					name = VOID_STORAGE,
					desc = L["TOGGLESKIN_DESC"]
				},
				watchframe = {
					type = "toggle",
					name = L["Objective Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				worldmap = {
					type = "toggle",
					name = WORLD_MAP,
					desc = L["TOGGLESKIN_DESC"]
				}
			}
		}
	}
}