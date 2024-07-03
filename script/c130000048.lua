--[[
Wiccink Anatomy
Card Author: Aurora
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[When your opponent declares a direct attack: Special Summon 1 "Wiccink Token" (Spellcaster/EARTH/Level 2/ATK 300/DEF 300), and if you do,
	it cannot be destroyed by that battle, also it cannot be Tributed or used as material for a Synchro or Link Summon]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If a card or effect is activated (except during the Damage Step): You can banish this card from your GY;
	double the original ATK/DEF of 1 "Wiccink Token" you control until the end of this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_ATKDEF)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetFunctions(nil,aux.bfgcost,s.atktg,s.atkop)
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_WICCINK}
s.listed_series={SET_WICCINK}

--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer() and Duel.GetAttackTarget()==nil
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
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
			token:RegisterEffect(e2)
		end
		Duel.SpecialSummonComplete()
	end
end

--E2
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(aux.FaceupFilter(Card.IsCode,TOKEN_WICCINK),tp,LOCATION_MZONE,0,nil)
	if chk==0 then
		return #g>0
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,1,tp,LOCATION_MZONE,0,OPINFO_FLAG_FUNCTION,s.opinfofunc1)
	Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,g,1,tp,LOCATION_MZONE,0,OPINFO_FLAG_FUNCTION,s.opinfofunc2)
end
function s.opinfofunc1(c)
	return {c:GetBaseAttack()*2}
end
function s.opinfofunc2(c)
	return {c:GetBaseDefense()*2}
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Select(HINTMSG_FACEUP,false,tp,aux.FaceupFilter(Card.IsCode,TOKEN_WICCINK),tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		local oatk,odef=tc:GetBaseAttack(),tc:GetBaseDefense()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		e1:SetValue(oatk*2)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(odef*2)
		tc:RegisterEffect(e2)
	end
end