local Type, Version = "button", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetWidgetVersion(Type) >= Version then return end

local Schema = {
    addSearchTags = "boolean?",
    click = "function",
    disabled = "function?",
    tooltip = "string?"
}

local function Constructor(template, parent)
    template:Validate(Schema)

    local layout = parent:GetLayout()
    local addSearchTags = false

    if template.tag then
        addSearchTags = true
    end

    local initializer = CreateSettingsButtonInitializer(
        template.tag,
        template.name,
        template.click,
        template.tooltip,
        addSearchTags)

    layout:AddInitializer(initializer)
end

lib:RegisterType(Type, Version, Constructor)