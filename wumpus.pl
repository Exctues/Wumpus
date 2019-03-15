% (Y,X) == (ROW, COLUMN) counting from bottom to up for row and from left to right for column.

%***********************************
% This is the 1st map
%%%%%%%%%%%
%* * * * *%
%* * * * *%
%* * G * *%
%P P * * *%
%S W * * *%
%%%%%%%%%%%

% wumpus((1,2)).                    
% gold((3,3)).
% pit((2,1)).
% pit((2,2)).   
%***********************************
%
%***********************************
% This is the 2nd map
%%%%%%%%%%%
%* * * P *%
%* P * P *%
%* W * P *%
%* P * P *%
%S P G P *%
%%%%%%%%%%%

% wumpus((3,2)).                    
% gold((1,3)).
% pit((1,2)).
% pit((2,2)).   
% pit((2,2)).   
% pit((4,2)).   
% pit((1,4)).   
% pit((2,4)).   
% pit((3,4)).   
% pit((4,4)).   
% pit((5,4)).   
%***********************************
%
%***********************************
% This is the 3rd map
%%%%%%%%%%%
%* * * * *%
%* * * * *%
%* * * * *%
%* * W P *%
%S * P G P%
%%%%%%%%%%%

% wumpus((2,3)).                    
% gold((1,4)).
% pit((1,3)).
% pit((1,5)).   
% pit((2,4)).   
%***********************************
% This is the 4th map
%%%%%%%%%%%
%* * W * G%
%* * * * *%
%* * * * *%
%* * * P *%
%S * * * *%
%%%%%%%%%%%

wumpus((5,3)).                    
gold((5,5)).
pit((2,4)).     


%Check whether we inside our playground.
not_wall((Y,X)):-
    X @>= 1,
    X @=< 5,
    Y @>= 1,
    Y @=< 5.

% Spreading stenches around wumpus.
stench((Y,X)):-
    (Xminus is X-1, Xplus is X+1),
    (Yminus is Y-1, Yplus is Y+1),
    wumpus((Y,X));
    (wumpus((Xminus,Y)); wumpus((Xplus,Y)));
    (wumpus((Y,Xminus)); wumpus((Y,Xplus))).

% Spreading breezes around pits.
breez((Y,X)):-
    (Xminus is X-1, Xplus is X+1),
    (Yminus is Y-1, Yplus is Y+1),
    pit((Y,X));
    (pit((Xminus, Y)); pit((Xplus, Y)));
    (pit((X, Yminus)); pit((X, Yplus))).

% Will I stay alive if i will step on (Y,X) cell?.
safe((Y,X), WumpusDead):- 
    (WumpusDead == 1) ->                    % if wumpus not dead
    not(pit((Y,X)));                        % then check if no pit on (Y,X)
    (not(pit((Y,X))), not(wumpus((Y,X)))).  % else chekc if no pit and no wumpus on (Y,X)

gotgold((Y,X), [], Visited, Count, Points, WumpusDead,Stream):-
    gold((Y,X)),
    Answer is Count+Points,
    write(Stream,Answer),
    write(Stream,"->").

%Since we try to kill wumpus only when it 1 cell near we can just check near cell. We use this fact when D = "direction+shoot" in gotgold function.
killWumpus((Y,X)):-
    wumpus((Y,X)).

%Count stands for number of cell our agent have traversed.
%Points stands for number of points it spent on Something(Backtracking from death by wumpus/pit, arrow).
%WumpusDead == 1 if wumpus is dead and otherwise it is 0.
gotgold((Y,X),[D|T], Visited, Count, Points, WumpusDead,Stream):-
    safe((Y,X), WumpusDead), % If it is not save then agent should die.
    Count @=< 25,                % Since our map is 5 by 5 then it is ineffective to step on more than 25 cells until you have found gold.
    Xplus is X+1, Xminus is X-1,
    Yplus is Y+1, Yminus is Y-1,
    Countplus is Count + 1,
    Pointsplus is Points + 10, % In case we should an arrow we should add this 10 points.
    ( 
        (D = "up", not_wall((Yplus,X)), not(member((Yplus,X),  Visited)), gotgold((Yplus,X),  T, [(Y,X)|Visited], Countplus, Points, WumpusDead,Stream));
        (D = "up+shoot", not_wall((Yplus,X)), not(member((Yplus,X), Visited)),
        stench((Y,X)), WumpusDead == 0, killWumpus((Yplus,X)),
        gotgold((Yplus,X), T, [(Y,X)|Visited], Countplus, Pointsplus, 1,Stream));

        (D = "right", not_wall((Y,Xplus)), not(member((Y,Xplus),  Visited)), gotgold((Y,Xplus),  T, [(Y,X)|Visited], Countplus, Points, WumpusDead,Stream));
        (D = "right+shoot", not_wall((Y,Xplus)), not(member((Y,Xplus), Visited)),
        stench((Y,X)), WumpusDead == 0, killWumpus((Y,Xplus)),
        gotgold((Y,Xplus), T, [(Y,X)|Visited], Countplus, Pointsplus, 1,Stream));

        (D = "down", not_wall((Yminus,X)), not(member((Yminus,X),  Visited)), gotgold((Yminus,X),  T, [(Y,X)|Visited], Countplus, Points, WumpusDead,Stream));
        (D = "down+shoot", not_wall((Yminus,X)), not(member((Yminus,X), Visited)),
        stench((Y,X)), WumpusDead == 0, killWumpus((Yminus,X)),
        gotgold((Yminus,X), T, [(Y,X)|Visited], Countplus, Pointsplus, 1,Stream));

        (D = "left", not_wall((Y,Xminus)), not(member((Y,Xminus),  Visited)), gotgold((Y,Xminus),  T, [(Y,X)|Visited], Countplus, Points, WumpusDead,Stream));
        (D = "left+shoot", not_wall((Y,Xminus)), not(member((Y,Xminus), Visited)),
        stench((Y,X)), WumpusDead == 0, killWumpus((Y,Xminus)),
        gotgold((Y,Xminus), T, [(Y,X)|Visited], Countplus, Pointsplus, 1,Stream))
    ).

% L is a list of solutions. The number of L's you get it is a number of possible solutions.
start(L):-
    %set_prolog_flag(answer_write_options,[max_depth(0)]),
    open('pyinput.txt',write, Stream),
    forall((gotgold((1,1), L, [], 0, 0, 0,Stream)), write(Stream, L)), %write in file all possible solutions(L).
    close(Stream).


% EVERYTHING BELOW DOESN'T WORK.
% I tried to make automatic usage of python script but didn't get how to do it properly 
% % Utilization function which helps to make output more cleaner. The final output is in "pyoutput.txt".
% python_run():-
%     % setup_call_cleanup(
%     % process_create(path('script.py'),[Script,Option],[stdout(pipe(Out))]),
%     % read_lines(Out,Lines),
%     % close(Out)).
%     process_create('script.py',[],[]).