*** TLA+/ TLC setup guide ***

TLA+ (Temporal Logic of Actions) is a formal specification language developed by Leslie Lamport. It is used for designing, modeling, documentation, and verification of programs, especially concurrent systems and distributed systems.

Alongside TLA+, TLC (Temporal Logic of Actions Model Checker) is a model checker for verifying the properties of systems specified using TLA+. TLC allows one to check whether a TLA+ specification satisfies various properties, such as safety and liveness, by exhaustively exploring all possible states and behaviors of the specified system.

In particular, TLC checks for: 
 * silliness errors: mathematical and logical errors, e.g., division by zero, dividing an integer by a string...
 * deadlocks: when the state can not enter the following state, referred to as Next in TLA+;
 * user-specified properties: validation of safety and liveness properties.


*** Downloading TLC ***

The classic way to run TLC is to install the [TLA+ toolbox](https://lamport.azurewebsites.net/tla/toolbox.html). TLA+ toolbox is an IDE for all TLA+ tools, including TLC, but also the PlusCal translator and the TLA+ proof system.

Alternatively, for Visual Code studio users, you can install the [TLA+ extension](https://marketplace.visualstudio.com/items?itemName=alygin.vscode-tlaplus), which is enough to run the TLC model checker and has the benefits of being lightweight and easy to handle.

*** Running TLC ***

If you run TLC on the provided code (right-click on the .tla file, then go down to "Check Model with TLC provided you have the TLA+ extension on VS Code), you will immediately detect any "silliness errors" as specified above. It should return Success. If there are any mistakes in the code, TLA+ notifies the user and highlights the troublesome line.

*** Different TLC modes ***

TLC has two different modes to detect errors. First, the "model check" mode explores all possible states. This mode can be used when the number of states is finite, which is not true for all specifications. Second, the "simulate" mode explores randomly generated behaviors. In our case, it is rather the interactions between functions that were troublesome, e.g., using the function knowD to detect which containers hold D, but on a disconnected container. Therefore, those two modes are not useful for us, as issues can be detected using only type 1 errors ("Silliness errors")

Yet, this mode is useful when the implementation becomes more detailed, e.g., considering the number of cars, the number of containers... Please, note that the simulation mode does not check liveness property and never stops. 

Running the "model check" mode when possible returns all possible issues, but, depending on the use case, the number of possible states may be infinite.