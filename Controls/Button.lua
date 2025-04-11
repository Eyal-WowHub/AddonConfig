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

    local label = ""
    local addSearchTags = false
    local options = template.options

    if options then
        label = options.label or ""
        addSearchTags = options.addSearchTags
    end

    local function click(...)
        template.click(template.__handler, ...)
    end

    local initializer = CreateSettingsButtonInitializer(
        label,
        template.name,
        click,
        template.tooltip,
        addSearchTags)

    template.__layout:AddInitializer(initializer)
end

lib:RegisterControl(Name, Version, Constructor)