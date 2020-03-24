local T, C, L = select(2, ...):unpack()

local DataText = T["DataTexts"]
local Popups = T["Popups"]
local Miscellaneous = T.Miscellaneous

local OnMouseDown = function()
	Miscellaneous.DropDown.Open(Miscellaneous.MicroMenu.Buttons, Miscellaneous.MicroMenu, "cursor", 0, 0, "MENU", 2)
end

local Enable = function(self)
	self:SetScript("OnMouseDown", OnMouseDown)
	self.Text:SetFormattedText("%s", DataText.NameColor .. "Micro Menu|r")
end

local Disable = function(self)
	self:SetScript("OnMouseDown", nil)
end

DataText:Register("Micro Menu", Enable, Disable, Update)
