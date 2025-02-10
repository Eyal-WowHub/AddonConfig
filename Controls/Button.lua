local Name, Version = "button", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetControlVersion(Name) >= Version then return end

local Schema = {
    addSearchTags = "boolean?",
    click = "function",
    tooltip = "string?"
}

local function Constructor(template)
    template:Validate(Schema)

    local parent = template:GetParentInfo()
    local handler = parent.handler

    local function click(...)
        template.click(handler, ...)
    end

    local addSearchTags = false

    if template.tag then
        addSearchTags = true
    end

    local initializer = CreateSettingsButtonInitializer(
        template.tag,
        template.name,
        click,
        template.tooltip,
        addSearchTags)

    parent.layout:AddInitializer(initializer)
end

lib:RegisterControl(Name, Version, Constructor)