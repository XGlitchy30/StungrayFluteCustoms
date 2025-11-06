--[[
Fienthalete Flare Strike
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2+ Fiend monsters, including a "Fienthalete" monster
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND),2,nil,s.lcheck)
	--[[If this card is Link Summoned: You can Special Summon 1 "Fienthalete" monster from your GY, except a Link Monster.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(xgl.LinkSummonedCond)
	e1:SetSpecialSummonFunctions(nil,nil,s.spfilter,LOCATION_GRAVE,0,1,1,nil)
	c:RegisterEffect(e1)
	--[[During the Battle Phase (Quick Effect): You can Tribute 1 other "Fienthalete" monster you control, then target 1 Spell/Trap your opponent controls; destroy it.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_BATTLE_START)
	e2:HOPT()
	e2:SetCondition(xgl.BattlePhaseCond())
	e2:SetCost(s.descost)
	e2:SetSendtoFunctions(0,TGCHECK_IT,Card.IsSpellTrapOnField,0,LOCATION_ONFIELD,1,1,nil)
	c:RegisterEffect(e2)
end
s.listed_series={SET_FIENTHALETE}

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_FIENTHALETE,lc,sumtype,tp)
end

--E1
function s.spfilter(c)
	return c:IsSetCard(SET_FIENTHALETE) and not c:IsMonsterType(TYPE_LINK)
end

--E2
function s.relfilter(c)
	return c:IsSetCard(SET_FIENTHALETE)
end
function s.desfilter(c,e)
	return c:IsSpellTrapOnField() and (not e or c:IsCanBeEffectTarget(e))
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.relfilter,1,false,aux.ReleaseCheckTarget,c,dg) end
	local sg=Duel.SelectReleaseGroupCost(tp,s.relfilter,1,1,false,aux.ReleaseCheckTarget,c,dg)
	Duel.Release(sg,REASON_COST)
end