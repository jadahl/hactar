(in-package :cl-user)

(defpackage :hactar
  (:use :cl :cl-user)
  (:export
    :hactar
    :hactar-connections :hactar-default-connections
    :connect-all
    :handle-all-connections
    :continuous-handle-all-connections
    ;; basic stuff
    :room
    :room-name
    :room-contains-participant
    :room-nick
    :event
    :event-respond-to :event-from-nick :event-respond-type :event-message-body
    :message
    :message-target
    :message-body
    ;; basic protocol classes and accessors
    :connection
    :connection-state
    :connection-default-rooms
    :connect
    :disconnect
    :connected
    :read-and-act
    :send-message
    :join-room
    :add-room
    :join-all-rooms
    ;; jabber specific
    :jabber-room
    :make-jabber-room
    :jabber-event
    :jabber-connection))

