-- We'll replace this some day.. maybe
ba.ranks.Create('Root', 10)
	:SetImmunity(10000)
	:SetRoot(true)

ba.ranks.Create('Sudo Root', 9)
	:SetImmunity(10000)
	:SetRoot(true)

ba.ranks.Create('Council', 8)
	:SetImmunity(7500)
	:SetFlags('uvmasgdc')
	:SetGA(true)

ba.ranks.Create('Super Admin', 7)
	:SetImmunity(7000)
	:SetFlags('uvmasd')
	:SetAdmin(true)
	:SetSA(true)

ba.ranks.Create('Double Admin', 6)
	:SetImmunity(6500)
	:SetFlags('uvmad')
	:SetDA(true)

ba.ranks.Create('Content Creator', 5)
	:SetImmunity(6250)
	:SetFlags('uvma')
	:SetGlobal(true)
	:SetAdmin(true)

ba.ranks.Create('Admin', 4)
	:SetImmunity(6000)
	:SetFlags('uvma')
	:SetAdmin(true)

ba.ranks.Create('Moderator', 3)
	:SetImmunity(5000)
	:SetFlags('uvm')
	:SetAdmin(true)

ba.ranks.Create('VIP', 2)
	:SetImmunity(0)
	:SetFlags('uv')
	:SetVIP(true)

ba.ranks.Create('User', 1)
	:SetImmunity(0)
	:SetFlags('u')
