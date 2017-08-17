# ufoEd
ufoEd

UFO Enemy Unknown Amiga Save Game Editor

In Amiga E

My notes, in case you find them interesting:

UFO, ENEMY UNKNOWN - SOLDIER EDITOR v1.00 NOTES!

SOLDIER                                                            UFO VAL       89 66 98 80
FFFF 00 03 00 02 00 00 00 21 [NAME] 00 10 11 13 12 13 15 17 13 12 13 15 17 13 00 55 40 60 50 20 2f 40 14 1d 00 05 04 02 02 00 0a 02 00 00 00 02 00 00 00 01 03 00 00 00 00 00 01
^       ^     ^              ^                                                   ^  ^  ^  ^                                                   ^
1       2     3              4                                                   5  6  7  8                                                    x

1:Marker between soldiers
2:Number of missions
3:Number of Kills
4:Soldiers Name
5:Time Units           [ Value := hex+4 ]
6:Health               [ Value := hex+2 ]
7:Stamina              [ Value := hex+2 ]
8:Reactions            [ Value := hex]
x:Armour 0 - None
         2 - Personal
         3 - PowerSuit
         4 - ?

