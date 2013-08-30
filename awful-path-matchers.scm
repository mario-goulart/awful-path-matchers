(module awful-path-matchers
  (path-match <int> <string> <number> combine-and combine-or)

(import chicken scheme)
(use data-structures)

(define (<int> thing)
  (let ((n (string->number thing)))
    (and n (exact? n) n)))

(define (<number> thing)
  (string->number thing))

(define <string> identity)

(define (combine-and . procs)
  (lambda (thing)
    (let loop ((procs procs)
               (result #f))
      (if (null? procs)
          result
          (let ((res ((car procs) thing)))
            (if res
                (loop (cdr procs) res)
                #f))))))

(define (combine-or . procs)
  (lambda (thing)
    (let loop ((procs procs)
               (result #f))
      (if (null? procs)
          result
          (let ((res ((car procs) thing)))
            (if res
                res
                (loop (cdr procs) #f)))))))

(define (sanitize-matchers matchers)
  (if (null? matchers)
      '()
      ;; Ignore leading / in matchers specification, since
      ;; string-split will remove it
      (if (member (car matchers) '("/" /))
          (cdr matchers)
          matchers)))

(define (path-match . matchers)
  (lambda (path)
    (let ((path-parts (string-split path "/"))
          (matchers (sanitize-matchers matchers)))
      (and (= (length path-parts)
              (length matchers))
           (let loop ((matchers matchers)
                      (path-parts path-parts)
                      (vals '()))
             (if (null? matchers)
                 (reverse vals)
                 (let ((matcher (car matchers))
                       (path-part (car path-parts)))
                   (if (procedure? matcher)
                       (let ((val (matcher path-part)))
                         (if val
                             (loop (cdr matchers)
                                   (cdr path-parts)
                                   (cons val vals))
                             #f))
                       (if (equal? matcher path-part) ;; string
                           (loop (cdr matchers)
                                 (cdr path-parts)
                                 vals)
                           #f)))))))))

) ;; end module
