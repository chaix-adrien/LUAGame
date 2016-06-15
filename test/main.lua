

math.randomseed(os.time())

largeur_map = 10
ma_ligne = {}

for i = 1, largeur_map, 1 do
    if (math.random(4) == 1) then
        table.insert(ma_ligne, 1)
    else
        table.insert(ma_ligne, 0)
    end
end
