(module
  (create-machine action enable-tape-bracket debug
    print-tape get-tape-pos get-tape assign-tape tape-size current-tape next-tape
    change-tap-pos
    symbol->char)
  (include "match.ss")
  (define tape '#())
  (define tape-pos 0)
  (define change-tap-pos
    (lambda (x)
      (set! tape-pos x)))
  (define debug
    (make-parameter #f
      (lambda (t)
        (unless (boolean? t)
          (errorf 'debug "invalid boolean ~s" t))
        t)))
  (define enable-tape-bracket
    (make-parameter #t
      (lambda (t)
        (unless (boolean? t)
          (errorf 'enable-pos "invalid boolean ~s" t))
        t)))
  (define get-tape (lambda () tape))
  (define get-tape-pos (lambda () tape-pos))

  (define current-tape (lambda () (vector-ref tape tape-pos)))
  (define next-tape (lambda (x) (vector-ref tape (+ tape-pos x))))
  (define tape-size
    (make-parameter 1000
      (lambda (n)
        (unless (and (fixnum? n) (fx>= n 0))
          (errorf 'tape-size "invalid size ~s" n))
        (unless (fx= n (vector-length tape))
          (set! tape (make-vector n #\B)))
        n)))
  (define action
    (lambda (rep dir)
      (vector-set! tape tape-pos rep)
      (cond
        [(eq? dir 'L) (if (> tape-pos 0) (set! tape-pos (sub1 tape-pos))
                          (errorf 'action "can't move left more"))]
        [(eq? dir 'R) (if (< (add1 tape-pos) (tape-size))
                          (set! tape-pos (add1 tape-pos))
                          (errorf 'action "can't move right more"))]
        [else (errorf 'action "invalid direction ~s" dir)])
      (if (debug) (print-tape))))
  (define assign-tape
    (lambda (str)
      (let ([s 0])
        (vector-for-each
          (let ([t s])
            (lambda (x) (vector-set! tape t x) (set! t (add1 t))))
          (list->vector (string->list str))))))
  (define (print-tape)
    (define insert-bracket
      (lambda (t x)
        (if (eq? t 0)
            (cons* #\[ (car x) #\] (cdr x))
            (cons (car x) (insert-bracket (sub1 t) (cdr x))))))
    (if (enable-tape-bracket)
        (and (display (list->string (insert-bracket tape-pos (vector->list tape)))) (newline))
        (and (display (list->string (vector->list tape))) (newline))))
  (define symbol->char
    (lambda (sym)
      (cond
        [(symbol? sym) (car (string->list (symbol->string sym)))]
        [(number? sym) (car (string->list (number->string sym)))]
        [else (errorf 'symbol->char "not invalid symbol ~a" sym)])))

  (define id (lambda (x) x))
  (define create-machine
    (lambda (start langs)
      (define rewrite
        (lambda (exp C)
          (match exp
            [((>> ,if0 ,else))
             (C `([(and (eq? (next-tape 1) #\1) (eq? (next-tape 2) #\1))
                   (,else)]
                  [#t (,if0)]
                  ))]
            [((-> ,to ,fn* ...) ,a* ...)
             (let ([va* (rewrite `(,a* ...) id)]
                   [vf* (map (lambda (x) (if (list? x) x (cons x '()))) fn*)])
               (C `([#t ,@vf* (,to)] ,@va*)))]
            [((* ,fn* ...) ,a* ...)
             (let ([va* (rewrite `(,a* ...) id)]
                   [vf* (map (lambda (x) (if (list? x) x (cons x '()))) fn*)])
               (C `([#t ,@vf*] ,@va*)))]
            [((: ,to ,found ,rep ,dir) ,a* ...)
             (let ([va* (rewrite `(,a* ...) id)])
               (C `([(eq? (current-tape) (symbol->char ',found))
                     (action (symbol->char ',rep) ',dir)
                     ,@(if (not (eq? to #f)) `((,to)) `())] ,@va*)))]
            [((,from ,conds* ...))
             (let ([ve* (rewrite `(,conds* ...) id)])
               (C `((,from (lambda () (cond ,@ve* (else 'halt)))))))]
            [(,h ,t ,t* ...)
             (rewrite `(,h)
               (lambda (eh*) `(,@eh* ,@(rewrite `(,t ,t* ...) C))))]
            [,exp (C exp)])))
      ;; (let ([st* (rewrite langs id)])
      ;;   `(letrec ,st* (,start)))
      (let ([st* (rewrite langs id)])
        (lambda () (eval `(letrec ,st* (,start)))))
      ))
  )
