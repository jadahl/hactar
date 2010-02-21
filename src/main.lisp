(in-package :hactar)

(defvar *hactar-instance* nil)

(defvar *callbacks* nil)

(setf *callbacks*
      '(google-command
        katt))


(defun run ()
  (when (not *hactar-instance*)
    (setf *hactar-instance* (make-instance 'hactar))
    (connect-all *hactar-instance*
                 (list
                   (make-instance
                     'jabber-connection
                     :username "hactar"
                     :password "paranoid"
                     :server "jabber.se"
                     :router-host "jabber.se"
                     :router-port 5222)))
    
    (format t "Adding callbacks...~%")
    (dolist (callback *callbacks*)
      (add-callback *hactar-instance* callback (make-instance callback)))

    (format t "Joining channels...~%")
    (join-channel
      (car (hactar-connections *hactar-instance*))
      (make-jabber-channel "talks" "conference.jabber.se" "Hactar(beta)")))
  (event:event-dispatch))
