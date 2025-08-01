--[[
Vixen Brew - Bottle of Volatile Explosive!
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If you control a Spellcaster monster: Target 1 monster your opponent controls; halve its ATK/DEF until the end of this turn, then, if this card was Set before activation and is on the field at resolution, you can destroy that monster.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_ATKDEF|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantBattleTimings()
	e1:SetFunctions(
		aux.AND(
			aux.StatChangeDamageStepCondition,
			xgl.LocationGroupCond(s.cfilter,LOCATION_MZONE,0,1)
		),
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
end

--E1
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	local pos=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsStatus(STATUS_ACT_FROM_HAND) and e:GetActivateLocation()&LOCATION_SZONE>0 and c:IsPreviousPosition(POS_FACEDOWN) and POS_FACEDOWN or 0
	Duel.SetTargetParam(pos)
	local cat = pos~=0 and CATEGORIES_ATKDEF|CATEGORY_DESTROY or CATEGORIES_ATKDEF
	e:SetCategory(cat)
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,tc,1,0,0,-2,OPINFO_FLAG_HALVE)
	if pos~=0 then
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToChain() then
		local c=e:GetHandler()
		local e1,e2,_,_,_,_,adiff,ddiff = tc:HalveATKDEF(RESET_PHASE|PHASE_END,{c,true})
		if (not tc:IsImmuneToEffect(e1) or not tc:IsImmuneToEffect(e2)) and (adiff<=0 or ddiff<=0) then
			Duel.AdjustInstantly(tc)
			local pos=Duel.GetTargetParam()
			if pos==POS_FACEDOWN and tc:IsRelateToChain() and c:IsRelateToChain() and Duel.SelectYesNo(tp,STRING_ASK_DESTROY) then
				Duel.BreakEffect()
				Duel.Destroy(tc,REASON_EFFECT)
			end
		end
	end
end