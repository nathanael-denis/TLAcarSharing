------------------- MODULE carSystem --------------------------------

EXTENDS Naturals, FiniteSets, Integers

VARIABLES
    Y, C, D, L, \* Sets of systems, containers, data items, labels, traces, and system states
    conflict_result, \* To store the result of the conflict function
    availableD_result \* To store the result of the availableD function


(* Y is defined as a tuple (id, containers...) and C is defined as 
a tuple (id, data)* and data as a tuple (id, value) *)

(* Function Declarations *)

(* Define knowD as a function *)
knowD(d, i) ==
    LET
        (* Define a local variable to store the result *)
        result == {}
    IN
        (* Iterate over all systems y in the set Y *)
        \E y \in Y: 
            (* Iterate over all containers c in the set C for system y *)
            \E c \in Y[2]:
                (* Check if the intersection of data items D and the set of data items stored by container c is not empty *)
                IF d \cap c # {} THEN
                    (* Add system y to the result *)
                    /\ result' = result \cup {y}
                ELSE 
                    (* Do nothing *)
                    /\ result' = result    
    (* Return the result *) 

connected(y, i, t) == 
    IF \E e \in t[y] : e.name = "disconnect"
        THEN {y} \* Empty set means disconnected
        ELSE {} \* Connected

unknownSet == {-1} \* To represent unknown and keep type coherence

conflict(l1, l2, y, i, t) == 
    IF connected(y, i, t) = {}
        THEN {-1} \* Return "unknown" if the set is disconnected, to avoid loophole.
        ELSE l1 = l2

findBackup(c1, d1, y, i, t) ==
    IF conflict(c1, d1, y, i, t) = "unknown"
        THEN knowD(d1, i)
        ELSE unknownSet

\* Relabeling can only occurs on DIFC values/usage control data

relabeling(data, newlabel) == 
    newlabel[3] = data \* Corresponds to newlabel.data in the article, newlabel[2] is for containers

extract_privilege(label, user, data) == \*Takes a user, and a label, returns if the label authorizes the user to access the specified data.
        user \in label[2][2] /\ data \in label[2]

\* Sample transactions in the distributed ledger
Transaction(recordId, renterAddress, ownerAddress, transactionValue) ==
  [recordId |-> recordId,
   renterAddress |-> renterAddress,
   ownerAddress |-> ownerAddress,
   transactionValue |-> transactionValue]

\* Initialize the DistributedLedger with sample transactions
DistributedLedger ==
  {<<1, "RenterAddress1", "OwnerAddress1", 100>>,
   <<2, "RenterAddress2", "OwnerAddress2", 75>>,
   <<3, "RenterAddress3", "OwnerAddress3", 120>>}

\* Sample geolocation data for cars
GeoData(lat, long, timestamp, ownerAddress) ==
  [latitude |-> lat,
   longitude |-> long,
   timestamp |-> timestamp,
   ownerAddress |-> ownerAddress]

\* Initialize the GeolocationData with sample data for each car
GeolocationData ==
  { <<"40.7128", "-74.0060", "2023-08-31T12:00:00", "CarOwnerAddress1">>,
    <<"34.0522", "-118.2437", "2023-08-31T13:30:00", "CarOwnerAddress2">>,
    <<"51.5074", "-0.1278", "2023-08-31T14:45:00", "CarOwnerAddress3">>}

(*/---------------------- Operations ----------------------- *)

RecordTransaction(owner, renter, car, transactionValue) ==
    /\ \E recordId \in Nat:
        /\ recordId > 0  \* Ensure the recordId is a positive integer
        /\ DistributedLedger' = DistributedLedger \cup {<<recordId, renter, owner, transactionValue>>}
    
UpdateGeolocationData(car, lat, long, timestamp, ownerAddress) ==
    /\ car \in DOMAIN(GeolocationData)  \* Check if the car is in the GeolocationData domain
    /\ GeolocationData' = [GeolocationData EXCEPT ![car] = <<lat, long, timestamp, ownerAddress>>]

\* UsageControl(renter, car, location) == ...
\* Usage control mechanism to manage geolocation data access

(* ---------------------- Properties ----------------------- *)
NonNegativeTransactionValues == 
    \A recordId, renter, owner, transactionValue \in DistributedLedger:
        transactionValue >= 0

ValidGPSCoordinates == 
    \A carData \in DOMAIN(GeolocationData):
        LET coords == GeolocationData[carData]
        IN
            /\ coords[1] <= 90  \* Check latitude is within -90 to 90 degrees
            /\ coords[1] => -90  \* Check latitude is within -90 to 90 degrees            
            /\ coords[2] <= 180  \* Check longitude is within -180 to 180 degrees        
            /\ coords[2] <= 180  \* Check longitude is within -180 to 180 degrees     


TemporalOrdering ==
    \A data, newlabel, user:
        /\ relabeling(data, newlabel)
        ~> extract_privilege(newlabel, user, data)               
(* ------------------------ Spec -------------------------- *)

Init == 
    /\ DistributedLedger = {}  \* Initially, the distributed ledger is empty 
    /\ GeolocationData = { 
            <<"40.7128", "-74.0060", "2023-08-31T12:00:00", "CarOwnerAddress1">>,
            <<"34.0522", "-118.2437", "2023-08-31T13:30:00", "CarOwnerAddress2">>,
            <<"51.5074", "-0.1278", "2023-08-31T14:45:00", "CarOwnerAddress3">>
       }    
    /\ Y = {<<"system1", {<<"c1">>}>>, <<"system2", {<<"c2">>}>>}
    /\ C = {<<"c1">>, <<"c2">>}
    /\ D = GeolocationData
    /\ L = { << "L1", { << "O1", {"R1", "R2"} >> }, {"D1", "D2"}, {"c1"} >> } \* Example label
    /\ conflict_result={TRUE}
    /\ availableD_result={TRUE}    
Next == 
    \/ \E owner, renter, car, transactionValue:
        /\ car \notin DOMAIN(GeolocationData)   \* Ensure the car is not already in the geolocation data
        /\ DistributedLedger' = DistributedLedger
        /\ GeolocationData' = GeolocationData
        /\ RecordTransaction(owner, renter, car, transactionValue)   \* Record a new transaction
    \/ \E car, lat, long, timestamp, ownerAddress:
        /\ car \in DOMAIN(GeolocationData)   \* Ensure the car exists in the geolocation data
        /\ DistributedLedger' = DistributedLedger
        /\ GeolocationData' = GeolocationData
        /\ UpdateGeolocationData(car, lat, long, timestamp, ownerAddress)

Spec == Init /\ [][Next]_DistributedLedger /\ [][Next]_GeolocationData 
        /\ NonNegativeTransactionValues
        /\ TemporalOrdering
------------------------------------------------------
=======================================================
