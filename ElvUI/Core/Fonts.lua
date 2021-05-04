local E, L, V, P, G = unpack(select(2, ...))
local LSM = E.Libs.LSM

local SetCVar = SetCVar

local function SetFont(obj, font, size, style, sr, sg, sb, sa, sox, soy, r, g, b)
	if not obj then return end

	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb, sa) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
	elseif r then obj:SetAlpha(r) end
end

function E:UpdateBlizzardFonts()
	local NORMAL		= E.media.normFont
	local NUMBER		= E.media.normFont
	local COMBAT		= LSM:Fetch("font", E.private.general.dmgfont)
	local NAMEFONT		= LSM:Fetch("font", E.private.general.namefont)
	local BUBBLE		= LSM:Fetch("font", E.private.general.chatBubbleFont)
	local SHADOWCOLOR	= _G.SHADOWCOLOR
	local NORMALOFFSET	= _G.NORMALOFFSET
	local BIGOFFSET		= _G.BIGOFFSET
	local MONOCHROME	= ""

	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
	CHAT_FONT_HEIGHTS = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

	if E.db.general.font == "Homespun" then
		MONOCHROME = "MONOCHROME"
	end

	if E.eyefinity then
		InterfaceOptionsCombatTextPanelTargetDamage:Hide()
		InterfaceOptionsCombatTextPanelPeriodicDamage:Hide()
		InterfaceOptionsCombatTextPanelPetDamage:Hide()
		InterfaceOptionsCombatTextPanelHealing:Hide()
		SetCVar("CombatLogPeriodicSpells", 0)
		SetCVar("PetMeleeDamage", 0)
		SetCVar("CombatDamage", 0)
		SetCVar("CombatHealing", 0)

		-- set an invisible font for xp, honor kill, etc
		COMBAT = E.Media.Fonts.Invisible
	end

	if E.private.general.replaceNameFont then
		UNIT_NAME_FONT = NAMEFONT
	end

	if E.private.general.replaceCombatFont then
		DAMAGE_TEXT_FONT = COMBAT
	end

	if E.private.general.replaceBlizzFonts then
		NAMEPLATE_FONT = NAMEFONT
		STANDARD_TEXT_FONT = NORMAL

		SetFont(ChatBubbleFont,						BUBBLE, self.private.general.chatBubbleFontSize, self.private.general.chatBubbleFontOutline)
		SetFont(GameTooltipHeader,					NORMAL, self.db.general.fontSize)
		SetFont(NumberFont_OutlineThick_Mono_Small,	NUMBER, self.db.general.fontSize, "OUTLINE")
		SetFont(NumberFont_Outline_Huge,			NUMBER, 28, MONOCHROME.."THICKOUTLINE", 28)
		SetFont(NumberFont_Outline_Large,			NUMBER, 15, MONOCHROME.."OUTLINE")
		SetFont(NumberFont_Outline_Med,				NUMBER, self.db.general.fontSize, "OUTLINE")
		SetFont(NumberFont_Shadow_Med,				NORMAL, self.db.general.fontSize)
		SetFont(NumberFont_Shadow_Small,			NORMAL, self.db.general.fontSize)
		SetFont(ChatFontSmall,						NORMAL, self.db.general.fontSize)
		SetFont(QuestFontHighlight,					NORMAL, self.db.general.fontSize)
		SetFont(QuestFont,							NORMAL, self.db.general.fontSize)
		SetFont(QuestFont_Large,					NORMAL, 14)
		SetFont(QuestFont_Huge,						NORMAL, 15, nil, SHADOWCOLOR, BIGOFFSET)
		SetFont(QuestFont_Super_Huge,				NORMAL, 22, nil, SHADOWCOLOR, BIGOFFSET)
		SetFont(QuestFont_Shadow_Huge,				NORMAL, 15, nil, SHADOWCOLOR, NORMALOFFSET)
		SetFont(QuestFont_Shadow_Small,				NORMAL, 14, nil, SHADOWCOLOR, NORMALOFFSET)
		SetFont(QuestTitleFont,						NORMAL, self.db.general.fontSize + 8)
		SetFont(QuestTitleFontBlackShadow,			NORMAL, self.db.general.fontSize + 8)
		SetFont(SystemFont_Large,					NORMAL, 15)
		SetFont(GameFontNormalMed3,					NORMAL, 15)
		SetFont(SystemFont_Shadow_Huge1,			NORMAL, 20, MONOCHROME.."OUTLINE")
		SetFont(SystemFont_Med1,					NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Med3,					NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_OutlineThick_Huge2,		NORMAL, 20, MONOCHROME.."THICKOUTLINE")
		SetFont(SystemFont_Outline_Small,			NUMBER, self.db.general.fontSize, "OUTLINE")
		SetFont(SystemFont_Shadow_Large,			NORMAL, 15)
		SetFont(SystemFont_Shadow_Med1,				NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Shadow_Med3,				NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Shadow_Outline_Huge2,	NORMAL, 20, MONOCHROME.."OUTLINE")
		SetFont(SystemFont_Shadow_Small,			NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Small,					NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Tiny,					NORMAL, self.db.general.fontSize)
		SetFont(Tooltip_Med,						NORMAL, self.db.general.fontSize)
		SetFont(Tooltip_Small,						NORMAL, self.db.general.fontSize)
		SetFont(FriendsFont_Normal,					NORMAL, self.db.general.fontSize)
		SetFont(FriendsFont_Small,					NORMAL, self.db.general.fontSize)
		SetFont(FriendsFont_Large,					NORMAL, self.db.general.fontSize)
		SetFont(FriendsFont_UserText,				NORMAL, self.db.general.fontSize)
		SetFont(SpellFont_Small,					NORMAL, self.db.general.fontSize)
		SetFont(ZoneTextString,						NORMAL, 32, MONOCHROME.."OUTLINE")
		SetFont(SubZoneTextString,					NORMAL, 25, MONOCHROME.."OUTLINE")
		SetFont(PVPInfoTextString,					NORMAL, 22, MONOCHROME.."OUTLINE")
		SetFont(PVPArenaTextString,					NORMAL, 22, MONOCHROME.."OUTLINE")
		SetFont(CombatTextFont,						COMBAT, 100, MONOCHROME.."OUTLINE")
		SetFont(SystemFont_Outline, 				NORMAL, 24, MONOCHROME.."OUTLINE")
		SetFont(SystemFont_OutlineThick_WTF,		NORMAL, 32, MONOCHROME.."OUTLINE")
		SetFont(SubZoneTextFont,					NORMAL, 24, MONOCHROME.."OUTLINE")
		SetFont(MailFont_Large,						NORMAL, 14)
		SetFont(InvoiceFont_Med,					NORMAL, 12)
		SetFont(InvoiceFont_Small,					NORMAL, self.db.general.fontSize)
		SetFont(AchievementFont_Small,				NORMAL, self.db.general.fontSize)
		SetFont(ReputationDetailFont,				NORMAL, self.db.general.fontSize)
		SetFont(BossEmoteNormalHuge,				NORMAL, 24)
		SetFont(Game13FontShadow,					NORMAL, 14)
		SetFont(GameFont_Gigantic,					NORMAL, 32, nil, SHADOWCOLOR, BIGOFFSET)
		SetFont(SystemFont_Shadow_Med2,				NORMAL, self.db.general.fontSize * 1.1)
		SetFont(CoreAbilityFont,					NORMAL, 26)
	end
end