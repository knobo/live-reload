# live-reload

live-reload prototype for clack

## Usage

```lisp
  (lack:builder
   :live-reload
   *web*)
```
Install live-reload plugin for your browser, and it *should* work.

## License

## Bugs

I had to update websocket-driver/src/driver.lisp with this code. I
don't know if it is a bug in websocket driver or the live-reload
plugin in chrome.

```lisp
(defun websocket-p (env)
  (let ((headers (getf env :headers)))
    (and (eq (getf env :request-method) :get)
         (search "upgrade"  (gethash "connection" headers "") :test 'equalp)
         (string-equal (gethash "upgrade" headers "") "websocket")
         (eql (let ((version (gethash "sec-websocket-version" headers)))
                (typecase version
                  (string (parse-integer version))
                  (number version))) 13))))

```

LLGPL
