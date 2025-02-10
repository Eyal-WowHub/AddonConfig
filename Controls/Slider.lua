local Name, Version = "slider", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetControlVersion(Name) >= Version then return end

local unpack = unpack

local Schema = {
    default = "number",
    get = "function",
    set = "function",
    options = "table"
}

local function Constructor(template)
    template:Validate(Schema)

    local parent = template:GetParentInfo()
    local setting = template:RegisterControlSetting()
    local options = Settings.CreateSliderOptions(
        template.options.min,
        template.options.max,
        template.options.steps)

    local label = template.options.label

    if label then
        local labelType, labelFormatter

        if type(label) == "table" then
            labelType, labelFormatter = unpack(label)
        else
            labelType = label
        end

        options:SetLabelFormatter(labelType, labelFormatter)
    end

    Settings.CreateSlider(parent.category, setting, options)
end

lib:RegisterControl(Name, Version, Constructor)