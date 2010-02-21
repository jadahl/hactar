(in-package :hactar)

(defclass filter (callback)
  ())

(defmethod run-filter (h c (f filter) x)
  "Do something with every event")
