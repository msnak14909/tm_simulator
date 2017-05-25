#! /usr/bin/scheme --script
(load "tm.ss")
(load "op.ss")
(tape-size 100)
(define (M*N+1 m n)
  ;; initial the tape
  ;; BmBnB
  (define var-size 2)
  (INIT 1)
  ;; init v1 with m
  (let init-input-m ([k m])
    (unless (eq? k 0)
      (and (S) (init-input-m (sub1 k)))))
  ;; init v2 with n
  (MR 1)
  (INIT 2)
  (let init-input-n ([k n])
    (unless (eq? k 0)
      (and (S) (init-input-n (sub1 k)))))
  (ML 1)

  ;; start the machine : BmBnB -> BoB, where o is equal to m*n+1
  (let ([M (create-machine 'L1
            `((L1
                (*
                  (HOME ,var-size)
                  (LOAD 1 1 ,var-size)
                  (LOAD 2 2 ,var-size)
                  (MULT)
                  (S)
                  (STORE1 1 ,var-size)
                  (RETURN 1 ,var-size)))))])
    (M)))

(debug #t)
(M*N+1 4 5)
(print-tape)
