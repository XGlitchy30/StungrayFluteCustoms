--[[
Vic Viper Prototype: T-300
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
	--[[If this card destroys an opponent's monster by battle: Activate 1 of these effects.
	● Target 1 LIGHT Machine monster with the effect "If this card destroys an opponent's monster by battle", or "Vic Viper T301"; it can make an additional attack during this Battle Phase.
	● Special Summon 1 "Prototype Option Token" (LIGHT/Machine/Level 4/ATK 1200/DEF 800), and if you do, if it battles an opponent's monster, at the end of the Damage Step, destroy that opponent's monster, also destroy that Token.
	● Special Summon 1 "Uska Token" (DARK/Machine/Level 1/ATK 500/DEF 0) to your opponent's field in Attack Position.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCustomCategory(0,CATEGORY_FLAG_ALPINIA)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	Gradius.RegisterAlpiniaCopyCheck(s)
end
s.listed_names={CARD_VIC_VIPER_T301,TOKEN_PROTOTYPE_OPTION,TOKEN_USKA}

--E1
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

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetProperty(0)
	e:SetCategory(0)
	local c=e:GetHandler()
	local b1=xgl.IsBattlePhase(tp) and Duel.IsExists(true,s.cfilter,tp,LOCATION_MZONE,0,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_PROTOTYPE_OPTION,0,TYPES_TOKEN,1200,800,4,RACE_MACHINE,ATTRIBUTE_LIGHT)
	local b3=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_USKA,0,TYPES_TOKEN,500,0,1,RACE_MACHINE,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,1-tp)
	local op=xgl.Option(tp,id,1,b1,b2,b3)
	if op==0 then
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Select(HINTMSG_TARGET,true,tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	elseif op==1 then
		e:SetCategory(CATEGORIES_TOKEN)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
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
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(id,4)
			e1:SetCustomCategory(0,CATEGORY_FLAG_INCREMENTAL)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetValue(s.atkval)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
			tc:RegisterEffect(e1)
		end
		
	elseif op==1 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_PROTOTYPE_OPTION,0,TYPES_TOKEN,1200,800,4,RACE_MACHINE,ATTRIBUTE_LIGHT) then return end
		local token=Duel.CreateToken(tp,TOKEN_PROTOTYPE_OPTION)
		if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(id,5)
			e1:SetCategory(CATEGORY_DESTROY)
			e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_DAMAGE_STEP_END)
			e1:SetLabelObject(token)
			e1:SetOperation(s.desop)
			Duel.RegisterEffect(e1,tp)
		end
	
	elseif op==2 then
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_USKA,0,TYPES_TOKEN,500,0,1,RACE_MACHINE,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,1-tp) then return end
		local token=Duel.CreateToken(tp,TOKEN_USKA)
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
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
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	if c and Duel.GetAttacker()==c or Duel.GetAttackTarget()==c then
		local tc=c:GetBattleTarget()
		if tc and ((tc:IsRelateToBattle() and tc:IsControler(1-tp)) or (not tc:IsRelateToBattle() and tc:IsPreviousControler(1-tp))) then
			Duel.Hint(HINT_CARD,tp,TOKEN_PROTOTYPE_OPTION)
			local g=Group.FromCards(c,tc):Filter(Card.IsRelateToBattle,nil)
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end