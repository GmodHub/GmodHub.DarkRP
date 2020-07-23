rp.struggle = {
    Active = {},
    ["Ziptie"] = {
        id = 2,
        max = 100,
        name = "Ziptie",
        caption = "Кликайте чтобы выбраться!",
        key = MOUSE_FIRST,
        check = function(pl)
            return pl:IsZiptied()
        end,
        func = function(pl)
            pl:UnZiptie()
        end,
    },
    ["UnZiptie"] = {
        id = 2,
        max = 50,
        name = "UnZiptie",
        caption = "Жмите G для освобождения!",
        key = KEY_G,
        check = function(pl)
            local ent = pl:GetEyeTrace().Entity
            return IsValid(ent) and isplayer(ent) and ent:IsZiptied()
        end,
        func = function(pl)
            local ent = pl:GetEyeTrace().Entity
            if IsValid(ent) and isplayer(ent) and ent:IsZiptied() then
                ent:UnZiptie()
            end
        end,
    },
}
