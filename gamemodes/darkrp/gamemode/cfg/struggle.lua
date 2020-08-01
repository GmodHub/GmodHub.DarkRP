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
    }
}
