local E, L, V, P, G = unpack(select(2, ...))

--Global Settings
G.general = {
	UIScale = 0.7111111111111111,
	version = 2.76,
	locale = E:GetLocale(),
	eyefinity = false,
	ignoreScalePopup = false,
	ignoreVersionPopup = false,
	smallerWorldMap = true,
	fadeMapWhenMoving = true,
	mapAlphaWhenMoving = 0.35,
	AceGUI = {
		width = 1000,
		height = 730
	},
	WorldMapCoordinates = {
		enable = true,
		position = "BOTTOMLEFT",
		xOffset = 0,
		yOffset = 0
	},
	showMissingTalentAlert = false
}

G.classtimer = {}

G.chat = {
	classColorMentionExcludedNames = {}
}

G.bags = {
	ignoredItems = {}
}

G.datatexts = {
	customCurrencies = {}
}

G.nameplates = {}

G.unitframe = {
	aurafilters = {},
	buffwatch = {},
	effectiveHealth = false,
	effectivePower = false,
	effectiveAura = false,
	effectiveHealthSpeed = 0.3,
	effectivePowerSpeed = 0.3,
	effectiveAuraSpeed = 0.3,
	raidDebuffIndicator = {
		instanceFilter = "RaidDebuffs",
		otherFilter = "CCDebuffs"
	},
	spellRangeCheck = {
		PRIEST = {
			enemySpells = {
				[585] = true	-- Smite (30 yards)
			},
			longEnemySpells = {
				[589] = true	-- Shadow Word: Pain (30 yards)
			},
			friendlySpells = {
				[2061] = true	-- Flash Heal (40 yards)
			},
			resSpells = {
				[2006] = true	-- Resurrection (40 yards)
			},
			petSpells = {}
		},
		DRUID = {
			enemySpells = {
				[33786] = true	-- Cyclone
			},
			longEnemySpells = {
				[5176] = true	-- Wrath
			},
			friendlySpells = {
				[774] = true	-- Rejuvenation
			},
			resSpells = {
				[50769] = true,	-- Revive
				[20484] = true	-- Rebirth
			},
			petSpells = {}
		},
		PALADIN = {
			enemySpells = {
				[20271] = true	-- Judgement
			},
			longEnemySpells = {
				[114165] = true,	-- Holy Prism
				[114157] = true	-- Execution Sentence
			},
			friendlySpells = {
				[85673] = true	-- Word of Glory
			},
			resSpells = {
				[7328] = true	-- Redemption
			},
			petSpells = {}
		},
		SHAMAN = {
			enemySpells = {
				[8042] = true	-- Earth Shock
			},
			longEnemySpells = {
				[403] = true	-- Lightning Bolt
			},
			friendlySpells = {
				[8004] = true	-- Healing Surge
			},
			resSpells = {
				[2008] = true	-- Ancestral Spirit
			},
			petSpells = {}
		},
		WARLOCK = {
			enemySpells = {
				[5782] = true	-- Fear
			},
			longEnemySpells = {
				[172] = true,	-- Corruption
				[686] = true,	-- Shadow Bolt
				[17962] = true	-- Conflagrate
			},
			friendlySpells = {
				[5697] = true	-- Unending Breath
			},
			resSpells = {},
			petSpells = {
				[755] = true	-- Health Funnel
			}
		},
		MAGE = {
			enemySpells = {
				[118] = true	-- Polymorph
			},
			longEnemySpells = {
				[44614] = true	-- Frostfire Bolt
			},
			friendlySpells = {
				[475] = true	-- Remove Curse
			},
			resSpells = {},
			petSpells = {}
		},
		HUNTER = {
			enemySpells = {
				[75] = true		-- Auto Shot
			},
			longEnemySpells = {},
			friendlySpells = {},
			resSpells = {},
			petSpells = {
				[136] = true	-- Mend Pet
			}
		},
		DEATHKNIGHT = {
			enemySpells = {
				[49576] = true	-- Death Grip
			},
			longEnemySpells = {},
			friendlySpells = {
				[47541] = true	-- Death Coil
			},
			resSpells = {
				[61999] = true	-- Raise Ally
			},
			petSpells = {}
		},
		ROGUE = {
			enemySpells = {
				[2094] = true	-- Blind
			},
			longEnemySpells = {
				[1725] = true,	-- Distract
				[114014] = true	-- Shuriken Toss
			},
			friendlySpells = {
				[57934] = true	-- Tricks of the Trade
			},
			resSpells = {},
			petSpells = {}
		},
		WARRIOR = {
			enemySpells = {
				[5246] = true,	-- Intimidating Shout
				[100] = true	-- Charge
			},
			longEnemySpells = {
				[355] = true	-- Taunt
			},
			friendlySpells = {
				[3411] = true	-- Intervene
			},
			resSpells = {},
			petSpells = {}
		},
		MONK = {
			enemySpells = {
				[115546] = true	-- Provoke
			},
			longEnemySpells = {},
			friendlySpells = {
				[115450] = true	-- Detox
			},
			resSpells = {
				[115178] = true	-- Resuscitate
			},
			petSpells = {}
		}
	}
}

G.profileCopy = {
	--Specific values
	selected = "Default",
	movers = {},
	--Modules
	actionbar = {
		general = true,
		bar1 = true,
		bar2 = true,
		bar3 = true,
		bar4 = true,
		bar5 = true,
		bar6 = true,
		bar7 = true,
		bar8 = true,
		bar9 = true,
		bar10 = true,
		barPet = true,
		stanceBar = true,
		microbar = true,
		extraActionButton = true,
		cooldown = true
	},
	auras = {
		general = true,
		buffs = true,
		debuffs = true,
		cooldown = true
	},
	bags = {
		general = true,
		split = true,
		vendorGrays = true,
		bagBar = true,
		cooldown = true
	},
	chat = {
		general = true
	},
	cooldown = {
		general = true,
		fonts = true
	},
	databars = {
		experience = true,
		reputation = true
	},
	datatexts = {
		general = true,
		panels = true
	},
	general = {
		general = true,
		minimap = true,
		threat = true,
		totems = true,
		altPowerBar = true
	},
	nameplates = {
		general = true,
		cooldown = true,
		reactions = true,
		threat = true,
		units = {
			FRIENDLY_PLAYER = true,
			ENEMY_PLAYER = true,
			FRIENDLY_NPC = true,
			ENEMY_NPC = true
		}
	},
	tooltip = {
		general = true,
		visibility = true,
		healthBar = true
	},
	unitframe = {
		general = true,
		cooldown = true,
		colors = {
			general = true,
			power = true,
			reaction = true,
			healPrediction = true,
			classResources = true,
			frameGlow = true,
			debuffHighlight = true
		},
		units = {
			player = true,
			target = true,
			targettarget = true,
			targettargettarget = true,
			focus = true,
			focustarget = true,
			pet = true,
			pettarget = true,
			boss = true,
			arena = true,
			party = true,
			raid = true,
			raid40 = true,
			raidpet = true,
			tank = true,
			assist = true
		}
	}
}