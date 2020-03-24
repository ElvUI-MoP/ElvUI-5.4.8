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
local lastPanel

local function currencyInfo(id)
	local name, count, texture = GetCurrencyInfo(id)
	local icon = format(iconStr, texture, 14, 14)

	return name, count, icon
end

local Currencies = {
	-- PVE / PVP
	["395"] = {ID = 395, NAME = currencyInfo(395), ICON = select(3, currencyInfo(395)), COUNT = select(2, currencyInfo(395))}, -- Justice Points
	["396"] = {ID = 396, NAME = currencyInfo(396), ICON = select(3, currencyInfo(396)), COUNT = select(2, currencyInfo(396))}, -- Valor Points
	["392"] = {ID = 392, NAME = currencyInfo(392), ICON = select(3, currencyInfo(392)), COUNT = select(2, currencyInfo(392))}, -- Honor Points
	["390"] = {ID = 390, NAME = currencyInfo(390), ICON = select(3, currencyInfo(390)), COUNT = select(2, currencyInfo(390))}, -- Conquest points
	-- MoP
	["697"] = {ID = 697, NAME = currencyInfo(697), ICON = select(3, currencyInfo(697)), COUNT = select(2, currencyInfo(697))}, -- Elder Charm of Good Fortune
	["738"] = {ID = 738, NAME = currencyInfo(738), ICON = select(3, currencyInfo(738)), COUNT = select(2, currencyInfo(738))}, -- Lesset Charm of Good Fortune
	["752"] = {ID = 752, NAME = currencyInfo(752), ICON = select(3, currencyInfo(752)), COUNT = select(2, currencyInfo(752))}, -- Mogu Rune of Fate
	["776"] = {ID = 776, NAME = currencyInfo(776), ICON = select(3, currencyInfo(776)), COUNT = select(2, currencyInfo(776))}, -- Timeless Coin
	["777"] = {ID = 777, NAME = currencyInfo(777), ICON = select(3, currencyInfo(777)), COUNT = select(2, currencyInfo(777))}, -- Warforged Seal
	["789"] = {ID = 789, NAME = currencyInfo(789), ICON = select(3, currencyInfo(789)), COUNT = select(2, currencyInfo(789))}, -- Bloody Coin
	-- Other
	["515"] = {ID = 515, NAME = currencyInfo(515), ICON = select(3, currencyInfo(515)), COUNT = select(2, currencyInfo(515))}, -- Darkmoon Prize Ticket
	["402"] = {ID = 402, NAME = currencyInfo(402), ICON = select(3, currencyInfo(402)), COUNT = select(2, currencyInfo(402))}, -- Chef's Award
	["698"] = {ID = 698, NAME = currencyInfo(698), ICON = select(3, currencyInfo(698)), COUNT = select(2, currencyInfo(698))}, -- Ironpaw Token
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

	if Currencies["395"].COUNT > 0 then DT.tooltip:AddDoubleLine(join("", Currencies["395"].ICON, " ", Currencies["395"].NAME), Currencies["395"].COUNT, 1, 1, 1) end
	if Currencies["396"].COUNT > 0 then DT.tooltip:AddDoubleLine(join("", Currencies["396"].ICON, " ", Currencies["396"].NAME), Currencies["396"].COUNT, 1, 1, 1) end
	if Currencies["392"].COUNT > 0 then DT.tooltip:AddDoubleLine(join("", Currencies["392"].ICON, " ", Currencies["392"].NAME), Currencies["392"].COUNT, 1, 1, 1) end
	if Currencies["390"].COUNT > 0 then DT.tooltip:AddDoubleLine(join("", Currencies["390"].ICON, " ", Currencies["390"].NAME), Currencies["390"].COUNT, 1, 1, 1) end

	DT.tooltip:AddLine(" ")

	DT.tooltip:AddLine(EXPANSION_NAME4)
	if Currencies["697"].COUNT > 0 then DT.tooltip:AddDoubleLine(join("", Currencies["697"].ICON, " ", Currencies["697"].NAME), Currencies["697"].COUNT, 1, 1, 1) end
	if Currencies["738"].COUNT > 0 then DT.tooltip:AddDoubleLine(join("", Currencies["738"].ICON, " ", Currencies["738"].NAME), Currencies["738"].COUNT, 1, 1, 1) end
	if Currencies["752"].COUNT > 0 then DT.tooltip:AddDoubleLine(join("", Currencies["752"].ICON, " ", Currencies["752"].NAME), Currencies["752"].COUNT, 1, 1, 1) end
	if Currencies["776"].COUNT > 0 then DT.tooltip:AddDoubleLine(join("", Currencies["776"].ICON, " ", Currencies["776"].NAME), Currencies["776"].COUNT, 1, 1, 1) end
	if Currencies["777"].COUNT > 0 then DT.tooltip:AddDoubleLine(join("", Currencies["777"].ICON, " ", Currencies["777"].NAME), Currencies["777"].COUNT, 1, 1, 1) end
	if Currencies["789"].COUNT > 0 then DT.tooltip:AddDoubleLine(join("", Currencies["789"].ICON, " ", Currencies["789"].NAME), Currencies["789"].COUNT, 1, 1, 1) end
	DT.tooltip:AddLine(" ")

	DT.tooltip:AddLine(OTHER)
	if Currencies["515"].COUNT > 0 then DT.tooltip:AddDoubleLine(join("", Currencies["515"].ICON, " ", Currencies["515"].NAME), Currencies["515"].COUNT, 1, 1, 1) end
	if Currencies["402"].COUNT > 0 then DT.tooltip:AddDoubleLine(join("", Currencies["402"].ICON, " ", Currencies["402"].NAME), Currencies["402"].COUNT, 1, 1, 1) end
	if Currencies["698"].COUNT > 0 then DT.tooltip:AddDoubleLine(join("", Currencies["698"].ICON, " ", Currencies["698"].NAME), Currencies["698"].COUNT, 1, 1, 1) end

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