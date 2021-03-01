local E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule("DataTexts")

local select, pairs = select, pairs
local format, join = string.format, string.join

local GetCurrencyInfo = GetCurrencyInfo
local GetMoney = GetMoney
local ToggleCharacter = ToggleCharacter

local BONUS_ROLL_REWARD_MONEY = BONUS_ROLL_REWARD_MONEY
local CURRENCY, OTHER, PVP = CURRENCY, OTHER, PVP
local EXPANSION_NAME4 = EXPANSION_NAME4
local COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVE = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVE

local iconStr = "\124T%s:%d:%d:0:0:64:64:5:59:5:59\124t"

local currencyList, gold

local function getCurrencyInfo(id)
	local name, count, texture = GetCurrencyInfo(id)
	local icon = format(iconStr, texture, 14, 14)

	return name, count, icon
end

local Currencies = {
	-- PvP
	["392"] = {ID = 392, NAME = getCurrencyInfo(392), ICON = select(3, getCurrencyInfo(392))}, -- Honor Points
	["390"] = {ID = 390, NAME = getCurrencyInfo(390), ICON = select(3, getCurrencyInfo(390))}, -- Conquest points
	-- PvE
	["395"] = {ID = 395, NAME = getCurrencyInfo(395), ICON = select(3, getCurrencyInfo(395))}, -- Justice Points
	["396"] = {ID = 396, NAME = getCurrencyInfo(396), ICON = select(3, getCurrencyInfo(396))}, -- Valor Points
	-- MoP
	["697"] = {ID = 697, NAME = getCurrencyInfo(697), ICON = select(3, getCurrencyInfo(697))}, -- Elder Charm of Good Fortune
	["738"] = {ID = 738, NAME = getCurrencyInfo(738), ICON = select(3, getCurrencyInfo(738))}, -- Lesset Charm of Good Fortune
	["752"] = {ID = 752, NAME = getCurrencyInfo(752), ICON = select(3, getCurrencyInfo(752))}, -- Mogu Rune of Fate
	["776"] = {ID = 776, NAME = getCurrencyInfo(776), ICON = select(3, getCurrencyInfo(776))}, -- Timeless Coin
	["777"] = {ID = 777, NAME = getCurrencyInfo(777), ICON = select(3, getCurrencyInfo(777))}, -- Warforged Seal
	["789"] = {ID = 789, NAME = getCurrencyInfo(789), ICON = select(3, getCurrencyInfo(789))}, -- Bloody Coin
	-- Other
	["402"] = {ID = 402, NAME = getCurrencyInfo(402), ICON = select(3, getCurrencyInfo(402))}, -- Chef's Award
	["515"] = {ID = 515, NAME = getCurrencyInfo(515), ICON = select(3, getCurrencyInfo(515))}, -- Darkmoon Prize Ticket
	["698"] = {ID = 698, NAME = getCurrencyInfo(698), ICON = select(3, getCurrencyInfo(698))}, -- Ironpaw Token
}

function DT:Currencies_GetCurrencyList()
	currencyList = {}
	for currency, data in pairs(Currencies) do
		currencyList[currency] = data.NAME
	end
	currencyList.GOLD = BONUS_ROLL_REWARD_MONEY

	return currencyList
end

local function OnEvent(self)
	gold = GetMoney()

	if E.db.datatexts.currencies.displayedCurrency == "GOLD" then
		self.text:SetText(E:FormatMoney(gold, E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins))
	else
		local chosenCurrency = Currencies[E.db.datatexts.currencies.displayedCurrency]

		if chosenCurrency then
			local count = select(2, getCurrencyInfo(chosenCurrency.ID))

			if E.db.datatexts.currencies.displayStyle == "ICON" then
				self.text:SetFormattedText("%s %d", chosenCurrency.ICON, count)
			elseif E.db.datatexts.currencies.displayStyle == "ICON_TEXT" then
				self.text:SetFormattedText("%s %s %d", chosenCurrency.ICON, chosenCurrency.NAME, count)
			else
				self.text:SetFormattedText("%s %s %d", chosenCurrency.ICON, E:AbbreviateString(chosenCurrency.NAME), count)
			end
		end
	end
end

local function OnClick()
	ToggleCharacter("TokenFrame")
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	-- Gold
	DT.tooltip:AddDoubleLine(L["Gold"]..":", E:FormatMoney(gold, E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins), nil, nil, nil, 1, 1, 1)
	DT.tooltip:AddLine(" ")
	-- PvP
	DT.tooltip:AddLine(PVP)
	DT.tooltip:AddDoubleLine(join("", Currencies["392"].ICON, " ", Currencies["392"].NAME), select(2, getCurrencyInfo(392)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["390"].ICON, " ", Currencies["390"].NAME), select(2, getCurrencyInfo(390)), 1, 1, 1)
	DT.tooltip:AddLine(" ")
	-- PvE
	DT.tooltip:AddLine(COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVE)
	DT.tooltip:AddDoubleLine(join("", Currencies["395"].ICON, " ", Currencies["395"].NAME), select(2, getCurrencyInfo(395)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["396"].ICON, " ", Currencies["396"].NAME), select(2, getCurrencyInfo(396)), 1, 1, 1)
	DT.tooltip:AddLine(" ")
	-- MoP
	DT.tooltip:AddLine(EXPANSION_NAME4)
	DT.tooltip:AddDoubleLine(join("", Currencies["697"].ICON, " ", Currencies["697"].NAME), select(2, getCurrencyInfo(697)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["738"].ICON, " ", Currencies["738"].NAME), select(2, getCurrencyInfo(738)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["752"].ICON, " ", Currencies["752"].NAME), select(2, getCurrencyInfo(752)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["776"].ICON, " ", Currencies["776"].NAME), select(2, getCurrencyInfo(776)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["777"].ICON, " ", Currencies["777"].NAME), select(2, getCurrencyInfo(777)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["789"].ICON, " ", Currencies["789"].NAME), select(2, getCurrencyInfo(789)), 1, 1, 1)
	DT.tooltip:AddLine(" ")
	-- Other
	DT.tooltip:AddLine(OTHER)
	DT.tooltip:AddDoubleLine(join("", Currencies["515"].ICON, " ", Currencies["515"].NAME), select(2, getCurrencyInfo(515)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["402"].ICON, " ", Currencies["402"].NAME), select(2, getCurrencyInfo(402)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["698"].ICON, " ", Currencies["698"].NAME), select(2, getCurrencyInfo(698)), 1, 1, 1)

	local shouldAddHeader = true
	for currencyID, info in pairs(E.global.datatexts.customCurrencies) do
		if info.DISPLAY_IN_MAIN_TOOLTIP then
			if shouldAddHeader then
				DT.tooltip:AddLine(" ")
				DT.tooltip:AddLine(L["Custom Currency"])
				shouldAddHeader = false
			end

			DT.tooltip:AddDoubleLine(info.NAME, select(2, getCurrencyInfo(info.ID)), 1, 1, 1)
		end
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext("Currencies", {"PLAYER_ENTERING_WORLD", "PLAYER_MONEY", "SEND_MAIL_MONEY_CHANGED", "SEND_MAIL_COD_CHANGED", "PLAYER_TRADE_MONEY", "TRADE_MONEY_CHANGED", "CHAT_MSG_CURRENCY", "CURRENCY_DISPLAY_UPDATE"}, OnEvent, nil, OnClick, OnEnter, nil, CURRENCY)