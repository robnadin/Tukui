local T, C, L = select(2, ...):unpack()

-- /run Tukui[1].GUI:Toggle() -- Try me!

local sort = table.sort
local tinsert = table.insert
local tremove = table.remove
local match = string.match
local floor = floor
local unpack = unpack
local pairs = pairs
local type = type

--[[
	Note: I'm going to be laying out a bunch of basics here, don't worry too much yet about how things look.
	I'll refine as the process goes on.
	
	To do:
	Create widgets
	Global/PerChar settings
	highlights?
	scrolling
	dropdown scrolling
	
	Widget list:
	checkbox(?)
	-switch
	-slider
	--dropdown (for textures, fonts, and misc)
	
	color
]]

-- IMO :SetFontTemplate should let you set the flag too
local StyleFont = function(fs, font, size)
	fs:SetFont(font, size)
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(1, -1)
end

local Font = C.Medias.Font
local Texture = C.Medias.Normal
local Blank = C.Medias.Blank

local ArrowUp = "Interface\\AddOns\\Tukui\\Medias\\Textures\\Others\\ArrowUp"
local ArrowDown = "Interface\\AddOns\\Tukui\\Medias\\Textures\\Others\\ArrowDown"

local MediumColor = {0.15, 0.15, 0.15} -- The default 0.1, 0.1, 0.1 is so dark to my eyes. But all of this styling is ultimately in your hands.
local LightColor = {0.175, 0.175, 0.175}
local BrightColor = {0.35, 0.35, 0.35}

-- You can switch this, I just don't know what kind of colors you want to be using, so I picked something.
local Color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
local R, G, B = Color.r, Color.g, Color.b

local WindowWidth = 460
local WindowHeight = 360

local Spacing = 4
local LabelSpacing = 6

local HeaderWidth = WindowWidth - (Spacing * 2)
local HeaderHeight = 22

local ButtonListWidth = 120
local ButtonListHeight = (WindowHeight - HeaderHeight - (Spacing * 3) + 2)

local MenuButtonWidth = ButtonListWidth - (Spacing * 2)
local MenuButtonHeight = 20

local WidgetListWidth = (WindowWidth - ButtonListWidth) - (Spacing * 3) + 1
local WidgetListHeight = ButtonListHeight

local WidgetHeight = 20 -- All widgets are the same height

local GUI = CreateFrame("Frame", nil, UIParent) -- Feel free to give a global name, It's available as T.GUI right now
GUI.Windows = {}
GUI.Buttons = {}
GUI.Queue = {}
GUI.Widgets = {}

local SetValue = function(group, option, value)
	if (type(C[group][option]) == "table") then
		C[group][option].Value = value
	else
		C[group][option] = value
	end
	
	local Settings
	
	--if TukuiConfigPerAccount then -- NYI
		Settings = TukuiSettings
	--else
	--	Settings = TukuiSettingsPerChar
	--end
	
	if (not Settings[group]) then
		Settings[group] = {}
	end
	
	Settings[group][option] = value
end

local TrimHex = function(s)
	local Subbed = match(s, "|cFF%x%x%x%x%x%x(.-)|r")
	
	return Subbed or s
end

local GetOrderedIndex = function(t)
    local OrderedIndex = {}
	
    for key in pairs(t) do
        tinsert(OrderedIndex, key)
    end
	
	sort(OrderedIndex, function(a, b)
		return TrimHex(a) < TrimHex(b)
	end)
	
    return OrderedIndex
end

local OrderedNext = function(t, state)
	local OrderedIndex = GetOrderedIndex(t)
	local Key
	
    if (state == nil) then
        Key = OrderedIndex[1]
		
        return Key, t[Key]
    end
	
    for i = 1, #OrderedIndex do
        if (OrderedIndex[i] == state) then
            Key = OrderedIndex[i + 1]
        end
    end
	
    if Key then
        return Key, t[Key]
    end
	
    return
end

local PairsByKeys = function(t)
    return OrderedNext, t, nil
end

-- Switches
local SwitchWidth = 46

local SwitchOnMouseUp = function(self)
	self.Thumb:ClearAllPoints()
	
	if self.Value then
		self.Thumb:Point("RIGHT", self, 0, 0)
		self.Movement:SetOffset(-27, 0)
		self.Value = false
	else
		self.Thumb:Point("LEFT", self, 0, 0)
		self.Movement:SetOffset(27, 0)
		self.Value = true
	end
	
	self.Movement:Play()
	
	SetValue(self.Group, self.Option, self.Value)
end

local CreateSwitch = function(self, group, option, text)
	local Value = C[group][option]
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:Size(WidgetListWidth - (Spacing * 2), WidgetHeight)
	
	local Switch = CreateFrame("Frame", nil, Anchor)
	Switch:Point("LEFT", Anchor, 0, 0)
	Switch:Size(SwitchWidth, WidgetHeight)
	Switch:SetTemplate(nil, Texture)
	Switch:SetBackdropColor(unpack(MediumColor))
	Switch:SetScript("OnMouseUp", SwitchOnMouseUp)
	Switch.Value = Value
	Switch.Group = group
	Switch.Option = option
	
	Switch.Thumb = CreateFrame("Frame", nil, Switch)
	Switch.Thumb:Size(WidgetHeight, WidgetHeight)
	Switch.Thumb:SetTemplate(nil, Texture)
	Switch.Thumb:SetBackdropColor(unpack(BrightColor))
	
	Switch.Movement = CreateAnimationGroup(Switch.Thumb):CreateAnimation("Move")
	Switch.Movement:SetDuration(0.1)
	Switch.Movement:SetEasing("in-sinusoidal")
	
	Switch.TrackTexture = Switch:CreateTexture(nil, "ARTWORK")
	Switch.TrackTexture:Point("TOPLEFT", Switch, 0, -1)
	Switch.TrackTexture:Point("BOTTOMRIGHT", Switch.Thumb, "BOTTOMLEFT", 0, 1)
	Switch.TrackTexture:SetTexture(Texture)
	Switch.TrackTexture:SetVertexColor(R, G, B)
	
	Switch.Label = Switch:CreateFontString(nil, "OVERLAY")
	Switch.Label:Point("LEFT", Switch, "RIGHT", Spacing, 0)
	StyleFont(Switch.Label, Font, 12)
	Switch.Label:SetText(text)
	
	if Value then
		Switch.Thumb:Point("RIGHT", Switch, 0, 0)
	else
		Switch.Thumb:Point("LEFT", Switch, 0, 0)
	end
	
	tinsert(self.Widgets, Anchor)
	
	return Switch
end

GUI.Widgets.CreateSwitch = CreateSwitch

-- Sliders
local SliderWidth = 94
local EditboxWidth = 46

local Round = function(num, dec)
	local Mult = 10 ^ (dec or 0)
	
	return floor(num * Mult + 0.5) / Mult
end

local SliderOnValueChanged = function(self)
	local Value = self:GetValue()
	local Step = self.EditBox.StepValue
	
	if (Step >= 1) then
		Value = floor(Value)
	else
		if (Step <= 0.01) then
			Value = Round(Value, 2)
		else
			Value = Round(Value, 1)
		end
	end
	
	self.EditBox.Value = Value
	self.EditBox:SetText(Value)
	
	SetValue(self.EditBox.Group, self.EditBox.Option, Value)
end

local SliderOnMouseWheel = function(self, delta)
	local Value = self.EditBox.Value
	local Step = self.EditBox.StepValue
	
	if (delta < 0) then
		Value = Value - Step
	else
		Value = Value + Step
	end
	
	if (Step >= 1) then
		Value = floor(Value)
	else
		if (Step <= 0.01) then
			Value = Round(Value, 2)
		else
			Value = Round(Value, 1)
		end
	end
	
	if (Value < self.EditBox.MinValue) then
		Value = self.EditBox.MinValue
	elseif (Value > self.EditBox.MaxValue) then
		Value = self.EditBox.MaxValue
	end
	
	self.EditBox.Value = Value
	
	self:SetValue(Value)
	self.EditBox:SetText(Value)
end

local EditBoxOnEnterPressed = function(self)
	self.Value = tonumber(self:GetText())
	
	if (self.Value ~= self.Value) then
		self.Slider:SetValue(self.Value)
		SliderOnValueChanged(self.Slider)
	else
		self.Slider:SetValue(self.Value)
		SliderOnValueChanged(self.Slider)
	end
	
	self:SetAutoFocus(false)
	self:ClearFocus()
end

local EditBoxOnMouseDown = function(self)
	self:SetAutoFocus(true)
	self:SetText(self.Value)
end

local EditBoxOnEditFocusLost = function(self)
	if (self.Value > self.MaxValue) then
		self.Value = self.MaxValue
	elseif (self.Value < self.MinValue) then
		self.Value = self.MinValue
	end
	
	self:SetText(self.Value)
end

local EditBoxOnMouseWheel = function(self, delta)
	if self:HasFocus() then
		self:SetAutoFocus(false)
		self:ClearFocus()
	end
	
	if (delta > 0) then
		self.Value = self.Value + self.StepValue
		
		if (self.Value > self.MaxValue) then
			self.Value = self.MaxValue
		end
	else
		self.Value = self.Value - self.StepValue
		
		if (self.Value < self.MinValue) then
			self.Value = self.MinValue
		end
	end
	
	self:SetText(self.Value)
	self.Slider:SetValue(self.Value)
end

local CreateSlider = function(self, group, option, minvalue, maxvalue, stepvalue, text)
	local Value = C[group][option]
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:Size(WidgetListWidth - (Spacing * 2), WidgetHeight)
	
	local EditBox = CreateFrame("Frame", nil, Anchor)
	EditBox:Point("LEFT", Anchor, 0, 0)
	EditBox:Size(EditboxWidth, WidgetHeight)
	EditBox:SetTemplate(nil, Texture)
	EditBox:SetBackdropColor(unpack(MediumColor))
	
	EditBox.Box = CreateFrame("EditBox", nil, EditBox)
	StyleFont(EditBox.Box, Font, 12)
	EditBox.Box:Point("TOPLEFT", EditBox, Spacing, -2)
	EditBox.Box:Point("BOTTOMRIGHT", EditBox, -Spacing, 2)
	EditBox.Box:SetJustifyH("CENTER")
	EditBox.Box:SetMaxLetters(4)
	EditBox.Box:SetAutoFocus(false)
	EditBox.Box:EnableKeyboard(true)
	EditBox.Box:EnableMouse(true)
	EditBox.Box:EnableMouseWheel(true)
	EditBox.Box:SetText(Value)
	EditBox.Box:SetScript("OnMouseWheel", EditBoxOnMouseWheel)
	EditBox.Box:SetScript("OnMouseDown", EditBoxOnMouseDown)
	EditBox.Box:SetScript("OnEscapePressed", EditBoxOnEnterPressed)
	EditBox.Box:SetScript("OnEnterPressed", EditBoxOnEnterPressed)
	EditBox.Box:SetScript("OnEditFocusLost", EditBoxOnEditFocusLost)
	EditBox.Box.Group = group
	EditBox.Box.Option = option
	EditBox.Box.MinValue = minvalue
	EditBox.Box.MaxValue = maxvalue
	EditBox.Box.StepValue = stepvalue
	EditBox.Box.Value = Value
	EditBox.Box.Parent = EditBox
	
	local Slider = CreateFrame("Slider", nil, EditBox)
	Slider:Point("LEFT", EditBox, "RIGHT", Spacing, 0)
	Slider:Size(SliderWidth, WidgetHeight)
	Slider:SetThumbTexture(Texture)
	Slider:SetOrientation("HORIZONTAL")
	Slider:SetValueStep(stepvalue)
	Slider:SetTemplate(nil, Texture)
	Slider:SetBackdropColor(unpack(MediumColor))
	Slider:SetMinMaxValues(minvalue, maxvalue)
	Slider:SetValue(Value)
	Slider:EnableMouseWheel(true)
	Slider:SetScript("OnMouseWheel", SliderOnMouseWheel)
	Slider:SetScript("OnValueChanged", SliderOnValueChanged)
	Slider.EditBox = EditBox.Box
	
	Slider.Label = Slider:CreateFontString(nil, "OVERLAY")
	Slider.Label:Point("LEFT", Slider, "RIGHT", LabelSpacing, 0)
	StyleFont(Slider.Label, Font, 12)
	Slider.Label:SetText(text)
	
	local Thumb = Slider:GetThumbTexture() 
	Thumb:Size(8, WidgetHeight)
	Thumb:SetTexture(Blank)
	Thumb:SetVertexColor(0, 0, 0)
	
	Slider.NewTexture = Slider:CreateTexture(nil, "OVERLAY")
	Slider.NewTexture:Point("TOPLEFT", Slider:GetThumbTexture(), 0, -1)
	Slider.NewTexture:Point("BOTTOMRIGHT", Slider:GetThumbTexture(), 0, 1)
	Slider.NewTexture:SetTexture(Blank)
	Slider.NewTexture:SetVertexColor(0, 0, 0)
	
	Slider.NewTexture2 = Slider:CreateTexture(nil, "OVERLAY")
	Slider.NewTexture2:Point("TOPLEFT", Slider.NewTexture, 1, 0)
	Slider.NewTexture2:Point("BOTTOMRIGHT", Slider.NewTexture, -1, 0)
	Slider.NewTexture2:SetTexture(Blank)
	Slider.NewTexture2:SetVertexColor(unpack(BrightColor))
	
	Slider.Progress = Slider:CreateTexture(nil, "ARTWORK")
	Slider.Progress:Point("TOPLEFT", Slider, 1, -1)
	Slider.Progress:Point("BOTTOMRIGHT", Slider.NewTexture, "BOTTOMLEFT", 0, 0)
	Slider.Progress:SetTexture(Texture)
	Slider.Progress:SetVertexColor(R, G, B)
	
	EditBox.Box.Slider = Slider
	
	Slider:Show()
	
	tinsert(self.Widgets, Anchor)
	
	return EditBox
end

GUI.Widgets.CreateSlider = CreateSlider

-- Dropdown Menu
local DropdownWidth = 144
local SelectedHighlightAlpha = 0.2
local LastActiveDropdown

local SetArrowUp = function(self)
	self.Arrow:SetTexture(ArrowUp)
end

local SetArrowDown = function(self)
	self.Arrow:SetTexture(ArrowDown)
end

local CloseLastDropdown = function(compare)
	if (LastActiveDropdown and LastActiveDropdown.Menu:IsShown() and (LastActiveDropdown ~= compare)) then
		if (not LastActiveDropdown.Menu.FadeOut:IsPlaying()) then
			LastActiveDropdown.Menu.FadeOut:Play()
			SetArrowDown(LastActiveDropdown)
		end
	end
end

local DropdownButtonOnMouseUp = function(self)
	self.Parent.Texture:SetVertexColor(unpack(BrightColor))
	
	if self.Menu:IsVisible() then
		self.Menu.FadeOut:Play()
		SetArrowDown(self)
	else
		for i = 1, #self.Menu do
			if self.Parent.CustomType then
				if (self.Menu[i].Key == self.Parent.Value) then
					self.Menu[i].Selected:Show()
				else
					self.Menu[i].Selected:Hide()
				end
			else
				if (self.Menu[i].Value == self.Parent.Value) then
					self.Menu[i].Selected:Show()
				else
					self.Menu[i].Selected:Hide()
				end
			end
		end
		
		CloseLastDropdown(self)
		self.Menu:Show()
		self.Menu.FadeIn:Play()
		SetArrowUp(self)
	end
	
	LastActiveDropdown = self
end

local DropdownButtonOnMouseDown = function(self)
	local R, G, B = unpack(BrightColor)
	
	self.Parent.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

local MenuItemOnMouseUp = function(self)
	self.Parent.FadeOut:Play()
	SetArrowDown(self.GrandParent.Button)
	
	self.Highlight:SetAlpha(0)
	
	if self.GrandParent.Type then
		SetValue(self.Group, self.Option, self.Key)
		
		self.GrandParent.Value = self.Key
	else
		SetValue(self.Group, self.Option, self.Value)
		
		self.GrandParent.Value = self.Value
	end
	
	if (self.GrandParent.Type == "Texture") then
		self.GrandParent.Texture:SetTexture(T.GetTexture(self.Key))
	elseif (self.GrandParent.Type == "Font") then
		self.GrandParent.Current:SetFontObject(T.GetFont(self.Key))
	end
	
	self.GrandParent.Current:SetText(self.Key)
end

local MenuItemOnEnter = function(self)
	self.Highlight:SetAlpha(SelectedHighlightAlpha)
end

local MenuItemOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local CreateDropdown = function(self, group, option, label, custom)
	local Value
	local Selections
	
	if custom then
		Value = C[group][option]
		
		if (custom == "Texture") then
			Selections = T.TextureTable
		else
			Selections = T.FontTable
		end
	else
		Value = C[group][option].Value
		Selections = C[group][option].Options
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:Size(WidgetListWidth - (Spacing * 2), WidgetHeight)
	
	local Dropdown = CreateFrame("Frame", nil, Anchor)
	Dropdown:Point("LEFT", Anchor, 0, 0)
	Dropdown:Size(DropdownWidth, WidgetHeight)
	Dropdown:SetTemplate()
	Dropdown:SetFrameLevel(self:GetFrameLevel() + 1)
	Dropdown.Values = Selections
	Dropdown.Value = Value
	Dropdown.Type = custom
	
	Dropdown.Texture = Dropdown:CreateTexture(nil, "ARTWORK")
	Dropdown.Texture:Point("TOPLEFT", Dropdown, 1, -1)
	Dropdown.Texture:Point("BOTTOMRIGHT", Dropdown, -1, 1)
	Dropdown.Texture:SetVertexColor(unpack(BrightColor))
	
	Dropdown.Button = CreateFrame("Frame", nil, Dropdown)
	Dropdown.Button:Size(DropdownWidth, WidgetHeight)
	Dropdown.Button:Point("LEFT", Dropdown, 0, 0)
	Dropdown.Button:SetScript("OnMouseUp", DropdownButtonOnMouseUp)
	Dropdown.Button:SetScript("OnMouseDown", DropdownButtonOnMouseDown)
	
	Dropdown.Current = Dropdown:CreateFontString(nil, "ARTWORK")
	Dropdown.Current:Point("LEFT", Dropdown, Spacing, 0)
	Dropdown.Current:SetFontObject(T.GetFont("Tukui"))
	Dropdown.Current:SetJustifyH("LEFT")
	Dropdown.Current:Width(DropdownWidth - 4)
	Dropdown.Current:SetText(Value)
	
	Dropdown.Label = Dropdown:CreateFontString(nil, "OVERLAY")
	Dropdown.Label:Point("LEFT", Dropdown, "RIGHT", LabelSpacing, 0)
	StyleFont(Dropdown.Label, Font, 12)
	Dropdown.Label:SetJustifyH("LEFT")
	Dropdown.Label:Width(DropdownWidth - 4)
	Dropdown.Label:SetText(label)
	
	Dropdown.ArrowAnchor = CreateFrame("Frame", nil, Dropdown)
	Dropdown.ArrowAnchor:Size(WidgetHeight, WidgetHeight)
	Dropdown.ArrowAnchor:Point("RIGHT", Dropdown, 0, 0)
	
	Dropdown.Button.Arrow = Dropdown.ArrowAnchor:CreateTexture(nil, "OVERLAY")
	Dropdown.Button.Arrow:Size(10, 10)
	Dropdown.Button.Arrow:Point("CENTER", Dropdown.ArrowAnchor, 0, 0)
	Dropdown.Button.Arrow:SetTexture(ArrowDown)
	Dropdown.Button.Arrow:SetVertexColor(R, G, B)
	
	Dropdown.Menu = CreateFrame("Frame", nil, Dropdown)
	Dropdown.Menu:Point("TOP", Dropdown, "BOTTOM", 0, -2)
	Dropdown.Menu:Size(DropdownWidth - 6, 1)
	Dropdown.Menu:SetTemplate()
	Dropdown.Menu:SetBackdropBorderColor(0, 0, 0)
	Dropdown.Menu:SetFrameLevel(Dropdown.Menu:GetFrameLevel() + 1)
	Dropdown.Menu:Hide()
	Dropdown.Menu:SetAlpha(0)
	
	Dropdown.Button.Menu = Dropdown.Menu
	Dropdown.Button.Parent = Dropdown
	
	Dropdown.Menu.Fade = CreateAnimationGroup(Dropdown.Menu)
	
	Dropdown.Menu.FadeIn = Dropdown.Menu.Fade:CreateAnimation("Fade")
	Dropdown.Menu.FadeIn:SetEasing("in-sinusoidal")
	Dropdown.Menu.FadeIn:SetDuration(0.15)
	Dropdown.Menu.FadeIn:SetChange(1)
	
	Dropdown.Menu.FadeOut = Dropdown.Menu.Fade:CreateAnimation("Fade")
	Dropdown.Menu.FadeOut:SetEasing("out-sinusoidal")
	Dropdown.Menu.FadeOut:SetDuration(0.15)
	Dropdown.Menu.FadeOut:SetChange(0)
	Dropdown.Menu.FadeOut:SetScript("OnFinished", function(self)
		self:GetParent():Hide()
	end)
	
	Dropdown.Menu.BG = CreateFrame("Frame", nil, Dropdown.Menu)
	Dropdown.Menu.BG:Point("TOPLEFT", Dropdown.Menu, -3, 3)
	Dropdown.Menu.BG:Point("BOTTOMRIGHT", Dropdown.Menu, 3, -3)
	Dropdown.Menu.BG:SetTemplate()
	Dropdown.Menu.BG:SetBackdropColor(unpack(LightColor))
	Dropdown.Menu.BG:SetFrameLevel(Dropdown.Menu:GetFrameLevel() - 1)
	Dropdown.Menu.BG:EnableMouse(true)
	
	local Count = 0
	local LastMenuItem
	
	for k, v in PairsByKeys(Selections) do
		Count = Count + 1
		
		local MenuItem = CreateFrame("Frame", nil, Dropdown.Menu)
		MenuItem:Size(DropdownWidth - 6, WidgetHeight)
		MenuItem:SetTemplate()
		MenuItem:SetScript("OnMouseUp", MenuItemOnMouseUp)
		MenuItem:SetScript("OnEnter", MenuItemOnEnter)
		MenuItem:SetScript("OnLeave", MenuItemOnLeave)
		MenuItem.Key = k
		MenuItem.Value = v
		MenuItem.Group = group
		MenuItem.Option = option
		MenuItem.Parent = MenuItem:GetParent()
		MenuItem.GrandParent = MenuItem:GetParent():GetParent()
		
		MenuItem.Highlight = MenuItem:CreateTexture(nil, "OVERLAY")
		MenuItem.Highlight:Point("TOPLEFT", MenuItem, 1, -1)
		MenuItem.Highlight:Point("BOTTOMRIGHT", MenuItem, -1, 1)
		MenuItem.Highlight:SetTexture(Blank)
		MenuItem.Highlight:SetVertexColor(1, 1, 1, SelectedHighlightAlpha)
		MenuItem.Highlight:SetAlpha(0)
		
		MenuItem.Texture = MenuItem:CreateTexture(nil, "ARTWORK")
		MenuItem.Texture:Point("TOPLEFT", MenuItem, 1, -1)
		MenuItem.Texture:Point("BOTTOMRIGHT", MenuItem, -1, 1)
		MenuItem.Texture:SetTexture(Texture)
		MenuItem.Texture:SetVertexColor(unpack(BrightColor))
		
		MenuItem.Selected = MenuItem:CreateTexture(nil, "OVERLAY")
		MenuItem.Selected:Point("TOPLEFT", MenuItem, 1, -1)
		MenuItem.Selected:Point("BOTTOMRIGHT", MenuItem, -1, 1)
		MenuItem.Selected:SetTexture(Blank)
		MenuItem.Selected:SetVertexColor(R, G, B)
		MenuItem.Selected:SetAlpha(SelectedHighlightAlpha)
		
		MenuItem.Text = MenuItem:CreateFontString(nil, "OVERLAY")
		MenuItem.Text:Point("LEFT", MenuItem, 5, 0)
		MenuItem.Text:SetFontObject(T.GetFont("Tukui"))
		MenuItem.Text:SetJustifyH("LEFT")
		MenuItem.Text:SetText(k)
		
		if (custom == "Texture") then
			MenuItem.Texture:SetTexture(T.GetTexture(k))
		elseif (custom == "Font") then
			MenuItem.Text:SetFontObject(T.GetFont(k))
		end
		
		if custom then
			if (MenuItem.Key == MenuItem.GrandParent.Value) then
				MenuItem.Selected:Show()
				MenuItem.GrandParent.Current:SetText(k)
			else
				MenuItem.Selected:Hide()
			end
		else
			if (MenuItem.Value == MenuItem.GrandParent.Value) then
				MenuItem.Selected:Show()
				MenuItem.GrandParent.Current:SetText(k)
			else
				MenuItem.Selected:Hide()
			end
		end
		
		tinsert(Dropdown.Menu, MenuItem)
		
		if LastMenuItem then
			MenuItem:Point("TOP", LastMenuItem, "BOTTOM", 0, 1)
		else
			MenuItem:Point("TOP", Dropdown.Menu, 0, 0)
		end
		
		LastMenuItem = MenuItem
	end
	
	if (custom == "Texture") then
		Dropdown.Texture:SetTexture(T.GetTexture(Value))
	elseif (custom == "Font") then
		Dropdown.Texture:SetTexture(Texture)
		Dropdown.Current:SetFontObject(T.GetFont(Value))
	else
		Dropdown.Texture:SetTexture(Texture)
	end
	
	Dropdown.Menu:Height(((WidgetHeight - 1) * Count) + 1)
	
	tinsert(self.Widgets, Anchor)
	
	return Dropdown
end

GUI.Widgets.CreateDropdown = CreateDropdown

-- GUI functions
GUI.SetScroll = function(self, offset)
	
end

GUI.AddWidgets = function(self, func)
	if (type(func) ~= "function") then
		return
	end
	
	tinsert(self.Queue, func)
end

GUI.UnpackQueue = function(self)
	local Function
	
	for i = 1, #self.Queue do
		Function = tremove(self.Queue, 1)
		
		Function(self)
	end
end

GUI.SortMenuButtons = function(self)
	sort(self.Buttons, function(a, b)
		return a.Name < b.Name
	end)
	
	for i = 1, #self.Buttons do
		self.Buttons[i]:ClearAllPoints()
		
		if (i == 1) then
			self.Buttons[i]:Point("TOPLEFT", self.ButtonList, Spacing, -Spacing)
		else
			self.Buttons[i]:Point("TOP", self.Buttons[i-1], "BOTTOM", 0, -(Spacing - 1))
		end
	end
end

local SortWidgets = function(self)
	for i = 1, #self.Widgets do
		if (i == 1) then
			self.Widgets[i]:Point("TOPLEFT", self, Spacing, -Spacing)
		else
			self.Widgets[i]:Point("TOPLEFT", self.Widgets[i-1], "BOTTOMLEFT", 0, -(Spacing - 1))
		end
	end
	
	self.Sorted = true
end

GUI.DisplayWindow = function(self, name)
	for WindowName, Window in pairs(self.Windows) do
		if (WindowName ~= name) then
			Window:Hide()
		else
			if (not Window.Sorted) then
				SortWidgets(Window)
			end
			
			Window:Show()
		end
	end
end

local MenuButtonOnMouseUp = function(self)
	self.Parent:DisplayWindow(self.Name)
end

local MenuButtonOnEnter = function(self)
	self.Highlight:Show()
end

local MenuButtonOnLeave = function(self)
	self.Highlight:Hide()
end

GUI.CreateWindow = function(self, name, default)
	if self.Windows[name] then
		return
	end
	
	self.WindowCount = self.WindowCount or 1 -- We start at 1 because of the apply button
	
	local Button = CreateFrame("Frame", nil, self.ButtonList)
	Button:Size(MenuButtonWidth, MenuButtonHeight)
	Button:SetTemplate()
	Button:SetBackdropColor(unpack(MediumColor))
	Button:SetScript("OnMouseUp", MenuButtonOnMouseUp)
	Button:SetScript("OnEnter", MenuButtonOnEnter)
	Button:SetScript("OnLeave", MenuButtonOnLeave)
	Button.Name = name
	Button.Parent = self
	
	Button.Label = Button:CreateFontString(nil, "OVERLAY")
	Button.Label:Point("CENTER", Button, 0, 0)
	StyleFont(Button.Label, Font, 14)
	Button.Label:SetText(name)
	
	Button.Highlight = Button:CreateTexture(nil, "OVERLAY")
	Button.Highlight:SetAllPoints()
	Button.Highlight:SetTexture(Texture)
	Button.Highlight:SetVertexColor(0.3, 0.3, 0.3, 0.3)
	Button.Highlight:Hide()
	
	tinsert(self.Buttons, Button)
	
	local Window = CreateFrame("Frame", nil, self)
	Window:Width(WidgetListWidth)
	Window:Point("BOTTOMRIGHT", self, -Spacing, Spacing)
	Window:Point("TOPRIGHT", self.Header, "BOTTOMRIGHT", 0, -(Spacing - 1))
	Window:SetTemplate()
	Window:SetBackdropColor(unpack(LightColor))
	Window:Hide()
	Window.Widgets = {}
	
	self.Windows[name] = Window
	
	for key, func in pairs(self.Widgets) do
		Window[key] = func
	end
	
	if default then
		self.DefaultWindow = name
	end
	
	self.WindowCount = self.WindowCount + 1
	
	return Window
end

GUI.GetWindow = function(self, name)
	if self.Windows[name] then
		return self.Windows[name]
	else
		return self.Windows[self.DefaultWindow]
	end
end

local CloseOnEnter = function(self)
	self.Label:SetTextColor(1, 0.2, 0.2)
end

local CloseOnLeave = function(self)
	self.Label:SetTextColor(1, 1, 1)
end

local CloseOnMouseUp = function()
	GUI.FadeOut:Play()
end

GUI.Create = function(self)
	if self.Created then
		return
	end
	
	-- Main Window
	self:Size(WindowWidth, WindowHeight)
	self:Point("CENTER", UIParent, 0, 0)
	self:SetTemplate()
	self:SetBackdropColor(unpack(MediumColor))
	self:SetAlpha(0)
	self:EnableMouse(true)
	self:SetMovable(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", self.StartMoving)
	self:SetScript("OnDragStop", self.StopMovingOrSizing)
	self:Hide()
	
	-- Animation
	self.Fade = CreateAnimationGroup(self)
	
	self.FadeIn = self.Fade:CreateAnimation("Fade")
	self.FadeIn:SetDuration(0.2)
	self.FadeIn:SetChange(1)
	self.FadeIn:SetEasing("in-sinusoidal")
	
	self.FadeOut = self.Fade:CreateAnimation("Fade")
	self.FadeOut:SetDuration(0.2)
	self.FadeOut:SetChange(0)
	self.FadeOut:SetEasing("out-sinusoidal")
	self.FadeOut:SetScript("OnFinished", function(self)
		self:GetParent():Hide()
	end)
	
	-- Header
	self.Header = CreateFrame("Frame", nil, self)
	self.Header:Size(HeaderWidth, HeaderHeight)
	self.Header:Point("TOP", self, 0, -Spacing)
	self.Header:SetTemplate(nil, Texture)
	self.Header:SetBackdropColor(unpack(LightColor))
	
	self.Header.Label = self.Header:CreateFontString(nil, "OVERLAY")
	self.Header.Label:Point("CENTER", self.Header, 0, 0)
	StyleFont(self.Header.Label, Font, 16)
	self.Header.Label:SetText("|cffff8000Tukui|r settings")
	
	-- Button list
	self.ButtonList = CreateFrame("Frame", nil, self)
	self.ButtonList:Width(ButtonListWidth)
	self.ButtonList:Point("BOTTOMLEFT", self, Spacing, Spacing)
	self.ButtonList:Point("TOPLEFT", self.Header, "BOTTOMLEFT", 0, -(Spacing - 1))
	self.ButtonList:Point("BOTTOMLEFT", self, Spacing, Spacing)
	self.ButtonList:SetTemplate()
	self.ButtonList:SetBackdropColor(unpack(LightColor))
	
	-- Close
	self.Close = CreateFrame("Frame", nil, self.Header)
	self.Close:Size(HeaderHeight, HeaderHeight)
	self.Close:Point("RIGHT", self.Header, 0, 0)
	self.Close:SetScript("OnEnter", CloseOnEnter)
	self.Close:SetScript("OnLeave", CloseOnLeave)
	self.Close:SetScript("OnMouseUp", CloseOnMouseUp)
	
	self.Close.Label = self.Close:CreateFontString(nil, "OVERLAY")
	self.Close.Label:Point("CENTER", self.Close, 0, 0)
	StyleFont(self.Close.Label, Font, 16)
	self.Close.Label:SetText("×")
	
	-- Apply
	local Button = CreateFrame("Frame", nil, self.ButtonList)
	Button:Size(MenuButtonWidth, MenuButtonHeight)
	Button:SetTemplate()
	Button:SetBackdropColor(unpack(MediumColor))
	Button:SetScript("OnMouseUp", ReloadUI)
	Button:SetScript("OnEnter", MenuButtonOnEnter)
	Button:SetScript("OnLeave", MenuButtonOnLeave)
	Button.Name = "ZZZ"
	
	Button.Label = Button:CreateFontString(nil, "OVERLAY")
	Button.Label:Point("CENTER", Button, 0, 0)
	StyleFont(Button.Label, Font, 14)
	Button.Label:SetText("Apply")
	
	Button.Highlight = Button:CreateTexture(nil, "OVERLAY")
	Button.Highlight:SetAllPoints()
	Button.Highlight:SetTexture(Texture)
	Button.Highlight:SetVertexColor(0.3, 0.3, 0.3, 0.3)
	Button.Highlight:Hide()
	
	self:UnpackQueue()
	
	-- Set the frame height
	self:Height((self.WindowCount * MenuButtonHeight) + ((self.WindowCount + 5) * Spacing) - 3)
	
	if self.DefaultWindow then
		self:DisplayWindow(self.DefaultWindow)
	end
	
	tinsert(self.Buttons, Button)
	
	self:SortMenuButtons()
	
	self.Created = true
end

GUI.Toggle = function(self)
	if InCombatLockdown() then
		return
	end
	
	if self:IsShown() then
		self.FadeOut:Play()
	else
		self:Show()
		self.FadeIn:Play()
	end
end

GUI.PLAYER_REGEN_DISABLED = function(self, event)
	if self:IsShown() then
		self:SetAlpha(0)
		self:Hide()
		self.CombatClosed = true
	end
end

GUI.PLAYER_REGEN_ENABLED = function(self, event)
	if self.CombatClosed then -- This is up to you, if you want it to re-open if it was combat closed
		self:Show()
		self:SetAlpha(1)
		self.CombatClosed = false
	end
end

GUI:RegisterEvent("PLAYER_REGEN_DISABLED")
GUI:RegisterEvent("PLAYER_REGEN_ENABLED")
GUI:SetScript("OnEvent", function(self, event)
	self[event](self, event)
end)

T.GUI = GUI -- Do we need a global name? This is all the access anyone would really need

-- Below here is just to test
local Testing = true

if (not Testing) then
	return
end

local General = function(self)
	local Window = self:CreateWindow("General", true)
	
	Window:CreateSwitch("General", "HideShadows", "Hide frame shadows")
	Window:CreateSwitch("General", "AFKSaver", "Enable AFK screensaver")
	Window:CreateSlider("General", "UIScale", 0.64, 1.15, 0.01, "Set ui scale")
	Window:CreateDropdown("General", "Themes", "Set ui theme")
end

local ActionBars = function(self)
	local Window = self:CreateWindow("Actionbars")
	
	Window:CreateSwitch("ActionBars", "Enable", "Enable actionbar module")
	Window:CreateSwitch("ActionBars", "HotKey", "Enable hotkeys text")
	Window:CreateSwitch("ActionBars", "EquipBorder", "EquipBorder")
	Window:CreateSwitch("ActionBars", "Macro", "Enable macro text")
	Window:CreateSwitch("ActionBars", "ShapeShift", "ShapeShift")
	Window:CreateSwitch("ActionBars", "Pet", "Enable pet bar")
	Window:CreateSwitch("ActionBars", "SwitchBarOnStance", "Switch bar on stance changes")
	Window:CreateSwitch("ActionBars", "HideBackdrop", "Hide the actionbar backdrop")
	Window:CreateSlider("ActionBars", "NormalButtonSize", 20, 36, 1, "Set button size")
	Window:CreateSlider("ActionBars", "PetButtonSize", 20, 36, 1, "Set pet button size")
	Window:CreateSlider("ActionBars", "ButtonSpacing", 0, 8, 1, "Set button spacing")
	Window:CreateDropdown("ActionBars", "Font", "Set actionbar font", "Font")
end

local Auras = function(self)
	local Window = self:CreateWindow("Auras")
	
	Window:CreateSwitch("Auras", "Enable", "Enable auras module")
	Window:CreateSwitch("Auras", "Flash", "Flash auras at low duration")
	Window:CreateSwitch("Auras", "ClassicTimer", "ClassicTimer")
	Window:CreateSwitch("Auras", "HideBuffs", "HideBuffs")
	Window:CreateSwitch("Auras", "HideDebuffs", "HideDebuffs")
	Window:CreateSwitch("Auras", "Animation", "Animation")
	Window:CreateSlider("Auras", "BuffsPerRow", 6, 20, 1, "BuffsPerRow")
	Window:CreateDropdown("Auras", "Font", "Set aura font", "Font")
end

local Bags = function(self)
	local Window = self:CreateWindow("Bags")
	
	Window:CreateSwitch("Bags", "Enable", "Enable bag module")
	Window:CreateSlider("Bags", "ButtonSize", 20, 36, 1, "Set bag slot size")
	Window:CreateSlider("Bags", "Spacing", 0, 8, 1, "Set bag slot spacing")
	Window:CreateSlider("Bags", "ItemsPerRow", 8, 16, 1, "Set items per row")
	Window:CreateDropdown("Bags", "Font", "Set bag font", "Font")
end

-- ["LinkColor"] = {0.08, 1, 0.36}
local Chat = function(self)
	local Window = self:CreateWindow("Chat")
	
	Window:CreateSwitch("Chat", "Enable", "Enable chat module")
	Window:CreateSwitch("Chat", "WhisperSound", "Enable whisper sound")
	Window:CreateSwitch("Chat", "ShortChannelName", "Shorten channel names")
	Window:CreateSwitch("Chat", "LinkBrackets", "Display URL links in brackets")
	Window:CreateSlider("Chat", "ScrollByX", 1, 6, 1, "Set lines to scroll")
	Window:CreateDropdown("Chat", "ChatFont", "Set chat font", "Font")
	Window:CreateDropdown("Chat", "TabFont", "Set chat tab font", "Font")
end

local Cooldowns = function(self)
	local Window = self:CreateWindow("Cooldowns")
	
	Window:CreateDropdown("Cooldowns", "Font", "Set cooldown font", "Font")
end

--["NameColor"] = {1, 1, 1}
--["ValueColor"] = {1, 1, 1}
local DataTexts = function(self)
	local Window = self:CreateWindow("DataTexts")
	
	Window:CreateSwitch("DataTexts", "Battleground", "Enable battleground datatext")
	Window:CreateDropdown("DataTexts", "Font", "Set datatext font", "Font")
end

local Loot = function(self)
	local Window = self:CreateWindow("Loot")
	
	Window:CreateSwitch("Loot", "Enable", "Enable loot module")
	Window:CreateSwitch("Loot", "StandardLoot", "StandardLoot")
	Window:CreateDropdown("Loot", "Font", "Set loot font", "Font")
end

local Misc = function(self)
	local Window = self:CreateWindow("Misc")
	
	Window:CreateSwitch("Misc", "ExperienceEnable", "Enable experience module")
	Window:CreateSwitch("Misc", "ReputationEnable", "Enable reputation module")
	Window:CreateSwitch("Misc", "ErrorFilterEnable", "Enable error filter module")
	Window:CreateSwitch("Misc", "AutoInviteEnable", "Enable auto invite module")
end

local NamePlates = function(self)
	local Window = self:CreateWindow("NamePlates")
	
	Window:CreateSwitch("NamePlates", "Enable", "Enable nameplate module")
	Window:CreateSwitch("NamePlates", "OnlySelfDebuffs", "OnlySelfDebuffs")
	Window:CreateSlider("NamePlates", "Width", 60, 200, 10, "Set nameplate width")
	Window:CreateSlider("NamePlates", "Height", 2, 20, 1, "Set nameplate height")
	Window:CreateDropdown("NamePlates", "Font", "Set nameplate font", "Font")
end

local Party = function(self)
	local Window = self:CreateWindow("Party")
	
	Window:CreateSwitch("Party", "Enable", "Enable party module")
	Window:CreateSwitch("Party", "ShowPlayer", "Display self in party")
	Window:CreateSwitch("Party", "ShowHealthText", "Display health text")
	Window:CreateSlider("Party", "RangeAlpha", 0, 1, 0.1, "Set out of range alpha")
	Window:CreateDropdown("Party", "Font", "Set party font", "Font")
	Window:CreateDropdown("Party", "HealthFont", "Set party health font", "Font")
end

local Raid = function(self)
	local Window = self:CreateWindow("Raid")
	
	Window:CreateSwitch("Raid", "Enable", "Enable raid module")
	Window:CreateSwitch("Raid", "AuraWatch", "Enable aurawatch module")
	Window:CreateSwitch("Raid", "AuraWatchTimers", "Enable aurawatch timers")
	Window:CreateSwitch("Raid", "DebuffWatch", "Enable debuffwatch module")
	Window:CreateSwitch("Raid", "ShowHealthText", "Display health text")
	Window:CreateSwitch("Raid", "ShowPets", "Display pets")
	Window:CreateSwitch("Raid", "VerticalHealth", "Enable vertical health")
	Window:CreateSlider("Raid", "RangeAlpha", 0, 1, 0.1, "Set out of range alpha")
	Window:CreateSlider("Raid", "MaxUnitPerColumn", 1, 15, 1, "Set max units per column")
	Window:CreateDropdown("Raid", "Font", "Set raid font", "Font")
	Window:CreateDropdown("Raid", "HealthFont", "Set raid health font", "Font")
	Window:CreateDropdown("Raid", "GroupBy", "Set raid grouping")
end

local Tooltips = function(self)
	local Window = self:CreateWindow("Tooltips")
	
	Window:CreateSwitch("Tooltips", "Enable", "Enable tooltip module")
	Window:CreateSwitch("Tooltips", "HideOnUnitFrames", "Hide tooltip on unitframes")
	Window:CreateSwitch("Tooltips", "UnitHealthText", "enable unit health text")
	Window:CreateSwitch("Tooltips", "MouseOver", "Display tooltips on the cursor")
	Window:CreateDropdown("Tooltips", "HealthFont", "Set tooltip health font", "Font")
end

local Textures = function(self)
	local Window = self:CreateWindow("Textures")
	
	Window:CreateDropdown("Textures", "QuestProgressTexture", "Set quest progress texture", "Texture")
	Window:CreateDropdown("Textures", "TTHealthTexture", "Set tooltip health texture", "Texture")
	Window:CreateDropdown("Textures", "UFHealthTexture", "Set unitframe health texture", "Texture")
	Window:CreateDropdown("Textures", "UFPowerTexture", "Set unitframe power texture", "Texture")
	Window:CreateDropdown("Textures", "UFCastTexture", "Set unitframe castbar texture", "Texture")
	Window:CreateDropdown("Textures", "UFPartyHealthTexture", "Set party health texture", "Texture")
	Window:CreateDropdown("Textures", "UFPartyPowerTexture", "Set party party texture", "Texture")
	Window:CreateDropdown("Textures", "UFRaidHealthTexture", "Set raid health texture", "Texture")
	Window:CreateDropdown("Textures", "UFRaidPowerTexture", "Set raid power texture", "Texture")
	Window:CreateDropdown("Textures", "NPHealthTexture", "Set nameplate health texture", "Texture")
	Window:CreateDropdown("Textures", "NPPowerTexture", "Set nameplate power texture", "Texture")
	Window:CreateDropdown("Textures", "NPCastTexture", "Set nameplate castbar texture", "Texture")

end

local UnitFrames = function(self)
	local Window = self:CreateWindow("UnitFrames")
	
	Window:CreateSwitch("UnitFrames", "Enable", "Enable unitframe module")
	Window:CreateSwitch("UnitFrames", "Portrait", "Enable unit portraits")
	Window:CreateSwitch("UnitFrames", "CastBar", "Enable castbar")
	Window:CreateSwitch("UnitFrames", "UnlinkCastBar", "UnlinkCastBar")
	Window:CreateSwitch("UnitFrames", "CastBarIcon", "Display castbar spell icon")
	Window:CreateSwitch("UnitFrames", "CastBarLatency", "Display castbar latency")
	Window:CreateSwitch("UnitFrames", "ComboBar", "Enable combo point bar")
	Window:CreateSwitch("UnitFrames", "Smooth", "Enable smooth health transitions")
	Window:CreateSwitch("UnitFrames", "CombatLog", "Enable combat feedback text")
	Window:CreateSwitch("UnitFrames", "PlayerAuras", "Enable player auras")
	Window:CreateSwitch("UnitFrames", "TargetAuras", "Enable target auras")
	Window:CreateSwitch("UnitFrames", "BossAuras", "Enable boss auras")
	Window:CreateSwitch("UnitFrames", "OnlySelfDebuffs", "OnlySelfDebuffs")
	Window:CreateSwitch("UnitFrames", "OnlySelfBuffs", "OnlySelfBuffs")
	Window:CreateSwitch("UnitFrames", "TargetEnemyHostileColor", "TargetEnemyHostileColor")
	Window:CreateSwitch("UnitFrames", "Boss", "Enable boss unitframe")
	Window:CreateDropdown("UnitFrames", "Font", "Set unitframe font", "Font")
end

-- Or you can stick ALL of the options into one function, whichever you prefer
GUI:AddWidgets(General)
GUI:AddWidgets(ActionBars)
GUI:AddWidgets(Auras)
GUI:AddWidgets(Bags)
GUI:AddWidgets(Chat)
GUI:AddWidgets(Cooldowns)
GUI:AddWidgets(DataTexts)
GUI:AddWidgets(Loot)
GUI:AddWidgets(Misc)
GUI:AddWidgets(NamePlates)
GUI:AddWidgets(Party)
GUI:AddWidgets(Raid)
GUI:AddWidgets(Tooltips)
GUI:AddWidgets(Textures)
GUI:AddWidgets(UnitFrames)