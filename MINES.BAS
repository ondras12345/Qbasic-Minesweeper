DECLARE SUB showMine (c AS INTEGER, r AS INTEGER, nested AS INTEGER)
DECLARE SUB checkWin ()
DECLARE SUB rePrint (c AS INTEGER, r AS INTEGER)
DECLARE SUB markMine (c AS INTEGER, r AS INTEGER)
DECLARE FUNCTION POS2C! (position AS INTEGER)
DECLARE SUB mineCursor (a AS STRING)
DECLARE FUNCTION CalculateVal% (c AS INTEGER, r AS INTEGER)
CONST size = 9
CONST minesCountMax = 10
CONST CSRLINOFFSET = 4 'na jake radce zacina hraci pole
CONST charsPerMine = 4 'pocet znaku na minu

CONST mine = 300
CONST marked = 100
CONST hidden = 10

CLS
PRINT "MINES"
PRINT "F10 - quit       M - mark as a mine      Enter - show"
DIM SHARED mines(size, size) AS INTEGER 'column,row

'inicializece tabulky
DIM minesCount AS INTEGER
WHILE minesCount < minesCountMax
        RANDOMIZE TIMER 'zmeni seed
        FOR r = 0 TO size - 1
                FOR c = 0 TO size - 1
                        IF minesCount < minesCountMax THEN
                                IF RND > .8 AND NOT mines(c, r) = mine AND NOT (c = 0 AND r = 0) THEN 'v prvni bunce nemuze byt mina
                                        mines(c, r) = mine
                                        minesCount = minesCount + 1
                                END IF
                        END IF
                NEXT c
        NEXT r
WEND

'dopocitani hodnot
FOR r% = 0 TO size - 1
FOR c% = 0 TO size - 1
IF NOT mines(c%, r%) = mine THEN
        mines(c%, r%) = CalculateVal(c%, r%) + hidden
END IF
NEXT c%
NEXT r%


'vypis tabulky
COLOR 8, 0 'seda
FOR r = 0 TO size - 1
        PRINT
        FOR c = 0 TO size - 1
                'debug - pak odebrat if
                'IF mines(c, r) >= mine THEN
                'PRINT " M  ";
                'ELSE
                PRINT " ?  ";
        NEXT c
NEXT r
COLOR 7, 0

showMine 0, 0, 0

ON KEY(12) GOSUB cursorL
KEY(12) ON
ON KEY(13) GOSUB cursorR
KEY(13) ON
ON KEY(11) GOSUB cursorU
KEY(11) ON
ON KEY(14) GOSUB cursorD
KEY(14) ON

ON KEY(10) GOSUB quitGame
KEY(10) ON

KEY 15, CHR$(32) + CHR$(50) 'M
ON KEY(15) GOSUB mark
KEY(15) ON

KEY 16, CHR$(32) + CHR$(28) 'Enter
ON KEY(16) GOSUB show
KEY(16) ON


LOCATE CSRLINOFFSET, 2, 1'kurzor
'COLOR 0, 15

WHILE 1
WEND

END

cursorL:
mineCursor ("L")
RETURN

cursorR:
mineCursor ("R")
RETURN

cursorU:
mineCursor ("U")
RETURN

cursorD:
mineCursor ("D")
RETURN

quitGame:
LOCATE CSRLINOFFSET + size + 2, 1
END
RETURN

mark: 'oznaci nezname policko jako minu / zrusi oznaceni
markMine POS2C(POS(0)), (CSRLIN - CSRLINOFFSET)
RETURN

show:
showMine POS2C(POS(0)), (CSRLIN - CSRLINOFFSET), 0
checkWin
RETURN

FUNCTION CalculateVal% (c AS INTEGER, r AS INTEGER)
DIM value AS INTEGER
value = 0
FOR i = -1 TO 1
        FOR j = -1 TO 1
                IF (c + i) >= 0 AND (c + i) <= (size - 1) AND (r + j) >= 0 AND (r + j) <= (size - 1) THEN
                     IF mines((c + i), (r + j)) = mine THEN
                        value = value + 1
                     END IF
                END IF
                
        NEXT j
NEXT i
CalculateVal% = value
END FUNCTION

SUB checkWin
FOR c = 0 TO size - 1
FOR r = 0 TO size - 1
IF mines(c, r) = mine OR (mines(c, r) >= marked AND NOT mines(c, r) = mine + marked) THEN 'pokud zbyly neoznacene miny
        EXIT SUB
END IF
NEXT r
NEXT c

LOCATE CSRLINOFFSET + size + 1, 1
PRINT "You Win!"
LOCATE CSRLINOFFSET + size + 2, 1
END

END SUB

SUB markMine (c AS INTEGER, r AS INTEGER) 'oznaci nezname policko jako minu / zrusi oznaceni
IF mines(c, r) >= marked AND NOT mines(c, r) = mine THEN
        mines(c, r) = mines(c, r) - marked
ELSE
        IF mines(c, r) >= hidden THEN 'aby neskryl zobrazene policko
                mines(c, r) = mines(c, r) + marked
        END IF
END IF
rePrint c, r  'znovu vypise aktualni policko - aby se projevily zmeny
checkWin
END SUB

SUB mineCursor (a AS STRING)
SELECT CASE a
CASE "L":
        IF POS(0) - charsPerMine > 0 THEN 'znaky se cisluji od 1
                LOCATE CSRLIN, (POS(0) - charsPerMine)
                'PRINT "doleva"
        END IF
CASE "R":
        IF POS(0) + charsPerMine < size * charsPerMine THEN
                LOCATE CSRLIN, (POS(0) + charsPerMine)
                'PRINT "doprava"
        END IF
CASE "U":
        IF CSRLIN > CSRLINOFFSET THEN
                LOCATE (CSRLIN - 1), POS(0)
                'PRINT "nahoru"
        END IF

CASE "D":
        IF CSRLIN + 1 < size + CSRLINOFFSET THEN
                LOCATE (CSRLIN + 1), POS(0)
                'PRINT "doprava"
        END IF

END SELECT
END SUB

FUNCTION POS2C (position AS INTEGER)
POS2C = (POS(0) - 1) / charsPerMine
END FUNCTION

SUB rePrint (c AS INTEGER, r AS INTEGER) 'znovu vypise policko
DIM prevCol AS INTEGER
DIM prevRow AS INTEGER
prevCol = POS(0)
prevRow = CSRLIN

LOCATE r + CSRLINOFFSET, c * charsPerMine + 1
IF mines(c, r) >= hidden THEN
        IF mines(c, r) >= marked AND NOT mines(c, r) = mine THEN
                COLOR 6, 0 'orange
                PRINT " * ";
                COLOR 7, 0 'deafult
        ELSE
                COLOR 8, 0 'seda
                PRINT " ? ";
                COLOR 7, 0 'default
        END IF

ELSE    'vypise cislo
        SELECT CASE mines(c, r)
                CASE 0:
                        COLOR 2 'GRN - 2; LGRN - 10
                CASE 4 TO 8:
                        COLOR 12 'RED - 4; LRED - 12
        END SELECT
        PRINT mines(c, r);
        COLOR 7, 0 'default

END IF
LOCATE prevRow, prevCol 'vrat kurzor
END SUB

SUB showMine (c AS INTEGER, r AS INTEGER, nested AS INTEGER)
IF mines(c, r) = mine THEN
        'user klikl na minu
        LOCATE r + CSRLINOFFSET, c * charsPerMine + 1
        COLOR 0, 4
        PRINT " @ "
        COLOR 7, 0 'default

        LOCATE CSRLINOFFSET + size + 1, 1
        PRINT "GAME OVER!"
        LOCATE CSRLINOFFSET + size + 2, 1
        END
       
ELSE
        IF mines(c, r) >= marked THEN
                'nic - nelze kliknout na oznacenou minu
        ELSE
                IF mines(c, r) >= hidden THEN
                        mines(c, r) = mines(c, r) - hidden
                        IF mines(c, r) = 0 AND nested < 10 THEN  'nested zabranuje chybe out of stack
                                'zobraz okoli
                                FOR i = -1 TO 1
                                FOR j = -1 TO 1
                                        IF (c + i) >= 0 AND (c + i) <= (size - 1) AND (r + j) >= 0 AND (r + j) <= (size - 1) THEN
                                                IF mines(c + i, r + j) >= hidden THEN
                                                        showMine (c + i), (r + j), nested + 1
                                                END IF
                                        END IF
                                NEXT j
                                NEXT i
                        END IF
                END IF
        END IF

END IF
rePrint c, r
END SUB

