Before running the actual Wordpress.mzn Minizinc model, we ran the Surrogate.mzn model in order to determine the maximum number of VMs needed for deployment. This number is then used in the corresponding dzn file for each Wordpress application.

We **run** the Wordpress.mzn model as follows:

minizinc  --time-limit 2400000 --search-complete-msg ""  --soln-sep "" --output-time --solver Chuffed Wordpress.mzn Wordpress12_Offers500.dzn -o Wordpress12_Offers500_Chuffed.csv 

where:
* --time-limit is the maximum time, in seconds, allowed for obtaining a model; we set it to 40 minutes;
* --search-complete-msg "" sets the status message when search exhausted the entire search space to empty needed for formatting the csv file (the default is "==========");
* --soln-sep "" specifies the string printed after each solution (as a separate line) to empty needed for formatting the csv file (the default is “———-“);
* --solver Chuffed sets the solver used for obtaining the solution to Chuffed;
* Wordpress.mzn is the input MiniZinc model; 
* Wordpress12_Offers500.dzn is the data file for storing the input data to the MiniZinc model;
* -o Wordpress12_Offers500_Chuffed.csv specifies the name of the output file.

The **output** file is a csv file having the following structure:

* an array with the type of the VMs needed for deployment;
* an array with the CPUs number of the VM offers needed in deployment
* an array with the memory of the VM offers needed in deployment
* an array with the storage of the VM offers needed in deployment
* an array with the price of the VM offers needed in deployment
* the association matrix (rows represent components, columns represent VMs)
* time is the instance-time i.e. static checking of the model instance
* time is the run-time i.e. evaluation of the instance (i.e., constraint solving).

The tests are for Wordpress with at least *3*, *4*, ..., *12*. The number of offers are *20*, *40*, *250*, *500*.

As solvers, we have tried:
* Chuffed
* Gecode - did not scale even for small instances of the problem
* CPLEX - @Andrei
* Gurobi - @Andrei