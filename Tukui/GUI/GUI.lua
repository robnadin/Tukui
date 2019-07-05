local T, C, L = select(2, ...):unpack()

-- /run Tukui[1].GUI:Toggle() -- Try me!

local sort = table.sort
local tinsert = table.insert
local tremove = table.remove
local unpack = unpack
local pairs = pairs
local type = type

--[[
	Note: I'm going to be laying out a bunch of basics here, don't worry too much yet about how things look.
	I'll refine as the process goes on.
	
	To do:
	Create widgets
	Global/PerChar settings
	
	Widget list:
	checkbox(?)
	switch
	slider
	dropdown (for textures, fonts, and misc)
]]

local Font = C.Medias.Font
local Texture = C.Medias.Normal

local LightColor = {0.175, 0.175, 0.175}
local BrightColor = {0.35, 0.35, 0.35}

-- You can switch this, I just don't know what kind of colors you want to be using, so I picked something.
local Color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
local R, G, B = Color.r, Color.g, Color.b

local Realm = GetRealmName()
local Name = UnitName("Player")

local WindowWidth = 480
local WindowHeight = 360

local Spacing = 4

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
	C[group][option] = value
	
	local Settings
	
	if TukuiConfigPerAccount then -- NYI
		Settings = TukuiSettings
	else
		Settings = TukuiSettingsPerChar
	end
	
	if (not Settings[group]) then
		Settings[group] = {}
	end
	
	Settings[group][option] = value
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
	
	local Switch = CreateFrame("Frame", nil, self)
	Switch:Size(SwitchWidth, WidgetHeight)
	Switch:SetTemplate(nil, Texture)
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
	Switch.TrackTexture:Point("BOTTOMRIGHT", Switch.Thumb, 0, 1)
	Switch.TrackTexture:SetTexture(Texture)
	Switch.TrackTexture:SetVertexColor(R, G, B)
	
	Switch.Label = Switch:CreateFontString(nil, "OVERLAY")
	Switch.Label:Point("LEFT", Switch, "RIGHT", Spacing, 0)
	Switch.Label:SetFontTemplate(Font, 12)
	Switch.Label:SetText(text)
	
	if Value then
		Switch.Thumb:Point("RIGHT", Switch, 0, 0)
	else
		Switch.Thumb:Point("LEFT", Switch, 0, 0)
	end
	
	tinsert(self.Widgets, Switch)
	
	return Switch
end

GUI.Widgets.CreateSwitch = CreateSwitch

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
			self.Widgets[i]:Point("TOPLEFT", self.Widgets[i-1], "BOTTOMLEFT", 0, -Spacing)
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
	
	local Button = CreateFrame("Frame", nil, self.ButtonList)
	Button:Size(MenuButtonWidth, MenuButtonHeight)
	Button:SetTemplate()
	Button:SetScript("OnMouseUp", MenuButtonOnMouseUp)
	Button:SetScript("OnEnter", MenuButtonOnEnter)
	Button:SetScript("OnLeave", MenuButtonOnLeave)
	Button.Name = name
	Button.Parent = self
	
	Button.Label = Button:CreateFontString(nil, "OVERLAY")
	Button.Label:Point("CENTER", Button, 0, 0)
	Button.Label:SetFontTemplate(Font, 14)
	Button.Label:SetText(name)
	
	Button.Highlight = Button:CreateTexture(nil, "OVERLAY")
	Button.Highlight:SetAllPoints()
	Button.Highlight:SetTexture(Texture)
	Button.Highlight:SetVertexColor(0.3, 0.3, 0.3, 0.3)
	Button.Highlight:Hide()
	
	tinsert(self.Buttons, Button)
	
	local Window = CreateFrame("Frame", nil, self.WindowParent)
	Window:Size(WidgetListWidth, WidgetListHeight)
	Window:Point("CENTER", self.WindowParent, 0, 0)
	Window:SetTemplate()
	Window:SetBackdropColor(unpack(LightColor))
	Window.Widgets = {}
	Window:Hide()
	
	self.Windows[name] = Window
	
	for key, func in pairs(self.Widgets) do
		Window[key] = func
	end
	
	if default then
		self.DefaultWindow = name
	end
	
	self:SortMenuButtons()
	
	return Window
end

GUI.Create = function(self)
	-- Main Window
	self:Size(WindowWidth, WindowHeight)
	self:Point("CENTER", UIParent, 0, 0)
	self:SetTemplate()
	self:SetAlpha(0)
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
	self.Header.Label:SetFontTemplate(Font, 16)
	self.Header.Label:SetText("|cffff8000Tukui|r settings")
	
	-- Button list
	self.ButtonList = CreateFrame("Frame", nil, self)
	self.ButtonList:Size(ButtonListWidth, ButtonListHeight)
	self.ButtonList:Point("BOTTOMLEFT", self, Spacing, Spacing)
	self.ButtonList:SetTemplate()
	self.ButtonList:SetBackdropColor(unpack(LightColor))
	
	-- Widget list
	self.WindowParent = CreateFrame("Frame", nil, self)
	self.WindowParent:Size(WidgetListWidth, WidgetListHeight)
	self.WindowParent:Point("BOTTOMRIGHT", self, -Spacing, Spacing)
	--self.WindowParent:SetTemplate()
	--self.WindowParent:SetBackdropColor(unpack(LightColor))
	
	self:UnpackQueue()
	
	if self.DefaultWindow then
		self:DisplayWindow(self.DefaultWindow)
	end
	
	local Button = CreateFrame("Frame", nil, self.ButtonList)
	Button:Size(MenuButtonWidth, MenuButtonHeight)
	Button:Point("BOTTOM", self.ButtonList, 0, Spacing)
	Button:SetTemplate()
	Button:SetScript("OnMouseUp", ReloadUI)
	Button:SetScript("OnEnter", MenuButtonOnEnter)
	Button:SetScript("OnLeave", MenuButtonOnLeave)
	
	Button.Label = Button:CreateFontString(nil, "OVERLAY")
	Button.Label:Point("CENTER", Button, 0, 0)
	Button.Label:SetFontTemplate(Font, 14)
	Button.Label:SetText("Apply")
	
	Button.Highlight = Button:CreateTexture(nil, "OVERLAY")
	Button.Highlight:SetAllPoints()
	Button.Highlight:SetTexture(Texture)
	Button.Highlight:SetVertexColor(0.3, 0.3, 0.3, 0.3)
	Button.Highlight:Hide()
	
	self.Created = true
end

GUI.Toggle = function(self)
	if InCombatLockdown() then
		return
	end
	
	if (not self.Created) then
		self:Create()
	end
	
	if self:IsShown() then
		self.FadeOut:Play()
	else
		self:Show()
		self.FadeIn:Play()
	end
end

GUI.VARIABLES_LOADED = function(self, event)
	self:UnregisterEvent(event)
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

GUI:RegisterEvent("VARIABLES_LOADED")
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

local Options = function(self)
	self:CreateWindow("General")
	self:CreateWindow("Tooltips")
	self:CreateWindow("Actionbars")
	self:CreateWindow("Minimap")
	self:CreateWindow("UnitFrames")
end

GUI:AddWidgets(Options)

-- More real example
GUI:AddWidgets(function(self)
	local TestWindow = self:CreateWindow("Test", true)
	
	local Switch = TestWindow:CreateSwitch("ActionBars", "Enable", "Enable Actionbars")
end)