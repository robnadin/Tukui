local T, C, L = select(2, ...):unpack()

local _G = _G
local Noop = function() end
local Font, FontPath
local ReplaceBags = 0
local LastButtonBag, LastButtonBank
local Token1, Token2, Token3 = BackpackTokenFrameToken1, BackpackTokenFrameToken2, BackpackTokenFrameToken3
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES
local NUM_BAG_FRAMES = NUM_BAG_FRAMES
local ContainerFrame_GetOpenFrame = ContainerFrame_GetOpenFrame
local BankFrame = BankFrame
local BagHelpBox = BagHelpBox
local ButtonSize, ButtonSpacing, ItemsPerRow
local Bags = CreateFrame("Frame")
local Inventory = T["Inventory"]
local QuestColor = {1, 1, 0}

local BlizzardBags = {
	CharacterBag0Slot,
	CharacterBag1Slot,
	CharacterBag2Slot,
	CharacterBag3Slot,
}

local BlizzardBank = {
	BankSlotsFrame["Bag1"],
	BankSlotsFrame["Bag2"],
	BankSlotsFrame["Bag3"],
	BankSlotsFrame["Bag4"],
	BankSlotsFrame["Bag5"],
	BankSlotsFrame["Bag6"],
	BankSlotsFrame["Bag7"],
}

local BagType = {
	[8] = true,     -- Leatherworking Bag
	[16] = true,    -- Inscription Bag
	[32] = true,    -- Herb Bag
	[64] = true,    -- Enchanting Bag
	[128] = true,   -- Engineering Bag
	[512] = true,   -- Gem Bag
	[1024] = true,  -- Mining Bag
	[32768] = true, -- Fishing Bag
}

function Bags:IsProfessionBag(bag)
	local Type = select(2, GetContainerNumFreeSlots(bag))

	if BagType[Type] then
		return true
	end
end

function Bags:SkinBagButton()
	if self.IsSkinned then
		return
	end

	local Icon = _G[self:GetName().."IconTexture"]
	local Quest = _G[self:GetName().."IconQuestTexture"]
	local JunkIcon = self.JunkIcon
	local Border = self.IconBorder
	local BattlePay = self.BattlepayItemTexture

	Border:SetAlpha(0)

	Icon:SetTexCoord(unpack(T.IconCoord))
	Icon:SetInside(self)

	if Quest then
		Quest:SetAlpha(0)
	end

	if JunkIcon then
		JunkIcon:SetAlpha(0)
	end

	if BattlePay then
		BattlePay:SetAlpha(0)
	end

	self.AutoCastShine = CreateFrame('Frame', '$parentShine', self, 'AutoCastShineTemplate')

	for _, sparks in pairs(self.AutoCastShine.sparkles) do
		sparks:SetSize(sparks:GetWidth() * 2, sparks:GetHeight() * 2)
	end

	self:HookScript("OnEnter", function(self) AutoCastShine_AutoCastStop(self.AutoCastShine) end)
	self:HookScript("OnHide", function(self) AutoCastShine_AutoCastStop(self.AutoCastShine) end)

	self:SetNormalTexture("")
	self:SetPushedTexture("")
	self:SetBackdrop({ edgeFile = C.Medias.Blank, edgeSize = T.Mult })
	self:SetBackdropBorderColor(unpack(C.General.BorderColor))
	self:StyleButton()
	self.IconOverlay:SetAlpha(0)

	self.IsSkinned = true
end

function Bags:HideBlizzard()
	local BankSlotsFrame = _G["BankSlotsFrame"]

	BagHelpBox:Kill()
	BankFrame:HookScript('OnShow', function(self) self:EnableMouse(false) end)

	for i = 1, 12 do
		local CloseButton = _G["ContainerFrame"..i.."CloseButton"]
		CloseButton:Hide()

		for k = 1, 7 do
			local Container = _G["ContainerFrame"..i]
			select(k, Container:GetRegions()):SetAlpha(0)
		end
	end

	-- Hide Bank Frame Textures
	for i = 1, BankFrame:GetNumRegions() do
		local Region = select(i, BankFrame:GetRegions())

		Region:SetAlpha(0)
	end

	-- Hide BankSlotsFrame Textures and Fonts
	for i = 1, BankSlotsFrame:GetNumRegions() do
		local Region = select(i, BankSlotsFrame:GetRegions())

		Region:SetAlpha(0)
	end

	-- Hide Tabs, we will create our tabs
	for i = 1, 2 do
		--local Tab = _G["BankFrameTab"..i]
		--Tab:Hide()
	end
end

function Bags:CreateContainer(storagetype, ...)
	local Container = CreateFrame("Frame", "Tukui".. storagetype, UIParent)
	Container:SetScale(1)
	Container:SetWidth(((ButtonSize + ButtonSpacing) * ItemsPerRow) + 22 - ButtonSpacing)
	Container:SetPoint(...)
	Container:SetFrameStrata("MEDIUM")
	Container:SetFrameLevel(50)
	Container:Hide()
	Container:SetTemplate()
	Container:CreateShadow()
	Container:EnableMouse(true)

	if (storagetype == "Bag") then
		local BagsContainer = CreateFrame("Frame", nil, UIParent)
		local ToggleBagsContainer = CreateFrame("Frame")

		BagsContainer:SetParent(Container)
		BagsContainer:SetWidth(10)
		BagsContainer:SetHeight(10)
		BagsContainer:SetPoint("BOTTOMRIGHT", Container, "TOPRIGHT", 0, 1)
		BagsContainer:Hide()
		BagsContainer:SetTemplate()
		BagsContainer:CreateShadow()

		ToggleBagsContainer:SetHeight(20)
		ToggleBagsContainer:SetWidth(20)
		ToggleBagsContainer:SetPoint("TOPRIGHT", Container, "TOPRIGHT", -6, -6)
		ToggleBagsContainer:SetParent(Container)
		ToggleBagsContainer:EnableMouse(true)
		ToggleBagsContainer.Text = ToggleBagsContainer:CreateFontString("button")
		ToggleBagsContainer.Text:SetPoint("CENTER", ToggleBagsContainer, "CENTER")
		ToggleBagsContainer.Text:SetFontObject(Font)
		ToggleBagsContainer.Text:SetText("X")
		ToggleBagsContainer.Text:SetTextColor(.5, .5, .5)
		ToggleBagsContainer:SetScript("OnMouseUp", function(self, button)
			local Purchase = BankFramePurchaseInfo

			if (button == "RightButton") then
				local BanksContainer = Bags.Bank.BagsContainer
				local Purchase = BankFramePurchaseInfo

				if (ReplaceBags == 0) then
					ReplaceBags = 1
					BagsContainer:Show()
					BanksContainer:Show()
					BanksContainer:ClearAllPoints()
					ToggleBagsContainer.Text:SetTextColor(1, 1, 1)

					if Purchase:IsShown() then
						BanksContainer:SetPoint("BOTTOMLEFT", Purchase, "TOPLEFT", 50, 2)
					end
				else
					ReplaceBags = 0
					BagsContainer:Hide()
					BanksContainer:Hide()
					ToggleBagsContainer.Text:SetTextColor(.4, .4, .4)
				end
			else
				CloseAllBags()
				CloseBankBagFrames()
				CloseBankFrame()

				PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
			end
		end)

		for _, Button in pairs(BlizzardBags) do
			local Count = _G[Button:GetName().."Count"]
			local Icon = _G[Button:GetName().."IconTexture"]

			Button:SetParent(BagsContainer)
			Button:ClearAllPoints()
			Button:SetWidth(ButtonSize)
			Button:SetHeight(ButtonSize)
			Button:SetFrameStrata("HIGH")
			Button:SetFrameLevel(2)
			Button:SetNormalTexture("")
			Button:SetPushedTexture("")
			Button:SetTemplate()
			Button.IconBorder:SetAlpha(0)
			Button:SkinButton()
			Button:SetCheckedTexture("")

			if LastButtonBag then
				Button:SetPoint("LEFT", LastButtonBag, "RIGHT", ButtonSpacing, 0)
			else
				Button:SetPoint("TOPLEFT", BagsContainer, "TOPLEFT", ButtonSpacing, -ButtonSpacing)
			end

			Count.Show = Noop
			Count:Hide()

			Icon:SetTexCoord(unpack(T.IconCoord))
			Icon:SetInside()

			LastButtonBag = Button
			BagsContainer:SetWidth((ButtonSize * getn(BlizzardBags)) + (ButtonSpacing * (getn(BlizzardBags) + 1)))
			BagsContainer:SetHeight(ButtonSize + (ButtonSpacing * 2))
		end

		Container.BagsContainer = BagsContainer
		Container.CloseButton = ToggleBagsContainer
		Container.SortButton = Sort
	else
		local PurchaseButton = BankFramePurchaseButton
		local CostText = BankFrameSlotCost
		local TotalCost = BankFrameDetailMoneyFrame
		local Purchase = BankFramePurchaseInfo
		local BankBagsContainer = CreateFrame("Frame", nil, Container)

		CostText:ClearAllPoints()
		CostText:SetPoint("BOTTOMLEFT", 60, 10)
		TotalCost:ClearAllPoints()
		TotalCost:SetPoint("LEFT", CostText, "RIGHT", 0, 0)
		PurchaseButton:ClearAllPoints()
		PurchaseButton:SetPoint("BOTTOMRIGHT", -10, 10)
		PurchaseButton:SkinButton()

		Purchase:ClearAllPoints()
		Purchase:SetWidth(Container:GetWidth() + 50)
		Purchase:SetHeight(70)
		Purchase:SetPoint("BOTTOMLEFT", Container, "TOPLEFT", -50, 2)
		Purchase:CreateBackdrop()
		Purchase.Backdrop:SetPoint("TOPLEFT", 50, 0)
		Purchase.Backdrop:SetPoint("BOTTOMRIGHT", 0, 0)
		Purchase.Backdrop:CreateShadow()

		BankBagsContainer:Size(Container:GetWidth(), BankSlotsFrame.Bag1:GetHeight() + ButtonSpacing + ButtonSpacing)
		BankBagsContainer:SetTemplate()
		BankBagsContainer:CreateShadow()
		BankBagsContainer:SetPoint("BOTTOMLEFT", Container, "TOPLEFT", 0, 2)
		BankBagsContainer:SetFrameLevel(Container:GetFrameLevel())
		BankBagsContainer:SetFrameStrata(Container:GetFrameStrata())

		for i = 1, 6 do
			local Bag = BankSlotsFrame["Bag"..i]
			
			Bag.HighlightFrame:SetAlpha(0)

			Bag:SetParent(BankBagsContainer)
			Bag:SetWidth(ButtonSize)
			Bag:SetHeight(ButtonSize)

			Bag.IconBorder:SetAlpha(0)
			Bag.icon:SetTexCoord(unpack(T.IconCoord))
			Bag.icon:SetInside()
			
			Bag:SkinButton()
			Bag:ClearAllPoints()

			if i == 1 then
				Bag:SetPoint("TOPLEFT", BankBagsContainer, "TOPLEFT", ButtonSpacing, -ButtonSpacing)
			else
				Bag:SetPoint("LEFT", BankSlotsFrame["Bag"..i-1], "RIGHT", ButtonSpacing, 0)
			end
		end

		BankBagsContainer:SetWidth((ButtonSize * 7) + (ButtonSpacing * (7 + 1)))
		BankBagsContainer:SetHeight(ButtonSize + (ButtonSpacing * 2))
		BankBagsContainer:Hide()

		BankFrame:EnableMouse(false)

		Container.BagsContainer = BankBagsContainer
		Container.SortButton = SortButton
	end

	self[storagetype] = Container
end

function Bags:SetBagsSearchPosition()

end

function Bags:SlotUpdate(id, button)
	if not button then
		return
	end

	local _, _, _, Rarity, _, _, _, _, _, ItemID = GetContainerItemInfo(id, button:GetID())
	local IsNewItem = C_NewItems.IsNewItem(id, button:GetID())

	if (button.ItemID == ItemID) then
		return
	end

	button.ItemID = ItemID

	local NewItem = button.NewItemTexture
	local IsProfBag = self:IsProfessionBag(id)
	local IconQuestTexture = button.IconQuestTexture

	if IconQuestTexture then
		IconQuestTexture:SetAlpha(0)
	end

	-- Letting you style this
	if IsProfBag then

	else
		--button:SetBackdropColor(unpack(C["General"].BackdropColor))
	end

	if Rarity and Rarity > 1 then
		button:SetBackdropBorderColor(GetItemQualityColor(Rarity))
	else
		button:SetBackdropBorderColor(unpack(C["General"].BorderColor))
	end
end

function Bags:BagUpdate(id)
	local Size = GetContainerNumSlots(id)

	for Slot = 1, Size do
		local Button = _G["ContainerFrame"..(id + 1).."Item"..Slot]

		if Button then
			if not Button:IsShown() then
				Button:Show()
			end

			self:SlotUpdate(id, Button)
		end
	end
end

function Bags:UpdateAllBags()
	local NumRows, LastRowButton, NumButtons, LastButton = 0, ContainerFrame1Item1, 1, ContainerFrame1Item1
	local FirstButton

	for Bag = 5, 1, -1 do
		local ID = Bag - 1
		local Slots = GetContainerNumSlots(ID)

		for Item = Slots, 1, -1 do
			local Button = _G["ContainerFrame"..Bag.."Item"..Item]
			local Money = ContainerFrame1MoneyFrame

			if not FirstButton then
				FirstButton = Button
			end

			Button:ClearAllPoints()
			Button:SetWidth(ButtonSize)
			Button:SetHeight(ButtonSize)
			Button:SetScale(1)
			Button:SetFrameStrata("HIGH")
			Button:SetFrameLevel(2)

			Button.newitemglowAnim:Stop()
			Button.newitemglowAnim.Play = Noop

			Button.flashAnim:Stop()
			Button.flashAnim.Play = Noop

			Money:ClearAllPoints()
			Money:Show()
			Money:SetPoint("TOPLEFT", Bags.Bag, "TOPLEFT", 8, -10)
			Money:SetFrameStrata("HIGH")
			Money:SetFrameLevel(2)
			Money:SetScale(1)

			if (Button == FirstButton) then
				Button:SetPoint("TOPLEFT", Bags.Bag, "TOPLEFT", 10, -40)
				LastRowButton = Button
				LastButton = Button
			elseif (NumButtons == ItemsPerRow) then
				Button:SetPoint("TOPRIGHT", LastRowButton, "TOPRIGHT", 0, -(ButtonSpacing + ButtonSize))
				Button:SetPoint("BOTTOMLEFT", LastRowButton, "BOTTOMLEFT", 0, -(ButtonSpacing + ButtonSize))
				LastRowButton = Button
				NumRows = NumRows + 1
				NumButtons = 1
			else
				Button:SetPoint("TOPRIGHT", LastButton, "TOPRIGHT", (ButtonSpacing + ButtonSize), 0)
				Button:SetPoint("BOTTOMLEFT", LastButton, "BOTTOMLEFT", (ButtonSpacing + ButtonSize), 0)
				NumButtons = NumButtons + 1
			end

			Bags.SkinBagButton(Button)

			LastButton = Button
		end

		Bags:BagUpdate(ID)
	end

	Bags.Bag:SetHeight(((ButtonSize + ButtonSpacing) * (NumRows + 1) + 54 + (ButtonSpacing * 4)) - ButtonSpacing)
end

function Bags:UpdateAllBankBags()
	local NumRows, LastRowButton, NumButtons, LastButton = 0, ContainerFrame1Item1, 1, ContainerFrame1Item1

	for Bank = 1, 24 do
		local Button = _G["BankFrameItem"..Bank]
		local Money = ContainerFrame2MoneyFrame
		local BankFrameMoneyFrame = BankFrameMoneyFrame

		Button:ClearAllPoints()
		Button:SetWidth(ButtonSize)
		Button:SetHeight(ButtonSize)
		Button:SetFrameStrata("HIGH")
		Button:SetFrameLevel(2)
		Button:SetScale(1)
		Button.IconBorder:SetAlpha(0)

		BankFrameMoneyFrame:Hide()

		if (Bank == 1) then
			Button:SetPoint("TOPLEFT", Bags.Bank, "TOPLEFT", 10, -10)
			LastRowButton = Button
			LastButton = Button
		elseif (NumButtons == ItemsPerRow) then
			Button:SetPoint("TOPRIGHT", LastRowButton, "TOPRIGHT", 0, -(ButtonSpacing + ButtonSize))
			Button:SetPoint("BOTTOMLEFT", LastRowButton, "BOTTOMLEFT", 0, -(ButtonSpacing + ButtonSize))
			LastRowButton = Button
			NumRows = NumRows + 1
			NumButtons = 1
		else
			Button:SetPoint("TOPRIGHT", LastButton, "TOPRIGHT", (ButtonSpacing + ButtonSize), 0)
			Button:SetPoint("BOTTOMLEFT", LastButton, "BOTTOMLEFT", (ButtonSpacing + ButtonSize), 0)
			NumButtons = NumButtons + 1
		end

		Bags.SkinBagButton(Button)
		Bags.SlotUpdate(self, -1, Button)

		LastButton = Button
	end

	for Bag = 6, 12 do
		local Slots = GetContainerNumSlots(Bag - 1)

		for Item = Slots, 1, -1 do
			local Button = _G["ContainerFrame"..Bag.."Item"..Item]

			Button:ClearAllPoints()
			Button:SetWidth(ButtonSize)
			Button:SetHeight(ButtonSize)
			Button:SetFrameStrata("HIGH")
			Button:SetFrameLevel(2)
			Button:SetScale(1)
			Button.IconBorder:SetAlpha(0)

			if (NumButtons == ItemsPerRow) then
				Button:SetPoint("TOPRIGHT", LastRowButton, "TOPRIGHT", 0, -(ButtonSpacing + ButtonSize))
				Button:SetPoint("BOTTOMLEFT", LastRowButton, "BOTTOMLEFT", 0, -(ButtonSpacing + ButtonSize))
				LastRowButton = Button
				NumRows = NumRows + 1
				NumButtons = 1
			else
				Button:SetPoint("TOPRIGHT", LastButton, "TOPRIGHT", (ButtonSpacing+ButtonSize), 0)
				Button:SetPoint("BOTTOMLEFT", LastButton, "BOTTOMLEFT", (ButtonSpacing+ButtonSize), 0)
				NumButtons = NumButtons + 1
			end

			Bags.SkinBagButton(Button)
			Bags.SlotUpdate(self, Bag - 1, Button)

			LastButton = Button
		end
	end

	Bags.Bank:SetHeight(((ButtonSize + ButtonSpacing) * (NumRows + 1) + 20) - ButtonSpacing)
end

function Bags:OpenBag(id)
	if (not CanOpenPanels()) then
		if (UnitIsDead("player")) then
			NotWhileDeadError()
		end

		return
	end

	local Size = GetContainerNumSlots(id)
	local OpenFrame = ContainerFrame_GetOpenFrame()

	for i = 1, Size, 1 do
		local Index = Size - i + 1
		local Button = _G[OpenFrame:GetName().."Item"..i]

		Button:SetID(Index)
		Button:Show()
	end

	OpenFrame.size = Size
	OpenFrame:SetID(id)
	OpenFrame:Show()

	if (id == 4) then
		Bags:UpdateAllBags()
	end
end

function Bags:CloseBag(id)
	CloseBag(id)
end

function Bags:OpenAllBags()
	self:OpenBag(0, 1)

	for i = 1, 4 do
		self:OpenBag(i, 1)
	end

	if IsBagOpen(0) then
		self.Bag:Show()

		if not self.Bag.MoverAdded then
			local Movers = T["Movers"]

			Movers:RegisterFrame(self.Bag)

			self.Bag.MoverAdded = true
		end
	end
end

function Bags:OpenAllBankBags()
	local Bank = BankFrame
	local CustomPosition = TukuiData[T.MyRealm][T.MyName].Move.TukuiBank

	if Bank:IsShown() then
		self.Bank:Show()

		if not self.Bank.MoverAdded then
			local Movers = T["Movers"]

			Movers:RegisterFrame(self.Bank)

			self.Bank.MoverAdded = true
		end

		if CustomPosition and not self.Bank.MoverApplied then
			self.Bank:ClearAllPoints()
			self.Bank:SetPoint(unpack(CustomPosition))

			self.Bank.MoverApplied = true
		end

		for i = 5, 10 do
			if (not IsBagOpen(i)) then

				self:OpenBag(i, 1)
			end
		end
	end
end

function Bags:CloseAllBags()
	if MerchantFrame:IsVisible() or InboxFrame:IsVisible() then
		return
	end

	CloseAllBags()

	PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
end

function Bags:CloseAllBankBags()
	local Bank = BankFrame

	if (Bank:IsVisible()) then
		CloseBankBagFrames()
		CloseBankFrame()
	end
end

function Bags:ToggleBags()
	if (self.Bag:IsShown() and BankFrame:IsShown()) and (not self.Bank:IsShown()) then
		self:OpenAllBankBags()

		return
	end

	if (self.Bag:IsShown() or self.Bank:IsShown()) then
		if MerchantFrame:IsVisible() or InboxFrame:IsVisible() then
			return
		end

		self:CloseAllBags()
		self:CloseAllBankBags()

		return
	end

	if not self.Bag:IsShown() then
		self:OpenAllBags()
	end

	if not self.Bank:IsShown() and BankFrame:IsShown() then
		self:OpenAllBankBags()
	end
end

function Bags:OnEvent(event, ...)
	if (event == "BAG_UPDATE") then
		self:BagUpdate(...)
	elseif (event == "CURRENCY_DISPLAY_UPDATE") then
		BackpackTokenFrame_Update()
	elseif (event == "BAG_CLOSED") then
		-- This is usually where the client find a bag swap in character or bank slots.

		local Bag = ... + 1

		-- We need to hide buttons from a bag when closing it because they are not parented to the original frame
		local Container = _G["ContainerFrame"..Bag]
		local Size = Container.size
		
		if Size then
			for i = 1, Size do
				local Button = _G["ContainerFrame"..Bag.."Item"..i]

				if Button then
					Button:Hide()
				end
			end
		end

		-- We close to refresh the all in one layout.
		self:CloseAllBags()
		self:CloseAllBankBags()
	elseif (event == "PLAYERBANKSLOTS_CHANGED") then
		local ID = ...

		if ID <= 28 then
			local Button = _G["BankFrameItem"..ID]

			if (Button) then
				self:SlotUpdate(-1, Button)
			end
		end
	elseif (event == "BANKFRAME_CLOSED") then
		local Bank = self.Bank

		Bank:Hide()
	elseif (event == "BANKFRAME_OPENED") then
		local Bank = self.Bank

		Bank:Show()
		self:UpdateAllBankBags()
	end
end

function Bags:Enable()
	if (not C.Bags.Enable) then
		return
	end

	--SetSortBagsRightToLeft(false)
	SetInsertItemsLeftToRight(true)

	Font = T.GetFont(C["Bags"].Font)
	FontPath = _G[Font]:GetFont()
	ButtonSize = C.Bags.ButtonSize
	ButtonSpacing = C.Bags.Spacing
	ItemsPerRow = C.Bags.ItemsPerRow

	local Bag = ContainerFrame1
	local GameMenu = GameMenuFrame
	local BankItem1 = BankFrameItem1
	local BankFrame = BankFrame
	local DataTextLeft = T["Panels"].DataTextLeft
	local DataTextRight = T["Panels"].DataTextRight

	self:CreateContainer("Bag", "BOTTOMRIGHT", DataTextRight, "TOPRIGHT", 0, 6)
	self:CreateContainer("Bank", "BOTTOMLEFT", DataTextLeft, "TOPLEFT", 0, 6)
	self:HideBlizzard()

	Bag:SetScript("OnHide", function()
		self.Bag:Hide()
	end)

	Bag:HookScript("OnShow", function() -- Cinematic Bug with Bags open.
		self.Bag:Show()
	end)

	BankItem1:SetScript("OnHide", function()
		self.Bank:Hide()
	end)

	-- Rewrite Blizzard Bags Functions
	function UpdateContainerFrameAnchors() end
	function ToggleBag() ToggleAllBags() end
	function ToggleBackpack() ToggleAllBags() end
	function OpenAllBags() ToggleAllBags() end
	function OpenBackpack() ToggleAllBags() end
	function ToggleAllBags() self:ToggleBags() end

	-- Destroy bubbles help boxes
	for i = 1, 13 do
		local HelpBox = _G["ContainerFrame"..i.."ExtraBagSlotsHelpBox"]

		if HelpBox then
			HelpBox:Kill()
		end
	end

	-- Register Events for Updates
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
	self:RegisterEvent("BAG_CLOSED")
	self:RegisterEvent("BANKFRAME_CLOSED")
	self:RegisterEvent("BANKFRAME_OPENED")
	self:SetScript("OnEvent", self.OnEvent)

	if ContainerFrame5 then
		ContainerFrame5:EnableMouse(false)
	end

	ToggleAllBags()
	ToggleAllBags()
end

Inventory.Bags = Bags
