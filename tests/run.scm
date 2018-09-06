(import scheme)
(cond-expand
  (chicken-4
   (use server-test test awful spiffy posix))
  (chicken-5
   (import (chicken process-context))
   (import awful server-test spiffy test))
  (else
   (error "Unsupported CHICKEN version")))

(test-server-port
 (cond ((get-environment-variable "SPIFFY_TEST_PORT")
        => (lambda (port)
             (string->number port)))
       (else (server-port))))

(server-port (test-server-port))

(with-test-server
 (lambda ()
   (awful-start
    (lambda ()
      (load-apps (list "server.scm")))))
  (lambda ()
    (load "client.scm")))

(test-exit)
