% Input parameters
%%%%%%%%%%%%%%%%

% maximal number of virtual machines needed to be deployed 
int: M;
% number of components of wordpress application
int: N;
% number of hardware requirements for a component
int: HR;
% number of virtual machines offers
int: VMNR;
% the minimum number of Wordpress component instances to be deployed
int : WP;

% minimum requirements for each component
array[1..N,1..HR] of int: compReq;
% virtual machines offers
array[1..VMNR, 1..HR] of int: vmOffers; 
% the cost of virtual machines
array[1..VMNR] of int: prices;
% to be used when dealing with conflicts later on 
set of int : S = { i | i in 1..N};

%%%%%%%%%%%%%%%%
% variables
%%%%%%%%%%%%%%%%
% components number

% assignment matrix a 
array[1..N,1..M] of var 0..1: a; 
% type of vms
array[1..M] of var int: t; 
% occupancy vector
array[1..M] of var 0..1: v; 
% the following arrays will contain the data of the virtual machine where the i-th component has been deployed on ( i in 1..M )
array[1..M] of var int: cpu; 
array[1..M] of var int: mem; 
array[1..M] of var int: storage; 
array[1..M] of var int: price;


%%%%%%%%%%%%%%%%
% functions and predicates
%%%%%%%%%%%%%%%%

% checks if the component with id "compId" is deployed at least once and returns 1 if so or 0 otherwise
function var int: H(int: compId) 
            = if ( sum ( k in 1..M)(a[compId,k]) > 0 ) then 1  else 0 endif;
                
% a machine which has at least 1 deployed component has type different than 0 
predicate setType ( )
            = forall( i in 1..N, k in 1..M )
              (a[i, k] == 1 -> t[k] > 0);
                
% every component is deployed at least once               
predicate basicAllocation (var set of int:exclusive)
            = forall( i in S diff exclusive) 
              (sum ( k in 1..M) (a[i, k]) >=1);

% an occupied machine has its corresponding occupancy assigned to it
predicate occupancy ( )
            = forall ( k in 1..M )
              (sum ( i in 1..N) (a[i,k]) >= 1 -> v[k] = 1);

% an unocuppied machine has no type assigned to it              
predicate link2 ( )
            = forall ( k in 1..M) 
              (sum ( i in 1..N) (a[i,k]) == 0 -> t[k] = 0);

% no other balancer or mysql instance is deployed on the same machine as varnish 
predicate conflict (int: compId, var set of int: conflicts ) 
            = forall ( k in 1..M, i in conflicts )
              ( a[compId, k] + a[i, k] <= 1 );

% sets a lower bound for the number of instances of component with id "compID"
predicate lowerBound (int: compId, int: bound)
            = sum ( k in 1..M) ( a[compId,k] ) >= bound ;
            
% sets a upper bound for the number of instances of component with id "compID"
predicate upperBound (int: compId, int: bound)
            = sum ( k in 1..M) ( a[compId,k] ) <= bound ;

% creates a require provide relation between components with id alpha and beta
predicate requireProvide(int: alphaCompId,int: betaCompId, int: alphaCompIdInstances,int: betaCompIdInstances ) 
            = betaCompIdInstances * sum (k in 1..M) (a[alphaCompId,k]) <=
              alphaCompIdInstances * sum (k in 1..M)(a[betaCompId,k]);

% creates an exclusive deployment relation between components with id alpha and beta            
predicate exclusiveDeployment(int: alphaCompId,int: betaCompId)
            = sum(k in 1..M) (a[alphaCompId,k]) > 0 \/ sum(k in 1..M) (a[betaCompId,k]) > 0; 
                  
% a component should be deployed on a machine that meets its hardware requirements
predicate capacity ()
            = forall( k in 1..M, h in 1..HR )( sum (i in 1..N) ( a[i,k] * compReq[i,h]) <= vmOffers[t[k],h] ); 
            
% if a machine "k" is deployed and has type "o" then the k-th cpu,storage, memory and price values should correspond to it
predicate link ()
            =  forall(k in 1..M, o in 1..VMNR) ( (v[k] == 1 /\ t[k] == o) -> (cpu[k] = vmOffers[o,1] /\ mem[k] = vmOffers[o,2] /\                                                                 
               storage[k] = vmOffers[o,3] /\ price[k] = prices[o] ) );
               
 
%%%%%%%%%%%%%%%%
% constraints
%%%%%%%%%%%%%%%%
                      
                                                                 
% if a machine has at least 1 deployed component on it then its type cannot be 0
constraint setType();

% every component should be deployed at least once
constraint basicAllocation({3,4,5});

% marks a machine as occupied in the occupancy array v
constraint occupancy ();

% a component should be deployed on a machine that meets its hardware requirements
constraint capacity();

% makes sure that a deployed machine has its corresponding cpu, memory, storage and price assgined to it
constraint link ();

% an unocuppied machine has no type assigned to it 
constraint link2();

% dns balancer requires at least one instance of wordpress and dns balancer can serve at most 7 wordpress instances
constraint requireProvide(3, 1, 7, 1);

% http balancer requires at least one wordpress instance and http balancer can serve at most 3 wordpress instances.
constraint requireProvide(4, 1, 3, 1);

% wordpress requires at least three instances of mysql and mysql can serve at most 2 Wordpress
constraint requireProvide(1, 2, 2, 3);

% only one type of balancer must be deployed
constraint exclusiveDeployment(3, 4);

% only one type of balancer must be deployed
constraint exclusiveDeployment(3, 5);

% varnish should not be deployed on the same machine with mysql, http or dns
constraint conflict(5, {2,3,4});

% set the minimum number of Wordpress component instances to be deployed as a lower bound
constraint lowerBound(1, WP);

% if http balancer is deployed then at least 2 instances of varnish must be deployed too
constraint if H(4) == 1 then lowerBound(5, 2) endif;

% at least 2 different entry points to the mysql cluster
constraint lowerBound(2, 2); 

% no more than 1 dns server deployed in the administrative domain.
constraint upperBound (3, 1);

% balancer components must be placed on a single VM, so they are considered to be in conflict with all the other components
constraint conflict(3, {1,2,5});

% balancer components must be placed on a single VM, so they are considered to be in conflict with all the other components
constraint conflict(4, {1,2,5});

% solve the problem such that the cost of virtual machines is the minimal one
solve minimize sum(p in price) (p);

% output in a csv like style
output[show_int(5,a[i,k]) | i in 1..N, k in 1..M ]++[","]++
        [show_int(5,t[k])|k in 1..M] ++ [","]++
        [show_int(5,cpu[k]) | k in 1..M] ++ [","]++
        [show_int(10,mem[k]) | k in 1..M] ++ [","]++
        [show_int(10,storage[k]) | k in 1..M] ++[","]++
        [show_int(10,price[k]) | k in 1..M];
        
