local Name, Version = "checkbox", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetControlVersion(Name) >= Version then return end

local Schema = {
    default = "boolean",
    get = "function",
    set = "function",
    tooltip = "string?"
}

local function Constructor(template)
    template:Validate(Schema)

    local parent = template:GetParentInfo()
    local setting = template:RegisterControlSetting()

    Settings.CreateCheckbox(parent.category, setting, template.tooltip)
end

lib:RegisterControl(Name, Version, Constructor)