local Name, Version = "button", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetControlVersion(Name) >= Version then return end

local Schema = {
    addSearchTags = "boolean?",
    click = "function",
    tooltip = "string?"
}

local function Constructor(template, parent)
    template:Validate(Schema)

    local layout = parent:GetLayout()
    local handler = parent and parent.handler
    local addSearchTags = false
    
    local function click(...)
        template.click(handler, ...)
    end

    if template.tag then
        addSearchTags = true
    end

    local initializer = CreateSettingsButtonInitializer(
        template.tag,
        template.name,
        click,
        template.tooltip,
        addSearchTags)

    layout:AddInitializer(initializer)
end

lib:RegisterControl(Name, Version, Constructor)