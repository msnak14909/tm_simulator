(load "tm.ss")

;;; basic operation
;;; erase a number
(define E1
  (create-machine 'start
    '((start
        (: q0 B B R))
      (q0
        (: q0 1 1 R)
        (: qf B B L))
      (qf
        (: qf 1 B L)))))
;;; move right to next number
(define MR1
  (create-machine 'start
    '((start
        (: qf B B R))
      (qf
        (: qf 1 1 R)))))
;;; move left to next number
(define ML1
  (create-machine 'start
    '((start
        (: qf B B L))
      (qf
        (: qf 1 1 L)))))

;;; successor , add1 ([B]111BB-> [B]1111B, be careful: [B]111B11B -> [B]111111B (that not correctly), if you run this, make sure there have enough blank.
(define S
  (create-machine 'start
    '((start
        (: q1 B B R))
      (q1
        (: q1 1 1 R)
        (: qf B 1 L))
      (qf
        (: qf 1 1 L)))))

;;; add two number: [B]1111B111B -> [B]111111BB (3 + 2 = 5) B1B is zero, B11B is 1 ... etc
(define A
  (create-machine 'start
    '((start
        (: q1 B B R))
      (q1
        (: q1 1 1 R)
        (: q2 B 1 R))
      (q2
        (: q2 1 1 R)
        (: q3 B B L))
      (q3
        (: q4 1 B L))
      (q4
        (: qf 1 B L))
      (qf
        (: qf 1 1 L)))))


;;; decrement 1 [B]111B -> [B]11BB
(define D
  (create-machine 'start
    '((start
        (: q1 B B R))
      (q1
        (: q2 1 1 R))
      (q2
        (: q3 1 1 R)
        (: qf B B L))
      (q3
        (: q3 1 1 R)
        (: q4 B B L))
      (q4
        (: qf 1 B L))
      (qf
        (: qf 1 1 L)))))

;;; zero the number : [B]111B -> [B]1BBB
(define Z
  (create-machine 'start
    '((start
        (: q1 B B R))
      (q1
        (: q1 1 1 R)
        (: q2 B B L))
      (q2
        (: q2 1 B L)
        (: q3 B B R))
      (q3
        (: #f B 1 L)))))
;;; find left : B1111BBB[B] -> [B]1111BBBB
(define FL
  (create-machine 'start
    '((start
        (: q1 B B L))
      (q1
        (: q1 B B L)
        (: qf 1 1 L))
      (qf
        (: qf 1 1 L)))))
;;; find right : [B]BBB1111B -> BBB[B]1111B
(define FR
  (create-machine 'start
    '((start
        (: q1 B B R))
      (q1
        (: q1 B B R)
        (: #f 1 1 L)))))

;;; copy a number: [B]111BBBBBBB -> [B]111B111BBB
(define CPY1
  (create-machine 'start
    '((start
        (: q1 B B R))
      (q1
        (: q2 1 X R)
        (: qf B B L))
      (q2
        (: q2 1 1 R)
        (: q3 B B R))
      (q3
        (: q3 1 1 R)
        (: q4 B 1 L))
      (q4
        (: q4 1 1 L)
        (: q4 B B L)
        (: q1 X 1 R))
      (qf
        (: qf 1 1 L)))))

;;; move right k number
(define (MR k)
  (let move ([k k])
    (unless (eq? k 0)
      (and (MR1) (move (sub1 k))))))

;;; move left k number
(define (ML k)
  (let move ([k k])
    (unless (eq? k 0)
      (and (ML1) (move (sub1 k))))))

;;; erase k number
(define (E k)
  (begin
    (MR k)
    (let erase ([k k])
      (unless (eq? k 0)
        (and (ML1) (E1) (erase (sub1 k)))))))

;;; copy 1 and ignored k number
(define (CPY1_ k)
  (define M
    (create-machine 'start
      `((start
          (-> q0 (MR ,(+ k 1)) (E1) (ML ,(+ k 1))))
        (q0
          (: q1 B B R))
        (q1
          (: q2 1 X R)
          (: qf B B L))
        (q2
          (: q2 1 1 R)
          (-> q3 (MR ,k)))
        (q3
          (: q4 B B R))
        (q4
          (: q4 1 1 R)
          (: q5 B 1 L))
        (q5
          (: q5 B B L)
          (: q5 1 1 L)
          (: q1 X 1 R))
        (qf
          (: qf 1 1 L)))))
  (M))

;;; copy k number
(define (CPY k)
  (begin
    (let copy ([t k])
      (unless (eq? t 0)
        (and (CPY1_ (sub1 k))
             (MR1)
             (copy (sub1 t)))))
    (ML k)))

;;; copy i number and ignored k number
(define (CPY_ i k)
  (begin
    (let copy ([t i])
      (unless (eq? t 0)
        (and (CPY1_ (+ i (sub1 k)))
             (MR1)
             (copy (sub1 t)))))
    (ML i)))

;;; translate: [B]BBBBB111 -> [B]111BBBBB
(define T
  (create-machine 'start
    '((start
        (: q0 B X R))
      (q0
        (: clean2 1 1 L)
        (: q1 B B R))
      (q1
        (: q1 B B R)
        (: qk 1 1 R))
      (qk
        (: qk 1 1 R)
        (: q2 B X L))

      ;; process
      (q2
        (: q3 1 B L))
      (q3
        (: q3 1 1 L)
        (: q4 B B L))
      (q4
        (: q4 B B L)
        (: replace X X R)
        (: replace 1 1 R))
      ;; replace 1
      (replace
        (: n0 B 1 R)
        (: clean 1 1 R))

      (n0
        (: clean 1 1 R)
        (: n1 B B R))
      (n1
        (: n1 B B R)
        (: clean2 X B L)
        (: n2 1 1 R))
      (n2
        (: n2 1 1 R)
        (: q2 B B L))

      ;; clean
      (clean
        (: clean 1 1 R)
        (: clean B B R)
        (: clean2 X B L))

      (clean2
        (: clean2 1 1 L)
        (: clean2 B B L)
        (: qf X B R))

      (qf
        (: #f 1 1 L)))))

;;; intercharge : [B]11B11111B -> [B]11111B11B
(define INT
  (create-machine 'start
    '((start
        (: q1 B B R))
      ;; left side
      (q1
        (: right-most B B R)
        (: q2 1 X R))
      (q2
        (: q2 1 1 R)
        (: q3 B B R))
      ;; left > right
      (q3
        (: q3 1 1 R)
        (: change B B L)
        (: change X X L))
      (change
        (: check 1 X L))
      (check
        (: back    1 1 L)
        (: left-most B B L))
      (back
        (: back B B L)
        (: back 1 1 L)
        (: q1 X X R))
      (left-most
        (: left-most 1 1 L)
        (: left-most X X L)
        (: clean-to-right B B R))
      (clean-to-right
        (: clean-to-right X 1 R)
        (: mid B B R)
        (: mid 1 B R))
      (mid
        (: mid 1 1 R)
        (: mid B 1 R)
        (: proc-x X 1 R))
      (proc-x
        (: proc-x X 1 R)
        (* ML1 ML1))
      ;; right > left
      (right-most
        (: right-most 1 1 R)
        (: right-most X X R)
        (: clean-to-left B B L))
      (clean-to-left
        (: clean-to-left X 1 L)
        (: proc-y 1 B L))
      (proc-y
        (: proc-y 1 1 L)
        (: proc-y B 1 L)
        (: deleteX X 1 L))
      (deleteX
        (: deleteX X 1 L))
      )))

;;; not support yet
;; (define (INSERT k)
;;   (define L
;;     (create-machine 'start
;;       `((start
;;           (: q1 B B R))
;;         (q1
;;           (: q2 1 X R))
;;         (q2
;;           (: q2 1 1 R)
;;           (: q3 B 1 L))
;;         (q3
;;           (: q3 1 1 L)
;;           (: #f X ,k R)))))
;;   (L))


;;; if branch is 0 run M else run N
;; (define (BRN0 M N)
;;   (if (or (procedure? M) (procedure? N))
;;       (errorf 'BRN "branch must use symbol as name, should not using procedure"))
;;   (let ([L (create-machine 'start
;;              `((start
;;                  (: q0 B B R))
;;                (q0
;;                  (: q1 1 1 R)
;;                  (: m B B L))
;;                (q1
;;                  (: q2 1 1 L)
;;                  (: q3 B B L))
;;                (q2
;;                  (: n 1 1 L))
;;                (q3
;;                  (: m 1 1 L))
;;                (n (* ,N))
;;                (m (* ,M))
;;                ))])
;;     (L)))


;;; pick i number ignored k
(define (PICK i k)
  (define L
    (create-machine 'start
      `((start
          (* (E ,(sub1 i)) T MR1 FR (E ,(- k i)) FL)))))
  (L))

;;; mult two number: [B]111B111B -> [B]11111BBB (2 * 2 = 4)
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

;;; simple assembly
;;; Bv1Bv2Bv3B...Bvn[B]r1Br2Br3B...
;;; \variable space/

;;; initial Vx variable
(define (INIT x)
  (define L
    (create-machine 'start
      `((start
          (* (MR ,(sub1 x)) Z (ML ,(sub1 x)))))))
  (L))

;;; MR t
(define (HOME t)
  (MR t))

;;; store reg 1 to variable i in n variable<-depend on the variable size you define
(define (STORE1 i n)
  (begin
    (let store1 ([k (add1 (- n i))])
      (unless (eq? k 0)
        (and (ML1) (INT) (store1 (sub1 k)))))
    (let store2 ([k (- n i)])
      (unless (eq? k 0)
        (and (MR1) (INT) (store2 (sub1 k)))))
    (MR1)
    (E1)))

;;; bug!!!
(define (STORE i t n)
  (begin
    (MR (- t 1))
    (INT)
    (let store1 ([k (sub1 (t + (- n i)))])
      (unless (eq? k 0)
        (and (ML1) (INT) (store1 (sub1 k)))))
    (let store2 ([k (sub1 (t + (- n i)))])
      (unless (eq? k 0)
        (and (MR1) (INT) (store2 (sub1 k)))))
    (MR t)
    (E1)
    (ML (sub1 t))))

;;; load variabe vi to reg t in n variabes
(define (LOAD i t n)
  (begin
    (ML (add1 (- n i)))
    (CPY1_ (sub1 (+ (- n i) t)))
    (MR (add1 (- n i)))))

;;; return variable vi in n variabes
(define (RETURN i n)
  (begin
    (ML n)
    (T)
    (MR 1)
    (FR)
    (E n)
    (FL)))


;;; the example in book
(define (2N+1 k)
  (define var-size 5)
  ;; init
  (INIT 1)
  (let init-input ([k k])
    (unless (eq? k 0)
      (and (S) (init-input (sub1 k)))))
  (let init-local-var ([k 1])
    (unless (eq? k var-size)
      (and (INIT (add1 k)) (init-local-var (add1 k)))))
  (HOME var-size)

  ;; run machine
  (let ([L (create-machine 'start
             `((start
                 (-> L1
                   (LOAD 1 1 ,var-size)
                   (STORE1 2 ,var-size)
                   (LOAD 2 1 ,var-size)
                   (LOAD 1 1 ,var-size)
                   ))
               (L1
                 (-> branch0 (LOAD 2 1 ,var-size)))
               (branch0 (>> L2 Continue))
               (Continue
                 (-> L1
                   (LOAD 1 1 ,var-size)
                   S
                   (STORE1 1 ,var-size)
                   (LOAD 2 1 ,var-size)
                   D
                   (STORE1 2 ,var-size)))
               (L2
                 (* (LOAD 1 1 ,var-size)
                   S
                   (STORE1 1 ,var-size)))
               ))])
    (L)
    (RETURN 1 var-size)
    ))



;; (define (PICK i k)
;;   (define C
;;     (create-machine 'start
;;       `((start
;;           (* FR (E ,(- k i)) FL)))))
;;   (define L
;;     (create-machine 'start
;;       `((start
;;           (-> check (E ,(sub1 i)) T MR1))
;;         (check
;;           (* (BRN0 'FL 'C))))))
;;   (L))
