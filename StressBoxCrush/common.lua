general = {}

function general:delaySeconds(nS, bTerm)
	local l = (tonumber(nS) or 0)
	if(l > 0) then
		local n = os.clock()
		local e = (n + l)
		while(n < e and not bTerm) do n = os.clock() end
	end
end

return general
