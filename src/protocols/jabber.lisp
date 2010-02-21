; License: GNU GPLv2
; Description: Hactar 2
; Author: Jonas Ådahl <tox@dtek.chalmers.se>
; (c) Copyright 2005 Jonas Ådahl

(in-package :hactar)

(defclass jabber-channel (channel jabber:conference)
  ())

(defmethod channel-name ((r jabber-channel))
  (format nil "~a@~a"
          (jabber:conference-name r)
          (jabber:conference-server r)))

(defmethod channel-contains-participant ((r jabber-channel) nick)
  (if (gethash nick (jabber:conference-participants r)) t nil))

(defmethod channel-nick ((r jabber-channel))
  (jabber:conference-nick r))

(defun make-jabber-channel (channel server nick)
  "Instantiate a jabber channel"
  (make-instance 'jabber-channel
                 :name channel
                 :server server
                 :nick nick))

(defclass jabber-event (event)
  ((jabber-message :accessor event-jabber-message
                   :initarg :jabber-message)))

(defmethod event-respond-type ((e jabber-event))
  (let ((m (event-jabber-message e)))
    (if (string-equal (jabber:stanza-type m) "groupchat")
      'groupchat
      'private)))

(defmethod event-respond-to ((e jabber-event))
  (let ((m (event-jabber-message e)))
    (if (eq (event-respond-type e) 'groupchat)
      (jabber:jid-user (jabber:stanza-from m))
      (jabber:stanza-from m))))

(defmethod event-from-nick ((e jabber-event))
  (let ((m (event-jabber-message e)))
    (jabber:jid-resource (stanza-from m))))

(defmethod event-message-body ((e jabber-event))
  (let ((m (event-jabber-message e)))
    (jabber:message-body m)))

(defclass jabber-connection (connection jabber:client jabber:muc)
  ())

(defmethod jabber:authenticated :after ((c jabber-connection))
  (connected c))

(defmethod jabber:joined-conference :after ((c jabber-connection)
                                            (co jabber:conference))
  (format t "Joined ~a.~%" (format nil "~a@~a"
                            (jabber:conference-name co)
                            (jabber:conference-server co)))
  (joined-channel c (format nil "~a@~a"
                            (jabber:conference-name co)
                            (jabber:conference-server co))))

(defmethod connect ((c jabber-connection))
  "Connect to a Jabber server."
  (format t "Connecting to jabber server...")
  (jabber:connect c)
  (setf (connection-state c) 'connected))

(defmethod disconnect ((c jabber-connection))
  "Disconnect from a Jabber server."
  (jabber:connection-close c))

(defmethod connection-stream ((c jabber-connection))
  (jabber:connection-socket c))

(defmethod send-message ((c jabber-connection) (m message))
  "Send event to target using jabber."
  (let ((type (cond
                ((eq (message-type m) 'groupchat) "groupchat")
                (t "chat"))))
    (jabber:send-message c :to (message-target m) :body (message-body m) :type type)))

(defmethod read-and-act ((c jabber-connection) &key (block nil))
  (format t "Reading and acting~%")
  (jabber:read-and-act c :block block))

(defmethod join-channel ((c jabber-connection) (r jabber-channel))
  (when (equal (connection-state c) 'activated)
    (jabber:join-conference c r)))

(defmethod jabber:handle-stanza ((c jabber-connection) (m jabber:message))
  (format t "Received message from ~a: ~a~%" (jabber:jid-resource (jabber:stanza-from m)) (jabber:message-body m))

  ;; when jid resource is empty the message comes directly from the conference room
  ;; should be changed to enable normal non-muc chats
  (when (jabber:jid-resource (jabber:stanza-from m))
    ;; ignore history messages
    (if (not (assoc '("x" . "jabber:x:delay") (jabber:stanza-children m) :test #'equal))
      (let ((from-channel (get-channel c (jabber:jid-user (jabber:stanza-from m)))))
        ;; avoid handeling messages from self
        (when (and from-channel
                   (not (string-equal (jabber:stanza-from m)
                                      (concatenate 'string
                                                   (channel-name from-channel)
                                                   "/"
                                                   (channel-nick from-channel)))))
          (call-event-master c (make-instance 'jabber-event
                                              :jabber-message m
                                              :connection c
                                              ;(remhash n (connection-pending-channels c)))
                                              :channel from-channel)))))))
