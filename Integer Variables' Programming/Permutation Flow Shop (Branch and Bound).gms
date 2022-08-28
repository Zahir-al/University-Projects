$Title Permutation Flow Shop Problem (B&B)

$ontext
Branch-and-bound algorithms for minimizing total earliness and tardiness
in a two-machine permutation flow shop with unforced idle allowed
$offtext

Sets
m index for machines /1,2/
j index for jobs /1*10/
Alias (k,j);

Parameters
d(j) Job due dates /1 39,2 37,3 38,4 36,5 39,6 41,7 44,8 45,9 51,10 53/;

Table p(j,m) Processing time of job j on machine m
         1       2
1        2       2
2        8       4.1
3        5       6
4        5       7.2
5        2       8
6        1       4.6
7        2       3
8        5       1.3
9        4       3
10       6       2.4;

Table UI(j,m) Unforced idle time of job j on machine m
         1       2
1        0       6
2        0       0
3        0       3
4        0       4
5        0       0
6        0       1
7        0       0
8        0       5
9        0       0
10       0       2;

scalar
maxC / 100 /
minC / 0 /
;

Variables
Z
Positive variable X
Positive variable Y
Integer Variable C(j,m);

Equations
ObjectiveFunction  For minimizing total earliness & tardiness
ConstraintL1(j)    Linearization constraint for 1st maximum part of objective function
ConstraintL2(j)    Linearization constraint for 2nd maximum part of objective function
Constraint1(j)     Completion time of job in position j on machine 1
Constraint2(j)     Completion time of job in position j on machine 2 (1st approach)
Constraint3(j)     Completion time of job in position j on machine 2 (2nd approach);

ObjectiveFunction .. Z =e= sum(j,X(j)+Y(j));
ConstraintL1(j)   .. X(j) =g= C(j,"2")-d(j);
ConstraintL2(j)   .. Y(j) =g= d(j)-C(j,"2");
Constraint1(j)    .. C(j,"1") =e= sum(k$(ord(k)<=ord(j)),p(k,"1"));
Constraint2(j)    .. C(j,"2") =g= C(j-1,"2")+UI(j,"2")+p(j,"2");
Constraint3(j)    .. C(j,"2") =g= C(j,"1")+UI(j,"2")+p(j,"2");

model PermutationFlowShop /all/
set node 'maximum size of the node pool' /node1*node1000/;
parameter bound(node) 'node n will have an obj <= bound(n)';
set fixed(node,j) 'variables C(j,m) are fixed to zero in this node';
set lowerbound(node,j) 'variables C(j,m)>=minC in this node';
scalar bestfound 'lowerbound in B&B tree' /-INF/;
scalar bestpossible 'upperbound in B&B tree' /+INF/;
set newnode(node) 'new node (singleton)';
set waiting(node) 'waiting node list';
set current(node) 'current node (singleton except exceptions)';
parameter log(node,*) 'logging information';
scalar done 'terminate' /0/;
scalar first 'controller for loop';
scalar first2 'controller for loop';
scalar obj 'objective of subproblem';
scalar maxC;
set w(node);
parameter nodenumber(node);
nodenumber(node) = ord(node);
fixed(node,j) = no;
lowerbound(node,j) = no;
set h(j,m);
alias (n,node);
waiting('node1') = yes;
current('node1') = yes;
newnode('node1') = yes;
bound('node1') =INF;
loop(node$(not done),
bestpossible = smax(waiting(n), bound(n));
current(n) = no;
current(waiting(n))$(bound(n) = bestpossible) = yes;
first = 1;
loop(current$first,
first = 0;
log(node,'node') = nodenumber(current);
log(node,'ub') = bestpossible;
waiting(current) = no;
C.lo(j,m) = 0;
C.up(j,m) = maxC;
h(j,m) = lowerbound(current,j);
C.lo(h) = minC;
h(j,m) = fixed(current,j);
C.up(h) = 0;
Option optca = 0, optcr = 0;
Option MIP = BARON;
solve PermutationFlowShop minimizing z using MIP;
log(node,'solvestat') = PermutationFlowShop.solvestat;
log(node,'modelstat') = PermutationFlowShop.modelstat;
abort$(PermutationFlowShop.solvestat <> 1) "Solver did not return ok";
if (PermutationFlowShop.modelstat = 1 or PermutationFlowShop.modelstat = 2,
obj = z.l;
log(node,'obj') = obj;
maxC = smax((j,m), min(C.l(j,m), max(minC-C.l(j,m),0)));
if (maxC = 0,
log(node,'integer') = 1;
if (obj > bestfound,
log(node,'best') = 1;
bestfound = obj;
w(n) = no; w(waiting) = yes;
waiting(w)$(bound(w) < bestfound) = no;
);
else
h(j,m) = no;
h(j,m)$(min(C.l(j,m), max(minC-C.l(j,m),0))=maxC) = yes;
first2 = 1;
loop(j$first2,
first2 = 0;
newnode(n) = newnode(n-1);
fixed(newnode,j) = fixed(current,j);
lowerbound(newnode,j) = lowerbound(newnode,j);
bound(newnode) = obj;
waiting(newnode) = yes;
fixed(newnode,j) = yes;
newnode(n) = newnode(n-1);
fixed(newnode,j) = fixed(current,j);
lowerbound(newnode,j) = lowerbound(newnode,j);
bound(newnode) = obj;
waiting(newnode) = yes;
lowerbound(newnode,j) = yes;
);
);
else
abort$(PermutationFlowShop.modelstat <> 4 and PermutationFlowShop.modelstat <> 5) "Solver did not solve subproblem";
);
log(node,'waiting') = card(waiting);
);
done$(card(waiting) = 0) = 1;
display log,C.l,Z.l;
);
