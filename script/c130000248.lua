--[[
Sciabola-X Hoots
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchymods_synchro.lua")
function s.initial_effect(c)
	--If you Summon an "X-Saber" monster(s) to your field (except during the Damage Step): You can Special Summon this card from your hand. 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCondition(s.spcon)
	e1:SetSpecialSummonSelfFunctions()
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	e1:FlipSummonEventClone(c)
	--This card on the field can be treated as a Level 1 monster when used for a Synchro Summon of an "X-Saber" Synchro Monster. 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetOperation(s.synop)
	c:RegisterEffect(e2)
	--If this face-up card in a Monster Zone is destroyed by battle or your opponent's card effect, you can place it face-up in your Spell & Trap Zone as a Continuous Spell, instead of sending it to the GY.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:HOPT()
	e3:SetCondition(s.repcon)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
	--While this card is a Continuous Spell, if the only monster you control is 1 "X-Saber" monster: You can Special Summon this card.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,2)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:HOPT()
	e4:SetCondition(s.spcon_spell)
	e4:SetSpecialSummonSelfFunctions()
	c:RegisterEffect(e4)
end
s.listed_series={SET_X_SABER}

--E1
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_X_SABER) and c:IsSummonPlayer(tp) and c:IsControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end

--E2
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	local c=e:GetHandler()
	local sum=(sg-c):GetSum(Card.GetSynchroLevel,sc)
	if sum+c:GetSynchroLevel(sc)==lv then return true,true end
	return e:CheckCountLimit(tp) and sc:IsSetCard(SET_X_SABER) and sum+1==lv,true,true
end

--E3
function s.repcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	local r=c:GetReason()
	return e:CheckCountLimit(tp) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and r&REASON_DESTROY~=0 and (r&REASON_BATTLE~=0 or (r&REASON_EFFECT~=0 and c:IsReasonPlayer(1-tp)))
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
	Duel.RaiseEvent(c,EVENT_CUSTOM+CARD_CRYSTAL_TREE,e,0,tp,0,0)
	e:UseCountLimit(tp)
end

--E4
function s.spcon_spell(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsContinuousSpell() and Duel.GetMonstersCount(tp)==1 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_X_SABER),tp,LOCATION_MZONE,0,1,nil)
end