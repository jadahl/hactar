; License: GNU GPLv2
; Author: Jonas Ådahl
; (c) Copyright 2007 Jonas Ådahl
;
; Based on katt.lisp from Hactar version 1

(in-package :hactar)

(defclass katt (command)
  ())

(defmethod run-command ((h hactar) (c connection) (cmd katt) (e event))
  (if (string-equal (event-message-body e) "!katt")
    (progn
      (send-message c (response-message
                        e
                        (elt *katt* (random (length *katt*)))))
      t)
    nil))

