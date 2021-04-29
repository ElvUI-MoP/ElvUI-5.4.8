local E, L, V, P, G = unpack(select(2, ...))

P.gridSize = 64
P.farmSize = 340
P.layoutSetting = "tank"

--Core
P.general = {
	messageRedirect = DEFAULT_CHAT_FRAME:GetName(),
	smoothingAmount = 0.33,
	taintLog = false,
	stickyFrames = true,
	loginmessage = true,
	interruptAnnounce = "NONE",
	autoRepair = "NONE",
	autoTrackReputation = false,
	autoRoll = false,
	autoAcceptInvite = false,
	topPanel = false,
	bottomPanel = true,
	hideErrorFrame = true,
	enhancedPvpMessages = true,
	watchFrameHeight = 480,
	watchFrameAutoHide = true,
	vehicleSeatIndicatorSize = 128,
	resurrectSound = false,
	questRewardMostValueIcon = true,
	durabilityScale = 1,
	afk = true,
	numberPrefixStyle = "ENGLISH",
	decimalLength = 1,
	altPowerBar = {
		enable = true,
		width = 250,
		height = 20,
		font = "PT Sans Narrow",
		fontSize = 12,
		fontOutline = "OUTLINE",
		statusBar = "ElvUI Norm",
		textFormat = "CURMAXPERC",
		statusBarColorGradient = false,
		statusBarColor = {r = 0.2, g = 0.4, b = 0.8},
		smoothbars = false
	},
	itemLevel = {
		displayCharacterInfo = true,
		displayInspectInfo = true,
		itemLevelFont = "PT Sans Narrow",
		itemLevelFontSize = 12,
		itemLevelFontOutline = "OUTLINE"
	},
	font = "PT Sans Narrow",
	fontSize = 12,
	fontStyle = "OUTLINE",
	bordercolor = {r = 0, g = 0, b = 0},
	backdropcolor = {r = 0.1, g = 0.1, b = 0.1},
	backdropfadecolor = {r = 0.06, g = 0.06, b = 0.06, a = 0.8},
	valuecolor = {r = 0.99, g = 0.48, b = 0.17},
	cropIcon = 2,
	minimap = {
		size = 176,
		locationText = "MOUSEOVER",
		locationFontSize = 12,
		locationFontOutline = "OUTLINE",
		locationFont = "PT Sans Narrow",
		resetZoom = {
			enable = false,
			time = 3
		},
		icons = {
			calendar = {
				scale = 1,
				position = "TOPRIGHT",
				xOffset = 0,
				yOffset = 0,
				hide = true
			},
			mail = {
				scale = 1,
				position = "TOPRIGHT",
				xOffset = 3,
				yOffset = 4,
				texture = "Mail0"
			},
			lfgEye = {
				scale = 1,
				position = "BOTTOMRIGHT",
				xOffset = 0,
				yOffset = 0
			},
			difficulty = {
				scale = 1,
				position = "TOPLEFT",
				xOffset = 0,
				yOffset = 0
			},
			challengeMode = {
				scale = 1,
				position = "TOPLEFT",
				xOffset = 8,
				yOffset = -8
			},
			ticket = {
				scale = 1,
				position = "TOPRIGHT",
				xOffset = 0,
				yOffset = 0
			},
			worldMap = {
				scale = 1,
				position = "TOP",
				xOffset = 0,
				yOffset = 0,
				hide = true
			}
		}
	},
	threat = {
		enable = true,
		position = "RIGHTCHAT",
		textfont = "PT Sans Narrow",
		textSize = 12,
		textOutline = "NONE"
	},
	totems = {
		enable = true,
		growthDirection = "VERTICAL",
		sortDirection = "ASCENDING",
		size = 40,
		spacing = 4
	},
	kittys = false
}

--DataBars
P.databars = {
	experience = {
		enable = true,
		width = 10,
		height = 180,
		textFormat = "NONE",
		textSize = 11,
		font = "PT Sans Narrow",
		fontOutline = "NONE",
		mouseover = false,
		orientation = "VERTICAL",
		reverseFill = false,
		hideAtMaxLevel = true,
		hideInVehicle = false,
		hideInCombat = false
	},
	reputation = {
		enable = false,
		width = 10,
		height = 180,
		textFormat = "NONE",
		textSize = 11,
		font = "PT Sans Narrow",
		fontOutline = "NONE",
		mouseover = false,
		orientation = "VERTICAL",
		reverseFill = false,
		hideInVehicle = false,
		hideInCombat = false
	}
}

--Bags
P.bags = {
	sortInverted = true,
	bagSize = 34,
	bagWidth = 406,
	bagButtonSpacing = 1,
	bankSize = 34,
	bankWidth = 406,
	bankButtonSpacing = 1,
	currencyFormat = "ICON_TEXT_ABBR",
	moneyFormat = "SMART",
	moneyCoins = true,
	battlePetIcon = true,
	junkIcon = false,
	junkDesaturate = true,
	upgradeIcon = true,
	newItemGlow = true,
	ignoredItems = {},
	itemLevel = true,
	itemLevelThreshold = 1,
	itemLevelFont = "Homespun",
	itemLevelFontSize = 10,
	itemLevelFontOutline = "MONOCHROMEOUTLINE",
	itemLevelCustomColorEnable = false,
	itemLevelCustomColor = {r = 1, g = 1, b = 1},
	countFont = "Homespun",
	countFontSize = 10,
	countFontOutline = "MONOCHROMEOUTLINE",
	countFontColor = {r = 1, g = 1, b = 1},
	reverseSlots = false,
	clearSearchOnClose = false,
	disableBagSort = false,
	disableBankSort = false,
	strata = "DIALOG",
	qualityColors = true,
	showBindType = false,
	transparent = false,
	questIcon = true,
	professionBagColors = true,
	professionBagColorsStyle = "BORDER",
	professionBagColorsMult = 0.35,
	questItemColors = true,
	colors = {
		profession = {
			leatherworking = {r = 0.88, g = 0.73, b = 0.29},
			inscription = {r = 0.29, g = 0.30, b = 0.88},
			herbs = {r = 0.07, g = 0.71, b = 0.13},
			enchanting = {r = 0.76, g = 0.02, b = 0.8},
			engineering = {r = 0.91, g = 0.46, b = 0.18},
			gems = {r = 0.03, g = 0.71, b = 0.81},
			mining = {r = 0.54, g = 0.40, b = 0.04},
			fishing = {r = 0.42, g = 0.59, b = 1},
			cooking = {r = 0.87, g = 0.05, b = 0.25}
		},
		items = {
			questStarter = {r = 1, g = 1, b = 0},
			questItem = {r = 1, g = 0.30, b = 0.30}
		}
	},
	vendorGrays = {
		enable = false,
		interval = 0.2,
		details = false,
		progressBar = true
	},
	split = {
		bagSpacing = 5,
		bankSpacing = 5,
		player = false,
		bank = false,
		bag1 = false,
		bag2 = false,
		bag3 = false,
		bag4 = false,
		bag5 = false,
		bag6 = false,
		bag7 = false,
		bag8 = false,
		bag9 = false,
		bag10 = false,
		bag11 = false
	},
	cooldown = {
		threshold = 4,
		override = false,
		reverse = false,
		expiringColor = {r = 1, g = 0, b = 0},
		secondsColor = {r = 1, g = 1, b = 1},
		minutesColor = {r = 1, g = 1, b = 1},
		hoursColor = {r = 1, g = 1, b = 1},
		daysColor = {r = 1, g = 1, b = 1},
		expireIndicator = {r = 1, g = 1, b = 1},
		secondsIndicator = {r = 1, g = 1, b = 1},
		minutesIndicator = {r = 1, g = 1, b = 1},
		hoursIndicator = {r = 1, g = 1, b = 1},
		daysIndicator = {r = 1, g = 1, b = 1},
		hhmmColorIndicator = {r = 1, g = 1, b = 1},
		mmssColorIndicator = {r = 1, g = 1, b = 1},

		checkSeconds = false,
		hhmmColor = {r = 1, g = 1, b = 1},
		mmssColor = {r = 1, g = 1, b = 1},
		hhmmThreshold = -1,
		mmssThreshold = -1,

		fonts = {
			enable = false,
			font = "PT Sans Narrow",
			fontOutline = "OUTLINE",
			fontSize = 18
		}
	},
	bagBar = {
		growthDirection = "VERTICAL",
		sortDirection = "ASCENDING",
		size = 30,
		spacing = 4,
		backdropSpacing = 4,
		showBackdrop = false,
		mouseover = false,
		transparent = false,
		justBackpack = false,
		visibility = "[petbattle] hide; show",
	}
}

--NamePlate
P.nameplates = {
	statusbar = "ElvUI Norm",
	font = "PT Sans Narrow",
	fontSize = 11,
	fontOutline = "OUTLINE",
	useTargetScale = true,
	targetScale = 1.15,
	arrow = "Arrow9",
	arrowSize = 50,
	arrowSpacing = 3,
	smoothbars = false,
	thinBorders = true,
	fadeIn = false,
	glowStyle = "style4",
	nameColoredGlow = false,
	alwaysShowTargetHealth = true,
	nonTargetTransparency = 0.40,
	motionType = "STACKED",
	lowHealthThreshold = 0.4,
	showFriendlyCombat = "DISABLED",
	showEnemyCombat = "DISABLED",
	cutawayHealth = false,
	cutawayHealthLength = 0.3,
	cutawayHealthFadeOutTime = 0.6,
	highlight = true,
	trivial = true,
	trivialWidth = 60,
	trivialHeight = 10,
	clickThrough = {
		friendly = false,
		enemy = false,
		trivial = false
	},
	plateSize ={
		friendlyWidth = 150,
		friendlyHeight = 30,
		enemyWidth = 150,
		enemyHeight = 30,
		trivialWidth = 60,
		trivialHeight = 20
	},
	colors = {
		glowColor = {r = 1, g = 1, b = 1, a = 1},
		castColor = {r = 1, g = 0.81, b = 0},
		castNoInterruptColor = {r = 0.78, g = 0.25, b = 0.25},
		castbarDesaturate = true,
		reactions = {
			friendlyPlayer = {r = 0.29, g = 0.68, b = 0.29},
			tapped = {r = 0.6, g = 0.6, b = 0.6},
			good = {r = 0.31, g = 0.45, b = 0.63},
			neutral = {r = 0.85, g = 0.77, b = 0.36},
			bad = {r = 0.78, g = 0.25, b = 0.25},
		},
		threat = {
			goodColor = {r = 0.29, g = 0.68, b = 0.29},
			badColor = {r = 0.78, g = 0.25, b = 0.25},
			goodTransition = {r = 0.85, g = 0.77, b = 0.36},
			badTransition = {r = 0.92, g = 0.63, b = 0.15},
		},
		comboPoints = {
			[1] = {r = 0.69, g = 0.31, b = 0.31},
			[2] = {r = 0.69, g = 0.31, b = 0.31},
			[3] = {r = 0.65, g = 0.63, b = 0.35},
			[4] = {r = 0.65, g = 0.63, b = 0.35},
			[5] = {r = 0.33, g = 0.59, b = 0.33}
		}
	},
	cooldown = {
		threshold = 4,
		override = true,
		reverse = false,
		expiringColor = {r = 1, g = 0, b = 0},
		secondsColor = {r = 1, g = 1, b = 1},
		minutesColor = {r = 1, g = 1, b = 1},
		hoursColor = {r = 1, g = 1, b = 1},
		daysColor = {r = 1, g = 1, b = 1},
		expireIndicator = {r = 1, g = 1, b = 1},
		secondsIndicator = {r = 1, g = 1, b = 1},
		minutesIndicator = {r = 1, g = 1, b = 1},
		hoursIndicator = {r = 1, g = 1, b = 1},
		daysIndicator = {r = 1, g = 1, b = 1},
		hhmmColorIndicator = {r = 1, g = 1, b = 1},
		mmssColorIndicator = {r = 1, g = 1, b = 1},

		checkSeconds = false,
		hhmmColor = {r = 0.43, g = 0.43, b = 0.43},
		mmssColor = {r = 0.56, g = 0.56, b = 0.56},
		hhmmThreshold = -1,
		mmssThreshold = -1
	},
	threat = {
		goodScale = 0.8,
		badScale = 1.2,
		useThreatColor = true
	},
	filters = {
		ElvUI_Boss = {triggers = {enable = false}},
		ElvUI_Totem = {triggers = {enable = true}}
	},
	units = {
		FRIENDLY_PLAYER = {
			health = {
				enable = false,
				height = 10,
				width = 150,
				text = {
					enable = false,
					format = "CURRENT",
					position = "CENTER",
					parent = "Health",
					xOffset = 0,
					yOffset = 0,
					font = "PT Sans Narrow",
					fontOutline = "OUTLINE",
					fontSize = 11,
				},
				useClassColor = true,
			},
			name = {
				enable = true,
				useClassColor = true,
				abbrev = false,
				font = "PT Sans Narrow",
				fontOutline = "OUTLINE",
				fontSize = 11
			},
			level = {
				enable = false,
				font = "PT Sans Narrow",
				fontOutline = "OUTLINE",
				fontSize = 11
			},
			castbar = {
				enable = true,
				width = 150,
				height = 8,
				hideSpellName = false,
				hideTime = false,
				textPosition = "BELOW",
				castTimeFormat = "CURRENT",
				channelTimeFormat = "CURRENT",
				iconPosition = "RIGHT",
				iconSize = 20,
				iconOffsetX = 2,
				iconOffsetY = 0,
				showIcon = true,
				xOffset = 0,
				yOffset = -2,
				font = "PT Sans Narrow",
				fontSize = 11,
				fontOutline = "OUTLINE"
			},
			buffs = {
				enable = true,
				perrow = 6,
				size = 24,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "TOPLEFT",
				growthX = "RIGHT",
				growthY = "UP",
				spacing = 1,
				yOffset = 20,
				xOffset = 0,
				cooldownOrientation = "VERTICAL",
				reverseCooldown = false,
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 11,
				countPosition = "BOTTOMRIGHT",
				countXOffset = -1,
				countYOffset = 1,
				durationFont = "PT Sans Narrow",
				durationFontOutline = "OUTLINE",
				durationFontSize = 11,
				durationPosition = "CENTER",
				durationXOffset = 0,
				durationYOffset = 0,
				filters = {
					minDuration = 0,
					maxDuration = 0,
					priority = "Blacklist,blockNoDuration,Personal,TurtleBuffs" --NamePlate FriendlyPlayer Buffs
				}
			},
			debuffs = {
				enable = true,
				perrow = 6,
				size = 24,
				numrows = 1,
				yOffset = 1,
				xOffset = 0,
				attachTo = "BUFFS",
				anchorPoint = "TOPRIGHT",
				growthX = "LEFT",
				growthY = "UP",
				onlyShowPlayer = false,
				spacing = 1,
				cooldownOrientation = "VERTICAL",
				reverseCooldown = false,
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 11,
				countPosition = "BOTTOMRIGHT",
				countXOffset = -1,
				countYOffset = 1,
				durationFont = "PT Sans Narrow",
				durationFontOutline = "OUTLINE",
				durationFontSize = 11,
				durationPosition = "CENTER",
				durationXOffset = 0,
				durationYOffset = 0,
				filters = {
					minDuration = 0,
					maxDuration = 0,
					priority = "Blacklist,blockNoDuration,Personal,CCDebuffs" --NamePlate FriendlyPlayer Debuffs
				}
			},
			raidTargetIndicator = {
				size = 24,
				position = "LEFT",
				xOffset = -4,
				yOffset = 0
			},
			pvpRole = {
				enable = false,
				showHealer = false,
				showTank = false
			}
		},
		ENEMY_PLAYER = {
			health = {
				enable = true,
				height = 10,
				width = 150,
				text = {
					enable = false,
					format = "CURRENT",
					position = "CENTER",
					parent = "Health",
					xOffset = 0,
					yOffset = 0,
					font = "PT Sans Narrow",
					fontOutline = "OUTLINE",
					fontSize = 11
				},
				useClassColor = true
			},
			name = {
				enable = true,
				useClassColor = true,
				abbrev = false,
				font = "PT Sans Narrow",
				fontOutline = "OUTLINE",
				fontSize = 11
			},
			level = {
				enable = true,
				font = "PT Sans Narrow",
				fontOutline = "OUTLINE",
				fontSize = 11
			},
			castbar = {
				enable = true,
				width = 150,
				height = 8,
				hideSpellName = false,
				hideTime = false,
				textPosition = "BELOW",
				castTimeFormat = "CURRENT",
				channelTimeFormat = "CURRENT",
				iconPosition = "RIGHT",
				iconSize = 20,
				iconOffsetX = 2,
				iconOffsetY = 0,
				showIcon = true,
				xOffset = 0,
				yOffset = -2,
				font = "PT Sans Narrow",
				fontSize = 11,
				fontOutline = "OUTLINE"
			},
			comboPoints = {
				enable = true,
				width = 10,
				height = 5,
				spacing = 5,
				xOffset = 0,
				yOffset = 0,
				hideEmpty = true
			},
			buffs = {
				enable = true,
				perrow = 6,
				size = 24,
				numrows = 1,
				yOffset = 20,
				xOffset = 0,
				attachTo = "FRAME",
				anchorPoint = "TOPLEFT",
				growthX = "RIGHT",
				growthY = "UP",
				onlyShowPlayer = false,
				cooldownOrientation = "VERTICAL",
				reverseCooldown = false,
				spacing = 1,
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 11,
				countPosition = "BOTTOMRIGHT",
				countXOffset = -1,
				countYOffset = 1,
				durationFont = "PT Sans Narrow",
				durationFontOutline = "OUTLINE",
				durationFontSize = 11,
				durationPosition = "CENTER",
				durationXOffset = 0,
				durationYOffset = 0,
				filters = {
					minDuration = 0,
					maxDuration = 300,
					priority = "Blacklist,PlayerBuffs,TurtleBuffs" --NamePlate EnemyPlayer Buffs
				}
			},
			debuffs = {
				enable = true,
				perrow = 6,
				size = 24,
				numrows = 1,
				yOffset = 1,
				xOffset = 0,
				attachTo = "BUFFS",
				anchorPoint = "TOPRIGHT",
				growthX = "LEFT",
				growthY = "UP",
				onlyShowPlayer = false,
				spacing = 1,
				cooldownOrientation = "VERTICAL",
				reverseCooldown = false,
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 11,
				countPosition = "BOTTOMRIGHT",
				countXOffset = -1,
				countYOffset = 1,
				durationFont = "PT Sans Narrow",
				durationFontOutline = "OUTLINE",
				durationFontSize = 11,
				durationPosition = "CENTER",
				durationXOffset = 0,
				durationYOffset = 0,
				filters = {
					minDuration = 0,
					maxDuration = 0,
					priority = "Blacklist,blockNoDuration,Personal,CCDebuffs,RaidDebuffs" --NamePlate EnemyPlayer Debuffs
				}
			},
			raidTargetIndicator = {
				size = 24,
				position = "LEFT",
				xOffset = -4,
				yOffset = 0
			},
			pvpRole = {
				enable = true,
				markHealers = true,
				markTanks = false
			}
		},
		FRIENDLY_NPC = {
			health = {
				enable = false,
				height = 10,
				width = 150,
				text = {
					enable = false,
					format = "CURRENT",
					position = "CENTER",
					parent = "Health",
					xOffset = 0,
					yOffset = 0,
					font = "PT Sans Narrow",
					fontOutline = "OUTLINE",
					fontSize = 11
				}
			},
			name = {
				enable = true,
				useReactionColor = false,
				abbrev = false,
				font = "PT Sans Narrow",
				fontOutline = "OUTLINE",
				fontSize = 11
			},
			level = {
				enable = false,
				font = "PT Sans Narrow",
				fontOutline = "OUTLINE",
				fontSize = 11
			},
			castbar = {
				enable = true,
				width = 150,
				height = 8,
				hideSpellName = false,
				hideTime = false,
				textPosition = "BELOW",
				castTimeFormat = "CURRENT",
				channelTimeFormat = "CURRENT",
				iconPosition = "RIGHT",
				iconSize = 20,
				iconOffsetX = 2,
				iconOffsetY = 0,
				showIcon = true,
				xOffset = 0,
				yOffset = -2,
				font = "PT Sans Narrow",
				fontSize = 11,
				fontOutline = "OUTLINE"
			},
			buffs = {
				enable = true,
				perrow = 6,
				size = 24,
				numrows = 1,
				yOffset = 20,
				xOffset = 0,
				attachTo = "FRAME",
				anchorPoint = "TOPLEFT",
				growthX = "RIGHT",
				growthY = "UP",
				onlyShowPlayer = false,
				spacing = 1,
				cooldownOrientation = "VERTICAL",
				reverseCooldown = false,
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 11,
				countPosition = "BOTTOMRIGHT",
				countXOffset = -1,
				countYOffset = 1,
				durationFont = "PT Sans Narrow",
				durationFontOutline = "OUTLINE",
				durationFontSize = 11,
				durationPosition = "CENTER",
				durationXOffset = 0,
				durationYOffset = 0,
				filters = {
					minDuration = 0,
					maxDuration = 0,
					priority = "Blacklist,blockNoDuration,Personal,TurtleBuffs" --NamePlate FriendlyNPC Buffs
				}
			},
			debuffs = {
				enable = true,
				perrow = 6,
				size = 24,
				numrows = 1,
				yOffset = 1,
				xOffset = 0,
				attachTo = "BUFFS",
				anchorPoint = "TOPRIGHT",
				growthX = "LEFT",
				growthY = "UP",
				onlyShowPlayer = false,
				spacing = 1,
				cooldownOrientation = "VERTICAL",
				reverseCooldown = false,
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 11,
				countPosition = "BOTTOMRIGHT",
				countXOffset = -1,
				countYOffset = 1,
				durationFont = "PT Sans Narrow",
				durationFontOutline = "OUTLINE",
				durationFontSize = 11,
				durationPosition = "CENTER",
				durationXOffset = 0,
				durationYOffset = 0,
				filters = {
					minDuration = 0,
					maxDuration = 0,
					priority = "Blacklist,CCDebuffs,RaidDebuffs" --NamePlate FriendlyNPC Debuffs
				}
			},
			eliteIcon = {
				enable = false,
				size = 15,
				position = "RIGHT",
				xOffset = 10,
				yOffset = 0
			},
			raidTargetIndicator = {
				size = 24,
				position = "LEFT",
				xOffset = -4,
				yOffset = 0
			},
			iconFrame = {
				enable = false,
				size = 24,
				parent = "Nameplate",
				position = "CENTER",
				xOffset = 0,
				yOffset = 42
			}
		},
		ENEMY_NPC = {
			health = {
				enable = true,
				height = 10,
				width = 150,
				text = {
					enable = false,
					format = "CURRENT",
					position = "CENTER",
					parent = "Health",
					xOffset = 0,
					yOffset = 0,
					font = "PT Sans Narrow",
					fontOutline = "OUTLINE",
					fontSize = 11
				}
			},
			name = {
				enable = true,
				useReactionColor = false,
				abbrev = false,
				font = "PT Sans Narrow",
				fontOutline = "OUTLINE",
				fontSize = 11
			},
			level = {
				enable = true,
				font = "PT Sans Narrow",
				fontOutline = "OUTLINE",
				fontSize = 11
			},
			castbar = {
				enable = true,
				width = 150,
				height = 8,
				hideSpellName = false,
				hideTime = false,
				textPosition = "BELOW",
				castTimeFormat = "CURRENT",
				channelTimeFormat = "CURRENT",
				iconPosition = "RIGHT",
				iconSize = 20,
				iconOffsetX = 2,
				iconOffsetY = 0,
				showIcon = true,
				xOffset = 0,
				yOffset = -2,
				font = "PT Sans Narrow",
				fontSize = 11,
				fontOutline = "OUTLINE"
			},
			comboPoints = {
				enable = true,
				width = 10,
				height = 5,
				spacing = 5,
				xOffset = 0,
				yOffset = 0,
				hideEmpty = true
			},
			buffs = {
				enable = true,
				perrow = 6,
				size = 24,
				numrows = 1,
				yOffset = 20,
				xOffset = 0,
				attachTo = "FRAME",
				anchorPoint = "TOPLEFT",
				growthX = "RIGHT",
				growthY = "UP",
				spacing = 1,
				cooldownOrientation = "VERTICAL",
				reverseCooldown = false,
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 11,
				countPosition = "BOTTOMRIGHT",
				countXOffset = -1,
				countYOffset = 1,
				durationFont = "PT Sans Narrow",
				durationFontOutline = "OUTLINE",
				durationFontSize = 11,
				durationPosition = "CENTER",
				durationXOffset = 0,
				durationYOffset = 0,
				filters = {
					minDuration = 0,
					maxDuration = 0,
					priority = "Blacklist,blockNoDuration,PlayerBuffs,TurtleBuffs" --NamePlate EnemyNPC Buffs
				}
			},
			debuffs = {
				enable = true,
				perrow = 6,
				size = 24,
				numrows = 1,
				yOffset = 1,
				xOffset = 0,
				attachTo = "BUFFS",
				anchorPoint = "TOPRIGHT",
				growthX = "LEFT",
				growthY = "UP",
				spacing = 1,
				cooldownOrientation = "VERTICAL",
				reverseCooldown = false,
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 11,
				countPosition = "BOTTOMRIGHT",
				countXOffset = -1,
				countYOffset = 1,
				durationFont = "PT Sans Narrow",
				durationFontOutline = "OUTLINE",
				durationFontSize = 11,
				durationPosition = "CENTER",
				durationXOffset = 0,
				durationYOffset = 0,
				filters = {
					minDuration = 0,
					maxDuration = 0,
					priority = "Blacklist,Personal,CCDebuffs" --NamePlate EnemyNPC Debuffs
				}
			},
			eliteIcon = {
				enable = false,
				size = 15,
				position = "RIGHT",
				xOffset = 10,
				yOffset = 0
			},
			raidTargetIndicator = {
				size = 24,
				position = "LEFT",
				xOffset = -4,
				yOffset = 0
			},
			iconFrame = {
				enable = false,
				size = 24,
				parent = "Nameplate",
				position = "CENTER",
				xOffset = 0,
				yOffset = 42
			}
		}
	}
}

--Auras
P.auras = {
	buffs = {
		barColor = {r = 0, g = 0.8, b = 0},
		barColorGradient = false,
		barSize = 2,
		barNoDuration = true,
		barPosition = "BOTTOM",
		barShow = false,
		barSpacing = 2,
		barTexture = "ElvUI Norm",
		countFont = "Homespun",
		countFontOutline = "MONOCHROMEOUTLINE",
		countFontSize = 10,
		countXOffset = 0,
		countYOffset = 0,
		timeFont = "Homespun",
		timeFontOutline = "MONOCHROMEOUTLINE",
		timeFontSize = 10,
		timeXOffset = 0,
		timeYOffset = 0,
		fadeThreshold = 6,
		growthDirection = "LEFT_DOWN",
		horizontalSpacing = 6,
		maxWraps = 3,
		seperateOwn = 1,
		showDuration = true,
		size = 32,
		sortDir = "-",
		sortMethod = "TIME",
		verticalSpacing = 16,
		wrapAfter = 12
	},
	debuffs = {
		barColor = {r = 0, g = 0.8, b = 0},
		barColorGradient = false,
		barSize = 2,
		barNoDuration = true,
		barPosition = "BOTTOM",
		barShow = false,
		barSpacing = 2,
		barTexture = "ElvUI Norm",
		countFont = "Homespun",
		countFontOutline = "MONOCHROMEOUTLINE",
		countFontSize = 10,
		countXOffset = 0,
		countYOffset = 0,
		timeFont = "Homespun",
		timeFontOutline = "MONOCHROMEOUTLINE",
		timeFontSize = 10,
		timeXOffset = 0,
		timeYOffset = 0,
		fadeThreshold = 6,
		growthDirection = "LEFT_DOWN",
		horizontalSpacing = 6,
		maxWraps = 1,
		seperateOwn = 1,
		showDuration = true,
		size = 32,
		sortDir = "-",
		sortMethod = "TIME",
		verticalSpacing = 16,
		wrapAfter = 12
	},
	consolidatedBuffs = {
		enable = true,
		filter = true,
		durations = true,
		position = "RIGHT",
		font = "Homespun",
		fontSize = 10,
		fontOutline = "MONOCHROMEOUTLINE",
		reverseStyle = true
	},
	cooldown = {
		threshold = 4,
		override = true,
		reverse = false,
		expiringColor = {r = 1, g = 0, b = 0},
		secondsColor = {r = 1, g = 1, b = 1},
		minutesColor = {r = 1, g = 1, b = 1},
		hoursColor = {r = 1, g = 1, b = 1},
		daysColor = {r = 1, g = 1, b = 1},
		expireIndicator = {r = 1, g = 1, b = 1},
		secondsIndicator = {r = 1, g = 1, b = 1},
		minutesIndicator = {r = 1, g = 1, b = 1},
		hoursIndicator = {r = 1, g = 1, b = 1},
		daysIndicator = {r = 1, g = 1, b = 1},
		hhmmColorIndicator = {r = 1, g = 1, b = 1},
		mmssColorIndicator = {r = 1, g = 1, b = 1},

		checkSeconds = false,
		hhmmColor = {r = 1, g = 1, b = 1},
		mmssColor = {r = 1, g = 1, b = 1},
		hhmmThreshold = -1,
		mmssThreshold = -1
	}
}

--Chat
P.chat = {
	lockPositions = true,
	url = true,
	shortChannels = true,
	hyperlinkHover = true,
	throttleInterval = 45,
	scrollDownInterval = 15,
	fade = true,
	inactivityTimer = 100,
	font = "PT Sans Narrow",
	fontOutline = "NONE",
	sticky = true,
	emotionIcons = true,
	keywordSound = "None",
	noAlertInCombat = false,
	chatHistory = true,
	lfgIcons = true,
	maxLines = 100,
	historySize = 100,
	editboxHistorySize = 20,
	channelAlerts = {
		GUILD = "None",
		OFFICER = "None",
		INSTANCE = "None",
		PARTY = "None",
		RAID = "None",
		WHISPER = "Whisper Alert"
	},
	showHistory = {
		WHISPER = true,
		GUILD = true,
		OFFICER = true,
		PARTY = true,
		RAID = true,
		INSTANCE = true,
		CHANNEL = true,
		SAY = true,
		YELL = true,
		EMOTE = true
	},
	tabSelector = "NONE",
	tabSelectedTextEnabled = false,
	tabSelectedTextColor = {r = 1, g = 1, b = 1},
	tabSelectorColor = {r = 0.3, g = 1, b = 0.3},
	timeStampFormat = "NONE",
	keywords = "ElvUI",
	separateSizes = false,
	panelWidth = 412,
	panelHeight = 180,
	panelWidthRight = 412,
	panelHeightRight = 180,
	panelBackdropNameLeft = "",
	panelBackdropNameRight = "",
	panelBackdrop = "SHOWBOTH",
	panelTabBackdrop = false,
	panelTabTransparency = false,
	editBoxPosition = "BELOW_CHAT",
	fadeUndockedTabs = false,
	fadeTabsNoBackdrop = true,
	fadeChatToggles = true,
	useAltKey = false,
	classColorMentionsChat = true,
	numAllowedCombatRepeat = 5,
	useCustomTimeColor = true,
	customTimeColor = {r = 0.7, g = 0.7, b = 0.7},
	numScrollMessages = 3,
	autoClosePetBattleLog = true,
	tabFont = "PT Sans Narrow",
	tabFontSize = 12,
	tabFontOutline = "NONE",
	panelColor = {r = 0.06, g = 0.06, b = 0.06, a = 0.8}
}

--Datatexts
P.datatexts = {
	font = "PT Sans Narrow",
	fontSize = 12,
	fontOutline = "NONE",
	wordWrap = false,
	panels = {
		LeftChatDataPanel = {
			left = "Armor",
			middle = "Durability",
			right = "Avoidance"
		},
		RightChatDataPanel = {
			left = "System",
			middle = "Time",
			right = "Gold"
		},
		LeftMiniPanel = "Guild",
		RightMiniPanel = "Friends",
		BottomMiniPanel = "",
		TopMiniPanel = "",
		BottomLeftMiniPanel = "",
		BottomRightMiniPanel = "",
		TopRightMiniPanel = "",
		TopLeftMiniPanel = ""
	},
	battleground = true,
	panelTransparency = false,
	panelBackdrop = true,
	noCombatClick = false,
	noCombatHover = false,

	--Datatext Options
	---General
	goldFormat = "BLIZZARD",
	goldCoins = false,
	---Currencies
	currencies = {
		displayedCurrency = "GOLD",
		displayStyle = "ICON"
	},
	---Time
	localTime = true,
	timeFormat = "%I:%M",
	dateFormat = "",
	---Friends
	friends = {
		--status
		hideAFK = false,
		hideDND = false,
	},
	--Enabled/Disabled Panels
	minimapPanels = true,
	leftChatPanel = true,
	rightChatPanel = true,
	minimapTop = false,
	minimapTopLeft = false,
	minimapTopRight = false,
	minimapBottom = false,
	minimapBottomLeft = false,
	minimapBottomRight = false
}

--Tooltip
P.tooltip = {
	showElvUIUsers = false,
	cursorAnchor = false,
	cursorAnchorType = "ANCHOR_CURSOR",
	cursorAnchorX = 0,
	cursorAnchorY = 0,
	alwaysShowRealm = false,
	targetInfo = true,
	playerTitles = true,
	guildRanks = true,
	itemCount = "BAGS_ONLY",
	modifierID = "SHOW",
	role = true,
	gender = false,
	font = "PT Sans Narrow",
	fontOutline = "NONE",
	headerFontSize = 12,
	textFontSize = 12,
	smallTextFontSize = 12,
	colorAlpha = 0.8,
	visibility = {
		bags = "SHOW",
		unitFrames = "SHOW",
		actionbars = "SHOW",
		combatOverride = "SHOW"
	},
	healthBar = {
		text = true,
		height = 7,
		font = "Homespun",
		fontSize = 10,
		fontOutline = "OUTLINE",
		statusPosition = "BOTTOM"
	},
	useCustomFactionColors = false,
	factionColors = {
		[1] = {r = 0.8, g = 0.3, b = 0.22},
		[2] = {r = 0.8, g = 0.3, b = 0.22},
		[3] = {r = 0.75, g = 0.27, b = 0},
		[4] = {r = 0.9, g = 0.7, b = 0},
		[5] = {r = 0, g = 0.6, b = 0.1},
		[6] = {r = 0, g = 0.6, b = 0.1},
		[7] = {r = 0, g = 0.6, b = 0.1},
		[8] = {r = 0, g = 0.6, b = 0.1}
	}
}

--UnitFrame
P.unitframe = {
	smoothbars = false,
	statusbar = "ElvUI Norm",
	font = "Homespun",
	fontSize = 10,
	fontOutline = "MONOCHROMEOUTLINE",
	debuffHighlighting = "FILL",
	targetOnMouseDown = false,
	modifiers = {
		SHIFT = "NONE",
		CTRL = "NONE",
		ALT = "NONE"
	},
	thinBorders = true,
	targetSound = false,
	cooldown = {
		threshold = 4,
		override = true,
		reverse = false,
		expiringColor = {r = 1, g = 0, b = 0},
		secondsColor = {r = 1, g = 1, b = 1},
		minutesColor = {r = 1, g = 1, b = 1},
		hoursColor = {r = 1, g = 1, b = 1},
		daysColor = {r = 1, g = 1, b = 1},
		expireIndicator = {r = 1, g = 1, b = 1},
		secondsIndicator = {r = 1, g = 1, b = 1},
		minutesIndicator = {r = 1, g = 1, b = 1},
		hoursIndicator = {r = 1, g = 1, b = 1},
		daysIndicator = {r = 1, g = 1, b = 1},
		hhmmColorIndicator = {r = 1, g = 1, b = 1},
		mmssColorIndicator = {r = 1, g = 1, b = 1},

		checkSeconds = false,
		hhmmColor = {r = 1, g = 1, b = 1},
		mmssColor = {r = 1, g = 1, b = 1},
		hhmmThreshold = -1,
		mmssThreshold = -1,

		fonts = {
			enable = false,
			font = "PT Sans Narrow",
			fontOutline = "OUTLINE",
			fontSize = 18
		}
	},
	colors = {
		borderColor = {r = 0, g = 0, b = 0},
		healthclass = false,
		forcehealthreaction = false,
		powerclass = false,
		colorhealthbyvalue = true,
		customhealthbackdrop = false,
		custompowerbackdrop = false,
		customcastbarbackdrop = false,
		customaurabarbackdrop = false,
		customclasspowerbackdrop = false,
		useDeadBackdrop = false,
		classbackdrop = false,
		healthMultiplier = 0,
		auraByType = true,
		auraBarByType = true,
		auraBarTurtle = true,
		auraBarTurtleColor = {r = 0.56, g = 0.39, b = 0.61},
		transparentHealth = false,
		transparentPower = false,
		transparentCastbar = false,
		transparentAurabars = false,
		transparentClasspower = false,
		invertCastBar = false,
		invertAurabars = false,
		invertPower = false,
		invertClasspower = false,
		castColor = {r = 0.31, g = 0.31, b = 0.31},
		castNoInterrupt = {r = 0.78, g = 0.25, b = 0.25},
		castInterruptedColor = {r = 0.30, g = 0.30, b = 0.30},
		castClassColor = false,
		castReactionColor = false,
		health = {r = 0.31, g = 0.31, b = 0.31},
		health_backdrop = {r = 0.8, g = 0.01, b = 0.01},
		health_backdrop_dead = {r = 0.8, g = 0.01, b = 0.01},
		castbar_backdrop = {r = 0.5, g = 0.5, b = 0.5},
		classpower_backdrop = {r = 0.5, g = 0.5, b = 0.5},
		aurabar_backdrop = {r = 0.5, g = 0.5, b = 0.5},
		power_backdrop = {r = 0.5, g = 0.5, b = 0.5},
		tapped = {r = 0.55, g = 0.57, b = 0.61},
		disconnected = {r = 0.84, g = 0.75, b = 0.65},
		auraBarBuff = {r = 0.31, g = 0.31, b = 0.31},
		auraBarDebuff = {r = 0.8, g = 0.1, b = 0.1},
		power = {
			MANA = {r = 0.31, g = 0.45, b = 0.63},
			RAGE = {r = 0.78, g = 0.25, b = 0.25},
			FOCUS = {r = 0.71, g = 0.43, b = 0.27},
			ENERGY = {r = 0.65, g = 0.63, b = 0.35},
			RUNIC_POWER = {r = 0, g = 0.82, b = 1}
		},
		reaction = {
			BAD = {r = 0.78, g = 0.25, b = 0.25},
			NEUTRAL = {r = 0.85, g = 0.77, b = 0.36},
			GOOD = {r = 0.29, g = 0.68, b = 0.29}
		},
		threat = {
			[ 0] = {r = 0.5, g = 0.5, b = 0.5}, -- low
			[ 1] = {r = 1.0, g = 1.0, b = 0.5}, -- overnuking
			[ 2] = {r = 1.0, g = 0.5, b = 0.0}, -- losing threat
			[ 3] = {r = 1.0, g = 0.2, b = 0.2}, -- tanking securely
		},
		healPrediction = {
			personal = {r = 0, g = 1, b = 0.5, a = 0.25},
			others = {r = 0, g = 1, b = 0, a = 0.25},
			absorbs = {r = 1, g = 1, b = 0, a = 0.25},
			healAbsorbs = {r = 1, g = 0, b = 0, a = 0.25},
			overabsorbs = {r = 1, g = 1, b = 0, a = 0.25},
			overhealabsorbs = {r = 1, g = 0, b = 0, a = 0.25},
			maxOverflow = 0
		},
		classResources = {
			comboPoints = {
				[1] = {r = 0.69, g = 0.31, b = 0.31},
				[2] = {r = 0.69, g = 0.31, b = 0.31},
				[3] = {r = 0.65, g = 0.63, b = 0.35},
				[4] = {r = 0.65, g = 0.63, b = 0.35},
				[5] = {r = 0.33, g = 0.59, b = 0.33}
			},
			DEATHKNIGHT = {
				[1] = {r = 1, g = 0, b = 0},
				[2] = {r = 0, g = 1, b = 0},
				[3] = {r = 0, g = 1, b = 1},
				[4] = {r = 0.9, g = 0.1, b = 1}
			},
			PALADIN = {r = 0.89, g = 1, b = 0.06},
			MAGE = {r = 0, g = 0.61, b = 1},
			ROGUE = {
				[1] = {r = 0.69, g = 0.31, b = 0.31},
				[2] = {r = 0.69, g = 0.31, b = 0.31},
				[3] = {r = 0.65, g = 0.63, b = 0.35},
				[4] = {r = 0.65, g = 0.63, b = 0.35},
				[5] = {r = 0.33, g = 0.59, b = 0.33}
			},
			PRIEST = {r = 1, g = 1, b = 1},
			WARLOCK = {
				[1] = {r = 0.58, g = 0.50, b = 0.79},
				[2] = {r = 0.58, g = 0.50, b = 0.79},
				[3] = {r = 0.90, g = 0.37, b = 0.37}
			},
			DRUID = {
				[1] = {r = 0.30, g = 0.52, b = 0.90},
				[2] = {r = 0.80, g = 0.82, b = 0.60}
			},
			MONK = {
				[1] = {r = 0.57, g = 0.63, b = 0.35},
				[2] = {r = 0.47, g = 0.63, b = 0.35},
				[3] = {r = 0.37, g = 0.63, b = 0.35},
				[4] = {r = 0.27, g = 0.63, b = 0.33},
				[5] = {r = 0.17, g = 0.63, b = 0.33}
			}
		},
		frameGlow = {
			mainGlow = {
				enable = false,
				class = false,
				color = {r = 1, g = 1, b = 1, a = 1}
			},
			targetGlow = {
				enable = true,
				class = true,
				color = {r = 1, g = 1, b = 1, a = 1}
			},
			focusGlow = {
				enable = false,
				class = false,
				color = {r = 1, g = 1, b = 1, a = 1}
			},
			mouseoverGlow = {
				enable = true,
				class = false,
				texture = "ElvUI Blank",
				color = {r = 1, g = 1, b = 1, a = 0.1}
			}
		},
		debuffHighlight = {
			Magic = {r = 0.2, g = 0.6, b = 1, a = 0.45},
			Curse = {r = 0.6, g = 0, b = 1, a = 0.45},
			Disease = {r = 0.6, g = 0.4, b = 0, a = 0.45},
			Poison = {r = 0, g = 0.6, b = 0, a = 0.45},
			blendMode = "ADD"
		}
	},
	units = {
		player = {
			enable = true,
			orientation = "LEFT",
			width = 270,
			height = 54,
			lowmana = 30,
			healPrediction = {
				enable = true,
				showAbsorbAmount = false,
				showOverAbsorbs = true
			},
			threatStyle = "GLOW",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			disableMouseoverGlow = false,
			disableTargetGlow = true,
			disableFocusGlow = true,
			health = {
				text_format = "[healthcolor][health:current-percent]",
				position = "LEFT",
				xOffset = 2,
				yOffset = 0,
				attachTextTo = "Health",
				reverseFill = false
			},
			fader = {
				enable = false,
				--range = true, [player doesnt get this option]
				hover = true,
				combat = true,
				playertarget = true,
				--unittarget = false, [player doesnt get this option]
				focus = false,
				health = true,
				power = true,
				vehicle = true,
				casting = true,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				autoHide = false,
				reverseFill = false,
				text_format = "[powercolor][power:current]",
				width = "fill",
				height = 10,
				offset = 0,
				position = "RIGHT",
				hideonnpc = false,
				xOffset = -2,
				yOffset = 0,
				attachTextTo = "Health",
				detachFromFrame = false,
				detachedWidth = 250,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				},
				parent = "FRAME"
			},
			infoPanel = {
				enable = false,
				height = 20,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "",
				xOffset = 0,
				yOffset = 0,
				attachTextTo = "Health"
			},
			pvp = {
				position = "BOTTOM",
				text_format = "||cFFB04F4F[pvptimer][mouseover]||r",
				xOffset = 0,
				yOffset = 0
			},
			RestIcon = {
				enable = true,
				defaultColor = true,
				color = {r = 1, g = 1, b = 1, a = 1},
				anchorPoint = "TOPLEFT",
				xOffset = -3,
				yOffset = 6,
				size = 22,
				texture = "DEFAULT"
			},
			raidRoleIcons = {
				enable = true,
				position = "TOPLEFT",
				xOffset = 0,
				yOffset = 0
			},
			CombatIcon = {
				enable = true,
				defaultColor = true,
				color = {r = 1, g = 0.2, b = 0.2, a = 1},
				anchorPoint = "CENTER",
				xOffset = 0,
				yOffset = 0,
				size = 20,
				texture = "DEFAULT"
			},
			pvpIcon = {
				enable = false,
				anchorPoint = "CENTER",
				xOffset = 0,
				yOffset = 0,
				scale = 1
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				camDistanceScale = 2,
				rotation = 0,
				style = "3D",
				xOffset = 0,
				yOffset = 0,
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 8,
				numrows = 1,
				attachTo = "DEBUFFS",
				anchorPoint = "TOPLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 0,
				priority = "Blacklist,Personal,PlayerBuffs,Whitelist,blockNoDuration,nonPersonal", --Player Buffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			debuffs = {
				enable = true,
				perrow = 8,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "TOPLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				desaturate = true,
				minDuration = 0,
				maxDuration = 0,
				priority = "Blacklist,Personal,nonPersonal", --Player Debuffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			castbar = {
				enable = true,
				width = 270,
				height = 18,
				icon = true,
				latency = true,
				format = "REMAINING",
				ticks = true,
				spark = true,
				displayTarget = false,
				iconSize = 42,
				iconAttached = true,
				insideInfoPanel = true,
				iconAttachedTo = "Frame",
				iconPosition = "LEFT",
				iconXOffset = -10,
				iconYOffset = 0,
				tickWidth = 1,
				tickColor = {r = 0, g = 0, b = 0, a = 0.8},
				timeToHold = 0,
				hidetext = false,
				textColor = {r = 0.84, g = 0.75, b = 0.65, a = 1},
				xOffsetText = 4,
				yOffsetText = 0,
				xOffsetTime = -4,
				yOffsetTime = 0,
				overlayOnFrame = "None",
				reverse = false,
				customTextFont = {
					enable = false,
					font = "PT Sans Narrow",
					fontSize = 12,
					fontStyle = "OUTLINE"
				},
				customTimeFont = {
					enable = false,
					font = "PT Sans Narrow",
					fontSize = 12,
					fontStyle = "OUTLINE"
				},
				customColor = {
					enable = false,
					transparent = false,
					invertColors = false,
					useClassColor = false,
					useCustomBackdrop = false,
					useReactionColor = false,
					color = {r = 0.31, g = 0.31, b = 0.31},
					colorNoInterrupt = {r = 0.78, g = 0.25, b = 0.25},
					colorInterrupted = {r = 0.30, g = 0.30, b = 0.30},
					colorBackdrop = {r = 0.5, g = 0.5, b = 0.5, a = 1}
				},
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			classbar = {
				enable = true,
				fill = "fill",
				height = 10,
				autoHide = false,
				additionalPowerText = true,
				detachFromFrame = false,
				detachedWidth = 250,
				parent = "FRAME",
				verticalOrientation = false,
				orientation = "HORIZONTAL",
				spacing = 5,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			aurabar = {
				enable = true,
				anchorPoint = "ABOVE",
				attachTo = "DEBUFFS",
				maxBars = 6,
				minDuration = 0,
				maxDuration = 120,
				priority = "Blacklist,blockNoDuration,Personal,RaidDebuffs,PlayerBuffs", --Player AuraBars
				friendlyAuraType = "HELPFUL",
				enemyAuraType = "HARMFUL",
				height = 20,
				detachedWidth = 270,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				yOffset = 0,
				spacing = 0,
				clickThrough = false
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			},
			resurrectIcon = {
				enable = true,
				size = 30,
				attachTo = "CENTER",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 0
			},
			stagger = {
				enable = true,
				autoHide = true,
				width = 10,
				staggerTextFormat = "[staggercolor][stagger]"
			},
			strataAndLevel = {
				useCustomStrata = false,
				frameStrata = "LOW",
				useCustomLevel = false,
				frameLevel = 1
			}
		},
		target = {
			enable = true,
			width = 270,
			height = 54,
			orientation = "RIGHT",
			threatStyle = "GLOW",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			healPrediction = {
				enable = true,
				showAbsorbAmount = false,
				showOverAbsorbs = true
			},
			middleClickFocus = true,
			disableMouseoverGlow = false,
			disableTargetGlow = true,
			disableFocusGlow = true,
			health = {
				text_format = "[healthcolor][health:current-percent]",
				position = "RIGHT",
				xOffset = -2,
				yOffset = 0,
				attachTextTo = "Health",
				reverseFill = false
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				autoHide = false,
				reverseFill = false,
				text_format = "[powercolor][power:current]",
				width = "fill",
				height = 10,
				offset = 0,
				position = "LEFT",
				hideonnpc = false,
				xOffset = 2,
				yOffset = 0,
				detachFromFrame = false,
				detachedWidth = 250,
				attachTextTo = "Health",
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				},
				parent = "FRAME"
			},
			infoPanel = {
				enable = false,
				height = 20,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium] [difficultycolor][smartlevel] [shortclassification]",
				xOffset = 0,
				yOffset = 0,
				attachTextTo = "Health"
			},
			phaseIndicator = {
				enable = false,
				anchorPoint = "CENTER",
				xOffset = 0,
				yOffset = 0,
				scale = 0.8,
				color = {r = 0.3, g = 0.5, b = 1}
			},
			CombatIcon = {
				enable = true,
				defaultColor = true,
				color = {r = 1, g = 0.2, b = 0.2, a = 1},
				anchorPoint = "CENTER",
				xOffset = 0,
				yOffset = 0,
				size = 20,
				texture = "DEFAULT"
			},
			pvpIcon = {
				enable = false,
				anchorPoint = "CENTER",
				xOffset = 0,
				yOffset = 0,
				scale = 1
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				camDistanceScale = 2,
				rotation = 0,
				style = "3D",
				xOffset = 0,
				yOffset = 0,
				overlayAlpha = 0.35
			},
			buffs = {
				enable = true,
				perrow = 8,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "TOPRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 0,
				priority = "Blacklist,Personal,nonPersonal", --Target Buffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			debuffs = {
				enable = true,
				perrow = 8,
				numrows = 1,
				attachTo = "BUFFS",
				anchorPoint = "TOPRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				desaturate = true,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,RaidDebuffs,CCDebuffs,Friendly:Dispellable", --Target Debuffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			castbar = {
				enable = true,
				width = 270,
				height = 18,
				icon = true,
				format = "REMAINING",
				spark = true,
				displayTarget = false,
				iconSize = 42,
				iconAttached = true,
				insideInfoPanel = true,
				iconAttachedTo = "Frame",
				iconPosition = "LEFT",
				iconXOffset = -10,
				iconYOffset = 0,
				timeToHold = 0,
				hidetext = false,
				textColor = {r = 0.84, g = 0.75, b = 0.65, a = 1},
				xOffsetText = 4,
				yOffsetText = 0,
				xOffsetTime = -4,
				yOffsetTime = 0,
				overlayOnFrame = "None",
				reverse = false,
				customTextFont = {
					enable = false,
					font = "PT Sans Narrow",
					fontSize = 12,
					fontStyle = "OUTLINE"
				},
				customTimeFont = {
					enable = false,
					font = "PT Sans Narrow",
					fontSize = 12,
					fontStyle = "OUTLINE"
				},
				customColor = {
					enable = false,
					transparent = false,
					invertColors = false,
					useClassColor = false,
					useCustomBackdrop = false,
					useReactionColor = false,
					color = {r = 0.31, g = 0.31, b = 0.31},
					colorNoInterrupt = {r = 0.78, g = 0.25, b = 0.25},
					colorInterrupted = {r = 0.30, g = 0.30, b = 0.30},
					colorBackdrop = {r = 0.5, g = 0.5, b = 0.5, a = 1}
				},
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			combobar = {
				enable = true,
				fill = "fill",
				height = 10,
				autoHide = true,
				detachFromFrame = false,
				detachedWidth = 250,
				parent = "FRAME",
				orientation = "HORIZONTAL",
				spacing = 5,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			aurabar = {
				enable = true,
				anchorPoint = "ABOVE",
				attachTo = "DEBUFFS",
				maxBars = 6,
				minDuration = 0,
				maxDuration = 120,
				priority = "Blacklist,blockNoDuration,Personal,PlayerBuffs,RaidDebuffs", --Target AuraBars
				friendlyAuraType = "HELPFUL",
				enemyAuraType = "HARMFUL",
				height = 20,
				detachedWidth = 270,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				yOffset = 0,
				spacing = 0,
				clickThrough = false
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			GPSArrow = {
				enable = false,
				size = 45,
				xOffset = 0,
				yOffset = 0,
				onMouseOver = true,
				outOfRange = true,
				color = {r = 0.83, g = 0.16, b = 0.16}
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			},
			raidRoleIcons = {
				enable = true,
				position = "TOPLEFT",
				xOffset = 0,
				yOffset = 0
			},
			resurrectIcon = {
				enable = true,
				size = 30,
				attachTo = "CENTER",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 0
			},
			strataAndLevel = {
				useCustomStrata = false,
				frameStrata = "LOW",
				useCustomLevel = false,
				frameLevel = 1
			}
		},
		targettarget = {
			enable = true,
			threatStyle = "NONE",
			orientation = "MIDDLE",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			width = 130,
			height = 36,
			disableMouseoverGlow = false,
			disableTargetGlow = true,
			disableFocusGlow = true,
			health = {
				text_format = "",
				position = "RIGHT",
				xOffset = -2,
				yOffset = 0,
				attachTextTo = "Health",
				reverseFill = false
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				autoHide = false,
				reverseFill = false,
				text_format = "",
				width = "fill",
				height = 7,
				offset = 0,
				position = "LEFT",
				hideonnpc = false,
				xOffset = 2,
				yOffset = 0,
				attachTextTo = "Health",
				detachFromFrame = false,
				detachedWidth = 250,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				},
				parent = "FRAME"
			},
			infoPanel = {
				enable = false,
				height = 14,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				xOffset = 0,
				yOffset = 0,
				attachTextTo = "Health"
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				camDistanceScale = 2,
				rotation = 0,
				style = "3D",
				xOffset = 0,
				yOffset = 0,
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 7,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,PlayerBuffs,Dispellable", --TargetTarget Buffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			debuffs = {
				enable = true,
				perrow = 5,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				desaturate = true,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,RaidDebuffs,CCDebuffs,Dispellable,Whitelist", --TargetTarget Debuffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			},
			strataAndLevel = {
				useCustomStrata = false,
				frameStrata = "LOW",
				useCustomLevel = false,
				frameLevel = 1
			}
		},
		targettargettarget = {
			enable = false,
			orientation = "MIDDLE",
			threatStyle = "NONE",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			width = 130,
			height = 36,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = false,
			health = {
				text_format = "",
				position = "RIGHT",
				xOffset = -2,
				yOffset = 0,
				attachTextTo = "Health",
				reverseFill = false
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				autoHide = false,
				reverseFill = false,
				text_format = "",
				width = "fill",
				height = 7,
				offset = 0,
				position = "LEFT",
				hideonnpc = false,
				xOffset = 2,
				yOffset = 0,
				attachTextTo = "Health",
				detachFromFrame = false,
				detachedWidth = 250,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				},
				parent = "FRAME"
			},
			infoPanel = {
				enable = false,
				height = 12,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				xOffset = 0,
				yOffset = 0
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				camDistanceScale = 1,
				rotation = 0,
				style = "3D",
				xOffset = 0,
				yOffset = 0,
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 7,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,nonPersonal", --TargetTargetTarget Buffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			debuffs = {
				enable = true,
				perrow = 5,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				desaturate = true,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,nonPersonal", --TargetTargetTarget Debuffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			},
			strataAndLevel = {
				useCustomStrata = false,
				frameStrata = "LOW",
				useCustomLevel = false,
				frameLevel = 1
			}
		},
		focus = {
			enable = true,
			threatStyle = "GLOW",
			orientation = "MIDDLE",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			width = 190,
			height = 36,
			healPrediction = {
				enable = true,
				showAbsorbAmount = false,
				showOverAbsorbs = true
			},
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = true,
			health = {
				text_format = "",
				position = "RIGHT",
				xOffset = -2,
				yOffset = 0,
				attachTextTo = "Health",
				reverseFill = false
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				autoHide = false,
				reverseFill = false,
				text_format = "",
				width = "fill",
				height = 7,
				offset = 0,
				position = "LEFT",
				hideonnpc = false,
				xOffset = 2,
				yOffset = 0,
				attachTextTo = "Health",
				detachFromFrame = false,
				detachedWidth = 250,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				},
				parent = "FRAME"
			},
			infoPanel = {
				enable = false,
				height = 14,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				xOffset = 0,
				yOffset = 0,
				attachTextTo = "Health"
			},
			CombatIcon = {
				enable = true,
				defaultColor = true,
				color = {r = 1, g = 0.2, b = 0.2, a = 1},
				anchorPoint = "CENTER",
				xOffset = 0,
				yOffset = 0,
				size = 20,
				texture = "DEFAULT"
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				camDistanceScale = 2,
				rotation = 0,
				style = "3D",
				xOffset = 0,
				yOffset = 0,
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 7,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,PlayerBuffs,CastByUnit,Dispellable", --Focus Buffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			debuffs = {
				enable = true,
				perrow = 5,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "TOPRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				desaturate = true,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,RaidDebuffs,Dispellable,Whitelist", --Focus Debuffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			castbar = {
				enable = true,
				width = 190,
				height = 18,
				icon = true,
				format = "REMAINING",
				spark = true,
				displayTarget = false,
				iconSize = 32,
				iconAttached = true,
				insideInfoPanel = true,
				iconAttachedTo = "Frame",
				iconPosition = "LEFT",
				iconXOffset = -10,
				iconYOffset = 0,
				timeToHold = 0,
				hidetext = false,
				textColor = {r = 0.84, g = 0.75, b = 0.65, a = 1},
				xOffsetText = 4,
				yOffsetText = 0,
				xOffsetTime = -4,
				yOffsetTime = 0,
				overlayOnFrame = "None",
				reverse = false,
				customTextFont = {
					enable = false,
					font = "PT Sans Narrow",
					fontSize = 12,
					fontStyle = "OUTLINE"
				},
				customTimeFont = {
					enable = false,
					font = "PT Sans Narrow",
					fontSize = 12,
					fontStyle = "OUTLINE"
				},
				customColor = {
					enable = false,
					transparent = false,
					invertColors = false,
					useClassColor = false,
					useCustomBackdrop = false,
					useReactionColor = false,
					color = {r = 0.31, g = 0.31, b = 0.31},
					colorNoInterrupt = {r = 0.78, g = 0.25, b = 0.25},
					colorInterrupted = {r = 0.30, g = 0.30, b = 0.30},
					colorBackdrop = {r = 0.5, g = 0.5, b = 0.5, a = 1}
				},
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			aurabar = {
				enable = false,
				anchorPoint = "ABOVE",
				attachTo = "DEBUFFS",
				maxBars = 3,
				minDuration = 0,
				maxDuration = 120,
				priority = "Blacklist,blockNoDuration,Personal,PlayerBuffs,RaidDebuffs", --Focus AuraBars
				friendlyAuraType = "HELPFUL",
				enemyAuraType = "HARMFUL",
				height = 20,
				detachedWidth = 190,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				yOffset = 0,
				spacing = 0,
				clickThrough = false
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			GPSArrow = {
				enable = true,
				size = 45,
				xOffset = 0,
				yOffset = 0,
				onMouseOver = true,
				outOfRange = true,
				color = {r = 0.83, g = 0.16, b = 0.16}
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			},
			strataAndLevel = {
				useCustomStrata = false,
				frameStrata = "LOW",
				useCustomLevel = false,
				frameLevel = 1
			}
		},
		focustarget = {
			enable = false,
			threatStyle = "NONE",
			orientation = "MIDDLE",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			width = 190,
			height = 26,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = true,
			health = {
				text_format = "",
				position = "RIGHT",
				xOffset = -2,
				yOffset = 0,
				attachTextTo = "Health",
				reverseFill = false
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = false,
				autoHide = false,
				reverseFill = false,
				text_format = "",
				width = "fill",
				height = 7,
				offset = 0,
				position = "LEFT",
				hideonnpc = false,
				xOffset = 2,
				yOffset = 0,
				attachTextTo = "Health",
				detachFromFrame = false,
				detachedWidth = 250,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				},
				parent = "FRAME"
			},
			infoPanel = {
				enable = false,
				height = 12,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				yOffset = 0,
				xOffset = 0
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				camDistanceScale = 1,
				rotation = 0,
				style = "3D",
				xOffset = 0,
				yOffset = 0,
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 7,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,PlayerBuffs,Dispellable,CastByUnit", --FocusTarget Buffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			debuffs = {
				enable = false,
				perrow = 5,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				desaturate = true,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,RaidDebuffs,Dispellable,Whitelist", --FocusTarget Debuffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			},
			strataAndLevel = {
				useCustomStrata = false,
				frameStrata = "LOW",
				useCustomLevel = false,
				frameLevel = 1
			}
		},
		pet = {
			enable = true,
			orientation = "MIDDLE",
			threatStyle = "GLOW",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			width = 130,
			height = 36,
			healPrediction = {
				enable = true,
				showAbsorbAmount = false,
				showOverAbsorbs = true
			},
			disableMouseoverGlow = false,
			disableTargetGlow = true,
			disableFocusGlow = true,
			health = {
				text_format = "",
				position = "RIGHT",
				yOffset = 0,
				xOffset = -2,
				attachTextTo = "Health",
				reverseFill = false
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				autoHide = false,
				reverseFill = false,
				text_format = "",
				width = "fill",
				height = 7,
				offset = 0,
				position = "LEFT",
				hideonnpc = false,
				xOffset = 2,
				yOffset = 0,
				attachTextTo = "Health",
				detachFromFrame = false,
				detachedWidth = 250,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				},
				parent = "FRAME"
			},
			infoPanel = {
				enable = false,
				height = 12,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				yOffset = 0,
				xOffset = 0
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				camDistanceScale = 1,
				rotation = 0,
				style = "3D",
				xOffset = 0,
				yOffset = 0,
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 7,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,PlayerBuffs", --Pet Buffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			debuffs = {
				enable = false,
				perrow = 5,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				desaturate = true,
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,RaidDebuffs,Dispellable,Whitelist", --Pet Debuffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			aurabar = {
				enable = false,
				anchorPoint = "ABOVE",
				attachTo = "FRAME",
				maxBars = 6,
				minDuration = 0,
				maxDuration = 120,
				priority = "",
				friendlyAuraType = "HELPFUL",
				enemyAuraType = "HARMFUL",
				height = 20,
				detachedWidth = 130,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				yOffset = 2,
				spacing = 2,
				clickThrough = false
			},
			buffIndicator = {
				enable = true,
				profileSpecific = false,
				size = 8
			},
			castbar = {
				enable = true,
				width = 130,
				height = 18,
				icon = true,
				format = "REMAINING",
				spark = true,
				displayTarget = false,
				iconSize = 26,
				iconAttached = true,
				insideInfoPanel = true,
				iconAttachedTo = "Frame",
				iconPosition = "LEFT",
				iconXOffset = -10,
				iconYOffset = 0,
				timeToHold = 0,
				hidetext = false,
				textColor = {r = 0.84, g = 0.75, b = 0.65, a = 1},
				xOffsetText = 4,
				yOffsetText = 0,
				xOffsetTime = -4,
				yOffsetTime = 0,
				overlayOnFrame = "None",
				reverse = false,
				customTextFont = {
					enable = false,
					font = "PT Sans Narrow",
					fontSize = 12,
					fontStyle = "OUTLINE"
				},
				customTimeFont = {
					enable = false,
					font = "PT Sans Narrow",
					fontSize = 12,
					fontStyle = "OUTLINE"
				},
				customColor = {
					enable = false,
					transparent = false,
					invertColors = false,
					useClassColor = false,
					useCustomBackdrop = false,
					useReactionColor = false,
					color = {r = 0.31, g = 0.31, b = 0.31},
					colorNoInterrupt = {r = 0.78, g = 0.25, b = 0.25},
					colorInterrupted = {r = 0.30, g = 0.30, b = 0.30},
					colorBackdrop = {r = 0.5, g = 0.5, b = 0.5, a = 1}
				},
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			strataAndLevel = {
				useCustomStrata = false,
				frameStrata = "LOW",
				useCustomLevel = false,
				frameLevel = 1
			}
		},
		pettarget = {
			enable = false,
			threatStyle = "NONE",
			orientation = "MIDDLE",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			width = 130,
			height = 26,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = false,
			health = {
				text_format = "",
				position = "RIGHT",
				yOffset = 0,
				xOffset = -2,
				attachTextTo = "Health",
				reverseFill = false
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = false,
				autoHide = false,
				reverseFill = false,
				text_format = "",
				width = "fill",
				height = 7,
				offset = 0,
				position = "LEFT",
				hideonnpc = false,
				xOffset = 2,
				yOffset = 0,
				attachTextTo = "Health",
				detachFromFrame = false,
				detachedWidth = 250,
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				},
				parent = "FRAME"
			},
			infoPanel = {
				enable = false,
				height = 12,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				yOffset = 0,
				xOffset = 0
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				camDistanceScale = 1,
				rotation = 0,
				style = "3D",
				xOffset = 0,
				yOffset = 0,
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 7,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,PlayerBuffs,CastByUnit,Whitelist", --PetTarget Buffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			debuffs = {
				enable = false,
				perrow = 5,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "BOTTOMRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				desaturate = true,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,Personal,RaidDebuffs", --PetTarget Debuffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			},
			strataAndLevel = {
				useCustomStrata = false,
				frameStrata = "LOW",
				useCustomLevel = false,
				frameLevel = 1
			}
		},
		boss = {
			enable = true,
			growthDirection = "DOWN",
			threatStyle = "NONE",
			orientation = "RIGHT",
			smartAuraPosition = "DISABLED",
			colorOverride = "USE_DEFAULT",
			width = 216,
			height = 46,
			spacing = 25,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = false,
			health = {
				text_format = "[healthcolor][health:current]",
				position = "LEFT",
				yOffset = 0,
				xOffset = 2,
				attachTextTo = "Health",
				reverseFill = false
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				autoHide = false,
				reverseFill = false,
				text_format = "[powercolor][power:current]",
				width = "fill",
				height = 7,
				offset = 0,
				position = "RIGHT",
				hideonnpc = false,
				yOffset = 0,
				xOffset = -2,
				attachTextTo = "Health"
			},
			classbar = {
				enable = true,
				fill = "fill",
				height = 10,
				altPowerColor = {r = 0.2, g = 0.4, b = 0.8},
				altPowerTextFormat = "[altpower:current]"
			},
			portrait = {
				enable = false,
				width = 35,
				overlay = false,
				fullOverlay = false,
				camDistanceScale = 1,
				rotation = 0,
				style = "3D",
				xOffset = 0,
				yOffset = 0,
				overlayAlpha = 0.35
			},
			infoPanel = {
				enable = false,
				height = 16,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				yOffset = 0,
				xOffset = 0,
				attachTextTo = "Health"
			},
			buffs = {
				enable = true,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "LEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 0,
				priority = "Blacklist,CastByUnit,Whitelist", --Boss Buffs
				xOffset = 0,
				yOffset = 20,
				sizeOverride = 22,
				spacing = 1
			},
			debuffs = {
				enable = true,
				perrow = 3,
				numrows = 2,
				attachTo = "FRAME",
				anchorPoint = "LEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				desaturate = true,
				minDuration = 0,
				maxDuration = 0,
				priority = "Blacklist,Personal,RaidDebuffs,CastByUnit,Whitelist", --Boss Debuffs
				xOffset = 0,
				yOffset = -3,
				sizeOverride = 22,
				spacing = 1
			},
			castbar = {
				enable = true,
				width = 215,
				height = 18,
				icon = true,
				format = "REMAINING",
				spark = true,
				displayTarget = false,
				iconSize = 32,
				iconAttached = true,
				insideInfoPanel = true,
				iconAttachedTo = "Frame",
				iconPosition = "LEFT",
				iconXOffset = -10,
				iconYOffset = 0,
				timeToHold = 0,
				hidetext = false,
				textColor = {r = 0.84, g = 0.75, b = 0.65, a = 1},
				xOffsetText = 4,
				yOffsetText = 0,
				xOffsetTime = -4,
				yOffsetTime = 0,
				overlayOnFrame = "None",
				reverse = false,
				customTextFont = {
					enable = false,
					font = "PT Sans Narrow",
					fontSize = 12,
					fontStyle = "OUTLINE"
				},
				customTimeFont = {
					enable = false,
					font = "PT Sans Narrow",
					fontSize = 12,
					fontStyle = "OUTLINE"
				},
				customColor = {
					enable = false,
					transparent = false,
					invertColors = false,
					useClassColor = false,
					useCustomBackdrop = false,
					useReactionColor = false,
					color = {r = 0.31, g = 0.31, b = 0.31},
					colorNoInterrupt = {r = 0.78, g = 0.25, b = 0.25},
					colorInterrupted = {r = 0.30, g = 0.30, b = 0.30},
					colorBackdrop = {r = 0.5, g = 0.5, b = 0.5, a = 1}
				},
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		arena = {
			enable = true,
			growthDirection = "DOWN",
			orientation = "RIGHT",
			smartAuraPosition = "DISABLED",
			spacing = 25,
			width = 246,
			height = 47,
			healPrediction = {
				enable = true,
				showAbsorbAmount = false,
				showOverAbsorbs = true
			},
			colorOverride = "USE_DEFAULT",
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = false,
			health = {
				text_format = "[healthcolor][health:current]",
				position = "LEFT",
				yOffset = 0,
				xOffset = 2,
				attachTextTo = "Health",
				reverseFill = false
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				autoHide = false,
				reverseFill = false,
				text_format = "[powercolor][power:current]",
				width = "fill",
				height = 7,
				offset = 0,
				attachTextTo = "Health",
				position = "RIGHT",
				hideonnpc = false,
				yOffset = 0,
				xOffset = -2
			},
			infoPanel = {
				enable = false,
				height = 17,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				yOffset = 0,
				xOffset = 0,
				attachTextTo = "Health"
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				camDistanceScale = 2,
				rotation = 0,
				style = "3D",
				xOffset = 0,
				yOffset = 0,
				overlayAlpha = 0.35
			},
			buffs = {
				enable = true,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "LEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,TurtleBuffs,PlayerBuffs,Dispellable", --Arena Buffs
				xOffset = 0,
				yOffset = 16,
				sizeOverride = 27,
				spacing = 1
			},
			debuffs = {
				enable = true,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "LEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				desaturate = false,
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,blockNoDuration,Personal,CCDebuffs,Whitelist", --Arena Debuffs
				xOffset = 0,
				yOffset = -16,
				sizeOverride = 27,
				spacing = 1
			},
			castbar = {
				enable = true,
				width = 256,
				height = 18,
				icon = true,
				format = "REMAINING",
				spark = true,
				displayTarget = false,
				iconSize = 32,
				iconAttached = true,
				insideInfoPanel = true,
				iconAttachedTo = "Frame",
				iconPosition = "LEFT",
				iconXOffset = -10,
				iconYOffset = 0,
				timeToHold = 0,
				hidetext = false,
				textColor = {r = 0.84, g = 0.75, b = 0.65, a = 1},
				xOffsetText = 4,
				yOffsetText = 0,
				xOffsetTime = -4,
				yOffsetTime = 0,
				overlayOnFrame = "None",
				reverse = false,
				customTextFont = {
					enable = false,
					font = "PT Sans Narrow",
					fontSize = 12,
					fontStyle = "OUTLINE"
				},
				customTimeFont = {
					enable = false,
					font = "PT Sans Narrow",
					fontSize = 12,
					fontStyle = "OUTLINE"
				},
				customColor = {
					enable = false,
					transparent = false,
					invertColors = false,
					useClassColor = false,
					useCustomBackdrop = false,
					useReactionColor = false,
					color = {r = 0.31, g = 0.31, b = 0.31},
					colorNoInterrupt = {r = 0.78, g = 0.25, b = 0.25},
					colorInterrupted = {r = 0.30, g = 0.30, b = 0.30},
					colorBackdrop = {r = 0.5, g = 0.5, b = 0.5, a = 1}
				},
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			pvpTrinket = {
				enable = true,
				position = "RIGHT",
				size = 46,
				xOffset = 1,
				yOffset = 0
			},
			pvpSpecIcon = {
				enable = true,
				width = 0
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		party = {
			enable = true,
			threatStyle = "GLOW",
			orientation = "LEFT",
			visibility = "[@raid6,exists][nogroup] hide;show",
			growthDirection = "UP_RIGHT",
			horizontalSpacing = 0,
			verticalSpacing = 3,
			numGroups = 1,
			groupsPerRowCol = 1,
			groupBy = "INDEX",
			sortDir = "ASC",
			sortMethod = "INDEX",
			raidWideSorting = false,
			invertGroupingOrder = false,
			startFromCenter = false,
			showPlayer = true,
			healPrediction = {
				enable = false,
				showAbsorbAmount = false,
				showOverAbsorbs = true
			},
			colorOverride = "USE_DEFAULT",
			width = 184,
			height = 54,
			groupSpacing = 0,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = false,
			health = {
				text_format = "[healthcolor][health:current-percent]",
				position = "LEFT",
				orientation = "HORIZONTAL",
				attachTextTo = "Health",
				yOffset = 0,
				xOffset = 2,
				reverseFill = false
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				autoHide = false,
				reverseFill = false,
				text_format = "[powercolor][power:current]",
				attachTextTo = "Health",
				width = "fill",
				height = 7,
				offset = 0,
				position = "RIGHT",
				hideonnpc = false,
				yOffset = 0,
				xOffset = -2
			},
			infoPanel = {
				enable = false,
				height = 15,
				transparent = false
			},
			name = {
				position = "CENTER",
				attachTextTo = "Health",
				text_format = "[namecolor][name:medium] [difficultycolor][smartlevel]",
				yOffset = 0,
				xOffset = 0
			},
			phaseIndicator = {
				enable = false,
				anchorPoint = "CENTER",
				xOffset = 0,
				yOffset = 0,
				scale = 0.8,
				color = {r = 0.3, g = 0.5, b = 1}
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				camDistanceScale = 2,
				rotation = 0,
				style = "3D",
				xOffset = 0,
				yOffset = 0,
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 4,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "LEFT",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,TurtleBuffs", --Party Buffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			debuffs = {
				enable = true,
				perrow = 4,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "RIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				desaturate = true,
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,RaidDebuffs,CCDebuffs,Dispellable,Whitelist", --Party Debuffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			buffIndicator = {
				enable = true,
				profileSpecific = false,
				size = 8
			},
			rdebuffs = {
				enable = false,
				showDispellableDebuff = true,
				onlyMatchSpellID = true,
				fontSize = 10,
				font = "Homespun",
				fontOutline = "MONOCHROMEOUTLINE",
				size = 26,
				xOffset = 0,
				yOffset = 0,
				duration = {
					position = "CENTER",
					xOffset = 0,
					yOffset = 0,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				},
				stack = {
					position = "BOTTOMRIGHT",
					xOffset = 0,
					yOffset = 2,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				}
			},
			castbar = {
				enable = false,
				width = 256,
				height = 18,
				icon = true,
				format = "REMAINING",
				spark = true,
				displayTarget = false,
				iconSize = 32,
				iconAttached = true,
				insideInfoPanel = true,
				iconAttachedTo = "Frame",
				iconPosition = "LEFT",
				iconXOffset = -10,
				iconYOffset = 0,
				timeToHold = 0,
				hidetext = false,
				textColor = {r = 0.84, g = 0.75, b = 0.65, a = 1},
				xOffsetText = 4,
				yOffsetText = 0,
				xOffsetTime = -4,
				yOffsetTime = 0,
				overlayOnFrame = "None",
				reverse = false,
				customTextFont = {
					enable = false,
					font = "PT Sans Narrow",
					fontSize = 12,
					fontStyle = "OUTLINE"
				},
				customTimeFont = {
					enable = false,
					font = "PT Sans Narrow",
					fontSize = 12,
					fontStyle = "OUTLINE"
				},
				customColor = {
					enable = false,
					transparent = false,
					invertColors = false,
					useClassColor = false,
					useCustomBackdrop = false,
					useReactionColor = false,
					color = {r = 0.31, g = 0.31, b = 0.31},
					colorNoInterrupt = {r = 0.78, g = 0.25, b = 0.25},
					colorInterrupted = {r = 0.30, g = 0.30, b = 0.30},
					colorBackdrop = {r = 0.5, g = 0.5, b = 0.5, a = 1}
				},
				positionsGroup = {
					anchorPoint = "BOTTOM",
					xOffset = 0,
					yOffset = 0
				},
				strataAndLevel = {
					useCustomStrata = false,
					frameStrata = "LOW",
					useCustomLevel = false,
					frameLevel = 1
				}
			},
			classbar = {
				enable = true,
				fill = "fill",
				height = 10,
				altPowerColor = {r = 0.2, g = 0.4, b = 0.8},
				altPowerTextFormat = "[altpower:current]"
			},
			roleIcon = {
				enable = true,
				position = "TOPRIGHT",
				attachTo = "Health",
				xOffset = 0,
				yOffset = 0,
				size = 15,
				tank = true,
				healer = true,
				damager = true,
				combatHide = false
			},
			raidRoleIcons = {
				enable = true,
				position = "TOPLEFT",
				xOffset = 0,
				yOffset = 0
			},
			petsGroup = {
				enable = false,
				width = 100,
				height = 22,
				threatStyle = "GLOW",
				anchorPoint = "TOPLEFT",
				xOffset = -1,
				yOffset = 0,
				name = {
					position = "CENTER",
					text_format = "[namecolor][name:short]",
					yOffset = 0,
					xOffset = 0
				},
				healPrediction = {
					enable = false,
					showAbsorbAmount = false,
					showOverAbsorbs = true
				},
				raidicon = {
					enable = true,
					size = 18,
					attachTo = "TOP",
					attachToObject = "Frame",
					xOffset = 0,
					yOffset = 8
				}
			},
			targetsGroup = {
				enable = false,
				width = 100,
				height = 22,
				threatStyle = "GLOW",
				anchorPoint = "TOPLEFT",
				xOffset = -1,
				yOffset = 0,
				name = {
					position = "CENTER",
					text_format = "[namecolor][name:short]",
					yOffset = 0,
					xOffset = 0
				},
				raidicon = {
					enable = true,
					size = 18,
					attachTo = "TOP",
					attachToObject = "Frame",
					xOffset = 0,
					yOffset = 8
				}
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			GPSArrow = {
				enable = true,
				size = 45,
				xOffset = 0,
				yOffset = 0,
				onMouseOver = true,
				outOfRange = true,
				color = {r = 0.83, g = 0.16, b = 0.16}
			},
			readycheckIcon = {
				enable = true,
				size = 12,
				attachTo = "Health",
				position = "BOTTOM",
				xOffset = 0,
				yOffset = 2
			},
			resurrectIcon = {
				enable = true,
				size = 30,
				attachTo = "CENTER",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 0
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		raid = {
			enable = true,
			threatStyle = "GLOW",
			orientation = "MIDDLE",
			visibility = "[@raid6,noexists][@raid26,exists] hide;show",
			growthDirection = "RIGHT_DOWN",
			horizontalSpacing = 3,
			verticalSpacing = 3,
			numGroups = 5,
			groupsPerRowCol = 1,
			groupBy = "GROUP",
			sortDir = "ASC",
			sortMethod = "INDEX",
			showPlayer = true,
			healPrediction = {
				enable = false,
				showAbsorbAmount = false,
				showOverAbsorbs = true
			},
			colorOverride = "USE_DEFAULT",
			width = 80,
			height = 44,
			groupSpacing = 0,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = false,
			health = {
				text_format = "[healthcolor][health:deficit]",
				position = "BOTTOM",
				orientation = "HORIZONTAL",
				attachTextTo = "Health",
				yOffset = 2,
				xOffset = 0,
				reverseFill = false
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = true,
				autoHide = false,
				reverseFill = false,
				text_format = "",
				attachTextTo = "Health",
				width = "fill",
				height = 7,
				offset = 0,
				position = "BOTTOMRIGHT",
				hideonnpc = false,
				yOffset = 2,
				xOffset = -2
			},
			classbar = {
				enable = true,
				fill = "fill",
				height = 10,
				altPowerColor = {r = 0.2, g = 0.4, b = 0.8},
				altPowerTextFormat = "[altpower:current]"
			},
			infoPanel = {
				enable = false,
				height = 12,
				transparent = false
			},
			name = {
				position = "CENTER",
				attachTextTo = "Health",
				text_format = "[namecolor][name:short]",
				yOffset = 0,
				xOffset = 0
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				camDistanceScale = 2,
				rotation = 0,
				style = "3D",
				xOffset = 0,
				yOffset = 0,
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "LEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,TurtleBuffs", --Raid Buffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			debuffs = {
				enable = false,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "RIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				desaturate = true,
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,RaidDebuffs,CCDebuffs,Dispellable", --Raid Debuffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			buffIndicator = {
				enable = true,
				profileSpecific = false,
				size = 8
			},
			rdebuffs = {
				enable = true,
				showDispellableDebuff = true,
				onlyMatchSpellID = true,
				fontSize = 10,
				font = "Homespun",
				fontOutline = "MONOCHROMEOUTLINE",
				size = 26,
				xOffset = 0,
				yOffset = 2,
				duration = {
					position = "CENTER",
					xOffset = 0,
					yOffset = 0,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				},
				stack = {
					position = "BOTTOMRIGHT",
					xOffset = 0,
					yOffset = 2,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				}
			},
			roleIcon = {
				enable = true,
				position = "TOPLEFT",
				attachTo = "Health",
				xOffset = 1,
				yOffset = -1,
				size = 15,
				tank = true,
				healer = true,
				damager = true,
				combatHide = false
			},
			raidRoleIcons = {
				enable = true,
				position = "TOPLEFT",
				xOffset = 0,
				yOffset = 0
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			GPSArrow = {
				enable = true,
				size = 40,
				xOffset = 0,
				yOffset = 0,
				onMouseOver = true,
				outOfRange = true,
				color = {r = 0.83, g = 0.16, b = 0.16}
			},
			readycheckIcon = {
				enable = true,
				size = 12,
				attachTo = "Health",
				position = "BOTTOM",
				xOffset = 0,
				yOffset = 2
			},
			resurrectIcon = {
				enable = true,
				size = 30,
				attachTo = "CENTER",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 0
			},
			phaseIndicator = {
				enable = false,
				anchorPoint = "CENTER",
				xOffset = 0,
				yOffset = 0,
				scale = 0.8,
				color = {r = 0.3, g = 0.5, b = 1}
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		raid40 = {
			enable = true,
			threatStyle = "GLOW",
			orientation = "MIDDLE",
			visibility = "[@raid26,noexists] hide;show",
			growthDirection = "RIGHT_DOWN",
			horizontalSpacing = 3,
			verticalSpacing = 3,
			numGroups = 8,
			groupsPerRowCol = 1,
			groupBy = "GROUP",
			sortDir = "ASC",
			sortMethod = "INDEX",
			showPlayer = true,
			healPrediction = {
				enable = false,
				showAbsorbAmount = false,
				showOverAbsorbs = true
			},
			colorOverride = "USE_DEFAULT",
			width = 80,
			height = 27,
			groupSpacing = 0,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = false,
			health = {
				text_format = "[healthcolor][health:deficit]",
				position = "BOTTOM",
				orientation = "HORIZONTAL",
				attachTextTo = "Health",
				yOffset = 2,
				xOffset = 0,
				reverseFill = false
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			power = {
				enable = false,
				autoHide = false,
				reverseFill = false,
				text_format = "",
				attachTextTo = "Health",
				width = "fill",
				height = 7,
				offset = 0,
				position = "BOTTOMRIGHT",
				hideonnpc = false,
				yOffset = 2,
				xOffset = -2
			},
			classbar = {
				enable = true,
				fill = "fill",
				height = 10,
				altPowerColor = {r = 0.2, g = 0.4, b = 0.8},
				altPowerTextFormat = "[altpower:current]"
			},
			infoPanel = {
				enable = false,
				height = 12,
				transparent = false
			},
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:short]",
				yOffset = 0,
				xOffset = 0,
				attachTextTo = "Health"
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				camDistanceScale = 1,
				rotation = 0,
				style = "3D",
				xOffset = 0,
				yOffset = 0,
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "LEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,TurtleBuffs", --Raid40 Buffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			debuffs = {
				enable = false,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "RIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				desaturate = true,
				minDuration = 0,
				maxDuration = 300,
				priority = "Blacklist,RaidDebuffs,CCDebuffs,Dispellable,Whitelist", --Raid40 Debuffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			rdebuffs = {
				enable = false,
				showDispellableDebuff = true,
				onlyMatchSpellID = true,
				fontSize = 10,
				font = "Homespun",
				fontOutline = "MONOCHROMEOUTLINE",
				size = 22,
				xOffset = 0,
				yOffset = 0,
				duration = {
					position = "CENTER",
					xOffset = 0,
					yOffset = 0,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				},
				stack = {
					position = "BOTTOMRIGHT",
					xOffset = 0,
					yOffset = 2,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				}
			},
			roleIcon = {
				enable = false,
				position = "BOTTOMRIGHT",
				attachTo = "Health",
				xOffset = -1,
				yOffset = 1,
				size = 15,
				tank = true,
				healer = true,
				damager = true,
				combatHide = false
			},
			raidRoleIcons = {
				enable = true,
				position = "TOPLEFT",
				xOffset = 0,
				yOffset = 0
			},
			buffIndicator = {
				enable = true,
				profileSpecific = false,
				size = 8
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			GPSArrow = {
				enable = true,
				size = 45,
				xOffset = 0,
				yOffset = 0,
				onMouseOver = true,
				outOfRange = true,
				color = {r = 0.83, g = 0.16, b = 0.16}
			},
			readycheckIcon = {
				enable = true,
				size = 12,
				attachTo = "Health",
				position = "BOTTOM",
				xOffset = 0,
				yOffset = 2
			},
			resurrectIcon = {
				enable = true,
				size = 30,
				attachTo = "CENTER",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 0
			},
			phaseIndicator = {
				enable = false,
				anchorPoint = "CENTER",
				xOffset = 0,
				yOffset = 0,
				scale = 0.8,
				color = {r = 0.3, g = 0.5, b = 1}
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		raidpet = {
			enable = false,
			orientation = "MIDDLE",
			threatStyle = "GLOW",
			visibility = "[group:raid] show; hide",
			growthDirection = "DOWN_RIGHT",
			horizontalSpacing = 3,
			verticalSpacing = 3,
			numGroups = 2,
			groupsPerRowCol = 1,
			groupBy = "PETNAME",
			sortDir = "ASC",
			sortMethod = "INDEX",
			raidWideSorting = true,
			invertGroupingOrder = false,
			startFromCenter = false,
			healPrediction = {
				enable = true,
				showAbsorbAmount = false,
				showOverAbsorbs = true
			},
			colorOverride = "USE_DEFAULT",
			width = 80,
			height = 30,
			groupSpacing = 0,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = false,
			health = {
				text_format = "[healthcolor][health:deficit]",
				position = "BOTTOM",
				orientation = "HORIZONTAL",
				yOffset = 2,
				xOffset = 0,
				attachTextTo = "Health",
				reverseFill = false
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			name = {
				position = "TOP",
				text_format = "[namecolor][name:short]",
				yOffset = -2,
				xOffset = 0,
				attachTextTo = "Health"
			},
			portrait = {
				enable = false,
				width = 45,
				overlay = false,
				fullOverlay = false,
				camDistanceScale = 1,
				rotation = 0,
				style = "3D",
				xOffset = 0,
				yOffset = 0,
				overlayAlpha = 0.35
			},
			buffs = {
				enable = false,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "LEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 0,
				priority = "Blacklist,Personal,PlayerBuffs,blockNoDuration,nonPersonal", --RaidPet Buffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			debuffs = {
				enable = false,
				perrow = 3,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "RIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				desaturate = true,
				minDuration = 0,
				maxDuration = 0,
				priority = "Blacklist,Personal,Whitelist,RaidDebuffs,blockNoDuration,nonPersonal", --RaidPet Debuffs
				xOffset = 0,
				yOffset = 0,
				sizeOverride = 0,
				spacing = 1
			},
			buffIndicator = {
				enable = true,
				profileSpecific = false,
				size = 8
			},
			rdebuffs = {
				enable = true,
				showDispellableDebuff = true,
				onlyMatchSpellID = true,
				fontSize = 10,
				font = "Homespun",
				fontOutline = "MONOCHROMEOUTLINE",
				size = 26,
				xOffset = 0,
				yOffset = 2,
				duration = {
					position = "CENTER",
					xOffset = 0,
					yOffset = 0,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				},
				stack = {
					position = "BOTTOMRIGHT",
					xOffset = 0,
					yOffset = 2,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				}
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		tank = {
			enable = true,
			orientation = "LEFT",
			threatStyle = "GLOW",
			colorOverride = "USE_DEFAULT",
			width = 120,
			height = 28,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = true,
			disableDebuffHighlight = true,
			verticalSpacing = 7,
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				yOffset = 0,
				xOffset = 0,
				attachTextTo = "Health"
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			buffs = {
				enable = false,
				perrow = 6,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "TOPLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 0,
				priority = "",
				xOffset = 0,
				yOffset = 2,
				sizeOverride = 0,
				spacing = 1
			},
			debuffs = {
				enable = false,
				perrow = 6,
				numrows = 1,
				attachTo = "BUFFS",
				anchorPoint = "TOPRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				desaturate = true,
				minDuration = 0,
				maxDuration = 0,
				priority = "",
				xOffset = 0,
				yOffset = 1,
				sizeOverride = 0,
				spacing = 1
			},
			buffIndicator = {
				enable = true,
				profileSpecific = false,
				size = 8
			},
			rdebuffs = {
				enable = true,
				showDispellableDebuff = true,
				onlyMatchSpellID = true,
				fontSize = 10,
				font = "Homespun",
				fontOutline = "MONOCHROMEOUTLINE",
				size = 26,
				xOffset = 0,
				yOffset = 0,
				duration = {
					position = "CENTER",
					xOffset = 0,
					yOffset = 0,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				},
				stack = {
					position = "BOTTOMRIGHT",
					xOffset = 0,
					yOffset = 2,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				}
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			targetsGroup = {
				enable = true,
				anchorPoint = "RIGHT",
				xOffset = 1,
				yOffset = 0,
				width = 120,
				height = 28,
				colorOverride = "USE_DEFAULT",
				name = {
					position = "CENTER",
					text_format = "[namecolor][name:medium]",
					yOffset = 0,
					xOffset = 0,
					attachTextTo = "Health"
				},
				raidicon = {
					enable = true,
					size = 18,
					attachTo = "TOP",
					attachToObject = "Frame",
					xOffset = 0,
					yOffset = 8
				}
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		},
		assist = {
			enable = true,
			orientation = "LEFT",
			threatStyle = "GLOW",
			colorOverride = "USE_DEFAULT",
			width = 120,
			height = 28,
			disableMouseoverGlow = false,
			disableTargetGlow = false,
			disableFocusGlow = false,
			disableDebuffHighlight = true,
			verticalSpacing = 7,
			name = {
				position = "CENTER",
				text_format = "[namecolor][name:medium]",
				yOffset = 0,
				xOffset = 0,
				attachTextTo = "Health"
			},
			fader = {
				enable = true,
				range = true,
				hover = false,
				combat = false,
				playertarget = false,
				unittarget = false,
				focus = false,
				health = false,
				power = false,
				vehicle = false,
				casting = false,
				smooth = 0.33,
				minAlpha = 0.35,
				maxAlpha = 1,
				delay = 0
			},
			buffs = {
				enable = false,
				perrow = 6,
				numrows = 1,
				attachTo = "FRAME",
				anchorPoint = "TOPLEFT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				minDuration = 0,
				maxDuration = 0,
				priority = "",
				xOffset = 0,
				yOffset = 2,
				sizeOverride = 0,
				spacing = 1
			},
			debuffs = {
				enable = false,
				perrow = 6,
				numrows = 1,
				attachTo = "BUFFS",
				anchorPoint = "TOPRIGHT",
				countFont = "PT Sans Narrow",
				countFontOutline = "OUTLINE",
				countFontSize = 12,
				durationPosition = "CENTER",
				sortMethod = "TIME_REMAINING",
				sortDirection = "DESCENDING",
				clickThrough = false,
				desaturate = true,
				minDuration = 0,
				maxDuration = 0,
				priority = "",
				xOffset = 0,
				yOffset = 1,
				sizeOverride = 0,
				spacing = 1
			},
			buffIndicator = {
				enable = true,
				profileSpecific = false,
				size = 8
			},
			rdebuffs = {
				enable = true,
				showDispellableDebuff = true,
				onlyMatchSpellID = true,
				fontSize = 10,
				font = "Homespun",
				fontOutline = "MONOCHROMEOUTLINE",
				size = 26,
				xOffset = 0,
				yOffset = 0,
				duration = {
					position = "CENTER",
					xOffset = 0,
					yOffset = 0,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				},
				stack = {
					position = "BOTTOMRIGHT",
					xOffset = 0,
					yOffset = 2,
					color = {r = 1, g = 0.9, b = 0, a = 1}
				}
			},
			raidicon = {
				enable = true,
				size = 18,
				attachTo = "TOP",
				attachToObject = "Frame",
				xOffset = 0,
				yOffset = 8
			},
			targetsGroup = {
				enable = true,
				anchorPoint = "RIGHT",
				xOffset = 1,
				yOffset = 0,
				width = 120,
				height = 28,
				colorOverride = "USE_DEFAULT",
				name = {
					position = "CENTER",
					text_format = "[namecolor][name:medium]",
					yOffset = 0,
					xOffset = 0,
					attachTextTo = "Frame"
				},
				raidicon = {
					enable = true,
					size = 18,
					attachTo = "TOP",
					attachToObject = "Frame",
					xOffset = 0,
					yOffset = 8
				}
			},
			cutaway = {
				health = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				},
				power = {
					enabled = false,
					fadeOutTime = 0.6,
					lengthBeforeFade = 0.3,
					forceBlankTexture = true
				}
			}
		}
	}
}

for i = 1, GetNumClasses() do
	local classDisplayName, classTag = GetClassInfo(i)
	P.unitframe.units.party["CLASS"..i] = classTag
	P.unitframe.units.raid["CLASS"..i] = classTag
	P.unitframe.units.raid40["CLASS"..i] = classTag
	P.unitframe.units.raidpet["CLASS"..i] = classTag
end

for i, role in ipairs({"TANK", "HEALER", "DAMAGER"}) do
	P.unitframe.units.party["ROLE"..i] = role
	P.unitframe.units.raid["ROLE"..i] = role
	P.unitframe.units.raid40["ROLE"..i] = role
	P.unitframe.units.raidpet["ROLE"..i] = role
end

--Cooldown
P.cooldown = {
	enable = true,
	threshold = 3,
	expiringColor = {r = 1, g = 0, b = 0},
	secondsColor = {r = 1, g = 1, b = 0},
	minutesColor = {r = 1, g = 1, b = 1},
	hoursColor = {r = 0.4, g = 1, b = 1},
	daysColor = {r = 0.4, g = 0.4, b = 1},
	expireIndicator = {r = 1, g = 1, b = 1},
	secondsIndicator = {r = 1, g = 1, b = 1},
	minutesIndicator = {r = 1, g = 1, b = 1},
	hoursIndicator = {r = 1, g = 1, b = 1},
	daysIndicator = {r = 1, g = 1, b = 1},
	hhmmColorIndicator = {r = 1, g = 1, b = 1},
	mmssColorIndicator = {r = 1, g = 1, b = 1},

	checkSeconds = false,
	hhmmColor = {r = 0.43, g = 0.43, b = 0.43},
	mmssColor = {r = 0.56, g = 0.56, b = 0.56},
	hhmmThreshold = -1,
	mmssThreshold = -1,

	fonts = {
		enable = false,
		font = "PT Sans Narrow",
		fontOutline = "OUTLINE",
		fontSize = 18
	}
}

--Actionbar
P.actionbar = {
	font = "Homespun",
	fontSize = 10,
	fontOutline = "MONOCHROMEOUTLINE",
	fontColor = {r = 1, g = 1, b = 1},

	flyoutSize = 32, -- match buttonsize default, blizz default is 28

	macrotext = false,
	hotkeytext = true,

	hotkeyTextPosition = "TOPRIGHT",
	hotkeyTextXOffset = 0,
	hotkeyTextYOffset = -3,

	countTextPosition = "BOTTOMRIGHT",
	countTextXOffset = 0,
	countTextYOffset = 2,

	keyDown = true,
	movementModifier = "SHIFT",
	transparentBackdrops = false,
	transparentButtons = false,
	globalFadeAlpha = 0,
	lockActionBars = true,
	addNewSpells = false,
	rightClickSelfCast = false,
	desaturateOnCooldown = false,

	equippedItem = false,
	equippedItemColor = {r = 0.4, g = 1.0, b = 0.4},

	useRangeColorText = false,
	noRangeColor = {r = 0.8, g = 0.1, b = 0.1},
	noPowerColor = {r = 0.5, g = 0.5, b = 1},
	usableColor = {r = 1, g = 1, b = 1},
	notUsableColor = {r = 0.4, g = 0.4, b = 0.4},

	flashAnimation = false,
	handleOverlay = true,

	cooldown = {
		threshold = 4,
		override = false,
		reverse = false,
		expiringColor = {r = 1, g = 0, b = 0},
		secondsColor = {r = 1, g = 1, b = 1},
		minutesColor = {r = 1, g = 1, b = 1},
		hoursColor = {r = 1, g = 1, b = 1},
		daysColor = {r = 1, g = 1, b = 1},
		expireIndicator = {r = 1, g = 1, b = 1},
		secondsIndicator = {r = 1, g = 1, b = 1},
		minutesIndicator = {r = 1, g = 1, b = 1},
		hoursIndicator = {r = 1, g = 1, b = 1},
		daysIndicator = {r = 1, g = 1, b = 1},
		hhmmColorIndicator = {r = 1, g = 1, b = 1},
		mmssColorIndicator = {r = 1, g = 1, b = 1},

		checkSeconds = false,
		hhmmColor = {r = 1, g = 1, b = 1},
		mmssColor = {r = 1, g = 1, b = 1},
		hhmmThreshold = -1,
		mmssThreshold = -1,

		fonts = {
			enable = false,
			font = "PT Sans Narrow",
			fontOutline = "OUTLINE",
			fontSize = 18
		}
	},
	barPet = {
		enabled = true,
		mouseover = false,
		clickThrough = false,
		hideHotkey = false,
		buttons = NUM_PET_ACTION_SLOTS,
		buttonsPerRow = 1,
		point = "TOPRIGHT",
		backdrop = true,
		heightMult = 1,
		widthMult = 1,
		buttonSize = 32,
		buttonSpacing = 2,
		backdropSpacing = 2,
		alpha = 1,
		frameStrata = "LOW",
		frameLevel = 1,
		inheritGlobalFade = false,
		visibility = "[petbattle] hide;[pet,novehicleui,nooverridebar,nopossessbar] show;hide"
	},
	stanceBar = {
		enabled = true,
		style = "darkenInactive",
		mouseover = false,
		clickThrough = false,
		hideHotkey = false,
		buttonsPerRow = NUM_STANCE_SLOTS,
		buttons = NUM_STANCE_SLOTS,
		point = "TOPLEFT",
		backdrop = false,
		heightMult = 1,
		widthMult = 1,
		buttonSize = 32,
		buttonSpacing = 2,
		backdropSpacing = 2,
		alpha = 1,
		frameStrata = "LOW",
		frameLevel = 1,
		inheritGlobalFade = false,
		visibility = "[vehicleui] hide; [petbattle] hide;show"
	},
	microbar = {
		enabled = false,
		mouseover = false,
		buttonsPerRow = 12,
		buttonSize = 20,
		buttonSpacing = 2,
		backdrop = false,
		transparentBackdrop = false,
		backdropSpacing = 2,
		alpha = 1,
		visibility = "[petbattle] hide; show"
	},
	extraActionButton = {
		alpha = 1,
		scale = 1,
		hideHotkey = false,
		inheritGlobalFade = false
	},
	vehicleExitButton = {
		enable = true,
		size = 32,
		frameStrata = "LOW",
		frameLevel = 1
	}
}

for i = 1, 10 do
	P.actionbar["bar"..i] = {
		enabled = false,
		mouseover = false,
		clickThrough = false,
		buttons = 12,
		buttonsPerRow = 12,
		point = "BOTTOMLEFT",
		backdrop = false,
		heightMult = 1,
		widthMult = 1,
		buttonSize = 32,
		buttonSpacing = 2,
		backdropSpacing = 2,
		alpha = 1,
		frameStrata = "LOW",
		frameLevel = 1,
		inheritGlobalFade = false,
		showGrid = true,
		flyoutDirection = "AUTOMATIC",
		paging = {},
		visibility = "[vehicleui] hide; [overridebar] hide; [petbattle] hide; show",
		countFont = "Homespun",
		countFontOutline = "MONOCHROMEOUTLINE",
		countFontSize = 10,
		countFontXOffset = 0,
		countFontYOffset = 2,
		countTextPosition = "BOTTOMRIGHT",
		customCountFont = false,
		customHotkeyFont = false,
		hideHotkey = false,
		hideMacroText = false,
		hotkeyFont = "Homespun",
		hotkeyFontOutline = "MONOCHROMEOUTLINE",
		hotkeyFontSize = 10,
		hotkeyTextPosition = "TOPRIGHT",
		hotkeyTextXOffset = 0,
		hotkeyTextYOffset = -3,
		useHotkeyColor = false,
		hotkeyColor = {r = 1, g = 1, b = 1},
		useCountColor = false,
		countColor = {r = 1, g = 1, b = 1},
		useMacroColor = false,
		macroColor = {r = 1, g = 1, b = 1}
	}
end

P.actionbar.bar1.enabled = true
P.actionbar.bar1.visibility = "[petbattle] hide; show"
P.actionbar.bar1.paging = {
	DRUID = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	PRIEST = "[bonusbar:1] 7;",
	ROGUE = "[stance:1] 7;  [stance:2] 7; [stance:3] 7;",
	MONK = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	WARRIOR = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;"
}

P.actionbar.bar3.enabled = true
P.actionbar.bar3.buttons = 6
P.actionbar.bar3.buttonsPerRow = 6

P.actionbar.bar4.enabled = true
P.actionbar.bar4.buttonsPerRow = 1
P.actionbar.bar4.point = "TOPRIGHT"
P.actionbar.bar4.backdrop = true

P.actionbar.bar5.enabled = true
P.actionbar.bar5.buttons = 6
P.actionbar.bar5.buttonsPerRow = 6

--Mover positions that are set inside the installation process. ALL is used still to prevent people from getting pissed off
--This allows movers positions to be reset to whatever profile is being used
E.LayoutMoverPositions = {
	ALL = {
		AlertFrameMover = "TOP,ElvUIParent,TOP,-1,-18",
		AltPowerBarMover = "TOP,ElvUIParent,TOP,-1,-36",
		BNETMover = "TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-274",
		BossButton = "BOTTOM,ElvUIParent,BOTTOM,-1,293",
		ElvAB_1 = "BOTTOM,ElvUIParent,BOTTOM,1,190",
		ElvAB_2 = "BOTTOM,ElvUIParent,BOTTOM,0,4",
		ElvAB_3 = "BOTTOM,ElvUIParent,BOTTOM,1,138",
		ElvAB_5 = "BOTTOM,ElvUIParent,BOTTOM,-92,57",
		ElvUF_FocusMover = "BOTTOM,ElvUIParent,BOTTOM,341,59",
		ElvUF_PartyMover = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,248",
		ElvUF_PetMover = "BOTTOM,ElvUIParent,BOTTOM,-340,99",
		ElvUF_PlayerCastbarMover = "BOTTOM,ElvUIParent,BOTTOM,1,96",
		ElvUF_PlayerMover = "BOTTOM,ElvUIParent,BOTTOM,-340,138",
		ElvUF_Raid40Mover = "TOPLEFT,ElvUIParent,BOTTOMLEFT,4,482",
		ElvUF_RaidMover = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,4,248",
		ElvUF_RaidpetMover = "TOPLEFT,ElvUIParent,BOTTOMLEFT,4,737",
		ElvUF_TargetCastbarMover = "BOTTOM,ElvUIParent,BOTTOM,1,242",
		ElvUF_TargetMover = "BOTTOM,ElvUIParent,BOTTOM,341,138",
		ElvUF_TargetTargetMover = "BOTTOM,ElvUIParent,BOTTOM,341,99",
		ExperienceBarMover = "BOTTOM,ElvUIParent,BOTTOM,0,43",
		LootFrameMover = "TOPLEFT,ElvUIParent,TOPLEFT,418,-186",
		LossControlMover = "BOTTOM,ElvUIParent,BOTTOM,-1,507",
		MirrorTimer1Mover = "TOP,ElvUIParent,TOP,-1,-96",
		WatchFrameMover = "TOPRIGHT,ElvUIParent,TOPRIGHT,-163,-325",
		ReputationBarMover = "TOPRIGHT,ElvUIParent,TOPRIGHT,-4,-246",
		ShiftAB = "TOPLEFT,ElvUIParent,BOTTOMLEFT,4,769",
		TotemBarMover = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,485,4",
		VehicleSeatMover = "TOPLEFT,ElvUIParent,TOPLEFT,4,-4"
	},
	dpsCaster = {
		ElvUF_PlayerCastbarMover = "BOTTOM,ElvUIParent,BOTTOM,1,243",
		ElvUF_TargetCastbarMover = "BOTTOM,ElvUIParent,BOTTOM,1,97"
	},
	healer = {
		ElvUF_PlayerCastbarMover = "BOTTOM,ElvUIParent,BOTTOM,1,243",
		ElvUF_TargetCastbarMover = "BOTTOM,ElvUIParent,BOTTOM,1,97",
		ElvUF_RaidMover = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,202,373",
		LootFrameMover = "TOPLEFT,ElvUIParent,TOPLEFT,250,-104",
		ShiftAB = "TOPLEFT,ElvUIParent,BOTTOMLEFT,4,273"
	}
}