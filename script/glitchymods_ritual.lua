local _IsCanBeRitualMaterial, _GetRitualMaterial = Card.IsCanBeRitualMaterial, Duel.GetRitualMaterial

function Card.IsCanBeRitualMaterial(c,...)
	if c:IsLocation(LOCATION_SZONE) and c:IsMonsterCard() and c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL) then
		c:AssumeProperty(ASSUME_TYPE,c:GetType()|TYPE_MONSTER)
	end
	local res = _IsCanBeRitualMaterial(c,...)
	Duel.AssumeReset()
	return res
end

local function GraveRitualMaterialFilter(c,check_level)
	return c:IsMonsterCard() and (not check_level or c:GetLevel()>0) and c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)
end

function Duel.GetRitualMaterial(p,...)
	local params={...}
	local check_level = true
    if #params>0 then check_level=params[1] end
	local original_ritual_mats = _GetRitualMaterial(p,...)
	
	local sz_mats = Duel.GetMatchingGroup(GraveRitualMaterialFilter,p,LOCATION_SZONE,0,nil,check_level)
	original_ritual_mats:Merge(sz_mats)

	return original_ritual_mats
end