--[[
Flamespear Style - Immolator Lance
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[When this card is activated: If you control a Level 7/Rank 5/Link 4 or higher Spellcaster monster, you can discard 1 card (or if you control "Valerie the Flamespear", you can activate this effect without discarding); send 1 monster your opponent controls to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetCost(xgl.LabelCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[Level 7/Rank 5/Link 3 or higher Spellcaster monsters you control can attack all monsters your opponent controls in their column and those adjacent to it, once each.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(s.atkfilter)
	xgl.RegisterGrantEffect(c,LOCATION_SZONE,LOCATION_MZONE,0,s.atktg,e2)
end
s.listed_names={CARD_VALERIE_THE_FLAMESPEAR}

--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and (c:IsLevelAbove(7) or c:IsRankAbove(5) or c:IsLinkAbove(4))
end
function s.cfilter2(c)
	return c:IsFaceup() and c:IsCode(CARD_VALERIE_THE_FLAMESPEAR)
end
function s.atkfilter(c,p)
	return c:IsFaceup() and c:IsControler(p) and c:IsLocation(LOCATION_MZONE)
end
function s.actchk(e,tp,eg,ep,ev,re,r,rp,b1,b2)
	return not Duel.PlayerHasFlagEffect(tp,id) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and (b1 or b2)
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local cost=Cost.Discard()
	local isCostChecked=e:GetLabel()==1
	e:SetLabel(0)
	local b1=not isCostChecked or Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_ONFIELD,0,1,nil)
	local b2=cost(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then
		return true
	end
	local param
	if s.actchk(e,tp,eg,ep,ev,re,r,rp,b1,b2) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_TOGRAVE)
		param=1
		
		local opt
		if not isCostChecked then
			opt=0
		else
			opt = (b2 and not b1) and 1 or Duel.SelectEffect(tp,{b2,aux.Stringid(id,1)},{b1,aux.Stringid(id,2)})
		end
		if opt==1 then
			cost(e,tp,eg,ep,ev,re,r,rp,chk)
		end
		local g1=Duel.Group(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,1,0,0)
	else
		e:SetCategory(0)
		param=0
	end
	Duel.SetTargetParam(param)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local param=Duel.GetTargetParam()
	if param==1 then
		local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
		if Duel.Highlight(g) then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

--E2
function s.atktg(e,c)
	return c:IsRace(RACE_SPELLCASTER) and (c:IsLevelAbove(7) or c:IsRankAbove(5) or c:IsLinkAbove(3))
end
function s.atkfilter(e,c)
	return e:GetHandler():GlitchyGetColumnGroup(1,1):IsContains(c)
end