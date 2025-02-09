AddonConfigEditboxControlMixin = CreateFromMixins(SettingsControlMixin)

--[[ Control ]]

local function HideButton(self)
    self.Button:Hide()
    self.Editbox:SetTextInsets(0, 0, 3, 3)
end

local function ShowButton(self)
    if not self.__disabledButton then
        self.Button:Show()
        self.Editbox:SetTextInsets(0, 20, 3, 3)
    else
        HideButton(self)
    end
end

local function OnEnterPressed(self)
    PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
    self.Editbox:ClearFocus()
    HideButton(self)
end

local function OnEscapePressed(self)
    self.Editbox:ClearFocus()
end

local function OnTextChanged(self)
    local text = self.Editbox:GetText()
    if tostring(text) ~= tostring(self.__lastText) then
        self.__lastText = text
        self:GetSetting():SetValue(text)
        ShowButton(self)
    end
end

local function SetText(self, value)
    self.__lastText = value or ""
    self.Editbox:SetText(value or "")
    self.Editbox:SetCursorPosition(0)
    HideButton(self)
end

local function SetMaxLetters(self, value)
    self.Editbox:SetMaxLetters(value or 0)
end

local function Disable(self)
    SetText(self)
    self.Editbox:EnableMouse(false)
    self.Editbox:ClearFocus()
    self.Editbox:SetTextColor(0.5, 0.5, 0.5)
    self:DisplayEnabled(false)
end

local function Enable(self)
    self.Editbox:EnableMouse(true)
    self.Editbox:SetTextColor(1, 1, 1)
    self:DisplayEnabled(true)
end

local function SetLabel(self, value)
    if value and value ~= "" then
        self.Text:SetText(value)
        self.Text:Show()
    else
        self.Text:SetText("")
        self.Text:Hide()
    end
end

local function Default(self)
    SetText(self)
    Enable(self)
    SetMaxLetters(self)
end

--[[ Bootstrapping ]]

function AddonConfigEditboxControlMixin:OnLoad()
    SettingsControlMixin.OnLoad(self)

    self.Tooltip:ClearAllPoints()
    self.Tooltip:Hide()

    self.Tooltip.HoverBackground:ClearAllPoints()
    self.Tooltip.HoverBackground:Hide()

    local editbox = CreateFrame("EditBox", nil, self, "InputBoxTemplate")
    self.Editbox = editbox
    editbox:SetAutoFocus(false)
    editbox:SetTextInsets(0, 0, 3, 3)
    editbox:SetMaxLetters(256)
    editbox:SetPoint("CENTER", self, "CENTER", 27, 0)
    editbox:SetWidth(200)
    editbox:SetHeight(44)
    editbox:SetScript("OnTextChanged", function(_) OnTextChanged(self) end)
    editbox:SetScript("OnEnterPressed", function(_) OnEnterPressed(self) end)
    editbox:SetScript("OnEscapePressed", function(_) OnEscapePressed(self) end)

    local button = CreateFrame("Button", nil, editbox, "UIPanelButtonTemplate")
    self.Button = button
    button:SetWidth(40)
    button:SetHeight(20)
    button:SetPoint("RIGHT", -2, 0)
    button:SetText(OKAY)
    button:Hide()
    button:SetScript("OnClick", function(_) OnEnterPressed(self) end)

    Default(self)
end

function AddonConfigEditboxControlMixin:Init(initializer)
    SettingsControlMixin.Init(self, initializer)

    local setting = self:GetSetting()
    local options = initializer:GetOptions()

    SetText(self, setting:GetValue())

    if options then
        SetMaxLetters(self, options.maxLetters)
        SetLabel(self, options.text)
        
        if options.disabled and type(options.disabled) == "function" then
            local function onValueChanged()
                local disabled = options.disabled()

                if disabled then
                    Disable(self)
                else
                    Enable(self)
                end
            end
        
            onValueChanged()
        
            EventRegistry:RegisterCallback("AddonConfig.ValueChanged", onValueChanged)
        end
    end
end

function AddonConfigEditboxControlMixin:OnSettingValueChanged(setting, value)
    SettingsControlMixin.OnSettingValueChanged(self, setting, value)
end

function AddonConfigEditboxControlMixin:Release()
    self.Editbox:SetScript("OnEnterPressed", nil)
    self.Editbox:SetScript("OnEscapePressed", nil)
    self.Editbox:SetScript("OnTextChanged", nil)
    self.Button:SetScript("OnClick", nil)
    SettingsControlMixin.Release(self)
end