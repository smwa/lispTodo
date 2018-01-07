(ql:quickload "hunchentoot")

(defpackage :webserver
  (:use :common-lisp :hunchentoot))

(in-package :webserver)



(defvar *todos* nil)

(defun make-todo (label) (list :label label :isdone nil))

(defun add-todo (label) (if (eq (list-length *todos*) 0) 
(push (make-todo label) *todos*)
(nconc *todos* (list (make-todo label)))
)  )


(add-todo "Step One")

(defun render-todo (todo)
    (concatenate 'string
        (format nil "<li>~a. " (position todo *todos*))
        (format nil "<a href='/?complete=~a'>" (position todo *todos*))
        (if (getf todo :isdone) (format nil "X") (format nil "_"))
        (format nil "</a> ~a</li>" (getf todo :label))
    )
)

(defun render-todos (todos)
    (format nil "New todo: <form method='POST'><input name='todo'><button>Create</button></form><ul>~{~a~}</ul>" (loop for todo in todos collect (render-todo todo)))
)

(defun todo-complete (index)
    (setf (nth index *todos*) (list :label (getf (nth index *todos*) :label) :isdone T) )
)

(defun todo-incomplete (index)
    (setf (nth index *todos*) (list :label (getf (nth index *todos*) :label) :isdone nil) )
)

(defun todo-toggle-complete (index)
    (if (getf (nth index *todos*) :isdone)
        (todo-incomplete index)
        (todo-complete index)
    )
)

(hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 4242))

(add-todo "Step Two")
(todo-complete 1)

(defun route-todos ()
  (if (post-parameter "todo") (add-todo (post-parameter "todo")))
  (if (get-parameter "complete") (todo-toggle-complete (parse-integer (get-parameter "complete"))))
  (render-todos *todos*)
)

(setq *dispatch-table* (list
    (create-prefix-dispatcher "/" 'route-todos)
))
