# Dans ce module j'expliquerais les différentes propriétés utilisé pour le jeu

Pour formaliser les propriétés écrites en sHML utilisées par detectEr, nous pouvons rappeler que :

Le mot-clé `#!shml with` repère la signature de la fonction qui est lancée en tant que processus, tandis que le mot-clé `#!shml monitor` définit la propriété à analyser au moment de l'exécution.

`# P1 propriété d'initialisation des variables:`
with 
    morpion_server:loop(_,_,_,_,_,_,_)
monitor
    and(
        [_ <- _, morpion_server:loop(Play_pion, Serv_pion, Cur_pion, O, X, B,L)
        when Play_pion=/= [] orelse Serv_pion =/= [] orelse Cur_pion=:=[] 
        orelse O=/=0 orelse X =/= 0 orelse B =/= false orelse L =:= []]ff


        ).
-Dans cette propriété l'on vérifie tout simplement le fait que losqu'une des variables contenu dans la la loop n'est pas initialisé (n'a pas sa valeur initiale ),au début du jeu alors il ya une violation de sécurité.

`# P2 propriété de position des pions:`

with
    morpion_server:loop(_,_,_,_,_,_,_)
monitor
    and([_<-_ ,morpion_server:loop(_,_,_,_,_,_,_)]
        max(X.
             and(
                 [_?{_,{move,{p1,_}}}] and(
                    [_:_ ! {ok, {P,_,{_,_}}} when P =/= {0,0}]ff,
                    [_:_ ! {ok, {P,_,{_,_}}} when P =:= {0,0}]X
                 ),


                 [_?{_,{move,{p2,_}}}] and(
                    [_:_ ! {ok, {P,_,{_,_}}} when P =/= {1,0}]ff,
                    [_:_ ! {ok, {P,_,{_,_}}} when P =:= {1,0}]X
                 ),


                 [_?{_,{move,{p3,_}}}] and(
                    [_:_ ! {ok, {P,_,{_,_}}} when P =/= {2,0}]ff,
                    [_:_ ! {ok, {P,_,{_,_}}} when P =:= {2,0}]X
                 ),


                [_?{_,{move,{p4,_}}}] and(
                    [_:_ ! {ok, {P,_,{_,_}}} when P =/= {0,1}]ff,
                    [_:_ ! {ok, {P,_,{_,_}}} when P =:= {0,1}]X
                 ),


                 [_?{_,{move,{p5,_}}}] and(
                    [_:_ ! {ok, {P,_,{_,_}}} when P =/= {1,1}]ff,
                    [_:_ ! {ok, {P,_,{_,_}}} when P =:= {1,1}]X
                 ),


                 [_?{_,{move,{p6,_}}}] and(
                    [_:_ ! {ok, {P,_,{_,_}}} when P =/= {2,1}]ff,
                    [_:_ ! {ok, {P,_,{_,_}}} when P =:= {2,1}]X
                 ),


                 [_?{_,{move,{p7,_}}}] and(
                    [_:_ ! {ok, {P,_,{_,_}}} when P =/= {0,2}]ff,
                    [_:_ ! {ok, {P,_,{_,_}}} when P =:= {0,2}]X
                 ),


                 [_?{_,{move,{p8,_}}}] and(
                    [_:_ ! {ok, {P,_,{_,_}}} when P =/= {1,2}]ff,
                    [_:_ ! {ok, {P,_,{_,_}}} when P =:= {1,2}]X
                 ),


                 [_?{_,{move,{p9,_}}}] and(
                    [_:_ ! {ok, {P,_,{_,_}}} when P =/= {2,2}]ff,
                    [_:_ ! {ok, {P,_,{_,_}}} when P =:= {2,2}]X
                 )

              )
        )
    ).


Sur cette propriété je précise par exemple d’une part le fait que lorsque le joueur souhaite placer son pion sur la première position p1 de coordonnées {0,0} ligne 7, si le serveur place le pion sur une autre position alors la propriété est violée ligne 8, mais au cas contraire il y a une récursivité de cette propriété ligne 9.  
La même règle s'applique aux autres positions, sachant que:
p1  = {0,0};
p2  = {1,0};
p3  = {2,0};
p4  = {0,1};
p5  = {1,1};
p6  = {2,1};
p7  = {0,2};
p8  = {1,2};
p9  = {2,2}.

`# P3 propriété de reponses aux client:`

with
  morpion_server:loop(_,_,_,_,_,_,_)
monitor
  and([_ <- _, morpion_server:loop(_,_,_,_,_,_,_)]
    max(X.
      and([Srv_1 ? {Clt_1, _}]
        max(Y.
          and(
            [Srv_2:Clt_2 ! _ when Srv_1 =:= Srv_2 andalso Clt_1 =/= Clt_2]ff,
            [Srv_2:Clt_2 ! _ when Srv_1 =:= Srv_2 andalso Clt_1 =:= Clt_2]X,
            [_ ? _]Y
          ) )))).

-Sur cette propriété, d’une part j’ai précisé que lorsque le serveur reçois n’importe quelle requête (ligne 7) alors il ne peut répondre que si le client qui reçois le service est bien celui qui a envoyé la requête, ligne 11. Dans le cas contraire il y a une violation de la propriété,ligne 10; L’évènement récursif «[_ ? _]Y » de réception signifie que parallèlement tout autre événement ne faisant pas appel à cette propriété n’est pas considérée.

`# P4 propriété du score:`

with
    morpion_server:loop(_,_,_,_,_,_,_)
monitor
    and([_ <- _, morpion_server:loop(_,_,_,_,_,_,_)]
        max(Y.
            and([_ ? {_, {move,{_,_}}}] 
                and(
                     [_:_ ! {ok, {_,_,{O,X}}} when X < 0 orelse O < 0]ff,
                     [_:_ ! {ok, {_,_,{O,X}}} when X >= 0 orelse O >= 0]Y
                )))).
-Dans cette propriété je précise bien que lorsque la variable représentant le score (X ou O) est inférieur à 0 alors il y a une violation de sécurité (ligne 9) au cas contraire il y a la récursivité sur la formule, ligne 10.

`# P5 propriété du symbole du pion:`
with
  morpion_server:loop(_,_,_,_, _, _,_)
monitor
  and([_ <- _, morpion_server:loop(_,_,_, _, _, _,_)]
        max(X.

           and(
             [_ ? {_, {move,{_,Symb}}}] 
                and(
                  [_:_ ! {ok, {_,_,{_,_}}}]
                      and(
                          [_? {_, {move,{_,Symb1}}} when Symb=/=Symb1]ff,
                          [_ ? {_, {move,{_,Symb1}}} when Symb=:=Symb1] and(
                          [_:_ ! {ok, {_,_,{_,_}}}]X

                         )))))).

-Dans cette propriété, j’ai stocké le symbole qui sera reçu premièrement dans la variable Symb (Ligne 9) ensuite le second symbole lors de la suivante requête est stocké dans la variable Symb1 et alors après je vérifie dans chaque cas si elles ont la même valeur (ligne 9) et cela me permettra de savoir si la propriété a été violée ou non.

