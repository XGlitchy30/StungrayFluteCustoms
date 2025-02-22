--[[
Fienthalete Curveball
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[You can discard this card; Special Summon 1 "Fienthalete" monster from your hand or GY, but if you Special Summon a monster from the GY, skip your next Battle Phase.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		xgl.CreateCost(xgl.LabelCost,xgl.DiscardSelfCost),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[You can banish this card from your GY, then target 1 "Fienthalete" Link Monster you control; it gains 700 ATK until the end of this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		aux.bfgcost,
		s.atktg,
		s.atkop
	)
	c:RegisterEffect(e2)
end
s.listed_series={SET_FIENTHALETE}

--E1
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_FIENTHALETE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetMZoneCount(tp)<=0 then return false end
		local c=e:GetHandler()
		local exc = not (e:GetLabel()==1 and c:IsAbleToGraveAsCost()) and c or nil
		e:SetLabel(0)
		return Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,exc,e,tp)
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return false end
	local tc=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsSummonLocation(LOCATION_GRAVE) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(id,2)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		if Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase() then
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(function(e) return Duel.GetTurnCount()~=e:GetLabel() end)
			e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_SELF_TURN,1)
		end
		Duel.RegisterEffect(e1,tp)
	end
end

--E2
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(SET_FIENTHALETE)
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