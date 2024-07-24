--[[
Hieratic Dragon of Khonsu
Card Author: Sock
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 Dragon monsters, including a "Hieratic" monster
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON),2,2,s.matcheck)
	--[[(Quick Effect): You can Tribute 1 monster from your hand or field, then target up to 1 card each on the field and in the GYs; shuffle them into the Deck]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetRelevantTimings()
	e1:HOPT()
	e1:SetFunctions(nil,s.tdcost,s.tdtg,s.tdop)
	c:RegisterEffect(e1)
	--[[If this card is Tributed: Special Summon 1 Dragon Normal Monster, or 1 non-Link "Hieratic" monster, from your hand, Deck, or GY, but make its ATK/DEF 0]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_RELEASE)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.sptg,s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_HIERATIC}

function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_HIERATIC,lc,sumtype,tp)
end

--E1
function s.thcfilter(c,e,tp)
	return c:IsMonster() and c:IsReleasable()
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,c,e)
end
function s.tdfilter(c,e)
	return c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.thcfilter,1,true,nil,nil,e,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.thcfilter,1,1,true,nil,nil,e,tp)
	Duel.Release(g,REASON_COST)
end
function s.tdcheck(g,e,tp)
	local ct=g:GetClassCount(Card.GetLocation)
	return #g==1 or ct==2, #g>1 and ct==1
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.Group(s.tdfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,nil,e)
	if chkc then
		return not Duel.PlayerHasFlagEffect(tp,id) and chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and chkc:IsAbleToDeck()
	end
	if chk==0 then return e:GetLabel()==1 or #g>0 end
	e:SetLabel(0)
	local tg=aux.SelectUnselectGroup(g,e,tp,1,2,s.tdcheck,1,tp,HINTMSG_TODECK)
	if #tg>1 then
		Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	end
	Duel.SetTargetCard(tg)
	Duel.SetCardOperationInfo(tg,CATEGORY_TODECK)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

--E2
function s.spfilter(c,e,tp)
	return ((c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON)) or (c:IsMonster() and not c:IsType(TYPE_LINK) and c:IsSetCard(SET_HIERATIC))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
end