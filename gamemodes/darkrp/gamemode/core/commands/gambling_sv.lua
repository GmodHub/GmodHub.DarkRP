local cards = {"Король", "Валет", "Дама", "Туз", "Двойка", "Тройка", "Четвёрка", "Пятёрка", "Шестёрка", "Семёрка", "Восьмёрка", "Девятка", "Десятка"}

rp.AddCommand("roll", function(pl)
	chat.Send("Roll", pl, math.random(100))
end)

rp.AddCommand("dice", function(pl)
	chat.Send("Dice", pl, math.random(1, 6), math.random(1, 6))
end)

rp.AddCommand("cards", function(pl)
	chat.Send("Cards", pl, table.Random(cards))
end)

rp.AddCommand("coin", function(pl)
	chat.Send("Coin", pl, table.Random({"Орёл", "Решка"}))
end)
