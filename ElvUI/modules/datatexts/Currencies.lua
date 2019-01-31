local E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule("DataTexts")

local select, pairs = select, pairs
local format = string.format
local join = string.join

local GetCurrencyInfo = GetCurrencyInfo
local GetMoney = GetMoney
local BONUS_ROLL_REWARD_MONEY = BONUS_ROLL_REWARD_MONEY
local EXPANSION_NAME4 = EXPANSION_NAME4
local OTHER = OTHER
local CURRENCY = CURRENCY

local Currencies = {
	-- MoP
	["ELDER_CHARM_OF_GOOD_FORTUNE"]		= {ID = 697, NAME = GetCurrencyInfo(697), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(697)), 16, 16)},
	["LESSER_CHARM_OF_GOOD_FORTUNE"]	= {ID = 738, NAME = GetCurrencyInfo(738), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(738)), 16, 16)},
	["MOGU_RUNE_OF_FATE"]				= {ID = 752, NAME = GetCurrencyInfo(752), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(752)), 16, 16)},
	["TIMELESS_COIN"]					= {ID = 776, NAME = GetCurrencyInfo(776), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(776)), 16, 16)},
	["WARFORGED_SEAL"]					= {ID = 777, NAME = GetCurrencyInfo(777), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(777)), 16, 16)},
	["BLOODY_COIN"]						= {ID = 789, NAME = GetCurrencyInfo(789), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(789)), 16, 16)},
	-- Other
	["DARKMOON_PRIZE_TICKET"]			= {ID = 515, NAME = GetCurrencyInfo(515), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(515)), 16, 16)},
	["IRONPAW_TOKEN"]					= {ID = 402, NAME = GetCurrencyInfo(402), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(402)), 16, 16)},
	["ZEN_JEWELCRAFTERS_TOKEN"]			= {ID = 698, NAME = GetCurrencyInfo(698), ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(698)), 16, 16)},
}

local currencyList
function DT:Currencies_GetCurrencyList()
	currencyList = {}
	for currency, data in pairs(Currencies) do
		currencyList[currency] = data.NAME
	end
	currencyList.GOLD = BONUS_ROLL_REWARD_MONEY

	return currencyList
end

local gold
local chosenCurrency, currencyAmount

local function OnEvent(self)
	gold = GetMoney()

	if E.db.datatexts.currencies.displayedCurrency == "GOLD" then
		self.text:SetText(E:FormatMoney(gold, E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins))
	else
		chosenCurrency = Currencies[E.db.datatexts.currencies.displayedCurrency]
		if chosenCurrency then
			currencyAmount = select(2, GetCurrencyInfo(chosenCurrency.ID))
			if E.db.datatexts.currencies.displayStyle == "ICON" then
				self.text:SetFormattedText("%s %d", chosenCurrency.ICON, currencyAmount)
			elseif E.db.datatexts.currencies.displayStyle == "ICON_TEXT" then
				self.text:SetFormattedText("%s %s %d", chosenCurrency.ICON, chosenCurrency.NAME, currencyAmount)
			else
				self.text:SetFormattedText("%s %s %d", chosenCurrency.ICON, E:AbbreviateString(chosenCurrency.NAME), currencyAmount)
			end
		end
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:AddDoubleLine(L["Gold"]..":", E:FormatMoney(gold, E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins), nil, nil, nil, 1, 1, 1)
	DT.tooltip:AddLine(" ")

	DT.tooltip:AddLine(EXPANSION_NAME4) -- MoP
	DT.tooltip:AddDoubleLine(Currencies["ELDER_CHARM_OF_GOOD_FORTUNE"].NAME, select(2, GetCurrencyInfo(Currencies["ELDER_CHARM_OF_GOOD_FORTUNE"].ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies["LESSER_CHARM_OF_GOOD_FORTUNE"].NAME, select(2, GetCurrencyInfo(Currencies["LESSER_CHARM_OF_GOOD_FORTUNE"].ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies["MOGU_RUNE_OF_FATE"].NAME, select(2, GetCurrencyInfo(Currencies["MOGU_RUNE_OF_FATE"].ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies["TIMELESS_COIN"].NAME, select(2, GetCurrencyInfo(Currencies["TIMELESS_COIN"].ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies["WARFORGED_SEAL"].NAME, select(2, GetCurrencyInfo(Currencies["WARFORGED_SEAL"].ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies["BLOODY_COIN"].NAME, select(2, GetCurrencyInfo(Currencies["BLOODY_COIN"].ID)), 1, 1, 1)
	DT.tooltip:AddLine(" ")

	DT.tooltip:AddLine(OTHER) -- Other
	DT.tooltip:AddDoubleLine(Currencies["DARKMOON_PRIZE_TICKET"].NAME, select(2, GetCurrencyInfo(Currencies["DARKMOON_PRIZE_TICKET"].ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies["IRONPAW_TOKEN"].NAME, select(2, GetCurrencyInfo(Currencies["IRONPAW_TOKEN"].ID)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(Currencies["ZEN_JEWELCRAFTERS_TOKEN"].NAME, select(2, GetCurrencyInfo(Currencies["ZEN_JEWELCRAFTERS_TOKEN"].ID)), 1, 1, 1)

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