(in-package :hactar)

(defclass foo-command (command)
  ())

(defmethod run-command ((h hactar) (c connection) (cmd command) (e event))
  (if (equal (event-message-body e) "!foo")
    (progn
      (send-message c (response-message e "bar"))
      t)
    nil))

