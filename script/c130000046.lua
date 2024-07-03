--[[
Wiccink Seal
Card Author: Aurora
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If you control no non-Spellcaster monsters: Special Summon 1 "Wiccink Token" (Spellcaster/EARTH/Level 2/ATK 300/DEF 300),
	but it cannot be Tributed or used as material for a Synchro or Link Summon]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[During the Damage Step, if a "Wiccink Token" you control battles: You can banish this card from your GY; double its original ATK/DEF for that battle only]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_ATKDEF)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(s.atkcon,aux.bfgcost,s.atktg,s.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	c:RegisterEffect(e3)
end
s.listed_names={TOKEN_WICCINK}
s.listed_series={SET_WICCINK}

--E1
function s.cfilter(c)
	return c:IsFacedown() or c:GetRace()~=RACE_SPELLCASTER
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_WICCINK,SET_WICCINK,TYPES_TOKEN,300,300,2,RACE_SPELLCASTER,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if s.target(e,tp,eg,ep,ev,re,r,rp,0) then
		local c=e:GetHandler()
		local token=Duel.CreateToken(tp,TOKEN_WICCINK)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			token:CannotBeTributed(1,nil,true,c)
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(130000043,2)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
			e1:SetValue(aux.cannotmatfilter(SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_LINK))
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1)
		end
		Duel.SpecialSummonComplete()
	end
end

--E2
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetBattleMonster(tp)
	return bc and bc:IsFaceup() and bc:IsCode(TOKEN_WICCINK) and bc:IsRelateToBattle()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.atkcon(e,tp,eg,ep,ev,re,r,rp) end
	local bc=Duel.GetBattleMonster(tp)
	Duel.SetTargetCard(bc)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,bc,1,tp,LOCATION_MZONE,{bc:GetBaseAttack()*2})
	Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,bc,1,tp,LOCATION_MZONE,{bc:GetBaseDefense()*2})
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsRelateToBattle() and tc:IsFaceup() then
		local oatk,odef=tc:GetBaseAttack(),tc:GetBaseDefense()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
		e1:SetValue(oatk*2)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(odef*2)
		tc:RegisterEffect(e2)
	end
end