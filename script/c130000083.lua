--[[
Together Stronger
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Target 1 Psychic monster you control; halve its ATK, also it cannot be destroyed by battle this turn, then, if you control a "Linaan" card, draw 1 card.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
end
s.listed_series={SET_LINAAN}

--E1
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHIC)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then
		return Duel.IsExists(true,s.filter,tp,LOCATION_MZONE,0,1,nil)
			and (not Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,SET_LINAAN),tp,LOCATION_ONFIELD,0,1,nil) or Duel.IsPlayerCanDraw(tp,1))
	end
	local tc=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,0,0,-2,OPINFO_FLAG_HALVE)
	local MustDraw=Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,SET_LINAAN),tp,LOCATION_ONFIELD,0,1,nil)
	Duel.SetConditionalOperationInfo(MustDraw,0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local c=e:GetHandler()
		if tc:IsFaceup() then
			tc:HalveATK(true,{c,true})
		end
		local e1,res=tc:CannotBeDestroyedByBattle(1,nil,RESET_PHASE|PHASE_END,c,nil,EFFECT_FLAG_SET_AVAILABLE)
		if res and not tc:IsImmuneToEffect(e1) and Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,SET_LINAAN),tp,LOCATION_ONFIELD,0,1,nil) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end