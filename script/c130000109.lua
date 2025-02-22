--[[
Fienthalete Net Block
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 "Fienthalete" monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_FIENTHALETE),2,2)
	--[[During the Main Phase (Quick Effect): You can pay 700 LP; Special Summon 1 "Fienthalete" monster from your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetRelevantTimings()
	e1:HOPT()
	e1:SetCondition(xgl.MainPhaseCond())
	e1:SetCost(xgl.PayLPCost(700))
	e1:SetSpecialSummonFunctions(nil,nil,xgl.ArchetypeFilter(SET_FIENTHALETE),LOCATION_HAND,0,1,1,nil)
	c:RegisterEffect(e1)
	--[[If an attack is declared involving a "Fienthalete" monster you control: You can target 1 "Fienthalete" monster you control; it gains 700 ATK until the end of this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:HOPT()
	e2:SetFunctions(s.atkcon,nil,s.atktg,s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_FIENTHALETE}

--E2
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetBattleMonster(tp)
	return tc and tc:IsFaceup() and tc:IsSetCard(SET_FIENTHALETE)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_FIENTHALETE)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,700)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		tc:UpdateATK(700,RESET_PHASE|PHASE_END,{e:GetHandler(),true})
	end
end