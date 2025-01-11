local Type, Version = "slider", 1
local lib = LibStub and LibStub("SettingsGenerator-1.0", true)
if not lib or lib:GetWidgetVersion(Type) >= Version then return end

local unpack = unpack

local Schema = {
    var = "table",
    default = "number",
    min = "number",
    max = "number",
    steps = "number",
    get = "function",
    set = "function",
    label = "table?"
}

local function Constructor(template, parent)
    template:Validate(Schema)

    local category = parent:GetCategory()
    local varName, varType = unpack(template.var)

    local sliderSettings = Settings.RegisterProxySetting(
        category,
        varName,
        varType,
        template.name,
        template.default,
        template.get,
        template.set)

    local sliderOptions = Settings.CreateSliderOptions(
        template.min, 
        template.max, 
        template.steps)

    if template.label then
        local labelType, labelFormatter = unpack(template.label)
        sliderOptions:SetLabelFormatter(labelType, labelFormatter)
    end

    Settings.CreateSlider(category, sliderSettings, sliderOptions)
end

lib:RegisterType(Type, Version, Constructor)