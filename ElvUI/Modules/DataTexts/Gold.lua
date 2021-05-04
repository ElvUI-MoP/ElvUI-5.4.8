local E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule("DataTexts")
local B = E:GetModule("Bags")

local type, ipairs, pairs = type, ipairs, pairs
local format, strjoin = string.format, strjoin
local tinsert, wipe = tinsert, wipe

local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local GetMoney = GetMoney
local IsControlKeyDown = IsControlKeyDown
local IsLoggedIn = IsLoggedIn
local IsShiftKeyDown = IsShiftKeyDown
local CURRENCY = CURRENCY
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST

local Profit, Spent = 0, 0

local currencyString = "|T%s:14:14:0:0:64:64:4:60:4:60|t %s"
local resetCountersFormatter = strjoin("", "|cffaaaaaa", L["Reset Counters: Hold Control + Right Click"], "|r")
local resetInfoFormatter = strjoin("", "|cffaaaaaa", L["Reset Data: Hold Shift + Right Click"], "|r")

local function OnEvent(self)
	if not IsLoggedIn() then return end

	ElvDB = ElvDB or {}
	ElvDB.gold = ElvDB.gold or {}
	ElvDB.gold[E.myrealm] = ElvDB.gold[E.myrealm] or {}

	ElvDB.class = ElvDB.class or {}
	ElvDB.class[E.myrealm] = ElvDB.class[E.myrealm] or {}
	ElvDB.class[E.myrealm][E.myname] = E.myclass

	ElvDB.faction = ElvDB.faction or {}
	ElvDB.faction[E.myrealm] = ElvDB.faction[E.myrealm] or {}
	ElvDB.faction[E.myrealm][E.myname] = E.myfaction

	--prevent an error possibly from really old profiles
	local oldMoney = ElvDB.gold[E.myrealm][E.myname]
	if oldMoney and type(oldMoney) ~= "number" then
		ElvDB.gold[E.myrealm][E.myname] = nil
		oldMoney = nil
	end

	local NewMoney = GetMoney()
	ElvDB.gold[E.myrealm][E.myname] = NewMoney

	local OldMoney = oldMoney or NewMoney
	local Change = NewMoney - OldMoney -- Positive if we gain money
	if OldMoney > NewMoney then
		Spent = Spent - Change -- Lost Money
	else
		Profit = Profit + Change -- Gained Moeny
	end

	self.text:SetText(E:FormatMoney(NewMoney, E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins))
end

local function OnClick(self, btn)
	if btn == "RightButton" then
		if IsShiftKeyDown() then
			wipe(ElvDB.gold)
			OnEvent(self)
			DT.tooltip:Hide()
		elseif IsControlKeyDown() then
			Profit = 0
			Spent = 0
			DT.tooltip:Hide()
		end
	else
		ToggleAllBags()
	end
end

local myGold = {}
local function OnEnter(self)
	DT:SetupTooltip(self)
	local textOnly = not E.db.datatexts.goldCoins and true or false
	local style = E.db.datatexts.goldFormat or "BLIZZARD"

	DT.tooltip:AddLine(L["Session:"])
	DT.tooltip:AddDoubleLine(L["Earned:"], E:FormatMoney(Profit, style, textOnly), 1, 1, 1, 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Spent:"], E:FormatMoney(Spent, style, textOnly), 1, 1, 1, 1, 1, 1)
	if Profit < Spent then
		DT.tooltip:AddDoubleLine(L["Deficit:"], E:FormatMoney(Profit - Spent, style, textOnly), 1, 0, 0, 1, 1, 1)
	elseif (Profit - Spent) > 0 then
		DT.tooltip:AddDoubleLine(L["Profit:"], E:FormatMoney(Profit - Spent, style, textOnly), 0, 1, 0, 1, 1, 1)
	end
	DT.tooltip:AddLine(" ")

	local totalGold, totalHorde, totalAlliance = 0, 0, 0
	DT.tooltip:AddLine(L["Character: "])

	wipe(myGold)
	for k in pairs(ElvDB.gold[E.myrealm]) do
		if ElvDB.gold[E.myrealm][k] then
			local class = ElvDB.class[E.myrealm][k] or "PRIEST"
			local color = E:ClassColor(class) or PRIEST_COLOR
			tinsert(myGold,
				{
					name = k,
					amount = ElvDB.gold[E.myrealm][k],
					amountText = E:FormatMoney(ElvDB.gold[E.myrealm][k], E.db.datatexts.goldFormat or "BLIZZARD", not E.db.datatexts.goldCoins),
					faction = ElvDB.faction[E.myrealm][k] or "",
					r = color.r, g = color.g, b = color.b,
				}
			)
		end
		if ElvDB.faction[E.myrealm][k] == "Alliance" then
			totalAlliance = totalAlliance + ElvDB.gold[E.myrealm][k]
		elseif ElvDB.faction[E.myrealm][k] == "Horde" then
			totalHorde = totalHorde + ElvDB.gold[E.myrealm][k]
		end

		totalGold = totalGold + ElvDB.gold[E.myrealm][k]
	end

	for _, g in ipairs(myGold) do
		local nameLine = ""
		if g.faction ~= "" and g.faction ~= "Neutral" then
			nameLine = format("|TInterface/FriendsFrame/PlusManz-%s:14|t ", g.faction)
		end
		nameLine = g.name == E.myname and nameLine..g.name.." |TInterface/COMMON/Indicator-Green:14|t" or nameLine..g.name

		DT.tooltip:AddDoubleLine(nameLine, g.amountText, g.r, g.g, g.b, 1, 1, 1)
	end

	DT.tooltip:AddLine(" ")
	DT.tooltip:AddLine(L["Server: "])
	if totalAlliance ~= 0 then DT.tooltip:AddDoubleLine(L["Alliance: "], E:FormatMoney(totalAlliance, style, textOnly), 0, 0.376, 1, 1, 1, 1) end
	if totalHorde ~= 0 then DT.tooltip:AddDoubleLine(L["Horde: "], E:FormatMoney(totalHorde, style, textOnly), 1, 0.2, 0.2, 1, 1, 1) end
	DT.tooltip:AddLine(" ")
	DT.tooltip:AddDoubleLine(L["Total: "], E:FormatMoney(totalGold, style, textOnly), 1, 1, 1, 1, 1, 1)
	DT.tooltip:AddLine(" ")

	for i = 1, MAX_WATCHED_TOKENS do
		local name, count, icon = GetBackpackCurrencyInfo(i)
		if name and i == 1 then
			DT.tooltip:AddLine(" ")
			DT.tooltip:AddLine(CURRENCY..":")
		end
		if name and count then DT.tooltip:AddDoubleLine(currencyString:format(icon, name), count, 1, 1, 1) end
	end

	local grayValue = B:GetGraysValue()
	if grayValue > 0 then
		DT.tooltip:AddLine(" ")
		DT.tooltip:AddDoubleLine(L["Grays"], E:FormatMoney(grayValue, style, textOnly), nil, nil, nil, 1, 1, 1)
	end

	DT.tooltip:AddLine(" ")
	DT.tooltip:AddLine(resetCountersFormatter)
	DT.tooltip:AddLine(resetInfoFormatter)

	DT.tooltip:Show()
end

DT:RegisterDatatext("Gold", {"PLAYER_ENTERING_WORLD", "PLAYER_MONEY", "SEND_MAIL_MONEY_CHANGED", "SEND_MAIL_COD_CHANGED", "PLAYER_TRADE_MONEY", "TRADE_MONEY_CHANGED"}, OnEvent, nil, OnClick, OnEnter, nil, L["Gold"])