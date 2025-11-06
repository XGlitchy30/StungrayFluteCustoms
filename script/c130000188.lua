--[[
Alpinia
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
	--If you control a LIGHT Machine monster with the effect "If this card destroys an opponent's monster by battle", or if you control "Vic Viper T301", you can Special Summon this card (from your hand).
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT(true)
	e1:SetCondition(xgl.LocationGroupCond(s.cfilter,LOCATION_ONFIELD,0))
	c:RegisterEffect(e1)
	--[[If this card destroys an opponent's monster by battle: Activate 1 of these effects.
	● Target 1 LIGHT Machine monster you control with the effect "If this card destroys an opponent's monster by battle", then choose 1 of its effects that activates when it destroys an opponent's monster by battle; this effect becomes that chosen effect.
	● Double this card's ATK.
	● Special Summon 1 "Alpine Token" with the same Type, Attribute, Level, and ATK/DEF as this card, but destroy it if this card leaves the field.]]
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
s.listed_names={CARD_VIC_VIPER_T301,TOKEN_ALPINE}

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

--E2
function s.tgfilter(c,eff,tp,eg,ep,ev,re,r,rp,chk)
	if not (c:IsFaceup() and c:IsAttributeRace(ATTRIBUTE_LIGHT,RACE_MACHINE) and c:IsType(TYPE_EFFECT)) then return false end
	local isInAlpiniaTable = Gradius.AlpiniaTable[c:GetOriginalCode()] or c:HasFlagEffect(CARD_ALPINIA)
	local eset={c:GetOwnEffects()}
	for _,e in ipairs(eset) do
		if e:IsHasCustomCategory(0,CATEGORY_FLAG_ALPINIA) or (isInAlpiniaTable and Gradius.hasHardcodedAlpiniaMarker(e)) then
			local tg=e:GetTarget()
			if not tg or tg(eff,tp,eg,ep,ev,re,r,rp,chk) then
				return true
			end
		end
	end
	
	return false
end
function s.filter2(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAttackBelow(1200)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local eff=e:GetLabelObject()
		if not eff then return false end
		local tg=eff:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	end
	if chk==0 then return true end
	e:SetProperty(0)
	e:SetCategory(0)
	local c=e:GetHandler()
	local b1=not Duel.PlayerHasFlagEffect(tp,id) and Duel.IsExists(true,s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,eg,ep,ev,re,r,rp,0)
	local b2=c:HasAttack()
	local b3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ALPINE,0,TYPES_TOKEN,c:GetAttack(),c:GetDefense(),c:GetLevel(),c:GetRace(),c:GetAttribute())
	local op=xgl.Option(tp,id,2,b1,b2,b3)
	if op==0 then
		Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local tc=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp,0):GetFirst()
		local available_effs, descs = {}, {}
		local isInAlpiniaTable = Gradius.AlpiniaTable[tc:GetOriginalCode()] or tc:HasFlagEffect(CARD_ALPINIA)
		local eset={tc:GetOwnEffects()}
		for _,ce in ipairs(eset) do
			if ce:IsHasCustomCategory(0,CATEGORY_FLAG_ALPINIA) or (isInAlpiniaTable and Gradius.hasHardcodedAlpiniaMarker(ce)) then
				local tg=ce:GetTarget()
				if not tg or tg(e,tp,eg,ep,ev,re,r,rp,0) then
					table.insert(available_effs,ce)
					table.insert(descs,ce:GetDescription())
				end
			end
		end
		
		local chosen_e
		if #available_effs>1 then
			local desc=Duel.SelectOption(tp,table.unpack(descs))
			chosen_e=available_effs[desc+1]
		else
			chosen_e=available_effs[1]
		end
		Duel.Hint(HINT_OPSELECTED,1-tp,chosen_e:GetDescription())
		local tg=chosen_e:GetTarget()
		if tg then
			e:SetProperty(chosen_e:GetProperty())
			tg(e,tp,eg,ep,ev,re,r,rp,chk)
		end
		local copied_obj=e:GetLabelObject()
		chosen_e:SetLabelObject(copied_obj)
		e:SetLabelObject(chosen_e)
		Duel.ClearOperationInfo(0)
		
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	elseif op==1 then
		e:SetCategory(CATEGORY_ATKCHANGE)
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,c:GetAttack()*2)
	elseif op==2 then
		e:SetCategory(CATEGORIES_TOKEN)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	else
		return
	end
	local copied_labels={e:GetLabel()}
	table.insert(copied_labels,op)
	e:SetLabel(table.unpack(copied_labels))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local isHandlerRelate=c:IsFaceup() and c:IsRelateToChain()
	local labels={e:GetLabel()}
	local op=table.remove(labels)
	if #labels>0 then
		e:SetLabel(table.unpack(labels))
	else
		e:SetLabel(0)
	end
	if op==0 then
		local eff=e:GetLabelObject()
		if not eff then return end
		local oper=eff:GetOperation()
		if oper then
			e:SetLabelObject(eff:GetLabelObject())
			oper(e,tp,eg,ep,ev,re,r,rp)
		end
		e:SetLabelObject(nil)
		
	elseif op==1 and isHandlerRelate then
		c:DoubleATK(true)
	
	elseif op==2 and isHandlerRelate then
		local atk=c:GetAttack()
		local def=c:GetDefense()
		local lv=c:GetLevel()
		local race=c:GetRace()
		local att=c:GetAttribute()
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ALPINE,0,TYPES_TOKEN,atk,def,lv,race,att) then return end
		local token=Duel.CreateToken(tp,TOKEN_ALPINE)
		c:CreateRelation(token,RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			local reset=RESET_EVENT|(RESETS_STANDARD&~RESET_TOFIELD)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(atk)
			e1:SetReset(reset)
			token:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetValue(def)
			token:RegisterEffect(e2,true)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CHANGE_LEVEL)
			e3:SetValue(lv)
			e3:SetReset(reset)
			token:RegisterEffect(e3,true)
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_CHANGE_RACE)
			e4:SetValue(race)
			e4:SetReset(reset)
			token:RegisterEffect(e4,true)
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e5:SetValue(att)
			e5:SetReset(reset)
			token:RegisterEffect(e5,true)
			local e6=Effect.CreateEffect(c)
			e6:SetType(EFFECT_TYPE_SINGLE)
			e6:SetCode(EFFECT_SELF_DESTROY)
			e6:SetCondition(s.tokendes)
			e6:SetReset(reset)
			token:RegisterEffect(e6,true)
		end
		Duel.SpecialSummonComplete()
	end
end
function s.tokendes(e)
	return not e:GetOwner():IsRelateToCard(e:GetHandler())
end