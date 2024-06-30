--[[
Backcode Talker
Card Author: Riku
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2+ Cyberse Effect Monsters, including 1 "Code Talker" monster
	Link.AddProcedure(c,s.matfilter,2,nil,s.matcheck)
	--[[If this card is Link Summoned: You can target 1 "Code Talker" Link Monster in your GY that was used as material for this card's Link Summon;
	this card gains ATK equal to that targeted monster's Link Rating x 800]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetFunctions(aux.LinkSummonedCond,nil,s.atktg,s.atkop)
	c:RegisterEffect(e1)
	--[[You can banish 1 "Code Talker" Link Monster from your field or GY, then target 1 card your opponent controls; destroy it.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT(false,2)
	e2:SetFunctions(nil,s.descost,s.destg,s.desop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CODE_TALKER}

function s.matfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_EFFECT,scard,sumtype,tp) and c:IsRace(RACE_CYBERSE,scard,sumtype,tp)
end
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_CODE_TALKER,lc,sumtype,tp)
end

--E1
function s.atkfilter(c,e,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsLinkMonster() and c:IsSetCard(SET_CODE_TALKER) and c:IsCanBeEffectTarget(e)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=c:GetMaterial():Filter(s.atkfilter,nil,e,tp)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg=c:GetMaterial():FilterSelect(tp,s.atkfilter,1,1,nil,e,tp)
	Duel.SetTargetCard(tg)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,0,tg:GetFirst():GetLink()*800)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToChain() and tc:IsRelateToChain() then
		local val=tc:GetLink()*800
		if val<0 then val=0 end
		c:UpdateATK(val,true,c)
	end
end

--E2
function s.costfilter(c)
	return c:IsLinkMonster() and c:IsSetCard(SET_CODE_TALKER) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,true)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end