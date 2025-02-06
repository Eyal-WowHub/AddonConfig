local Name, Version = "dropdown", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetControlVersion(Name) >= Version then return end

local Schema = {
    default = "number",
    get = "function",
    set = "function",
    tooltip = "string?",
    options = "table"
}

local function GetOptions(template)
    local container = Settings.CreateControlTextContainer()

    for index, option in ipairs(template.options) do
        local optionType = type(option)
        if optionType == "table" then
            container:Add(index, option.text, option.tooltip)
        elseif optionType == "string" then
            container:Add(index, option)
        end
    end

    return container:GetData()
end

local function Constructor(template, parent)
    template:Validate(Schema)

    template.__varType = Settings.VarType.Number

    local category = parent:GetCategory()
    local setting = template:RegisterControlSetting()

	Settings.CreateDropdown(category, setting, GetOptions(template), template.tooltip)
end

lib:RegisterControl(Name, Version, Constructor)