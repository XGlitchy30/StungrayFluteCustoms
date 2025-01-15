--[[
Queltz Fright
Card Author: LimitlessSocks
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If you control a "Queltz" Ritual Monster: Target 2 cards your opponent controls in different columns; destroy all your opponent's cards in those columns, also the zones in those columns
	cannot be used until the end of their next turn.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_MAIN_END|TIMING_END_PHASE)
	e1:HOPT(true)
	e1:SetFunctions(
		xgl.LocationGroupCond(s.cfilter,LOCATION_MZONE,0,1),
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
end
s.listed_series={SET_QUELTZ}

--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsRitualMonster() and c:IsSetCard(SET_QUELTZ)
end
function s.filter(c,e)
	return c:IsCanBeEffectTarget(e) and not c:IsLocation(LOCATION_FZONE) and (not Duel.IsDuelType(DUEL_MODE_MR3) or not c:IsLocation(LOCATION_PZONE))
end
function s.gcheck(g,e,tp,mg,c)
	if #g==1 then return true end
	local c1,c2=g:GetFirst(),g:GetNext()
	return not c2:IsColumn(c1:GetSequence(),c1:GetControler(),c1:GetLocation()&(LOCATION_MZONE|LOCATION_SZONE))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.Group(s.filter,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,0)
	end
	local dg=aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,1,tp,HINTMSG_DESTROY)
	Duel.SetTargetCard(dg)
	Duel.SetCardOperationInfo(dg,CATEGORY_DESTROY)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards():Filter(Card.IsControler,nil,1-tp)
	if #g==2 and s.gcheck(g) then
		local c1,c2=g:GetFirst(),g:GetNext()
		local seq1,seq2=c1:GetSequence(),c2:GetSequence()
		local z1,z2=Duel.GetFullColumnZoneFromSequence(seq1,LOCATION_ONFIELD,true),Duel.GetFullColumnZoneFromSequence(seq2,LOCATION_ONFIELD,true)
		local dg=g+c1:GetColumnGroup()+c2:GetColumnGroup()
		Duel.Destroy(dg,REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetLabel(z1|z2)
		e1:SetOperation(s.disop)
		e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,Duel.GetNextPhaseCount(nil,1-tp))
		Duel.RegisterEffect(e1,tp)
	end
end
function s.disop(e,tp)
	local v=e:GetLabel()
	return v
end