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
	GUI initialization
	Create widgets
	
	Widget list:
	checkbox(?)
	switch
	slider
	dropdown (for textures, fonts, and misc)
]]

local Font = C.Medias.Font
local Texture = C.Medias.Normal

local LightColor = {0.175, 0.175, 0.175}

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

local GUI = CreateFrame("Frame", nil, UIParent) -- Feel free to give a global name, It's available as T.GUI right now
GUI.Windows = {}
GUI.Buttons = {}
GUI.Queue = {}
GUI.Widgets = {}

GUI.AddOptions = function(self, func)
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

GUI.DisplayWindow = function(self, name)
	for WindowName, Window in pairs(self.Windows) do
		if (WindowName ~= name) then
			Window:Hide()
		else
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

GUI.CreateWindow = function(self, name)
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
	
	self.Windows[name] = Window
	
	self:SortMenuButtons()
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
	self.WindowParent:SetTemplate()
	self.WindowParent:SetBackdropColor(unpack(LightColor))
	
	self:UnpackQueue()
	
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
	self:CreateWindow("UnitFrames")
	self:CreateWindow("Party")
	self:CreateWindow("Raid")
end

GUI:AddOptions(Options)