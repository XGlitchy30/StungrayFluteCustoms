--[[
Ancestagon Savage Rush
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Tribute 1 Level 2 "Ancestagon" monster, then target 2 cards on the field; destroy them.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCustomCategory(0,CATEGORY_FLAG_ANCESTAGON_PLASMATAIL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:HOPT(true)
	e1:SetCost(xgl.LabelCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ANCESTAGON}

function s.spcheck(sg,tp,exg,dg)
	local a=0
	for c in aux.Next(sg) do
		if dg:IsContains(c) then a=a+1 end
		for tc in aux.Next(c:GetEquipGroup()) do
			if dg:IsContains(tc) then a=a+1 end
		end
	end
	return #dg-a>=2
end
function s.cfilter(c)
	return c:IsLevel(2) and c:IsSetCard(SET_ANCESTAGON)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local exc=xgl.GetSelfTargetExceptionForSpellTrap(e)
	if chkc then return chkc:IsOnField() and chkc~=exc and xgl.PlasmatailFilter(tp)(chkc) end
	local dg=Duel.GetMatchingGroup(xgl.PlasmatailFilter(tp,Card.IsCanBeEffectTarget),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,exc,e)
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,s.spcheck,nil,dg)
		else
			return Duel.IsExistingTarget(xgl.PlasmatailFilter(tp),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,exc)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		local sg=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,s.spcheck,nil,dg)
		Duel.Release(sg,REASON_COST)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,xgl.PlasmatailFilter(tp),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exc)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end