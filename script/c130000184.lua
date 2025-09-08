--[[
Vergerossa, the Sylvan High Keeper
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2+ Level 1 "Sylvan" monsters
	--Once per turn, you can also Xyz Summon "Vergerossa, the Sylvan High Keeper" by using 1 "Grovenor, the Sylvan Uniter" you control as material, but it cannot be used as Xyz Material this turn.
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SYLVAN),1,2,s.ovfilter,aux.Stringid(id,0),Xyz.InfiniteMats,s.xyzop)
	--You can detach 1 material from this card, then target a number of "Sylvan" monsters in your GY, up to the number of Plant monsters you control with different names; shuffle them into the Deck, or, if this card has no materials, you can place them on top of your Deck in any order.
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(id,2)
    e1:SetCategory(CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:HOPT()
    e1:SetFunctions(
		nil,
		Cost.DetachFromSelf(1,1,nil),
		s.target,
		s.operation
	)
    c:RegisterEffect(e1)
end
s.listed_names={id,CARD_GROVENOR_THE_SYLVAN_UNITER}
s.listed_series={SET_SYLVAN}

function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,CARD_GROVENOR_THE_SYLVAN_UNITER)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
	local c=e:GetHandler()
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(id,1)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_OATH|EFFECT_FLAG_CLIENT_HINT)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetValue(1)
	e0:SetReset(RESET_EVENT|RESETS_REDIRECT|RESET_PHASE|PHASE_END)
	c:RegisterEffect(e0)
	return true
end

--E1
function s.tdfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_SYLVAN) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	local fg=Duel.Group(aux.FaceupFilter(Card.IsRace,RACE_PLANT),tp,LOCATION_MZONE,0,nil)
	local max=fg:GetClassCount(Card.GetCode)
	if chk==0 then return max>0
		and Duel.IsExists(true,s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	local tg=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,max,nil)
	Duel.SetCardOperationInfo(tg,CATEGORY_TODECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:GetOverlayCount()==0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.PlaceOnTopOfDeck(g,tp)
	else
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end