local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.WorldStateFrame then return end

	local function captureBarCreate(id)
		local bar = _G["WorldStateCaptureBar"..id]
		local leftBar = _G["WorldStateCaptureBar"..id.."LeftBar"]
		local rightBar = _G["WorldStateCaptureBar"..id.."RightBar"]
		local middleBar = _G["WorldStateCaptureBar"..id.."MiddleBar"]

		select(4, bar:GetRegions()):SetTexture(nil)

		_G["WorldStateCaptureBar"..id.."LeftLine"]:SetTexture(nil)
		_G["WorldStateCaptureBar"..id.."RightLine"]:SetTexture(nil)

		_G["WorldStateCaptureBar"..id.."LeftIconHighlight"]:SetTexture(nil)
		_G["WorldStateCaptureBar"..id.."RightIconHighlight"]:SetTexture(nil)

		_G["WorldStateCaptureBar"..id.."Indicator"]:StripTextures()

		bar:CreateBackdrop()
		bar:Size(173, 16)

		leftBar:Size(85, 16)
		leftBar:Point("LEFT", 0, 0)
		leftBar:SetTexture(E.media.glossTex)
		leftBar:SetTexCoord(1, 0, 1, 0)
		leftBar:SetVertexColor(0, 0.44, 0.87)

		bar.leftBarIcon = bar:CreateTexture("$parentLeftBarIcon", "ARTWORK")
		bar.leftBarIcon:SetTexture(E.Media.Textures.Alliance)
		bar.leftBarIcon:Point("RIGHT", bar, "LEFT", 0, 0)
		bar.leftBarIcon:Size(32)

		rightBar:Size(85, 16)
		rightBar:Point("RIGHT", 0, 0)
		rightBar:SetTexture(E.media.glossTex)
		rightBar:SetTexCoord(1, 0, 1, 0)
		rightBar:SetVertexColor(0.77, 0.12, 0.23)

		bar.rightBarIcon = bar:CreateTexture("$parentRightBarIcon", "ARTWORK")
		bar.rightBarIcon:SetTexture(E.Media.Textures.Horde)
		bar.rightBarIcon:Point("LEFT", bar, "RIGHT", -4, 0)
		bar.rightBarIcon:Size(32)

		middleBar:Size(25, 16)
		middleBar:SetTexture(E.media.glossTex)
		middleBar:SetTexCoord(1, 0, 1, 0)
		middleBar:SetVertexColor(1, 1, 1)

		bar.spark = CreateFrame("Frame", "$parentSpark", bar)
		bar.spark:SetTemplate("Default", true)
		bar.spark:Size(4, 18)
	end

	hooksecurefunc(ExtendedUI["CAPTUREPOINT"], "create", captureBarCreate)

	hooksecurefunc(ExtendedUI["CAPTUREPOINT"], "update", function(id, value, neutralPercent)
		local bar = _G["WorldStateCaptureBar"..id]
		local middleBar = _G["WorldStateCaptureBar"..id.."MiddleBar"]

		local barSize = 170
		local position = 173 * (1 - value / 100)

		if neutralPercent == 0 then
			middleBar:Width(1)
		else
			middleBar:Width(neutralPercent / 100 * barSize)
		end

		bar.oldValue = position

		if bar.spark then
			bar.spark:Point("CENTER", bar, "LEFT", position, 0)
		else
			captureBarCreate(id)
		end
	end)
end

S:AddCallback("WorldStateFrame", LoadSkin)