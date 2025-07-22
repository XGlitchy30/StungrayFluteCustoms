--[[
Is Lady Luck On Your Side?
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchylib_delayed_event.lua")
function s.initial_effect(c)
	--When this card is activated: You can add 1 "Lady Luck" monster from your Deck to your hand.
	local e0=c:Activation(nil,nil,nil,nil,s.target,s.activate,true)
	e0:SetCategory(CATEGORIES_SEARCH)
	c:RegisterEffect(e0)
	--[[Once per Chain, if a die (or dice) is rolled (except during the Damage Step): You can choose 1 result from among those dice; "Lady Luck" monsters you currently control gain ATK equal to 100 x that result until the end of this turn.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,EVENT_TOSS_DICE,nil,id,LOCATION_SZONE,nil,LOCATION_SZONE,s.transferResults,nil,nil,s.storeResults,true,nil,true)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_SZONE)
	e1:OPC()
	e1:SetFunctions(
		aux.MergedDelayedEventCondition,
		nil,
		s.atktg,
		s.atkop
	)
	c:RegisterEffect(e1)
	--[[If a "Lady Luck" monster(s) you control is sent to the GY, even during the Damage Step: You can roll a six-sided die, then apply the appropriate effect based on the result.
	● 1, 2 or 3: Special Summon 1 "Lady Luck Token" (Fairy/Tuner/LIGHT/ Level 1/ATK 600/ DEF 600) in Defense Position.
	● 4, 5 or 6: Banish this card, and if you do, Special Summon 1 "Lady Luck" monster from your Deck during your 2nd Standby Phase after this effect's activation.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DICE|CATEGORIES_TOKEN|CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:HOPT()
	e2:SetFunctions(
		xgl.EventGroupCond(s.cfilter),
		nil,
		s.dicetg,
		s.diceop
	)
	c:RegisterEffect(e2)
end
s.listed_series={SET_LADY_LUCK}
s.roll_dice=true

local FLAG_SAVED_RESULT 			= id
local FLAG_TRANSFERRED_RESULT 		= id+100
local PFLAG_USED_ACTIVATION_EFFECT	= id

--E0
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if not Duel.PlayerHasFlagEffect(tp,PFLAG_USED_ACTIVATION_EFFECT) then
		e:SetCategory(CATEGORIES_SEARCH)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(0)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_LADY_LUCK) and c:IsMonster() and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.PlayerHasFlagEffect(tp,PFLAG_USED_ACTIVATION_EFFECT) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,STRING_ASK_SEARCH) then
		Duel.RegisterFlagEffect(tp,PFLAG_USED_ACTIVATION_EFFECT,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.Search(g)
		end
	end
end

--E1
function s.storeResults(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local dc={Duel.GetDiceResult()}
	local ct=(ev&0xff)+(ev>>16)
	for i=1,ct do
		c:RegisterFlagEffect(FLAG_SAVED_RESULT,RESET_EVENT|RESETS_STANDARD,0,1,dc[i])
	end
end
function s.transferResults(e,tp,eg,ep,ev,re,r,rp,obj)
	local c=e:GetOwner()
	c:ResetFlagEffect(FLAG_TRANSFERRED_RESULT)
	for _,res in ipairs({c:GetFlagEffectLabel(FLAG_SAVED_RESULT)}) do
		c:RegisterFlagEffect(FLAG_TRANSFERRED_RESULT,RESET_EVENT|RESETS_STANDARD,0,1,res)
	end
	c:ResetFlagEffect(FLAG_SAVED_RESULT)
	return MERGED_ID
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 and c:HasFlagEffect(FLAG_TRANSFERRED_RESULT) end
	local results={}
	for _,res in ipairs({c:GetFlagEffectLabel(FLAG_TRANSFERRED_RESULT)}) do
		if not xgl.FindInTable(results,res) then
			table.insert(results,res)
		end
	end
	c:ResetFlagEffect(FLAG_TRANSFERRED_RESULT)
	table.sort(results)
	local n
	if #results>1 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
		n=Duel.AnnounceNumber(tp,table.unpack(results))
	else
		n=results[1]
		Duel.Hint(HINT_NUMBER,tp,n)
		Duel.Hint(HINT_NUMBER,1-tp,n)
	end
	local val=n*100
	Duel.SetTargetParam(val)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,val)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local val=Duel.GetTargetParam()
	local g=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil)
	for tc in g:Iter() do
		tc:UpdateATK(val,RESET_PHASE|PHASE_END,{c,true})
	end
end

--E2
function s.cfilter(c,_,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousSetCard(SET_LADY_LUCK)
		and c:IsMonster() and c:IsSetCard(SET_LADY_LUCK)
end
function s.dicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LADY_LUCK,SET_LADY_LUCK,TYPES_TOKEN|TYPE_TUNER,600,600,1,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE)
		local b2=c:IsAbleToRemove()
		return b1 or b2
	end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	if d>=1 and d<=3 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,2))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
			Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LADY_LUCK,SET_LADY_LUCK,TYPES_TOKEN|TYPE_TUNER,600,600,1,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE) then
			local token=Duel.CreateToken(tp,TOKEN_LADY_LUCK)
			Duel.BreakEffect()
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
		
	elseif d>3 and d<=6 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,3))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
		local c=e:GetHandler()
		if c:IsRelateToChain() and c:IsAbleToRemove() then
			Duel.BreakEffect()
			if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 then
				xgl.DelayedOperation(nil,PHASE_STANDBY,nil,e,tp,s.spop,s.spcon,RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,2,nil,aux.Stringid(id,6))
			end
		end
	end
end
function s.spcon(_,e,tp,eg,ep,ev,re,r,rp,turncount)
	if Duel.GetTurnPlayer()~=tp then return false end
	local ct=e:GetLabel()
	e:GetOwner():SetTurnCounter(ct+1)
	if ct==1 then
		return true
	else
		e:SetLabel(ct+1)
		return false
	end
end
function s.spop(_,e,tp,eg,ep,ev,re,r,rp,turncount)
	Duel.Hint(HINT_CARD,tp,id)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_LADY_LUCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end