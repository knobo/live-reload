(defpackage #:test-live-reload
  (:use #:cl #:fiveam)
  (:export
   #:run-live-reload-test))

(in-package #:test-live-reload)

(def-suite live-reload
    :description "Test Live Reload"
    )

(in-suite live-reload)

(test testsystem
      :description "Test system is running"
      (is (string= "run" "run")))

(defun run-live-reload-test ()
  (run!))
