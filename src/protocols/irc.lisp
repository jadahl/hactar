; License: GNU GPLv2
; Description: Hactar 2
; Author: Jonas Ådahl <tox@dtek.chalmers.se>
; (c) Copyright 2005 Jonas Ådahl

(in-package :hactar)

(defclass irc-channel (channel)
  ((name :accessor irc-channel-name
         :initform nil
         :initarg :name)
   (nick :accessor irc-channel-nick
         :initarg :nick
         :initform nil)
   (participants :accessor irc-channel-participants
                 :initform nil)))

(defmethod channel-name ((c irc-channel))
  (irc-channel-name c))

(defmethod channel-contains-participant ((c irc-channel) nick)
  (if (gethash nick (irc-channel-participants c)) t nil))

(defmethod channel-nick ((c irc-channel))
  (irc-channel-nick c))

(defun make-irc-channel (channel nick)
  "Instantiate a IRC channel"
  (make-instance 'irc-channel
                 :name channel
                 :nick nick))

(defclass irc-event (event)
  ((irc-message :accessor irc-event-message
                :initform nil
                :initarg :irc-message)))

(defmethod event-respond-to ((e irc-event))
  (let ((m (irc-event-message e)))
    (irc:source m)))

(defmethod event-from-nick ((e irc-event))
  (let ((m (irc-event-message e)))
    (irc:user m)))

(defmethod event-respond-type ((e irc-event))
  'groupchat) ;;; verify

(defmethod event-message-body ((e irc-event))
  (let ((m (irc-event-message e)))
    (irc:command m)))

(defclass irc-connection (connection)
  ((nick :accessor irc-nick
         :initarg :nick
         :initform nil)
   (socket :accessor irc-socket
               :initform nil)
   (server :accessor irc-server
           :initarg :server
           :initform nil)
   (port :accessor irc-port
         :initarg :port
         :initform 6667)))

(defmethod add-hooks ((c irc-connection))
  (format t "HOOKING UP IRC-HANDLE-PRIVMSG")
  (irc:add-hook (irc-socket c) 'irc::irc-privmsg-message (lambda (m) (irc-handle-privmsg c m))))

(defmethod connect ((c irc-connection))
  "Connect to an IRC server."
  ;;(my-debug "Connecting to ~a:~a~%" host port)
  (setf (irc-socket c) (irc:connect :nickname (irc-nick c) :server (irc-server c) :port (irc-port c)))
  (add-hooks c))

(defmethod disconnect ((c irc-connection))
  (irc:quit *hactar-quit-message*))

(defmethod connection-stream ((c irc-connection))
  (irc::network-stream (irc-socket c)))

(defmethod send-message ((c irc-connection) (m message))
  "Send message to a target using irc"
  (format t "Sending irc message to ~a: ~a~%" (message-target m) (message-body m))
  (irc:privmsg (irc-socket c) (message-target m) (message-body m)))
  
(defmethod read-and-act ((c irc-connection) &key (block nil))
  (when (or block 
            #+clisp (ext:read-byte-lookahead (irc::network-stream (irc-socket c)))
            #-clisp (listen (irc::network-stream (irc-socket c)))
            )
    (format t "read?~a~%"  (ext:read-byte-lookahead (irc::network-stream (irc-socket c))))
    (irc:read-message (irc-socket c))))

(defmethod join-channel ((c irc-connection) (ch irc-channel))
  (irc:join (irc-socket c) (channel-name ch)))



(defmethod irc-handle-privmsg ((c irc-connection) (m irc:irc-message))
  (call-event-master c (make-instance 'irc-event :irc-message m)))



;; add ctcp version
(in-package :irc)
(setf *ctcp-version* (format nil "Hactar 0.2.0 using ~a" *ctcp-version*))
(in-package :hactar)

