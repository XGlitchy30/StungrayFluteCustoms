--[[
Sciabola-XX Generale Gottoms
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--1+ Tuners + 1+ EARTH monsters
	Synchro.AddProcedure(c,nil,1,99,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_EARTH),1,99)
	--If this card is Synchro Summoned and your opponent controls more cards than you do: You can Special Summon 1 "X-Saber" monster from your GY in Attack Position, but it must attack, if able, also it cannot be used as material for a Fusion, Synchro, Xyz, or Link Summon, except for the Summon of a "X-Saber" monster.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		xgl.SynchroSummonedCond,
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--If an "X-Saber" monster(s) you control would be destroyed by a card effect, you can destroy 1 other "X-Saber" card you control instead of 1 of those cards.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_X_SABER}

--E1
function s.filter(c,e,tp)
	return c:IsSetCard(SET_X_SABER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then
		return Duel.GetFieldCount(tp)<Duel.GetFieldCount(1-tp)
			and Duel.GetMZoneCount(tp)>0 and #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local tc=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3200)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(id,1)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CLIENT_HINT)
		e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e3:SetValue(s.matlimit)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
	end
	Duel.SpecialSummonComplete()
end
function s.matlimit(e,sc,sumtype,tp)
	if sc and sc:IsSetCard(SET_X_SABER) then return false end
	local disallowed={SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK}
	local sum=(SUMMON_TYPE_FUSION|SUMMON_TYPE_SYNCHRO|SUMMON_TYPE_XYZ|SUMMON_TYPE_LINK)&sumtype
	for _,val in pairs(disallowed) do
		if sum==val then return true end
	end
	return false
end

--E2
function s.replacement(c,e)
	return c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED|STATUS_BATTLE_DESTROYED) 
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_X_SABER) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=eg:Filter(s.repfilter,nil,tp)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and #g>0 and Duel.IsExistingMatchingCard(s.replacement,tp,LOCATION_ONFIELD,0,1,g,e) end
	if Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,3)) then
		Duel.Hint(HINT_CARD,tp,id)
		if #g==1 then
			e:SetLabelObject(g:GetFirst())
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE_GLITCHY)
			local cg=g:Select(tp,1,1,nil)
			Duel.HintSelection(cg)
			e:SetLabelObject(cg:GetFirst())
		end
		local repc=Duel.Select(HINTMSG_DESTROY,false,tp,s.replacement,tp,LOCATION_ONFIELD,0,1,1,g,e):GetFirst()
		Duel.HintSelection(repc)
		repc:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		Duel.SetTargetCard(repc)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		return true
	else return false end
end
function s.repval(e,c)
	return c==e:GetLabelObject()
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local repc=Duel.GetFirstTarget()
	repc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(repc,REASON_EFFECT|REASON_REPLACE)
end