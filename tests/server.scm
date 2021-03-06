(import scheme)
(cond-expand
  (chicken-4
   (use irregex)
   (use awful awful-path-matchers))
  (chicken-5
   (import (chicken base)
           (chicken irregex)
           (chicken string))
   (import awful awful-path-matchers))
  (else
   (error "Unsupported CHICKEN version.")))

(page-template (lambda (content . args) content))

(enable-sxml #t)

;;; <int>
(define-page (path-match "foo" <int>)
  (lambda (n)
    n))

(define-page (path-match "foo" <int> <int>)
  (lambda (a b)
    (* a b)))

;;; alist-ref
(define-page (path-match "alist-ref" string->symbol)
  (lambda (key)
    (or (alist-ref key '((a . 1)
                         (b . 2)
                         (c . 3)))
        "no match")))

;;; <string>
(define-page (path-match "string" <string>)
  (lambda (s)
    s))

(define-page (path-match "string-and-int" <string> <int>)
  (lambda (s n)
    (conc s "-" n)))

;;; <number>
(define-page (path-match "number" <number>)
  (lambda (n)
    (+ 1 n)))

;;; <regex>
(define-page (path-match "regex" (<regex> "abc[0-9]"))
  (lambda (m)
    (irregex-match-substring m 0)))

;;; sanitize-matchers
(define-page (path-match "/" "sane" <int>)
  (lambda (n)
    n))

;;; Combinators
(define-page (path-match "combine-and" (combine-and <number> <int>) <number>)
  (lambda (n1 n2)
    (+ n1 n2)))

(define (<foo> thing)
  (and (equal? thing "foo") "foo"))

(define (<bar> thing)
  (and (equal? thing "bar") "bar"))

(define-page (path-match "combine-or" (combine-or <foo> <bar>) <number>)
  (lambda (fb n)
    (conc fb "-" n)))

(define-page (path-match "combine-or-multiple-types" (combine-or 42 "xxx" <foo>) <number>)
  (lambda (x n)
    (conc x "-" n)))

;;; exactly
(define-page (path-match "exactly" (exactly "specific") <number>)
  (lambda (specific n)
    (conc specific "-" n)))

(define-page (path-match "exactly-42-string" (exactly "42" convert: string->number) <number>)
  (lambda (forty-two n)
    (+ forty-two n)))

(define-page (path-match "exactly-42" (exactly 42) <number>)
  (lambda (forty-two n)
    (+ forty-two n)))

(define-page (path-match "42-or-43" (combine-or (exactly 42) (exactly 43)) <number>)
  (lambda (n1 n2)
    (+ n1 n2)))
