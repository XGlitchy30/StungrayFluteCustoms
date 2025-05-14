--Special library for advanced custom effects that Normal Summon a monster
FLAG_SUMMONABLE_BY_OPPONENT = 130000036

--Register an identifier effect that marks card with an effect that allows the opponent to Normal Summon them
function Card.IsSummonableByOpponent(c)
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e:SetCode(EFFECT_SUMMONABLE_BY_OPPONENT)
	c:RegisterEffect(e)
end

function Auxiliary.RegisterSummonableByOpponentGlobalCheck(c)
	if not aux.IsSummonableByOpponentCheckEnabled then
		aux.IsSummonableByOpponentCheckEnabled=true
		local e0=Effect.GlobalEffect()
		e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_ADJUST)
		e0:SetOperation(aux.IsSummonableByOpponentCheckOp)
		Duel.RegisterEffect(e0,0)
		local e0x=Effect.GlobalEffect()
		e0x:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e0x:SetCode(EVENT_ADJUST)
		e0x:SetOperation(aux.IsSummonableByOpponentCheckOp)
		Duel.RegisterEffect(e0x,1)
	end
end
function aux.IsSummonableByOpponentCheckOp(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(Card.IsHasEffect,tp,0,LOCATION_HAND,nil,EFFECT_SUMMONABLE_BY_OPPONENT)
	if #g==0 then return end
	for tc in aux.Next(g) do
		local res1=tc:IsSummonable(true,nil)
		local res2=tc:HasFlagEffect(FLAG_SUMMONABLE_BY_OPPONENT)
		if res1 and not res2 then
			tc:RegisterFlagEffect(FLAG_SUMMONABLE_BY_OPPONENT,0,0,0)
		elseif not res1 and res2 then
			tc:ResetFlagEffect(FLAG_SUMMONABLE_BY_OPPONENT)
		end
	end
end

--Return the maximum amount of Normal Summons a player can conduct during the current turn
function Duel.GetSummonCountLimit(p)
	if Duel.GetDuelType()&DUEL_UNLIMITED_SUMMONS~=0 then
		return 2147483547
	else
		local ct=1
		local eset={Duel.GetPlayerEffect(p,EFFECT_SET_SUMMON_COUNT_LIMIT)}
		for _,e in ipairs(eset) do
			local val=e:Evaluate()
			if val>ct then
				ct=val
			end
		end
		return ct
	end
end