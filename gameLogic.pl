:-use_module(library(lists)).
  :-use_module(library(random)).

  play(Board) :- chooseSourceCoords(RowSource, ColSource, Board, Piece),
                 chooseDestinyCoords(RowSource, ColSource, Board, Piece, BoardOut),nl,nl,
                 if_then_else(endGame(Board),play(BoardOut),(nl,write('End Game'),nl,checkWinner(PointsXOut,PointsYOut))).

  chooseSourceCoords(RowSource, ColSource,Board,Piece) :-  repeat,
                                                            player(Curr_player),nl,
                                                            write('It is the turn of '),
                                                            write(Curr_player), nl,nl,
                                                            write('Please choose the piece that you want move:'), nl,
                                                            write('Please enter a position (A...I)'),nl,
                                                            getChar(ColLetter),
                                                            once(letterToNumber(ColLetter, ColSource)),
                                                            write('Please enter a position (1...9)'),
                                                            nl,
                                                            getCode(RowSource),
                                                            validateSourcePiece(ColSource, RowSource,Board,Piece).

  chooseDestinyCoords(RowSource, ColSource, Board,Piece, BoardOut) :- repeat,nl,
                                                                      write('What is the destiny of your piece?'),
                                                                      nl,
                                                                      write('Please enter a position (A...I)'),
                                                                      nl,
                                                                      getChar(ColLetter),
                                                                      once(letterToNumber(ColLetter, ColDestiny)),
                                                                      write('Please enter a position (1...9)'),
                                                                      nl,
                                                                      getCode(RowDestiny),
                                                                      validateDestinyPiece(ColSource,RowSource,ColDestiny, RowDestiny,Board,Piece, BoardOut),
                                                                      printFinalBoard(BoardOut),
                                                                      player(Curr_player),
                                                                      if_then_else(Curr_player == 'playerX', set_player('playerY'),set_player('playerX')).



  letterToNumber('A',1).
  letterToNumber('B',2).
  letterToNumber('C',3).
  letterToNumber('D',4).
  letterToNumber('E',5).
  letterToNumber('F',6).
  letterToNumber('G',7).
  letterToNumber('H',8).
  letterToNumber('I',9).

  validateSourcePiece(Ncol, Nrow,Board,Piece) :- player(Curr_player),
                                                 getPiece(Board, Nrow, Ncol, Piece),
                                                 if_then_else(Curr_player == 'playerX',
                                                 (Piece \= 'pieceY1',
                                                 Piece \= 'pieceY2'),
                                                 (Piece \= 'pieceX1',
                                                 Piece \= 'pieceX2')),
                                                 Piece \= 'empty',
                                                 Piece \= 'noPiece'.

  validateDestinyPiece(LastCol,LastRow,Ncol,Nrow,Board, Piece, BoardOut) :- checkIfCanMove(Ncol, Nrow, LastCol,LastRow,Board,Piece,BoardOut).


  checkIfCanMove(Ncol,Nrow,LastCol,LastRow,Board,'pieceX1',BoardOut) :- getPiece(Board, Nrow, Ncol, NewPiece),
                                                          NewPiece \= 'empty',
                                                          if_then_else((NewPiece=='noPiece'),
                                                                ((chooseNewJump(Nrow, Ncol,Row,Col,'pieceX1'), getPiece(Board,Row,Col,Piece2),
                                                                if_then_else(Piece2=='noPiece', (chooseNewJump(Nrow, Ncol,Row,Col,'pieceX1'),
                                                                Col2 is Ncol, Row2 is Nrow,Col1 is Col,Row1 is Row),
                                                                (if_then_else((Piece2=='pieceY1';Piece2=='pieceY2'),
                                                                (validateMove('pieceX1', Col2, Row2, Col1, Row1),choosePieceToRemove(Board, BoardOut2, 'pieceX1'),
                                                                setPiece(BoardOut2,Nrow,Ncol,Piece2,BoardOut)),(validateMove(Piece2, Col2, Row2, Col1, Row1),
                                                                setPiece(Board,Row2,Col2,'noPiece',BoardOut2), setPiece(BoardOut2,Row2,Col2,'pieceX1',BoardOut))))))),
                                                                        (if_then_else((NewPiece=='pieceY1';NewPiece=='pieceY2'), (validateMove('pieceX1', LastCol, LastRow, Ncol, Nrow),
                                                                        choosePieceToRemove(Board, BoardOut2, 'pieceX1'),setPiece(BoardOut2,Nrow,Ncol,'pieceX1',BoardOut)),
                                                                        (validateMove('pieceX1', LastCol, LastRow, Ncol, Nrow),setPiece(Board,LastRow,LastCol,'noPiece',BoardOut2),
                                                                        setPiece(BoardOut2,LastRow,LastCol,'pieceX1',BoardOut))))),
                                                                        write(LastCol),nl,write(LastRow),nl,write(Nrow),nl,write(Ncol).

  checkIfCanMove(Ncol,Nrow,LastCol,LastRow, Board,'pieceX2',BoardOut) :- getPiece(Board, Nrow, Ncol, NewPiece),
                                                        NewPiece \= 'empty',
                                                        if_then_else((NewPiece=='noPiece'),  (chooseNewJump(Nrow, Ncol,Row,Col,'pieceX2'),checkIfCanMove(Col,Row,Ncol,Nrow,Board,'pieceX2',BoardOut), LastCol==Ncol, LastRow==Nrow,Ncol==Col,Nrow==Row),
                                                        (if_then_else((NewPiece=='pieceY1';NewPiece=='pieceY2'),choosePieceToRemove(Board, BoardOut, 'pieceX2'),setPiece(Board,LastRow,LastCol,'noPiece',BoardOut)))).

  checkIfCanMove(Ncol,Nrow,LastCol,LastRow,Board,'pieceY1',BoardOut) :- getPiece(Board, Nrow, Ncol, NewPiece),
                                                        NewPiece \= 'empty',
                                                        if_then_else((NewPiece=='noPiece'),  (chooseNewJump(Nrow, Ncol,Row,Col,'pieceY1'),checkIfCanMove(Col,Row,Ncol,Nrow,Board,'pieceY1',BoardOut), LastCol==Ncol, LastRow==Nrow,Ncol==Col,Nrow==Row),
                                                        (if_then_else((NewPiece=='pieceX1';NewPiece=='pieceX2'),choosePieceToRemove(Board, BoardOut, 'pieceY1'),setPiece(Board,LastRow,LastCol,'noPiece',BoardOut)))).

  checkIfCanMove(Ncol,Nrow,LastCol,LastRow,Board,'pieceY2',BoardOut) :- getPiece(Board, Nrow, Ncol, NewPiece),
                                                        NewPiece \= 'empty',
                                                        if_then_else((NewPiece=='noPiece'),  (chooseNewJump(Nrow, Ncol,Row,Col,'pieceY2'),checkIfCanMove(Col,Row,Ncol,Nrow,Board,'pieceY2',BoardOut), LastCol==Ncol, LastRow==Nrow,Ncol==Col,Nrow==Row),
                                                        (if_then_else((NewPiece=='pieceX1';NewPiece=='pieceX2'),choosePieceToRemove(Board, BoardOut, 'pieceY2'),setPiece(Board,LastRow,LastCol,'noPiece',BoardOut)))).


  validateMove('pieceX1', LastCol,LastRow,Ncol,Nrow) :- (Ncol is LastCol+2,
                                                   Nrow is LastRow+2);
                                                   (Ncol is LastCol,
                                                   Nrow is LastRow+2);
                                                   (Nrow is LastRow,
                                                   Ncol is LastCol+2).

  validateMove('pieceX2', LastCol,LastRow,Ncol,Nrow) :- (Ncol is LastCol+2,
                                                  Nrow is LastRow);
                                                  (Ncol is LastCol,
                                                  Nrow is LastRow+2);
                                                  (Nrow is LastRow-2,
                                                  Ncol is LastCol+2).

  validateMove('pieceY1', LastCol,LastRow,Ncol,Nrow) :- (Ncol is LastCol-2,
                                                  Nrow is LastRow+2);
                                                  (Ncol is LastCol+2,
                                                  Nrow is LastRow+2);
                                                  (Nrow is LastRow,
                                                  Ncol is LastCol-2).

  validateMove('pieceY2', LastCol,LastRow,Ncol,Nrow) :- (Ncol is LastCol-2,
                                                  Nrow is LastRow-2);
                                                  (Ncol is LastCol-2,
                                                  Nrow is LastRow);
                                                  (Nrow is LastRow-2,
                                                  Ncol is LastCol).


chooseNewJump(LastRow,LastCol,Row,Col,'pieceX1') :- repeat,write('You need jump one more time!'),
                                                    nl,
                                                    write('Please enter a position (A...I)'),
                                                    nl,
                                                    getChar(ColLetter),
                                                    once(letterToNumber(ColLetter, Col)),
                                                    write('Please enter a position (1...9)'),
                                                    nl,
                                                    getCode(Row),
                                                    /*trace,*/
                                                    validateMove('pieceX1', LastCol, LastRow, Col, Row).

chooseNewJump(LastRow,LastCol,Row,Col,'pieceX2') :- repeat,write('You need jump one more time!'),
                                                    nl,
                                                    write('Please enter a position (A...I)'),
                                                    nl,
                                                    getChar(ColLetter),
                                                    once(letterToNumber(ColLetter, Col)),
                                                    write('Please enter a position (1...9)'),
                                                    nl,
                                                    getCode(Row),
                                                    validateMove('pieceX2', LastCol, LastRow, Col, Row).

chooseNewJump(LastRow,LastCol,Row,Col,'pieceY1') :- repeat,write('You need jump one more time!'),
                                                    nl,
                                                    write('Please enter a position (A...I)'),
                                                    nl,
                                                    getChar(ColLetter),
                                                    once(letterToNumber(ColLetter, Col)),
                                                    write('Please enter a position (1...9)'),
                                                    nl,
                                                    getCode(Row),
                                                    validateMove('pieceY1', LastCol, LastRow, Col, Row).

chooseNewJump(LastRow,LastCol,Row,Col,'pieceY2') :- repeat,write('You need jump one more time!'),
                                                   nl,
                                                   write('Please enter a position (A...I)'),
                                                   nl,
                                                   getChar(ColLetter),
                                                   once(letterToNumber(ColLetter, Col)),
                                                   write('Please enter a position (1...9)'),
                                                   nl,
                                                   getCode(Row),
                                                   validateMove('pieceY2', LastCol, LastRow, Col, Row).

choosePieceToRemove(Board, BoardOut, 'pieceX1') :- repeat, write('What is the piece that you want remove?'),
                                          nl,
                                          write('Please enter a position (A...I)'),
                                          nl,
                                          getChar(ColLetter),
                                          once(letterToNumber(ColLetter, Col)),
                                          write('Please enter a position (1...9)'),
                                          nl,
                                          getCode(Row),trace,
                                          checkIfCanRemove(Board, Col, Row, 'pieceX1'),
                                          setPiece(Board,Row,Col,'noPiece',BoardOut).

choosePieceToRemove(Board, BoardOut, 'pieceX2') :- repeat,write('What is the piece that you want remove?'),
                                        nl,
                                        write('Please enter a position (A...I)'),
                                        nl,
                                        getChar(ColLetter),
                                        once(letterToNumber(ColLetter, Col)),
                                        write('Please enter a position (1...9)'),
                                        nl,
                                        getCode(Row),
                                        checkIfCanRemove(Board, Col, Row, 'pieceX2'),
                                        setPiece(Board,Row,Col,'noPiece',BoardOut).

choosePieceToRemove(Board, BoardOut, 'pieceY1') :- repeat, write('What is the piece that you want remove?'),
                                        nl,
                                        write('Please enter a position (A...I)'),
                                        nl,
                                        getChar(ColLetter),
                                        once(letterToNumber(ColLetter, Col)),
                                        write('Please enter a position (1...9)'),
                                        nl,
                                        getCode(Row),
                                        checkIfCanRemove(Board, Col, Row, 'pieceY1'),
                                        setPiece(Board,Row,Col,'noPiece',BoardOut).

choosePieceToRemove(Board, BoardOut, 'pieceY2') :- repeat, write('What is the piece that you want remove?'),
                                        nl,
                                        write('Please enter a position (A...I)'),
                                        nl,
                                        getChar(ColLetter),
                                        once(letterToNumber(ColLetter, Col)),
                                        write('Please enter a position (1...9)'),
                                        nl,
                                        getCode(Row),
                                        checkIfCanRemove(Board, Col, Row, 'pieceY2'),
                                        setPiece(Board,Row,Col,'noPiece',BoardOut).

checkIfCanRemove(Board, Col, Row, 'pieceX1') :- getPiece(Board, Row, Col, NewPiece),
                                                NewPiece \= 'empty',
                                                NewPiece \= 'pieceY1',
                                                NewPiece \= 'pieceY2',
                                                NewPiece \= 'noPiece'.

checkIfCanRemove(Board, Col, Row, 'pieceX2') :- getPiece(Board, Row, Col, NewPiece),
                                                NewPiece \= 'empty',
                                                NewPiece \= 'pieceY1',
                                                NewPiece \= 'pieceY2',
                                                NewPiece \= 'noPiece'.

checkIfCanRemove(Board, Col, Row, 'pieceY1') :- getPiece(Board, Row, Col, NewPiece),
                                                NewPiece \= 'empty',
                                                NewPiece \= 'pieceX1',
                                                NewPiece \= 'pieceX2',
                                                NewPiece \= 'noPiece'.

checkIfCanRemove(Board, Col, Row, 'pieceY2') :- getPiece(Board, Row, Col, NewPiece),
                                                NewPiece \= 'empty',
                                                NewPiece \= 'pieceX1',
                                                NewPiece \= 'pieceX2',
                                                NewPiece \= 'noPiece'.

  getPiece(Board, Nrow, Ncol, Piece) :- getElePos(Nrow, Board, Row),
                                        getElePos(Ncol, Row, Piece).

  getElePos(1, [Element|_], Element).
  getElePos(Pos, [_|Remainder], Element) :- Pos > 1,
                                            Next is Pos-1,
                                            getElePos(Next, Remainder, Element).

  setPiece(BoardIn, Nrow, Ncol, Piece, BoardOut) :- setOnRow(Nrow, BoardIn, Ncol, Piece, BoardOut).

  setOnRow(1, [Row|Remainder], Ncol, Piece, [Newrow|Remainder]):- setOnCol(Ncol, Row, Piece, Newrow).
  setOnRow(Pos, [Row|Remainder], Ncol, Piece, [Row|Newremainder]):- Pos > 1,
                                                                    Next is Pos-1,
                                                                    setOnRow(Next, Remainder, Ncol, Piece, Newremainder).

  setOnCol(1, [_|Remainder], Piece, [Piece|Remainder]).
  setOnCol(Pos, [X|Remainder], Piece, [X|Newremainder]):- Pos > 1,
                                                          Next is Pos-1,
                                                          setOnCol(Next, Remainder, Piece, Newremainder).

  if_then_else(If, Then,_):- If,!, Then.
  if_then_else(_, _, Else):- Else.

  getElement(Board,Nrow,Ncol,Element) :- nth1(Nrow, Board, Row),
                                         nth1(Ncol,Row,Element).

  checkPieces('pieceX1',Board) :- getElement(Board,_,_,'pieceX1').

  checkPieces('pieceX2',Board) :- getElement(Board,_,_,'pieceX2').

  checkPieces('pieceY1',Board) :- getElement(Board,_,_,'pieceY1').

  checkPieces('pieceY2',Board) :- getElement(Board,_,_,'pieceY2').

  checkMoves('pieceX1', Board) :- getElement(Board, Nrow, Ncol, 'pieceX1'),
                              NewRow is Nrow+2,
                              Newcol is Ncol+2,
                              (getPiece(Board,NewRow,Newcol,Piece),
                              Piece \='empty');
                              (getPiece(Board,Nrow,Newcol,Piece),
                              Piece \='empty');
                              (getPiece(Board,NewRow,Ncol,Piece),
                              Piece \='empty').

  checkMoves('pieceX2', Board) :- getElement(Board, Nrow, Ncol, 'pieceX2'),
                             NewRow is Nrow+2,
                             Newcol is Ncol+2,
                             Newrow is Nrow-2,
                            (getPiece(Board,Nrow,Newcol,Piece),
                            Piece \='empty');
                            (getPiece(Board,NewRow,Ncol,Piece),
                            Piece \='empty');
                            (getPiece(Board,Newrow,Newcol,Piece),
                            Piece \='empty').

  checkMoves('pieceY1', Board) :- getElement(Board, Nrow, Ncol, 'pieceY1'),
                            NewRow is Nrow+2,
                            Newcol is Ncol+2,
                            NewCol is Ncol-2,
                            (getPiece(Board,NewRow,NewCol,Piece),
                            Piece \='empty');
                            (getPiece(Board,NewRow,Newcol,Piece),
                            Piece \='empty');
                            (getPiece(Board,Nrow,NewCol,Piece),
                            Piece \='empty').

  checkMoves('pieceY2', Board) :- getElement(Board, Nrow, Ncol, 'pieceY2'),
                            NewRow is Nrow-2,
                            Newcol is Ncol-2,
                            (getPiece(Board,NewRow,Newcol,Piece),
                            Piece \='empty');
                            (getPiece(Board,Nrow,Newcol,Piece),
                            Piece \='empty');
                            (getPiece(Board,NewRow,Ncol,Piece),
                            Piece \='empty').

  endGame(Board) :- player(Curr_player),
                    if_then_else(Curr_player==playerX, (checkPieces('pieceX1',Board),checkPieces('pieceX2',Board),
                                                      checkMoves('pieceX1',Board),checkMoves('pieceX2',Board)),
                                                                (checkPieces('pieceY1',Board),checkPieces('pieceY2',Board),
                                                                 checkMoves('pieceY1',Board),checkMoves('pieceY2',Board))).
  areaX(Nrow,Ncol):- (Ncol@>1,
                      Ncol@<6,
                      Nrow@>0,
                      Nrow@<5);
                      (Ncol@>0,
                      Ncol@<5,
                      Nrow@>4,
                      Nrow@<9).

  areaY(Nrow,Ncol):- (Ncol@>5,
                      Ncol@<10,
                      Nrow@>1,
                      Nrow@<6);
                      (Ncol@>4,
                      Ncol@<9,
                      Nrow@>5,
                      Nrow@<10).


  saveElements(Board,'pieceX1',List):- setof(Nrow-Ncol,getElement(Board,Nrow,Ncol,'pieceX1'),List).
  saveElements(Board,'pieceX2',List):- setof(Nrow-Ncol,getElement(Board,Nrow,Ncol,'pieceX2'),List).
  saveElements(Board,'pieceY1',List):- setof(Nrow-Ncol,getElement(Board,Nrow,Ncol,'pieceY1'),List).
  saveElements(Board,'pieceY2',List):- setof(Nrow-Ncol,getElement(Board,Nrow,Ncol,'pieceY2'),List).

  getNrowNcol([],PointsXIn,PointsXOut,'playerX').
  getNrowNcol([],PointsYIn,PointsYOut,'playerY').
  getNrowNcol([Nrow-Ncol|Rest],PointsXIn,PointsXOut,'playerX'):-
                                                    if_then_else(areaX(Nrow,Ncol),PointsXOut is PointsXIn+3,
                                                                                  PointsXOut is PointsXIn+1),nl,
                                                                                  write(Nrow-Ncol),
                                                                      getNrowNcol(Rest,PointsXIn,PointsXOut,'playerX').
  getNrowNcol([Nrow-Ncol|Rest],PointsYIn,PointsYOut,'playerY'):-
                                                    if_then_else(areaY(Nrow,Ncol),PointsYOut is PointsYIn+3,
                                                                                  PointsYOut is PointsYIn+1),
                                                                      getNrowNcol(Rest,PointsYIn,PointsYOut,'playerY').

  calculatePoints(Board):- saveElements(Board,'pieceX1',List),
                           saveElements(Board,'pieceX2',List2),
                           append(List,List2,FinalListX),
                           getNrowNcol(FinalListX,0,PointsX,'playerX'),
                           saveElements(Board,'pieceY1',List3),
                           saveElements(Board,'pieceY2',List4),
                           append(List3,List4,FinalListY),
                           getNrowNcol(FinalListY,0,PointsY,'playerY'),
                           nl,
                           write('Points of playerX:'), write(PointsX),nl,
                           write('Points of playerY:'), write(PointsY),nl.

  checkWinner(PointsX,PointsY) :- if_then_else(PointsX@>PointsY,write('The winner is PlayerY'),write('The winner is PlayerX')).
