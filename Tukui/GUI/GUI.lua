local T, C, L = select(2, ...):unpack()

local sort = table.sort
local tinsert = table.insert
local unpack = unpack

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

GUI.SortMenuButtons = function(self)
	sort(self.Buttons, function(a, b)
		return a.Name < b.Name
	end)
	
	for i = 1, #self.Buttons do
		self.Buttons[i]:ClearAllPoints()
		
		if (i == 1) then
			self.Buttons[i]:Point("TOPLEFT", self.ButtonList, Spacing, -Spacing)
		else
			self.Buttons[i]:Point("TOP", self.Buttons[i-1], "BOTTOM", 0, -2)
		end
	end
end

GUI.CreateWindow = function(self, name)
	if self.Windows[name] then
		return
	end
	
	local Button = CreateFrame("Frame", nil, self)
	Button:Size(MenuButtonWidth, MenuButtonHeight)
	Button:Point("CENTER", UIParent, 0, 0)
	Button:SetTemplate()
	Button.Name = name
	
	tinsert(self.Buttons, Button)
	
	local Window = CreateFrame("Frame", nil, self)
	Window:Size(WidgetListWidth, WidgetListHeight)
	Window:Point("BOTTOMRIGHT", self, -Spacing, Spacing)
	Window:SetTemplate()
	Window:SetBackdropColor(unpack(LightColor))
	
	self.Windows[name] = Window
	
	SortMenuButtons()
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
	self.Header.Label:SetFontTemplate(Font, 14)
	self.Header.Label:SetText("|cffff8000Tukui|r settings")
	
	-- Button list
	self.ButtonList = CreateFrame("Frame", nil, self)
	self.ButtonList:Size(ButtonListWidth, ButtonListHeight)
	self.ButtonList:Point("BOTTOMLEFT", self, Spacing, Spacing)
	self.ButtonList:SetTemplate()
	self.Header:SetBackdropColor(unpack(LightColor))
	
	-- Widget list
	self.WidgetList = CreateFrame("Frame", nil, self)
	self.WidgetList:Size(WidgetListWidth, WidgetListHeight)
	self.WidgetList:Point("BOTTOMRIGHT", self, -Spacing, Spacing)
	self.WidgetList:SetTemplate()
	self.Header:SetBackdropColor(unpack(LightColor))
	
	self.Created = true
end

GUI.Toggle = function(self)
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

T.GUI = GUI -- Do we need a global name? This is all the access anyone would really need

-- /run Tukui[1].GUI:Toggle()