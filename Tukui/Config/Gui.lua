local T, C, L = select(2, ...):unpack()

--[[ TODO after classic release in this file ]]

-- Translate the GUI

--[[ TODO after classic release in this file ]]

local sort = table.sort
local tinsert = table.insert
local tremove = table.remove
local match = string.match
local floor = floor
local unpack = unpack
local pairs = pairs
local type = type

local StyleFont = function(fs, font, size)
	fs:SetFont(font, size)
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(1, -1)
end

local Font = C.Medias.Font
local Texture = "Interface\\AddOns\\Tukui\\Medias\\Textures\\Status\\ElvUI2"
local Blank = C.Medias.Blank

local ArrowUp = "Interface\\AddOns\\Tukui\\Medias\\Textures\\Others\\ArrowUp"
local ArrowDown = "Interface\\AddOns\\Tukui\\Medias\\Textures\\Others\\ArrowDown"

local LightColor = {0.175, 0.175, 0.175}
local BGColor = {0.2, 0.2, 0.2}
local BrightColor = {0.35, 0.35, 0.35}
local HeaderColor = {0.43, 0.43, 0.43}

local Color = T.Colors.class[select(2, UnitClass("player"))]
local R, G, B = unpack(Color)

local HeaderText = "Tukui Settings"

local WindowWidth = 490
local WindowHeight = 360

local Spacing = 4
local LabelSpacing = 6

local HeaderWidth = WindowWidth - (Spacing * 2)
local HeaderHeight = 22

local ButtonListWidth = 120

local MenuButtonWidth = ButtonListWidth - (Spacing * 2)
local MenuButtonHeight = 20

local WidgetListWidth = (WindowWidth - ButtonListWidth) - (Spacing * 3) + 1

local WidgetHeight = 20 -- All widgets are the same height
local WidgetHighlightAlpha = 0.3

local LastActiveWindow

local CreditLines = {"A very special thanks to", "", "Elv", "Hydra", "Haste", "Nightcracker", "Haleth", "Caellian", "Shestak", "Tekkub", "Roth", "Alza", "P3lim", "Tulla", "Hungtar", "Ishtara", "Caith", "Azilroka", "Simpy", "Aftermathh"}

local GUI = CreateFrame("Frame", "TukuiGUI", UIParent)
GUI.Windows = {}
GUI.Buttons = {}
GUI.Queue = {}
GUI.Widgets = {}

local SetValue = function(group, option, value)
	if (type(C[group][option]) == "table") then
		if C[group][option].Value then
			C[group][option].Value = value
		else
			C[group][option] = value
		end
	else
		C[group][option] = value
	end

	local Settings

	if (not TukuiSettingsPerCharacter) then
		TukuiSettingsPerCharacter = {}
	end

	if (not TukuiSettingsPerCharacter[T.MyRealm]) then
		TukuiSettingsPerCharacter[T.MyRealm] = {}
	end

	if (not TukuiSettingsPerCharacter[T.MyRealm][T.MyName]) then
		TukuiSettingsPerCharacter[T.MyRealm][T.MyName] = {}
	end

	if TukuiSettingsPerCharacter[T.MyRealm][T.MyName].General and TukuiSettingsPerCharacter[T.MyRealm][T.MyName].General.UseGlobal then
		Settings = TukuiSettings
	else
		Settings = TukuiSettingsPerCharacter[T.MyRealm][T.MyName]
	end

	if (not Settings[group]) then
		Settings[group] = {}
	end

	Settings[group][option] = value
end

local TrimHex = function(s)
	local Subbed = match(s, "|c%x%x%x%x%x%x%x%x(.-)|r")

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

local Reverse = function(value)
	if (value == true) then
		return false
	else
		return true
	end
end

-- Sections
local CreateSection = function(self, text)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:Size(WidgetListWidth - (Spacing * 2), WidgetHeight)
	Anchor.IsSection = true

	local Section = CreateFrame("Frame", nil, Anchor)
	Section:Point("TOPLEFT", Anchor, 0, 0)
	Section:Point("BOTTOMRIGHT", Anchor, 0, 0)
	Section:SetTemplate(nil, Texture)
	Section:SetBackdropColor(unpack(HeaderColor))

	Section.Label = Section:CreateFontString(nil, "OVERLAY")
	Section.Label:Point("CENTER", Section, LabelSpacing, 0)
	Section.Label:Width(WidgetListWidth - (Spacing * 4))
	StyleFont(Section.Label, Font, 12)
	Section.Label:SetJustifyH("CENTER")
	Section.Label:SetText(text)

	tinsert(self.Widgets, Anchor)

	return Section
end

GUI.Widgets.CreateSection = CreateSection

-- Buttons
local ButtonWidth = 134

local ButtonOnEnter = function(self)
	self.Highlight:SetAlpha(WidgetHighlightAlpha)
end

local ButtonOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local ButtonOnMouseDown = function(self)
	self:SetBackdropColor(unpack(BGColor))
end

local ButtonOnMouseUp = function(self)
	self:SetBackdropColor(unpack(BrightColor))
end

local CreateButton = function(self, midtext, text, func)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:Size(WidgetListWidth - (Spacing * 2), WidgetHeight)

	local Button = CreateFrame("Frame", nil, Anchor)
	Button:Size(ButtonWidth, WidgetHeight)
	Button:Point("LEFT", Anchor, 0, 0)
	Button:SetTemplate(nil, Texture)
	Button:SetBackdropColor(unpack(BrightColor))
	Button:SetScript("OnMouseDown", ButtonOnMouseDown)
	Button:SetScript("OnMouseUp", ButtonOnMouseUp)
	Button:SetScript("OnEnter", ButtonOnEnter)
	Button:SetScript("OnLeave", ButtonOnLeave)
	Button:HookScript("OnMouseUp", func)

	Button.Highlight = Button:CreateTexture(nil, "OVERLAY")
	Button.Highlight:SetAllPoints()
	Button.Highlight:SetTexture(Texture)
	Button.Highlight:SetVertexColor(0.5, 0.5, 0.5)
	Button.Highlight:SetAlpha(0)

	Button.Middle = Button:CreateFontString(nil, "OVERLAY")
	Button.Middle:Point("CENTER", Button, 0, 0)
	Button.Middle:Width(WidgetListWidth - (Spacing * 4))
	StyleFont(Button.Middle, Font, 12)
	Button.Middle:SetJustifyH("CENTER")
	Button.Middle:SetText(midtext)

	Button.Label = Button:CreateFontString(nil, "OVERLAY")
	Button.Label:Point("LEFT", Button, "RIGHT", Spacing, 0)
	Button.Label:Width(WidgetListWidth - ButtonWidth - (Spacing * 4))
	Button.Label:SetJustifyH("LEFT")
	StyleFont(Button.Label, Font, 12)
	Button.Label:SetText(text)

	tinsert(self.Widgets, Anchor)

	return Button
end

GUI.Widgets.CreateButton = CreateButton

-- Switches
local SwitchWidth = 46

local SwitchOnMouseUp = function(self, button)
	self.Thumb:ClearAllPoints()

	if (button == "RightButton") then
		self.Value = Reverse(T.Defaults[self.Group][self.Option])
	end

	if self.Value then
		self.Thumb:Point("RIGHT", self, 0, 0)
		self.Movement:SetOffset(-26, 0)
		self.Value = false
	else
		self.Thumb:Point("LEFT", self, 0, 0)
		self.Movement:SetOffset(26, 0)
		self.Value = true
	end

	self.Movement:Play()

	SetValue(self.Group, self.Option, self.Value)

	if self.Hook then
		self.Hook(self.Value)
	end
end

local SwitchOnEnter = function(self)
	self.Highlight:SetAlpha(WidgetHighlightAlpha)
end

local SwitchOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local CreateSwitch = function(self, group, option, text)
	local Value = C[group][option]

	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:Size(WidgetListWidth - (Spacing * 2), WidgetHeight)

	local Switch = CreateFrame("Frame", nil, Anchor)
	Switch:Point("LEFT", Anchor, 0, 0)
	Switch:Size(SwitchWidth, WidgetHeight)
	Switch:SetTemplate(nil, Texture)
	Switch:SetBackdropColor(unpack(BGColor))
	Switch:SetScript("OnMouseUp", SwitchOnMouseUp)
	Switch:SetScript("OnEnter", SwitchOnEnter)
	Switch:SetScript("OnLeave", SwitchOnLeave)
	Switch.Value = Value
	Switch.Group = group
	Switch.Option = option

	Switch.Highlight = Switch:CreateTexture(nil, "OVERLAY")
	Switch.Highlight:SetAllPoints()
	Switch.Highlight:SetTexture(Texture)
	Switch.Highlight:SetVertexColor(0.5, 0.5, 0.5)
	Switch.Highlight:SetAlpha(0)

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
	Switch.Label:Width(WidgetListWidth - SwitchWidth - (Spacing * 4))
	Switch.Label:SetJustifyH("LEFT")
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
local SliderWidth = 84
local EditboxWidth = 46

local Round = function(num, dec)
	local Mult = 10 ^ (dec or 0)

	return floor(num * Mult + 0.5) / Mult
end

local EditBoxOnEnter = function(self)
	self.Highlight:SetAlpha(WidgetHighlightAlpha)
end

local EditBoxOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local SliderOnEnter = function(self)
	self.Highlight:SetAlpha(WidgetHighlightAlpha)
end

local SliderOnLeave = function(self)
	self.Highlight:SetAlpha(0)
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
	local Value = tonumber(self:GetText())

	if (type(Value) ~= "number") then
		return
	end

	if (Value ~= self.Value) then
		self.Slider:SetValue(Value)
		SliderOnValueChanged(self.Slider)
	end

	self:SetAutoFocus(false)
	self:ClearFocus()
end

local EditBoxOnChar = function(self)
	local Value = tonumber(self:GetText())

	if (type(Value) ~= "number") then
		self:SetText(self.Value)
	end
end

local EditBoxOnMouseDown = function(self, button)
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

local CreateSlider = function(self, group, option, text, minvalue, maxvalue, stepvalue)
	local Value = C[group][option]

	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:Size(WidgetListWidth - (Spacing * 2), WidgetHeight)

	local EditBox = CreateFrame("Frame", nil, Anchor)
	EditBox:Point("LEFT", Anchor, 0, 0)
	EditBox:Size(EditboxWidth, WidgetHeight)
	EditBox:SetTemplate(nil, Texture)
	EditBox:SetBackdropColor(unpack(BrightColor))

	EditBox.Highlight = EditBox:CreateTexture(nil, "OVERLAY")
	EditBox.Highlight:SetAllPoints()
	EditBox.Highlight:SetTexture(Texture)
	EditBox.Highlight:SetVertexColor(0.5, 0.5, 0.5)
	EditBox.Highlight:SetAlpha(0)

	EditBox.Box = CreateFrame("EditBox", nil, EditBox)
	StyleFont(EditBox.Box, Font, 12)
	EditBox.Box:Point("TOPLEFT", EditBox, 0, 0)
	EditBox.Box:Point("BOTTOMRIGHT", EditBox, 0, 0)
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
	EditBox.Box:SetScript("OnChar", EditBoxOnChar)
	EditBox.Box:SetScript("OnEnter", EditBoxOnEnter)
	EditBox.Box:SetScript("OnLeave", EditBoxOnLeave)
	EditBox.Box.Group = group
	EditBox.Box.Option = option
	EditBox.Box.MinValue = minvalue
	EditBox.Box.MaxValue = maxvalue
	EditBox.Box.StepValue = stepvalue
	EditBox.Box.Value = Value
	EditBox.Box.Parent = EditBox
	EditBox.Box.Highlight = EditBox.Highlight

	local Slider = CreateFrame("Slider", nil, EditBox)
	Slider:Point("LEFT", EditBox, "RIGHT", Spacing, 0)
	Slider:Size(SliderWidth, WidgetHeight)
	Slider:SetThumbTexture(Texture)
	Slider:SetOrientation("HORIZONTAL")
	Slider:SetValueStep(stepvalue)
	Slider:SetTemplate(nil, Texture)
	Slider:SetBackdropColor(unpack(BGColor))
	Slider:SetMinMaxValues(minvalue, maxvalue)
	Slider:SetValue(Value)
	Slider:EnableMouseWheel(true)
	Slider:SetScript("OnMouseWheel", SliderOnMouseWheel)
	Slider:SetScript("OnValueChanged", SliderOnValueChanged)
	Slider:SetScript("OnEnter", SliderOnEnter)
	Slider:SetScript("OnLeave", SliderOnLeave)
	Slider.EditBox = EditBox.Box

	Slider.Highlight = Slider:CreateTexture(nil, "OVERLAY")
	Slider.Highlight:SetAllPoints()
	Slider.Highlight:SetTexture(Texture)
	Slider.Highlight:SetVertexColor(0.5, 0.5, 0.5)
	Slider.Highlight:SetAlpha(0)

	Slider.Label = Slider:CreateFontString(nil, "OVERLAY")
	Slider.Label:Point("LEFT", Slider, "RIGHT", LabelSpacing, 0)
	Slider.Label:Width(WidgetListWidth - (SliderWidth + EditboxWidth) - (Spacing * 5))
	Slider.Label:SetJustifyH("LEFT")
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
local DropdownWidth = 134
local SelectedHighlightAlpha = 0.2
local ListItemsToShow = 8
local LastActiveDropdown

local SetArrowUp = function(self)
	self.ArrowDown.Fade:SetChange(0)
	self.ArrowDown.Fade:SetEasing("out-sinusoidal")

	self.ArrowUp.Fade:SetChange(1)
	self.ArrowUp.Fade:SetEasing("in-sinusoidal")

	self.ArrowDown.Fade:Play()
	self.ArrowUp.Fade:Play()
end

local SetArrowDown = function(self)
	self.ArrowUp.Fade:SetChange(0)
	self.ArrowUp.Fade:SetEasing("out-sinusoidal")

	self.ArrowDown.Fade:SetChange(1)
	self.ArrowDown.Fade:SetEasing("in-sinusoidal")

	self.ArrowUp.Fade:Play()
	self.ArrowDown.Fade:Play()
end

local CloseLastDropdown = function(compare)
	if (LastActiveDropdown and LastActiveDropdown.Menu:IsShown() and (LastActiveDropdown ~= compare)) then
		if (not LastActiveDropdown.Menu.FadeOut:IsPlaying()) then
			LastActiveDropdown.Menu.FadeOut:Play()
			SetArrowDown(LastActiveDropdown)
		end
	end
end

local DropdownButtonOnMouseUp = function(self, button)
	self.Parent.Texture:SetVertexColor(unpack(BrightColor))

	if (button == "LeftButton") then
		if self.Menu:IsVisible() then
			self.Menu.FadeOut:Play()
			SetArrowDown(self)
		else
			for i = 1, #self.Menu do
				if self.Parent.Type then
					if (self.Menu[i].Key == self.Parent.Value) then
						self.Menu[i].Selected:Show()

						if (self.Parent.Type == "Texture") then
							self.Menu[i].Selected:SetTexture(T.GetTexture(self.Parent.Value))
						end
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
	else
		local Value = T.Defaults[self.Parent.Group][self.Parent.Option]

		self.Parent.Value = Value

		if (self.Parent.Type == "Texture") then
			self.Parent.Texture:SetTexture(T.GetTexture(Value))
		elseif (self.Parent.Type == "Font") then
			self.Parent.Current:SetFontObject(T.GetFont(Value))
		end

		self.Parent.Current:SetText(self.Parent.Value)

		SetValue(self.Parent.Group, self.Parent.Option, self.Parent.Value)
	end
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

	if self.GrandParent.Hook then
		self.GrandParent.Hook(self.Value)
	end

	self.GrandParent.Current:SetText(self.Key)
end

local MenuItemOnEnter = function(self)
	self.Highlight:SetAlpha(WidgetHighlightAlpha)
end

local MenuItemOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local DropdownButtonOnEnter = function(self)
	self.Highlight:SetAlpha(WidgetHighlightAlpha)
end

local DropdownButtonOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local ScrollMenu = function(self)
	local First = false

	for i = 1, #self do
		if (i >= self.Offset) and (i <= self.Offset + ListItemsToShow - 1) then
			if (not First) then
				self[i]:Point("TOPLEFT", self, 0, 0)
				First = true
			else
				self[i]:Point("TOPLEFT", self[i-1], "BOTTOMLEFT", 0, 1)
			end

			self[i]:Show()
		else
			self[i]:Hide()
		end
	end
end

local SetDropdownOffsetByDelta = function(self, delta)
	if (delta == 1) then -- up
		self.Offset = self.Offset - 1

		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else -- down
		self.Offset = self.Offset + 1

		if (self.Offset > (#self - (ListItemsToShow - 1))) then
			self.Offset = self.Offset - 1
		end
	end
end

local DropdownOnMouseWheel = function(self, delta)
	self:SetDropdownOffsetByDelta(delta)
	self:ScrollMenu()
	self.ScrollBar:SetValue(self.Offset)
end

local SetDropdownOffset = function(self, offset)
	self.Offset = offset

	if (self.Offset <= 1) then
		self.Offset = 1
	elseif (self.Offset > (#self - ListItemsToShow - 1)) then
		self.Offset = self.Offset - 1
	end

	self:ScrollMenu()
end

local DropdownScrollBarOnValueChanged = function(self)
	local Value = Round(self:GetValue())
	local Parent = self:GetParent()
	Parent.Offset = Value

	Parent:ScrollMenu()
end

local DropdownScrollBarOnMouseWheel = function(self, delta)
	DropdownOnMouseWheel(self:GetParent(), delta)
end

local AddDropdownScrollBar = function(self)
	local MaxValue = (#self - (ListItemsToShow - 1))
	local Width = WidgetHeight / 2

	local ScrollBar = CreateFrame("Slider", nil, self)
	ScrollBar:Point("TOPRIGHT", self, -Spacing, -Spacing)
	ScrollBar:Point("BOTTOMRIGHT", self, -Spacing, Spacing)
	ScrollBar:Width(Width)
	ScrollBar:SetThumbTexture(Texture)
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:SetTemplate(nil, Texture)
	ScrollBar:SetBackdropColor(unpack(BGColor))
	ScrollBar:SetMinMaxValues(1, MaxValue)
	ScrollBar:SetValue(1)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", DropdownScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", DropdownScrollBarOnValueChanged)

	self.ScrollBar = ScrollBar

	local Thumb = ScrollBar:GetThumbTexture()
	Thumb:Size(Width, WidgetHeight)
	Thumb:SetTexture(Blank)
	Thumb:SetVertexColor(0, 0, 0)

	ScrollBar.NewTexture = ScrollBar:CreateTexture(nil, "OVERLAY")
	ScrollBar.NewTexture:Point("TOPLEFT", Thumb, 0, 0)
	ScrollBar.NewTexture:Point("BOTTOMRIGHT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetTexture(Blank)
	ScrollBar.NewTexture:SetVertexColor(0, 0, 0)

	ScrollBar.NewTexture2 = ScrollBar:CreateTexture(nil, "OVERLAY")
	ScrollBar.NewTexture2:Point("TOPLEFT", ScrollBar.NewTexture, 1, -1)
	ScrollBar.NewTexture2:Point("BOTTOMRIGHT", ScrollBar.NewTexture, -1, 1)
	ScrollBar.NewTexture2:SetTexture(Blank)
	ScrollBar.NewTexture2:SetVertexColor(unpack(BrightColor))

	self:EnableMouseWheel(true)
	self:SetScript("OnMouseWheel", DropdownOnMouseWheel)

	self.ScrollMenu = ScrollMenu
	self.SetDropdownOffset = SetDropdownOffset
	self.SetDropdownOffsetByDelta = SetDropdownOffsetByDelta
	self.ScrollBar = ScrollBar

	self:SetDropdownOffset(1)

	ScrollBar:Show()

	for i = 1, #self do
		self[i]:Width((DropdownWidth - Width) - (Spacing * 3) - 1)
	end

	self:Height(((WidgetHeight - 1) * ListItemsToShow) + 1)
end

local CreateDropdown = function(self, group, option, text, custom)
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
	Dropdown.Group = group
	Dropdown.Option = option
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
	Dropdown.Button:SetScript("OnEnter", DropdownButtonOnEnter)
	Dropdown.Button:SetScript("OnLeave", DropdownButtonOnLeave)

	Dropdown.Button.Highlight = Dropdown:CreateTexture(nil, "ARTWORK")
	Dropdown.Button.Highlight:SetAllPoints()
	Dropdown.Button.Highlight:SetTexture(Texture)
	Dropdown.Button.Highlight:SetVertexColor(0.5, 0.5, 0.5)
	Dropdown.Button.Highlight:SetAlpha(0)

	Dropdown.Current = Dropdown:CreateFontString(nil, "ARTWORK")
	Dropdown.Current:Point("LEFT", Dropdown, Spacing, 0)
	Dropdown.Current:SetFontObject(T.GetFont("Tukui"))
	Dropdown.Current:SetJustifyH("LEFT")
	Dropdown.Current:Width(DropdownWidth - 4)
	Dropdown.Current:SetText(Value)

	Dropdown.Label = Dropdown:CreateFontString(nil, "OVERLAY")
	Dropdown.Label:Point("LEFT", Dropdown, "RIGHT", LabelSpacing, 0)
	Dropdown.Label:Width(WidgetListWidth - DropdownWidth - (Spacing * 4))
	Dropdown.Label:SetJustifyH("LEFT")
	StyleFont(Dropdown.Label, Font, 12)
	Dropdown.Label:SetJustifyH("LEFT")
	Dropdown.Label:Width(DropdownWidth - 4)
	Dropdown.Label:SetText(text)

	Dropdown.ArrowAnchor = CreateFrame("Frame", nil, Dropdown)
	Dropdown.ArrowAnchor:Size(WidgetHeight, WidgetHeight)
	Dropdown.ArrowAnchor:Point("RIGHT", Dropdown, 0, 0)

	Dropdown.Button.ArrowDown = Dropdown.ArrowAnchor:CreateTexture(nil, "OVERLAY")
	Dropdown.Button.ArrowDown:Size(10, 10)
	Dropdown.Button.ArrowDown:Point("CENTER", Dropdown.ArrowAnchor, 0, 0)
	Dropdown.Button.ArrowDown:SetTexture(ArrowDown)
	Dropdown.Button.ArrowDown:SetVertexColor(R, G, B)

	Dropdown.Button.ArrowUp = Dropdown.ArrowAnchor:CreateTexture(nil, "OVERLAY")
	Dropdown.Button.ArrowUp:Size(10, 10)
	Dropdown.Button.ArrowUp:Point("CENTER", Dropdown.ArrowAnchor, 0, 0)
	Dropdown.Button.ArrowUp:SetTexture(ArrowUp)
	Dropdown.Button.ArrowUp:SetVertexColor(R, G, B)
	Dropdown.Button.ArrowUp:SetAlpha(0)

	Dropdown.Button.ArrowDown.Fade = CreateAnimationGroup(Dropdown.Button.ArrowDown):CreateAnimation("Fade")
	Dropdown.Button.ArrowDown.Fade:SetDuration(0.15)

	Dropdown.Button.ArrowUp.Fade = CreateAnimationGroup(Dropdown.Button.ArrowUp):CreateAnimation("Fade")
	Dropdown.Button.ArrowUp.Fade:SetDuration(0.15)

	Dropdown.Menu = CreateFrame("Frame", nil, Dropdown)
	Dropdown.Menu:Point("TOP", Dropdown, "BOTTOM", 0, -2)
	Dropdown.Menu:Size(DropdownWidth - 6, 1)
	Dropdown.Menu:SetTemplate()
	Dropdown.Menu:SetBackdropBorderColor(0, 0, 0)
	Dropdown.Menu:SetFrameLevel(Dropdown.Menu:GetFrameLevel() + 1)
	Dropdown.Menu:SetFrameStrata("DIALOG")
	Dropdown.Menu:Hide()
	Dropdown.Menu:SetAlpha(0)

	Dropdown.Button.Menu = Dropdown.Menu
	Dropdown.Button.Parent = Dropdown

	Dropdown.Menu.Fade = CreateAnimationGroup(Dropdown.Menu)

	Dropdown.Menu.FadeIn = Dropdown.Menu.Fade:CreateAnimation("Fade")
	Dropdown.Menu.FadeIn:SetEasing("in-sinusoidal")
	Dropdown.Menu.FadeIn:SetDuration(0.3)
	Dropdown.Menu.FadeIn:SetChange(1)

	Dropdown.Menu.FadeOut = Dropdown.Menu.Fade:CreateAnimation("Fade")
	Dropdown.Menu.FadeOut:SetEasing("out-sinusoidal")
	Dropdown.Menu.FadeOut:SetDuration(0.3)
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
		MenuItem.Highlight:SetTexture(Texture)
		MenuItem.Highlight:SetVertexColor(0.5, 0.5, 0.5)
		MenuItem.Highlight:SetAlpha(0)

		MenuItem.Texture = MenuItem:CreateTexture(nil, "ARTWORK")
		MenuItem.Texture:Point("TOPLEFT", MenuItem, 1, -1)
		MenuItem.Texture:Point("BOTTOMRIGHT", MenuItem, -1, 1)
		MenuItem.Texture:SetTexture(Texture)
		MenuItem.Texture:SetVertexColor(unpack(BrightColor))

		MenuItem.Selected = MenuItem:CreateTexture(nil, "OVERLAY")
		MenuItem.Selected:Point("TOPLEFT", MenuItem, 1, -1)
		MenuItem.Selected:Point("BOTTOMRIGHT", MenuItem, -1, 1)
		MenuItem.Selected:SetTexture(Texture)
		MenuItem.Selected:SetVertexColor(R, G, B)

		MenuItem.Text = MenuItem:CreateFontString(nil, "OVERLAY")
		MenuItem.Text:Point("LEFT", MenuItem, 5, 0)
		MenuItem.Text:Width((DropdownWidth - 6) - (Spacing * 2))
		MenuItem.Text:SetFontObject(T.GetFont("Tukui"))
		MenuItem.Text:SetJustifyH("LEFT")
		MenuItem.Text:SetText(k)

		if (custom == "Texture") then
			MenuItem.Texture:SetTexture(T.GetTexture(k))
			MenuItem.Selected:SetTexture(T.GetTexture(k))
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

		if (Count > ListItemsToShow) then
			MenuItem:Hide()
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

	if (#Dropdown.Menu > ListItemsToShow) then
		AddDropdownScrollBar(Dropdown.Menu)
	else
		Dropdown.Menu:Height(((WidgetHeight - 1) * Count) + 1)
	end

	if self.Widgets then
		tinsert(self.Widgets, Anchor)
	end

	return Dropdown
end

GUI.Widgets.CreateDropdown = CreateDropdown

-- Color selection
local ColorButtonWidth = 110

local ColorPickerFrameCancel = function()

end

local ColorOnMouseUp = function(self, button)
	local CPF = ColorPickerFrame

	if CPF:IsShown() then
		return
	end

	self:SetBackdropColor(unpack(BrightColor))

	local CurrentR, CurrentG, CurrentB = unpack(self.Value)

	if (button == "LeftButton") then
		local ShowColorPickerFrame = function(r, g, b, func, cancel)
			HideUIPanel(CPF)
			CPF.Button = self

			CPF:SetColorRGB(CurrentR, CurrentG, CurrentB)

			CPF.Group = self.Group
			CPF.Option = self.Option
			CPF.OldR = CurrentR
			CPF.OldG = CurrentG
			CPF.OldB = CurrentB
			CPF.previousValues = self.Value
			CPF.func = func
			CPF.opacityFunc = func
			CPF.cancelFunc = cancel

			ShowUIPanel(CPF)
		end

		local ColorPickerFunction = function(restore)
			if (restore ~= nil or self ~= CPF.Button) then
				return
			end

			local NewR, NewG, NewB = CPF:GetColorRGB()

			NewR = Round(NewR, 3)
			NewG = Round(NewG, 3)
			NewB = Round(NewB, 3)

			local NewValue = {NewR, NewG, NewB}

			CPF.Button:GetParent():SetBackdropColor(NewR, NewG, NewB)
			CPF.Button.Value = NewValue

			SetValue(CPF.Group, CPF.Option, NewValue)
		end

		ShowColorPickerFrame(CurrentR, CurrentG, CurrentB, ColorPickerFunction, ColorPickerFrameCancel)
	else
		local Value = T.Defaults[self.Group][self.Option]

		self:GetParent():SetBackdropColor(unpack(Value))
		self.Value = Value

		SetValue(self.Group, self.Option, Value)
	end
end

local ColorOnMouseDown = function(self)
	self:SetBackdropColor(unpack(BGColor))
end

local ColorOnEnter = function(self)
	self.Highlight:SetAlpha(WidgetHighlightAlpha)
end

local ColorOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local CreateColorSelection = function(self, group, option, text)
	local Value = C[group][option]
	local Selections

	local CurrentR, CurrentG, CurrentB = unpack(Value)

	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:Size(WidgetListWidth - (Spacing * 2), WidgetHeight)

	local Swatch = CreateFrame("Frame", nil, Anchor)
	Swatch:Size(WidgetHeight, WidgetHeight)
	Swatch:Point("LEFT", Anchor, 0, 0)
	Swatch:SetTemplate(nil, Texture)
	Swatch:SetBackdropColor(CurrentR, CurrentG, CurrentB)

	Swatch.Select = CreateFrame("Frame", nil, Swatch)
	Swatch.Select:Size(ColorButtonWidth, WidgetHeight)
	Swatch.Select:Point("LEFT", Swatch, "RIGHT", Spacing, 0)
	Swatch.Select:SetTemplate(nil, Texture)
	Swatch.Select:SetBackdropColor(unpack(BrightColor))
	Swatch.Select:SetScript("OnMouseDown", ColorOnMouseDown)
	Swatch.Select:SetScript("OnMouseUp", ColorOnMouseUp)
	Swatch.Select:SetScript("OnEnter", ColorOnEnter)
	Swatch.Select:SetScript("OnLeave", ColorOnLeave)
	Swatch.Select.Group = group
	Swatch.Select.Option = option
	Swatch.Select.Value = Value

	Swatch.Select.Highlight = Swatch.Select:CreateTexture(nil, "OVERLAY")
	Swatch.Select.Highlight:SetAllPoints()
	Swatch.Select.Highlight:SetTexture(Texture)
	Swatch.Select.Highlight:SetVertexColor(0.5, 0.5, 0.5)
	Swatch.Select.Highlight:SetAlpha(0)

	Swatch.Select.Label = Swatch.Select:CreateFontString(nil, "OVERLAY")
	Swatch.Select.Label:Point("CENTER", Swatch.Select, 0, 0)
	StyleFont(Swatch.Select.Label, Font, 12)
	Swatch.Select.Label:SetJustifyH("CENTER")
	Swatch.Select.Label:Width(ColorButtonWidth - 4)
	Swatch.Select.Label:SetText("Select Color")

	Swatch.Label = Swatch:CreateFontString(nil, "OVERLAY")
	Swatch.Label:Point("LEFT", Swatch.Select, "RIGHT", LabelSpacing, 0)
	Swatch.Label:Width(WidgetListWidth - (ColorButtonWidth + WidgetHeight) - (Spacing * 5))
	Swatch.Label:SetJustifyH("LEFT")
	StyleFont(Swatch.Label, Font, 12)
	Swatch.Label:SetJustifyH("LEFT")
	Swatch.Label:Width(DropdownWidth - 4)
	Swatch.Label:SetText(text)

	tinsert(self.Widgets, Anchor)

	return Swatch
end

GUI.Widgets.CreateColorSelection = CreateColorSelection

-- GUI functions
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

local Scroll = function(self)
	local First = false

	for i = 1, #self.Widgets do
		if (i >= self.Offset) and (i <= self.Offset + self:GetParent().WindowCount - 1) then
			if (not First) then
				self.Widgets[i]:Point("TOPLEFT", self, Spacing, -Spacing)
				First = true
			else
				self.Widgets[i]:Point("TOPLEFT", self.Widgets[i-1], "BOTTOMLEFT", 0, -(Spacing - 1))
			end

			self.Widgets[i]:Show()
		else
			self.Widgets[i]:Hide()
		end
	end
end

local SetOffsetByDelta = function(self, delta)
	if (delta == 1) then -- up
		self.Offset = self.Offset - 1

		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else -- down
		self.Offset = self.Offset + 1

		if (self.Offset > (#self.Widgets - (self:GetParent().WindowCount - 1))) then
			self.Offset = self.Offset - 1
		end
	end
end

local WindowOnMouseWheel = function(self, delta)
	self:SetOffsetByDelta(delta)
	self:Scroll()
	self.ScrollBar:SetValue(self.Offset)
end

local SetOffset = function(self, offset)
	self.Offset = offset

	if (self.Offset <= 1) then
		self.Offset = 1
	elseif (self.Offset > (#self.Widgets - self:GetParent().WindowCount - 1)) then
		self.Offset = self.Offset - 1
	end

	self:Scroll()
end

local WindowScrollBarOnValueChanged = function(self)
	local Value = Round(self:GetValue())
	local Parent = self:GetParent()
	Parent.Offset = Value

	Parent:Scroll()
end

local WindowScrollBarOnMouseWheel = function(self, delta)
	WindowOnMouseWheel(self:GetParent(), delta)
end

local AddScrollBar = function(self)
	local MaxValue = (#self.Widgets - (self:GetParent().WindowCount - 1))

	local ScrollBar = CreateFrame("Slider", nil, self)
	ScrollBar:Point("TOPRIGHT", self, -Spacing, -Spacing)
	ScrollBar:Point("BOTTOMRIGHT", self, -Spacing, Spacing)
	ScrollBar:Width(WidgetHeight)
	ScrollBar:SetThumbTexture(Texture)
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:SetTemplate(nil, Texture)
	ScrollBar:SetBackdropColor(unpack(BGColor))
	ScrollBar:SetMinMaxValues(1, MaxValue)
	ScrollBar:SetValue(1)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", WindowScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", WindowScrollBarOnValueChanged)

	ScrollBar.Window = self

	local Thumb = ScrollBar:GetThumbTexture()
	Thumb:Size(WidgetHeight, WidgetHeight)
	Thumb:SetTexture(Blank)
	Thumb:SetVertexColor(0, 0, 0)

	ScrollBar.NewTexture = ScrollBar:CreateTexture(nil, "OVERLAY")
	ScrollBar.NewTexture:Point("TOPLEFT", Thumb, 0, 0)
	ScrollBar.NewTexture:Point("BOTTOMRIGHT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetTexture(Blank)
	ScrollBar.NewTexture:SetVertexColor(0, 0, 0)

	ScrollBar.NewTexture2 = ScrollBar:CreateTexture(nil, "OVERLAY")
	ScrollBar.NewTexture2:Point("TOPLEFT", ScrollBar.NewTexture, 1, -1)
	ScrollBar.NewTexture2:Point("BOTTOMRIGHT", ScrollBar.NewTexture, -1, 1)
	ScrollBar.NewTexture2:SetTexture(Blank)
	ScrollBar.NewTexture2:SetVertexColor(unpack(BrightColor))

	self:EnableMouseWheel(true)
	self:SetScript("OnMouseWheel", WindowOnMouseWheel)

	self.Scroll = Scroll
	self.SetOffset = SetOffset
	self.SetOffsetByDelta = SetOffsetByDelta
	self.ScrollBar = ScrollBar

	self:SetOffset(1)

	ScrollBar:Show()

	for i = 1, #self.Widgets do
		if self.Widgets[i].IsSection then
			self.Widgets[i]:Width((WidgetListWidth - WidgetHeight) - (Spacing * 3))
		end
	end
end

GUI.DisplayWindow = function(self, name)
	if (TukuiCredits and TukuiCredits:IsShown()) then
		TukuiCredits:Hide()
		TukuiCredits.Move:Stop()

		local Window = GUI:GetWindow(LastActiveWindow)

		Window:Show()
		Window.Button.Selected:Show()

		return
	end

	for WindowName, Window in pairs(self.Windows) do
		if (WindowName ~= name) then
			Window:Hide()

			if Window.Button.Selected:IsShown() then
				Window.Button.Selected:Hide()
			end
		else
			if (not Window.Sorted) then
				SortWidgets(Window)

				if (#Window.Widgets > self.WindowCount) then
					AddScrollBar(Window)
				end
			end

			Window:Show()
			Window.Button.Selected:Show()

			LastActiveWindow = WindowName
		end
	end

	CloseLastDropdown()
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

	self.WindowCount = self.WindowCount or 0

	local Button = CreateFrame("Frame", nil, self.ButtonList)
	Button:Size(MenuButtonWidth, MenuButtonHeight)
	Button:SetTemplate(nil, Texture)
	Button:SetBackdropColor(unpack(BrightColor))
	Button:SetScript("OnMouseUp", MenuButtonOnMouseUp)
	Button:SetScript("OnEnter", MenuButtonOnEnter)
	Button:SetScript("OnLeave", MenuButtonOnLeave)
	Button.Name = name
	Button.Parent = self

	Button.Highlight = Button:CreateTexture(nil, "OVERLAY")
	Button.Highlight:SetAllPoints()
	Button.Highlight:SetTexture(Texture)
	Button.Highlight:SetVertexColor(0.5, 0.5, 0.5, 0.3)
	Button.Highlight:Hide()

	Button.Selected = Button:CreateTexture(nil, "OVERLAY")
	Button.Selected:Point("TOPLEFT", Button, 1, -1)
	Button.Selected:Point("BOTTOMRIGHT", Button, -1, 1)
	Button.Selected:SetTexture(Texture)
	Button.Selected:SetVertexColor(0.7, 0.7, 0.7, 0.5)
	Button.Selected:Hide()

	Button.Label = Button:CreateFontString(nil, "OVERLAY")
	Button.Label:Point("CENTER", Button, 0, 0)
	Button.Label:Width(MenuButtonWidth - (Spacing * 2))
	StyleFont(Button.Label, Font, 14)
	Button.Label:SetText(name)

	tinsert(self.Buttons, Button)

	local Window = CreateFrame("Frame", nil, self)
	Window:Width(WidgetListWidth)
	Window:Point("TOPRIGHT", self.Header, "BOTTOMRIGHT", 0, -(Spacing - 1))
	Window:Point("BOTTOMRIGHT", self.Footer, "TOPRIGHT", 0, (Spacing - 1))
	Window:SetTemplate("Transparent")
	Window:CreateShadow()
	--Window:SetBackdropColor(unpack(LightColor))
	Window.Button = Button
	Window.Widgets = {}
	Window.Offset = 0
	Window:Hide()

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
	GUI:Toggle()
end

local CreditLineHeight = 20

local SetUpCredits = function(frame)
	frame.Lines = {}

	for i = 1, #CreditLines do
		local Line = CreateFrame("Frame", nil, frame)
		Line:Size(frame:GetWidth(), CreditLineHeight)

		Line.Text = Line:CreateFontString(nil, "OVERLAY")
		Line.Text:Point("CENTER", Line, 0, 0)
		StyleFont(Line.Text, Font, 16)
		Line.Text:SetJustifyH("CENTER")
		Line.Text:SetText(CreditLines[i])

		if (i == 1) then
			Line:Point("TOP", frame, 0, -1)
		else
			Line:Point("TOP", frame.Lines[i-1], "BOTTOM", 0, 0)
		end

		tinsert(frame.Lines, Line)
	end

	frame:Height(#frame.Lines * CreditLineHeight)
end

local ShowCreditFrame = function()
	local Window = GUI:GetWindow(LastActiveWindow)

	Window:Hide()

	TukuiCredits:Show()
	TukuiCredits.Move:Play()
end

local HideCreditFrame = function()
	TukuiCredits:Hide()
	TukuiCredits.Move:Stop()

	local Window = GUI:GetWindow(LastActiveWindow)

	Window:Show()
	Window.Button.Selected:Show()
end

local ToggleCreditsFrame = function()
	if TukuiCredits:IsShown() then
		HideCreditFrame()
	else
		ShowCreditFrame()
	end
end

GUI.Enable = function(self)
	if self.Created then
		return
	end

	-- Main Window
	self:SetFrameStrata("DIALOG")
	self:Width(WindowWidth)
	self:Point("CENTER", UIParent, 0, 0)
	self:SetBackdropColor(unpack(BGColor))
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

		if TukuiCredits:IsShown() then
			HideCreditFrame()
		end
	end)

	-- Header
	self.Header = CreateFrame("Frame", nil, self)
	self.Header:SetFrameStrata("DIALOG")
	self.Header:Size(HeaderWidth, HeaderHeight)
	self.Header:Point("TOP", self, 0, -Spacing)
	self.Header:SetTemplate(nil, Texture)
	self.Header:CreateShadow()
	self.Header:SetBackdropColor(unpack(HeaderColor))

	self.Header.Label = self.Header:CreateFontString(nil, "OVERLAY")
	self.Header.Label:Point("CENTER", self.Header, 0, 0)
	StyleFont(self.Header.Label, Font, 16)
	self.Header.Label:SetText(HeaderText)

	-- Footer
	self.Footer = CreateFrame("Frame", nil, self)
	self.Footer:SetFrameStrata("DIALOG")
	self.Footer:Size(HeaderWidth, HeaderHeight)
	self.Footer:Point("BOTTOM", self, 0, Spacing)
	self.Footer:SetBackdropColor(unpack(LightColor))

	local FooterButtonWidth = ((HeaderWidth / 4) - Spacing) + 1

	-- Global button
	local GlobalButtonString = "You are currently using per-character gui settings, push me to switch to global"

	if TukuiSettingsPerCharacter[T.MyRealm][T.MyName].General and TukuiSettingsPerCharacter[T.MyRealm][T.MyName].General.UseGlobal then
		GlobalButtonString = "You are currently using global gui settings, push me to switch to per-character"
	end

	local Global = CreateFrame("Frame", nil, self.Footer)
	Global:Size(self.Footer:GetWidth(), HeaderHeight)
	Global:Point("LEFT", self.Footer, 0, 0)
	Global:SetTemplate(nil, Texture)
	Global:CreateShadow()
	Global:SetBackdropColor(unpack(BrightColor))
	Global:SetScript("OnMouseDown", ButtonOnMouseDown)
	Global:SetScript("OnMouseUp", ButtonOnMouseUp)
	Global:SetScript("OnEnter", ButtonOnEnter)
	Global:SetScript("OnLeave", ButtonOnLeave)
	Global:HookScript("OnMouseUp", function()
		local Settings = TukuiSettingsPerCharacter[T.MyRealm][T.MyName]

		if Settings.General and Settings.General.UseGlobal then
			TukuiSettingsPerCharacter[T.MyRealm][T.MyName].General.UseGlobal = false
		else
			if not TukuiSettingsPerCharacter[T.MyRealm][T.MyName].General then
				TukuiSettingsPerCharacter[T.MyRealm][T.MyName].General = {}
			end

			TukuiSettingsPerCharacter[T.MyRealm][T.MyName].General.UseGlobal = true
		end

		ReloadUI()
	end)

	Global.Highlight = Global:CreateTexture(nil, "OVERLAY")
	Global.Highlight:SetAllPoints()
	Global.Highlight:SetTexture(Texture)
	Global.Highlight:SetVertexColor(0.5, 0.5, 0.5)
	Global.Highlight:SetAlpha(0)

	Global.Middle = Global:CreateFontString(nil, "OVERLAY")
	Global.Middle:SetAllPoints()
	StyleFont(Global.Middle, Font, 14)
	Global.Middle:SetJustifyH("CENTER")
	Global.Middle:SetText(GlobalButtonString)

	-- Apply button
	local Apply = CreateFrame("Frame", nil, self.Footer)
	Apply:Size(FooterButtonWidth + 3, HeaderHeight)
	Apply:Point("LEFT", self.Footer, 0, -25)
	Apply:SetTemplate(nil, Texture)
	Apply:CreateShadow()
	Apply:SetBackdropColor(unpack(BrightColor))
	Apply:SetScript("OnMouseDown", ButtonOnMouseDown)
	Apply:SetScript("OnMouseUp", ButtonOnMouseUp)
	Apply:SetScript("OnEnter", ButtonOnEnter)
	Apply:SetScript("OnLeave", ButtonOnLeave)
	Apply:HookScript("OnMouseUp", ReloadUI)

	Apply.Highlight = Apply:CreateTexture(nil, "OVERLAY")
	Apply.Highlight:SetAllPoints()
	Apply.Highlight:SetTexture(Texture)
	Apply.Highlight:SetVertexColor(0.5, 0.5, 0.5)
	Apply.Highlight:SetAlpha(0)

	Apply.Middle = Apply:CreateFontString(nil, "OVERLAY")
	Apply.Middle:Point("CENTER", Apply, 0, 0)
	Apply.Middle:Width(FooterButtonWidth - (Spacing * 2))
	StyleFont(Apply.Middle, Font, 14)
	Apply.Middle:SetJustifyH("CENTER")
	Apply.Middle:SetText("Apply")

	-- Reset button
	local Reset = CreateFrame("Frame", nil, self.Footer)
	Reset:Size(FooterButtonWidth - 1, HeaderHeight)
	Reset:Point("LEFT", Apply, "RIGHT", (Spacing - 1), 0)
	Reset:SetTemplate(nil, Texture)
	Reset:CreateShadow()
	Reset:SetBackdropColor(unpack(BrightColor))
	Reset:SetScript("OnMouseDown", ButtonOnMouseDown)
	Reset:SetScript("OnMouseUp", ButtonOnMouseUp)
	Reset:SetScript("OnEnter", ButtonOnEnter)
	Reset:SetScript("OnLeave", ButtonOnLeave)
	Reset:HookScript("OnMouseUp", function()
		T.Popups.ShowPopup("TUKUI_RESET_SETTINGS")
	end)

	Reset.Highlight = Reset:CreateTexture(nil, "OVERLAY")
	Reset.Highlight:SetAllPoints()
	Reset.Highlight:SetTexture(Texture)
	Reset.Highlight:SetVertexColor(0.5, 0.5, 0.5)
	Reset.Highlight:SetAlpha(0)

	Reset.Middle = Reset:CreateFontString(nil, "OVERLAY")
	Reset.Middle:Point("CENTER", Reset, 0, 0)
	Reset.Middle:Width(FooterButtonWidth - (Spacing * 2))
	StyleFont(Reset.Middle, Font, 14)
	Reset.Middle:SetJustifyH("CENTER")
	Reset.Middle:SetText("Reset")

	-- Move button
	local Move = CreateFrame("Frame", nil, self.Footer)
	Move:Size(FooterButtonWidth + 1, HeaderHeight)
	Move:Point("LEFT", Reset, "RIGHT", (Spacing - 1), 0)
	Move:SetTemplate(nil, Texture)
	Move:CreateShadow()
	Move:SetBackdropColor(unpack(BrightColor))
	Move:SetScript("OnMouseDown", ButtonOnMouseDown)
	Move:SetScript("OnMouseUp", ButtonOnMouseUp)
	Move:SetScript("OnEnter", ButtonOnEnter)
	Move:SetScript("OnLeave", ButtonOnLeave)
	Move:HookScript("OnMouseUp", function()
		T.Movers:StartOrStopMoving()
	end)

	Move.Highlight = Move:CreateTexture(nil, "OVERLAY")
	Move.Highlight:SetAllPoints()
	Move.Highlight:SetTexture(Texture)
	Move.Highlight:SetVertexColor(0.5, 0.5, 0.5)
	Move.Highlight:SetAlpha(0)

	Move.Middle = Move:CreateFontString(nil, "OVERLAY")
	Move.Middle:Point("CENTER", Move, 0, 0)
	Move.Middle:Width(FooterButtonWidth - (Spacing * 2))
	StyleFont(Move.Middle, Font, 14)
	Move.Middle:SetJustifyH("CENTER")
	Move.Middle:SetText("Move UI")

	-- Credits button
	local Credits = CreateFrame("Frame", nil, self.Footer)
	Credits:Size(FooterButtonWidth + 2, HeaderHeight)
	Credits:Point("LEFT", Move, "RIGHT", (Spacing - 1), 0)
	Credits:SetTemplate(nil, Texture)
	Credits:CreateShadow()
	Credits:SetBackdropColor(unpack(BrightColor))
	Credits:SetScript("OnMouseDown", ButtonOnMouseDown)
	Credits:SetScript("OnMouseUp", ButtonOnMouseUp)
	Credits:SetScript("OnEnter", ButtonOnEnter)
	Credits:SetScript("OnLeave", ButtonOnLeave)
	Credits:HookScript("OnMouseUp", ToggleCreditsFrame)

	Credits.Highlight = Credits:CreateTexture(nil, "OVERLAY")
	Credits.Highlight:SetAllPoints()
	Credits.Highlight:SetTexture(Texture)
	Credits.Highlight:SetVertexColor(0.5, 0.5, 0.5)
	Credits.Highlight:SetAlpha(0)

	Credits.Middle = Credits:CreateFontString(nil, "OVERLAY")
	Credits.Middle:Point("CENTER", Credits, 0, 0)
	Credits.Middle:Width(FooterButtonWidth - (Spacing * 2))
	StyleFont(Credits.Middle, Font, 14)
	Credits.Middle:SetJustifyH("CENTER")
	Credits.Middle:SetText("Credits")

	-- Button list
	self.ButtonList = CreateFrame("Frame", nil, self)
	self.ButtonList:Width(ButtonListWidth)
	self.ButtonList:Point("BOTTOMLEFT", self, Spacing, Spacing)
	self.ButtonList:Point("TOPLEFT", self.Header, "BOTTOMLEFT", 0, -(Spacing - 1))
	self.ButtonList:Point("BOTTOMLEFT", self.Footer, "TOPLEFT", 0, (Spacing - 1))
	self.ButtonList:SetTemplate("Transparent")
	self.ButtonList:CreateShadow()
	--self.ButtonList:SetBackdropColor(unpack(LightColor))

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

	self:UnpackQueue()

	-- Set the frame height
	local Height = (HeaderHeight * 2) + (Spacing + 2) + (self.WindowCount * MenuButtonHeight) + ((self.WindowCount) * Spacing)

	self:Height(Height)

	if self.DefaultWindow then
		self:DisplayWindow(self.DefaultWindow)
	end

	self:SortMenuButtons()

	-- Create credits
	local CreditFrame = CreateFrame("Frame", "TukuiCredits", self)
	CreditFrame:Point("TOPRIGHT", self.Header, "BOTTOMRIGHT", 0, -(Spacing - 1))
	CreditFrame:Point("TOPLEFT", self.ButtonList, "TOPRIGHT", (Spacing - 1), 0)
	CreditFrame:Point("BOTTOMRIGHT", self.Footer, "TOPRIGHT", 0, (Spacing - 1))
	CreditFrame:Point("BOTTOMLEFT", self.ButtonList, "BOTTOMRIGHT", (Spacing - 1), 0)
	CreditFrame:SetFrameStrata("DIALOG")
	CreditFrame:SetTemplate("Transparent")
	CreditFrame:CreateShadow()
	CreditFrame:EnableMouse(true)
	CreditFrame:EnableMouseWheel(true)
	CreditFrame:Hide()

	local ScrollFrame = CreateFrame("ScrollFrame", nil, CreditFrame)
	ScrollFrame:Point("TOPLEFT", CreditFrame, 1, -1)
	ScrollFrame:Point("BOTTOMRIGHT", CreditFrame, -1, 1)

	local Scrollable = CreateFrame("Frame", nil, ScrollFrame)
	Scrollable:Size(ScrollFrame:GetSize())

	CreditFrame.Move = CreateAnimationGroup(Scrollable):CreateAnimation("Move")
	CreditFrame.Move:SetDuration(12)
	CreditFrame.Move:SetScript("OnFinished", function(self)
		local Parent = self:GetParent()

		Parent:ClearAllPoints()
		Parent:Point("TOP", ScrollFrame, "BOTTOM", 0, 0)

		self:Play()
	end)

	ScrollFrame:SetScrollChild(Scrollable)

	SetUpCredits(Scrollable)

	CreditFrame.Move:SetOffset(0, (Scrollable:GetHeight() * 2))

	Scrollable:ClearAllPoints()
	Scrollable:SetPoint("TOP", ScrollFrame, "BOTTOM", 0, 0)

	GameMenuFrame:HookScript("OnShow", function()
		if GUI:IsShown() then
			GUI:Toggle()
		end
	end)

	self.Created = true
end

GUI.Toggle = function(self)
	if InCombatLockdown() then
		return
	end

	local Panels = T.Panels
	local IsBarEnabled = C.ActionBars.Enable

	if self:IsShown() then
		self.FadeOut:Play()

		if IsBarEnabled then
			local Pet = T.Panels["ActionBarPetToggleButton"]

			for i = 2, 5 do
				local Toggle = Panels["ActionBar" .. i .. "ToggleButton"]

				Toggle:Hide()
			end

			Pet:Hide()
		end
	else
		self:Show()
		self.FadeIn:Play()

		-- Really annoying to receive each day the same question on discord about how to hide action bars, let's show them when GUI is displayed.
		if IsBarEnabled then
			local Pet = T.Panels["ActionBarPetToggleButton"]

			for i = 2, 5 do
				local Toggle = Panels["ActionBar" .. i .. "ToggleButton"]

				Toggle:Show()
			end

			if T.Panels.PetActionBar:IsShown() then
				Pet:Show()
			end
		end
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
	if self.CombatClosed then
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

T.GUI = GUI

local General = function(self)
	local Window = self:CreateWindow("General", true)

	Window:CreateSection("Theme")
	Window:CreateDropdown("General", "Themes", "Set UI theme")

	Window:CreateSection("Scaling")
	Window:CreateSlider("General", "UIScale", "Set UI scale", 0.64, 1, 0.01)
	Window:CreateSlider("General", "MinimapScale", "Set minimap scale (%)", 50, 200, 1)
	Window:CreateSlider("General", "WorldMapScale", "Set world map scale (%)", 40, 100, 1)

	Window:CreateSection("Border & Backdrop")
	Window:CreateColorSelection("General", "BackdropColor", "Backdrop color")
	Window:CreateColorSelection("General", "BorderColor", "Border color")
	Window:CreateSwitch("General", "HideShadows", "Hide frame shadows")
end

local ActionBars = function(self)
	local Window = self:CreateWindow("Actionbars")

	Window:CreateSection("Enable")
	Window:CreateSwitch("ActionBars", "Enable", "Enable actionbar module")
	Window:CreateSwitch("ActionBars", "Pet", "Enable pet bar")
	Window:CreateSwitch("ActionBars", "HotKey", "Enable hotkeys text")
	Window:CreateSwitch("ActionBars", "Macro", "Enable macro text")

	Window:CreateSection("Styling")
	Window:CreateSwitch("ActionBars", "EquipBorder", "Highlight equipped item if they are in action bars")
	Window:CreateSwitch("ActionBars", "ShapeShift", "ShapeShift")
	Window:CreateSwitch("ActionBars", "SwitchBarOnStance", "Switch bar on stance changes")
	Window:CreateSwitch("ActionBars", "HideBackdrop", "Hide the actionbar backdrop")

	Window:CreateSection("Sizing")
	Window:CreateSlider("ActionBars", "NormalButtonSize", "Set button size", 20, 36, 1)
	Window:CreateSlider("ActionBars", "PetButtonSize", "Set pet button size", 20, 36, 1)
	Window:CreateSlider("ActionBars", "ButtonSpacing", "Set button spacing", 0, 8, 1)

	Window:CreateSection("Font")
	Window:CreateDropdown("ActionBars", "Font", "Set actionbar font", "Font")
	Window:CreateDropdown("Cooldowns", "Font", "Set cooldown font", "Font")
end

local Auras = function(self)
	local Window = self:CreateWindow("Auras")

	Window:CreateSection("Enable")
	Window:CreateSwitch("Auras", "Enable", "Enable auras module")

	Window:CreateSection("Styling")
	Window:CreateSwitch("Auras", "Flash", "Flash auras at low duration")
	Window:CreateSwitch("Auras", "ClassicTimer", "Classic timer countdown")
	Window:CreateSwitch("Auras", "HideBuffs", "Hide buffs")
	Window:CreateSwitch("Auras", "HideDebuffs", "Hide debuffs")
	Window:CreateSwitch("Auras", "Animation", "Animate new auras")
	Window:CreateSlider("Auras", "BuffsPerRow", "Buffs per row", 6, 20, 1)

	Window:CreateSection("Font")
	Window:CreateDropdown("Auras", "Font", "Set aura font", "Font")
end

local Bags = function(self)
	local Window = self:CreateWindow("Bags")

	Window:CreateSection("Enable")
	Window:CreateSwitch("Bags", "Enable", "Enable bag module")

	Window:CreateSection("Sizing")
	Window:CreateSlider("Bags", "ButtonSize", "Set bag slot size", 20, 36, 1)
	Window:CreateSlider("Bags", "Spacing", "Set bag slot spacing", 0, 8, 1)
	Window:CreateSlider("Bags", "ItemsPerRow", "Set items per row", 8, 16, 1)
end

local Chat = function(self)
	local Window = self:CreateWindow("Chat")

	Window:CreateSection("Enable")
	Window:CreateSwitch("Chat", "Enable", "Enable chat module")
	Window:CreateSwitch("Chat", "WhisperSound", "Enable whisper sound")
	Window:CreateSwitch("Chat", "TextFading", "Fade the chat message after inactivity?")

	Window:CreateSection("Size [Tukui 18 theme only]")
	Window:CreateSlider("Chat", "LeftWidth", "Set left chat width", 300, 600, 10)
	Window:CreateSlider("Chat", "LeftHeight", "Set left chat height", 150, 600, 10)
	Window:CreateSlider("Chat", "RightWidth", "Set right chat width", 300, 600, 10)
	Window:CreateSlider("Chat", "RightHeight", "Set right chat height", 150, 600, 10)

	Window:CreateSection("Styling")
	Window:CreateSwitch("Chat", "ShortChannelName", "Shorten channel names")
	Window:CreateSlider("Chat", "ScrollByX", "Set lines to scroll", 1, 6, 1)
	Window:CreateSlider("Chat", "BackgroundAlpha", "Set chat background alpha", 40, 100, 1)
	Window:CreateSlider("Chat", "TextFadingTimer", "Timer that chat text should fade?", 10, 600, 10)
	Window:CreateSwitch("Chat", "LinkBrackets", "Display URL links in brackets")
	Window:CreateSwitch("Chat", "RightChatAlignRight", "Align text to right on second chat frame")
	Window:CreateColorSelection("Chat", "LinkColor", "Link color")

	Window:CreateSection("Font")
	Window:CreateDropdown("Chat", "ChatFont", "Set chat font", "Font")
	Window:CreateDropdown("Chat", "TabFont", "Set chat tab font", "Font")
end

local DataTexts = function(self)
	local Window = self:CreateWindow("DataTexts")

	Window:CreateSection("Enable")
	Window:CreateSwitch("DataTexts", "Battleground", "Enable battleground datatext")
	Window:CreateSwitch("DataTexts", "Hour24", "Switch time datatext to 24h mode")
	Window:CreateSwitch("DataTexts", "HideFriendsNotPlaying", "Hide friends currently not playing any games")

	Window:CreateSection("Color")
	Window:CreateColorSelection("DataTexts", "NameColor", "Name color")
	Window:CreateColorSelection("DataTexts", "ValueColor", "Value color")
	Window:CreateColorSelection("DataTexts", "HighlightColor", "Highlight color")
	Window:CreateSwitch("DataTexts", "ClassColor", "Color datatext by class (Overwrite Name/Value)")

	Window:CreateSection("Font")
	Window:CreateDropdown("DataTexts", "Font", "Set datatext font", "Font")
end

local Loot = function(self)
	local Window = self:CreateWindow("Loot")

	Window:CreateSection("Enable")
	Window:CreateSwitch("Loot", "Enable", "Enable loot module")

	Window:CreateSection("Font")
	Window:CreateDropdown("Loot", "Font", "Set loot font", "Font")
end

local Misc = function(self)
	local Window = self:CreateWindow("Misc")
				
	Window:CreateSection("Threat")
	Window:CreateSwitch("Misc", "ThreatBar", "Enable Threat Bar")
	Window:CreateSection("World Map")
	Window:CreateSwitch("Misc", "WorldMapEnable", "Enable our custom world map")
	Window:CreateSwitch("Misc", "FadeWorldMapWhileMoving", "Fade world map while moving?")
	Window:CreateSection("Experience and reputation")
	Window:CreateSwitch("Misc", "ExperienceEnable", "Enable experience and reputation bars")
	Window:CreateSection("UI Error filter")
	Window:CreateSwitch("Misc", "ErrorFilterEnable", "Enable error filter module")
	Window:CreateSection("Screensaver")
	Window:CreateSwitch("Misc", "AFKSaver", "Enable AFK screensaver")
	Window:CreateSection("Inventory")
	Window:CreateSwitch("Misc", "AutoSellJunk", "Sell junk automatically when visiting a vendor?")
	Window:CreateSwitch("Misc", "AutoRepair", "Auto repair your equipment when visiting a vendor?")
	Window:CreateSection("Objective Tracker")
	Window:CreateDropdown("Misc", "ObjectiveTrackerFont", "Set objective tracker font", "Font")
end

local NamePlates = function(self)
	local Window = self:CreateWindow("NamePlates")

	Window:CreateSection("Enable")
	Window:CreateSwitch("NamePlates", "Enable", "Enable nameplate module")
	Window:CreateSwitch("NamePlates", "NameplateCastBar", "Enable nameplate castbar")

	Window:CreateSection("Styling")
	Window:CreateSwitch("NamePlates", "OnlySelfDebuffs", "Display only our debuffs")
	Window:CreateColorSelection("NamePlates", "HighlightColor", "Highlight texture color")

	Window:CreateSection("Sizing")
	Window:CreateSlider("NamePlates", "Width", "Set nameplate width", 60, 200, 10)
	Window:CreateSlider("NamePlates", "Height", "Set nameplate height", 2, 20, 1)
	Window:CreateSlider("NamePlates", "HighlightSize", "Set nameplate highlight size", 5, 15, 1)

	Window:CreateSection("Font")
	Window:CreateDropdown("NamePlates", "Font", "Set nameplate font", "Font")
end

local Party = function(self)
	local Window = self:CreateWindow("Party")

	Window:CreateSection("Enable")
	Window:CreateSwitch("Party", "Enable", "Enable party module")
	Window:CreateSwitch("Party", "ShowPets", "Display Pets")

	Window:CreateSection("Styling")
	Window:CreateSwitch("Party", "ShowPlayer", "Display self in party")
	Window:CreateSlider("Party", "RangeAlpha", "Set out of range alpha", 0, 1, 0.1)
	Window:CreateSwitch("Party", "ShowHealthText", "Display health text values")
	Window:CreateSwitch("Party", "ShowManaText", "Display mana text values")
	Window:CreateColorSelection("Party", "HighlightColor", "Highlight texture color")
	Window:CreateSlider("Party", "HighlightSize", "Set nameplate highlight size", 5, 15, 1)

	Window:CreateSection("Font")
	Window:CreateDropdown("Party", "Font", "Set party font", "Font")
	Window:CreateDropdown("Party", "HealthFont", "Set party health font", "Font")
end

local Raid = function(self)
	local Window = self:CreateWindow("Raid")

	Window:CreateSection("Enable")
	Window:CreateSwitch("Raid", "Enable", "Enable raid module")
	Window:CreateSwitch("Raid", "ShowPets", "Enable raid module for pets")
	Window:CreateSwitch("Raid", "DebuffWatch", "Display dispellable debuffs")
	Window:CreateSwitch("Raid", "VerticalHealth", "Enable vertical health")
	Window:CreateSwitch("Raid", "DesaturateNonPlayerBuffs", "Displays other players buffs grayscaled")
	Window:CreateDropdown("Raid", "RaidBuffs", "Show buff on raid frames")
	Window:CreateDropdown("Raid", "GroupBy", "Set raid grouping")
	
	Window:CreateSection("Styling")
	Window:CreateSlider("Raid", "RangeAlpha", "Set out of range alpha", 0, 1, 0.1)
	Window:CreateSlider("Raid", "MaxUnitPerColumn", "Set max units per column", 1, 15, 1)
	Window:CreateSlider("Raid", "WidthSize", "Set raid unit width", 79, 150, 1)
	Window:CreateSlider("Raid", "HeightSize", "Set raid unit height", 45, 150, 1)
	Window:CreateColorSelection("Raid", "HighlightColor", "Highlight texture color")
	Window:CreateSlider("Raid", "HighlightSize", "Set raid unit highlight size", 5, 15, 1)

	Window:CreateSection("Font")
	Window:CreateDropdown("Raid", "Font", "Set raid font", "Font")
	Window:CreateDropdown("Raid", "HealthFont", "Set raid health font", "Font")
end

local Tooltips = function(self)
	local Window = self:CreateWindow("Tooltips")

	Window:CreateSection("Enable")
	Window:CreateSwitch("Tooltips", "Enable", "Enable tooltip module")
	Window:CreateSwitch("Tooltips", "UnitHealthText", "Enable unit health text")
	Window:CreateSwitch("Tooltips", "AlwaysCompareItems", "Always compare items")

	Window:CreateSection("Styling")
	Window:CreateSwitch("Tooltips", "HideInCombat", "Hide tooltip while in combat")
	Window:CreateSwitch("Tooltips", "MouseOver", "Display tooltips on the cursor")

	Window:CreateSection("Font")
	Window:CreateDropdown("Tooltips", "HealthFont", "Set tooltip health font", "Font")
end

local Textures = function(self)
	local Window = self:CreateWindow("Textures")

	Window:CreateSection("Unitframe")
	Window:CreateDropdown("Textures", "UFHealthTexture", "Unitframe health texture", "Texture")
	Window:CreateDropdown("Textures", "UFPowerTexture", "Unitframe power texture", "Texture")
	Window:CreateDropdown("Textures", "UFCastTexture", "Unitframe castbar texture", "Texture")

	Window:CreateSection("Party")
	Window:CreateDropdown("Textures", "UFPartyHealthTexture", "Party health texture", "Texture")
	Window:CreateDropdown("Textures", "UFPartyPowerTexture", "Party party texture", "Texture")

	Window:CreateSection("Raid")
	Window:CreateDropdown("Textures", "UFRaidHealthTexture", "Raid health texture", "Texture")
	Window:CreateDropdown("Textures", "UFRaidPowerTexture", "Raid power texture", "Texture")

	Window:CreateSection("Nameplates")
	Window:CreateDropdown("Textures", "NPHealthTexture", "Nameplate health texture", "Texture")
	Window:CreateDropdown("Textures", "NPPowerTexture", "Nameplate power texture", "Texture")
	Window:CreateDropdown("Textures", "NPCastTexture", "Nameplate castbar texture", "Texture")

	Window:CreateSection("Misc")
	Window:CreateDropdown("Textures", "QuestProgressTexture", "Quest progress texture", "Texture")
	Window:CreateDropdown("Textures", "TTHealthTexture", "Tooltip health texture", "Texture")
end

local UnitFrames = function(self)
	local Window = self:CreateWindow("UnitFrames")

	Window:CreateSection("Enable")
	Window:CreateSwitch("UnitFrames", "Enable", "Enable unitframe module")
	Window:CreateSwitch("UnitFrames", "OOCNameLevel", "Display my name/level while out of combat")
	Window:CreateSwitch("UnitFrames", "OOCPetNameLevel", "Display my pet name/level while out of combat")
	Window:CreateSwitch("UnitFrames", "ShowTargetManaText", "Display power text on target")
	Window:CreateSwitch("UnitFrames", "Portrait", "Enable unit portraits")
	Window:CreateSwitch("UnitFrames", "CastBar", "Enable castbar")
	Window:CreateSwitch("UnitFrames", "PowerTick", "Enable power ticks")
	Window:CreateSwitch("UnitFrames", "HealComm", "Enable HealComm")

	if T.MyClass == "SHAMAN" then
		Window:CreateSwitch("UnitFrames", "TotemBar", "Enable totem bar")
	end

	Window:CreateSection("Scrolling combat text")
	Window:CreateSwitch("UnitFrames", "ScrollingCombatText", "Enable scrolling combat text")
	Window:CreateSlider("UnitFrames", "ScrollingCombatTextFontSize", "Text size of scrolling", 10, 80, 1)
	Window:CreateDropdown("UnitFrames", "ScrollingCombatTextFont", "Set scrolling combat font", "Font")

	Window:CreateSection("Auras")
	Window:CreateSwitch("UnitFrames", "PlayerAuras", "Enable player auras")
	Window:CreateSwitch("UnitFrames", "PlayerAuraBars", "Enable player auras as status bars")
	Window:CreateSwitch("UnitFrames", "OnlySelfBuffs", "Display only our buffs on unitframes")
	Window:CreateSwitch("UnitFrames", "OnlySelfDebuffs", "Display only our debuffs on target")
	Window:CreateSwitch("UnitFrames", "TargetAuras", "Enable target auras")
	Window:CreateSwitch("UnitFrames", "TOTAuras", "Enable target of target auras")
	Window:CreateSwitch("UnitFrames", "PetAuras", "Enable pet auras")
	Window:CreateSwitch("UnitFrames", "AurasBelow", "Move auras below unitframes")

	Window:CreateSection("Styling")
	Window:CreateSlider("UnitFrames", "StatusBarBackgroundMultiplier", "Health and Power background opacity", 0, 100, 1)
	Window:CreateSwitch("UnitFrames", "UnlinkCastBar", "Unlink cast bars from unitframes")
	Window:CreateSwitch("UnitFrames", "CastBarIcon", "Display castbar spell icon")
	Window:CreateSwitch("UnitFrames", "CastBarLatency", "Display castbar latency")
	Window:CreateSwitch("UnitFrames", "ComboBar", "Enable combo point bar")
	Window:CreateSwitch("UnitFrames", "Smooth", "Enable smooth health transitions")
	Window:CreateSwitch("UnitFrames", "CombatLog", "Enable combat feedback text")
	Window:CreateSwitch("UnitFrames", "TargetEnemyHostileColor", "Enemy health bar colored by hostile reaction color")
	Window:CreateSwitch("UnitFrames", "Portrait2D", "Use 2D Portrait")
	Window:CreateDropdown("UnitFrames", "Font", "Set unitframe font", "Font")
	Window:CreateColorSelection("UnitFrames", "HealCommSelfColor", "HealComm - my heals")
	Window:CreateColorSelection("UnitFrames", "HealCommOtherColor", "HealComm - others heals")
	Window:CreateSlider("UnitFrames", "RaidIconSize", "Size of raid icons", 16, 32, 1)
end

GUI:AddWidgets(General)
GUI:AddWidgets(ActionBars)
GUI:AddWidgets(Auras)
GUI:AddWidgets(Bags)
GUI:AddWidgets(Chat)
GUI:AddWidgets(DataTexts)
GUI:AddWidgets(Loot)
GUI:AddWidgets(Misc)
GUI:AddWidgets(NamePlates)
GUI:AddWidgets(Party)
GUI:AddWidgets(Raid)
GUI:AddWidgets(Tooltips)
GUI:AddWidgets(Textures)
GUI:AddWidgets(UnitFrames)
