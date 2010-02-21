(in-package :hactar)

(defclass callback ()
  ((id  :accessor callback-id
        :initarg :id
        :initform nil)
   (acl :accessor callback-acl
           :initarg :acl
           :initform '((allow . all)))))


(defmethod initiate-callback (h c (cb callback))
  "Called once for every channel")

