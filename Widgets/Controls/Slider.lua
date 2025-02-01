local Type, Version = "slider", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetWidgetVersion(Type) >= Version then return end

local unpack = unpack

local Schema = {
    default = "number",
    disabled = "function?",
    label = "table?",
    max = "number",
    min = "number",
    get = "function",
    set = "function",
    steps = "number",
    var = "table"
}

local function Constructor(template, parent)
    template:Validate(Schema)

    local category = parent:GetCategory()
    local varName, varType = unpack(template.var)

    local setting = Settings.RegisterProxySetting(
        category,
        varName,
        varType,
        template.name,
        template.default,
        template.get,
        template.set)

    local options = Settings.CreateSliderOptions(
        template.min, 
        template.max, 
        template.steps)

    if template.label then
        local labelType, labelFormatter = unpack(template.label)
        options:SetLabelFormatter(labelType, labelFormatter)
    end

    Settings.CreateSlider(category, setting, options)
end

lib:RegisterType(Type, Version, Constructor)