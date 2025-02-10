--[[ Control API ]]

local Control = {}

local function OnEnterPressed(self)
    PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
    self:ClearFocus()
    self:HideButton()
end

local function OnEscapePressed(self)
    self:ClearFocus()
end

local function OnTextChanged(self)
    local value = self.Editbox:GetText()
    if self.validate and type(self.validate) == "function" then
        if not self.validate(value) then
            self:SetText(self.lastText)
            self:ClearFocus()
            return
        end
    end
    if tostring(value) ~= tostring(self.lastText) then
        self.lastText = value
        self.Setting:SetValue(value)
        self:ShowButton()
    end
end

function Control:ClearFocus()
    self.Editbox:ClearFocus()
end

function Control:HideButton()
    self.Button:Hide()
    self.Editbox:SetTextInsets(0, 0, 3, 3)
end

function Control:ShowButton()
    self.Button:Show()
    self.Editbox:SetTextInsets(0, 20, 3, 3)
end

function Control:SetText(value)
    self.lastText = value or ""
    self.Editbox:SetText(value or "")
    self.Editbox:SetCursorPosition(0)
    self:HideButton()
end

function Control:SetMaxLetters(value)
    self.Editbox:SetMaxLetters(value or 0)
end

function Control:Disable()
    self:SetText()
    self.Editbox:EnableMouse(false)
    self.Editbox:ClearFocus()
    self.Editbox:SetTextColor(0.5, 0.5, 0.5)
    self.Context:DisplayEnabled(false)
end

function Control:Enable()
    self.Editbox:EnableMouse(true)
    self.Editbox:SetTextColor(1, 1, 1)
    self.Context:DisplayEnabled(true)
end

function Control:SetDisabled(options)
    local disabled = options.disabled()

    if disabled then
        self:Disable()
    else
        self:Enable()
    end
end

function Control:SetLabel(value)
    if value and value ~= "" then
        self.Label:SetText(value)
        self.Label:Show()
    else
        self.Label:SetText("")
        self.Label:Hide()
    end
end

function Control:Default()
    self:SetText()
    self:Enable()
    self:SetMaxLetters()
end

function Control:Initialize(options)
    self:SetText(self.Setting:GetValue())

    self.Editbox:SetScript("OnTextChanged", self.OnTextChanged)
    self.Editbox:SetScript("OnEnterPressed", self.OnEnterPressed)
    self.Editbox:SetScript("OnEscapePressed", self.OnEscapePressed)
    self.Button:SetScript("OnClick", self.OnClick)

    if options then
        self:SetMaxLetters(options.maxLetters)
        self:SetLabel(options.label)

        self.validate = options.validate
        
        if options.disabled and type(options.disabled) == "function" then
            self:SetDisabled(options)
        
            EventRegistry:RegisterCallback("AddonConfig.ValueChanged", self.SetDisabled, self, options)
        end
    end
end

function Control:Release()
    self.Editbox:SetScript("OnTextChanged", nil)
    self.Editbox:SetScript("OnEnterPressed", nil)
    self.Editbox:SetScript("OnEscapePressed", nil)
    self.Button:SetScript("OnClick", nil)

    EventRegistry:UnregisterCallback("AddonConfig.ValueChanged", self.SetDisabled, self)
end

--[[ Control Implementation ]]

AddonConfigEditboxControlMixin = CreateFromMixins(SettingsControlMixin)

function AddonConfigEditboxControlMixin:OnLoad()
    SettingsControlMixin.OnLoad(self)

    self.Control = setmetatable({}, { __index = Control })
    self.Control.Context = self
    self.Control.Label = self.Text

    local editbox = CreateFrame("EditBox", nil, self, "InputBoxTemplate")
    self.Control.Editbox = editbox
    editbox:SetAutoFocus(false)
    editbox:SetTextInsets(0, 0, 3, 3)
    editbox:SetMaxLetters(256)
    editbox:SetPoint("CENTER", self, "CENTER", 27, 0)
    editbox:SetWidth(200)
    editbox:SetHeight(44)

    local button = CreateFrame("Button", nil, editbox, "UIPanelButtonTemplate")
    self.Control.Button = button
    button:SetWidth(40)
    button:SetHeight(20)
    button:SetPoint("RIGHT", -2, 0)
    button:SetText(OKAY)
    button:Hide()

    self.Control.OnTextChanged = function() OnTextChanged(self.Control) end
    self.Control.OnEnterPressed = function() OnEnterPressed(self.Control) end
    self.Control.OnEscapePressed = function() OnEscapePressed(self.Control) end
    self.Control.OnClick = function() OnEnterPressed(self.Control) end

    self.Tooltip:ClearAllPoints()
    self.Tooltip:Hide()

    self.Tooltip.HoverBackground:ClearAllPoints()
    self.Tooltip.HoverBackground:Hide()

    self.Control:Default()
end

function AddonConfigEditboxControlMixin:Init(initializer)
    SettingsControlMixin.Init(self, initializer)

    local control = self.Control
    control.Setting = self:GetSetting()

    local options = initializer:GetOptions()

    control:Initialize(options)
end

function AddonConfigEditboxControlMixin:OnSettingValueChanged(setting, value)
    SettingsControlMixin.OnSettingValueChanged(self, setting, value)
end

function AddonConfigEditboxControlMixin:Release()
    self.Control:Release()
    SettingsControlMixin.Release(self)
end