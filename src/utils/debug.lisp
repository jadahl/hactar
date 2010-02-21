; License: GNU GPLv2
; Description: Hactar 2
; Author: Jonas Ådahl <tox@dtek.chalmers.se>
; (c) Copyright 2005 Jonas Ådahl

(in-package :hactar)

(defvar debug-output t)

(defun my-debug (&rest args)
  (when debug-output
    (apply 'format t args)))

