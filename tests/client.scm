(import scheme)
(cond-expand
  (chicken-4
   (use test http-client posix awful))
  (chicken-5
   (import (chicken format)
           (chicken io)
           (chicken pathname))
   (import awful http-client test)
   (define close-all-connections! close-idle-connections!))
  (else
   (error "Unsupported CHICKEN version.")))

(define server-uri (sprintf "http://localhost:~a" (server-port)))

(define (get path/vars)
  (let ((val (with-input-from-request
              (make-pathname server-uri path/vars)
              #f
              read-string)))
    (close-all-connections!)
    val))

(test-begin "awful-path-matchers")

(test-begin "<int>")
(test "2" (get "/foo/2"))
(test "6" (get "/foo/2/3"))
(test 'ok (handle-exceptions exn
            'ok
            (get "/foo/2.0")))
(test-end "<int>")

(test-begin "alist-ref")
(test "1" (get "/alist-ref/a"))
(test "2" (get "/alist-ref/b"))
(test "3" (get "/alist-ref/c"))
(test "no match" (get "/alist-ref/d"))
(test-end "alist-ref")

(test-begin "<string>")
(test "foo" (get "/string/foo"))
(test "foo-42" (get "/string-and-int/foo/42"))
(test-end "<string>")

(test-begin "<number>")
(test "43.0" (get "/number/42.0"))
(test-end "<number>")

(test-begin "<regex>")
(test "abc4" (get "/regex/abc4"))
(test 'ok (handle-exceptions exn
            'ok
            (get "/regex/abc4w")))
(test-end "<regex>")

(test-begin "sanitize-matchers")
(test "42" (get "/sane/42"))
(test-end "sanitize-matchers")

(test-begin "combinators")
(test "43.0" (get "/combine-and/42/1.0"))
(test 'ok (handle-exceptions exn
            'ok
            (get "/combine-and/42.0/1")))

(test "foo-42" (get "/combine-or/foo/42"))
(test "bar-42" (get "/combine-or/bar/42"))

(test 'ok (handle-exceptions exn
            'ok
            (get "/combine-or/baz/42")))

(test "42-42" (get "/combine-or-multiple-types/42/42"))
(test "xxx-42" (get "/combine-or-multiple-types/xxx/42"))
(test "foo-42" (get "/combine-or-multiple-types/foo/42"))
(test 'ok (handle-exceptions exn
            'ok
            (get "/combine-or-multiple-types/baz/42")))

(test-end "combinators")

(test-begin "exactly")
(test "specific-42" (get "/exactly/specific/42"))
(test "84" (get "/exactly-42-string/42/42"))
(test "84" (get "/exactly-42/42/42"))
(test "43" (get "/42-or-43/42/1"))
(test "44" (get "/42-or-43/43/1"))
(test 'ok (handle-exceptions exn
            'ok
            (get "/42-or-43/44/1")))
(test-end "exactly")

(test-end "awful-path-matchers")
