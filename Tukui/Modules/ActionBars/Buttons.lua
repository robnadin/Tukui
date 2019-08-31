local T, C, L = select(2, ...):unpack()

local ActionBars = T["ActionBars"]

local IsShiftKeyDown = IsShiftKeyDown
local InCombatLockdown = InCombatLockdown
local error = ERR_NOT_IN_COMBAT

local BarButtons = {}

local OnEnter = function(self)
	GameTooltip:SetOwner(self)
	GameTooltip:SetAnchorType("ANCHOR_CURSOR")

	if self.Bar:IsShown() then
		GameTooltip:AddLine(self.Num == 4 and "Click to hide action bar top row" or "Click to hide action bar "..self.Num)
		GameTooltip:AddLine(self.Num == 4 and "" or "Shift-click to set the amount of buttons")
	else
		GameTooltip:AddLine("Click to show action bar "..self.Num)
	end
	
	GameTooltip:Show()
end

local OnLeave = function(self)
	GameTooltip_Hide()
end

function ActionBars:ShowAllButtons(bar, num)
	local Button

	for i = 1, NUM_ACTIONBAR_BUTTONS do
		Button = bar["Button"..i]
		Button:Show()
	end

	if (num == 2 or num == 3) then
		bar:Width((MultiBarBottomLeftButton1:GetWidth() * 6) + (C.ActionBars.ButtonSpacing * 7))
	elseif (num == 5) then
		bar:Height((MultiBarBottomLeftButton1:GetWidth() * 12) + (C.ActionBars.ButtonSpacing * 13))
	end
end

function ActionBars:RemoveColumn(bar, num)
	local Data = TukuiData[GetRealmName()][UnitName("Player")]

	if (not bar.NextColumnToHide) then
		bar.NextColumnToHide = 6
	end

	if (bar.NextColumnToHide <= 1) then -- Reset the count at 1 button shown
		bar.NextColumnToHide = 6
		self:ShowAllButtons(bar, num)
		Data["Bar"..num.."Buttons"] = bar.NextColumnToHide

		return
	end

	local Button1 = bar["Button"..bar.NextColumnToHide]
	local Button2 = bar["Button"..bar.NextColumnToHide + 6]

	Button1:Hide()
	Button2:Hide()

	bar:Width((MultiBarBottomLeftButton1:GetWidth() * (bar.NextColumnToHide - 1)) + (C.ActionBars.ButtonSpacing * bar.NextColumnToHide))

	bar.NextColumnToHide = bar.NextColumnToHide - 1

	Data["Bar"..num.."Buttons"] = bar.NextColumnToHide
end

function ActionBars:RemoveButton(bar, num)
	local Data = TukuiData[GetRealmName()][UnitName("Player")]

	if (not bar.NextButtonToHide) then
		bar.NextButtonToHide = 12
	end

	if (bar.NextButtonToHide <= 1) then -- Reset the count at 1 button shown
		bar.NextButtonToHide = 12
		self:ShowAllButtons(bar, num)
		Data["Bar"..num.."Buttons"] = bar.NextButtonToHide

		return
	end

	local Button = bar["Button"..bar.NextButtonToHide]

	Button:Hide()

	bar:Height((MultiBarBottomLeftButton1:GetWidth() * (bar.NextButtonToHide - 1)) + (C.ActionBars.ButtonSpacing * bar.NextButtonToHide))

	bar.NextButtonToHide = bar.NextButtonToHide - 1

	Data["Bar"..num.."Buttons"] = bar.NextButtonToHide
end

function ActionBars:ShowTopButtons(bar)
	local Button
	local Value = bar.NextColumnToHide or 6
	local MainBar = T.Panels["ActionBar1"]

	for i = 7, (Value + 6) do
		Button = bar["Button"..i]

		Button:Show()
	end
	
	if MainBar.Backdrop.BorderTop then
		MainBar.Backdrop.BorderTop:SetColorTexture(0, 0, 0, 0) -- Fix a border display bug
	end
	
	bar:Height((MultiBarBottomLeftButton1:GetWidth() * 2) + (C.ActionBars.ButtonSpacing * 3))
end

function ActionBars:HideTopButtons()
	local MainBar = T.Panels["ActionBar1"]
	local Bar2 = T.Panels["ActionBar2"]
	local Bar3 = T.Panels["ActionBar3"]
	local R, G, B = unpack(C["General"].BorderColor)

	for i = 7, 12 do
		Bar2["Button"..i]:Hide()
		Bar3["Button"..i]:Hide()
	end
	
	if MainBar.Backdrop.BorderTop then
		MainBar.Backdrop.BorderTop:SetColorTexture(R, G, B, 1) -- Fix a border display bug
	end
	
	Bar2:Height((MultiBarBottomLeftButton1:GetWidth() * 1) + (C.ActionBars.ButtonSpacing * 2))
	Bar3:Height((MultiBarBottomRightButton1:GetWidth() * 1) + (C.ActionBars.ButtonSpacing * 2))
end

local OnClick = function(self, button)
	if InCombatLockdown() then
		return T.Print(error)
	end

	local ShiftClick = IsShiftKeyDown()
	local Data = TukuiData[GetRealmName()][UnitName("Player")]
	local Text = self.Text
	local Bar = self.Bar
	local Num = self.Num

	if (Bar:IsVisible()) then
		if (ShiftClick and Num ~= 4) then -- Handle shift-clicks on the button
			if (Num == 2 or Num == 3) then
				ActionBars:RemoveColumn(Bar, Num)
			else
				ActionBars:RemoveButton(Bar, Num)
			end

			return
		else
			-- Visibility
			UnregisterStateDriver(Bar, "visibility")
			Bar:Hide()

			if (Num == 4) then
				ActionBars:HideTopButtons()

				BarButtons[2]:Height((MultiBarBottomLeftButton1:GetWidth() * 1) + (C.ActionBars.ButtonSpacing * 2))
				BarButtons[3]:Height((MultiBarBottomLeftButton1:GetWidth() * 1) + (C.ActionBars.ButtonSpacing * 2))
			end

			-- Move the button
			self:ClearAllPoints()

			if (Num == 2) then
				self:Point("RIGHT", Bar, "RIGHT", 0, 0)
				Text:SetText(L.ActionBars.ArrowLeft)
			elseif (Num == 3) then
				self:Point("LEFT", Bar, "LEFT", 0, 0)
				Text:SetText(L.ActionBars.ArrowRight)
			elseif (Num == 4) then
				self:Point("TOP", T.Panels.ActionBar1, "BOTTOM", 0, -3)
				Text:SetText(L.ActionBars.ArrowUp)
			elseif (Num == 5) then
				self:Size(MultiBarBottomLeftButton1:GetWidth(), Bar:GetHeight() - 40)
				self:Point("LEFT", Bar, "RIGHT", 3, 0)
				Text:SetText(L.ActionBars.ArrowLeft)
			end

			-- Set value
			Data["HideBar"..Num] = true
		end
	else
		-- Visibility
		Bar:Show()

		if (Num == 4) then
			local Bar2 = T.Panels["ActionBar2"]
			local Bar3 = T.Panels["ActionBar3"]

			ActionBars:ShowTopButtons(Bar2)
			ActionBars:ShowTopButtons(Bar3)

			BarButtons[2]:Height((MultiBarBottomLeftButton1:GetWidth() * 2) + (C.ActionBars.ButtonSpacing * 3))
			BarButtons[3]:Height((MultiBarBottomLeftButton1:GetWidth() * 2) + (C.ActionBars.ButtonSpacing * 3))
		end

		-- Move the button
		self:ClearAllPoints()

		if (Num == 2) then
			self:Point("RIGHT", Bar, "LEFT", -3, 0)
			Text:SetText(L.ActionBars.ArrowRight)
		elseif (Num == 3) then
			self:Point("LEFT", Bar, "RIGHT", 3, 0)
			Text:SetText(L.ActionBars.ArrowLeft)
		elseif (Num == 4) then
			self:Point("TOP", T.Panels.ActionBar1, "BOTTOM", 0, -3)
			Text:SetText(L.ActionBars.ArrowDown)
		elseif (Num == 5) then
			self:Size(Bar:GetWidth(), 18)
			self:Point("TOP", Bar, "BOTTOM", 0, -3)
			Text:SetText(L.ActionBars.ArrowRight)
		end

		-- Set value
		Data["HideBar"..Num] = false
	end
end

function ActionBars:CreateToggleButtons()
	for i = 2, 5 do
		local Bar = T.Panels["ActionBar" .. i]
		local Width = Bar:GetWidth()
		local Height = Bar:GetHeight()

		local Button = CreateFrame("Button", nil, UIParent)
		Button:SetFrameStrata("BACKGROUND")
		Button:SetFrameLevel(4)
		Button:SetTemplate()
		Button:RegisterForClicks("AnyUp")
		Button.Bar = Bar
		Button.Num = i

		Button:SetScript("OnClick", OnClick)
		Button:SetScript("OnEnter", OnEnter)
		Button:SetScript("OnLeave", OnLeave)

		Button.Text = Button:CreateFontString(nil, "OVERLAY")
		Button.Text:Point("CENTER", Button, 0, 0)
		Button.Text:SetFont(C.Medias.ActionBarFont, 12)

		Button:CreateShadow()

		if (i == 2) then
			Button:Size(18, Height)
			Button:Point("RIGHT", Bar, "LEFT", -3, 0)
			Button.Text:SetText(L.ActionBars.ArrowRight)
		elseif (i == 3) then
			Button:Size(18, Height)
			Button:Point("LEFT", Bar, "RIGHT", 3, 0)
			Button.Text:SetText(L.ActionBars.ArrowLeft)
		elseif (i == 4) then
			Button:Size(Width, 12)
			Button:Point("TOP", T.Panels.ActionBar1, "BOTTOM", 0, -3)
			Button.Text:SetText(L.ActionBars.ArrowDown)
		elseif (i == 5) then
			Button:Size(Width, 18)
			Button:Point("TOP", Bar, "BOTTOM", 0, -3)
			Button.Text:SetText(L.ActionBars.ArrowRight)
		end
		
		Button:Hide()

		BarButtons[i] = Button

		T.Panels["ActionBar" .. i .. "ToggleButton"] = Button
	end
end

function ActionBars:LoadVariables()
	if (not TukuiData[GetRealmName()][UnitName("Player")]) then
		TukuiData[GetRealmName()][UnitName("Player")] = {}
	end

	local Data = TukuiData[GetRealmName()][UnitName("Player")]

	-- Hide Buttons
	for bar = 2, 3 do
		if Data["Bar"..bar.."Buttons"] then
			for button = 1, (6 - Data["Bar"..bar.."Buttons"]) do
				self:RemoveColumn(T.Panels["ActionBar"..bar], bar)
			end
		end
	end

	-- Hide more buttons
	for bar = 4, 5 do
		if Data["Bar"..bar.."Buttons"] then
			for button = 1, (6 - Data["Bar"..bar.."Buttons"]) do
				self:RemoveButton(T.Panels["ActionBar"..bar], bar)
			end
		end
	end

	-- Hide Bars
	for i = 2, 5 do
		local Button = BarButtons[i]

		if Data["HideBar"..i] then
			OnClick(Button)
		end
	end
end
