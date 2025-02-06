local Name, Version = "checkbox", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetControlVersion(Name) >= Version then return end

local Schema = {
    default = "boolean",
    get = "function",
    set = "function",
    tooltip = "string?"
}

local function Constructor(template, parent)
    template:Validate(Schema)

    template.__varType = Settings.VarType.Boolean

    local category = parent:GetCategory()
    local setting = template:RegisterControlSetting()

	Settings.CreateCheckbox(category, setting, template.tooltip)
end

lib:RegisterControl(Name, Version, Constructor)