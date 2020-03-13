local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs = pairs

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.raid ~= true then return end

	local StripAllTextures = {
		"RaidGroup1",
		"RaidGroup2",
		"RaidGroup3",
		"RaidGroup4",
		"RaidGroup5",
		"RaidGroup6",
		"RaidGroup7",
		"RaidGroup8"
	}

	for _, object in pairs(StripAllTextures) do
		if not _G[object] then print(object) end

		if _G[object] then
			_G[object]:StripTextures()
		end
	end

	for i = 1, MAX_RAID_GROUPS*5 do
		S:HandleButton(_G["RaidGroupButton"..i], true)
	end

	for i = 1, 8 do
		for j = 1, 5 do
			_G["RaidGroup"..i.."Slot"..j]:StripTextures()
			_G["RaidGroup"..i.."Slot"..j]:SetTemplate("Transparent")
		end
	end

	--[[S:HandleButton(RaidFrameReadyCheckButton)
	RaidFrameReadyCheckButton:Point("TOPLEFT", RaidFrameAllAssistCheckButton, "TOPRIGHT", 100, -1)

	S:HandleCheckBox(RaidFrameAllAssistCheckButton)
	RaidFrameAllAssistCheckButton:Point("TOPLEFT", 15, -23)

	RaidFrameAllAssistCheckButtonText:Point("LEFT", RaidFrameAllAssistCheckButton, "RIGHT", 0, -2)]]
end

S:AddCallbackForAddon("Blizzard_RaidUI", "RaidUI", LoadSkin)