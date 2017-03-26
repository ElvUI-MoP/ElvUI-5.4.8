local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local _G = _G;
local split = string.split;

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bgscore ~= true then return end

	for i = 19, MAX_WORLDSTATE_SCORE_BUTTONS do
		_G["WorldStateScoreButton"..i]:StripTextures()
	end
	MAX_WORLDSTATE_SCORE_BUTTONS = 18; WorldStateScoreFrame_Resize()

	WorldStateScoreFrame:StripTextures()
	WorldStateScoreFrame:SetTemplate("Transparent")

	WorldStateScoreScrollFrame:StripTextures()
	WorldStateScoreFrameInset:Kill()

	S:HandleCloseButton(WorldStateScoreFrameCloseButton)
	S:HandleScrollBar(WorldStateScoreScrollFrameScrollBar)
	S:HandleButton(WorldStateScoreFrameLeaveButton)

	for i = 1, 3 do 
		S:HandleTab(_G["WorldStateScoreFrameTab"..i])
	end

	WorldStateScoreFrameTab1:Point("TOPLEFT", WorldStateScoreFrame, "BOTTOMLEFT", 5, 2)

	WorldStateScoreFrameKB:StyleButton()
	WorldStateScoreFrameDeaths:StyleButton()
	WorldStateScoreFrameHK:StyleButton()
	WorldStateScoreFrameDamageDone:StyleButton()
	WorldStateScoreFrameHealingDone:StyleButton()
	WorldStateScoreFrameHonorGained:StyleButton()
	WorldStateScoreFrameName:StyleButton()
	WorldStateScoreFrameClass:StyleButton()
	WorldStateScoreFrameTeam:StyleButton()
	WorldStateScoreFrameRatingChange:StyleButton()

	for i = 1, 5 do 
		_G["WorldStateScoreColumn"..i]:StyleButton()
	end

	hooksecurefunc("WorldStateScoreFrame_Update", function()
		local inArena = IsActiveBattlefieldArena()
		local offset = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame)

		for i = 1, MAX_WORLDSTATE_SCORE_BUTTONS do
			local index = offset + i
			local name, _, _, _, _, faction, _, _, class = GetBattlefieldScore(index)
			if(name) then
				local n, r = split("-", name, 2)
				local myName = UnitName("player")

				if(name == myName) then
					n = "> "..n.." <"
				end

				if(r) then
					local color
					if(inArena) then
						if(faction == 1) then
							color = "|cffffd100"
						else
							color = "|cff19ff19"
						end
					else
						if(faction == 1) then
							color = "|cff00adf0"
						else
							color = "|cffff1919"
						end
					end
					r = color..r.."|r"
					n = n.."|cffffffff - |r"..r
				end

				local classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class];

				_G["WorldStateScoreButton"..i.."NameText"]:SetText(n)
				_G["WorldStateScoreButton"..i.."NameText"]:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
			end
		end
	end)
end

S:AddCallback("WorldStateScore", LoadSkin);