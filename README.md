TM_SIMULATOR
====

tm_simulator is the turing machine simulator written by chezscheme, and that just for fun www.

1. op.ss is stored the basic operations.
2. simu.ss is the main program, you can just execute ```scheme simu.ss ``` or ```make```
3. tm.ss is the core of this program, that provide the function that you can create a machine.

However i'm not sure all machine in op.ss is run correctly, maybe some bug tho.

Syntax
=====

create-machine, take a simple as shown below, that mult two number in tape,
and i'm not written the parser for this, so make sure the syntax is correctly when you enter these.

```scheme
(define MULT
  (create-machine 'q0
    '((q0
        (: q1 B B R))
      (q1
        (: q2 1 1 R))
      (q2
        (: e1 B B R)
        (: q3 1 X R))
      (e1
        (* E1 ML1))
      (q3
        (: q3 1 1 R)
        (-> qt CPY1))
      (qt
        (: q5 B B L))
      (q5
        (: q4 X B L)
        (: q6 1 1 L))
      (q6
        (: q6 1 1 L)
        (: q7 X X R))
      (q7
        (: q8 1 X R))
      (q8
        (: q8 1 1 R)
        (-> qt (CPY1_ 1) MR1 A ML1))
      (q4
        (: q4 1 B L)
        (: q4 X B L)
        (* T E1 T)))))
```

the detail of this syntax:

```scheme
(define machine-name
  (create-machine 'start-state
    '((start-state
        (: state1 B 1 R)
        ;; change to the state1 if found B on tape and replace with 1, move right
        (-> state2 MR1 T ..etc )
        ;; chnage to the state2 by execute MR1 machine , T machine(translate) .... etc
        ;; that -> is always true , so be careful using always at end
        )
      (state1
        (>> state-0 state-else)
        ;; if the current tape is 0 : B1B , then goto state-0 else state-else
        )
      (state-0
        (* ML1 INT ... etc)
        ;; just exectue ML1 INT .... etc , without goto any state and machine end here
        )
      ...)))

```

USAGE
====

you can try the machine in op.ss
just enter something like these:

```scheme
(print-tape)  ;; print the tape
(tape-size 100) ;; change tape size to 100
(assign-tape "B1111B111B") ;; assign the tape B1111B111B to current tape

(debug #t) ;; show the details of tape when execute the machine

(MR1) ;; execute the machine: MR1
;; [B]111B111B -> B111[B]111B

;; or create machine for yourself

```

run an example, you can see the test.ss for more details, that is a simple machine of M*N+1.
```
make test
```
