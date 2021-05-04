local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local hooksecurefunc = hooksecurefunc
local GetInboxHeaderInfo = GetInboxHeaderInfo
local GetInboxItemLink = GetInboxItemLink
local GetItemInfo = GetItemInfo
local GetSendMailItem = GetSendMailItem
local GetItemQualityColor = GetItemQualityColor

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.mail then return end

	-- Inbox Frame
	MailFrame:StripTextures(true)
	MailFrame:SetTemplate("Transparent")
	MailFrame:SetHitRectInsets(0, 0, 0, 0)
	MailFrame:EnableMouseWheel(true)
	MailFrame:SetScript("OnMouseWheel", function(_, value)
		if value > 0 then
			if InboxPrevPageButton:IsEnabled() == 1 then
				InboxPrevPage()
			end
		else
			if InboxNextPageButton:IsEnabled() == 1 then
				InboxNextPage()
			end
		end
	end)

	MailFrameInset:Kill()
	MailFrameBg:Kill()

	InboxFrame:StripTextures()

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local mail = _G["MailItem"..i]
		local button = _G["MailItem"..i.."Button"]
		local icon = _G["MailItem"..i.."ButtonIcon"]
		local expire = _G["MailItem"..i.."ExpireTime"]

		mail:StripTextures()
		mail:CreateBackdrop("Transparent")
		mail.backdrop:SetParent(button)
		mail.backdrop:ClearAllPoints()
		mail.backdrop:Point("TOPLEFT", mail, 42, -2)
		mail.backdrop:Point("BOTTOMRIGHT", mail, 4, 7)
		mail.backdrop:SetFrameLevel(mail:GetFrameLevel() - 1)

		button:StripTextures()
		button:CreateBackdrop()
		button:Point("TOPLEFT", 2, -3)
		button:Size(34)
		button:StyleButton()
		button.hover:SetAllPoints(icon)
		button.checked:SetAllPoints(icon)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside(button.backdrop)

		if expire then
			expire:Point("TOPRIGHT", mail, "TOPRIGHT", 4, -3)
		end
	end

	hooksecurefunc("InboxFrame_Update", function()
		local numItems = GetInboxNumItems()
		local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY) + 1

		for i = 1, INBOXITEMS_TO_DISPLAY do
			local button = _G["MailItem"..i.."Button"]

			if index <= numItems then
				local packageIcon, _, _, _, _, _, _, _, _, _, _, _, isGM = GetInboxHeaderInfo(index)

				if packageIcon and not isGM then
					local link = GetInboxItemLink(index, 1)

					if link then
						local quality = select(3, GetItemInfo(link))

						if quality then
							button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
						else
							button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
						end
					end
				elseif isGM then
					button.backdrop:SetBackdropBorderColor(0, 0.56, 0.94)
				else
					button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end

			index = index + 1
		end
	end)

	InboxTitleText:ClearAllPoints()
	InboxTitleText:Point("TOP", MailFrame, 0, -5)

	SendMailTitleText:ClearAllPoints()
	SendMailTitleText:Point("TOP", MailFrame, 0, -5)

	InboxTooMuchMail:ClearAllPoints()
	InboxTooMuchMail:Point("TOP", MailFrame, -10, -24)

	S:HandleNextPrevButton(InboxPrevPageButton, nil, nil, true)
	InboxPrevPageButton:Size(32)
	InboxPrevPageButton:Point("CENTER", InboxFrame, "BOTTOMLEFT", 25, 112)

	S:HandleNextPrevButton(InboxNextPageButton, nil, nil, true)
	InboxNextPageButton:Size(32)
	InboxNextPageButton:Point("CENTER", InboxFrame, "BOTTOMLEFT", 312, 112)

	S:HandleCloseButton(MailFrameCloseButton, MailFrame.backdrop)

	for i = 1, 2 do
		S:HandleTab(_G["MailFrameTab"..i])
	end

	-- Send Mail Frame
	SendMailFrame:StripTextures()

	SendMailMoneyBg:Kill()
	SendMailMoneyInset:StripTextures()

	SendMailScrollFrame:StripTextures(true)
	SendMailScrollFrame:CreateBackdrop()
	SendMailScrollFrame.backdrop:Point("TOPLEFT", 0, 0)
	SendMailScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -2)

	S:HandleScrollBar(SendMailScrollFrameScrollBar)
	SendMailScrollFrameScrollBar:ClearAllPoints()
	SendMailScrollFrameScrollBar:Point("TOPRIGHT", SendMailScrollFrame, 24, -18)
	SendMailScrollFrameScrollBar:Point("BOTTOMRIGHT", SendMailScrollFrame, 0, 16)

	hooksecurefunc("SendMailFrame_Update", function()
		for i = 1, ATTACHMENTS_MAX_SEND do
			local button = _G["SendMailAttachment"..i]
			local icon = button:GetNormalTexture()
			local link = GetSendMailItem(i)

			if not button.isSkinned then
				button:StripTextures()
				button:SetTemplate("Default", true)
				button:StyleButton(nil, true)

				button.isSkinned = true
			end

			if link then
				local quality = select(3, GetItemInfo(link))

				if quality then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end

				icon:SetTexCoord(unpack(E.TexCoords))
				icon:SetInside()
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	SendMailBodyEditBox:SetTextColor(1, 1, 1)

	S:HandleEditBox(SendMailNameEditBox)
	SendMailNameEditBox:Height(18)

	S:HandleEditBox(SendMailSubjectEditBox)
	SendMailSubjectEditBox:Point("TOPLEFT", SendMailNameEditBox, "BOTTOMLEFT", 0, -10)
	SendMailSubjectEditBox:Size(211, 18)

	S:HandleEditBox(SendMailMoneyGold)
	S:HandleEditBox(SendMailMoneySilver)
	S:HandleEditBox(SendMailMoneyCopper)

	S:HandleButton(SendMailMailButton)
	SendMailMailButton:Point("RIGHT", SendMailCancelButton, "LEFT", -2, 0)

	S:HandleButton(SendMailCancelButton)
	SendMailCancelButton:Point("BOTTOMRIGHT", -51, 92)

	S:HandleRadioButton(SendMailSendMoneyButton)
	S:HandleRadioButton(SendMailCODButton)

	SendMailMoneyFrame:Point("BOTTOMLEFT", 170, 95)

	for i = 1, 5 do
		_G["AutoCompleteButton"..i]:StyleButton()
	end

	-- Open Mail Frame
	OpenMailFrame:StripTextures(true)
	OpenMailFrame:SetTemplate("Transparent")

	OpenMailFrameInset:Kill()

	for i = 1, ATTACHMENTS_MAX_SEND do
		local button = _G["OpenMailAttachmentButton"..i]
		local icon = _G["OpenMailAttachmentButton"..i.."IconTexture"]

		button:StripTextures()
		button:SetTemplate("Default", true)
		button:StyleButton()

		if icon then
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer("ARTWORK")
			icon:SetInside()

			_G["OpenMailAttachmentButton"..i.."Count"]:SetDrawLayer("OVERLAY")
		end
	end

	hooksecurefunc("OpenMailFrame_UpdateButtonPositions", function()
		for i = 1, ATTACHMENTS_MAX_RECEIVE do
			local link = GetInboxItemLink(InboxFrame.openMailID, i)
			local button = _G["OpenMailAttachmentButton"..i]

			if link then
				local quality = select(3, GetItemInfo(link))

				if quality then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	S:HandleCloseButton(OpenMailFrameCloseButton)
	OpenMailFrameCloseButton:Point("CENTER", OpenMailFrame, "TOPRIGHT", -40, -13)

	S:HandleButton(OpenMailReportSpamButton)

	S:HandleButton(OpenMailReplyButton)
	OpenMailReplyButton:Point("RIGHT", OpenMailDeleteButton, "LEFT", -2, 0)

	S:HandleButton(OpenMailDeleteButton)
	OpenMailDeleteButton:Point("RIGHT", OpenMailCancelButton, "LEFT", -2, 0)

	S:HandleButton(OpenMailCancelButton)

	OpenMailScrollFrame:StripTextures(true)
	OpenMailScrollFrame:CreateBackdrop()

	S:HandleScrollBar(OpenMailScrollFrameScrollBar)
	OpenMailScrollFrameScrollBar:ClearAllPoints()
	OpenMailScrollFrameScrollBar:Point("TOPRIGHT", OpenMailScrollFrame, 25, -17)
	OpenMailScrollFrameScrollBar:Point("BOTTOMRIGHT", OpenMailScrollFrame, 0, 17)

	OpenMailBodyText:SetTextColor(1, 1, 1)
	InvoiceTextFontNormal:SetFont(E.media.normFont, 13)
	InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	OpenMailInvoiceBuyMode:SetTextColor(1, 0.80, 0.10)

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
end

S:AddCallback("Mail", LoadSkin)