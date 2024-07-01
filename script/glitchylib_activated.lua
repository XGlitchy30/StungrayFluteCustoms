Glitchy=Glitchy or {}
xgl=Glitchy

--Search effect templates: Add N card(s) from LOCATION to your hand
function Glitchy.SearchTarget(f,loc,min,exc)
	f=aux.SearchFilter(f)
	loc=loc or LOCATION_DECK
	min=min or 1
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local exc=exc and e:GetHandler() or nil
					return Duel.IsExistingMatchingCard(f,tp,loc,0,min,exc,e,tp)
				end
				Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,min,tp,loc)
			end
end
function Glitchy.SearchOperation(f,loc,min,max,exc)
	loc=loc or LOCATION_DECK
	f=aux.SearchFilter(f)
	if loc&LOCATION_GRAVE>0 then
		f=aux.NecroValleyFilter(f)
	end
	min=min or 1
	max=max or min
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local exc=exc and e:GetHandler() or nil
				local g=Duel.Select(HINTMSG_ATOHAND,false,tp,f,tp,loc,0,min,max,exc,e,tp)
				if #g>0 then
					Duel.Search(g)
				end
			end
end