--[[
Evil★Twins Loving Embrace
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2+ monsters, including an "Evil★Twin" monster
	Link.AddProcedure(c,nil,2,4,s.lcheck)
	--(Quick Effect): You can Tribute this card; Special Summon 1 "Ki-sikil" or 1 "Lil-la" monster from your GY, then lose LP equal to its ATK.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(Cost.SelfTribute)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--You can banish this card from your GY, then target 4 "Evil★Twin" and/or "Live☆Twin" monsters in your GY and/or banishment (2 "Ki-sikil and 2 "Lil-la"): shuffle them into the Deck, and if you do, draw 1 card.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.drawtg)
	e2:SetOperation(s.drawop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_KI_SIKIL,SET_LIL_LA,SET_EVIL_TWIN,SET_LIVE_TWIN}

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_EVIL_TWIN,lc,sumtype,tp)
end

--E1
function s.spfilter(c,e,tp)
	return c:IsSetCard({SET_KI_SIKIL,SET_LIL_LA}) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMZoneCount(tp,e:IsCostChecked() and e:GetHandler() or nil)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local tc=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsFaceup() then
		Duel.BreakEffect()
		Duel.LoseLP(tp,tc:GetAttack())
	end
end

--E2
function s.tgfilter(c,e)
	return c:IsFaceupEx() and c:IsMonster() and c:IsSetCard({SET_EVIL_TWIN,SET_LIVE_TWIN}) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.rescon(g,e,tp,mg,c)
	local g1=g:Filter(Card.IsSetCard,nil,SET_KI_SIKIL)
	local g2=g:Filter(Card.IsSetCard,nil,SET_LIL_LA)
	
	local valid = #g1>=2 and #g2>=2
	
	local razor
	if #g1==2 and #g2==0 then
		razor = {Card.IsSetCard,SET_LIL_LA}
	elseif #g2==2 and #g1==0 then
		razor = {Card.IsSetCard,SET_KI_SIKIL}
	end
	
	return valid,false,razor
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local exc=(e:IsCostChecked() and chk==0) and e:GetHandler() or nil
	local g=Duel.Group(s.tgfilter,tp,LOCATION_GB,0,exc,e)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1) and xgl.SelectUnselectGroup(0,g,e,tp,4,4,s.rescon,0)
	end
	local tg=xgl.SelectUnselectGroup(0,g,e,tp,4,4,s.rescon,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(tg)
	Duel.SetCardOperationInfo(tg,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end