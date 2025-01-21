local Type, Version = "dropdown", 1
local lib = LibStub and LibStub("SettingsGenerator-1.0", true)
if not lib or lib:GetWidgetVersion(Type) >= Version then return end

local Schema = {
    default = "number",
    disabled = "function?",
    get = "function",
    options = "table",
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

    local function GetOptions()
        local container = Settings.CreateControlTextContainer()

        for index, option in ipairs(template.options) do
            local optionType = type(option)
            if optionType == "table" then
                container:Add(option.value or index, option.text, option.tooltip)
            elseif optionType == "string" then
                container:Add(index, option)
            end
        end

        return container:GetData();
    end

	Settings.CreateDropdown(category, setting, GetOptions(), template.tooltip)
end

lib:RegisterType(Type, Version, Constructor)