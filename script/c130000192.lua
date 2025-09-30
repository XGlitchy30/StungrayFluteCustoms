--[[
Victory Construction!
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Special Summon 1 LIGHT Machine monster with the effect "If this card destroys an opponent's monster by battle", or "Vic Viper T301", from your Deck, and if you do, it gains 1000 ATK until the end of the next turn and it gains 1 additional attack each Battle Phase.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	Gradius.RegisterAlpiniaCopyCheck(s)
end
s.listed_names={CARD_VIC_VIPER_T301}

--E1
function s.cfilter(c,e,tp)
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	if c:IsCode(CARD_VIC_VIPER_T301) then return true end
	if c:IsAttributeRace(ATTRIBUTE_LIGHT,RACE_MACHINE) and c:IsType(TYPE_EFFECT) then
		local eset={c:GetOwnEffects()}
		for _,e in ipairs(eset) do
			if e:IsHasCustomCategory(0,CATEGORY_FLAG_ALPINIA) then
				return true
			end
		end
		
		if Gradius.AlpiniaTable[c:GetOriginalCode()] or c:HasFlagEffect(CARD_ALPINIA) then
			return true
		end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END,2)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(id,1)
		e2:SetCustomCategory(0,CATEGORY_FLAG_INCREMENTAL)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_EXTRA_ATTACK)
		e2:SetValue(s.atkval)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
end
function s.atkval(e,c,return_only_incr)
	if return_only_incr then return 1 end
	local ct=c:GetAttackAnnouncedCount()
	local extra_total_base, extra_total_incr = 0, 0
	local eset={c:GetCardEffect(EFFECT_EXTRA_ATTACK)}
	for _,ce in ipairs(eset) do
		if ce:IsHasCustomCategory(nil,CATEGORY_FLAG_INCREMENTAL) then
			local n=ce:Evaluate(c,true)
			extra_total_incr = extra_total_incr + n
		else
			local n=ce:Evaluate(c)
			extra_total_base = math.max(n,extra_total_base)
		end
	end
	local a=Duel.GetAttacker()
	local extra_total=extra_total_base + extra_total_incr + 1
	if ct<extra_total or (ct==extra_total and a and a==c) then
		return ct
	else
		return 0
	end
end