(module awful-path-matchers
  (path-match <int> <string> <number> <regex> combine-and combine-or exactly)

(import chicken scheme)
(use data-structures irregex)

(define (<int> thing)
  (let ((n (string->number thing)))
    (and n (exact? n) n)))

(define (<number> thing)
  (string->number thing))

(define <string> identity)

(define (<regex> regex)
  (lambda (thing)
    (irregex-match regex thing)))

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

(define (combine-or . objs)
  (lambda (thing)
    (let loop ((objs objs))
      (if (null? objs)
          #f
          (let ((obj (car objs)))
            (cond ((procedure? obj)
                   (let ((res (obj thing)))
                     (if res
                         res
                         (loop (cdr objs)))))
                  ((number? obj)
                   (let ((n (string->number thing)))
                     (or (and n (= n obj) n)
                         (loop (cdr objs)))))
                  (else
                   (or (and (equal? obj thing) obj)
                       (loop (cdr objs))))))))))

(define (exactly this #!key test (convert identity))
  (lambda (thing)
    (cond ((number? this)
           (let ((test (or test =))
                 (nthing (string->number thing)))
             (and nthing (test this nthing) (convert nthing))))
          (else
           (let ((test (or test equal?)))
             (and (test thing this) (convert thing)))))))

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
