local Name, Version = "dropdown", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetControlVersion(Name) >= Version then return end

local Schema = {
    get = "function",
    set = "function",
    tooltip = "string?",
    options = "table"
}

local function GetOptions(template)
    local container = Settings.CreateControlTextContainer()
    local value = template.default

    for index, option in ipairs(template.options) do
        local optionType = type(option)
        if optionType == "table" then
            value = value or option.value or index
            container:Add(option.value or index, option.text, option.tooltip)
        elseif optionType == "string" or optionType == "number" or optionType == "boolean" then
            value = value or index
            container:Add(index, option)
        end
    end

    if not template:HasVariableType() then
        template:SetVariableTypeByValue(value)
    end

    return container:GetData()
end

local function Constructor(template)
    template:Validate(Schema)

    local parent = template:GetParentInfo()
    local options = GetOptions(template)
    local setting = template:RegisterControlSetting()

	Settings.CreateDropdown(parent.category, setting, options, template.tooltip)
end

lib:RegisterControl(Name, Version, Constructor)