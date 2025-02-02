local Type, Version = "slider", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetControlVersion(Type) >= Version then return end

local unpack = unpack

local Schema = {
    default = "number",
    get = "function",
    set = "function",
    label = "table?",
    options = "table"
}

local function Constructor(template, parent)
    template:Validate(Schema)

    template.__varType = Settings.VarType.Number

    local category = parent:GetCategory()
    local setting = template:RegisterControlSetting()
    local options = Settings.CreateSliderOptions(unpack(template.options))

    if template.label then
        local labelType, labelFormatter = unpack(template.label)
        options:SetLabelFormatter(labelType, labelFormatter)
    end

    Settings.CreateSlider(category, setting, options)
end

lib:RegisterType(Type, Version, Constructor)