--[[
Wiccink Flurry
Card Author: Aurora
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:Activation()
	--[[Once per turn, if your opponent Normal or Special Summons a monster(s) (except during the Damage Step): You can target 1 "Wiccink" Spell in your banishment; add it to your hand. ]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_SZONE)
	e1:OPT()
	e1:SetFunctions(s.thcon,nil,s.thtg,s.thop)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[Once per turn, during the End Phase, if you control no Tokens: Special Summon 1 "Wiccink Token" (Spellcaster/EARTH/Level 2/ATK 300/DEF 300) in Attack Position, and if you do, double its original ATK/DEF until the end of your opponent's next turn, also it cannot be Tributed or used as material for a Synchro or Link Summon.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE|PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:OPT()
	e2:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_WICCINK}
s.listed_series={SET_WICCINK}

--E1
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsSpellType() and c:IsSetCard(SET_WICCINK) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Search(tc)
	end
end

--E2
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOKEN)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExists(false,s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_WICCINK,SET_WICCINK,TYPES_TOKEN,300,300,2,RACE_SPELLCASTER,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) then
		local c=e:GetHandler()
		local token=Duel.CreateToken(tp,TOKEN_WICCINK)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
			token:CannotBeTributed(1,nil,true,c)
			local e0=Effect.CreateEffect(c)
			e0:SetDescription(130000043,2)
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e0:SetCode(EFFECT_CANNOT_BE_MATERIAL)
			e0:SetValue(aux.cannotmatfilter(SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_LINK))
			e0:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e0)
			local oatk,odef=token:GetBaseAttack(),token:GetBaseDefense()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_OPPO_TURN,Duel.GetNextPhaseCount(PHASE_END,1-tp))
			e1:SetValue(oatk*2)
			token:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_BASE_DEFENSE)
			e2:SetValue(odef*2)
			token:RegisterEffect(e2)
		end
		Duel.SpecialSummonComplete()
	end
end