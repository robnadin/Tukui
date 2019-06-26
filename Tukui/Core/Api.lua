local T, C, L = select(2, ...):unpack()

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
local Noop = function() return end
local Hider = CreateFrame("Frame", nil, UIParent)

-- UI Scaling
T.Mult = 768 / string.match(T.Resolution, "%d+x(%d+)") / GetCVar("uiScale")
T.Scale = function(x) return T.Mult * math.floor(x / T.Mult + .5) end

----------------------------------------------------------------
-- Kills
----------------------------------------------------------------

local function Kill(self)
	if (self.UnregisterAllEvents) then
		self:UnregisterAllEvents()
		self:SetParent(Hider)
	else
		self.Show = self.Hide
	end

	self:Hide()
end

local function StripTextures(self, Kill)
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

----------------------------------------------------------------
-- Fading
----------------------------------------------------------------

local function SetFadeInTemplate(self, FadeTime, Alpha)
	securecall(UIFrameFadeIn, self, FadeTime, self:GetAlpha(), Alpha)
end

local function SetFadeOutTemplate(self, FadeTime, Alpha)
	securecall(UIFrameFadeOut, self, FadeTime, self:GetAlpha(), Alpha)
end

----------------------------------------------------------------
-- Fonts
----------------------------------------------------------------

local function SetFontTemplate(self, Font, FontSize, ShadowOffsetX, ShadowOffsetY)
	self:SetFont(Font, T.Scale(FontSize), "THINOUTLINE")
	self:SetShadowColor(0, 0, 0, 1)
	self:SetShadowOffset(T.Scale(ShadowOffsetX or 1), -T.Scale(ShadowOffsetY or 1))
end

----------------------------------------------------------------
-- Sizing & Pointing
----------------------------------------------------------------

local function Size(self, WidthSize, HeightSize)
	self:SetSize(T.Scale(WidthSize), T.Scale(HeightSize or WidthSize))
end

local function Width(self, WidthSize)
	self:SetWidth(T.Scale(WidthSize))
end

local function Height(self, HeightSize)
	self:SetHeight(T.Scale(HeightSize))
end

local function Point(self, arg1, arg2, arg3, arg4, arg5)
	if arg2 == nil then
		arg2 = self:GetParent()
	end

	if type(arg1) == "number" then arg1 = T.Scale(arg1) end
	if type(arg2) == "number" then arg2 = T.Scale(arg2) end
	if type(arg3) == "number" then arg3 = T.Scale(arg3) end
	if type(arg4) == "number" then arg4 = T.Scale(arg4) end
	if type(arg5) == "number" then arg5 = T.Scale(arg5) end

	self:SetPoint(arg1, arg2, arg3, arg4, arg5)
end

local function SetOutside(self, Anchor, OffsetX, OffsetY)
	OffsetX = OffsetX or 1
	OffsetY = OffsetY or 1
	
	Anchor = Anchor or self:GetParent()

	if self:GetPoint() then
		self:ClearAllPoints()
	end

	self:Point("TOPLEFT", Anchor, "TOPLEFT", -OffsetX, OffsetY)
	self:Point("BOTTOMRIGHT", Anchor, "BOTTOMRIGHT", OffsetX, -OffsetY)
end

local function SetInside(self, Anchor, OffsetX, OffsetY)
	OffsetX = OffsetX or 1
	OffsetY = OffsetY or 1
	
	Anchor = Anchor or self:GetParent()

	if self:GetPoint() then
		self:ClearAllPoints()
	end

	self:Point("TOPLEFT", Anchor, "TOPLEFT", OffsetX, -OffsetY)
	self:Point("BOTTOMRIGHT", Anchor, "BOTTOMRIGHT", -OffsetX, OffsetY)
end

----------------------------------------------------------------
-- Borders & Backdrop
----------------------------------------------------------------

local function SetTemplate(self, Template, Texture)
	local BackgroundAlpha = (Template == "Transparent" and 0.8) or (1)

	local BorderR, BorderG, BorderB = unpack(C.General.BorderColor)
	local BackdropR, BackdropG, BackdropB = unpack(C.General.BackdropColor)
	local Texture = C.Medias.Blank

	self:SetBackdrop({bgFile = Texture or C.Medias.Blank, edgeFile = C.Medias.Blank, tile = false, tileSize = 0, edgeSize = T.Mult})
	self:SetBackdropColor(BackdropR, BackdropG, BackdropB, BackgroundAlpha)
	self:SetBackdropBorderColor(BorderR, BorderG, BorderB)
end

local function CreateBackdrop(self, Template, Texture)
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

local function CreateShadow(self, ShadowScale)
	if (self.Shadow) then
		return
	end

	local Level = (self:GetFrameLevel() - 1 >= 0 and self:GetFrameLevel() - 1) or (0)
	local Scale = ShadowScale or 1

	local Shadow = CreateFrame("Frame", nil, self)
	Shadow:SetFrameStrata("BACKGROUND")
	Shadow:SetFrameLevel(Level)
	Shadow:SetOutside(self, 4, 4)
	Shadow:SetBackdrop({edgeFile = C.Medias.Glow, edgeSize = T.Scale(4)})
	Shadow:SetBackdropBorderColor(0, 0, 0, .8)
	Shadow:SetScale(T.Scale(Scale))
	
	self.Shadow = Shadow
end

local function CreateGlow(self, Scale, EdgeSize, R, G, B, Alpha)
	if (self.Glow) then
		return
	end

	local Level = (self:GetFrameLevel() - 1 >= 0 and self:GetFrameLevel() - 1) or (0)
	
	local Glow = CreateFrame("Frame", nil, self)
	Glow:SetFrameStrata("BACKGROUND")
	Glow:SetFrameLevel(Level)
	Glow:SetOutside(self, 4, 4)
	Glow:SetBackdrop({edgeFile = C.Medias.Glow, edgeSize = T.Scale(EdgeSize)})
	Glow:SetScale(T.Scale(Scale))
	Glow:SetBackdropBorderColor(R, G, B, Alpha)

	self.Glow = Glow
end

----------------------------------------------------------------
-- Action Bars
----------------------------------------------------------------

local function StyleButton(self)
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

----------------------------------------------------------------
-- Skinning
----------------------------------------------------------------

local function SkinButton(self, BackdropStyle, Shadows, Strip)
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
		local Class = select(2, UnitClass("player"))
		local Color = T.Colors.class[Class]
		local R, G, B = Color[1], Color[2], Color[3]

		self:SetBackdropColor(R * .15, G * .15, B * .15)
		self:SetBackdropBorderColor(R, G, B)
	end)

	self:HookScript("OnLeave", function()
		self:SetBackdropColor(C.General.BackdropColor[1], C.General.BackdropColor[2], C.General.BackdropColor[3])
		self:SetBackdropBorderColor(C.General.BorderColor[1], C.General.BorderColor[2], C.General.BorderColor[3])
	end)
end

local function SkinCloseButton(self, OffsetX, OffsetY, CloseSize)
	self:SetNormalTexture("")
	self:SetPushedTexture("")
	self:SetHighlightTexture("")
	self:SetDisabledTexture("")

	self.Text = self:CreateFontString(nil, "OVERLAY")
	self.Text:SetFont(C.Medias.Font, 12, "OUTLINE")
	self.Text:SetPoint("CENTER", 0, 1)
	self.Text:SetText("X")
	self.Text:SetTextColor(.5, .5, .5)
end

local function SkinEditBox(self)
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

local function SkinArrowButton(self, Vertical)
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

local function SkinDropDown(self, Width)
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

local function SkinCheckBox(self)
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

local Tabs = {
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"Left",
	"Middle",
	"Right",
}

local function SkinTab(self)
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

local function SkinScrollBar(self)
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
			Point(ScrollUpButton.texture, "TOPLEFT", 2, -2)
			Point(ScrollUpButton.texture, "BOTTOMRIGHT", -2, 2)
			ScrollUpButton.texture:SetTexture([[Interface\AddOns\Tukui\Medias\Textures\Others\ArrowUp]])
			ScrollUpButton.texture:SetVertexColor(unpack(C.General.BorderColor))
		end

		ScrollDownButton:StripTextures()
		ScrollDownButton:SetTemplate("Default", true)

		if not ScrollDownButton.texture then
			ScrollDownButton.texture = ScrollDownButton:CreateTexture(nil, "OVERLAY")
			ScrollDownButton.texture:SetTexture([[Interface\AddOns\Tukui\Medias\Textures\Others\ArrowDown]])
			ScrollDownButton.texture:SetVertexColor(unpack(C.General.BorderColor))
			ScrollDownButton.texture:Point("TOPLEFT", 2, -2)
			ScrollDownButton.texture:Point("BOTTOMRIGHT", -2, 2)
		end

		if not self.trackbg then
			self.trackbg = CreateFrame("Frame", nil, self)
			Point(self.trackbg, "TOPLEFT", ScrollUpButton, "BOTTOMLEFT", 0, -1)
			Point(self.trackbg, "BOTTOMRIGHT", ScrollDownButton, "TOPRIGHT", 0, 1)
			SetTemplate(self.trackbg, "Transparent")
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
-- Do Magic!
---------------------------------------------------

local function AddAPI(object)
	local mt = getmetatable(object).__index

	if not object.SetFadeInTemplate then mt.SetFadeInTemplate = SetFadeInTemplate end
	if not object.SetFadeOutTemplate then mt.SetFadeOutTemplate = SetFadeOutTemplate end
	if not object.SetFontTemplate then mt.SetFontTemplate = SetFontTemplate end
	if not object.Size then mt.Size = Size end
	if not object.Point then mt.Point = Point end
	if not object.SetOutside then mt.SetOutside = SetOutside end
	if not object.SetInside then mt.SetInside = SetInside end
	if not object.SetTemplate then mt.SetTemplate = SetTemplate end
	if not object.CreateBackdrop then mt.CreateBackdrop = CreateBackdrop end
	if not object.StripTextures then mt.StripTextures = StripTextures end
	if not object.CreateShadow then mt.CreateShadow = CreateShadow end
	if not object.Kill then mt.Kill = Kill end
	if not object.StyleButton then mt.StyleButton = StyleButton end
	if not object.Width then mt.Width = Width end
	if not object.Height then mt.Height = Height end
	if not object.SkinEditBox then mt.SkinEditBox = SkinEditBox end
	if not object.SkinButton then mt.SkinButton = SkinButton end
	if not object.SkinCloseButton then mt.SkinCloseButton = SkinCloseButton end
	if not object.SkinArrowButton then mt.SkinArrowButton = SkinArrowButton end
	if not object.SkinDropDown then mt.SkinDropDown = SkinDropDown end
	if not object.SkinCheckBox then mt.SkinCheckBox = SkinCheckBox end
	if not object.SkinTab then mt.SkinTab = SkinTab end
	if not object.SkinScrollBar then mt.SkinScrollBar = SkinScrollBar end
end

local Handled = {["Frame"] = true}

local Object = CreateFrame("Frame")
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

Hider:Hide()

T.Hider = Hider