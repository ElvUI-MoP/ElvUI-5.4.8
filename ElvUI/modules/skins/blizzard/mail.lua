local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local _G = _G;
local pairs, unpack, select = pairs, unpack, select;

local ATTACHMENTS_MAX_SEND = ATTACHMENTS_MAX_SEND

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.mail ~= true then return end

	MailFrame:StripTextures(true)
	MailFrame:SetTemplate("Transparent")
	MailFrame:Width(345)

	MailFrameInset:Kill()
	MailFrameBg:Kill()

	InboxFrame:StripTextures()

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local bg = _G["MailItem"..i]
		bg:StripTextures()
		bg:CreateBackdrop("Default")
		bg.backdrop:Point("TOPLEFT", 2, 1)
		bg.backdrop:Point("BOTTOMRIGHT", -2, 2)

		local b = _G["MailItem"..i.."Button"]
		b:StripTextures()
		b:SetTemplate("Default", true)
		b:StyleButton()

		local t = _G["MailItem"..i.."ButtonIcon"]
		t:SetTexCoord(unpack(E.TexCoords))
		t:SetInside()
	end

	S:HandleCloseButton(MailFrameCloseButton)
	MailFrameCloseButton:Point("TOPRIGHT", 2, 2)

	S:HandleNextPrevButton(InboxPrevPageButton)
	S:HandleNextPrevButton(InboxNextPageButton)

	for i = 1, 2 do
		_G["MailFrameTab"..i]:StripTextures()
		S:HandleTab(_G["MailFrameTab"..i])
	end

	-- send mail
	SendMailFrame:StripTextures()

	SendMailMoneyBg:Kill()
	SendMailMoneyInset:StripTextures()

	SendMailScrollFrame:StripTextures(true)
	SendMailScrollFrame:SetTemplate("Default")

	S:HandleScrollBar(SendMailScrollFrameScrollBar)

	S:HandleEditBox(SendMailNameEditBox)
	SendMailNameEditBox.backdrop:Point("BOTTOMRIGHT", 2, 0)
	SendMailNameEditBox:Height(20)

	S:HandleEditBox(SendMailSubjectEditBox)
	SendMailSubjectEditBox.backdrop:Point("BOTTOMRIGHT", 2, 0)
	SendMailSubjectEditBox:Point("TOPLEFT", SendMailNameEditBox, "BOTTOMLEFT", 0, -5)

	S:HandleEditBox(SendMailMoneyGold)
	S:HandleEditBox(SendMailMoneySilver)
	S:HandleEditBox(SendMailMoneyCopper)

	for i = 1, 5 do
		_G["AutoCompleteButton"..i]:StyleButton()
	end

	local function MailFrameSkin()
		for i = 1, ATTACHMENTS_MAX_SEND do
			local b = _G["SendMailAttachment"..i];
			if(not b.skinned) then
				b:StripTextures();
				b:SetTemplate("Default", true);
				b:StyleButton(nil, true);
				b.skinned = true;
			end
			local t = b:GetNormalTexture();
			local itemName = GetSendMailItem(i);
			if(itemName) then
				local quality = select(3, GetItemInfo(itemName));
				if(quality and quality > 1) then
					b:SetBackdropBorderColor(GetItemQualityColor(quality));
				else
					b:SetBackdropBorderColor(unpack(E["media"].bordercolor));
				end
				t:SetTexCoord(unpack(E.TexCoords));
				t:SetInside();
			else
				b:SetBackdropBorderColor(unpack(E["media"].bordercolor));
			end
		end
	end
	hooksecurefunc("SendMailFrame_Update", MailFrameSkin)

	local function OpenMail_Update()
		if(not InboxFrame.openMailID) then return; end
		local _, _, isTakeable = GetInboxText(InboxFrame.openMailID);
		local _, itemRowCount = OpenMail_GetItemCounts(isTakeable, textCreated, money);
		if(itemRowCount > 0 and OpenMailFrame.activeAttachmentButtons) then
			for i, attachmentButton in pairs(OpenMailFrame.activeAttachmentButtons) do
				if(attachmentButton ~= OpenMailLetterButton and attachmentButton ~= OpenMailMoneyButton) then
					local name, _, _, quality = GetInboxItem(InboxFrame.openMailID, attachmentButton:GetID());
					if (name) then
						if (quality and quality > 1) then
							attachmentButton:SetBackdropBorderColor(GetItemQualityColor(quality));
						else
							attachmentButton:SetBackdropBorderColor(unpack(E["media"].bordercolor));
						end
					end
				end
			end
		end
	end
	hooksecurefunc("OpenMail_Update", OpenMail_Update);

	S:HandleButton(SendMailMailButton)
	S:HandleButton(SendMailCancelButton)

	-- open mail (cod)
	OpenMailFrame:StripTextures(true)
	OpenMailFrame:SetTemplate("Transparent")

	OpenMailFrameInset:Kill()

	S:HandleCloseButton(OpenMailFrameCloseButton)
	OpenMailFrameCloseButton:Point("TOPRIGHT", 2, 2)

	S:HandleButton(OpenMailReportSpamButton)

	S:HandleButton(OpenMailReplyButton)
	OpenMailReplyButton:Point("RIGHT", OpenMailDeleteButton, "LEFT", -2, 0)

	S:HandleButton(OpenMailDeleteButton)
	OpenMailDeleteButton:Point("RIGHT", OpenMailCancelButton, "LEFT", -2, 0)

	S:HandleButton(OpenMailCancelButton)

	OpenMailScrollFrame:StripTextures(true)
	OpenMailScrollFrame:SetTemplate("Default")

	S:HandleScrollBar(OpenMailScrollFrameScrollBar)

	SendMailBodyEditBox:SetTextColor(1, 1, 1)
	OpenMailBodyText:SetTextColor(1, 1, 1)
	InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	OpenMailInvoiceBuyMode:SetTextColor(1, 0.80, 0.10);

	OpenMailArithmeticLine:Kill()

	OpenMailLetterButton:StripTextures()
	OpenMailLetterButton:SetTemplate("Default", true)
	OpenMailLetterButton:StyleButton()

	OpenMailLetterButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	OpenMailLetterButtonIconTexture:SetDrawLayer("ARTWORK")
	OpenMailLetterButtonIconTexture:SetInside()

	OpenMailLetterButtonCount:SetDrawLayer("OVERLAY")

	OpenMailMoneyButton:StripTextures()
	OpenMailMoneyButton:SetTemplate("Default", true)
	OpenMailMoneyButton:StyleButton()

	OpenMailMoneyButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	OpenMailMoneyButtonIconTexture:SetDrawLayer("ARTWORK")
	OpenMailMoneyButtonIconTexture:SetInside()

	OpenMailMoneyButtonCount:SetDrawLayer("OVERLAY")

	for i = 1, ATTACHMENTS_MAX_SEND do
		local b = _G["OpenMailAttachmentButton"..i]
		b:StripTextures()
		b:SetTemplate("Default", true)
		b:StyleButton()

		local it = _G["OpenMailAttachmentButton"..i.."IconTexture"]
		local c = _G["OpenMailAttachmentButton"..i.."Count"]
		if it then
			it:SetTexCoord(unpack(E.TexCoords))
			it:SetDrawLayer("ARTWORK")
			it:SetInside()
			c:SetDrawLayer("OVERLAY")
		end
	end
end

S:AddCallback("Mail", LoadSkin);