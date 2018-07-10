(in-package :cl-user)

(defpackage lack.middleware.live.reload
  (:use :cl)
  (:export :*lack-middleware-live-reload*))

(in-package :lack.middleware.live.reload)

(defparameter *lack-middleware-live-reload*
  (lambda (app) ;; &key port ...
    (lambda (env)
      (live-reload-ws:ensure-running)
      (destructuring-bind (&whole w code headers result) (funcall app env)
        (declare (ignore code headers))
         (typecase result
           (pathname (live-reload:add result (getf env :path-info))
                     w)
           (t w)))))
  "Middleware for live-reload")
