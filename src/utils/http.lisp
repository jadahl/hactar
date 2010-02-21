(in-package :hactar)

(defun http-get-body (uri-string)
  (multiple-value-bind (body status headers uri stream must close)
    (drakma:http-request uri-string)
    (progn
      (close stream)
      body)))
