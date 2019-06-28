--[[

Since WotLK, lots of peoples were using our API in multiples new UI.
However, lots of peoples edited it, and now there is too many deviated API.
This make addons/plugins authors a hard time to make their stuff compatibles
with every UIs when they want to use this API.

Starting with WoW Classic and WoW 9.0, Tukui staff will make an API toolkit for
everyone. Every developers who use our API is invited to participate for their need.

The library will be called UIToolkit (not set in stone for now) and will be available
to download at www.tukui.org/toolkit

--]]

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack
local type = type
local assert = assert
local getmetatable = getmetatable

-- WoW Globals
local CreateFrame = CreateFrame
local CreateTexture = CreateTexture
local UIFrameFadeOut = UIFrameFadeOut
local UIFrameFadeIn = UIFrameFadeIn

-- Locals
local Resolution = GetCVar("gxWindowedResolution")
local Noop = function() return end
local Toolkit = CreateFrame("Frame", "UIToolkit", UIParent)
local Tabs = {"LeftDisabled", "MiddleDisabled", "RightDisabled", "Left", "Middle", "Right"}

-- Tables
Toolkit.Settings = {}
Toolkit.API = {}
Toolkit.Functions = {}
Toolkit.Frames = {}

-- Toolkit Parameters
Toolkit.Settings.Mult = 768 / string.match(Resolution, "%d+x(%d+)") / GetCVar("uiScale")
Toolkit.Settings.DefaultTexture = "Interface\\Buttons\\WHITE8x8"
Toolkit.Settings.ShadowGlowTexture = ""
Toolkit.Settings.DefaultFont = "STANDARD_TEXT_FONT"
Toolkit.Settings.BackdropColor = { .1,.1,.1 }
Toolkit.Settings.BorderColor = { 0, 0, 0 }
Toolkit.Settings.ArrowUp = ""
Toolkit.Settings.ArrowDown = ""

----------------------------------------------------------------
-- API
----------------------------------------------------------------

-- Kills --

Toolkit.API.Kill = function(self)
	if (self.UnregisterAllEvents) then
		self:UnregisterAllEvents()
		self:SetParent(Hider)
	else
		self.Show = self.Hide
	end

	self:Hide()
end

Toolkit.API.StripTextures = function(self, Kill)
	for i = 1, self:GetNumRegions() do
		local Region = select(i, self:GetRegions())
		if (Region and Region:GetObjectType() == "Texture") then
			if (Kill and type(Kill) == "boolean") then
				Region:Kill()
			elseif (Region:GetDrawLayer() == Kill) then
				Region:SetTexture(nil)
			elseif (Kill and type(Kill) == "string" and Region:GetTexture() ~= Kill) then
				Region:SetTexture(nil)
			else
				Region:SetTexture(nil)
			end
		end
	end
end

-- Fading --

Toolkit.API.SetFadeInTemplate = function(self, FadeTime, Alpha)
	securecall(UIFrameFadeIn, self, FadeTime, self:GetAlpha(), Alpha)
end

Toolkit.API.SetFadeOutTemplate = function(self, FadeTime, Alpha)
	securecall(UIFrameFadeOut, self, FadeTime, self:GetAlpha(), Alpha)
end

-- Fonts --

Toolkit.API.SetFontTemplate = function(self, Font, FontSize, ShadowOffsetX, ShadowOffsetY)
	self:SetFont(Font, Toolkit.Functions.Scale(FontSize), "THINOUTLINE")
	self:SetShadowColor(0, 0, 0, 1)
	self:SetShadowOffset(Toolkit.Functions.Scale(ShadowOffsetX or 1), -Toolkit.Functions.Scale(ShadowOffsetY or 1))
end

-- Sizing & Pointing --

Toolkit.API.Size = function(self, WidthSize, HeightSize)
	self:SetSize(Toolkit.Functions.Scale(WidthSize), Toolkit.Functions.Scale(HeightSize or WidthSize))
end

Toolkit.API.Width = function(self, WidthSize)
	self:SetWidth(Toolkit.Functions.Scale(WidthSize))
end

Toolkit.API.Height = function(self, HeightSize)
	self:SetHeight(Toolkit.Functions.Scale(HeightSize))
end

Toolkit.API.Point = function(self, arg1, arg2, arg3, arg4, arg5)
	if arg2 == nil then
		arg2 = self:GetParent()
	end

	if type(arg1) == "number" then arg1 = Toolkit.Functions.Scale(arg1) end
	if type(arg2) == "number" then arg2 = Toolkit.Functions.Scale(arg2) end
	if type(arg3) == "number" then arg3 = Toolkit.Functions.Scale(arg3) end
	if type(arg4) == "number" then arg4 = Toolkit.Functions.Scale(arg4) end
	if type(arg5) == "number" then arg5 = Toolkit.Functions.Scale(arg5) end

	self:SetPoint(arg1, arg2, arg3, arg4, arg5)
end

Toolkit.API.SetOutside = function(self, Anchor, OffsetX, OffsetY)
	OffsetX = OffsetX or 1
	OffsetY = OffsetY or 1
	
	Anchor = Anchor or self:GetParent()

	if self:GetPoint() then
		self:ClearAllPoints()
	end

	self:Point("TOPLEFT", Anchor, "TOPLEFT", -OffsetX, OffsetY)
	self:Point("BOTTOMRIGHT", Anchor, "BOTTOMRIGHT", OffsetX, -OffsetY)
end

Toolkit.API.SetInside = function(self, Anchor, OffsetX, OffsetY)
	OffsetX = OffsetX or 1
	OffsetY = OffsetY or 1
	
	Anchor = Anchor or self:GetParent()

	if self:GetPoint() then
		self:ClearAllPoints()
	end

	self:Point("TOPLEFT", Anchor, "TOPLEFT", OffsetX, -OffsetY)
	self:Point("BOTTOMRIGHT", Anchor, "BOTTOMRIGHT", -OffsetX, OffsetY)
end

-- Borders & Backdrop --

Toolkit.API.SetTemplate = function(self, BackgroundTemplate, BackgroundTexture, BorderTemplate)
	if (self.BorderIsCreated) then
		return
	end
	
	local BackgroundAlpha = (BackgroundTemplate == "Transparent" and 0.8) or (1)
	local BorderR, BorderG, BorderB = unpack(Toolkit.Settings.BorderColor)
	local BackdropR, BackdropG, BackdropB = unpack(Toolkit.Settings.BackdropColor)
	
	self:SetBackdrop({bgFile = BackgroundTexture or Toolkit.Settings.DefaultTexture})
	self:SetBackdropColor(BackdropR, BackdropG, BackdropB, BackgroundAlpha)

	self.FrameRaised = CreateFrame("Frame", nil, self)
	self.FrameRaised:SetFrameLevel(self:GetFrameLevel() + 1)
	self.FrameRaised:SetAllPoints()

	self.BorderTop = self.FrameRaised:CreateTexture(nil, "OVERLAY")
	self.BorderTop:Size(1, 1)
	self.BorderTop:Point("TOPLEFT", self, "TOPLEFT", 0, 0)
	self.BorderTop:Point("TOPRIGHT", self, "TOPRIGHT", 0, 0)
	self.BorderTop:SetSnapToPixelGrid(false)
	self.BorderTop:SetTexelSnappingBias(0)
	
	self.BorderBottom = self.FrameRaised:CreateTexture(nil, "OVERLAY")
	self.BorderBottom:Size(1, 1)
	self.BorderBottom:Point("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
	self.BorderBottom:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	self.BorderBottom:SetSnapToPixelGrid(false)
	self.BorderBottom:SetTexelSnappingBias(0)

	self.BorderLeft = self.FrameRaised:CreateTexture(nil, "OVERLAY")
	self.BorderLeft:Size(1, 1)
	self.BorderLeft:Point("TOPLEFT", self, "TOPLEFT", 0, 0)
	self.BorderLeft:Point("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
	self.BorderLeft:SetSnapToPixelGrid(false)
	self.BorderLeft:SetTexelSnappingBias(0)

	self.BorderRight = self.FrameRaised:CreateTexture(nil, "OVERLAY")
	self.BorderRight:Size(1, 1)
	self.BorderRight:Point("TOPRIGHT", self, "TOPRIGHT", 0, 0)
	self.BorderRight:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	self.BorderRight:SetSnapToPixelGrid(false)
	self.BorderRight:SetTexelSnappingBias(0)
	
	self:SetBorderColor(BorderR, BorderG, BorderB, BorderA)
	
	if (BorderTemplate == "TRIPLE") then
		self.OutsideBorderTop = self.FrameRaised:CreateTexture(nil, "OVERLAY")
		self.OutsideBorderTop:Size(1, 1)
		self.OutsideBorderTop:Point("TOPLEFT", self, "TOPLEFT", -1, 1)
		self.OutsideBorderTop:Point("TOPRIGHT", self, "TOPRIGHT", 1, -1)
		self.OutsideBorderTop:SetSnapToPixelGrid(false)
		self.OutsideBorderTop:SetTexelSnappingBias(0)

		self.OutsideBorderBottom = self.FrameRaised:CreateTexture(nil, "OVERLAY")
		self.OutsideBorderBottom:Size(1, 1)
		self.OutsideBorderBottom:Point("BOTTOMLEFT", self, "BOTTOMLEFT", -1, -1)
		self.OutsideBorderBottom:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", 1, -1)
		self.OutsideBorderBottom:SetSnapToPixelGrid(false)
		self.OutsideBorderBottom:SetTexelSnappingBias(0)

		self.OutsideBorderLeft = self.FrameRaised:CreateTexture(nil, "OVERLAY")
		self.OutsideBorderLeft:Size(1, 1)
		self.OutsideBorderLeft:Point("TOPLEFT", self, "TOPLEFT", -1, 1)
		self.OutsideBorderLeft:Point("BOTTOMLEFT", self, "BOTTOMLEFT", 1, -1)
		self.OutsideBorderLeft:SetSnapToPixelGrid(false)
		self.OutsideBorderLeft:SetTexelSnappingBias(0)

		self.OutsideBorderRight = self.FrameRaised:CreateTexture(nil, "OVERLAY")
		self.OutsideBorderRight:Size(1, 1)
		self.OutsideBorderRight:Point("TOPRIGHT", self, "TOPRIGHT", 1, 1)
		self.OutsideBorderRight:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, -1)
		self.OutsideBorderRight:SetSnapToPixelGrid(false)
		self.OutsideBorderRight:SetTexelSnappingBias(0)

		self.InsideBorderTop = self.FrameRaised:CreateTexture(nil, "OVERLAY")
		self.InsideBorderTop:Size(1, 1)
		self.InsideBorderTop:Point("TOPLEFT", self, "TOPLEFT", 1, -1)
		self.InsideBorderTop:Point("TOPRIGHT", self, "TOPRIGHT", -1, 1)
		self.InsideBorderTop:SetSnapToPixelGrid(false)
		self.InsideBorderTop:SetTexelSnappingBias(0)

		self.InsideBorderBottom = self.FrameRaised:CreateTexture(nil, "OVERLAY")
		self.InsideBorderBottom:Size(1, 1)
		self.InsideBorderBottom:Point("BOTTOMLEFT", self, "BOTTOMLEFT", 1, 1)
		self.InsideBorderBottom:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
		self.InsideBorderBottom:SetSnapToPixelGrid(false)
		self.InsideBorderBottom:SetTexelSnappingBias(0)

		self.InsideBorderLeft = self.FrameRaised:CreateTexture(nil, "OVERLAY")
		self.InsideBorderLeft:Size(1, 1)
		self.InsideBorderLeft:Point("TOPLEFT", self, "TOPLEFT", 1, -1)
		self.InsideBorderLeft:Point("BOTTOMLEFT", self, "BOTTOMLEFT", -1, 1)
		self.InsideBorderLeft:SetSnapToPixelGrid(false)
		self.InsideBorderLeft:SetTexelSnappingBias(0)

		self.InsideBorderRight = self.FrameRaised:CreateTexture(nil, "OVERLAY")
		self.InsideBorderRight:Size(1, 1)
		self.InsideBorderRight:Point("TOPRIGHT", self, "TOPRIGHT", -1, -1)
		self.InsideBorderRight:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", 1, 1)
		self.InsideBorderRight:SetSnapToPixelGrid(false)
		self.InsideBorderRight:SetTexelSnappingBias(0)
		
		self.OutsideBorderTop:SetColorTexture(0, 0, 0, 1)
		self.OutsideBorderBottom:SetColorTexture(0, 0, 0, 1)
		self.OutsideBorderLeft:SetColorTexture(0, 0, 0, 1)
		self.OutsideBorderRight:SetColorTexture(0, 0, 0, 1)
		self.InsideBorderTop:SetColorTexture(0, 0, 0, 1)
		self.InsideBorderBottom:SetColorTexture(0, 0, 0, 1)
		self.InsideBorderLeft:SetColorTexture(0, 0, 0, 1)
		self.InsideBorderRight:SetColorTexture(0, 0, 0, 1)
	end
	
	self.BorderIsCreated = true
end

Toolkit.API.SetBorderColor = function(self, R, G, B, Alpha)
	self.BorderTop:SetColorTexture(R, G, B, Alpha)
	self.BorderBottom:SetColorTexture(R, G, B, Alpha)
	self.BorderRight:SetColorTexture(R, G, B, Alpha)
	self.BorderLeft:SetColorTexture(R, G, B, Alpha)
end

Toolkit.API.CreateBackdrop = function(self, Template, Texture)
	if self.Backdrop then
		return
	end

	local Level = (self:GetFrameLevel() - 1 >= 0 and self:GetFrameLevel() - 1) or (0)

	local Backdrop = CreateFrame("Frame", nil, self)
	Backdrop:SetOutside()
	Backdrop:SetTemplate(Template, Texture)
	Backdrop:SetFrameLevel(Level)

	self.Backdrop = Backdrop
end

Toolkit.API.CreateShadow = function(self, ShadowScale)
	if (self.Shadow) then
		return
	end

	local Level = (self:GetFrameLevel() - 1 >= 0 and self:GetFrameLevel() - 1) or (0)
	local Scale = ShadowScale or 1
	local Shadow = CreateFrame("Frame", nil, self)

	Shadow:SetBackdrop({edgeFile = Toolkit.Settings.ShadowGlowTexture, edgeSize = Toolkit.Functions.Scale(4)})
	Shadow:SetFrameStrata("BACKGROUND")
	Shadow:SetFrameLevel(Level)
	Shadow:SetOutside(self, 4, 4)
	Shadow:SetBackdropBorderColor(0, 0, 0, .8)
	Shadow:SetScale(Toolkit.Functions.Scale(Scale))
	
	self.Shadow = Shadow
end

Toolkit.API.CreateGlow = function(self, Scale, EdgeSize, R, G, B, Alpha)
	if (self.Glow) then
		return
	end

	local Level = (self:GetFrameLevel() - 1 >= 0 and self:GetFrameLevel() - 1) or (0)
	
	local Glow = CreateFrame("Frame", nil, self)
	Glow:SetFrameStrata("BACKGROUND")
	Glow:SetFrameLevel(Level)
	Glow:SetOutside(self, 4, 4)
	Glow:SetBackdrop({edgeFile = Toolkit.Settings.ShadowGlowTexture, edgeSize = Toolkit.Functions.Scale(EdgeSize)})
	Glow:SetScale(Toolkit.Functions.Scale(Scale))
	Glow:SetBackdropBorderColor(R, G, B, Alpha)

	self.Glow = Glow
end

-- Action Bars --

Toolkit.API.StyleButton = function(self)
	local Cooldown = self:GetName() and _G[self:GetName().."Cooldown"]
	
	if (self.SetHighlightTexture and not self.Highlight) then
		local Highlight = self:CreateTexture()
		
		Highlight:SetColorTexture(1, 1, 1, 0.3)
		Highlight:SetInside(self, 1, 1)
		Highlight:SetSnapToPixelGrid(false)
		Highlight:SetTexelSnappingBias(0)
		
		self.Highlight = Highlight
		self:SetHighlightTexture(Highlight)
	end

	if (self.SetPushedTexture and not self.Pushed) then
		local Pushed = self:CreateTexture()
		
		Pushed:SetColorTexture(0.9, 0.8, 0.1, 0.3)
		Pushed:SetInside(self, 1, 1)
		Pushed:SetSnapToPixelGrid(false)
		Pushed:SetTexelSnappingBias(0)
		
		self.Pushed = Pushed
		self:SetPushedTexture(Pushed)
	end

	if (self.SetCheckedTexture and not self.Checked) then
		local Checked = self:CreateTexture()
		
		Checked:SetColorTexture(0, 1, 0, 0.3)
		Checked:SetInside(self, 1, 1)
		Checked:SetSnapToPixelGrid(false)
		Checked:SetTexelSnappingBias(0)
		
		self.Checked = Checked
		self:SetCheckedTexture(Checked)
	end

	if (Cooldown) then
		Cooldown:ClearAllPoints()
		Cooldown:SetInside()
		Cooldown:SetDrawEdge(true)
	end
end

-- Skinning --

Toolkit.API.SkinButton = function(self, BackdropStyle, Shadows, Strip)
	-- Unskin everything
	if self.Left then self.Left:SetAlpha(0) end
	if self.Middle then self.Middle:SetAlpha(0) end
	if self.Right then self.Right:SetAlpha(0) end
	if self.TopLeft then self.TopLeft:SetAlpha(0) end
	if self.TopMiddle then self.TopMiddle:SetAlpha(0) end
	if self.TopRight then self.TopRight:SetAlpha(0) end
	if self.MiddleLeft then self.MiddleLeft:SetAlpha(0) end
	if self.MiddleMiddle then self.MiddleMiddle:SetAlpha(0) end
	if self.MiddleRight then self.MiddleRight:SetAlpha(0) end
	if self.BottomLeft then self.BottomLeft:SetAlpha(0) end
	if self.BottomMiddle then self.BottomMiddle:SetAlpha(0) end
	if self.BottomRight then self.BottomRight:SetAlpha(0) end
	if self.LeftSeparator then self.LeftSeparator:SetAlpha(0) end
	if self.RightSeparator then self.RightSeparator:SetAlpha(0) end
	if self.SetNormalTexture then self:SetNormalTexture("") end
	if self.SetHighlightTexture then self:SetHighlightTexture("") end
	if self.SetPushedTexture then self:SetPushedTexture("") end
	if self.SetDisabledTexture then self:SetDisabledTexture("") end
	if Strip then self:StripTexture() end
	
	-- Push our style
	self:SetTemplate(BackdropStyle)

	if (Shadows) then
		self:CreateShadow()
	end

	self:HookScript("OnEnter", function()
		local Color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

		self:SetBackdropColor(Color.r * .2, Color.g * .2, Color.b * .2)
		self:SetBorderColor(Color.r, Color.g, Color.b)
	end)

	self:HookScript("OnLeave", function()
		self:SetBackdropColor(Toolkit.Settings.BackdropColor[1], Toolkit.Settings.BackdropColor[2], Toolkit.Settings.BackdropColor[3], 1)
		self:SetBorderColor(Toolkit.Settings.BorderColor[1], Toolkit.Settings.BorderColor[2], Toolkit.Settings.BorderColor[3], 1)
	end)
end

Toolkit.API.SkinCloseButton = function(self, OffsetX, OffsetY, CloseSize)
	self:SetNormalTexture("")
	self:SetPushedTexture("")
	self:SetHighlightTexture("")
	self:SetDisabledTexture("")

	self.Text = self:CreateFontString(nil, "OVERLAY")
	self.Text:SetFont(Toolkit.Settings.DefaultFont, 12, "OUTLINE")
	self.Text:SetPoint("CENTER", 0, 1)
	self.Text:SetText("X")
	self.Text:SetTextColor(.5, .5, .5)
end

Toolkit.API.SkinEditBox = function(self)
	local Left = _G[self:GetName().."Left"]
	local Middle = _G[self:GetName().."Middle"]
	local Right = _G[self:GetName().."Right"]
	local Mid = _G[self:GetName().."Mid"]

	if Left then Left:Kill() end
	if Middle then Middle:Kill() end
	if Right then Right:Kill() end
	if Mid then Mid:Kill() end

	self:CreateBackdrop()

	if self:GetName() and self:GetName():find("Silver") or self:GetName():find("Copper") then
		self.Backdrop:Point("BOTTOMRIGHT", -12, -2)
	end
end

Toolkit.API.SkinArrowButton = function(self, Vertical)
	self:SetTemplate()
	self:Size(self:GetWidth() - 7, self:GetHeight() - 7)

	if Vertical then
		self:GetNormalTexture():SetTexCoord(0.3, 0.29, 0.3, 0.72, 0.65, 0.29, 0.65, 0.72)

		if self:GetPushedTexture() then
			self:GetPushedTexture():SetTexCoord(0.3, 0.35, 0.3, 0.8, 0.65, 0.35, 0.65, 0.8)
		end

		if self:GetDisabledTexture() then
			self:GetDisabledTexture():SetTexCoord(0.3, 0.29, 0.3, 0.75, 0.65, 0.29, 0.65, 0.75)
		end
	else
		self:GetNormalTexture():SetTexCoord(0.3, 0.29, 0.3, 0.81, 0.65, 0.29, 0.65, 0.81)

		if self:GetPushedTexture() then
			self:GetPushedTexture():SetTexCoord(0.3, 0.35, 0.3, 0.81, 0.65, 0.35, 0.65, 0.81)
		end

		if self:GetDisabledTexture() then
			self:GetDisabledTexture():SetTexCoord(0.3, 0.29, 0.3, 0.75, 0.65, 0.29, 0.65, 0.75)
		end
	end

	self:GetNormalTexture():ClearAllPoints()
	self:GetNormalTexture():SetInside()

	if self:GetDisabledTexture() then
		self:GetDisabledTexture():SetAllPoints(self:GetNormalTexture())
	end

	if self:GetPushedTexture() then
		self:GetPushedTexture():SetAllPoints(self:GetNormalTexture())
	end

	self:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.3)
	self:GetHighlightTexture():SetAllPoints(self:GetNormalTexture())
end

Toolkit.API.SkinDropDown = function(self, Width)
	local Button = _G[self:GetName().."Button"]
	local Text = _G[self:GetName().."Text"]

	self:StripTextures()
	self:Width(Width or 155)

	Text:ClearAllPoints()
	Text:Point("RIGHT", Button, "LEFT", -2, 0)

	Button:ClearAllPoints()
	Button:Point("RIGHT", self, "RIGHT", -10, 3)
	Button.SetPoint = Noop

	Button:SkinArrowButton(true)

	self:CreateBackdrop()
	self.Backdrop:Point("TOPLEFT", 20, -2)
	self.Backdrop:Point("BOTTOMRIGHT", Button, "BOTTOMRIGHT", 2, -2)
end

Toolkit.API.SkinCheckBox = function(self)
	self:StripTextures()
	self:CreateBackdrop()
	self.Backdrop:SetInside(self, 4, 4)

	if self.SetCheckedTexture then
		self:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	end

	if self.SetDisabledCheckedTexture then
		self:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	end

	-- why does the disabled texture is always displayed as checked ?
	self:HookScript("OnDisable", function(self)
		if not self.SetDisabledTexture then return end

		if self:GetChecked() then
			self:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
		else
			self:SetDisabledTexture("")
		end
	end)

	self.SetNormalTexture = Noop
	self.SetPushedTexture = Noop
	self.SetHighlightTexture = Noop
end

Toolkit.API.SkinTab = function(self)
	if (not self) then
		return
	end

	for _, object in pairs(Tabs) do
		local Texture = _G[self:GetName()..object]
		if (Texture) then
			Texture:SetTexture(nil)
		end
	end

	if self.GetHighlightTexture and self:GetHighlightTexture() then
		self:GetHighlightTexture():SetTexture(nil)
	else
		self:StripTextures()
	end

	self.Backdrop = CreateFrame("Frame", nil, self)
	self.Backdrop:SetTemplate()
	self.Backdrop:SetFrameLevel(self:GetFrameLevel() - 1)
	self.Backdrop:Point("TOPLEFT", 10, -3)
	self.Backdrop:Point("BOTTOMRIGHT", -10, 3)
end

Toolkit.API.SkinScrollBar = function(self)
	local ScrollUpButton = _G[self:GetName().."ScrollUpButton"]
	local ScrollDownButton = _G[self:GetName().."ScrollDownButton"]
	if _G[self:GetName().."BG"] then
		_G[self:GetName().."BG"]:SetTexture(nil)
	end

	if _G[self:GetName().."Track"] then
		_G[self:GetName().."Track"]:SetTexture(nil)
	end

	if _G[self:GetName().."Top"] then
		_G[self:GetName().."Top"]:SetTexture(nil)
	end

	if _G[self:GetName().."Bottom"] then
		_G[self:GetName().."Bottom"]:SetTexture(nil)
	end

	if _G[self:GetName().."Middle"] then
		_G[self:GetName().."Middle"]:SetTexture(nil)
	end

	if ScrollUpButton and ScrollDownButton then
		ScrollUpButton:StripTextures()
		ScrollUpButton:SetTemplate("Default", true)

		if not ScrollUpButton.texture then
			ScrollUpButton.texture = ScrollUpButton:CreateTexture(nil, "OVERLAY")
			ScrollUpButton.texture:Point("TOPLEFT", 2, -2)
			ScrollUpButton.texture:Point("BOTTOMRIGHT", -2, 2)
			ScrollUpButton.texture:SetTexture(Toolkit.Settings.ArrowUp)
			ScrollUpButton.texture:SetVertexColor(unpack(Toolkit.Settings.BorderColor))
		end

		ScrollDownButton:StripTextures()
		ScrollDownButton:SetTemplate("Default", true)

		if not ScrollDownButton.texture then
			ScrollDownButton.texture = ScrollDownButton:CreateTexture(nil, "OVERLAY")
			ScrollDownButton.texture:SetTexture(Toolkit.Settings.ArrowDown)
			ScrollDownButton.texture:SetVertexColor(unpack(Toolkit.Settings.BorderColor))
			ScrollDownButton.texture:Point("TOPLEFT", 2, -2)
			ScrollDownButton.texture:Point("BOTTOMRIGHT", -2, 2)
		end

		if not self.trackbg then
			self.trackbg = CreateFrame("Frame", nil, self)
			self.trackbg:Point("TOPLEFT", ScrollUpButton, "BOTTOMLEFT", 0, -1)
			self.trackbg:Point("BOTTOMRIGHT", ScrollDownButton, "TOPRIGHT", 0, 1)
			self.trackbg:SetTemplate("Transparent")
		end

		if self:GetThumbTexture() then
			--[[if not thumbTrim then -- This is a global lookup
				thumbTrim = 3
			end]]
			local thumbTrim = 3

			self:GetThumbTexture():SetTexture(nil)

			if not self.thumbbg then
				self.thumbbg = CreateFrame("Frame", nil, self)
				self.thumbbg:Point("TOPLEFT", self:GetThumbTexture(), "TOPLEFT", 2, -thumbTrim)
				self.thumbbg:Point("BOTTOMRIGHT", self:GetThumbTexture(), "BOTTOMRIGHT", -2, thumbTrim)
				self.thumbbg:SetTemplate("Default", true)

				if self.trackbg then
					self.thumbbg:SetFrameLevel(self.trackbg:GetFrameLevel())
				end
			end
		end
	end
end

---------------------------------------------------
-- Functions
---------------------------------------------------
		
Toolkit.Functions.Scale = function(x) 
	local Value = Toolkit.Settings.Mult * math.floor(x / Toolkit.Settings.Mult + .5)
		
	return Value
end

Toolkit.Functions.AddAPI = function(object)
	local mt = getmetatable(object).__index

	for API, FUNCTIONS in pairs(Toolkit.API) do
		if not object[API] then mt[API] = Toolkit.API[API] end
	end
end

Toolkit.Functions.AddFrames = function(self)
	-- Create an hidden frame for hiding stuff
	self.Frames.Hider = CreateFrame("Frame", nil, UIParent)
	self.Frames.Hider:Hide()
end

---------------------------------------------------
-- Toolkit init
---------------------------------------------------

Toolkit.Enable = function(self)
	local Handled = {["Frame"] = true}
	local Object = CreateFrame("Frame")
	local AddAPI = self.Functions.AddAPI
	local AddFrames = self.Functions.AddFrames
	
	AddAPI(Object)
	AddAPI(Object:CreateTexture())
	AddAPI(Object:CreateFontString())

	Object = EnumerateFrames()

	while Object do
		if not Object:IsForbidden() and not Handled[Object:GetObjectType()] then
			AddAPI(Object)
			
			Handled[Object:GetObjectType()] = true
		end

		Object = EnumerateFrames(Object)
	end
	
	AddFrames(self)
end