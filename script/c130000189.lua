--[[
Metalion Space Fighter N322
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")

if not Gradius then
	Gradius = {}
	Duel.LoadScript("glitchylib_archetypes.lua",false)
end

function s.initial_effect(c)
	--If you Normal Summon a LIGHT Machine monster(s) (except during the Damage Step): You can Special Summon this card from your GY (if it was there when the monster was Normal Summoned) or hand (even if not), but banish it when it leaves the field.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCondition(s.spcon)
	e1:SetSpecialSummonSelfFunctions(false,LOCATION_REMOVED)
	c:RegisterEffect(e1)
	--When your LIGHT Machine monster with the effect "If this card destroys an opponent's monster by battle", or "Vic Viper T301" attacks, your opponent cannot activate cards or effects until the end of the Damage Step.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.actcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--[[If this card destroys an opponent's monster by battle: Activate 1 of these effects;
	● LIGHT Machine monsters you control can make an additional attack this Battle Phase.
	● Monsters your opponent controls lose 500 ATK.
	● Special Summon 1 "Option Warrior Token" (Machine/LIGHT/Level 4/ATK 1400/DEF 1200).]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCustomCategory(0,CATEGORY_FLAG_ALPINIA)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	Gradius.RegisterAlpiniaCopyCheck(s)
end
s.listed_names={CARD_VIC_VIPER_T301,TOKEN_OPTION_WARRIOR}

--E1
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ep==tp and ec:IsFaceup() and ec:IsAttributeRace(ATTRIBUTE_LIGHT,RACE_MACHINE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.cfilter(c)
	if not c:IsFaceup() then return false end
	if c:IsCode(CARD_VIC_VIPER_T301) then return true end
	if c:IsLocation(LOCATION_MZONE) and c:IsAttributeRace(ATTRIBUTE_LIGHT,RACE_MACHINE) and c:IsType(TYPE_EFFECT) then
		local eset={c:GetOwnEffects()}
		for _,e in ipairs(eset) do
			if e:IsHasCustomCategory(0,CATEGORY_FLAG_ALPINIA) then
				return true
			end
		end
		
		if Gradius.AlpiniaTable[c:GetOriginalCode()] or c:HasFlagEffect(CARD_ALPINIA) then
			return true
		end
	end
	return false
end
function s.actcon(e)
	local ac=Duel.GetAttacker()
	return ac and ac:IsControler(e:GetHandlerPlayer()) and s.cfilter(ac)
end

--E3
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetProperty(0)
	e:SetCategory(0)
	local c=e:GetHandler()
	local g=Duel.Group(aux.FaceupFilter(Card.HasAttack),tp,0,LOCATION_MZONE,nil)
	local b1=xgl.IsBattlePhase(tp)
	local b2=#g>0
	local b3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_OPTION_WARRIOR,0,TYPES_TOKEN,1400,1200,4,RACE_MACHINE,ATTRIBUTE_LIGHT)
	local op=xgl.Option(tp,id,2,b1,b2,b3)
	if op==0 then
		e:SetCategory(0)
	elseif op==1 then
		e:SetCategory(CATEGORY_ATKCHANGE)
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,-500)
	elseif op==2 then
		e:SetCategory(CATEGORIES_TOKEN)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	else
		return
	end
	Duel.SetTargetParam(op)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=Duel.GetTargetParam()
	if op==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetCustomCategory(0,CATEGORY_FLAG_INCREMENTAL)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsAttributeRace,ATTRIBUTE_LIGHT,RACE_MACHINE))
		e1:SetValue(s.atkval)
		e1:SetReset(RESET_PHASE|PHASE_BATTLE)
		Duel.RegisterEffect(e1,tp)
		
	elseif op==1 then
		local g=Duel.Group(aux.FaceupFilter(Card.HasAttack),tp,0,LOCATION_MZONE,nil)
		for tc in g:Iter() do
			tc:UpdateATK(-500,true,{c,true})
		end
	
	elseif op==2 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_OPTION_WARRIOR,0,TYPES_TOKEN,1400,1200,4,RACE_MACHINE,ATTRIBUTE_LIGHT) then return end
		local token=Duel.CreateToken(tp,TOKEN_OPTION_WARRIOR)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.atkval(e,c,return_only_incr)
	if return_only_incr then return 1 end
	local ct=c:GetAttackAnnouncedCount()
	local extra_total_base, extra_total_incr = 0, 0
	local eset={c:GetCardEffect(EFFECT_EXTRA_ATTACK)}
	for _,ce in ipairs(eset) do
		if ce:IsHasCustomCategory(nil,CATEGORY_FLAG_INCREMENTAL) then
			local n=ce:Evaluate(c,true)
			extra_total_incr = extra_total_incr + n
		else
			local n=ce:Evaluate(c)
			extra_total_base = math.max(n,extra_total_base)
		end
	end
	local a=Duel.GetAttacker()
	local extra_total=extra_total_base + extra_total_incr + 1
	if ct<extra_total or (ct==extra_total and a and a==c) then
		return ct
	else
		return 0
	end
end