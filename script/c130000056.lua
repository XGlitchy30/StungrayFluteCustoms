--[[
Sunwing Burnswift
Card Author: BraveFrontier
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 Effect Monsters with different names
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,2,s.lcheck)
	--[[If this card is Special Summoned: You can target 1 Attack Position monster on the field; change it to face-up or face-down Defense Position, and if you do,
	this card gains ATK equal to half its original ATK or DEF (whichever is higher), or, if it cannot be changed to Defense Position, banish it.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_POSITION|CATEGORY_ATKCHANGE|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	--[[When an attack is declared involving your opponent's monster while this card is in your GY: You can Special Summon this card, but banish when it leaves the field.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(s.spcon,nil,xgl.SpecialSummonSelfTarget(),xgl.SpecialSummonSelfOperation(LOCATION_REMOVED))
	c:RegisterEffect(e2)
end
function s.lcheck(g,lc,sumtype,tp)
	return g:CheckDifferentProperty(Card.GetCode,lc,sumtype,tp)
end

--E1
function s.filter(c)
	return c:IsAttackPos() and (c:IsCanChangePosition() or c:IsCanTurnSet() or c:IsAbleToRemove())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc)
	end
	if chk==0 then
		return Duel.IsExists(true,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	local tc=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	local category=(tc:IsCanChangePosition() or tc:IsCanTurnSet()) and CATEGORY_POSITION or CATEGORY_REMOVE
	Duel.SetCardOperationInfo(tc,category)
	local c=e:GetHandler()
	local val=math.floor(math.max(tc:GetBaseAttack(),tc:GetBaseDefense())/2)
	Duel.SetConditionalCustomOperationInfo(category==CATEGORY_POSITION,0,CATEGORY_ATKCHANGE,c,1,tp,0,val)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local pos=0
		if not tc:IsPosition(POS_FACEUP_DEFENSE) and tc:IsCanChangePosition() then
			pos=POS_FACEUP_DEFENSE
		end
		if tc:IsCanTurnSet() then
			pos=pos|POS_FACEDOWN_DEFENSE
		end
		if pos~=0 then
			local choice=Duel.SelectPosition(tp,tc,pos)
			if Duel.ChangePosition(tc,choice)>0 and tc:IsRelateToChain() and tc:IsPosition(choice) then
				local c=e:GetHandler()
				if c:IsRelateToChain() and c:IsFaceup() then
					local val=math.floor(math.max(tc:GetBaseAttack(),tc:GetBaseDefense())/2)
					if c:IsCanUpdateATK(val,e,tp,REASON_EFFECT) then
						c:UpdateATK(val,true,c)
					end
				end
			end
		else
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local _,at=Duel.GetBattleMonster(tp)
	return at
end