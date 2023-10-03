%%%%MORPION
%-include_lib("rand.hrl").
-module(morpion_server).
-export([start/0,loop/8,pion_update/5,morpion/9]).


start()->
    spawn(?MODULE,loop,[[],[],
        [[P1={0,0},P2={1,0},P3={2,0}],
        [P1={0,0},P4={0,1},P7={0,2}],
        [P1={0,0},P5={1,1},P9={2,2}],
        [P2={1,0},P5={1,1},P8={1,2}],
        [P3={2,0},P6={2,1},P9={2,2}],
        [P3={2,0},P5={1,1},P7={0,2}],
        [P4={0,1},P5={1,1},P6={2,1}],
        [P7={0,2},P8={1,2},P9={2,2}]],
        0,0,0,false,[{0,0},{1,0},{2,0},{0,1},{1,1},{2,1},{0,2},{1,2},{2,2}]]).

        

loop(Play_pion, Serv_pion, Cur_pion, Incr, O, X, B,L) ->
    receive
        {Clt, {move,{Position,Symb}}} ->
            
            Clt ! {ok, {Symb,{O,X}}},
            
            if
                Position == p1 -> P = {0,0};
                Position == p2 -> P = {1,0};
                Position == p3 -> P = {2,0};
                Position == p4 -> P = {0,1};
                Position == p5 -> P = {1,1};
                Position == p6 -> P = {2,1};
                Position == p7 -> P = {0,2};
                Position == p8 -> P = {1,2};
                Position == p9 -> P = {2,2}
            end,

            if
                Symb==x ->

                    {NewB,NewL,NewPlayPion, NewServPion} = pion_update(Play_pion, Serv_pion,P,L,B),
                    
                   
                    io:fwrite("Incr : ~w~n", [Incr]),
                    io:fwrite("X: ~w~n", [NewPlayPion]),
                    io:fwrite("B:~w ~n", [B]),
                    io:fwrite("O: ~w~n", [NewServPion]),
                    io:fwrite("B:~w ~n", [NewB]);
                Symb==o ->

                    {NewB,NewL,NewPlayPion, NewServPion} = pion_update(Play_pion, Serv_pion,P,L,B),
                    
                    io:fwrite("Incr : ~w~n", [Incr]),
                    io:fwrite("O: ~w~n", [NewPlayPion]),
                    io:fwrite("B:~w ~n", [B]),
                    io:fwrite("X: ~w~n", [NewServPion]),
                    io:fwrite("B:~w ~n", [NewB])
                end,
                    
           if
               length(NewPlayPion)>=3-> 
                    morpion(NewPlayPion, NewServPion, Cur_pion, O, X, B,Incr,NewL,Symb);
                

               length(NewPlayPion)<3 -> 
                    loop(NewPlayPion, NewServPion, Cur_pion, Incr + 1, O, X, B,NewL)
         end;

        {Clt, stop} ->
            Clt ! {bye}
    end.



morpion(Play_pion,Serv_pion,Cur_pion,O,X,B,Incr,L,Symb)->
    
    if 
        length(Play_pion)==3->
             Play=[[lists:nth(1,Play_pion),lists:nth(2,Play_pion),lists:nth(3,Play_pion)]],
             Serv=[[lists:nth(1,Serv_pion),lists:nth(2,Serv_pion),lists:nth(3,Serv_pion)]];

        length(Play_pion)==4->
             Play=[[lists:nth(1,Play_pion),lists:nth(2,Play_pion),lists:nth(3,Play_pion)],
                [lists:nth(2,Play_pion),lists:nth(3,Play_pion),lists:nth(4,Play_pion)],
                [lists:nth(1,Play_pion),lists:nth(3,Play_pion),lists:nth(4,Play_pion)],
                [lists:nth(1,Play_pion),lists:nth(2,Play_pion),lists:nth(4,Play_pion)]],

            Serv=[[lists:nth(1,Serv_pion),lists:nth(2,Serv_pion),lists:nth(3,Serv_pion)],
                [lists:nth(1,Serv_pion),lists:nth(3,Serv_pion),lists:nth(4,Serv_pion)],
                [lists:nth(1,Serv_pion),lists:nth(2,Serv_pion),lists:nth(4,Serv_pion)],
                [lists:nth(2,Serv_pion),lists:nth(3,Serv_pion),lists:nth(4,Serv_pion)]];
        
        length(Play_pion)==5->  

                Play=[[lists:nth(1,Play_pion),lists:nth(2,Play_pion),lists:nth(3,Play_pion)],
                 [lists:nth(1,Play_pion),lists:nth(2,Play_pion),lists:nth(4,Play_pion)],
                 [lists:nth(1,Play_pion),lists:nth(2,Play_pion),lists:nth(5,Play_pion)],
                 [lists:nth(1,Play_pion),lists:nth(3,Play_pion),lists:nth(4,Play_pion)],
                 [lists:nth(1,Play_pion),lists:nth(3,Play_pion),lists:nth(5,Play_pion)],
                 [lists:nth(1,Play_pion),lists:nth(4,Play_pion),lists:nth(5,Play_pion)],
                 [lists:nth(2,Play_pion),lists:nth(3,Play_pion),lists:nth(4,Play_pion)],
                 [lists:nth(2,Play_pion),lists:nth(4,Play_pion),lists:nth(5,Play_pion)],
                 [lists:nth(3,Play_pion),lists:nth(4,Play_pion),lists:nth(5,Play_pion)],
                 [lists:nth(3,Play_pion),lists:nth(2,Play_pion),lists:nth(5,Play_pion)]],
    
                Serv=[[lists:nth(1,Serv_pion),lists:nth(2,Serv_pion),lists:nth(3,Serv_pion)],
                 [lists:nth(1,Serv_pion),lists:nth(3,Serv_pion),lists:nth(4,Serv_pion)],
                 [lists:nth(1,Serv_pion),lists:nth(2,Serv_pion),lists:nth(4,Serv_pion)],
                 [lists:nth(2,Serv_pion),lists:nth(3,Serv_pion),lists:nth(4,Serv_pion)]]
        end,



    case lists:any(fun(Element)->lists:member(lists:sort(Element), lists:sort(Cur_pion)) end,Play) of 
           true->
            if
             Symb==o ->
                NewO=O+1, 
                NewX=X,
                io:fwrite("Win!! :) ~n"),
                io:fwrite("YourScore:~w ~n",[NewO]),
                io:fwrite("ServerScore:~w ~n",[NewX]);
                
             Symb==x ->
                NewO=O,
                NewX=X+1,
                io:fwrite("Win!! :) ~n"),
                io:fwrite("YourScore:~w ~n",[NewX]),
                io:fwrite("ServerScore:~w ~n",[NewO])
             end,

            loop([],[],Cur_pion,0,NewO,NewX,B,[{0,0},{1,0},{2,0},{0,1},{1,1},{2,1},{0,2},{1,2},{2,2}]),
             
                true;
            false->
                case lists:any(fun(Element)->lists:member(lists:sort(Element), lists:sort(Cur_pion)) end,Serv) of 
                true->
                    if 
                        Symb==o->
                            NewO=O,
                            NewX=X+1,
                            io:fwrite("Lost!! :(  ~n"),
                            io:fwrite("YourScore:~w ~n",[NewO]),
                            io:fwrite("ServerScore:~w ~n",[NewX]);
                        Symb==x->
                            NewO=O+1,
                            NewX=X,
                            io:fwrite("Lost!! :(  ~n"),
                            io:fwrite("YourScore:~w ~n",[NewX]),
                            io:fwrite("ServerScore:~w ~n",[NewO])
                        end,

                    loop([],[],Cur_pion,0,NewO,NewX,B,[{0,0},{1,0},{2,0},{0,1},{1,1},{2,1},{0,2},{1,2},{2,2}]),
             
                    true;
                false->
                    if 
                        length(Play_pion)==5->
                            NewO=O,
                            NewX=X,
                            loop([],[],Cur_pion,0,NewO,NewX,B,[{0,0},{1,0},{2,0},{0,1},{1,1},{2,1},{0,2},{1,2},{2,2}]);
                        length(Play_pion)<5->
                            NewO=O,
                            NewX=X,
                            loop(Play_pion,Serv_pion,Cur_pion,Incr+1,NewO,NewX,B,L)
                        end

                    
                end
        end.




pion_update(Play_pion,Serv_pion,Position,L,B)->
    if
        length(Play_pion)<4->

            case lists:member(Position,Play_pion++Serv_pion) of
                true->
                    NewPlayPion=Play_pion,
                    NewServPion=Serv_pion,
                    NewL1=L,
                    NewB=B,
                    {NewB,NewL1,NewPlayPion,NewServPion};

        
                
                false->
                    NewPlaypion=Play_pion++[Position],
                    NewL= lists:delete(Position,L),
                    N=rand:uniform(length(NewL)),
                    Element=lists:nth(N, NewL),
                    NewServPion=Serv_pion++[Element],
                    NewL1=lists:delete(Element,NewL),
                    NewB=true,
                    {NewB,NewL1,NewPlaypion,NewServPion}
            end;

        length(Play_pion)==4->
            case lists:member(Position,Play_pion++Serv_pion) of
                true->
                    NewPlayPion=Play_pion,
                    NewServPion=Serv_pion,
                    NewL1=L,
                    NewB=B,
                    {NewB,NewL1,NewPlayPion,NewServPion};

        

                false->
                NewPlaypion=Play_pion++[Position],
                NewServPion=Serv_pion,
                NewB=true,
                NewL1=L,
                {NewB,NewL1,NewPlaypion, NewServPion}
            end
        end.



                


        
        



