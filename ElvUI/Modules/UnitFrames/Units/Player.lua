local E, L, V, P, G = unpack(select(2, ...))
local UF = E:GetModule("UnitFrames")
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

local _G = _G
local tinsert = table.insert

local CAN_HAVE_CLASSBAR = (E.myclass == "PALADIN" or E.myclass == "DRUID" or E.myclass == "DEATHKNIGHT" or E.myclass == "WARLOCK" or E.myclass == "PRIEST" or E.myclass == "MONK" or E.myclass == "MAGE" or E.myclass == "ROGUE")

function UF:Construct_PlayerFrame(frame)
	frame.ThreatIndicator = self:Construct_Threat(frame)
	frame.Health = self:Construct_HealthBar(frame, true, true, "RIGHT")
	frame.Health.frequentUpdates = true
	frame.Power = self:Construct_PowerBar(frame, true, true, "LEFT")
	frame.Power.frequentUpdates = true
	frame.Name = self:Construct_NameText(frame)
	frame.Portrait3D = self:Construct_Portrait(frame, "model")
	frame.Portrait2D = self:Construct_Portrait(frame, "texture")
	frame.Buffs = self:Construct_Buffs(frame)
	frame.Debuffs = self:Construct_Debuffs(frame)
	frame.Castbar = self:Construct_Castbar(frame, L["Player Castbar"])

	if CAN_HAVE_CLASSBAR then
		--Create a holder frame all "classbars" can be positioned into
		frame.ClassBarHolder = CreateFrame("Frame", nil, frame)
		frame.ClassBarHolder:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 150)

		if E.myclass == "PALADIN" or E.myclass == "MONK" or E.myclass == "PRIEST" then
			frame.ClassPower = self:Construct_ClassBar(frame)
			frame.ClassBar = "ClassPower"
			if E.myclass == "MONK" then
				frame.Stagger = self:Construct_Stagger(frame)
			end
		elseif E.myclass == "MAGE" or E.myclass == "ROGUE" then
			frame.SpecPower = self:Construct_SpecPower(frame)
			frame.ClassBar = "SpecPower"
		elseif E.myclass == "WARLOCK" then
			frame.SoulShards = self:Construct_SoulShardsBar(frame)
			frame.ClassBar = "SoulShards"
			frame.BurningEmbers = self:Construct_BurningEmbersBar(frame)
			frame.DemonicFury = self:Construct_DemonicFuryBar(frame)
		elseif E.myclass == "DEATHKNIGHT" then
			frame.Runes = self:Construct_DeathKnightResourceBar(frame)
			frame.ClassBar = "Runes"
		elseif E.myclass == "DRUID" then
			frame.EclipseBar = self:Construct_DruidEclipseBar(frame)
			frame.ClassBar = "EclipseBar"
			frame.AdditionalPower = self:Construct_AdditionalPowerBar(frame)
		end
	end

	frame.MouseGlow = self:Construct_MouseGlow(frame)
	frame.TargetGlow = self:Construct_TargetGlow(frame)
	frame.FocusGlow = UF:Construct_FocusGlow(frame)
	frame.RaidTargetIndicator = self:Construct_RaidIcon(frame)
	frame.RaidRoleFramesAnchor = self:Construct_RaidRoleFrames(frame)
	frame.RestingIndicator = self:Construct_RestingIndicator(frame)
	frame.ResurrectIndicator = UF:Construct_ResurrectionIcon(frame)
	frame.CombatIndicator = self:Construct_CombatIndicator(frame)
	frame.PvPText = self:Construct_PvPIndicator(frame)
	frame.AuraHighlight = self:Construct_AuraHighlight(frame)
	frame.HealthPrediction = self:Construct_HealComm(frame)
	frame.AuraBars = self:Construct_AuraBarHeader(frame)
	frame.InfoPanel = self:Construct_InfoPanel(frame)
	frame.PvPIndicator = self:Construct_PvPIcon(frame)
	frame.Fader = self:Construct_Fader()
	frame.Cutaway = self:Construct_Cutaway(frame)
	frame.customTexts = {}

	frame:Point("BOTTOMLEFT", E.UIParent, "BOTTOM", -413, 68)
	E:CreateMover(frame, frame:GetName().."Mover", L["Player Frame"], nil, nil, nil, "ALL,SOLO", nil, "unitframe,individualUnits,player,generalGroup")
	frame.unitframeType = "player"
end

function UF:Update_PlayerFrame(frame, db)
	frame.db = db

	do
		frame.ORIENTATION = db.orientation
		frame.UNIT_WIDTH = db.width
		frame.UNIT_HEIGHT = db.infoPanel.enable and (db.height + db.infoPanel.height) or db.height
		frame.USE_POWERBAR = db.power.enable
		frame.POWERBAR_DETACHED = db.power.detachFromFrame
		frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == "inset" and frame.USE_POWERBAR
		frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == "spaced" and frame.USE_POWERBAR)
		frame.USE_POWERBAR_OFFSET = (db.power.width == "offset" and db.power.offset ~= 0) and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED
		frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0
		frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (frame.BORDER * 2)) / 2 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((frame.BORDER + frame.SPACING) * 2)))
		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == "MIDDLE")
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width
		frame.CAN_HAVE_CLASSBAR = CAN_HAVE_CLASSBAR
		frame.MAX_CLASS_BAR = frame.MAX_CLASS_BAR or UF.classMaxResourceBar[E.myclass] or 0
		frame.USE_CLASSBAR = db.classbar.enable and frame.CAN_HAVE_CLASSBAR
		frame.CLASSBAR_SHOWN = frame.CAN_HAVE_CLASSBAR and frame[frame.ClassBar]:IsShown()
		frame.CLASSBAR_DETACHED = db.classbar.detachFromFrame
		frame.USE_MINI_CLASSBAR = db.classbar.fill == "spaced" and frame.USE_CLASSBAR
		frame.CLASSBAR_HEIGHT = frame.USE_CLASSBAR and db.classbar.height or 0
		frame.CLASSBAR_WIDTH = frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING) * 2) - frame.PORTRAIT_WIDTH - (frame.ORIENTATION == "MIDDLE" and (frame.POWERBAR_OFFSET * 2) or frame.POWERBAR_OFFSET)
		--If formula for frame.CLASSBAR_YOFFSET changes, then remember to update it in classbars.lua too
		frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and (frame.SPACING + (frame.CLASSBAR_HEIGHT / 2)) or (frame.CLASSBAR_HEIGHT - (frame.BORDER - frame.SPACING)))
		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0
		frame.USE_STAGGER = db.stagger and db.stagger.enable
		frame.STAGGER_SHOWN = frame.USE_STAGGER and frame.Stagger and frame.Stagger:IsShown()
		frame.STAGGER_WIDTH = frame.STAGGER_SHOWN and (db.stagger.width + (frame.BORDER * 3)) or 0
		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)

		frame.VARIABLES_SET = true
	end

	if db.strataAndLevel and db.strataAndLevel.useCustomStrata then
		frame:SetFrameStrata(db.strataAndLevel.frameStrata)
	else
		frame:SetFrameStrata(frame:GetParent():GetFrameStrata())
	end

	if db.strataAndLevel and db.strataAndLevel.useCustomLevel then
		frame:SetFrameLevel(db.strataAndLevel.frameLevel)
	else
		frame:SetFrameLevel(frame:GetParent():GetFrameLevel() + 1)
	end

	frame.colors = ElvUF.colors
	frame.Portrait = frame.Portrait or (db.portrait.style == "2D" and frame.Portrait2D or frame.Portrait3D)
	frame:RegisterForClicks(self.db.targetOnMouseDown and "AnyDown" or "AnyUp")
	frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
	_G[frame:GetName().."Mover"]:Size(frame:GetSize())

	UF:Configure_InfoPanel(frame)
	UF:Configure_Threat(frame)
	UF:Configure_RestingIndicator(frame)
	UF:Configure_CombatIndicator(frame)
	UF:Configure_ClassBar(frame)
	UF:Configure_HealthBar(frame)
	UF:UpdateNameSettings(frame)
	UF:Configure_PVPIndicator(frame)
	UF:Configure_Power(frame)
	UF:Configure_Portrait(frame)
	UF:EnableDisable_Auras(frame)
	UF:Configure_AllAuras(frame)
	UF:Configure_ResurrectionIcon(frame)
	if E.myclass == "MONK" then
		UF:Configure_Stagger(frame)
	end
	--Castbar
	frame:DisableElement("Castbar")
	UF:Configure_Castbar(frame)

	if not db.enable and not E.private.unitframe.disabledBlizzardFrames.player then
		CastingBarFrame_OnLoad(CastingBarFrame, "player", true, false)
		CastingBarFrame_SetUnit(CastingBarFrame, "player", true, false)
		PetCastingBarFrame_OnLoad(PetCastingBarFrame)
		CastingBarFrame_SetUnit(PetCastingBarFrame, "pet", false, false)
	elseif not db.enable and E.private.unitframe.disabledBlizzardFrames.player or (db.enable and not db.castbar.enable) then
		CastingBarFrame_SetUnit(CastingBarFrame, nil)
		CastingBarFrame_SetUnit(PetCastingBarFrame, nil)
	end
	UF:Configure_Fader(frame)
	UF:Configure_AuraHighlight(frame)
	UF:Configure_RaidIcon(frame)
	UF:Configure_HealComm(frame)
	UF:Configure_AuraBars(frame)
	--We need to update Target AuraBars if attached to Player AuraBars
	--mainly because of issues when using power offset on player and switching to/from middle orientation
	if E.db.unitframe.units.target.aurabar.attachTo == "PLAYER_AURABARS" and ElvUF_Target then
		UF:Configure_AuraBars(ElvUF_Target)
	end
	UF:Configure_PVPIcon(frame)
	UF:Configure_RaidRoleIcons(frame)
	UF:Configure_Cutaway(frame)
	UF:Configure_CustomTexts(frame)

	E:SetMoverSnapOffset(frame:GetName().."Mover", -(12 + db.castbar.height))
	frame:UpdateAllElements("ElvUI_UpdateAllElements")
end

tinsert(UF.unitstoload, "player")