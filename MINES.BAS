DECLARE SUB printDEBUG (text AS STRING)
DECLARE SUB printAll (showMines AS INTEGER)
DECLARE SUB showMine (c AS INTEGER, r AS INTEGER, nested AS INTEGER)
DECLARE SUB checkWin ()
DECLARE SUB rePrint (c AS INTEGER, r AS INTEGER)
DECLARE SUB markMine (c AS INTEGER, r AS INTEGER)
DECLARE FUNCTION POS2C! (position AS INTEGER) 'cursor position to cell position
DECLARE SUB mineCursor (a AS STRING)
DECLARE FUNCTION CalculateVal% (c AS INTEGER, r AS INTEGER)
CONST size = 9 'playground size
CONST minesCountMax = 10
CONST CSRLINOFFSET = 6 'at which line does the playground start
CONST charsPerMine = 4 'number of characters per mine

CONST mine = 300
CONST marked = 100
CONST hidden = 10

CLS
PRINT "MINES"
PRINT "Use cursor keys or WASD to move"
PRINT "There are" + STR$(minesCountMax) + " mines."
PRINT "F10 - quit       M - mark as a mine      Enter - show"
DIM SHARED mines(size, size) AS INTEGER 'column,row

'table initialization
DIM minesCount AS INTEGER
WHILE minesCount < minesCountMax
        RANDOMIZE TIMER 'change the seed
        FOR r = 0 TO size - 1
                FOR c = 0 TO size - 1
                        IF minesCount < minesCountMax THEN
                                IF RND > .8 AND NOT mines(c, r) = mine AND NOT (c = 0 AND r = 0) THEN 'first cell cannot contain a mine
                                        mines(c, r) = mine
                                        minesCount = minesCount + 1
                                END IF
                        END IF
                NEXT c
        NEXT r
WEND

'values calculation
FOR r% = 0 TO size - 1
FOR c% = 0 TO size - 1
IF NOT mines(c%, r%) = mine THEN
        mines(c%, r%) = CalculateVal(c%, r%) + hidden
END IF
NEXT c%
NEXT r%


'print the table
printAll 0
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

KEY 17, CHR$(32) + CHR$(17) 'W
ON KEY(17) GOSUB cursorU
KEY(17) ON

KEY 18, CHR$(32) + CHR$(30) 'A
ON KEY(18) GOSUB cursorL
KEY(18) ON

KEY 19, CHR$(32) + CHR$(31) 'S
ON KEY(19) GOSUB cursorD
KEY(19) ON

KEY 20, CHR$(32) + CHR$(32) 'D
ON KEY(20) GOSUB cursorR
KEY(20) ON


LOCATE CSRLINOFFSET, 2, 1 'cursor visible
'COLOR 0, 15

WHILE 1 'endless loop
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

mark: 'marks unknown cell as a mine / cancels the mark
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
'If there are unmarked mines left:
IF mines(c, r) = mine OR (mines(c, r) >= marked AND NOT mines(c, r) = mine + marked) THEN
        EXIT SUB 'stop checking
END IF
NEXT r
NEXT c

'else: user wins
LOCATE CSRLINOFFSET + size + 1, 1
PRINT "You Win!"
LOCATE CSRLINOFFSET + size + 2, 1
END

END SUB

SUB markMine (c AS INTEGER, r AS INTEGER) 'marks unknown cell as a mine / cancels the mark
IF mines(c, r) >= marked AND NOT mines(c, r) = mine THEN
        mines(c, r) = mines(c, r) - marked
ELSE
        IF mines(c, r) >= hidden THEN 'to prevent marking a shown cell
                mines(c, r) = mines(c, r) + marked
        END IF
END IF
rePrint c, r  'reprint this cell
checkWin
END SUB

SUB mineCursor (a AS STRING)
SELECT CASE a
CASE "L":
        IF POS(0) - charsPerMine > 0 THEN 'characters numbering starts at 1
                LOCATE CSRLIN, (POS(0) - charsPerMine)
                'PRINT "left"
        END IF
CASE "R":
        IF POS(0) + charsPerMine < size * charsPerMine THEN
                LOCATE CSRLIN, (POS(0) + charsPerMine)
                'PRINT "right"
        END IF
CASE "U":
        IF CSRLIN > CSRLINOFFSET THEN
                LOCATE (CSRLIN - 1), POS(0)
                'PRINT "up"
        END IF

CASE "D":
        IF CSRLIN + 1 < size + CSRLINOFFSET THEN
                LOCATE (CSRLIN + 1), POS(0)
                'PRINT "down"
        END IF

END SELECT
END SUB

FUNCTION POS2C (cursorPosition AS INTEGER) 'cursor position to cell position
POS2C = (cursorPosition - 1) / charsPerMine
END FUNCTION

SUB printAll (showMines AS INTEGER)
LOCATE CSRLINOFFSET - 1, 1 '-1 compensates for the first PRINT in for r
COLOR 8, 0 'grey
FOR r = 0 TO size - 1
        PRINT 'newline
        FOR c = 0 TO size - 1
                IF showMines > 0 THEN
                        IF mines(c, r) = mine THEN 'mine that is not marked
                                PRINT " ";
                                COLOR 0, 4 'red
                                PRINT "M";
                                COLOR 7, 0 'default
                                PRINT "  ";
                        ELSE
                                IF mines(c, r) >= marked AND mines(c, r) < mine THEN 'false mark
                                        PRINT " ";
                                        COLOR 10, 8 'light green, grey
                                        PRINT "*";
                                        COLOR 7, 0 'default
                                        PRINT "  ";
                                       
                                ELSE
                                        LOCATE CSRLIN, (POS(0) + charsPerMine)
                                END IF
                        END IF
                ELSE
                        PRINT " ?  ";
                END IF
        NEXT c
NEXT r
COLOR 7, 0 'default

END SUB

SUB printDEBUG (text AS STRING)
prevCol = POS(0)
prevRow = CSRLIN

LOCATE (CSRLINOFFSET + size + 2), 1
PRINT text

LOCATE prevRow, prevCol 'move the cursor to its previous location
END SUB

SUB rePrint (c AS INTEGER, r AS INTEGER) 'reprints a cell
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
                COLOR 8, 0 'grey
                PRINT " ? ";
                COLOR 7, 0 'default
        END IF

ELSE    'print the number
        SELECT CASE mines(c, r)
                CASE 0:
                        COLOR 2 'GRN - 2; LGRN - 10
                CASE 4 TO 8:
                        COLOR 12 'RED - 4; LRED - 12
        END SELECT
        PRINT mines(c, r);
        COLOR 7, 0 'default

END IF
LOCATE prevRow, prevCol 'move the cursor to its previous location
END SUB

SUB showMine (c AS INTEGER, r AS INTEGER, nested AS INTEGER)
IF mines(c, r) = mine THEN
        'user clicked on a mine
        printAll 1 'show mines
        LOCATE r + CSRLINOFFSET, c * charsPerMine + 1

        COLOR 0, 4 'red
        PRINT " @ "
        COLOR 7, 0 'default

        LOCATE CSRLINOFFSET + size + 1, 1
        PRINT "GAME OVER!"
        LOCATE CSRLINOFFSET + size + 2, 1
        END
       
ELSE
        IF mines(c, r) >= marked THEN
                'nothing - it is not possible to click on a marked mine
        ELSE
                IF mines(c, r) >= hidden THEN
                        mines(c, r) = mines(c, r) - hidden
                        IF mines(c, r) = 0 AND nested < 10 THEN  'nested prevents out of stack exception
                                'show the surrounding cells
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

