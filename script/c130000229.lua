--[[
Kappa Intimidatorio
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
    --FLIP: Special Summon 1 "Kappa" monster from your hand.
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_FLIP)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    --If you Special Summon a "Kappa" monster(s) from the Extra Deck (except during the Damage Step): You can banish this card from your GY; for the rest of this Duel, all "Kappa" monsters you control gain 200 ATK/DEF.
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORIES_ATKDEF)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT(EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(s.statscon)
    e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.statstg)
	e2:SetOperation(s.statsop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_KAPPA}
s.lists_kappa_monster=true

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.filter(c,e,tp)
	return c:IsSetCard(SET_KAPPA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsFaceup() and c:IsSetCard(SET_KAPPA)
end
function s.statscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.statstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    local g=Duel.Group(aux.FaceupFilter(Card.IsSetCard,SET_KAPPA),tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,200)
    Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,tp,200)
end
function s.statsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    Duel.RegisterFlagEffect(tp,id,0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_KAPPA))
    e1:SetValue(200)
    Duel.RegisterEffect(e1,tp)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    Duel.RegisterEffect(e2,tp)
end