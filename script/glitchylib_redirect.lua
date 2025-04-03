--Library with functions that allow specific checks on EFFECT_TYPE_FIELD effects

local _IsLocation, _GetLocation, _IsOnField = Card.IsLocation, Card.GetLocation, Card.IsOnField

function Card.IsLocation(c,loc)
	local e=c:GetCardEffect(EFFECT_ASSUME_LOCATION)
	if not e then
		return _IsLocation(c,loc)
	else
		local val=e:Evaluate(c)
		return val&loc>0
	end
end
function Card.GetLocation(c)
	local e=c:GetCardEffect(EFFECT_ASSUME_LOCATION)
	if not e then
		return _GetLocation(c)
	else
		return e:Evaluate(c)
	end
end
function Card.IsOnField(c)
	return c:IsLocation(LOCATION_ONFIELD)
end

--Register and reset EFFECT_ASSUME_LOCATION to a card
function Card.AssumeLocation(c,loc)
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE)
	e:SetCode(EFFECT_ASSUME_LOCATION)
	e:SetValue(loc)
	c:RegisterEffect(e,true)
	return e
end
function Card.ResetAssumedLocation(c)
	local e=c:GetCardEffect(EFFECT_ASSUME_LOCATION)
	if e then
		e:Reset()
	end
end