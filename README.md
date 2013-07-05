[UPDATE] Better migrate to Robotlegs 2
----
https://github.com/katopz/robotlegs2-SignalCommandMap-example

Or keep mess with old version compiled swc here...
----
https://github.com/katopz/robotlegs-modular-signals/tree/master/bin

Which is merging optimized version from...
----
1. Robotlegs : https://github.com/katopz/robotlegs-framework
2. Modular : https://github.com/katopz/robotlegs-utilities-Modular
3. CommandSignal with agruments : https://github.com/katopz/signals-extensions-CommandSignal

You will also need as3-signals
----
https://github.com/robertpenner/as3-signals

Don't forget to add this to compiler option
----

    -keep-as3-metadata+=Inject -keep-as3-metadata+=PostConstruct
