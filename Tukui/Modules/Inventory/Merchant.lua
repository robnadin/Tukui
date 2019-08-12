local T, C, L = select(2, ...):unpack()

local Inventory = T["Inventory"]
local Merchant = CreateFrame("Frame")
local strmatch = string.match
local BlizzardMerchantClick = MerchantItemButton_OnModifiedClick
local Popups = T.Popups

Popups.Popup["TUKUI_SELL_JUNK"] = {
	Question = "Do you want to sell your junk items? (gray items)",
	Answer1 = YES,
	Answer2 = NO,
	Function1 = function(self)
		Merchant:SellJunk()
	end,
}

function Merchant:SellJunk()
	local Cost = 0

	for Bag = 0, 4 do
		for Slot = 1, GetContainerNumSlots(Bag) do
			local Link, ID = GetContainerItemLink(Bag, Slot), GetContainerItemID(Bag, Slot)

			if (Link and ID and type(Link) == "string") then
				local Price = 0
				local Mult1, Mult2 = select(11, GetItemInfo(Link)), select(2, GetContainerItemInfo(Bag, Slot))

				if (Mult1 and Mult2) then
					Price = Mult1 * Mult2
				end

				if (select(3, GetItemInfo(Link)) == 0 and Price > 0) then
					UseContainerItem(Bag, Slot)
					PickupMerchantItem()
					Cost = Cost + Price
				end
			end
		end
	end

	if (Cost > 0) then
		local Gold, Silver, Copper = math.floor(Cost / 10000) or 0, math.floor((Cost % 10000) / 100) or 0, Cost % 100

		DEFAULT_CHAT_FRAME:AddMessage(L.Merchant.SoldTrash.." |cffffffff"..Gold..L.DataText.GoldShort.." |cffffffff"..Silver..L.DataText.SilverShort.." |cffffffff"..Copper..L.DataText.CopperShort..".", 0255, 255, 0)
	end
end

function Merchant:OnEvent(event)
	if (event == "MERCHANT_SHOW") then
		if (IsShiftKeyDown()) then
			Merchant:SellJunk()
		else
			Popups.ShowPopup("TUKUI_SELL_JUNK")
		end
	elseif (event == "MERCHANT_CLOSED") then
		for i = 1, 4 do
			local Popup = Popups.Frames[1]

			if Popup:IsShown() and Popup.CurrentPopup == "TUKUI_SELL_JUNK" then
				Popup:Hide()
			end
		end
	end
end

function Merchant:MerchantClick(...)
	if (IsAltKeyDown()) then
		local MaxStack = select(8, GetItemInfo(GetMerchantItemLink(self:GetID())))

		if (MaxStack and MaxStack > 1) then
			BuyMerchantItem(self:GetID(), GetMerchantItemMaxStack(self:GetID()))
		end
	end

	BlizzardMerchantClick(self, ...)
end

function Merchant:Enable()
	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("MERCHANT_CLOSED")
	self:SetScript("OnEvent", self.OnEvent)

	MerchantItemButton_OnModifiedClick = self.MerchantClick
end

function Merchant:Disable()
	self:UnregisterEvent("MERCHANT_SHOW")
	self:UnregisterEvent("MERCHANT_CLOSED")
	self:SetScript("OnEvent", nil)

	MerchantItemButton_OnModifiedClick = BlizzardMerchantClick
end

Inventory.Merchant = Merchant
