(in-package :hactar)

(defclass filterskel (filter) ())

(defmethod initiate-callback ((h hactar) (c connection) (f filterskel))
  (setf (connection-database c) (acons 'filterskel 0 (connection-database c))))

(defmethod run-filter ((h hactar) (c connection) (f filterskel) (e event))
  (format t "Length of message:~a~%" (length (event-message-body e))))

