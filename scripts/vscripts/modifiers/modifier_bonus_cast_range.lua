modifier_bonus_cast_range = class({})

function modifier_bonus_cast_range:IsHidden() return true end
function modifier_bonus_cast_range:IsPurgable() return false end
function modifier_bonus_cast_range:RemoveOnDeath() return false end
function modifier_bonus_cast_range:IsPermanent() return true end

function modifier_bonus_cast_range:DeclareFunctions()
    return { MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING }
end

function modifier_bonus_cast_range:GetModifierCastRangeBonusStacking(params)
    local ability = params.ability
    if ability and ability:GetAbilityName() == "pudge_meat_hook" then
        local kills = self:GetParent()._hnr_kills or 0
        return BONUS_CAST_RANGE + (kills * HOOK_KILL_RANGE_BONUS)
    end
    return 0
end
