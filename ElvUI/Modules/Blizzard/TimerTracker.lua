local E, L, V, P, G = unpack(select(2, ...))
local B = E:GetModule("Blizzard")

local select, unpack, pairs = select, unpack, pairs

function B:START_TIMER()
	for _, frame in pairs(TimerTracker.timerList) do
		if frame.bar and not frame.bar.isSkinned then
			for i = 1, frame.bar:GetNumRegions() do
				local region = select(i, frame.bar:GetRegions())

				if region:IsObjectType("Texture") then
					region:SetTexture()
				elseif region:IsObjectType("FontString") then
					region:FontTemplate(nil, 12, "OUTLINE")
				end
			end

			frame.bar:StripTextures()
			frame.bar:CreateBackdrop("Transparent")
			frame.bar:SetStatusBarTexture(E.media.normTex)
			frame.bar:SetStatusBarColor(unpack(E.media.rgbvaluecolor))
			E:RegisterStatusBar(frame.bar)

			frame.bar.isSkinned = true
		end
	end
end

function B:SkinBlizzTimers()
	self:RegisterEvent("START_TIMER")
	self:START_TIMER()
end