local E, L, V, P, G = unpack(select(2, ...))
local UF = E:GetModule("UnitFrames")
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

local _G = _G
local tinsert = table.insert

function UF:Construct_FocusTargetFrame(frame)
	frame.Health = UF:Construct_HealthBar(frame, true, true, "RIGHT")
	frame.Power = UF:Construct_PowerBar(frame, true, true, "LEFT")
	frame.Name = UF:Construct_NameText(frame)
	frame.Portrait3D = UF:Construct_Portrait(frame, "model")
	frame.Portrait2D = UF:Construct_Portrait(frame, "texture")
	frame.Buffs = UF:Construct_Buffs(frame)
	frame.RaidTargetIndicator = UF:Construct_RaidIcon(frame)
	frame.Debuffs = UF:Construct_Debuffs(frame)
	frame.ThreatIndicator = UF:Construct_Threat(frame)
	frame.MouseGlow = UF:Construct_MouseGlow(frame)
	frame.TargetGlow = UF:Construct_TargetGlow(frame)
	frame.FocusGlow = UF:Construct_FocusGlow(frame)
	frame.InfoPanel = UF:Construct_InfoPanel(frame)
	frame.Fader = UF:Construct_Fader()
	frame.Cutaway = UF:Construct_Cutaway(frame)

	frame.customTexts = {}
	frame:Point("BOTTOM", ElvUF_Focus, "TOP", 0, 7)
	E:CreateMover(frame, frame:GetName().."Mover", L["FocusTarget Frame"], nil, -7, nil, "ALL,SOLO", nil, "unitframe,individualUnits,focustarget,generalGroup")
	frame.unitframeType = "focustarget"
end

function UF:Update_FocusTargetFrame(frame, db)
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
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (UF.BORDER * 2)) / 2 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((UF.BORDER + UF.SPACING) * 2)))
		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == "MIDDLE")
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width
		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0
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
	UF:Configure_HealthBar(frame)
	UF:UpdateNameSettings(frame)
	UF:Configure_Power(frame)
	UF:Configure_Portrait(frame)
	UF:Configure_Threat(frame)
	UF:EnableDisable_Auras(frame)
	UF:Configure_AllAuras(frame)
	UF:Configure_Fader(frame)
	UF:Configure_RaidIcon(frame)
	UF:Configure_Cutaway(frame)
	UF:Configure_CustomTexts(frame)

	frame:UpdateAllElements("ElvUI_UpdateAllElements")
end

tinsert(UF.unitstoload, "focustarget")