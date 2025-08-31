--[[
Draining Parasite
Card Author: C.C
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_ADJUST)
	e0:SetRange(LOCATION_MZONE)
	e0:SetOperation(s.saveATKstate)
	c:RegisterEffect(e0)
	--Gains 400 ATK/DEF for each face-up monster on the field whose current ATK is different from its original ATK (when recalculating, this card's ATK is treated as its value immediately before this effect is reapplied, including any ATK/DEF currently gained by this effect). 
	local e1=Effect.CreateEffect(c)
	e1:SetCustomCategory(0,CATEGORY_FLAG_DRAINING_PARASITE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	e1:UpdateDefenseClone(c)
	--If this card is added to your hand: You can have all face-up monsters currently on the field lose 400 ATK/DEF until the end of the next Battle Phase.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORIES_ATKDEF)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetFunctions(
		nil,
		nil,
		s.atktg,
		s.atkop
	)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		s.DrainingParasiteATK=-1
	end)
end
--E0
function s.saveATKstate(e,tp,eg,ep,ev,re,r,rp)
	s.DrainingParasiteATK=e:GetHandler():GetAttack()
end

--E1
function s.IsRecalculator(c)
	if not c:IsFaceup() then return false end
	local eset={c:GetCardEffect()}
	for _,e in ipairs(eset) do
		if e:IsHasCustomCategory(nil,CATEGORY_FLAG_DRAINING_PARASITE) then
			return true
		end
	end
	return false
end
function s.valfilter(c)
	if not c:IsFaceup() then return false end
	if s.IsRecalculator(c) then
		local atk=c.DrainingParasiteATK
		return atk~=-1 and atk~=c:GetBaseAttack()
	end
	return not c:IsAttack(c:GetBaseAttack())
end
function s.value(e,c)
	--local rg=Duel.Group(s.IsRecalculator,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	--local ct0=Duel.GetMatchingGroupCount(s.valfilter,0,LOCATION_MZONE,LOCATION_MZONE,rg)
	--if ct0==0 then return 0 end
	local ct1=Duel.GetMatchingGroupCount(s.valfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	return ct1*400
end

--E2
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,-400)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,0,-400)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for tc in g:Iter() do
		tc:UpdateATKDEF(-400,-400,{RESET_PHASE|PHASE_BATTLE,Duel.GetNextBattlePhaseCount()},{c,true})
	end
end