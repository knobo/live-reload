;;;; live-reload.asd

(asdf:defsystem #:live-reload
  :description "Describe live-reload here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on ("sb-concurrency"
               "alexandria"
               "inotify"
               "websocket-driver"
               "clack"
               "ningle"
               "log4cl")
  :components ((:file "package")
               (:file "live-reload")
               (:file "live-reload-ws")
               (:file "live-reload-middleware")))
