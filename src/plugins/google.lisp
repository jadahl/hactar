(in-package :hactar)

(defclass google-command (command)
  ())

(defmethod run-command ((h hactar) (c connection) (cmd google-command) (ev event))
  (cond-command-args (identity cmd) (identity ev)
                     (("google" args)
                      (format t "eh:~a~%" args)))
  (cond-command-args
    cmd ev
    (("google" args)
     (let ((result (google-search args)))
       (when result
         (send-message c (response-message ev result)))))))

(defun render-query (args)
  (reduce (lambda (x y) (concatenate 'string x "+" y)) args))

(defun google-search (args)
  (let ((query (render-query args)))
    (multiple-value-bind (body code headers uri stream must-close)
      (drakma:http-request
        (format nil "http://www.google.com/search?q=~a&btnI=" query)
        :redirect nil)
      (declare (ignore body))
      (declare (ignore uri))
      (declare (ignore must-close))
      (declare (ignore body))
      (let ((loc (cdr (assoc :location headers))))
        (if loc
          loc
          "No result.")))))
