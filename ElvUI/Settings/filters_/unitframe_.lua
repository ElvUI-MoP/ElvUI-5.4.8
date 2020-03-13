local E, L, V, P, G = unpack(select(2, ...))

local print, unpack = print, unpack

local GetSpellInfo = GetSpellInfo

local function SpellName(id)
	local name = GetSpellInfo(id)
	if not name then
		print("|cff1784d1ElvUI:|r SpellID is not valid: "..id..". Please check for an updated version, if none exists report to ElvUI author.")
		return "Impale"
	else
		return name
	end
end

local function Defaults(priorityOverride)
	return {["enable"] = true, ["priority"] = priorityOverride or 0, ["stackThreshold"] = 0}
end

G.unitframe.aurafilters = {}

G.unitframe.aurafilters["CCDebuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Death Knight
		[47476] = Defaults(),	-- Strangulate
		[49203] = Defaults(),	-- Hungering Cold
		[91800] = Defaults(),	-- Gnaw (Pet)
		[91807] = Defaults(),	-- Shambling Rush (Pet)
		[91797] = Defaults(),	-- Monstrous Blow (Pet)
		[108194] = Defaults(),	-- Asphyxiate
		[115001] = Defaults(),	-- Remorseless Winter
	-- Druid
		[33786] = Defaults(),	-- Cyclone
		[2637] = Defaults(),	-- Hibernate
		[339] = Defaults(),		-- Entangling Roots
		[78675] = Defaults(),	-- Solar Beam
		[22570] = Defaults(),	-- Maim
		[5211] = Defaults(),	-- Mighty Bash
		[9005] = Defaults(),	-- Pounce
		[102359] = Defaults(),	-- Mass Entanglement
		[99] = Defaults(),		-- Disorienting Roar
		[127797] = Defaults(),	-- Ursol's Vortex
		[45334] = Defaults(),	-- Immobilized
		[102795] = Defaults(),	-- Bear Hug
		[114238] = Defaults(),	-- Fae Silence
		[113004] = Defaults(),	-- Intimidating Roar (Warrior Symbiosis)
	-- Hunter
		[3355] = Defaults(),	-- Freezing Trap
		[1513] = Defaults(),	-- Scare Beast
		[19503] = Defaults(),	-- Scatter Shot
		[34490] = Defaults(),	-- Silencing Shot
		[24394] = Defaults(),	-- Intimidation
		[64803] = Defaults(),	-- Entrapment
		[19386] = Defaults(),	-- Wyvern Sting
		[117405] = Defaults(),	-- Binding Shot
		[128405] = Defaults(),	-- Narrow Escape
		[50519] = Defaults(),	-- Sonic Blast (Bat)
		[91644] = Defaults(),	-- Snatch (Bird of Prey)
		[90337] = Defaults(),	-- Bad Manner (Monkey)
		[54706] = Defaults(),	-- Venom Web Spray (Silithid)
		[4167] = Defaults(),	-- Web (Spider)
		[90327] = Defaults(),	-- Lock Jaw (Dog)
		[56626] = Defaults(),	-- Sting (Wasp)
		[50245] = Defaults(),	-- Pin (Crab)
		[50541] = Defaults(),	-- Clench (Scorpid)
		[96201] = Defaults(),	-- Web Wrap (Shale Spider)
		[96201] = Defaults(),	-- Lullaby (Crane)
	-- Mage
		[31661] = Defaults(),	-- Dragon's Breath
		[118] = Defaults(),		-- Polymorph
		[55021] = Defaults(),	-- Silenced - Improved Counterspell
		[122] = Defaults(),		-- Frost Nova
		[82691] = Defaults(),	-- Ring of Frost
		[118271] = Defaults(),	-- Combustion Impact
		[44572] = Defaults(),	-- Deep Freeze
		[33395] = Defaults(),	-- Freeze (Water Ele)
		[102051] = Defaults(),	-- Frostjaw
	-- Paladin
		[20066] = Defaults(),	-- Repentance
		[10326] = Defaults(),	-- Turn Evil
		[853] = Defaults(),		-- Hammer of Justice
		[105593] = Defaults(),	-- Fist of Justice
		[31935] = Defaults(),	-- Avenger's Shield
		[105421] = Defaults(),	-- Blinding Light
	-- Priest
		[605] = Defaults(),		-- Dominate Mind
		[64044] = Defaults(),	-- Psychic Horror
		--[64058] = Defaults(),	-- Psychic Horror (Disarm)
		[8122] = Defaults(),	-- Psychic Scream
		[9484] = Defaults(),	-- Shackle Undead
		[15487] = Defaults(),	-- Silence
		[114404] = Defaults(),	-- Void Tendrils
		[88625] = Defaults(),	-- Holy Word: Chastise
		[113792] = Defaults(),	-- Psychic Terror (Psyfiend)
		[87194] = Defaults(),	-- Sin and Punishment
	-- Rogue
		[2094] = Defaults(),	-- Blind
		[1776] = Defaults(),	-- Gouge
		[6770] = Defaults(),	-- Sap
		[1833] = Defaults(),	-- Cheap Shot
		[51722] = Defaults(),	-- Dismantle
		[1330] = Defaults(),	-- Garrote - Silence
		[408] = Defaults(),		-- Kidney Shot
		[88611] = Defaults(),	-- Smoke Bomb
		[115197] = Defaults(),	-- Partial Paralytic
		[113953] = Defaults(),	-- Paralysis
	-- Shaman
		[51514] = Defaults(),	-- Hex
		[64695] = Defaults(),	-- Earthgrab
		[63685] = Defaults(),	-- Freeze (Frozen Power)
		[76780] = Defaults(),	-- Bind Elemental
		[118905] = Defaults(),	-- Static Charge
		[118345] = Defaults(),	-- Pulverize (Earth Elemental)
	-- Warlock
		[710] = Defaults(),		-- Banish
		[6789] = Defaults(),	-- Mortal Coil
		[118699] = Defaults(),	-- Fear
		[5484] = Defaults(),	-- Howl of Terror
		[6358] = Defaults(),	-- Seduction
		[30283] = Defaults(),	-- Shadowfury
		[24259] = Defaults(),	-- Spell Lock (Felhunter)
		[115782] = Defaults(),	-- Optical Blast (Observer)
		[115268] = Defaults(),	-- Mesmerize (Shivarra)
		[118093] = Defaults(),	-- Disarm (Voidwalker)
		[89766] = Defaults(),	-- Axe Toss (Felguard)
		[137143] = Defaults(),	-- Blood Horror
	-- Warrior
		[20511] = Defaults(),	-- Intimidating Shout
		[7922] = Defaults(),	-- Charge Stun
		[676] = Defaults(),		-- Disarm
		[105771] = Defaults(),	-- Warbringer
		[107566] = Defaults(),	-- Staggering Shout
		[132168] = Defaults(),	-- Shockwave
		[107570] = Defaults(),	-- Storm Bolt
		[118895] = Defaults(),	-- Dragon Roar
		[18498] = Defaults(),	-- Gag Order
	-- Monk
		[116706] = Defaults(),	-- Disable
		[117368] = Defaults(),	-- Grapple Weapon
		[115078] = Defaults(),	-- Paralysis
		[122242] = Defaults(),	-- Clash
		[119392] = Defaults(),	-- Charging Ox Wave
		[119381] = Defaults(),	-- Leg Sweep
		[120086] = Defaults(),	-- Fists of Fury
		[116709] = Defaults(),	-- Spear Hand Strike
		[123407] = Defaults(),	-- Spinning Fire Blossom
		[140023] = Defaults(),	-- Ring of Peace
	-- Racial
		[25046] = Defaults(),	-- Arcane Torrent
		[20549] = Defaults(),	-- War Stomp
		[107079] = Defaults() 	-- Quaking Palm
	}
}

G.unitframe.aurafilters["TurtleBuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Mage
		[45438] = Defaults(5),	-- Ice Block
		[115610] = Defaults(),	-- Temporal Shield
	-- Death Knight
		[48797] = Defaults(5),	-- Anti-Magic Shell
		[48792] = Defaults(),	-- Icebound Fortitude
		[49039] = Defaults(),	-- Lichborne
		[87256] = Defaults(4),	-- Dancing Rune Weapon
		[55233] = Defaults(),	-- Vampiric Blood
		[50461] = Defaults(),	-- Anti-Magic Zone
	-- Priest
		[33206] = Defaults(3),	-- Pain Suppression
		[47788] = Defaults(),	-- Guardian Spirit
		[62618] = Defaults(),	-- Power Word: Barrier
		[47585] = Defaults(5),	-- Dispersion
	--Warlock
		[104773] = Defaults(),	-- Unending Resolve
		[110913] = Defaults(),	-- Dark Bargain
		[108359] = Defaults(),	-- Dark Regeneration
	-- Druid
		[22812] = Defaults(2),	-- Barkskin
		[102342] = Defaults(2),	-- Ironbark
		[106922] = Defaults(),	-- Might of Ursoc
		[61336] = Defaults(),	-- Survival Instincts
	-- Hunter
		[19263] = Defaults(5),	-- Deterrence
		[53480] = Defaults(),	-- Roar of Sacrifice (Cunning)
	-- Rogue
		[1966] = Defaults(),	-- Feint
		[31224] = Defaults(),	-- Cloak of Shadows
		[74001] = Defaults(),	-- Combat Readiness
		--[74002] = Defaults(),	-- Combat Insight (stacking buff from CR)
		[5277] = Defaults(5),	-- Evasion
		[45182] = Defaults(),	-- Cheating Death
	-- Shaman
		[98007] = Defaults(),	-- Spirit Link Totem
		[30823] = Defaults(),	-- Shamanistic Rage
		[108271] = Defaults(),	-- Astral Shift
	-- Paladin
		[1022] = Defaults(5),	-- Hand of Protection
		[6940] = Defaults(),	-- Hand of Sacrifice
		[114039] = Defaults(),	-- Hand of Purity
		[31821] = Defaults(3),	-- Devotion Aura
		[498] = Defaults(2),	-- Divine Protection
		[642] = Defaults(5),	-- Divine Shield
		[86659] = Defaults(4),	-- Guardian of the Ancient Kings (Prot)
		[31850] = Defaults(4),	-- Ardent Defender
	-- Warrior
		[118038] = Defaults(5),	-- Die by the Sword
		[55694] = Defaults(),	-- Enraged Regeneration
		[97463] = Defaults(),	-- Rallying Cry
		[12975] = Defaults(),	-- Last Stand
		[114029] = Defaults(2),	-- Safeguard
		[871] = Defaults(3),	-- Shield Wall
		[114030] = Defaults(),	-- Vigilance
	--Monk
		[120954] = Defaults(2),	-- Fortifying Brew
		[131523] = Defaults(5),	-- Zen Meditation
		[122783] = Defaults(),	-- Diffuse Magic
		[122278] = Defaults(),	-- Dampen Harm
		[115213] = Defaults(),	-- Avert Harm
		[116849] = Defaults(),	-- Life Cocoon
	--Racial
		[20594] = Defaults()	-- Stoneform
	}
}

G.unitframe.aurafilters["PlayerBuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Mage
		[45438] = Defaults(),	-- Ice Block
		[115610] = Defaults(),	-- Temporal Shield
		[110909] = Defaults(),	-- Alter Time
		[12051] = Defaults(),	-- Evocation
		[12472] = Defaults(),	-- Icy Veins
		[80353] = Defaults(),	-- Time Warp
		[12042] = Defaults(),	-- Arcane Power
		[32612] = Defaults(),	-- Invisibility
		[110960] = Defaults(),	-- Greater Invisibility
		[108839] = Defaults(),	-- Ice Flows
		[111264] = Defaults(),	-- Ice Ward
		[108843] = Defaults(),	-- Blazing Speed
	-- Death Knight
		[48797] = Defaults(),	-- Anti-Magic Shell
		[48792] = Defaults(),	-- Icebound Fortitude
		[49039] = Defaults(),	-- Lichborne
		[87256] = Defaults(),	-- Dancing Rune Weapon
		[49222] = Defaults(),	-- Bone Shield
		[55233] = Defaults(),	-- Vampiric Blood
		[50461] = Defaults(),	-- Anti-Magic Zone
		[49016] = Defaults(),	-- Unholy Frenzy
		[51271] = Defaults(),	-- Pillar of Frost
		[96268] = Defaults(),	-- Death's Advance
	-- Priest
		[33206] = Defaults(),	-- Pain Suppression
		[47788] = Defaults(),	-- Guardian Spirit
		[62618] = Defaults(),	-- Power Word: Barrier
		[47585] = Defaults(),	-- Dispersion
		[6346] = Defaults(),	-- Fear Ward
		[10060] = Defaults(),	-- Power Infusion
		[114239] = Defaults(),	-- Phantasm
		[119032] = Defaults(),	-- Spectral Guise
		[27827] = Defaults(),	-- Spirit of Redemption
	-- Warlock
		[104773] = Defaults(),	-- Unending Resolve
		[110913] = Defaults(),	-- Dark Bargain
		[108359] = Defaults(),	-- Dark Regeneration
		[113860] = Defaults(),	-- Dark Sould: Misery
		[113861] = Defaults(),	-- Dark Soul: Knowledge
		[113858] = Defaults(),	-- Dark Soul: Instability
		[88448] = Defaults(),	-- Demonic Rebirth
	-- Druid
		[22812] = Defaults(),	-- Barkskin
		[102342] = Defaults(),	-- Ironbark
		[106922] = Defaults(),	-- Might of Ursoc
		[61336] = Defaults(),	-- Survival Instincts
		[117679] = Defaults(),	-- Incarnation (Tree of Life)
		[102543] = Defaults(),	-- Incarnation: King of the Jungle
		[102558] = Defaults(),	-- Incarnation: Son of Ursoc
		[102560] = Defaults(),	-- Incarnation: Chosen of Elune
		[16689] = Defaults(),	-- Nature's Grasp
		[132158] = Defaults(),	-- Nature's Swiftness
		[106898] = Defaults(),	-- Stampeding Roar
		[1850] = Defaults(),	-- Dash
		[106951] = Defaults(),	-- Berserk
		[29166] = Defaults(),	-- Innervate
		[52610] = Defaults(),	-- Savage Roar
		[69369] = Defaults(),	-- Predatory Swiftness
		[112071] = Defaults(),	-- Celestial Alignment
		[124974] = Defaults(),	-- Nature's Vigil
	-- Hunter
		[19263] = Defaults(),	-- Deterrence
		[53480] = Defaults(),	-- Roar of Sacrifice (Cunning)
		[51755] = Defaults(),	-- Camouflage
		[54216] = Defaults(),	-- Master's Call
		[34471] = Defaults(),	-- The Beast Within
		[3045] = Defaults(),	-- Rapid Fire
		[3584] = Defaults(),	-- Feign Death
		[131894] = Defaults(),	-- A Murder of Crows
		[90355] = Defaults(),	-- Ancient Hysteria
		[90361] = Defaults(),	-- Spirit Mend
	-- Rogue
		[31224] = Defaults(),	-- Cloak of Shadows
		[74001] = Defaults(),	-- Combat Readiness
		--[74002] = Defaults(),	-- Combat Insight (stacking buff from CR)
		[5277] = Defaults(),	-- Evasion
		[45182] = Defaults(),	-- Cheating Death
		[51713] = Defaults(),	-- Shadow Dance
		[114018] = Defaults(),	-- Shroud of Concealment
		[2983] = Defaults(),	-- Sprint
		[121471] = Defaults(),	-- Shadow Blades
		[11327] = Defaults(),	-- Vanish
		[108212] = Defaults(),	-- Burst of Speed
		[57933] = Defaults(),	-- Tricks of the Trade
		[79140] = Defaults(),	-- Vendetta
		[13750] = Defaults(),	-- Adrenaline Rush
	-- Shaman
		[98007] = Defaults(),	-- Spirit Link Totem
		[30823] = Defaults(),	-- Shamanistic Rage
		[108271] = Defaults(),	-- Astral Shift
		[16188] = Defaults(),	-- Ancestral Swiftness
		[2825] = Defaults(),	-- Bloodlust
		[79206] = Defaults(),	-- Spiritwalker's Grace
		[16191] = Defaults(),	-- Mana Tide
		[8178] = Defaults(),	-- Grounding Totem Effect
		[58875] = Defaults(),	-- Spirit Walk
		[108281] = Defaults(),	-- Ancestral Guidance
		[108271] = Defaults(),	-- Astral Shift
		[16166] = Defaults(),	-- Elemental Mastery
		[114896] = Defaults(),	-- Windwalk Totem
	-- Paladin
		[1044] = Defaults(),	-- Hand of Freedom
		[1022] = Defaults(),	-- Hand of Protection
		[1038] = Defaults(),	-- Hand of Salvation
		[6940] = Defaults(),	-- Hand of Sacrifice
		[114039] = Defaults(),	-- Hand of Purity
		[31821] = Defaults(),	-- Devotion Aura
		[498] = Defaults(),		-- Divine Protection
		[642] = Defaults(),		-- Divine Shield
		[86659] = Defaults(),	-- Guardian of the Ancient Kings (Prot)
		[20925] = Defaults(),	-- Sacred Shield
		[31850] = Defaults(),	-- Ardent Defender
		[31884] = Defaults(),	-- Avenging Wrath
		[53563] = Defaults(),	-- Beacon of Light
		[31842] = Defaults(),	-- Divine Favor
		[54428] = Defaults(),	-- Divine Plea
		[105809] = Defaults(),	-- Holy Avenger
		[85499] = Defaults(),	-- Speed of Light
	-- Warrior
		[118038] = Defaults(),	-- Die by the Sword
		[55694] = Defaults(),	-- Enraged Regeneration
		[97463] = Defaults(),	-- Rallying Cry
		[12975] = Defaults(),	-- Last Stand
		[114029] = Defaults(),	-- Safeguard
		[871] = Defaults(),		-- Shield Wall
		[114030] = Defaults(),	-- Vigilance
		[18499] = Defaults(),	-- Berserker Rage
		--[85730] = Defaults(),	-- Deadly Calm
		[1719] = Defaults(),	-- Recklessness
		[23920] = Defaults(),	-- Spell Reflection
		[114028] = Defaults(),	-- Mass Spell Reflection
		[46924] = Defaults(),	-- Bladestorm
		[3411] = Defaults(),	-- Intervene
		[107574] = Defaults(),	-- Avatar
	--Monk
		[120954] = Defaults(),	-- Fortifying Brew
		[131523] = Defaults(),	-- Zen Meditation
		[122783] = Defaults(),	-- Diffuse Magic
		[122278] = Defaults(),	-- Dampen Harm
		[115213] = Defaults(),	-- Avert Harm
		[116849] = Defaults(),	-- Life Cocoon
		[125174] = Defaults(),	-- Touch of Karma
		[116841] = Defaults(),	-- Tiger's Lust
	-- Racial
		[20594] = Defaults(),	-- Stoneform
		[59545] = Defaults(),	-- Gift of the Naaru
		[20572] = Defaults(),	-- Blood Fury
		[26297] = Defaults(),	-- Berserking
		[68992] = Defaults()	-- Darkflight
	}
}

G.unitframe.aurafilters["Blacklist"] = {
	["type"] = "Blacklist",
	["spells"] = {
	-- Spells
		[36032] = Defaults(),	-- Arcane Charge
		[132365] = Defaults(),	-- Vengeance
		[15007] = Defaults(),	-- Resurrection Sickness
		[8733] = Defaults(),	-- Blessing of Blackfathom
		[57724] = Defaults(),	-- Sated
		[25771] = Defaults(),	-- Forbearance
		[57723] = Defaults(),	-- Exhaustion
		[36032] = Defaults(),	-- Arcane Blast
		[58539] = Defaults(),	-- Watchers Corpse
		[26013] = Defaults(),	-- Deserter
		[6788] = Defaults(),	-- Weakended Soul
		[71041] = Defaults(),	-- Dungeon Deserter
		[46221] = Defaults(),	-- Animal Blood
		[41425] = Defaults(),	-- Hypothermia
		[55711] = Defaults(),	-- Weakened Heart
		[8326] = Defaults(),	-- Ghost
		[23445] = Defaults(),	-- Evil Twin
		[24755] = Defaults(),	-- Tricked or Treated Debuff
		[25163] = Defaults(),	-- Oozeling Disgusting Aura
		[80354] = Defaults(),	-- Timewarp Debuff
		[95223] = Defaults(),	-- Group Res Debuff
		[124275] = Defaults(),	-- Stagger
		[124274] = Defaults(),	-- Stagger
		[124273] = Defaults(),	-- Stagger
		[117870] = Defaults()	-- Touch of The Titans
	}
}

G.unitframe.aurafilters["Whitelist"] = {
	["type"] = "Whitelist",
	["spells"] = {
		[31821] = Defaults(),	-- Devotion Aura
		[2825] = Defaults(),	-- Bloodlust
		[32182] = Defaults(),	-- Heroism
		[80353] = Defaults(),	-- Time Warp
		[90355] = Defaults(),	-- Ancient Hysteria
		[47788] = Defaults(),	-- Guardian Spirit
		[33206] = Defaults(),	-- Pain Suppression
		[116849] = Defaults(),	-- Life Cocoon
		[22812] = Defaults()	-- Barkskin
	}
}

G.unitframe.aurafilters["RaidDebuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Mogu'shan Vaults
		-- The Stone Guard
		[116281] = Defaults(),	-- Cobalt Mine Blast
		-- Feng the Accursed
		[116784] = Defaults(),	-- Wildfire Spark
		[116417] = Defaults(),	-- Arcane Resonance
		[116942] = Defaults(),	-- Flaming Spear
		-- Gara'jal the Spiritbinder
		[116161] = Defaults(),	-- Crossed Over
		[122151] = Defaults(),	-- Voodoo Doll
		-- The Spirit Kings
		[117708] = Defaults(),	-- Maddening Shout
		[118303] = Defaults(),	-- Fixate
		[118048] = Defaults(),	-- Pillaged
		[118135] = Defaults(),	-- Pinned Down
		-- Elegon
		[117878] = Defaults(),	-- Overcharged
		[117949] = Defaults(),	-- Closed Circuit
		-- Will of the Emperor
		[116835] = Defaults(),	-- Devastating Arc
		[116778] = Defaults(),	-- Focused Defense
		[116525] = Defaults(),	-- Focused Assault
	-- Heart of Fear		
		-- Imperial Vizier Zor'lok
		[122761] = Defaults(),	-- Exhale
		[122760] = Defaults(),	-- Exhale
		[122740] = Defaults(),	-- Convert
		[123812] = Defaults(),	-- Pheromones of Zeal
		-- Blade Lord Ta'yak
		[123180] = Defaults(),	-- Wind Step
		[123474] = Defaults(),	-- Overwhelming Assault
		-- Garalon
		[122835] = Defaults(),	-- Pheromones
		[123081] = Defaults(),	-- Pungency
		-- Wind Lord Mel'jarak
		[122125] = Defaults(),	-- Corrosive Resin Pool
		[121885] = Defaults(),	-- Amber Prison
		-- Wind Lord Mel'jarak
		[121949] = Defaults(),	-- Parasitic Growth
	-- Terrace of Endless Spring
		-- Protectors of the Endless
		[117436] = Defaults(),	-- Lightning Prison
		[118091] = Defaults(),	-- Defiled Ground
		[117519] = Defaults(),	-- Touch of Sha
		-- Tsulong
		[122752] = Defaults(),	-- Shadow Breath
		[123011] = Defaults(),	-- Terrorize
		[116161] = Defaults(),	-- Crossed Over
		-- Lei Shi
		[123121] = Defaults(),	-- Spray
		-- Sha of Fear
		[119985] = Defaults(),	-- Dread Spray
		[119086] = Defaults(),	-- Penetrating Bolt
		[119775] = Defaults(),	-- Reaching Attack	
		[122151] = Defaults(),	-- Voodoo Doll
	-- Throne of Thunder
		-- Trash
		[138349] = Defaults(),	-- Static Wound
		[137371] = Defaults(),	-- Thundering Throw
		-- Horridon
		[136767] = Defaults(),	-- Triple Puncture
		-- Council of Elders
		[137641] = Defaults(),	-- Soul Fragment
		[137359] = Defaults(),	-- Shadowed Loa Spirit Fixate
		[137972] = Defaults(),	-- Twisted Fate
		[136903] = Defaults(),	-- Frigid Assault
		-- Tortos
		[136753] = Defaults(),	-- Slashing Talons
		[137633] = Defaults(),	-- Crystal Shell
		-- Megaera
		[137731] = Defaults(),	-- Ignite Flesh
		-- Durumu the Forgotten
		[133767] = Defaults(),	-- Serious Wound
		[133768] = Defaults(),	-- Arterial Cut
		-- Primordius
		[136050] = Defaults(),	-- Malformed Blood
		-- Dark Animus
		[138569] = Defaults(),	-- Explosive Slam
		-- Iron Qon
		[134691] = Defaults(),	-- Impale
		-- Twin Consorts
		[137440] = Defaults(),	-- Icy Shadows
		[137408] = Defaults(),	-- Fan of Flames
		[137360] = Defaults(),	-- Corrupted Healing
		-- Lei Shen
		[135000] = Defaults(),	-- Decapitate
	-- Siege of Orgrimmar
		-- Immerseus
		[143436] = Defaults(),	-- Corrosive Blast
		[143579] = Defaults(),	-- Sha Corruption(Heroic)
		-- Fallen Protectors
		[147383] = Defaults(),	-- Debilitation
		-- Norushen
		[146124] = Defaults(),	-- Self Doubt
		[144851] = Defaults(),	-- Test of Confidence
		-- Sha of Pride
		[144358] = Defaults(),	-- Wounded Pride
		[144774] = Defaults(),	-- Reaching Attacks
		[147207] = Defaults(),	-- Weakened Resolve(Heroic)
		-- Kor'kron Dark Shaman
		[144215] = Defaults(),	-- Froststorm Strike
		[143990] = Defaults(),	-- Foul Geyser
		[144330] = Defaults(),	-- Iron Prison(Heroic)
		-- General Nazgrim
		[143494] = Defaults(),	-- Sundering Blow
		-- Malkorok
		[142990] = Defaults(),	-- Fatal Strike
		[143919] = Defaults(),	-- Languish(Heroic)
		-- Thok the Bloodthirsty
		[143766] = Defaults(),	-- Panic
		[143773] = Defaults(),	-- Freezing Breath
		[146589] = Defaults(),	-- Skeleton Key
		[143777] = Defaults(),	-- Frozen Solid
		-- Siegecrafter Blackfuse
		[143385] = Defaults(),	-- Electrostatic Charge
		-- Paragons of the Klaxxi
		[143974] = Defaults(),	-- Shield Bash
		-- Garrosh Hellscream
		[145183] = Defaults()	-- Gripping Despair
	}
}

--Spells that we want to show the duration backwards
E.ReverseTimer = {

}

--BuffWatch
--List of personal spells to show on unitframes as icon
local function ClassBuff(id, point, color, anyUnit, onlyShowMissing, style, displayText, decimalThreshold, textColor, textThreshold, xOffset, yOffset, sizeOverride)
	local r, g, b = unpack(color)

	local r2, g2, b2 = 1, 1, 1
	if textColor then
		r2, g2, b2 = unpack(textColor)
	end

	return {
		["enabled"] = true,
		["id"] = id,
		["point"] = point,
		["color"] = {
			["r"] = r,
			["g"] = g,
			["b"] = b
		},
		["anyUnit"] = anyUnit,
		["onlyShowMissing"] = onlyShowMissing,
		["style"] = style or "coloredIcon",
		["displayText"] = displayText or false,
		["decimalThreshold"] = decimalThreshold or 5,
		["textColor"] = {
			["r"] = r2,
			["g"] = g2,
			["b"] = b2
		},
		["textThreshold"] = textThreshold or -1,
		["xOffset"] = xOffset or 0,
		["yOffset"] = yOffset or 0,
		["sizeOverride"] = sizeOverride or 0
	}
end

G.unitframe.buffwatch = {
	PRIEST = {
		[6788] = ClassBuff(6788, "TOPRIGHT", {1, 0, 0}, true),				-- Weakened Soul
		[41635] = ClassBuff(41635, "BOTTOMRIGHT", {0.2, 0.7, 0.2}),			-- Prayer of Mending
		[139] = ClassBuff(139, "BOTTOMLEFT", {0.4, 0.7, 0.2}),				-- Renew
		[17] = ClassBuff(17, "TOPLEFT", {0.81, 0.85, 0.1}, true),			-- Power Word: Shield
		[123258] = ClassBuff(123258, "TOPLEFT", {0.81, 0.85, 0.1}, true),	-- Power Word: Shield Power Insight
		[10060] = ClassBuff(10060 , "RIGHT", {0.89, 0.09, 0.05}),			-- Power Infusion
		[47788] = ClassBuff(47788, "LEFT", {0.86, 0.45, 0}, true),			-- Guardian Spirit
		[33206] = ClassBuff(33206, "LEFT", {0.89, 0.09, 0.05}, true),		-- Pain Suppression
	},
	DRUID = {
		[774] = ClassBuff(774, "TOPRIGHT", {0.8, 0.4, 0.8}),				-- Rejuvenation
		[8936] = ClassBuff(8936, "BOTTOMLEFT", {0.2, 0.8, 0.2}),			-- Regrowth
		[33763] = ClassBuff(33763, "TOPLEFT", {0.4, 0.8, 0.2}),				-- Lifebloom
		[48438] = ClassBuff(48438, "BOTTOMRIGHT", {0.8, 0.4, 0}),			-- Wild Growth
	},
	PALADIN = {
		[53563] = ClassBuff(53563, "TOPRIGHT", {0.7, 0.3, 0.7}),			-- Beacon of Light
		[1022] = ClassBuff(1022, "BOTTOMRIGHT", {0.2, 0.2, 1}, true),		-- Hand of Protection
		[1044] = ClassBuff(1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true),		-- Hand of Freedom
		[1038] = ClassBuff(1038, "BOTTOMRIGHT", {0.93, 0.75, 0}, true),		-- Hand of Salvation
		[6940] = ClassBuff(6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true),	-- Hand of Sacrifice
		[114039] = ClassBuff(114039, "BOTTOMRIGHT", {0.64, 0.41, 0.71}),	-- Hand of Purity
		[20925] = ClassBuff(20925, 'TOPLEFT', {0.93, 0.75, 0}),				-- Sacred Shield
		[114163] = ClassBuff(114163, 'BOTTOMLEFT', {0.87, 0.7, 0.03}),		-- Eternal Flame
	},
	SHAMAN = {
		[61295] = ClassBuff(61295, "TOPRIGHT", {0.7, 0.3, 0.7}),			-- Riptide
		[974] = ClassBuff(974, "BOTTOMLEFT", {0.2, 0.7, 0.2}, true),		-- Earth Shield
		[51945] = ClassBuff(51945, "BOTTOMRIGHT", {0.7, 0.4, 0}),			-- Earthliving
	},
	MONK = {
		[119611] = ClassBuff(119611, "TOPLEFT", {0.8, 0.4, 0.8}),			-- Renewing Mist
		[116849] = ClassBuff(116849, "TOPRIGHT", {0.2, 0.8, 0.2}),			-- Life Cocoon
		[132120] = ClassBuff(132120, "BOTTOMLEFT", {0.4, 0.8, 0.2}),		-- Enveloping Mist
		[124081] = ClassBuff(124081, "BOTTOMRIGHT", {0.7, 0.4, 0}),			-- Zen Sphere
	},
	ROGUE = {
		[57934] = ClassBuff(57934, "TOPRIGHT", {0.89, 0.09, 0.05}),			-- Tricks of the Trade
	},
	MAGE = {
		[111264] = ClassBuff(111264, "TOPLEFT", {0.2, 0.2, 1}),				-- Ice Ward
	},
	WARRIOR = {
		[114030] = ClassBuff(114030, "TOPLEFT", {0.2, 0.2, 1}),				-- Vigilance
		[3411] = ClassBuff(3411, "TOPRIGHT", {0.89, 0.09, 0.05}),			-- Intervene
		[114029] = ClassBuff(114029, "TOPRIGHT", {0.89, 0.09, 0.05}),		-- Safe Guard
	},
	DEATHKNIGHT = {
		[49016] = ClassBuff(49016, "TOPRIGHT", {0.89, 0.09, 0.05}),			-- Unholy Frenzy
	},
	PET = {
		[19615] = ClassBuff(19615, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Frenzy
		[136] = ClassBuff(136, 'TOPRIGHT', {0.2, 0.8, 0.2}, true)			-- Mend Pet
	}
}

P["unitframe"]["filters"] = {
	["buffwatch"] = {}
}

-- Ticks
G.unitframe.ChannelTicks = {
	-- Warlock
	[SpellName(1120)] = 6,		-- Drain Soul
	[SpellName(689)] = 6,		-- Drain Life
	[SpellName(108371)] = 6,	-- Harvest Life
	[SpellName(5740)] = 4,		-- Rain of Fire
	[SpellName(755)] = 6,		-- Health Funnel
	[SpellName(103103)] = 4,	-- Malefic Grasp
	-- Druid
	[SpellName(44203)] = 4,		-- Tranquility
	[SpellName(16914)] = 10,	-- Hurricane
	-- Priest
	[SpellName(15407)] = 3,		-- Mind Flay
	[SpellName(129197)] = 3,	-- Mind Flay (Insanity)
	[SpellName(48045)] = 5,		-- Mind Sear
	[SpellName(47540)] = 2,		-- Penance
	[SpellName(64901)] = 4,		-- Hymn of Hope
	[SpellName(64843)] = 4,		-- Divine Hymn
	-- Mage
	[SpellName(5143)] = 5,		-- Arcane Missiles
	[SpellName(10)] = 8,		-- Blizzard
	[SpellName(12051)] = 4,		-- Evocation
	--Monk
	[SpellName(115175)] = 9,	-- Smoothing Mist
}

G.unitframe.ChannelTicksSize = {
    --Warlock
    [SpellName(1120)] = 2,		-- Drain Soul
    [SpellName(689)] = 1,		-- Drain Life
	[SpellName(108371)] = 1,	-- Harvest Life
	[SpellName(103103)] = 1,	-- Malefic Grasp
}

--Spells Effected By Haste
G.unitframe.HastedChannelTicks = {
	[SpellName(64901)] = true, -- Hymn of Hope
	[SpellName(64843)] = true, -- Divine Hymn
}

G.unitframe.AuraBarColors = {
	[2825] = {r = 0.98, g = 0.57, b = 0.10},	-- Bloodlust
	[32182] = {r = 0.98, g = 0.57, b = 0.10},	-- Heroism
	[80353] = {r = 0.98, g = 0.57, b = 0.10},	-- Time Warp
	[90355] = {r = 0.98, g = 0.57, b = 0.10},	-- Ancient Hysteria
	[84963] = {r = 0.98, g = 0.57, b = 0.10},	-- Inquisition
}

G.unitframe.InvalidSpells = {
	[65148] = true,	--Sacred Shield
}

G.unitframe.DebuffHighlightColors = {
	[25771] = {enable = false, style = "FILL", color = {r = 0.85, g = 0, b = 0, a = 0.85}}, -- Forbearance
}

G.unitframe.specialFilters = {
	["Personal"] = true,
	["nonPersonal"] = true,
	["blockNonPersonal"] = true,
	["CastByUnit"] = true,
	["notCastByUnit"] = true,
	["blockNoDuration"] = true,
	["Dispellable"] = true,
}