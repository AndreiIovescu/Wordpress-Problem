The format of the data files is as follows:

* *M*: 		maximal number of virtual machines needed to be deployed
* *N*: 		the number of components of Wordpress Application
* *HR*: 		the number of hardware requirements for a component
* *VMNR*: 	the number of virtual machine offers
* *WP*: 		the minimum number of Wordpress component instances to be deployed
* *vmOffers*: 	array with HR columns and VMNR lines containing the offered virtual machines with their specifications
* *compReq*: 	array with HR columns and N lines containing the minimum hardware requirements for each component of the application where line *i* represents the requirements of the i-th component and so on for every line while column *1* represents cpu, column *2* memory and column *3* storage in our case
* *prices*:   	array with VMNR elements where position *i* means the price to rent the i-th machine from vmOffers


The naming convention for the data files is WordpressWP_OffersVMNR, where WP and VMNR correspond to the above explanation