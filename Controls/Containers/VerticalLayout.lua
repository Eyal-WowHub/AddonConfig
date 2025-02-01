local Type, Version = "vertical-layout", 1
local lib = LibStub and LibStub("AddonConfig-1.0", true)
if not lib or lib:GetControlVersion(Type) >= Version then return end

local function Constructor(template, parent)
    if not parent then
        local category = Settings.RegisterVerticalLayoutCategory(template.name)

        template:RegisterCategory(category)

        Settings.RegisterAddOnCategory(category)
    else
        local subCategory, layout = Settings.RegisterVerticalLayoutSubcategory(parent:GetCategory(), template.name)

        template:RegisterCategory(subCategory, layout)
    end
end

lib:RegisterType(Type, Version, Constructor)