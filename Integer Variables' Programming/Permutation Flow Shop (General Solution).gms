$Title Permutation Flow Shop Problem (General Solution)

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

Variables
Z
Positive Variable X
Positive Variable Y
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

Model PermutationFlowShop /all/;
Option optca = 0, optcr = 0;
Option limrow = 30;
Option MIP = BARON;
Solve PermutationFlowShop using MIP minimizing Z;
Display Z.l, C.l;
