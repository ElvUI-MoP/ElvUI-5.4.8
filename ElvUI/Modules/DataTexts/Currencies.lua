local E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule("DataTexts")

local select, pairs = select, pairs
local format, join = string.format, string.join

local GetCurrencyInfo = GetCurrencyInfo
local GetMoney = GetMoney
local BONUS_ROLL_REWARD_MONEY = BONUS_ROLL_REWARD_MONEY
local EXPANSION_NAME4 = EXPANSION_NAME4
local OTHER = OTHER
local CURRENCY = CURRENCY

local displayString = ""
local iconStr = "\124T%s:%d:%d:0:0:64:64:5:59:5:59\124t"

local currencyList, gold

local function currencyInfo(id)
	local texture = select(3, GetCurrencyInfo(id))
	local icon = format(iconStr, texture, 14, 14)

	return icon
end

local Currencies = {
	-- PVE / PVP
	["395"] = {ID = 395, NAME = GetCurrencyInfo(395), ICON = currencyInfo(395)}, -- Justice Points
	["396"] = {ID = 396, NAME = GetCurrencyInfo(396), ICON = currencyInfo(396)}, -- Valor Points
	["392"] = {ID = 392, NAME = GetCurrencyInfo(392), ICON = currencyInfo(392)}, -- Honor Points
	["390"] = {ID = 390, NAME = GetCurrencyInfo(390), ICON = currencyInfo(390)}, -- Conquest points
	-- MoP
	["697"] = {ID = 697, NAME = GetCurrencyInfo(697), ICON = currencyInfo(697)}, -- Elder Charm of Good Fortune
	["738"] = {ID = 738, NAME = GetCurrencyInfo(738), ICON = currencyInfo(738)}, -- Lesset Charm of Good Fortune
	["752"] = {ID = 752, NAME = GetCurrencyInfo(752), ICON = currencyInfo(752)}, -- Mogu Rune of Fate
	["776"] = {ID = 776, NAME = GetCurrencyInfo(776), ICON = currencyInfo(776)}, -- Timeless Coin
	["777"] = {ID = 777, NAME = GetCurrencyInfo(777), ICON = currencyInfo(777)}, -- Warforged Seal
	["789"] = {ID = 789, NAME = GetCurrencyInfo(789), ICON = currencyInfo(789)}, -- Bloody Coin
	-- Other
	["402"] = {ID = 402, NAME = GetCurrencyInfo(402), ICON = currencyInfo(402)}, -- Chef's Award
	["515"] = {ID = 515, NAME = GetCurrencyInfo(515), ICON = currencyInfo(515)}, -- Darkmoon Prize Ticket
	["698"] = {ID = 698, NAME = GetCurrencyInfo(698), ICON = currencyInfo(698)}, -- Ironpaw Token
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
			local count = select(2, GetCurrencyInfo(chosenCurrency.ID))

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

local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:AddDoubleLine(L["Gold"]..":", E:FormatMoney(gold, E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins), nil, nil, nil, 1, 1, 1)
	DT.tooltip:AddLine(" ")

	DT.tooltip:AddDoubleLine(join("", Currencies["395"].ICON, " ", Currencies["395"].NAME), select(2, GetCurrencyInfo(395)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["396"].ICON, " ", Currencies["396"].NAME), select(2, GetCurrencyInfo(396)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["392"].ICON, " ", Currencies["392"].NAME), select(2, GetCurrencyInfo(392)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["390"].ICON, " ", Currencies["390"].NAME), select(2, GetCurrencyInfo(390)), 1, 1, 1)

	DT.tooltip:AddLine(" ")

	DT.tooltip:AddLine(EXPANSION_NAME4)
	DT.tooltip:AddDoubleLine(join("", Currencies["697"].ICON, " ", Currencies["697"].NAME), select(2, GetCurrencyInfo(697)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["738"].ICON, " ", Currencies["738"].NAME), select(2, GetCurrencyInfo(738)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["752"].ICON, " ", Currencies["752"].NAME), select(2, GetCurrencyInfo(752)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["776"].ICON, " ", Currencies["776"].NAME), select(2, GetCurrencyInfo(776)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["777"].ICON, " ", Currencies["777"].NAME), select(2, GetCurrencyInfo(777)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["789"].ICON, " ", Currencies["789"].NAME), select(2, GetCurrencyInfo(789)), 1, 1, 1)
	DT.tooltip:AddLine(" ")

	DT.tooltip:AddLine(OTHER)
	DT.tooltip:AddDoubleLine(join("", Currencies["515"].ICON, " ", Currencies["515"].NAME), select(2, GetCurrencyInfo(515)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["402"].ICON, " ", Currencies["402"].NAME), select(2, GetCurrencyInfo(402)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(join("", Currencies["698"].ICON, " ", Currencies["698"].NAME), select(2, GetCurrencyInfo(698)), 1, 1, 1)

	local shouldAddHeader = true
	for currencyID, info in pairs(E.global.datatexts.customCurrencies) do
		if info.DISPLAY_IN_MAIN_TOOLTIP then
			if shouldAddHeader then
				DT.tooltip:AddLine(" ")
				DT.tooltip:AddLine(L["Custom Currency"])
				shouldAddHeader = false
			end

			DT.tooltip:AddDoubleLine(info.NAME, select(2, GetCurrencyInfo(info.ID)), 1, 1, 1)
		end
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext("Currencies", {"PLAYER_ENTERING_WORLD", "PLAYER_MONEY", "SEND_MAIL_MONEY_CHANGED", "SEND_MAIL_COD_CHANGED", "PLAYER_TRADE_MONEY", "TRADE_MONEY_CHANGED", "CHAT_MSG_CURRENCY", "CURRENCY_DISPLAY_UPDATE"}, OnEvent, nil, nil, OnEnter, nil, CURRENCY)