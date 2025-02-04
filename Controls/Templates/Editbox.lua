AddonConfigEditboxControlMixin = CreateFromMixins(SettingsControlMixin)

--[[ Label ]]

function AddonConfigEditboxControlMixin:SetLabel(value)
    if value and value ~= "" then
        self.Label:SetText(value)
        self.Label:Show()
        self.Editbox:SetPoint("TOPLEFT", self, "TOPLEFT", 7, -18)
        self:SetHeight(44)
    else
        self.Label:SetText("")
        self.Label:Hide()
        self.Editbox:SetPoint("TOPLEFT", self, "TOPLEFT", 7, 0)
        self:SetHeight(26)
    end
end

--[[ Button ]]

local function OnButtonClick(self)
    self.EditBox:ClearFocus()
    OnEnterPressed(self)
end

function AddonConfigEditboxControlMixin:HideButton()
    self.Button:Hide()
    self.Editobx:SetTextInsets(0, 0, 3, 3)
end

function AddonConfigEditboxControlMixin:ShowButton()
    if not self.__disabledButton then
        self.Button:Show()
        self.Editobx:SetTextInsets(0, 20, 3, 3)
    else
        self:HideButton()
    end
end

function AddonConfigEditboxControlMixin:DisableButton()
    self.__disabledButton = true
    self:HideButton()
end

function AddonConfigEditboxControlMixin:EnableButton()
    self.__disabledButton = false
    self:ShowButton()
end

--[[ EditBox ]]

local function OnTextChanged(self, text)
    if tostring(text) ~= tostring(self.__lastText) then
        self.__lastText = value
        self:ShowButton()
    end
end

local function OnEnterPressed(self)
    PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
    self:HideButton()
end

local function OnEscapePressed(self)
    self.Editbox:ClearFocus()
end

function AddonConfigEditboxControlMixin:SetText(value)
    self.__lastText = value or ""
    self.Editbox:SetText(value or "")
    self.Editbox:SetCursorPosition(0)
    self:HideButton()
end

function AddonConfigEditboxControlMixin:SetMaxLetters(value)
    self.Editbox:SetMaxLetters(value or 0)
end

function AddonConfigEditboxControlMixin:Disable()
    self.__disabled = true
    self.Editbox:EnableMouse(false)
    self.Editbox:ClearFocus()
    self.Editbox:SetTextColor(0.5, 0.5, 0.5)
    self.Label:SetTextColor(0.5, 0.5, 0.5)
end

function AddonConfigEditboxControlMixin:Enable()
    self.__disabled = false
    self.Editbox:EnableMouse(true)
    self.Editbox:SetTextColor(1, 1, 1)
    self.Label:SetTextColor(1, .82, 0)
end

function AddonConfigEditboxControlMixin:Default()
    self.Editbox:SetWidth(200)
    self:Enable()
    self:EnableButton()
    self:SetLabel()
    self:SetText()
    self:SetMaxLetters(0)
end

--[[ Bootstrapping ]]

function AddonConfigEditboxControlMixin:OnLoad()
    SettingsControlMixin.OnLoad(self)

    local editbox = CreateFrame("EditBox", nil, self, "InputBoxTemplate")
    self.Editbox = editbox
    editbox:SetAutoFocus(false)
    editbox:SetFontObject(ChatFontNormal)
    editbox:SetTextInsets(0, 0, 3, 3)
    editbox:SetMaxLetters(256)
    editbox:SetPoint("BOTTOMLEFT", 6, 0)
    editbox:SetPoint("BOTTOMRIGHT")
    editbox:SetHeight(19)

    editbox:SetScript("OnTextChanged", function(_, text)
        OnTextChanged(self, text)
        self:GetSetting():SetValue(text)
    end)

    editbox:SetScript("OnEnterPressed", function()
        OnEnterPressed(self)
    end)

    editbox:SetScript("OnEscapePressed", function()
        OnEscapePressed(self)
    end)

    local label = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    self.Label = label
    label:SetPoint("TOPLEFT", 0, -2)
    label:SetPoint("TOPRIGHT", 0, -2)
    label:SetJustifyH("LEFT")
    label:SetHeight(18)

    local button = CreateFrame("Button", nil, editbox, "UIPanelButtonTemplate")
    self.Button = button
    button:SetWidth(40)
    button:SetHeight(20)
    button:SetPoint("RIGHT", -2, 0)
    button:SetText(OKAY)
    button:Hide()

    button:SetScript("OnClick", function()
        OnButtonClick(self)
    end)

    self:Default()
end

function AddonConfigEditboxControlMixin:Init(initializer)
    SettingsControlMixin.Init(self, initializer)

    local options = initializer:GetOptions()

    if options then
        self.Editbox:SetMaxLetters(options.maxLetters)
        self.Editbox:SetLabel(options.label)
    end
end

function AddonConfigEditboxControlMixin:OnSettingValueChanged(setting, value)
    SettingsControlMixin.OnSettingValueChanged(self, setting, value)
end

function AddonConfigEditboxControlMixin:SetValue(value)
    self:SetText(value)
end

function AddonConfigEditboxControlMixin:Release()
    self.Editbox:SetScript("OnEnterPressed", nil)
    self.Editbox:SetScript("OnEscapePressed", nil)
    self.Editbox:SetScript("OnTextChanged", nil)
    self.Button:SetScript("OnClick", nil)
    SettingsControlMixin.Release(self)
end