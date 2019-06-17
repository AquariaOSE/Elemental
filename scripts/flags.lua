if not v then v = {} end

----------------------------------------
-- Custom Flags for Labyrinth --
----------------------------------------

-- FG: FIXME: should better move those to node internal flags !!

TEXT_START = 1
TEXT_END = 2
PUZZLE_DIATOMS = 3

DRIFT_PEARL = 4

PEARL_STASH = 5

KUIRLIN_MYTH = 6

PEARL_MINE = 7

KUIRLIN_CHILDREN = 8

KUIRLIN_BABIES = 9

MITHALA_DOLL = 10

EXCUSE_ME = 11

GOOD_KITCHEN = 12
BARRIER_CUT = 13
	
--LET_GO = 14 -- no longer used

ATE_THEM = 15

BIGCELLBOSS_DONE = 16
MINEOCTOBOSS_DONE = 17

LI_SUB = 18

BLASTERBOSS_DONE = 19

-- NO MORE FLAGS HERE! FLAG 21 ALREADY USED BY THE ENGINE!! CONTINUE AT END OF FILE!


-- FG: we should probably prefix the above with FLAG_

-- FLAG_SONGCAVECRYSTAL == 20, so maybe better relocate the flags if it gets more

FLAG_DRIFTPEARLS_COLLECTED = 301
FLAG_COSTUMES_COLLECTED = 302 -- there is no API to check if a costume was collected. this is set in collectibletemplate.lua.
FLAG_THINGS_COLLECTED = 303 -- there is no API to check if a costume was collected. this is set in collectibletemplate.lua.

FLAG_FOUND_DRIFTPEARL0 = 304
-- not explicitly used, but kept here for reference
FLAG_FOUND_DRIFTPEARL1 = 305
FLAG_FOUND_DRIFTPEARL2 = 306
FLAG_FOUND_DRIFTPEARL3 = 307
FLAG_FOUND_DRIFTPEARL4 = 308
FLAG_FOUND_DRIFTPEARL5 = 309
FLAG_FOUND_DRIFTPEARL6 = 310
FLAG_FOUND_DRIFTPEARL7 = 311
FLAG_FOUND_DRIFTPEARL8 = 312

FLAG_ENDING = 320 -- 0: normal game, 1: during ending sequence, 2: already finished but still playing


-- new flags should continue here:

TRAPPED_MAZE = 321

FAMILIAR_PLACE = 322
FAMILIAR_PLACE2 = 323
FAMILIAR_PLACE3 = 324

FLAG_WORLDMAP_INITED = 325
CANNON_DONE = 326

ENTER_4ELEMENTS = 327
ENTER_FOREST = 328
ENTER_AIR = 329
ENTER_DARK = 330
ENTER_ENERGY = 331
ENTER_ICE = 332
FALSE_GENESIS = 333
ENTER_OOB = 334

FLAG_COLLECTIBLE_TURTLESHELL = 680 -- somewhere near the end of flags
