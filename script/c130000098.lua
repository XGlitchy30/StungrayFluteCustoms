--[[
Queltz Storm
Card Author: LimitlessSock
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Reveal 1 "Queltz" Ritual Monster in your hand, then activate 1 of these effects.
	● Target 1 Spell/Trap your opponent controls; place it on the top of the Deck.
	● Ritual Summon the revealed monster from your hand, by paying LP equal to its DEF.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:HOPT(true)
	e1:SetFunctions(nil,xgl.LabelCost,s.target,s.activate)
	c:RegisterEffect(e1)
	if not s.ritual_matching_function then
		s.ritual_matching_function={}
	end
	s.ritual_matching_function[c]=aux.FilterEqualFunction(Card.IsSetCard,SET_QUELTZ)
end
s.listed_series={SET_QUELTZ}

--E1
function s.rvfilter(c,lp,e,tp)
	if not (c:IsRitualMonster() and c:IsSetCard(SET_QUELTZ) and not c:IsPublic()) then return false end
	if not lp then
		return true
	else
		local def=c:GetDefense()
		return def>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false) and lp>=def
	end
end
function s.tdfilter(c)
	return c:IsSpellTrapOnField() and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsOnField() and s.tdfilter(chkc)
	end
	local isCostChecked=e:GetLabel()==1
	local lp=Duel.GetLP(tp)
	local b1=Duel.IsExists(false,s.rvfilter,tp,LOCATION_HAND,0,1,c) and Duel.IsExists(true,s.tdfilter,tp,0,LOCATION_ONFIELD,1,nil)
	local b2=isCostChecked and Duel.GetMZoneCount(tp)>0 and (chk~=0 or Duel.IsExists(false,s.rvfilter,tp,LOCATION_HAND,0,1,c,lp,e,tp))
	e:SetLabel(0)
	if chk==0 then
		return b1 or b2
	end
	local rc
	if isCostChecked then
		local rg=Duel.Select(HINTMSG_CONFIRM,false,tp,s.rvfilter,tp,LOCATION_HAND,0,1,1,c)
		rc=rg:GetFirst()
		Duel.ConfirmCards(1-tp,rg)
	end
	if b2 then b2=b2 and rc and s.rvfilter(rc,lp,e,tp) end
	local opt=xgl.Option(tp,id,1,b1,b2)
	Duel.SetTargetParam(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_TODECK)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		local g=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
	elseif opt==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(0)
		Duel.SetTargetCard(rc)
		Duel.SetCardOperationInfo(rc,CATEGORY_SPECIAL_SUMMON)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then return end
	local opt=Duel.GetTargetParam()
	if opt==0 then
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	elseif opt==1 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local lp=Duel.GetLP(tp)
		mustpay=true
		Duel.PayLPCost(tp,tc:GetDefense())
		mustpay=false
		tc:SetMaterial(nil)
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end