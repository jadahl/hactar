(require 'asdf)
(asdf:operate 'asdf:load-op :hactar)
(in-package :hactar)

(defun test-irc ()
  (let ((default-channels
          (list
            (make-irc-channel "#test" "Hactar_beta_"))))
    (setf h (make-instance
              'hactar
              :default-connections (list
                                     (make-instance
                                       'irc-connection
                                       :nick "Hactar_beta"
                                       :server "kietsu.olf.sgsnet.se"
                                       :port 5899
                                       :default-channels default-channels))))
    (connect-all c)))
                                                         

(defun test-jabber ()
  (setf h (make-instance
            'hactar))
  (connect-all h (list
                   (make-instance
                     'jabber-connection
                     :username "test"
                     :password "test"
                     :server "lap"
                     :router-host "lap"
                     :router-port 5222))))

(defun test-talks ()
    (setf h (make-instance
                          'hactar))
      (connect-all h (list
                       (make-instance
                         'jabber-connection
                         :username "hactar"
                         :password "paranoid"
                         :server "jabber.se"
                         :router-host "jabber.se"
                         :router-port 5222)))
      (join-channel
        (car (hactar-connections h))
        (make-jabber-channel "talks" "conference.jabber.se" "Hactar(beta)")))


(defun test-talks ()
  (setf h (make-instance
            'hactar))
  (connect-all h (list
                   (make-instance
                     'jabber-connection
                     :username "hactar"
                     :password "paranoid"
                     :server "jabber.se"
                     :router-host "jabber.se"
                     :router-port 5222)))
  (join-channel
    (car (hactar-connections h))
    (make-jabber-channel "test" "conference.jabber.se" "Hactar(beta)")))
  ;(continuous-handle-all-connections h))

(defun join-jabber ()
  (join-channel
    (car (hactar-connections h))
    (make-jabber-channel "test" "conference.lap" "Hactar_beta_")))
