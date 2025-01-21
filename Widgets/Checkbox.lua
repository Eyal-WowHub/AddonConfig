local Type, Version = "checkbox", 1
local lib = LibStub and LibStub("SettingsGenerator-1.0", true)
if not lib or lib:GetWidgetVersion(Type) >= Version then return end

local Schema = {
    default = "number",
    disabled = "function?",
    get = "function",
    set = "function",
    tooltip = "string?",
    var = "table"
}

local function Constructor(template, parent)
    template:Validate(Schema)

    local category = parent:GetCategory()
    local varName, varType = unpack(template.var)

    local setting = Settings.RegisterProxySetting(
        category,
        varName,
        varType,
        template.name,
        template.default,
        template.get,
        template.set)

	Settings.CreateCheckbox(category, setting, template.tooltip)
end

lib:RegisterType(Type, Version, Constructor)