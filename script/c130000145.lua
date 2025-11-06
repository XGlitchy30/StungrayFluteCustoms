--[[
Ancestagon Brachion, The Fortress of Extinction
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchymods_MR3spsummon.lua")
function s.initial_effect(c)
	c:Activation()
	--[[Once per turn, if an "Ancestagon" monster(s) is Tributed (except during the Damage Step): You can Special Summon 1 "Ancestagon Token" (Dinosaur/FIRE/Level 2/0 ATK/0 DEF), but that Token cannot be used as material to Summon a monster from the Extra Deck, except for the Summon of an "Ancestagon" monster.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_TOKEN)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e1:SetCode(EVENT_RELEASE)
	e1:SetRange(LOCATION_FZONE)
	e1:OPT()
	e1:SetFunctions(
		xgl.EventGroupCond(s.cfilter),
		nil,
		s.tktg,
		s.tkop
	)
	c:RegisterEffect(e1)
	--[[While you control 2 "Ancestagon" cards in your Pendulum Zones, you can Special Summon "Ancestagon" Pendulum Monsters from your face-up Extra Deck to your Main Monster Zones as if they were linked, but if you do so by this effect, you cannot Special Summon monsters from your Extra Deck for the rest of that turn, except "Ancestagon" monsters.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_ALLOW_MR3_SPSUMMON_FROM_ED)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetValue(0x1f)
	c:RegisterEffect(e2)
	
end
s.listed_names={TOKEN_ANCESTAGON}
s.listed_series={SET_ANCESTAGON}

--E1
function s.cfilter(c)
	local current_state = not c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsMonsterType() and c:IsSetCard(SET_ANCESTAGON)
	local previous_state = c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousSetCard(SET_ANCESTAGON)
	return current_state or previous_state
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ANCESTAGON,SET_ANCESTAGON,TYPES_TOKEN,0,0,2,RACE_DINOSAUR,ATTRIBUTE_FIRE) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if s.tktg(e,tp,eg,ep,ev,re,r,rp,0) then
		local token=Duel.CreateToken(tp,TOKEN_ANCESTAGON)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			local c=e:GetHandler()
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(id,3)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
			e1:SetValue(s.matlimit)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1,true)
		end
		Duel.SpecialSummonComplete()
	end
end
function s.matlimit(e,sc,sumtype,tp)
	if sc:IsSetCard(SET_ANCESTAGON) then return false end
	local not_allowed={SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK}
	local sum=(SUMMON_TYPE_FUSION|SUMMON_TYPE_SYNCHRO|SUMMON_TYPE_XYZ|SUMMON_TYPE_LINK)&sumtype
	for _,val in pairs(not_allowed) do
		if sum==val then return true end
	end
	return false
end

--E2
function s.spcon(e)
	return Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,SET_ANCESTAGON),e:GetHandlerPlayer(),LOCATION_PZONE,0,2,nil)
end
function s.sptg(e,c)
	return c:IsFaceup() and c:IsControler(e:GetHandlerPlayer()) and c:IsType(TYPE_PENDULUM) and c:IsSetCard(SET_ANCESTAGON)
end
function s.spop(e,tp,up,sc)
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,tp,id)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,2)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splim)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.addTempLizardCheck(c,tp,function(_,c) return not c:IsOriginalSetCard(SET_ANCESTAGON) end)
end
function s.splim(_,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_ANCESTAGON)
end