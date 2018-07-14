(in-package :cl-user)

(defpackage #:live-reload-ws
  (:use #:cl #:wsd #:ningle)
  (:export
   #:start-live-reload
   #:stop-live-reload
   #:ensure-running
   #:*live-reload*
   #:start-live-reload-ws))

(in-package #:live-reload-ws)

(defvar *live-reload-server* nil)
(defvar *live-reload-port* 35729)
(defvar *live-reload-address* "0.0.0.0")

(defparameter *live-reload-web* (make-instance 'ningle:<app>))

(defparameter *live-reload*
  (lack:builder
   :accesslog
   *live-reload-web*))

(defparameter *live-reload-hello-string* "{\"command\":\"hello\",\"protocols\":[\"http://livereload.com/protocols/official-7\",\"http://livereload.com/protocols/2.x-origin-version-negotiation\",\"http://livereload.com/protocols/2.x-remote-control\"],\"serverName\":\"LiveReload 2\"}")

(defun start-live-reload-ws (env)
  (if (wsd:websocket-p env)
      (let ((ws (wsd:make-server env)))

        (wsd:on :open ws
                (lambda ()
                  (setf (gethash ws live-reload:*live-reload-clients*) t)))

        (wsd:on :close ws
                (lambda (&rest args)
                  (declare (ignore args))
                  (remhash ws live-reload:*live-reload-clients*)))

        (wsd:on :message ws
                (lambda (message)
                  ;;(log:info "Message" message)
                  ))

        (wsd:once  :message ws
                   (lambda (message)
                     "Maybe move this to connect.."
                     (declare (ignore message))
                     (wsd:send ws *live-reload-hello-string*)))

        (wsd:start-connection ws))
      (progn  (error "not websocket"))))

(setf (ningle:route *live-reload-web* "/livereload")
      (lambda (params)
        (declare (ignore params))
        (let ((env (lack.request:request-env *request*)))
          (start-live-reload-ws env))))

(setf (ningle:route *live-reload-web* "/livereload.js")
      (lambda (params)
        (declare (ignore params))
        (merge-pathnames "static/js/livereload.js"  (asdf:system-source-directory :live-reload))))

(setf (ningle:route *live-reload-web* "/")
      (lambda (params)
        (declare  (ignore params))
        nil))

(defun ensure-running (&key
                         (port *live-reload-port*)
                         (address *live-reload-address*))
  (unless *live-reload-server*
    (log:info "Starting live-reload server")
    (start-live-reload)))

(defun start-live-reload (&key
                            (port *live-reload-port*)
                            (address *live-reload-address*))
  (setf *live-reload-server*
	(clack:clackup *live-reload*
		       :address address
		       :server :hunchentoot
		       :port port
		       :worker-num 2
		       :debug t))
  (live-reload:run-thread))

;; (start-live-reload)
(defun stop-live-reload ()
  (clack:stop *live-reload-server*)
  (live-reload:stop)
  (setf *live-reload-server* nil))
