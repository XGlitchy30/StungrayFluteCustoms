--[[
Fossa Atlantica di Sepoltura
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")

function s.initial_effect(c)
	--When this card is activated, if you have no cards in your Extra Deck: You can send 1 "Atlantean" monster from your Deck to the GY.
	c:Activation(true,nil,nil,nil,s.target,s.activate,nil,CATEGORY_TOGRAVE)
	--During your End Phase: You can target 1 "Atlantean" monster in your GY, whose Level is equal to or less than the number of "Atlantean" monsters in your GY; Special Summon it in Defense Position, but negate its effects.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_PHASE|PHASE_END)
	e1:HOPT()
	e1:SetFunctions(xgl.EndPhaseCond(0),nil,s.sptg,s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ATLANTEAN}

--E0
function s.tgfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_ATLANTEAN) and c:IsAbleToGrave()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.GetExtraDeckCount(tp)==0 and not Duel.PlayerHasFlagEffect(tp,id) then
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.SetTargetParam(1)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(0)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTargetParam()==1 and Duel.IsExists(false,s.tgfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,STRING_ASK_TO_GRAVE) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

--E1
function s.ctfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_ATLANTEAN)
end
function s.spfilter(c,lv,e,tp)
	return c:IsSetCard(SET_ATLANTEAN) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=Duel.GetMatchingGroupCount(s.ctfilter,tp,LOCATION_GRAVE,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,ct,e,tp) end
	if chk==0 then
		return ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,ct,e,tp)
	end
	local g=Duel.Select(HINTMSG_SPSUMMON,true,tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,ct,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SpecialSummonNegate(e,tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end