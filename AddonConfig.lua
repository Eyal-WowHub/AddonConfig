---@diagnostic disable: undefined-field
assert(LibStub, "AddonConfig-1.0 requires LibStub")

local C = LibStub("Contracts-1.0")
assert(C, "AddonConfig-1.0 requires Contracts-1.0")

local lib = LibStub:NewLibrary("AddonConfig-1.0", 0)
if not lib then return end

lib.Styles = lib.Styles or {}
lib.Types = lib.Types or {}
lib.Schema = lib.Schema or {
    name = "string",
    type = "string",
    handler = "table?",
    props = "table?",
}

--[[ Localization ]]

local L = {
    ["ALREADY_REGISTERED"] = "the %s '%s version %d' already registered.",
    ["STYLE_TYPE_IS_INVALID"] = "the style type is invalid. Expected type 'string'.",
    ["STYLE_IS_UNKNOWN"] = "the style '%s' is unknown.",
    ["TYPE_IS_NOT_SUPPORTED"] = "the type '%s' is not supported. the type can either be 'boolean', 'number', 'string', 'table' or 'function'.",
    ["TEMPLATE_FIELD_IS_MISSING_OR_NIL"] = "the template field '[#%s].%s' is either missing or has a nil value. Expected type '%s'.",
    ["TEMPLATE_FIELD_TYPE_HAS_UNKNOWN_CONTROL_TYPE"] = "the template field '[\"%s\"].type' is assigned with an unknown control type '%s'.",
}

--[[ Template APIs ]]

local Template = {}

function Template:Validate(schema)
    lib:Validate(self, schema)
end

function Template:RegisterCategory(category, layout)
    self.__category = category
    self.__layout = layout
end

function Template:GetParent()
    return self.__parent
end

function Template:GetLayout()
    return self.__layout
end

function Template:GetCategory()
    return self.__category
end

function Template:GetIndex()
    return self.__index
end

function Template:GetCurrentIndex()
    return self:GetIndex():match(".*:(%d+)") or self:GetIndex()
end

function Template:RegisterControlSetting()
    local category = self:GetCategory()
    local parent = self:GetParent()
    local handler = parent and parent.handler

    local function get()
        return self.get(handler)
    end

    local function set(value)
        self.set(handler, value)
    end

    return Settings.RegisterProxySetting(category, self.__varName, self.__varType, self.name, self.default, get, set)
end

function Template:InitializeControl(controlTemplate)
    local layout = self:GetLayout()
    local setting = self:RegisterControlSetting()
    local initializer = Settings.CreateControlInitializer(controlTemplate, setting, self.options, self.tooltip)

    layout:AddInitializer(initializer)
end

-- [[ Library APIs ]]

function lib:RegisterStyle(style, version, transformer)
    C:IsString(style, 2)
    C:IsNumber(version, 3)
    C:IsFunction(transformer, 4)

    C:Ensures(not self.Styles[style] or self.Styles[style].version == version, L["ALREADY_REGISTERED"], "style", style, version)

    self.Styles[style] = {
        version = version,
        transformer = transformer
    }
end

function lib:GetStyleVersion(style)
    C:IsString(style, 2)

    return self.Styles[style] and self.Styles[style].version or 0
end

function lib:RegisterType(type, version, ctor)
    C:IsString(type, 2)
    C:IsNumber(version, 3)
    C:IsFunction(ctor, 4)

    C:Ensures(not self.Types[type] or self.Types[type].version == version, L["ALREADY_REGISTERED"], "type", type, version)

    self.Types[type] = {
        version = version,
        constructor = ctor
    }
end

function lib:GetControlVersion(type)
    C:IsString(type, 2)

    return self.Types[type] and self.Types[type].version or 0
end

do
    local LuaType = {
        ["boolean"] = true,
        ["number"] = true,
        ["string"] = true,
        ["table"] = true,
        ["function"] = true
    }

    local function GetSchemaType(schemaType)
        local actualType, optional = string.match(schemaType, "^([a-z]+)([?]?)$")
        local isOptional = optional ~= ""

        actualType = LuaType[actualType] and actualType

        C:Ensures(actualType, L["TYPE_IS_NOT_SUPPORTED"], schemaType)

        return actualType, isOptional
    end

    local function IsValidValue(propValue, schemaType)
        local actualType, isOptional = GetSchemaType(schemaType)

        return isOptional and propValue == nil or type(propValue) == actualType
    end

    function lib:Validate(template, schema)
        C:IsTable(template, 1)
        C:IsTable(schema, 2)

        for propName, propType in pairs(schema) do
            local propValue = template[propName]

            C:Ensures(IsValidValue(propValue, propType), L["TEMPLATE_FIELD_IS_MISSING_OR_NIL"], template:GetIndex(), propName, propType)
        end
    end
end

do
    local function GenerateVariableName(name)
        return (name:gsub("([A-Za-z0-9])([A-Za-z0-9]*)", function(first, rest)
            return first:upper() .. rest:lower()
        end):gsub("%W", ""))
    end

    local function ConstructType(template)
        template = setmetatable(template, { __index = Template })

        lib:Validate(template, lib.Schema)

        local parent = template:GetParent()
        local type = lib.Types[template.type]

        C:Ensures(type, L["TEMPLATE_FIELD_TYPE_HAS_UNKNOWN_CONTROL_TYPE"], template.name, template.type)

        type.constructor(template, parent)
    end

    local function ConstructTypes(template)
        template.__index = template.__index or "1"
        template.__varName = template.__varName or GenerateVariableName(template.name)

        ConstructType(template)

        if type(template.props) == "table" then
            for index, t in ipairs(template.props) do
                t.__parent = template
                t.__index = template.__index .. ":" .. index
                t.__varName = template.__varName .. "_" .. GenerateVariableName(t.name)
                ConstructTypes(t)
            end
        end
    end

    function lib:Generate(template, style)
        C:IsTable(template, 2)

        if style then
            C:Ensures(type(style) == "string", L["STYLE_TYPE_IS_INVALID"])

            local styleInfo = self.Styles[style]

            C:Ensures(styleInfo, L["STYLE_IS_UNKNOWN"], style)

            template = styleInfo.transformer(template)
        end

        ConstructTypes(template)

        local topCategory = template:GetCategory()

        return topCategory:GetID()
    end
end