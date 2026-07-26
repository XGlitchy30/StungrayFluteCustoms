--[[
Salvezza Oscura
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")

if not Salvo then
	Salvo = {}
	Duel.LoadScript("glitchylib_archetypes.lua",false)
end
function s.initial_effect(c)
	--If your opponent activates a card or effect: Tribute 1 "Engine Token"; add 1 Machine "Salvo" monster from your Deck to your hand. 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAINING)
	e1:HOPT()
	e1:SetCondition(s.condition)
	e1:SetCost(xgl.TributeCost(aux.FilterBoolFunction(Card.IsCode,TOKEN_ENGINE),1,1))
	e1:SetSearchFunctions(s.thfilter,LOCATION_DECK,1,1,nil)
	c:RegisterEffect(e1)
	--When your opponent declares a direct attack: You can banish this card from your GY, then target 1 Machine "Salvo" monster from your GY; Special Summon it in Defense Position.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetCondition(s.spcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_ENGINE}
s.listed_series={SET_SALVO}

--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.thfilter(c)
	return c:IsMonster() and c:IsRace(RACE_MACHINE) and c:IsSalvo()
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
function s.spfilter(c,e,tp)
	return c:IsSalvo() and c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then
		local exc=e:IsCostChecked() and e:GetHandler() or nil
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,exc,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end