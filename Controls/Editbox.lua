local Type, Version = "editbox", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetControlVersion(Type) >= Version then return end

local Schema = {
    get = "function",
    set = "function",
    validate = "function?"
}

local function Constructor(template, parent)
    template:Validate(Schema)

    local initializer = template:CreateControlWithOptions("AddonConfigEditboxControlTemplate", template)

    layout:AddInitializer(initializer)
end

lib:RegisterType(Type, Version, Constructor)