local _TossDice = Duel.TossDice

function Duel.TossDice(p,ct1,ct2)
	if not ct2 and ct1==1 then
		local eset={Duel.GetPlayerEffect(p,EFFECT_SKIP_DICE_ROLL)}
		if #eset>0 then
			local e=eset[1]
			local tg=e:GetTarget()
			if not tg or tg(e,self_reference_effect) then
				return e:Evaluate(self_reference_effect)
			end
		end
	end
	return _TossDice(p,ct1,ct2)
end