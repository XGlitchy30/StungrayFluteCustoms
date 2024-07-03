--[[
Wiccink Brand
Card Author: Aurora
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Target 1 "Wiccink Token" you control; send 1 "Wiccink" Spell from your Deck to the GY, and if you do, double that monster's original ATK/DEF until the end of your opponent's next turn]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORIES_ATKDEF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[At the start of the Battle Phase, if you control no Tokens: You can banish this card from your GY; Special Summon 1 "Wiccink Token" (Spellcaster/EARTH/Level 2/ATK 300/DEF 300),
	and if you do, you take no Battle Damage from battles involving it until the end of this turn, also it cannot be Tributed or used as material for a Synchro or Link Summon]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
	e2:SetRange(LOCATION_GRAVE)
	e2:OPT()
	e2:SetFunctions(s.spcon,aux.bfgcost,s.sptg,s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_WICCINK}
s.listed_series={SET_WICCINK}

--E1
function s.filter(c)
	return c:IsFaceup() and c:IsCode(TOKEN_WICCINK)
end
function s.tgfilter(c)
	return c:IsSpell() and c:IsSetCard(SET_WICCINK) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExists(true,s.filter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExists(false,s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,LOCATION_MZONE,{tc:GetBaseAttack()*2})
	Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,tp,LOCATION_MZONE,{tc:GetBaseDefense()*2})
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGraveAndCheck(g) then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and tc:IsFaceup() then
			local oatk,odef=tc:GetBaseAttack(),tc:GetBaseDefense()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_OPPO_TURN,Duel.GetNextPhaseCount(PHASE_END,1-tp))
			e1:SetValue(oatk*2)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_BASE_DEFENSE)
			e2:SetValue(odef*2)
			tc:RegisterEffect(e2)
		end
	end
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExists(false,aux.FaceupFilter(Card.IsType,TYPE_TOKEN),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_WICCINK,SET_WICCINK,TYPES_TOKEN,300,300,2,RACE_SPELLCASTER,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if s.sptg(e,tp,eg,ep,ev,re,r,rp,0) then
		local c=e:GetHandler()
		local token=Duel.CreateToken(tp,TOKEN_WICCINK)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			token:CannotBeTributed(1,nil,true,c)
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(id,2)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
			e1:SetValue(aux.cannotmatfilter(SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_LINK))
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(STRING_AVOID_BATTLE_DAMAGE)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			token:RegisterEffect(e2)
		end
		Duel.SpecialSummonComplete()
	end
end