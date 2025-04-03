--[[
Percussion Beetle Triplet Performance
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Target 2 "Percussion Beetle" monsters you control with different names in Attack Position; Special Summon 1 "Percussion Beetle" monster with a different name from your Deck in Attack Position.
	Until the end of this turn, you cannot Special Summon monsters, except "Percussion Beetle" monsters, also the original ATK of all "Percussion Beetle" monsters you currently control becomes 2000.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[At the end of the Damage Step, if a "Percussion Beetle" monster battles an opponent's monster, [but the opponent's monster was not destroyed by the battle]: You can banish this card from your
	GY; halve the ATK/DEF of that opponent's monster.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORIES_ATKDEF)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(nil,aux.bfgcost,s.attg,s.atop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PERCUSSION_BEETLE}

--E1
function s.filter(c,e)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSetCard(SET_PERCUSSION_BEETLE) and c:IsCanBeEffectTarget(e)
end
function s.spfilter(c,e,tp,g)
	return c:IsSetCard(SET_PERCUSSION_BEETLE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
		and (not g or not g:IsExists(Card.IsCode,1,nil,c:GetCode()))
end
function s.afilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_PERCUSSION_BEETLE)
end
function s.gcheck(dg)
	return	function(g,e,tp,mg,c)
				local merged=g:Clone()+dg
				local valid = g:GetClassCount(Card.GetCode)==#g and merged:GetClassCount(Card.GetCode)>#g
				local razor = {aux.NOT(Card.IsCode),c:GetCode()}
				return valid,false,razor
			end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil,e)
	local dg=Duel.Group(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then
		return #dg>0 and Duel.GetMZoneCount(tp)>0 and xgl.SelectUnselectGroup(g,e,tp,2,2,s.gcheck(dg),0)
	end
	local g=xgl.SelectUnselectGroup(g,e,tp,2,2,s.gcheck(dg),1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	local ag=Duel.Group(s.afilter,tp,LOCATION_MZONE,0,nil)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,ag,#ag+1,tp,LOCATION_MZONE,2000,OPINFO_FLAG_ORIGINAL)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards():Filter(Card.IsFaceup,nil)
	if #g>0 and Duel.GetMZoneCount(tp)>0 then
		local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,g)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		end
	end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local ag=Duel.Group(s.afilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(ag) do
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_BASE_ATTACK)
		e2:SetValue(2000)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(SET_PERCUSSION_BEETLE)
end

--E2
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	local a,b=Duel.GetAttacker(),Duel.GetAttackTarget()
	if chk==0 then
		if not b then return false end
		for i=1,2 do
			local res=s.afilter(a) and b:IsControler(1-tp) and b:IsLocation(LOCATION_MZONE) and b:IsRelateToBattle()
			if res then
				return true
			else
				a,b=b,a
			end
		end
		return false 
	end
	
	local res=s.afilter(a) and b:IsControler(1-tp) and b:IsLocation(LOCATION_MZONE) and b:IsRelateToBattle()
	if not res then
		a,b=b,a
	end
	Duel.SetTargetCard(b)
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,b,1,0,0,-2,OPINFO_FLAG_HALVE)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
		local c=e:GetHandler()
		tc:HalveATK(true,{c,true})
		tc:HalveDEF(true,{c,true})
	end
end