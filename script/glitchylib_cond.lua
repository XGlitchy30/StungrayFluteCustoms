--Event Group (eg) Check Condition
function Glitchy.EventGroupCond(f,min,max,exc)
	if not min then min=1 end
	if max then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local exc=(not exc) and nil or e:GetHandler()
					return eg:IsExists(f,min,exc,e,tp,eg,ep,ev,re,r,rp) and not eg:IsExists(f,max,exc,e,tp,eg,ep,ev,re,r,rp)
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local exc=(not exc) and nil or e:GetHandler()
					return eg:IsExists(f,min,exc,e,tp,eg,ep,ev,re,r,rp)
				end
	end
end
function Glitchy.ExactEventGroupCond(f,ct,exc)
	if not ct then ct=1 end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local exc=(not exc) and nil or e:GetHandler()
				return eg:FilterCount(f,exc,e,tp,eg,ep,ev,re,r,rp)==ct
			end
end

--Location Group Check Conditions
function Glitchy.LocationGroupCond(f,loc1,loc2,min,max,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=loc1 end
	if not min then min=1 end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if not tp then
					tp=e:GetHandlerPlayer()
				end
				local exc=(exc) and e:GetHandler() or nil
				local ct=Duel.GetMatchingGroupCount(f,tp,loc1,loc2,exc,e,tp,eg,ep,ev,re,r,rp)
				return ct>=min and (not max or ct<=max)
			end
end
function Glitchy.ExactLocationGroupCond(f,loc1,loc2,ct0,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=loc1 end
	if not ct then ct=1 end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if not tp then
					tp=e:GetHandlerPlayer()
				end
				local exc=(not exc) and nil or e:GetHandler()
				local ct=Duel.GetMatchingGroupCount(f,tp,loc1,loc2,exc,e,tp,eg,ep,ev,re,r,rp)
				return ct==ct0
			end
end
function Glitchy.CompareLocationGroupCond(res,f,loc,exc)
	if not f then f=aux.TRUE end
	if not loc then loc=LOCATION_MZONE end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if not tp then
					tp=e:GetHandlerPlayer()
				end
				local res = (res and res==1) and 1-tp or tp
				local exc=(exc) and e:GetHandler() or nil
				local ct1=Duel.GetMatchingGroupCount(f,tp,loc,0,exc,e,tp,eg,ep,ev,re,r,rp)
				local ct2=Duel.GetMatchingGroupCount(f,tp,0,loc,exc,e,tp,eg,ep,ev,re,r,rp)
				local p
				if ct1>ct2 then
					p=tp
				elseif ct1<ct2 then
					p=1-tp
				else
					p=PLAYER_NONE
				end
				return res==p
			end
end

--If you control no (f) monsters...
function Glitchy.ControlNoMonstersCond(f)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
				if f then
					g:Match(aux.FaceupFilter(f),nil,e,tp)
				end
				return g:GetCount()==0
			end
end

--When this card is X Summoned
function Glitchy.RitualSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function Glitchy.FusionSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function Glitchy.SynchroSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function Glitchy.XyzSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function Glitchy.PendulumSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function Glitchy.LinkSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function Glitchy.ProcSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1)
end

--Equip
function Glitchy.IsEquippedCond(e)
	return e:GetHandler():GetEquipTarget()
end
function Glitchy.IsEquippedToCond(f)
	return	function(e,tp)
				if not tp then tp=e:GetHandlerPlayer() end
				local ec=e:GetHandler():GetEquipTarget()
				return ec and (not f or f(ec,e,tp))
			end
end

--Turn/Phase Conditions
function Glitchy.DrawPhaseCond(tp)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return xgl.IsDrawPhase(tp)
			end
end
function Glitchy.StandbyPhaseCond(tp)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return xgl.IsStandbyPhase(tp)
			end
end
function Glitchy.MainPhaseCond(tp,ct)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return xgl.IsMainPhase(tp,ct)
			end
end
function Glitchy.BattlePhaseCond(tp)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return xgl.IsBattlePhase(tp)
			end
end
function Glitchy.MainOrBattlePhaseCond(tp,ct)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return xgl.IsMainPhase(tp,ct) or xgl.IsBattlePhase(tp)
			end
end
function Glitchy.EndPhaseCond(tp)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return xgl.IsEndPhase(tp)
			end
end
function Glitchy.ExceptOnDamageStep()
	return Glitchy.ExceptOnDamageCalc()
end
function Glitchy.ExceptOnDamageCalc()
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function Glitchy.TurnPlayerCond(tp)
	return	function(e,p)
				if not p then p=e:GetHandlerPlayer() end
				local tp = (not tp or tp==0) and p or 1-p
				return Duel.GetTurnPlayer()==tp
			end
end

--Type-Related
----XYZ
function Glitchy.HasXyzMaterialCond(e)
	return e:GetHandler():GetOverlayCount()>0
end

----LINK
function Glitchy.ThisCardPointsToCond(f,min)
	if not f then f=aux.TRUE end
	return	function(e)
				local tp=e:GetHandlerPlayer()
				return e:GetHandler():GetLinkedGroup():IsExists(f,min,nil,e,tp)
			end
end