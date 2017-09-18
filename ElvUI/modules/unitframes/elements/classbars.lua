local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local _, ns = ...;
local ElvUF = ns.oUF;
assert(ElvUF, "ElvUI was unable to locate oUF.");

local select, unpack = select, unpack;
local floor, max = math.floor, math.max;
local find = string.find

local CreateFrame = CreateFrame;
local UnitPower = UnitPower;
local UnitPowerMax = UnitPowerMax;
local IsSpellKnown = IsSpellKnown;
local GetEclipseDirection = GetEclipseDirection;
local SPELL_POWER_HOLY_POWER = SPELL_POWER_HOLY_POWER;
local SPELL_POWER_SHADOW_ORBS = SPELL_POWER_SHADOW_ORBS
local SPELL_POWER_CHI = SPELL_POWER_CHI

local SPELL_POWER = {
	PALADIN = SPELL_POWER_HOLY_POWER,
	MONK = SPELL_POWER_CHI,
	PRIEST = SPELL_POWER_SHADOW_ORBS
}

function UF:Configure_ClassBar(frame)
	if not frame.VARIABLES_SET then return end
	local bars = frame[frame.ClassBar];
	if(not bars) then return; end
	local db = frame.db;
	bars.origParent = frame;

	if(bars.UpdateAllRuneTypes) then
		bars.UpdateAllRuneTypes(frame);
	end

	if((not self.thinBorders and not E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 7) then
		frame.CLASSBAR_HEIGHT = 7;
		if(db.classbar) then db.classbar.height = 7; end
		UF.ToggleResourceBar(bars);
	elseif((self.thinBorders or E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 3) then
		frame.CLASSBAR_HEIGHT = 3;
		if(db.classbar) then db.classbar.height = 3; end
		UF.ToggleResourceBar(bars);
	elseif (not frame.CLASSBAR_DETACHED and frame.CLASSBAR_HEIGHT > 30) then
		frame.CLASSBAR_HEIGHT = 10
		if db.classbar then db.classbar.height = 10 end
		UF.ToggleResourceBar(bars)
	end

	local CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH;

	local color = self.db.colors.classResources.bgColor;
	bars.backdrop.ignoreUpdates = true;
	bars.backdrop.backdropTexture:SetVertexColor(color.r, color.g, color.b)

	color = E.db.unitframe.colors.borderColor
	bars.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

	if(frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED) then
		bars:ClearAllPoints();
		bars:Point("CENTER", frame.Health.backdrop, "TOP", 0, 0);
		if(E.myclass == "DRUID") then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * 2/3
		else
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * (frame.MAX_CLASS_BAR - 1) / frame.MAX_CLASS_BAR;
		end

		bars:SetFrameLevel(50) --RaisedElementParent uses 100, we want it lower than this

		if(bars.Holder and bars.Holder.mover) then
			bars.Holder.mover:SetScale(0.0001);
			bars.Holder.mover:SetAlpha(0);
		end
	elseif(not frame.CLASSBAR_DETACHED) then
		bars:ClearAllPoints();

		if(frame.ORIENTATION == "RIGHT") then
			bars:Point("BOTTOMRIGHT", frame.Health.backdrop, "TOPRIGHT", -frame.BORDER, frame.SPACING*3);
		else
			bars:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", frame.BORDER, frame.SPACING*3);
		end

		bars:SetFrameLevel(frame:GetFrameLevel() + 5)

		if(bars.Holder and bars.Holder.mover) then
			bars.Holder.mover:SetScale(0.0001);
			bars.Holder.mover:SetAlpha(0);
		end
	else
		CLASSBAR_WIDTH = db.classbar.detachedWidth - ((frame.BORDER + frame.SPACING)*2);
		if(bars.Holder) then bars.Holder:Size(db.classbar.detachedWidth, db.classbar.height); end

		if(not bars.Holder or (bars.Holder and not bars.Holder.mover)) then
			bars.Holder = CreateFrame("Frame", nil, bars);
			bars.Holder:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 150);
			bars.Holder:Size(db.classbar.detachedWidth, db.classbar.height);
			bars:Width(CLASSBAR_WIDTH);
			bars:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER+frame.SPACING)*2));
			bars:ClearAllPoints();
			bars:Point("BOTTOMLEFT", bars.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING);
			E:CreateMover(bars.Holder, "ClassBarMover", L["Classbar"], nil, nil, nil, "ALL,SOLO");
		else
			bars:ClearAllPoints();
			bars:Point("BOTTOMLEFT", bars.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING);
			bars.Holder.mover:SetScale(1);
			bars.Holder.mover:SetAlpha(1);
		end

		if not db.classbar.strataAndLevel.useCustomStrata then
			bars:SetFrameStrata("LOW")
		else
			bars:SetFrameStrata(db.classbar.strataAndLevel.frameStrata)
		end

		if not db.classbar.strataAndLevel.useCustomLevel then
			bars:SetFrameLevel(frame:GetFrameLevel() + 5)
		else
			bars:SetFrameLevel(db.classbar.strataAndLevel.frameLevel)
		end
	end

	bars:Width(CLASSBAR_WIDTH);
	bars:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2));

	if(E.myclass ~= "DRUID") then
		for i = 1, (UF.classMaxResourceBar[E.myclass] or 0) do
			bars[i]:Hide();
			bars[i].backdrop:Hide()

			if(i <= frame.MAX_CLASS_BAR) then
				bars[i].backdrop.ignoreUpdates = true;
				bars[i].backdrop.backdropTexture:SetVertexColor(color.r, color.g, color.b)

				color = E.db.unitframe.colors.borderColor
				bars[i].backdrop:SetBackdropBorderColor(color.r, color.g, color.b);

				bars[i]:Height(bars:GetHeight());
				if(frame.MAX_CLASS_BAR == 1) then
					bars[i]:SetWidth(CLASSBAR_WIDTH);
				elseif(frame.USE_MINI_CLASSBAR) then
					bars[i]:SetWidth((CLASSBAR_WIDTH - ((5 + (frame.BORDER*2 + frame.SPACING*2))*(frame.MAX_CLASS_BAR - 1)))/frame.MAX_CLASS_BAR);
				elseif(i ~= frame.MAX_CLASS_BAR) then
					bars[i]:Width((CLASSBAR_WIDTH - ((frame.MAX_CLASS_BAR-1)*(frame.BORDER-frame.SPACING))) / frame.MAX_CLASS_BAR);
				end

				bars[i]:GetStatusBarTexture():SetHorizTile(false);
				bars[i]:ClearAllPoints();
				if(i == 1) then
					bars[i]:Point("LEFT", bars);
				else
					if(frame.USE_MINI_CLASSBAR) then
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", (5 + frame.BORDER*2 + frame.SPACING*2), 0);
					elseif i == frame.MAX_CLASS_BAR then
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", frame.BORDER-frame.SPACING, 0);
						bars[i]:Point("RIGHT", bars);
					else
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", frame.BORDER-frame.SPACING, 0);
					end
				end

				if(not frame.USE_MINI_CLASSBAR) then
					bars[i].backdrop:Hide();
				else
					bars[i].backdrop:Show();
				end

				if E.myclass == "ROGUE" or E.myclass == "MONK" then
					bars[i]:SetStatusBarColor(unpack(ElvUF.colors[frame.ClassBar][i]))

					if bars[i].bg then
						bars[i].bg:SetTexture(unpack(ElvUF.colors[frame.ClassBar][i]))
					end
				elseif(E.myclass ~= "DEATHKNIGHT") then
					bars[i]:SetStatusBarColor(unpack(ElvUF.colors[frame.ClassBar]));

					if(bars[i].bg) then
						bars[i].bg:SetTexture(unpack(ElvUF.colors[frame.ClassBar]));
					end
				end

				if frame.CLASSBAR_DETACHED and db.classbar.verticalOrientation then
					bars[i]:SetOrientation("VERTICAL")
				else
					bars[i]:SetOrientation("HORIZONTAL")
				end

				bars[i]:Show();
			end
		end
	else
		--?? Apparent bug fix for the width after in-game settings change
		bars.LunarBar:SetMinMaxValues(0, 0)
		bars.SolarBar:SetMinMaxValues(0, 0)
		bars.LunarBar:SetStatusBarColor(unpack(ElvUF.colors.EclipseBar[1]))
		bars.SolarBar:SetStatusBarColor(unpack(ElvUF.colors.EclipseBar[2]))
		bars.LunarBar:Size(CLASSBAR_WIDTH, frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))
		bars.SolarBar:Size(CLASSBAR_WIDTH, frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))
	end

	if(E.myclass ~= "DRUID") then
		if(not frame.USE_MINI_CLASSBAR) then
			bars.backdrop:Show();
		else
			bars.backdrop:Hide();
		end
	end

	if(frame.CLASSBAR_DETACHED and db.classbar.parent == "UIPARENT") then
		E.FrameLocks[bars] = true;
		bars:SetParent(E.UIParent);
	else
		E.FrameLocks[bars] = nil;
		bars:SetParent(frame);
	end

	if(frame.db.classbar.enable and frame.CAN_HAVE_CLASSBAR and not frame:IsElementEnabled(frame.ClassBar)) then
		frame:EnableElement(frame.ClassBar);
		bars:Show();
	elseif(not frame.USE_CLASSBAR and frame:IsElementEnabled(frame.ClassBar)) then
		frame:DisableElement(frame.ClassBar);
		bars:Hide();
	end
end

local function ToggleResourceBar(bars)
	local frame = bars.origParent or bars:GetParent();
	local db = frame.db;
	if(not db) then return; end
	frame.CLASSBAR_SHOWN = bars:IsShown();

	local height;
	if(db.classbar) then
		height = db.classbar.height;
	elseif(db.combobar) then
		height = db.combobar.height;
	elseif(frame.AlternativePower) then
		height = db.power.height;
	end

	if(bars.text) then
		if(frame.CLASSBAR_SHOWN) then
			bars.text:SetAlpha(1);
		else
			bars.text:SetAlpha(0);
		end
	end

	frame.CLASSBAR_HEIGHT = (frame.USE_CLASSBAR and (frame.CLASSBAR_SHOWN and height) or 0);
	frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and ((frame.SPACING+(frame.CLASSBAR_HEIGHT/2))) or (frame.CLASSBAR_HEIGHT - (frame.BORDER-frame.SPACING)));

	if(not frame.CLASSBAR_DETACHED) then
		UF:Configure_HealthBar(frame);
		UF:Configure_Portrait(frame, true);
		UF:Configure_Threat(frame);
	end
end
UF.ToggleResourceBar = ToggleResourceBar;

-- Paladin
function UF:Construct_PaladinResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	for i = 1, UF["classMaxResourceBar"][E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
		bars[i]:SetStatusBarTexture(E["media"].blankTex)
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF["statusbars"][bars[i]] = true

		bars[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		bars[i].backdrop:SetParent(bars)

		bars[i].bg = bars[i]:CreateTexture(nil, "BORDER")
		bars[i].bg:SetAllPoints()
		bars[i].bg:SetTexture(E["media"].blankTex)
		bars[i].bg.multiplier = 0.3
	end

	bars.Override = UF.Update_HolyPower
	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

function UF:Update_HolyPower(event, unit, powerType)
	if not (powerType == nil or powerType == "HOLY_POWER") then return end

	local db = self.db
	if not db then return; end
	local numPower = UnitPower("player", SPELL_POWER[E.myclass]);
	local maxPower = UnitPowerMax("player", SPELL_POWER[E.myclass]);

	local bars = self[self.ClassBar]
	local isShown = bars:IsShown()
	if numPower == 0 and db.classbar.autoHide then
		bars:Hide()
	else
		bars:Show()
		for i = 1, maxPower do
			if(i <= numPower) then
				bars[i]:SetAlpha(1)
			else
				bars[i]:SetAlpha(.2)
			end
		end
	end

	if maxPower ~= self.MAX_CLASS_BAR then
		self.MAX_CLASS_BAR = maxPower
		UF:Configure_ClassBar(self)
	end
end

-- Mage
function UF:Construct_MageResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	for i = 1, UF["classMaxResourceBar"][E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
		bars[i]:SetStatusBarTexture(E["media"].blankTex)
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF["statusbars"][bars[i]] = true

		bars[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		bars[i].backdrop:SetParent(bars)

		bars[i].bg = bars[i]:CreateTexture(nil, "BORDER")
		bars[i].bg:SetAllPoints()
		bars[i].bg:SetTexture(E["media"].blankTex)
		bars[i].bg.multiplier = 0.3
	end

	bars.PostUpdate = UF.UpdateArcaneCharges
	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

function UF:UpdateArcaneCharges(event, arcaneCharges, maxCharges)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return; end

	if(E.myspec == 1 and arcaneCharges == 0) then
		if db.classbar.autoHide then
			self:Hide()
		else
			for i = 1, maxCharges do
				self[i]:SetValue(0)
				self[i]:SetScript("OnUpdate", nil)
			end

			self:Show()
		end
	end
end

-- Rogue
function UF:Construct_RogueResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	for i = 1, UF["classMaxResourceBar"][E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
		bars[i]:SetStatusBarTexture(E["media"].blankTex)
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF["statusbars"][bars[i]] = true

		bars[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		bars[i].backdrop:SetParent(bars)

		bars[i].bg = bars[i]:CreateTexture(nil, "BORDER")
		bars[i].bg:SetAllPoints()
		bars[i].bg:SetTexture(E["media"].blankTex)
		bars[i].bg.multiplier = 0.3
	end

	bars.PostUpdate = UF.UpdateAnticipation
	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

function UF:UpdateAnticipation(event, charges, maxCharges)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return; end

	if(IsSpellKnown(114015) and charges == 0) then
		if db.classbar.autoHide then
			self:Hide()
		else
			for i = 1, maxCharges do
				self[i]:SetValue(0)
				self[i]:SetScript("OnUpdate", nil)
			end

			self:Show()
		end
	end
end

-- Warlock
function UF:Construct_WarlockResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	for i = 1, UF["classMaxResourceBar"][E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
		bars[i]:SetStatusBarTexture(E["media"].blankTex)
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF["statusbars"][bars[i]] = true

		bars[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		bars[i].backdrop:SetParent(bars)

		bars[i].bg = bars[i]:CreateTexture(nil, "BORDER")
		bars[i].bg:SetAllPoints()
		bars[i].bg:SetTexture(E["media"].blankTex)
		bars[i].bg.multiplier = 0.3
	end

	bars.PostUpdate = UF.UpdateShardBar
	bars:SetScript("OnShow", ToggleResourceBar)
	bars:SetScript("OnHide", ToggleResourceBar)

	return bars
end

function UF:UpdateShardBar()
	local frame = self.origParent or self:GetParent()
	if not frame.USE_CLASSBAR then return; end

	if frame.MAX_CLASS_BAR ~= self.number then
		frame.MAX_CLASS_BAR = self.number
		UF:Configure_ClassBar(frame)
		ToggleResourceBar(self)
	end
end

-- Monk
function UF:Construct_MonkResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	for i = 1, UF["classMaxResourceBar"][E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
		bars[i]:SetStatusBarTexture(E["media"].blankTex)
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF["statusbars"][bars[i]] = true

		bars[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		bars[i].backdrop:SetParent(bars)

		bars[i].bg = bars[i]:CreateTexture(nil, "BORDER")
		bars[i].bg:SetAllPoints()
		bars[i].bg:SetTexture(E["media"].blankTex)
		bars[i].bg.multiplier = 0.3
	end

	bars.PostUpdate = UF.UpdateHarmony

	return bars
end

function UF:UpdateHarmony()
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return; end

	local maxBars = self.numPoints
	local numChi = UnitPower("player", SPELL_POWER_CHI)
	local isShown = self:IsShown()

	if numChi == 0 and db.classbar.autoHide then
		self:Hide()
		if self.updateOnHide ~= false then 
			ToggleResourceBar(self)
			self.updateOnHide = false
		end
	else
		if frame.CLASSBAR_SHOWN ~= isShown then
			ToggleResourceBar(self)
			self.updateOnHide = true
		end
	end

	if maxBars ~= frame.MAX_CLASS_BAR then
		for i=1, frame.MAX_CLASS_BAR do
			if self[i]:IsShown() and frame.USE_MINI_CLASSBAR then
				self[i].backdrop:Show()
			else
				self[i].backdrop:Hide()
			end
		end
		frame.MAX_CLASS_BAR = maxBars
		UF:Configure_ClassBar(frame)
	end
end

--Priest
function UF:Construct_PriestResourceBar(frame)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop("Default", nil, nil, self.thinBorders, true)

	for i = 1, UF["classMaxResourceBar"][E.myclass] do
		bars[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, bars)
		bars[i]:SetStatusBarTexture(E["media"].blankTex)
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF["statusbars"][bars[i]] = true

		bars[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		bars[i].backdrop:SetParent(bars)

		bars[i].bg = bars[i]:CreateTexture(nil, "BORDER")
		bars[i].bg:SetAllPoints()
		bars[i].bg:SetTexture(E["media"].blankTex)
		bars[i].bg.multiplier = 0.3
	end

	bars.PostUpdate = UF.UpdateShadowOrbs

	return bars
end


function UF:UpdateShadowOrbs()
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return; end
	local numPower = UnitPower("player", SPELL_POWER[E.myclass]);
	local maxPower = UnitPowerMax("player", SPELL_POWER[E.myclass]);

	local bars = frame[frame.ClassBar]
	local isShown = bars:IsShown()

	if(numPower == 0 and db.classbar.autoHide) then
		bars:Hide()
		if(bars.updateOnHide ~= false) then
			ToggleResourceBar(bars)
			bars.updateOnHide = false
		end
	else
		if(frame.CLASSBAR_SHOWN ~= isShown) then
			ToggleResourceBar(bars)
			bars.updateOnHide = true
		end
		for i = 1, maxPower do
			if(i <= numPower) then
				bars[i]:SetAlpha(1)
			else
				bars[i]:SetAlpha(.2)
			end
		end
	end

	if(maxPower ~= frame.MAX_CLASS_BAR) then
		frame.MAX_CLASS_BAR = maxPower
		UF:Configure_ClassBar(frame)
	end
end

--Death Knight
function UF:Construct_DeathKnightResourceBar(frame)
	local runes = CreateFrame("Frame", nil, frame);
	runes:CreateBackdrop("Default", nil, nil, self.thinBorders, true);

	for i = 1, self["classMaxResourceBar"][E.myclass] do
		runes[i] = CreateFrame("StatusBar", frame:GetName().."ClassBarButton"..i, runes)
		self["statusbars"][runes[i]] = true;
		runes[i]:SetStatusBarTexture(E["media"].blankTex);
		runes[i]:GetStatusBarTexture():SetHorizTile(false);

		runes[i]:CreateBackdrop("Default", nil, nil, self.thinBorders, true);
		runes[i].backdrop:SetParent(runes);

		runes[i].bg = runes[i]:CreateTexture(nil, "BORDER");
		runes[i].bg:SetAllPoints();
		runes[i].bg:SetTexture(E["media"].blankTex);
		runes[i].bg.multiplier = 0.2;
	end

	return runes;
end

-- Druid
function UF:Construct_DruidResourceBar(frame)
	local eclipseBar = CreateFrame("Frame", nil, frame)
	eclipseBar:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
	eclipseBar.PostUpdatePower = UF.EclipseDirection
	eclipseBar.PostUpdateVisibility = UF.EclipsePostUpdateVisibility

	local lunarBar = CreateFrame("StatusBar", nil, eclipseBar)
	lunarBar:Point("LEFT", eclipseBar)
	lunarBar:SetStatusBarTexture(E["media"].blankTex)
	UF["statusbars"][lunarBar] = true
	eclipseBar.LunarBar = lunarBar

	local solarBar = CreateFrame("StatusBar", nil, eclipseBar)
	solarBar:Point("LEFT", lunarBar:GetStatusBarTexture(), "RIGHT")
	solarBar:SetStatusBarTexture(E["media"].blankTex)
	UF["statusbars"][solarBar] = true
	eclipseBar.SolarBar = solarBar

	eclipseBar.Text = lunarBar:CreateFontString(nil, "OVERLAY")
	eclipseBar.Text:FontTemplate(nil, 20)
	eclipseBar.Text:Point("CENTER", lunarBar:GetStatusBarTexture(), "RIGHT")

	return eclipseBar
end

function UF:Construct_DruidAltManaBar(frame)
	local dpower = CreateFrame("Frame", nil, frame)
	dpower:SetInside(frame.EclipseBar.backdrop)
	dpower:CreateBackdrop("Default", nil, nil, self.thinBorders, true);
	dpower:SetFrameLevel(dpower:GetFrameLevel() + 10)
	dpower.colorPower = true;
	dpower.PostUpdateVisibility = UF.DruidManaPostUpdateVisibility
	dpower.PostUpdatePower = UF.DruidPostUpdateAltPower

	dpower.ManaBar = CreateFrame("StatusBar", nil, dpower)
	dpower.ManaBar:SetStatusBarTexture(E["media"].blankTex)
	UF['statusbars'][dpower.ManaBar] = true
	dpower.ManaBar:SetAllPoints(dpower)

	dpower.bg = dpower:CreateTexture(nil, "BORDER")
	dpower.bg:SetAllPoints(dpower.ManaBar)
	dpower.bg:SetTexture(E["media"].blankTex)
	dpower.bg.multiplier = 0.3

	dpower.Text = dpower:CreateFontString(nil, "OVERLAY")
	UF:Configure_FontString(dpower.Text)

	return dpower
end

function UF:EclipseDirection()
	local direction = GetEclipseDirection()
	if direction == "sun" then
		self.Text:SetText(">")
		self.Text:SetTextColor(.2, .2, 1, 1)
	elseif direction == "moon" then
		self.Text:SetText("<")
		self.Text:SetTextColor(1, 1, .3, 1)
	else
		self.Text:SetText("")
	end
end

function UF:DruidPostUpdateAltPower(_, min, max)
	local frame = self:GetParent()
	local powerValue = frame.Power.value
	local powerValueText = powerValue:GetText()
	local powerValueParent = powerValue:GetParent()
	local db = frame.db

	if not db then return; end

	local powerTextPosition = db.power.position

	if powerValueText then powerValueText = powerValueText:gsub("|cff(.*) ", "") end

	if min ~= max then
		local color = ElvUF["colors"].power["MANA"]
		color = E:RGBToHex(color[1], color[2], color[3])

		self.Text:SetParent(powerValueParent)

		self.Text:ClearAllPoints()
		if (powerValueText ~= "" and powerValueText ~= " ") then
			if find(powerTextPosition, "RIGHT") then
				self.Text:Point("RIGHT", powerValue, "LEFT", 3, 0)
				self.Text:SetFormattedText(color.."%d%%|r |cffD7BEA5- |r", floor(min / max * 100))
			elseif find(powerTextPosition, "LEFT") then
				self.Text:Point("LEFT", powerValue, "RIGHT", -3, 0)
				self.Text:SetFormattedText("|cffD7BEA5-|r"..color.." %d%%|r", floor(min / max * 100))
			else
				if select(4, powerValue:GetPoint()) <= 0 then
					self.Text:Point("LEFT", powerValue, "RIGHT", -3, 0)
					self.Text:SetFormattedText("|cffD7BEA5-|r"..color.." %d%%|r", floor(min / max * 100))
				else
					self.Text:Point("RIGHT", powerValue, "LEFT", 3, 0)
					self.Text:SetFormattedText(color.."%d%%|r |cffD7BEA5- |r", floor(min / max * 100))
				end
			end
		else
			self.Text:Point(powerValue:GetPoint())
			self.Text:SetFormattedText(color.."%d%%|r", floor(min / max * 100))
		end
	else
		self.Text:SetText()
	end
end

local druidEclipseIsShown = false
local druidManaIsShown = false
function UF:EclipsePostUpdateVisibility()
	local isShown = self:IsShown()
	if druidEclipseIsShown ~= isShown then
		druidEclipseIsShown = isShown

		if not druidManaIsShown then
			ToggleResourceBar(self)
		end
	end

	local color = E.db.unitframe.colors.borderColor
	self.backdrop:SetBackdropBorderColor(color.r, color.g, color.b);
end

function UF:DruidManaPostUpdateVisibility()
	local isShown = self:IsShown()
	if druidManaIsShown ~= isShown then
		druidManaIsShown = isShown

		if not druidEclipseIsShown then
			ToggleResourceBar(self)
		end
	end

	local color = E.db.unitframe.colors.borderColor
	self.backdrop:SetBackdropBorderColor(color.r, color.g, color.b);
end