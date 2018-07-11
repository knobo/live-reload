;;;; live-reload.lisp

(in-package #:live-reload)

(defvar *file-adder-mailbox* (make-mailbox :name "Add files"))
(defvar *files* (make-hash-table :test 'equal))

(defvar *live-reload-clients* (make-hash-table :test 'eql))

(defun stop ()
  (send-message *file-adder-mailbox* "stop"))

;; (run-thread)

(defun add (path url)
  (send-message live-reload::*file-adder-mailbox* (list path url inotify:in-close-write)))

(defun add-file-to-listener (inot message)
  (destructuring-bind (file url mask) message
    (pushnew url (gethash file *files*) :test 'equal)
    (inotify:add-watch inot file mask)))

(defun send-update-url (url)
  (dolist (client (alexandria:hash-table-keys *live-reload-clients*))
    (wsd:send client (format nil "{\"command\":\"reload\",\"path\":\"~a\",\"liveCSS\":\"true\"}" url))))

(defun event-listener (inot)
  (declare (optimize (debug 3)))
  (loop for events = (inotify:read-events inot :time-out 0.2)
     do
       (dolist (event events)
         (let* ((pathname (inotify:event-full-name event))
                (urls (gethash pathname *files*)))
           (dolist (url urls)
             (send-update-url url))
           (log:info "Notify update:" urls)))))

(defmacro mlcar ((el list) &body body)
  "Map lambda char. Syntactic sugar for mapcar."
  `(mapcar (lambda (,el) ,@body) ,list))

(defun run-thread ()
  (bt:make-thread
   (lambda ()
     (let ((files (mlcar (file (alexandria:hash-table-keys *files*))
                    (list file inotify:in-close-write))))
       (inotify:with-inotify (inot files)

         (let ((thread (bt:make-thread
                        (lambda () (event-listener inot))
                        :name "Live Reload Read event")))

           (loop for message = (receive-message *file-adder-mailbox*)
              while (listp message)
              do (add-file-to-listener inot message))

           (when (bt:thread-alive-p thread)
             (bt:destroy-thread thread))))))

   :name "Live Reload Watcher"))
