(in-package :hactar)

; split string into words
(defun split-string (str)
  (let ((words nil)
        (w 0)
        (s 0))
    (loop
      (setf w (position-if #'(lambda (chr) (char/= #\Space chr)) str :start s))
      (when (not w) (return))
      (setf s (position #\Space str :start w))
      (pushnew (subseq str w s) words)
      ;;(setf words (append words (list (substring str w s))))
      (when (or (not w) (not s)) (return)))
    words))

(defvar *command-operators* (list "!" "+"))

(defun match-command (str command)
  (format t "length:~a~%" (length str))
  (when (and
          (> (length str) 1)
          (eq 0 (position (subseq str 0 1) *command-operators* :test #'string-equal)))
    (let ((given-command (subseq str 1)))
        (string-equal given-command command))))

