local Name, Version = "button", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetControlVersion(Name) >= Version then return end

local Schema = {
    click = "function",
    tooltip = "string?",
    options = "table?",
}

local function Constructor(template)
    template:Validate(Schema)

    local parent = template:GetParentInfo()
    local handler = parent.handler
    local label = ""
    local addSearchTags = false
    local options = template.options

    if options then
        label = options.label or ""
        addSearchTags = options.addSearchTags
    end

    local function click(...)
        template.click(handler, ...)
    end

    local initializer = CreateSettingsButtonInitializer(
        label,
        template.name,
        click,
        template.tooltip,
        addSearchTags)

    parent.layout:AddInitializer(initializer)
end

lib:RegisterControl(Name, Version, Constructor)