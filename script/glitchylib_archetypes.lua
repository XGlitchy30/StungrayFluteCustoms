--Library for archetype-specific functions

Duel.LoadScript("glitchylib_new.lua")

--NECROVALLEY
local _NecroValleyFilter = Auxiliary.NecroValleyFilter

function Auxiliary.NecroValleyFilter(f)
	if not aux.NecroValleyFilterMod then
		return _NecroValleyFilter(f)
	else
		return	function(target,...)
					return f(target,...) and not (target:IsHasEffect(EFFECT_NECRO_VALLEY) and not target:IsHasEffect(CARD_HIDDEN_MONASTERY_OF_NECROVALLEY) and Duel.IsChainDisablable(0))
				end
	end
end

--NUMBERS
function Auxiliary.NumberLPCondition(e,p,val,chk)
	if Duel.GetLP(p)<=val then return true end
	local eset={Duel.IsPlayerAffectedByEffect(p,CARD_NUMBERS_REVOLUTION)}
	for _,ce in ipairs(eset) do
		local tg=ce:GetTarget()
		if not tg or tg(ce,e:GetHandler(),p,e,val,chk) then
			return true
		end
	end
	return false
end