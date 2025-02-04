local Type, Version = "editbox", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetControlVersion(Type) >= Version then return end

local Schema = {
    get = "function",
    set = "function",
    options = "table?",
    validate = "function?"
}

local function Constructor(template)
    template:Validate(Schema)

    template:InitializeControl("AddonConfigEditboxControlTemplate")
end

lib:RegisterType(Type, Version, Constructor)