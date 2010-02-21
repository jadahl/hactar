(in-package :hactar)

(defclass hactar ()
  ((connections :accessor hactar-connections
                :initform nil
                :documentation "Active connections.")
   (callbacks :accessor hactar-callbacks
              :initform (make-hash-table :test #'equal))))
   ;; FIXME remove default-connections, leave that to initating procedure
   ;;(default-connections :accessor hactar-default-connections
   ;;                     :initarg :default-connections
   ;;                     :initform nil)))


(defmethod new-connection ((h hactar) (c connection))
  (setf (connection-event-handler c) 'hactar-handle-event)
  (setf (connection-event-master c) h)
  (pushnew c (hactar-connections h))
  (connect c)
  (format t "Adding:~a~%" 'hactar::read-and-act)
  (event:add-event-callback (connection-stream c) (event:make-flags :ev-persist t) #'hactar::read-and-act c))

(defmethod connect-all ((h hactar) connections)
  (dolist (c connections)
    (new-connection h c)))

(defmethod disconnect-all ((h hactar))
  (dolist (c (hactar-connections h))
    (disconnect c)))

;;(defmethod handle-all-connections ((h hactar))
;;  (dolist (c (hactar-connections h))
;;    (read-and-act c)))

(defmethod continuous-handle-all-connections ((h hactar))
  (event:event-dispatch))

(defmethod add-callback ((h hactar) name callback)
  (setf (gethash name (hactar-callbacks h)) callback))

(defmethod join-channel ((h hactar) channel)
  (dolist (c (hactar-connections h))
    (join-channel c channel)))

;;(defmethod add-callback ((h hactar) (c callback))
;;  (add-callback h (callback-id c) c))

(defmethod del-callback ((h hactar) name)
  (remhash name (hactar-callbacks h)))

(defmethod filter-event ((h hactar) (c connection) (f filter) event)
  (run-filter h c f event))

(defmethod command-event ((h hactar) (c connection) (cmd command) event)
  (run-command h c cmd event))

(defmethod invoke-callback ((h hactar) (c connection) (e event) (f filter))
  (format t "Running filter...")
  (run-filter h c f e))

(defmethod invoke-callback ((h hactar) (c connection) (e event) (cmd command))
  (format t "Running command...")
  (if (run-command h c cmd e) (throw 'stop-callbacks nil)))

(defmethod hactar-handle-event ((h hactar) (c connection) (e event))
  "Handle incoming event"
  (format t "Handeling incoming event:\"~a\"~%" (event-message-body e))
  (catch 'stop-callbacks
    (maphash #'(lambda (cn cb)
                 (invoke-callback h c e cb)) (hactar-callbacks h))))
