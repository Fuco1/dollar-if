;;; $if.el --- Anaphoric if macro

;; Copyright (C) 2014 Matus Goljer

;; Author: Matus Goljer <matus.goljer@gmail.com>
;; Maintainer: Matus Goljer <matus.goljer@gmail.com>
;; Keywords: lisp
;; Version: 0.0.1
;; Created: 21th March 2014
;; Package-requires: ((dash "2.5.0"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Anaphoric if macro

;;; Code:
(require 'dash)

(defmacro $if (condition true-body &rest false-body)
  "Evaluate TRUE-BODY if CONDITION evals to non-nil, otherwise FALSE-BODY

The result of evaluating CONDITION is available as $0.

All the list subexpressions in CONDITION are available as $1, $2,
..., ordered by the position of the opening paren."
  (declare (indent 2))
  (let* ((if-index 0)
         (if-alist nil)
         (expr ($if--instrument condition))
         (if-alist-sorted (-sort (-on (-flip 'string-lessp) (-compose 'symbol-name 'car)) if-alist))
         (used-symbols (--filter (string-match-p "$[0-9]+" (symbol-name it)) (-flatten (list true-body false-body))))
         (test (make-symbol "test")))
    `(let* ,(-concat (--map (list (car it)
                                  (-map '$if--subst (cdr it)))
                            if-alist-sorted)
                     `((,test ,(-map '$if--subst expr)))
                     (when (member '$0 used-symbols)
                       `(($0 ,test)))
                     (-map
                      (lambda (int-symb)
                        (list int-symb (car (--first (equal (symbol-name (car it)) (symbol-name int-symb)) if-alist-sorted))))
                      (--remove (eq it '$0) used-symbols)))
       (if ,test ,true-body ,@false-body))))

(defun $if--subst (x)
  "Substitute previously computed values."
  (if (and (listp x)
           (assoc (car x) if-alist))
      (car x)
    x))

(defun $if--instrument (form)
  "Mark the sublists."
  (--map
   (if (not (listp it))
       it
     (cl-incf if-index)
     (let ((sym (make-symbol (format "$%d" if-index)))
           (re (if (equal (car it) 'quote) it ($if--instrument it))))
       (push (cons sym re) if-alist)
       (cons sym re)))
   form))

(provide '$if)
;;; $if.el ends here
