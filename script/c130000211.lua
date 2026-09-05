--[[
Laval Star
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")

function s.initial_effect(c)
	--If this card is Normal Summoned: You can add 1 Spell/Trap with "Laval" in its text from your Deck to your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetSearchFunctions(s.thfilter)
	c:RegisterEffect(e1)
	--If this card is in your GY: You can banish "Laval" monsters from your GY, whose total Levels equal 4 or more; Special Summon this card in Defense Position, but shuffle it into the Deck when it leaves the field.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_LAVAL}

--E1
function s.thfilter(c)
	return c:IsSpellTrap() and c:ListsArchetype(SET_LAVAL)
end

--E2
function s.rescon(sg,e,tp,mg,c)
	local lvsum=sg:GetSum(Card.GetLevel)
	local _,lvmin=sg:GetMinGroup(Card.GetLevel)
	local valid=aux.ChkfMMZ(1)(sg,nil,tp) and lvsum>=4
	return valid,false,s.razor(lvsum,lvmin)
end
function s.razor(lvsum,lvmin)
	return	function(c,sg,e,tp,mg)
				return lvsum+c:GetLevel()-4<lvmin
			end
end
function s.breakcon(sg,e,tp,mg)
	return sg:GetSum(Card.GetLevel)>=4
end
function s.cfilter(c)
	return c:IsAbleToRemoveAsCost() and c:HasLevel() and c:IsSetCard(SET_LAVAL) and aux.SpElimFilter(c,true,true)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,c)
	if chk==0 then return xgl.SelectUnselectGroup(0,g,e,tp,1,#g,s.rescon,0) end
	local rg=xgl.SelectUnselectGroup(0,g,e,tp,1,#g,s.rescon,1,tp,HINTMSG_REMOVE,s.rescon,s.breakcon,false)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummonRedirect(LOCATION_DECKSHF,e,c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end