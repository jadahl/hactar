(defpackage hactar-system
  (:use :common-lisp :asdf))

(in-package hactar-system)

(defsystem hactar
           :version "0.2.0"
           :licence "GPLv2"
           :depends-on (:jabber-client
                         :jabber-muc
                         :cl-event
			 :cl-ppcre
			 :drakma)
			 ;:cl-irc)
           :components 
           ((:file "packages")
            (:module utils
		     :depends-on ("packages")
                     :components
                     ((:file "debug")
                      (:file "utils")))
            (:module protocols
                     :depends-on ("packages" utils)
                     :components
                     ((:file "base")
		      (:file "jabber" :depends-on ("base"))))
		      ;(:file "irc" :depends-on ("base"))))
            (:module func
                     :depends-on ("packages" utils)
                     :components
                     ((:file "callback")
                      (:file "filter" :depends-on ("callback"))
                      (:file "command" :depends-on ("callback"))))
            (:file "hactar" :depends-on (protocols func))
            (:module plugins
                     :depends-on ("hactar" utils)
                     :components
                     ((:file "google")
                      (:file "katter")
                      (:file "katt" :depends-on ("katter"))))
	    (:file "main" :depends-on ("hactar" plugins))))
