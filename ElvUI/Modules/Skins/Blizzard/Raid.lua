local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs = pairs

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.raid then return end

	for i = 1, MAX_RAID_GROUPS do
		local frame = _G["RaidGroup"..i]

		frame:StripTextures()

		for j = 1, 5 do
			local slot = _G["RaidGroup"..i.."Slot"..j]

			slot:StripTextures()
			slot:SetTemplate("Transparent")
		end
	end

	for i = 1, MAX_RAID_GROUPS * 5 do
		S:HandleButton(_G["RaidGroupButton"..i], true)
	end
end

S:AddCallbackForAddon("Blizzard_RaidUI", "RaidUI", LoadSkin)