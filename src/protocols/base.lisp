; License: GNU GPLv2
; Description: Hactar 2
; Author: Jonas Ådahl <tox@dtek.chalmers.se>
; (c) Copyright 2005 Jonas Ådahl

(in-package :hactar)

;; Room class
;; put stuff like data private to channel here some way like hashtable
(defclass channel ()
  ((database :accessor channel-database
             :initform nil)))

(defmethod channel-name ((r channel))
  "Returns the name of the channel"
  "woot")

(defmethod channel-contains-participant ((r channel) nick)
  "Returns t if nick exists in the channel")

(defmethod channel-nick ((r channel))
  "Returns the nick Hactar uses in this channel")

;;;
; event - messages from chat channel or person
(defclass event ()
  ((connection :accessor event-connection
               :initform nil
               :initarg :connection)
   (channel    :accessor event-channel
               :initform nil
               :initarg :channel)))

(defmethod event-respond-to ((e event))
  "Return the target of which the respond should be sent to")

(defmethod event-from-nick ((e event))
  "Return the nick of the identity that the message comes from")

(defmethod event-respond-type ((c event))
  "Return what type the respond message should be: 'private or 'groupchat")

(defmethod event-message-body ((e event))
  "Return the message part of the event")

(defclass dummy-event ()
  ((body :accessor dummy-event-body
         :initarg :body)))

(defmethod event-message-body ((e dummy-event))
  (dummy-event-body e))

(defclass message ()
  ((target :accessor message-target
           :initarg :target)
   (body   :accessor message-body
           :initarg :body)
   (type   :accessor message-type
           :initarg :type
           :initform 'chat)))

(defmethod response-message ((e event) body)
  "Generate a respond message from an event with a given body."
  (make-instance 'message 
                 :target (event-respond-to e)
                 :type (event-respond-type e)
                 :body body))


;;;
; hactar-connection - basic operations for a server connection
;
; Usage:
; (defclass irc-connection (hactar-connection) ...)
;
; Features:
; hook - function hooks, features to the bot
; database - data stored on hard drive, should be loaded on startup
; runtime - runtime data for this connection
;
; Methods:
; (hactar-connect connection :host "hostname" :port portnum)
; (hactar-disconnect connection)
; (hactar-read connection)
; (hactar-send connection hactar-id data)
;;;
(defclass connection ()
  ((state :accessor connection-state
          :initarg :state
          :initform 'unconnected)
   (event-handler :accessor connection-event-handler
                  :initform nil)
   (event-master :accessor connection-event-master
                 :initform nil)
   ;; integer telling how many seconds the client should wait to connect
   ;; after a ping packet is transmitted
   (reconnect-timeout :accessor connection-reconnect-timeout
                      :initarg :reconnect-timeout
                      :initform 0)
   ;; channels who are being connected to
   (pending-channels :accessor connection-pending-channels
                     :initform (make-hash-table :test #'equal))
   ;; established channels
   (channels :accessor connection-channels
             :initform (make-hash-table :test #'equal))
   ;; list of filter and function callbacks
   (callbacks :accessor connection-callbacks
              :initarg :hooks
              :initform nil)
   ;; reference to what database to use
   (database :accessor connection-database
             :initarg :database
             :initform nil)
;;   (socket :accessor connection-socket
;;           :initform nil)
   (runtime :accessor connection-runtime
            :initarg :runtime
            :initform nil)))

;;;
; Methods of hactar-connection
(defmethod connect :before ((c connection))
  (setf (connection-state c) 'connecting)
  (my-debug "Protocol: connecting..."))

(defmethod disconnect :before ((c connection))
  (setf (connection-state c) 'disconnected)
  (my-debug "Protocol: disconnecting~%"))

(defmethod connected ((c connection))
  (format t "Connected... joining all channels.~%")
  ; FIXME notify session handler
  (setf (connection-state c) 'activated)
  (maphash #'(lambda (cn ch) (join-channel c ch))
           (connection-pending-channels c)))
  ;;(join-all-channels c))

(defmethod connection-stream ((c connection))
  "Return stream object"
  (error "There is no stream object in an abstract connection"))

(defmethod read-and-act ((c connection) &key (block nil))
  "Read and act.")

(defmethod send-message ((c connection) (m message)))

(defmethod delete-channel ((c connection) n)
  (remhash n (connection-pending-channels c)))

(defmethod get-channel-f ((c connection) channel-name f)
  (format t "calling ~a with ~a~%" f c)
  (let ((channels (funcall f c)))
    (gethash channel-name channels)))

(defmethod get-pending-channel ((c connection) channel-name)
  (get-channel-f c channel-name 'connection-pending-channels))

(defmethod get-channel ((c connection) channel-name)
  (get-channel-f c channel-name 'connection-channels))

(defmethod join-channel :before ((c connection) (r channel))
  "Join a channel"
  (let ((n (channel-name r)))
    (setf (gethash n (connection-pending-channels c)) r)))

(defmethod joined-channel ((c connection) channel-name)
  (let ((ch (gethash channel-name (connection-pending-channels c))))
    (remhash channel-name (connection-pending-channels c))
    (setf (gethash channel-name (connection-channels c)) ch)
    ))
    ;; when to initiate channel wise?
    ;;(when ch (initiate-all-callbacks c ch)))) 

(defmethod initiate-all-callbacks ((c connection) (r channel))
  (maphash #'(lambda (ck cb) (initiate-callback (cdr cb) r))
           (connection-callbacks c)))

(defmethod add-channel ((c connection) (r channel))
  (pushnew r (connection-channels c)))

(defmethod join-all-channels ((c connection) channels)
  (dolist (r channels)
    (join-channel c r)))

(defmethod call-event-master ((c connection) (e event))
  (let ((handler (connection-event-handler c))
        (master (connection-event-master c)))
    (if (and handler master)
      (funcall (connection-event-handler c) (connection-event-master c) c e)
      (format t "WARNING: Connection has no master, all events will be discarded."))))
