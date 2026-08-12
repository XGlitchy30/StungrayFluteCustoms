--[[
Rifrazione Cristallo
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")

if not xgl.EnableOriginalTypeMods or not xgl.EnableTrapMonsterSSMods then
	xgl.EnableOriginalTypeMods=true
	xgl.EnableTrapMonsterSSMods=true
	Duel.LoadScript("glitchylib_cardstats.lua",false)
end
function s.initial_effect(c)
	--Send 1 "Crystal Beast" Monster Card from your Spell & Trap Zone to the GY, then target 1 face-up monster your opponent controls; it loses ATK equal to the ATK of the sent monster in the GY until the end of this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetFunctions(aux.StatChangeDamageStepCondition,xgl.DummyCost,s.target,s.activate)
	c:RegisterEffect(e1)
	--If you control "Advanced Dark", except the turn this card was sent to the GY: You can Special Summon this card from your GY as a "Crystal Beast" monster (Rock/DARK/Level 3/ATK 0/DEF 0) (This card is NOT treated as a Trap) with the following effect. 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--● If this card is destroyed in a Monster Zone, you can place it face-up in your Spell & Trap Zone as a Continuous Spell, instead of sending it to the GY, also it is treated as a Monster Card while in the Spell & Trap Zone
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e3:SetCondition(s.repcon)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_ADVANCED_DARK}
s.listed_series={SET_CRYSTAL_BEAST}

--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsMonsterCard() and c:IsSetCard(SET_CRYSTAL_BEAST) and c:GetTextAttack()>0 and c:IsAbleToGraveAsCost()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then
		return e:IsCostChecked() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil) 
			and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
	local atk=g:GetFirst():IsLocation(LOCATION_GRAVE) and g:GetFirst():GetAttack() or 0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tg=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetTargetParam(atk)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tg,#tg,tp,-atk)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		local atk=Duel.GetTargetParam()
		if atk>0 then
			tc:UpdateATK(-atk,RESET_PHASE|PHASE_END,e:GetHandler())
		end
	end
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.exccon(e) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_ADVANCED_DARK),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_CRYSTAL_BEAST,TYPE_MONSTER|TYPE_EFFECT,0,0,3,RACE_ROCK,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_CRYSTAL_BEAST,TYPE_MONSTER|TYPE_EFFECT,0,0,3,RACE_ROCK,ATTRIBUTE_DARK) then
		c:AddMonsterAttribute(TYPE_EFFECT)
		c:AssumeProperty(ASSUME_LEVEL,3)
		c:AssumeProperty(ASSUME_ATTACK,0)
		c:AssumeProperty(ASSUME_DEFENSE,0)
		c:AssumeProperty(ASSUME_ATTRIBUTE,ATTRIBUTE_DARK)
		c:AssumeProperty(ASSUME_RACE,RACE_ROCK)
		if Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP) then
			local reset_flags = RESET_EVENT|(RESETS_STANDARD|RESET_OVERLAY)&~(RESET_TOFIELD|RESET_LEAVE)
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SET_AVAILABLE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_SETCODE)
			e1:SetValue(SET_CRYSTAL_BEAST)
			e1:SetReset(reset_flags)
			c:RegisterEffect(e1,true)
			--Remember Monster Attributes
			local e3=e1:Clone()
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SET_AVAILABLE)
			e3:SetCode(EFFECT_REMEMBER_MONSTER_ATTRIBUTES)
			e3:SetValue(s.monstattr)
			c:RegisterEffect(e3,true)
			c:RegisterFlagEffect(id,reset_flags,0,1)
		end
		c:AddMonsterAttributeComplete()
		Duel.SpecialSummonComplete()
	end
end
function s.monstattr(e,c)
	return {
		cardtype = TYPE_EFFECT,
		attribute = ATTRIBUTE_DARK,
		level = 3,
		race = RACE_ROCK,
		atk = 0,
		def = 0,
	}
end

--E3
function s.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY) and (c:IsSummonType(SUMMON_TYPE_SPECIAL+1) or c:HasFlagEffect(id))
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Treated as a Continuous Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,3)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
	c:RegisterEffect(e1)
	--Treated as a Monster Card
	local e2=e1:Clone()
	e2:SetDescription(id,4)
	e2:SetCode(EFFECT_ADD_ORIGINAL_TYPE)
	e2:SetValue(TYPE_MONSTER)
	c:RegisterEffect(e2)

	Duel.RaiseEvent(c,EVENT_CUSTOM+CARD_CRYSTAL_TREE,e,0,tp,0,0)
end
