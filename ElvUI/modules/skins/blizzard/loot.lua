local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local unpack, select = unpack, select;
local find = string.find;

local UnitName = UnitName;
local IsFishingLoot = IsFishingLoot;
local GetLootRollItemInfo = GetLootRollItemInfo
local GetItemQualityColor = GetItemQualityColor
local SquareButton_SetIcon = SquareButton_SetIcon
local C_LootHistory_GetNumItems = C_LootHistory.GetNumItems
local LOOTFRAME_NUMBUTTONS = LOOTFRAME_NUMBUTTONS;
local NUM_GROUP_LOOT_FRAMES = NUM_GROUP_LOOT_FRAMES
local LOOT = LOOT;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.loot ~= true) then return; end

	-- Loot History Frame
	LootHistoryFrame:StripTextures()
	LootHistoryFrame:SetTemplate('Transparent')

	LootHistoryFrameScrollFrame:StripTextures()

	LootHistoryFrame.ResizeButton:StripTextures();
	LootHistoryFrame.ResizeButton:SetTemplate();
	LootHistoryFrame.ResizeButton:HookScript("OnEnter", S.SetModifiedBackdrop);
	LootHistoryFrame.ResizeButton:HookScript("OnLeave", S.SetOriginalBackdrop);
	LootHistoryFrame.ResizeButton:Width(LootHistoryFrame:GetWidth())
	LootHistoryFrame.ResizeButton:Height(19)
	LootHistoryFrame.ResizeButton:ClearAllPoints()
	LootHistoryFrame.ResizeButton:Point("TOP", LootHistoryFrame, "BOTTOM", 0, -2)

	LootHistoryFrame.ResizeButton.icon = LootHistoryFrame.ResizeButton:CreateTexture(nil, "ARTWORK");
	LootHistoryFrame.ResizeButton.icon:Size(20, 17);
	LootHistoryFrame.ResizeButton.icon:Point("CENTER");
	LootHistoryFrame.ResizeButton.icon:SetTexture([[Interface\Buttons\SquareButtonTextures]])

	SquareButton_SetIcon(LootHistoryFrame.ResizeButton, "DOWN");

	S:HandleScrollBar(LootHistoryFrameScrollFrameScrollBar)

	S:HandleCloseButton(LootHistoryFrame.CloseButton)

	local function UpdateLoots()
		local numItems = C_LootHistory_GetNumItems()
		for i = 1, numItems do
			local frame = LootHistoryFrame.itemFrames[i]

			if(not frame.isSkinned) then
				local Icon = frame.Icon:GetTexture()

				frame:StripTextures()
				frame:CreateBackdrop()
				frame.backdrop:SetOutside(frame.Icon)

				frame.Icon:SetTexture(Icon)
				frame.Icon:SetTexCoord(unpack(E.TexCoords))
				frame.Icon:SetParent(frame.backdrop)

				frame.ToggleButton:SetNormalTexture("");
				frame.ToggleButton.SetNormalTexture = E.noop;
				frame.ToggleButton:SetPushedTexture("");
				frame.ToggleButton.SetPushedTexture = E.noop;
				frame.ToggleButton:SetHighlightTexture("")
				frame.ToggleButton.SetHighlightTexture = E.noop;

				frame.ToggleButton.Text = frame.ToggleButton:CreateFontString(nil, "OVERLAY");
				frame.ToggleButton.Text:FontTemplate(nil, 22);
				frame.ToggleButton.Text:Point("LEFT", -1, 0);
				frame.ToggleButton.Text:SetText("+");

				hooksecurefunc(frame.ToggleButton, "SetNormalTexture", function(self, texture)
					if(find(texture, "MinusButton")) then
						self.Text:SetText("-");
					else
						self.Text:SetText("+");
					end
				end);

				frame.isSkinned = true
			end
		end
	end
	hooksecurefunc("LootHistoryFrame_FullUpdate", UpdateLoots)

	--MasterLoot Frame
	MasterLooterFrame:StripTextures()
	MasterLooterFrame:SetTemplate("Transparent")
	MasterLooterFrame:SetFrameStrata("TOOLTIP")

	hooksecurefunc("MasterLooterFrame_Show", function()
		local b = MasterLooterFrame.Item
		if b then
			local i = b.Icon
			local icon = i:GetTexture()
			local c = ITEM_QUALITY_COLORS[LootFrame.selectedQuality]

			b:StripTextures()
			i:SetTexture(icon)
			i:SetTexCoord(unpack(E.TexCoords))
			b:CreateBackdrop()
			b.backdrop:SetOutside(i)
			b.backdrop:SetBackdropBorderColor(c.r, c.g, c.b)
		end

		for i = 1, MasterLooterFrame:GetNumChildren() do
			local child = select(i, MasterLooterFrame:GetChildren())
			if child and not child.isSkinned and not child:GetName() then
				if child:GetObjectType() == "Button" then
					if child:GetPushedTexture() then
						S:HandleCloseButton(child)
					else
						child:StripTextures()
						child:SetTemplate()
						child:StyleButton()
					end
					child.isSkinned = true
				end
			end
		end
	end)

	--Bonus Roll Frame
	BonusRollFrame:StripTextures()
	BonusRollFrame:SetTemplate("Transparent")

	BonusRollFrame.PromptFrame.Icon:SetTexCoord(unpack(E.TexCoords))

	BonusRollFrame.PromptFrame.IconBackdrop = CreateFrame("Frame", nil, BonusRollFrame.PromptFrame)
	BonusRollFrame.PromptFrame.IconBackdrop:SetFrameLevel(BonusRollFrame.PromptFrame.IconBackdrop:GetFrameLevel() - 1)
	BonusRollFrame.PromptFrame.IconBackdrop:SetOutside(BonusRollFrame.PromptFrame.Icon)
	BonusRollFrame.PromptFrame.IconBackdrop:SetTemplate()

	BonusRollFrame.PromptFrame.Timer.Bar:SetTexture(1, 1, 1)
	BonusRollFrame.PromptFrame.Timer.Bar:SetVertexColor(1, 1, 1)

	--Loot Frame
	if(E.private.general.loot) then return; end

	LootFrame:StripTextures();
	LootFrame:SetTemplate("Transparent")

	LootFrameInset:Kill()
	LootFramePortraitOverlay:SetParent(E.HiddenFrame);

	S:HandleCloseButton(LootFrameCloseButton);

	for i = 1, LootFrame:GetNumRegions() do
		local region = select(i, LootFrame:GetRegions());
		if(region:GetObjectType() == "FontString") then
			if(region:GetText() == ITEMS) then
				LootFrame.Title = region;
			end
		end
	end

	LootFrame.Title:ClearAllPoints();
	LootFrame.Title:Point("TOPLEFT", LootFrame.backdrop, "TOPLEFT", 4, -4);
	LootFrame.Title:SetJustifyH("LEFT");

	for i = 1, LOOTFRAME_NUMBUTTONS do
		local button = _G["LootButton" .. i]
		local questTex = _G["LootButton"..i.."IconQuestTexture"]

		_G["LootButton" .. i .. "NameFrame"]:Hide()

		S:HandleItemButton(button, true)

		questTex:SetTexCoord(unpack(E.TexCoords))
		questTex:SetInside()
	end

	S:HandleNextPrevButton(LootFrameUpButton);
	SquareButton_SetIcon(LootFrameUpButton, "UP");
	LootFrameUpButton:Point("BOTTOMLEFT", 25, 20)

	S:HandleNextPrevButton(LootFrameDownButton);
	SquareButton_SetIcon(LootFrameDownButton, "DOWN");
	LootFrameDownButton:Point("BOTTOMLEFT", 143, 20)

	LootFrame:HookScript("OnShow", function(self)
		if(IsFishingLoot()) then
			self.Title:SetText(L["Fishy Loot"]);
		elseif(not UnitIsFriend("player", "target") and UnitIsDead("target")) then
			self.Title:SetText(UnitName("target"));
		else
			self.Title:SetText(LOOT);
		end
	end);
end

local function LoadRollSkin()
	if(E.private.general.lootRoll) then return; end
	if(not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lootRoll) then return; end

	local function OnShow(self)
		local cornerTexture = _G[self:GetName() .. "Corner"]
		local iconFrame = _G[self:GetName() .. "IconFrame"]
		local statusBar = _G[self:GetName() .. "Timer"]
		local _, _, _, quality = GetLootRollItemInfo(self.rollID)

		self:SetTemplate("Transparent")

		cornerTexture:SetTexture()

		iconFrame:SetBackdropBorderColor(GetItemQualityColor(quality))
		statusBar:SetStatusBarColor(GetItemQualityColor(quality))
	end

	for i = 1, NUM_GROUP_LOOT_FRAMES do
		local frame = _G["GroupLootFrame" .. i]
		frame:StripTextures();
		frame:ClearAllPoints();

		if(i == 1) then
			frame:Point("TOP", AlertFrameHolder, "BOTTOM", 0, -4);
		else
			frame:Point("TOP", _G["GroupLootFrame" .. i - 1], "BOTTOM", 0, -4);
		end

		local frameName = frame:GetName();

		local iconFrame = _G[frameName .. "IconFrame"];
		iconFrame:SetTemplate("Default");
		iconFrame:StyleButton()

		local icon = _G[frameName .. "IconFrameIcon"];
		icon:SetInside();
		icon:SetTexCoord(unpack(E.TexCoords));

		local statusBar = _G[frameName .. "Timer"];
		statusBar:StripTextures();
		statusBar:CreateBackdrop("Default");
		statusBar:SetStatusBarTexture(E["media"].normTex);
		E:RegisterStatusBar(statusBar);

		local decoration = _G[frameName .. "Decoration"];
		decoration:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon");
		decoration:Size(130);
		decoration:Point("TOPLEFT", -37, 20);

		local pass = _G[frameName .. "PassButton"];
		S:HandleCloseButton(pass, frame);

		_G["GroupLootFrame" .. i]:HookScript("OnShow", OnShow);
	end
end

S:AddCallback("Loot", LoadSkin);
S:AddCallback("LootRoll", LoadRollSkin); 