local Name, Version = "editbox", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetControlVersion(Name) >= Version then return end

local Schema = {
    get = "function",
    set = "function",
    options = "table?",
    validate = "function?"
}

local function Constructor(template)
    template:Validate(Schema)

    template.default = template.default or ""
    template.options = template.options or {}
    template.options.text = template.options.text or template.name
    template.options.validate = template.validate
    
    template:InitializeControl("AddonConfigEditboxControlTemplate")
end

lib:RegisterControl(Name, Version, Constructor)