--[[
Principe Mokey Mokey
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id = GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--"Mokey Mokey" + "Mokey Mokey"
	Fusion.AddProcMixN(c,true,true,CARD_MOKEY_MOKEY,2)
	--This card's name is treated as "Mokey Mokey King" while face-up on the field or in the GY. 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e1:SetValue(CARD_MOKEY_MOKEY_KING)
	c:RegisterEffect(e1)
	--"Mokey Mokey" you control gain 1000 ATK/DEF.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,CARD_MOKEY_MOKEY))
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	e2:UpdateDefenseClone(c)
	--While you control "Mokey Mokey", your opponent's monsters cannot target this card for attacks.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(xgl.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_MOKEY_MOKEY),LOCATION_ONFIELD,0,1))
	e3:SetValue(aux.imval2)
	c:RegisterEffect(e3)
	--If this face-up card leaves the field: Special Summon 1 "Mokey Mokey" from your GY.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_MOKEY_MOKEY,CARD_MOKEY_MOKEY_KING}

--E4
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_MOKEY_MOKEY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.Group(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local infog = #g>0 and g or nil
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,infog,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end