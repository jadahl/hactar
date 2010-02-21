(in-package :hactar)

(defclass command (callback)
  ((prefixes :accessor command-prefixes
             :initform '("!" "+")
             :initarg :prefixes
             :documentation "Command prefixes, !weather where ! is the prefix")
   (ignore-whitespace :accessor command-ignore-whitespace
                      :initform t
                      :initarg :ignore-whitespace)))

(defmethod run-command (h c (cmd command) x)
  "Function: do something with every event")


;; helper functions

;; Name: command-prefix-of
;; Returns: prefix length or nil if no match
(defun command-prefix-of (prefix command body)
  (let ((prefix-length (+ (length prefix) (length command))))
    (when (>= (length body) prefix-length)
      (string-equal (concatenate 'string prefix command)
                    body :end2 prefix-length))))

(defun is-of-command (prefixes command body)
  (let ((prefix (car prefixes)))
    (when prefix
      (if (command-prefix-of prefix command body)
        t
        (is-of-command (cdr prefixes) command body)))))

(defmacro cond-command-args (command event &rest clauses)
  (cons
    'cond
    (let ((body `(event-message-body ,event)))
      (mapcar
        (lambda (clause)
          (let* ((cmd-expr (car clause))
                 (cmd-string (first cmd-expr))
                 (args-name (second cmd-expr))
                 (code (cdr clause)))
            `((is-of-command (command-prefixes ,command) ,cmd-string ,body)
              (let ((,args-name (cdr (ppcre:split " " ,body))))
                ,@code))))
        clauses))))

(defmacro cond-command (command event &rest clauses)
  `(cond-command-args ,command ,event
      ,@(mapcar (lambda (clause)
                  `((,(car clause)
                      tmp)
                    (declare (ignore tmp))
                    ,@(cdr clause)))
                clauses)))

