--[[
Ninfe Gishki
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchymods_disclosure.lua")
function s.initial_effect(c)
	--[[If you control a Ritual Monster (Quick Effect): You can reveal the top card of your Deck, then, if it is a "Gishki" card, you can Special Summon this card from your hand in Defense Position.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetRelevantTimings()
	e1:HOPT()
	e1:SetFunctions(s.rvcon,nil,s.rvtg,s.rvop)
	c:RegisterEffect(e1)
	--If this card is Special Summoned: You can target 1 "Gishki" monster you control; it cannot be destroyed by battle this turn.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.indtg,s.indop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GISHKI}
s.listed_card_types={TYPE_RITUAL|TYPE_MONSTER}

--E1
function s.ritfilter(c)
	return c:IsFaceup() and c:IsRitualMonster()
end
function s.rvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,s.ritfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.rvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	local tc=Duel.RevealDecktop(tp,1):GetFirst()
	local c=e:GetHandler()
	if tc and tc:IsSetCard(SET_GISHKI) and c:IsRelateToChain() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
		Duel.BreakEffect()
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

--E2
function s.indfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GISHKI)
end
function s.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.indfilter(chkc) end
	if chk==0 then return Duel.IsExists(true,s.indfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Select(HINTMSG_TARGET,true,tp,s.indfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		tc:CannotBeDestroyedByBattle(1,nil,RESET_PHASE|PHASE_END,e:GetHandler())
	end
end