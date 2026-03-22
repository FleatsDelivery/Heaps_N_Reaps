modifier_cooldown_reduction = class({})

-- Modifier properties
function modifier_cooldown_reduction:IsHidden() return true end
function modifier_cooldown_reduction:IsDebuff() return false end
function modifier_cooldown_reduction:IsPurgable() return false end
function modifier_cooldown_reduction:RemoveOnDeath() return false end
function modifier_cooldown_reduction:IsPermanent() return true end

-- Declare the functions this modifier affects
function modifier_cooldown_reduction:DeclareFunctions()
    return { MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE }
end

-- Return the cooldown reduction percentage
function modifier_cooldown_reduction:GetModifierPercentageCooldown()
    -- You can make this a constant or a variable
    return COOLDOWN_REDUCTION_PERCENTAGE
end
