## Test de sécurité du jeu

Tout d'abord exécutons le programme serveur du morpion.

1. On change le répertoire à `detecter/examples/erlang` pour pouvoir utiliser les propriétés de sécurité placées dans `detecter/examples/erlang/props/props_morpion`.

```console
ceph@DESKTOP-F06DBDB:~$ cd /mnt/c/Users/cephas/Desktop/detecter/detecter-master/detecter
ceph@DESKTOP-F06DBDB:/mnt/c/Users/cephas/Desktop/detecter/detecter-master/detecter$ cd ..
ceph@DESKTOP-F06DBDB:/mnt/c/Users/cephas/Desktop/detecter/detecter-master$ cd examples/erlang
ceph@DESKTOP-F06DBDB:/mnt/c/Users/cephas/Desktop/detecter/detecter-master/examples/erlang$ ls -l
total 0
-rwxrwxrwx 1 ceph ceph  573 Aug 11  2022 Makefile
drwxrwxrwx 1 ceph ceph 4096 Oct 31 16:57 ebin
drwxrwxrwx 1 ceph ceph 4096 Nov  8 13:10 props
drwxrwxrwx 1 ceph ceph 4096 Oct  4 10:17 src
```

2. Exécutons `make` pour compiler tous les modules de code source Erlang situés dans `examples/erlang/src`. 
   Le répertoire `ebin`, contenant les fichiers `*.beam` compilés, est mis à jour.

```console
ceph@DESKTOP-F06DBDB:/mnt/c/Users/cephas/Desktop/detecter/detecter-master/examples/erlang$ make
rm -f ebin/*.beam ebin/*.E ebin/*.erl ebin/*.tmp ebin/*.app erl_crash.dump
rm -df ebin
mkdir -p ebin
erlc -pa ebin +debug_info -I include -o ebin    src/demo/bob_client.erl src/demo/bob_server.erl src/demo/calc_client.erl src/demo/calc_server.erl src/demo/calc_server_bug.erl src/demo/calc_server_dbl_add.erl src/demo/hello.erl src/demo/token_server.erl src/morpion/morpion_server.erl
```

3. Lançons le shell Erlang avec `erl`.
   Nous ajoutons les binaires de detectEr et ceux que nous venons de compiler au chemin de code du shell via `-pa`.

```console
ceph@DESKTOP-F06DBDB:/mnt/c/Users/cephas/Desktop/detecter/detecter-master/examples/erlang$ erl -pa ../../detecter/ebin ebin
Erlang/OTP 22 [erts-10.6.4] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1]

Eshell V10.6.4  (abort with ^G)
1>
```

4. Le serveur de bob game est démarré en invoquant `#!erlang morpion_server:start/0`.
   Cette fonction génère le processus du serveur et retourne un PID. On enregistre donc ce PID dans une variable, par exemple `#!erlang Pid`.

```erl
1> Pid=morpion_server:start().
<0.80.0>
2>
```

5. Le serveur est maintenant prêt à traiter les demandes des clients. On essaye de demander au serveur de placer un pion à la position p1 c'est à dire {0,0}.

```erl
2> Pid!{self(),{move,{p1,x}}}.
{<0.78.0>,{move,{p1,x}}}
X: [{0,0}]
B:false
O: [{0,1}]
B:true
```
On constate que lorsque le joueur a palcé le pion à la position p1 le pion pour le contre-carrée l'a placé à la position p4 c'est à dire {0,1}.

6. Pour obtenir la réponse du serveur depuis la boîte aux lettres du shell, nous utilisons un autre BIF, `#!erlang flush/0`, qui vide le contenu de la boîte aux lettres du shell.

```erl  
3> flush().
Shell got {ok,{{0,0},x,{0,0}}}
ok
On constate que nous avons la position joué `#!erlang {0, 0}`, le symbole du pion `#!erlang x` placé et enfin les scores des deux joueurs `#!erlang {0, 0}`.

```

7. Jouon pour constater le comportement du jeu

```erl
3> flush().
Shell got {ok,{{0,0},x,{0,0}}}
ok
4> Pid!{self(),{move,{p3,x}}}.
X: [{0,0},{2,0}]
{<0.78.0>,{move,{p3,x}}}
B:false
O: [{0,1},{0,2}]
B:true
5> Pid!{self(),{move,{p5,x}}}.
X: [{0,0},{2,0},{1,1}]
{<0.78.0>,{move,{p5,x}}}
B:false
O: [{0,1},{0,2},{1,2}]
B:true
6> Pid!{self(),{move,{p7,x}}}.
X: [{0,0},{2,0},{1,1}]
{<0.78.0>,{move,{p7,x}}}
B:false
O: [{0,1},{0,2},{1,2}]
B:false
7> Pid!{self(),{move,{p8,x}}}.
X: [{0,0},{2,0},{1,1}]
{<0.78.0>,{move,{p8,x}}}
B:false
O: [{0,1},{0,2},{1,2}]
B:false
8> Pid!{self(),{move,{p2,x}}}.
X: [{0,0},{2,0},{1,1},{1,0}]
{<0.78.0>,{move,{p2,x}}}
B:false
O: [{0,1},{0,2},{1,2},{2,1}]
B:true
Win!! :)
YourScore:1
ServerScore:0

En jouant on se rend compte que que lorsque j'essaie de placer le pion à P7 et P8 ligne 6 et ligne 7, ma liste de pions ne change pas car ces positions sont déjà occupées et contenus dans la liste de pions du serveur.
p7={0,2} et p8={1,2}.
Par contre lorsque j'ai placé le pion à p2 position n'étant pas encore ocuupé j'ai gangé la partie( Ligne 8).
```

8. Pour arrêter le serveur, on émet une requête `stop`

```erl
9> Pid!{self(),stop}.
{<0.78.0>,stop}
10> flush().
Shell got {ok,{{2,0},x,{0,0}}}
Shell got {ok,{{1,1},x,{0,0}}}
Shell got {ok,{{0,2},x,{0,0}}}
Shell got {ok,{{1,2},x,{0,0}}}
Shell got {ok,{{1,0},x,{0,0}}}
Shell got {bye}
ok
11> is_process_alive(Pid).
false
Le processus est bien terminé car le shell nous confirme suite à l'instruction `11>` que `#!erlang Pid` "n'est plus en vie".
De plus le dernier service reçu par le client Shell got {bye}.
```

## Inline instrumentation sur le jeu du morpion
---
### Test de sécurité sur la propriété  `init`

1. Mais avant de lancer le jeu créons une violation de sécurité qui sera détéctée

start()->
    %%%%Initalisation des variables
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

Dans cette fonction qui est chargé d'initialisé mes variables je vais transformé les deux premières listes vides afin de créer un bug.

start()->
    %%%%Initalisation des variables
    spawn(?MODULE,loop,[[1,2],[2,3],
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

2. Nous allons d'abord synthétiser notre analyseur programmé en sHML.

```erl
Eshell V10.6.4  (abort with ^G)
1> hml_eval:compile("props/props_morpion/prop_init.hml", [{outdir, "ebin"}, v]).
ok
```

3. Ensuite On doit charger les fichiers du répertoire `src` dans le shell.

```erl
2> weaver:weave("src", fun prop_init:mfa_spec/1, [{outdir, "ebin"}]).
[{ok,morpion_server,[]},
 {ok,token_server,[]},
 {ok,hello,[]},
 {ok,calc_server_dbl_add,[]},
 {ok,calc_server_bug,[]},
 {ok,calc_server,[]},
 {ok,calc_client,[]},
 {ok,bob_server,[]},
 {ok,bob_client,[]}]
```
4. 3>  Pid=morpion_server:start().
*** [<0.78.0>] Instrumenting monitor for MFA pattern '{morpion_server,
                                                                loop,
                                                                [[1,2],
                                                                 [1,2],
                                                                 [[{0,0},
                                                                   {1,0},
                                                                   {2,0}],
                                                                  [{0,0},
                                                                   {0,1},
                                                                   {0,2}],
                                                                  [{0,0},
                                                                   {1,1},
                                                                   {2,2}],
                                                                  [{1,0},
                                                                   {1,1},
                                                                   {1,2}],
                                                                  [{2,0},
                                                                   {2,1},
                                                                   {2,2}],
                                                                  [{2,0},
                                                                   {1,1},
                                                                   {0,2}],
                                                                  [{0,1},
                                                                   {1,1},
                                                                   {2,1}],
                                                                  [{0,2},
                                                                   {1,2},
                                                                   {2,2}]],
                                                                 0,0,false,
                                                                 [{0,0},
                                                                  {1,0},
                                                                  {2,0},
                                                                  {0,1},
                                                                  {1,1},
                                                                  {2,1},
                                                                  {0,2},
                                                                  {1,2},
                                                                  {2,2}]]}'.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,spawned,<0.78.0>,
                                      {morpion_server,loop,
                                       [[1,2],
                                        [1,2],
                                        [[{0,0},{1,0},{2,0}],
                                         [{0,0},{0,1},{0,2}],
                                         [{0,0},{1,1},{2,2}],
                                         [{1,0},{1,1},{1,2}],
                                         [{2,0},{2,1},{2,2}],
                                         [{2,0},{1,1},{0,2}],
                                         [{0,1},{1,1},{2,1}],
                                         [{0,2},{1,2},{2,2}]],
                                        0,0,false,
                                        [{0,0},
                                         {1,0},
                                         {2,0},
                                         {0,1},
                                         {1,1},
                                         {2,1},
                                         {0,2},
                                         {1,2},
                                         {2,2}]]}}.
<0.145.0>
*** [<0.145.0>] Reached verdict 'no'.
[INFO - <0.145.0> - analyzer:164] - Reached verdict 'no' after {init,<0.145.0>,<0.78.0>,{morpion_server,loop,[[1,2],[1,2],[[{0,0},{1,0},{2,0}],[{0,0},{0,1},{0,2}],[{0,0},{1,1},{2,2}],[{1,0},{1,1},{1,2}],[{2,0},{2,1},{2,2}],[{2,0},{1,1},{0,2}],[{0,1},{1,1},{2,1}],[{0,2},{1,2},{2,2}]],0,0,false,[{0,0},{1,0},{2,0},{0,1},{1,1},{2,1},{0,2},{1,2},{2,2}]]}}.

Dès que le processus de `#!erlang morpion_server` est démarré on observe une analyse de l'évènement d'initialisation `init` du detectEr. Cela est dû à la détection de l'évènement `#!erlang spawned` d'Erlang;
Cela conduit bien à un verdict de rejet, `#!erlang no`, qui correspond à une violation de notre propriété `init`.

5.  Peut importe les prochaines requêtes le verdict sera toujours `#!erlang no` tant que le programme n'est pas relancé.

Pid!{self(),{move,{p1,x}}}.
[INFO - <0.145.0> - analyzer:179] - Reached verdict 'no' after {recv,<0.145.0>,{<0.78.0>,{move,{p1,x}}}}.
[INFO - <0.145.0> - analyzer:174] - Reached verdict 'no' after {send,<0.145.0>,<0.78.0>,{ok,{{0,0},x,{0,0}}}}.
{<0.78.0>,{move,{p1,x}}}
X: [1,2,{0,0}]
B:false
O: [1,2,{0,2}]
B:true

6. Maintenant nous pouvons tester la version correct du serveur pour voir l'analyse du detectEr.

3> Pid=morpion_server:start().
*** [<0.78.0>] Instrumenting monitor for MFA pattern '{morpion_server,
                                                                loop,
                                                                [[],[],
                                                                 [[{0,0},
                                                                   {1,0},
                                                                   {2,0}],
                                                                  [{0,0},
                                                                   {0,1},
                                                                   {0,2}],
                                                                  [{0,0},
                                                                   {1,1},
                                                                   {2,2}],
                                                                  [{1,0},
                                                                   {1,1},
                                                                   {1,2}],
                                                                  [{2,0},
                                                                   {2,1},
                                                                   {2,2}],
                                                                  [{2,0},
                                                                   {1,1},
                                                                   {0,2}],
                                                                  [{0,1},
                                                                   {1,1},
                                                                   {2,1}],
                                                                  [{0,2},
                                                                   {1,2},
                                                                   {2,2}]],
                                                                 0,0,false,
                                                                 [{0,0},
                                                                  {1,0},
                                                                  {2,0},
                                                                  {0,1},
                                                                  {1,1},
                                                                  {2,1},
                                                                  {0,2},
                                                                  {1,2},
                                                                  {2,2}]]}'.
*** [<0.145.0>] Reached verdict 'end' on event {trace,<0.145.0>,
                                                         spawned,<0.78.0>,
                                                         {morpion_server,
                                                          loop,
                                                          [[],[],
                                                           [[{0,0},
                                                             {1,0},
                                                             {2,0}],
                                                            [{0,0},
                                                             {0,1},
                                                             {0,2}],
                                                            [{0,0},
                                                             {1,1},
                                                             {2,2}],
                                                            [{1,0},
                                                             {1,1},
                                                             {1,2}],
                                                            [{2,0},
                                                             {2,1},
                                                             {2,2}],
                                                            [{2,0},
                                                             {1,1},
                                                             {0,2}],
                                                            [{0,1},
                                                             {1,1},
                                                             {2,1}],
                                                            [{0,2},
                                                             {1,2},
                                                             {2,2}]],
                                                           0,0,false,
                                                           [{0,0},
                                                            {1,0},
                                                            {2,0},
                                                            {0,1},
                                                            {1,1},
                                                            {2,1},
                                                            {0,2},
                                                            {1,2},
                                                            {2,2}]]}}.
<0.145.0>
[INFO - <0.145.0> - analyzer:164] - Reached verdict 'end' after {init,<0.145.0>,<0.78.0>,{morpion_server,loop,[[],[],[[{0,0},{1,0},{2,0}],[{0,0},{0,1},{0,2}],[{0,0},{1,1},{2,2}],[{1,0},{1,1},{1,2}],[{2,0},{2,1},{2,2}],[{2,0},{1,1},{0,2}],[{0,1},{1,1},{2,1}],[{0,2},{1,2},{2,2}]],0,0,false,[{0,0},{1,0},{2,0},{0,1},{1,1},{2,1},{0,2},{1,2},{2,2}]]}}.

Le verdict est `#!erlang end`, c'est le résultat attendu avec cette propriété d'initialisation. Si le verdict était `#!erlang no` alors il y aurait un problème dans les arguments de la fonction lancée.

### Test de sécurité sur la propriété de position  `pos`

1. Mettons le bug 
                Position == p1 -> P = {5,0};
                Position == p2 -> P = {1,0};
                Position == p3 -> P = {2,0};
                Position == p4 -> P = {0,1};
                Position == p5 -> P = {1,1};
                Position == p6 -> P = {2,1};
                Position == p7 -> P = {0,2};
                Position == p8 -> P = {1,2};
                Position == p9 -> P = {2,2}.

En effet la position p1 est plutôt {0,0}, au lieu de {5,0}.

2. Le test donne:
 Pid!{self(),{move,{p1,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p1,x}}}}.
{<0.78.0>,{move,{p1,x}}}
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{5,0},x,{0,0}}},
                                      <0.78.0>}.
*** [<0.145.0>] Reached verdict 'no'.
5> [INFO - <0.145.0> - analyzer:174] - Reached verdict 'no' after {send,<0.145.0>,<0.78.0>,{ok,{{5,0},x,{0,0}}}}.
X: [{5,0}]
B:false
O: [{0,2}]
B:true

Nous avons bien une violation de propriété avec le verdict `#!erlang no`.

3. Testons le serveur sans bug

5>  Pid!{self(),{move,{p1,x}}}.
*** [<0.146.0>] Analyzing event {trace,<0.146.0>,'receive',
                                      {<0.78.0>,{move,{p1,x}}}}.
{<0.78.0>,{move,{p1,x}}}
*** [<0.146.0>] Analyzing event {trace,<0.146.0>,send,
                                      {ok,{{0,0},x,{0,0}}},
                                      <0.78.0>}.
*** [<0.146.0>] Unfolding rec. var. 'X'.
X: [{0,0}]
B:false
O: [{1,2}]
B:true

La récursivité de la variable `#!erlang x` fonctionne bien avec cette propriété, la `position` qui montre que la propriété n'est pas violée.

### Test de sécurité sur la propriété de reponse  `reply`
4>  Pid!{self(),{move,{p1,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p1,x}}}}.
{<0.78.0>,{move,{p1,x}}}
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{0,0},x,{0,0}}},
                                      <0.78.0>}.
*** [<0.145.0>] Unfolding rec. var. 'X'.
X: [{0,0}]
B:false
O: [{0,2}]
B:true
5>  Pid!{self(),{move,{p2,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p2,x}}}}.
{<0.78.0>,{move,{p2,x}}}
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{1,0},x,{0,0}}},
                                      <0.78.0>}.
*** [<0.145.0>] Unfolding rec. var. 'X'.
X: [{0,0},{1,0}]
B:false
O: [{0,2},{0,1}]
B:true
6>  Pid!{self(),{move,{p7,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p7,x}}}}.
{<0.78.0>,{move,{p7,x}}}
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{0,2},x,{0,0}}},
                                      <0.78.0>}.
*** [<0.145.0>] Unfolding rec. var. 'X'.
X: [{0,0},{1,0}]
B:false
O: [{0,2},{0,1}]
B:false
7>  Pid!{self(),{move,{p8,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p8,x}}}}.
{<0.78.0>,{move,{p8,x}}}
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{1,2},x,{0,0}}},
                                      <0.78.0>}.
*** [<0.145.0>] Unfolding rec. var. 'X'.
X: [{0,0},{1,0},{1,2}]
B:false
O: [{0,2},{0,1},{1,1}]
B:true
8>  Pid!{self(),{move,{p5,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p5,x}}}}.
{<0.78.0>,{move,{p5,x}}}
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{1,1},x,{0,0}}},
                                      <0.78.0>}.
*** [<0.145.0>] Unfolding rec. var. 'X'.
X: [{0,0},{1,0},{1,2}]
B:false
O: [{0,2},{0,1},{1,1}]
B:false
9>  Pid!{self(),{move,{p3,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p3,x}}}}.
{<0.78.0>,{move,{p3,x}}}
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{2,0},x,{0,0}}},
                                      <0.78.0>}.
*** [<0.145.0>] Unfolding rec. var. 'X'.
X: [{0,0},{1,0},{1,2},{2,0}]
B:false
O: [{0,2},{0,1},{1,1},{2,1}]
B:true
Win!! :)
YourScore:1
ServerScore:0
10> flush().
Shell got {ok,{{0,0},x,{0,0}}}
Shell got {ok,{{1,0},x,{0,0}}}
Shell got {ok,{{0,2},x,{0,0}}}
Shell got {ok,{{1,2},x,{0,0}}}
Shell got {ok,{{1,1},x,{0,0}}}
Shell got {ok,{{2,0},x,{0,0}}}

L'on constate bien que le serveur repond toujours au bon Pid qui a envoyé la requête.

### Test de sécurité sur la propriété du score `score`

1. Créons le Bug
            Symb==o ->
                NewO=O-1, 
                NewX=X,
                io:fwrite("Win!! :) ~n"),
                io:fwrite("YourScore:~w ~n",[NewO]),
                io:fwrite("ServerScore:~w ~n",[NewX]);
                
             Symb==x ->
                NewO=O,
                NewX=X-1,
                io:fwrite("Win!! :) ~n"),
                io:fwrite("YourScore:~w ~n",[NewX]),
                io:fwrite("ServerScore:~w ~n",[NewO])
2. Testons
9>  Pid!{self(),{move,{p6,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p6,x}}}}.
{<0.78.0>,{move,{p6,x}}}
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{2,1},x,{0,0}}},
                                      <0.78.0>}.
*** [<0.145.0>] Unfolding rec. var. 'Y'.
X: [{0,0},{0,1},{1,1},{2,1}]
B:false
O: [{2,0},{0,2},{2,2},{1,2}]
B:true
Win!! :)
YourScore:-1
ServerScore:0
10>  Pid!{self(),{move,{p5,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p5,x}}}}.
{<0.78.0>,{move,{p5,x}}}
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{1,1},x,{0,-1}}},
                                      <0.78.0>}.
*** [<0.145.0>] Reached verdict 'no'.
11> [INFO - <0.145.0> - analyzer:174] - Reached verdict 'no' after {send,<0.145.0>,<0.78.0>,{ok,{{1,1},x,{0,-1}}}}.
X: [{1,1}]
B:false
O: [{1,2}]
B:true

L'on constate que dès que le score devient négatif ligne 9 alors les requêtes suivantes conduiront à un verdict `#!erlang no` de violation de sécurité.

3. Testons le serveur sans bug

4>  Pid!{self(),{move,{p1,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p1,x}}}}.
{<0.78.0>,{move,{p1,x}}}
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{0,0},x,{0,0}}},
                                      <0.78.0>}.
*** [<0.145.0>] Unfolding rec. var. 'Y'.
X: [{0,0}]
B:false
O: [{1,0}]
B:true
5>  Pid!{self(),{move,{p2,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p2,x}}}}.
{<0.78.0>,{move,{p2,x}}}
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{1,0},x,{0,0}}},
                                      <0.78.0>}.
*** [<0.145.0>] Unfolding rec. var. 'Y'.
X: [{0,0}]
B:false
O: [{1,0}]
B:false
6>  Pid!{self(),{move,{p4,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p4,x}}}}.
{<0.78.0>,{move,{p4,x}}}
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{0,1},x,{0,0}}},
                                      <0.78.0>}.
*** [<0.145.0>] Unfolding rec. var. 'Y'.
X: [{0,0},{0,1}]
B:false
O: [{1,0},{2,2}]
B:true
7>  Pid!{self(),{move,{p7,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p7,x}}}}.
{<0.78.0>,{move,{p7,x}}}
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{0,2},x,{0,0}}},
                                      <0.78.0>}.
*** [<0.145.0>] Unfolding rec. var. 'Y'.
X: [{0,0},{0,1},{0,2}]
B:false
O: [{1,0},{2,2},{1,1}]
B:true
Win!! :)
YourScore:1
ServerScore:0
8>  Pid!{self(),{move,{p1,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p1,x}}}}.
{<0.78.0>,{move,{p1,x}}}
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{0,0},x,{0,1}}},
                                      <0.78.0>}.
*** [<0.145.0>] Unfolding rec. var. 'Y'.
X: [{0,0}]
B:false
O: [{1,0}]
B:true

L'on constate que lorsque le score passe s'incrémente j'ai pas de violation de sécurité.
Mais plutôt une récursivité `Unfolding rec. var. 'Y'.`

### Test de sécurité sur la propriété du symbole `symb`

4>  Pid!{self(),{move,{p1,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p1,x}}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{0,0},x,{0,0}}},
                                      <0.78.0>}.
{<0.78.0>,{move,{p1,x}}}
X: [{0,0}]
B:false
O: [{0,1}]
B:true
5>  Pid!{self(),{move,{p2,o}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p2,o}}}}.
{<0.78.0>,{move,{p2,o}}}
*** [<0.145.0>] Reached verdict 'no'.
[INFO - <0.145.0> - analyzer:179] - Reached verdict 'no' after {recv,<0.145.0>,{<0.78.0>,{move,{p2,o}}}}.
6> [INFO - <0.145.0> - analyzer:174] - Reached verdict 'no' after {send,<0.145.0>,<0.78.0>,{ok,{{1,0},o,{0,0}}}}.
O: [{0,0},{1,0}]
B:false
X: [{0,1},{1,1}]
B:true

L'on constate qe lorsque le joueur place un pion de symbole `o` juste après un pion de symbole différent `x` alors il ya une violation de sécurité.

Mais dans le cas contraire il n'ya aucune violation de sécurité.
4> Pid!{self(),{move,{p4,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p4,x}}}}.
{<0.78.0>,{move,{p4,x}}}
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{0,1},x,{0,0}}},
                                      <0.78.0>}.
X: [{0,1}]
B:false
O: [{1,2}]
B:true
5> Pid!{self(),{move,{p5,x}}}.
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,'receive',
                                      {<0.78.0>,{move,{p5,x}}}}.
{<0.78.0>,{move,{p5,x}}}
*** [<0.145.0>] Analyzing event {trace,<0.145.0>,send,
                                      {ok,{{1,1},x,{0,0}}},
                                      <0.78.0>}.
*** [<0.145.0>] Unfolding rec. var. 'X'.
X: [{0,1},{1,1}]
B:false
O: [{1,2},{2,2}]
B:true

###### Ces test constituent les fruits de l'utilisation de l'outil detectEr.
   



