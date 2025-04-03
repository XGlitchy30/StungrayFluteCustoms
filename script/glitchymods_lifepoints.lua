--Auxiliary function that registers the global effect that will handle all effects that continuously modify LPs
function Glitchy.RegisterContinuousLPModifier()
	if not xgl.ContinuousLPModifierEnabled then
		xgl.ContinuousLPModifierEnabled=true
		local ge=Effect.GlobalEffect()
		ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_ADJUST)
		ge:SetOperation(xgl.ContinuousLPModifierOperation)
		Duel.RegisterEffect(ge,0)
	end
end
function Glitchy.ContinuousLPModifierOperation(e,tp)
	if not xgl.UpdatedLP then
		xgl.UpdatedLP={0,0}
	end
	for p in aux.TurnPlayers() do
		local upval=0
		local eset={Duel.GetPlayerEffect(p,EFFECT_UPDATE_LP)}
		for _,ce in ipairs(eset) do
			upval=upval+ce:Evaluate(p)
		end
		
		local updated_lp=Duel.GetLP(p)-xgl.UpdatedLP[p+1]+upval
		xgl.UpdatedLP[p+1]=upval
		if Duel.GetLP(p)~=updated_lp then
			Duel.SetLP(p,updated_lp)
		end
	end
end