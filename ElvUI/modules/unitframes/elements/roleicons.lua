local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

function UF:Construct_RoleIcon(frame)
 	local tex = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "ARTWORK")
	tex:Size(17);
	tex:Point("BOTTOM", frame.Health, "BOTTOM", 0, 2);
	tex.Override = UF.UpdateRoleIcon;
	return tex;
end

function UF:UpdateRoleIcon()
	local lfdrole = self.LFDRole
	local db = self.db.roleIcon;

	if not db then return; end
	local role = UnitGroupRolesAssigned(self.unit)

	if self.isForced then
		local rnd = math.random(1, 3)
		role = rnd == 1 and "TANK" or (rnd == 2 and "HEALER" or (rnd == 3 and "DAMAGER"))
	end

	if(role == 'TANK' or role == 'HEALER' or role == 'DAMAGER') and (UnitIsConnected(self.unit) or self.isForced) and db.enable then
		if role == 'TANK' then
			lfdrole:SetTexture([[Interface\AddOns\ElvUI\media\textures\tank.tga]])
		elseif role == 'HEALER' then
			lfdrole:SetTexture([[Interface\AddOns\ElvUI\media\textures\healer.tga]])
		elseif role == 'DAMAGER' then
			lfdrole:SetTexture([[Interface\AddOns\ElvUI\media\textures\dps.tga]])
		end

		lfdrole:Show()
	else
		lfdrole:Hide()
	end
end

function UF:Configure_RoleIcon(frame)
	local role = frame.LFDRole;
	local db = frame.db;

	if(db.roleIcon.enable) then
		frame:EnableElement("LFDRole");
		local attachPoint = self:GetObjectAnchorPoint(frame, db.roleIcon.attachTo);

		role:ClearAllPoints();
		role:Point(db.roleIcon.position, attachPoint, db.roleIcon.position, db.roleIcon.xOffset, db.roleIcon.yOffset);
		role:Size(db.roleIcon.size);
	else
		frame:DisableElement("LFDRole");
		role:Hide();
	end
end