# live-reload

live-reload prototype for clack

## Usage

```lisp
  (lack:builder
   :live-reload
   *web*)
```
Install live-reload plugin for your browser, and it *should* work.

### Manually add files to watch for changes


```lisp
;; example:
(live-reload:add #p"/path/templates/djula-template..html" "/url/mypage")
```


## License

LLGPL

