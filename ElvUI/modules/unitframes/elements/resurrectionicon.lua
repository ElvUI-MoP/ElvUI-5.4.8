local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule('UnitFrames');

function UF:Construct_ResurectionIcon(frame)
	local tex = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "OVERLAY")
	tex:Point('CENTER', frame.Health.value, 'CENTER')
	tex:Size(30, 25)
	tex:SetDrawLayer('OVERLAY', 7)

	return tex
end