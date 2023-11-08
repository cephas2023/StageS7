# EXPLICATION DU JEU MORPION

Afin de favoriser la compréhension de mon projet de stage, dans la suite j'expliquerais les différentes fonctions qui y interviennent.

# LE JEU DU MORPION

Considérons une grille de 9 positions;
Sur cette grille i y est question de placé des pions qui sont réprésenter par les symboles X et O selon le joueur.
Alors il s'agit de placé les pions sur les différentes positions afin d'aligner trois pions(Verticalement,Horizontalement,diagonalement), afin de remporter la partie de jeu.

Ainsi, il existe un protocole client-serveur dans lequel les messages sont adressés au serveur en utilisant son PID.
Dans ce protocole client-serveur, les messages contiennent la commande "move" qui permet de placer le pion, la position à laquelle on le place "p1...p9", le symbole du pion "X ou O" et le PID du client auquel est adressée la réponse correspondante du serveur.
Mon programme Bob est implémenté dans le module Erlang `#!erlan morpion_server`.

# Morpion_serveur

Le serveur est constitué de 2 principales fontions, que je vais expliqué avant d'entamer l'explication de la fonction principale.

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
        0,0,false,[{0,0},{1,0},{2,0},
        {0,1},{1,1},{2,1},{0,2},{1,2},{2,2}]]).

-La fonction `#!erlan morpion_server:start/0` est utilisé pour initialiser les paramètres du jeu à savoir, une première liste qui est la liste de pions placés par le joueur, et une seconde qui est celle des pions placés par le serveur; Aussi nous avons une liste contenant les différentes combinaisons possibles de pions permettant de remporter une partie de jeu; et Enfin nous avons les deux scores des deux joueurs, la variable permettant de montrer l'alternance des tours de jeu (booléenne false), et une liste contenant des positions que le serveur jouera.


morpion(Play_pion,Serv_pion,Cur_pion,O,X,B,L,Symb)->
    
    if 
        
        length(Play_pion)==3->
             Play=[[lists:nth(1,Play_pion),lists:nth(2,Play_pion),
                lists:nth(3,Play_pion)]],
             Serv=[[lists:nth(1,Serv_pion),lists:nth(2,Serv_pion),
                lists:nth(3,Serv_pion)]];

        length(Play_pion)==4->
             Play=[[lists:nth(1,Play_pion),lists:nth(2,Play_pion),
                lists:nth(3,Play_pion)],
                [lists:nth(2,Play_pion),lists:nth(3,Play_pion),
                    lists:nth(4,Play_pion)],
                [lists:nth(1,Play_pion),lists:nth(3,Play_pion),
                    lists:nth(4,Play_pion)],
                [lists:nth(1,Play_pion),lists:nth(2,Play_pion),
                    lists:nth(4,Play_pion)]],

            Serv=[[lists:nth(1,Serv_pion),lists:nth(2,Serv_pion),
                lists:nth(3,Serv_pion)],
                [lists:nth(1,Serv_pion),lists:nth(3,Serv_pion),
                    lists:nth(4,Serv_pion)],
                [lists:nth(1,Serv_pion),lists:nth(2,Serv_pion),
                    lists:nth(4,Serv_pion)],
                [lists:nth(2,Serv_pion),lists:nth(3,Serv_pion),
                    lists:nth(4,Serv_pion)]];
        
        length(Play_pion)==5->  

                Play=[[lists:nth(1,Play_pion),lists:nth(2,Play_pion),
                    lists:nth(3,Play_pion)],
                 [lists:nth(1,Play_pion),lists:nth(2,Play_pion),
                    lists:nth(4,Play_pion)],
                 [lists:nth(1,Play_pion),lists:nth(2,Play_pion),
                    lists:nth(5,Play_pion)],
                 [lists:nth(1,Play_pion),lists:nth(3,Play_pion),
                    lists:nth(4,Play_pion)],
                 [lists:nth(1,Play_pion),lists:nth(3,Play_pion),
                    lists:nth(5,Play_pion)],
                 [lists:nth(1,Play_pion),lists:nth(4,Play_pion),
                    lists:nth(5,Play_pion)],
                 [lists:nth(2,Play_pion),lists:nth(3,Play_pion),
                    lists:nth(4,Play_pion)],
                 [lists:nth(2,Play_pion),lists:nth(4,Play_pion),
                    lists:nth(5,Play_pion)],
                 [lists:nth(3,Play_pion),lists:nth(4,Play_pion),
                    lists:nth(5,Play_pion)],
                 [lists:nth(3,Play_pion),lists:nth(2,Play_pion),
                    lists:nth(5,Play_pion)]],
    
                Serv=[[lists:nth(1,Serv_pion),lists:nth(2,Serv_pion),
                    lists:nth(3,Serv_pion)],
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

            loop([],[],Cur_pion,NewO,NewX,B,[{0,0},{1,0},{2,0},{0,1},{1,1},{2,1},{0,2},{1,2},{2,2}]),
             
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

                    loop([],[],Cur_pion,NewO,NewX,B,[{0,0},{1,0},{2,0},{0,1},{1,1},{2,1},{0,2},{1,2},{2,2}]),
             
                    true;
                false->
                    if 
                        length(Play_pion)==5->
                            NewO=O,
                            NewX=X,
                            loop([],[],Cur_pion,NewO,NewX,B,[{0,0},{1,0},{2,0},{0,1},{1,1},{2,1},{0,2},{1,2},{2,2}]);
                        length(Play_pion)<5->
                            NewO=O,
                            NewX=X,
                            loop(Play_pion,Serv_pion,Cur_pion,NewO,NewX,B,L)
                        end

                    
                end
        end.

-La fonction `#!erlang morpion_server:morpion/8`, est une fonction utilisé afin de de vérifier sur la grille de jeu, l'état de celle-ci ou si toutefois, un des joueurs a gagné la partie.
Prémièrement, le serveur lance la vérification que dans le cas où il ya plus de 3 pions dans la grille de jeu.
En effet lorsqu'on a de tois pions, alors le serveur crée une liste Play avec une combinaison de trois position de pions sur trois pions (L'ordre ne compte pas) -> Cours de proba :)
Si il ya 4 ou 5 élémnets dans la liste alors la liste Play va contenir, les combinaisons des 3 positions de pions sur 4 positions ou sur 5 positions.
Ce processus est effctué de même pour la liste de pions du serveur Serv_pion.
Deuxièmement, le serveur verifie si au moins une des combinaisons de positions créée précedemment appartien à la liste des combinaison possible pour remporter la partie à savoir la liste Cur_pion.
Si c'est le cas en fonction du symbole des pions joués par les joueurs on incrémente le score et on relance un nouveuau tour de jeu, dans le cas contraire on relance un nouveau tour de jeu grâce à la fonction boucle et cela sans modifié les scores.
Enfin, lorsque toutes les parties ont joué leurs pions c'est à dire que lorsque la liste de pions du joueur atteindra 5 et qu'aucun des joueurs n'a remporté la partie jeu alors le jeu est rénitialisé avec toutes les variables comprises.



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


-La fonction `#!erlang morpion_server:pion_update/5`,permet de mettre à jour la grille de jeu.
D'abord si la liste de pions du joueurs est inférieurs à 4 éléments, le serveyr vérifie que la position Position, n'est pas encore utilisé dans par le serveur ou est préalablement utilisé par le joueur lui même; Si c'est le cas la position n'est pas ajouté et les liste des pions de chaque joueurs reste inchangé.
NB: en Erlang les variables sont immuables raisons pour laquelle on affecte leurs valeurs à d'autres nouvelles variables pour les utilisés.Exemple: NewPlayPion=Play_pion.
Ensuite si la position n'est pas encire utilisée on l'ajoute à la liste des pions du joueur et le serveur ajoute une position à sa liste de pions; Pour éviter que la position joué par le serveur ne soit réutilisée on l'enlève de la liste dans laquelle le serveur pioche les positions de pions.
Enfin si le nombre d'éléments de la liste de pions du joueurs est égale à 4 c'est à dire qu'il s'agit du dernier tour de jeu dans la partie alors le même processus de mise à jour est répété à l'exeption du fait le serveur ne pourra pas jouer puisqu'on a 9 positions sur la grille dont (4 pour le serveur et 5 pour le joueur).


# ATTAQUONS LA FONCTION PRINCIPALE LOOP/7

loop(Play_pion, Serv_pion, Cur_pion, O, X, B,L) ->
    receive
        {Clt, {move,{Position,Symb}}} ->
            
            
            
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

            Clt ! {ok, {P,Symb,{O,X}}},

            if
                Symb==x ->

                    {NewB,NewL,NewPlayPion, NewServPion} = pion_update(Play_pion, Serv_pion,P,L,B),
                    
                   
                    %io:fwrite("Incr : ~w~n", [Incr]),
                    io:fwrite("X: ~w~n", [NewPlayPion]),
                    io:fwrite("B:~w ~n", [B]),
                    io:fwrite("O: ~w~n", [NewServPion]),
                    io:fwrite("B:~w ~n", [NewB]);
                Symb==o ->

                    {NewB,NewL,NewPlayPion, NewServPion} = pion_update(Play_pion, Serv_pion,P,L,B),
                    
                   % io:fwrite("Incr : ~w~n", [Incr]),
                    io:fwrite("O: ~w~n", [NewPlayPion]),
                    io:fwrite("B:~w ~n", [B]),
                    io:fwrite("X: ~w~n", [NewServPion]),
                    io:fwrite("B:~w ~n", [NewB])
                end,
                    
           if
               length(NewPlayPion)>=3-> 
                    morpion(NewPlayPion, NewServPion, Cur_pion, O, X, B,NewL,Symb);
                

               length(NewPlayPion)<3 -> 
                    loop(NewPlayPion, NewServPion, Cur_pion, O, X, B,NewL)
         end;

        {Clt, stop} ->
            Clt ! {bye}
    end.

-Dans cette fonction, il ya d'abord suite à la reception de la requête : {Clt, {move,{Position,Symb}}} une phase de correspondance des positions est effectué, ensuite il ya l'envoi du service : Clt ! {ok, {P,Symb,{O,X}}}, par le serveur. Enfin, la fonction update_pion est utilisé pour mettre à jour la grille de jeu, renvoyant ainsi les nouvelles valeurs de variables qui seront affichés.
Quant à la fonction morpion il est appélé dès qu'on a au moins trois pions placés sur la grille de jeu.