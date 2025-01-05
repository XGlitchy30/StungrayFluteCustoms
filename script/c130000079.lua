--[[
Days of Sunshine, Past
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Banish 1 Psychic monster from your GY, then target 1 face-up monster your opponent controls; it loses ATK/DEF equal to the ATK/DEF of the banished monster, also decrease its Level by the Level
	of the banished monster (if possible). These changes last until the end of the next turn.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_ATKDEF|CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetFunctions(
		xgl.ExceptOnDamageCalc,
		xgl.LabelCost,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
end

--E1
function s.cfilter(c,tp)
	local atk,def=c:GetStats()
	local statchk=atk>0 or def>0
	local lvchk=c:GetLevel()>0
	if not statchk and not lvchk then return false end
	return c:IsRace(RACE_PSYCHIC) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
		and Duel.IsExists(false,s.filter,tp,0,LOCATION_MZONE,1,c,statchk,lvchk)
end
function s.filter(c,statchk,lvchk)
	return c:IsFaceup() and (statchk or (lvchk and c:IsLevelAbove(2)))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	local atk,def=tc:GetStats()
	local lv=tc:GetLevel()
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	return atk,def,lv
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if not (chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)) then return false end
		local fe=Duel.GetFlagEffectWithSpecificLabel(tp,id,e:GetChainLink())
		local _,atk,def,lv=fe:GetLabel()
		return s.filter(chkc,atk>0 or def>0,lv>0)
	end
	if chk==0 then
		local IsCostChecked=e:GetLabel()==1
		e:SetLabel(0)
		return IsCostChecked and s.cost(e,tp,eg,ep,ev,re,r,rp,0)
	end
	local atk,def,lv=s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	local tc=Duel.Select(HINTMSG_FACEUP,true,tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,atk>0 or def>0,lv>0):GetFirst()
	local fe=Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	fe:SetLabel(Duel.GetCurrentChain(),atk,def,lv)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,0,-atk)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,tc,1,0,-def)
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,tc,1,0,-lv)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		local fe=Duel.GetFlagEffectWithSpecificLabel(tp,id,Duel.GetCurrentChain())
		if not fe then return end
		local _,atk,def,lv=fe:GetLabel()
		tc:UpdateATKDEF(-atk,-def,{RESET_PHASE|PHASE_END,2},{c,true})
		if lv>0 and tc:HasLevel() then
			xgl.UpdateLevel(tc,-lv,{RESET_PHASE|PHASE_END,2},{c,true})
		end
	end
end