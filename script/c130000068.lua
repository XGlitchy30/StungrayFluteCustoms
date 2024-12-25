--[[
Hieratic Dragon Priest of Anub
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--[[If this card is Ritual Summoned: You can shuffle any number of "Hieratic" monsters from your GY into your Deck, and if you do, draw 1 card for every 3 cards shuffled into the Deck this way.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		xgl.RitualSummonedCond,
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e1)
	--[[You can Tribute 1 "Hieratic" card you control, then activate the appropriate effect, depending on what was Tributed.
	● Monster: Add 1 Spell/Trap from your GY to your hand.
	● Spell/Trap: Special Summon 1 "Hieratic" monster from your GY, but its ATK/DEF become 0.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(nil,xgl.LabelCost,s.tg,s.op)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_HIERATIC_AWAKENING}
s.listed_series={SET_HIERATIC}

--E1
function s.tdfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_HIERATIC) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(aux.Necro(s.tdfilter),tp,LOCATION_GRAVE,0,nil)
	if #g==0 then return end
	Duel.HintMessage(tp,HINTMSG_TODECK)
	local tg=g:Select(tp,1,#g,nil)
	if Duel.Highlight(tg) and Duel.ShuffleIntoDeck(tg)>0 then
		local ct=Duel.GetGroupOperatedByThisEffect(e):FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
		if ct>=3 then
			Duel.Draw(tp,math.floor(ct/3),REASON_EFFECT)
		end
	end
end

--E2
function s.thfilter(c)
	return c:IsSpellTrap() and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_HIERATIC) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rlcheck(g,tp,exg,e)
	local c=g:GetFirst()
	if c:IsLocation(LOCATION_MZONE) and Duel.IsExists(false,s.thfilter,tp,LOCATION_GRAVE,0,1,nil) then
		return true
	elseif c:IsSpellTrap() and Duel.GetMZoneCount(tp,c)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) then
		return true
	else
		return false
	end
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local extraGroup=Duel.Group(aux.FilterBoolFunction(Card.IsSetCard,SET_HIERATIC),tp,LOCATION_SZONE,0,nil):Filter(Card.IsReleasable,nil)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return xgl.CheckReleaseGroupCost(tp,aux.FilterBoolFunction(Card.IsSetCard,SET_HIERATIC),1,1,extraGroup,false,s.rlcheck,nil,e)
	end
	e:SetLabel(0)
	Duel.HintMessage(tp,HINTMSG_RELEASE)
	local rc=xgl.SelectReleaseGroupCost(tp,aux.FilterBoolFunction(Card.IsSetCard,SET_HIERATIC),1,1,extraGroup,false,s.rlcheck,nil,e):GetFirst()
	local opt=0
	if rc:IsLocation(LOCATION_MZONE) and Duel.IsExists(false,s.thfilter,tp,LOCATION_GRAVE,0,1,nil) then opt=1 end
	if rc:IsSpellTrap() and Duel.GetMZoneCount(tp,rc)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) then opt=opt|2 end
	Duel.Release(rc,REASON_COST)
	if opt==3 then
		opt=aux.Option(tp,id,2,true,true)+1
	end
	Duel.SetTargetParam(opt)
	if opt==1 then
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	elseif opt==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	if opt==1 then
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.Search(g)
		end
	elseif opt==2 and Duel.GetMZoneCount(tp)>0 then
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_DEFENSE)
			tc:RegisterEffect(e2,true)
		end
		Duel.SpecialSummonComplete()
	end
end