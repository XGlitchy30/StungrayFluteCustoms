--[[
L'EROE Malvagio Ascende
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Target 1 "Evil HERO" and 1 "Elemental HERO" monster in your banishment; shuffle them into the Deck, and if you do, if you shuffled a Normal Monster by this effect, you can Special Summon 1 non-Fusion "Evil HERO" monster from your GY.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:HOPT(true)
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
end
s.listed_card_types={TYPE_NORMAL}
s.listed_series={SET_EVIL_HERO,SET_ELEMENTAL_HERO}

--E1
function s.filter(c,e)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard({SET_EVIL_HERO,SET_ELEMENTAL_HERO}) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.spfilter(c,e,tp)
	return not c:IsType(TYPE_FUSION) and c:IsSetCard(SET_EVIL_HERO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.Group(s.filter,tp,LOCATION_REMOVED,0,nil,e)
	if chk==0 then
		return xgl.SelectUnselectGroup(g,e,tp,2,2,xgl.SubGroupCheckDuoSingleFilter(Card.IsSetCard,SET_EVIL_HERO,SET_ELEMENTAL_HERO),0)
	end
	local tg=xgl.SelectUnselectGroup(g,e,tp,2,2,xgl.SubGroupCheckDuoSingleFilter(Card.IsSetCard,SET_EVIL_HERO,SET_ELEMENTAL_HERO),1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(tg)
	Duel.SetCardOperationInfo(tg,CATEGORY_TODECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 and Duel.ShuffleIntoDeck(g,nil,nil,nil,nil,aux.FilterBoolFunction(Card.IsType,TYPE_NORMAL))>0 and Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
		local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end