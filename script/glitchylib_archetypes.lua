--Library for archetype-specific functions

Duel.LoadScript("glitchylib_new.lua")

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