
(require 'rx)

;; Associate with .ink files.
(add-to-list 'auto-mode-alist '("\\.ink\\'" . ink-mode))

(defvar ink-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?/ ". 124" table)
    (modify-syntax-entry ?* ". 23b" table)
    (modify-syntax-entry ?\n ">" table)
    table)
  "Syntax table used in `ink-mode' buffers.")

(defvar ink-mode-font-lock-keywords nil "first element for `font-lock-defaults'")
(setq ink-mode-font-lock-keywords
      `(
	(,(rx (group "TODO:" (zero-or-more not-newline))) (0 font-lock-comment-face))
	;; Builtins/prepro/marcro
	(,(rx (or "INCLUDE" "CHOICE_COUNT" "TURNS_IN")) (0 font-lock-preprocessor-face)) 
	(,(rx (group "#" (zero-or-more not-newline))) (0 font-lock-variable-name-face))
	;; These are the choice weave headings *,-,+
	(,(rx bol (zero-or-more blank) (one-or-more "*") blank (zero-or-more (or blank "*") blank) )
	 (0 font-lock-constant-face))
	(,(rx bol (zero-or-more blank) (one-or-more "-") blank (zero-or-more (or blank "-") blank) )
	 (0 font-lock-constant-face))
	(,(rx bol (zero-or-more blank) (one-or-more "+") blank (zero-or-more (or blank "+") blank) )
	 (0 font-lock-constant-face))
	;; Knots. Of course a rx can't match the number of == so not perfect, but will do for now.
	(, (rx bol (zero-or-more blank) (one-or-more "==") (zero-or-more "=") (one-or-more blank) (one-or-more letter)
	       (one-or-more (any letter digit "_"))
	       (or (sequence (one-or-more blank) (one-or-more "==") (zero-or-more "="))
	       (sequence (zero-or-more blank) eol)))
	   ( 0 font-lock-keyword-face))
	;; And stitches with only one leading =
	(, (rx bol "=" (one-or-more blank) (one-or-more letter)
	       (one-or-more (any letter digit "_"))(zero-or-more blank) eol)
	   ( 0 font-lock-keyword-face))
	;; Matching [ and ] for marking supressed choice text.
	(,(rx bol (zero-or-more blank) (one-or-more (or "*" "-" "+")) (one-or-more (not (any "]")))
	      (group "[") (zero-or-more (not (any "]" ))) (group "]"))
	 (1 font-lock-string-face) (2 font-lock-string-face))
	;; Matching { and } for logic.
	(,(rx (group "{") (zero-or-more (not (any "}" ))) (group "}"))
	 (1 font-lock-string-face) (2 font-lock-string-face))
	;; Link matching regs. A link os -> followed by knot name or END
	;; First, Special case for -> END link name.
	(,(rx (group "->") (one-or-more blank) (group "END"))
	 (1 font-lock-function-name-face) (2 font-lock-doc-face))
	;; Then general case.
	(,(rx (group "->") ;; Arrow
	      (or (sequence (zero-or-more blank) eol) ;; Either nothing,
		  ;; or a well formed link knot[.stitch]
		  (group (one-or-more blank) (group (one-or-more letter) (zero-or-more (any letter digit "_"))
				      (zero-or-one (sequence "." letter)) (zero-or-more (any letter digit "_"))))))
	 (1 font-lock-function-name-face) (2 font-lock-keyword-face))
	;; Matching glue sybol '<>'
	(,(rx bol (zero-or-more blank) (group "<>"))
	 (1 font-lock-type-face)) ;; BUGGY, check this!
	(,(rx (group "<>") (zero-or-more blank) eol)
	 (1 font-lock-type-face))
	)
      )

(define-derived-mode ink-mode text-mode "Ink"
  "A major mode for editing ink interactive fiction scripts."
  :syntax-table ink-mode-syntax-table
  (setq font-lock-defaults '(ink-mode-font-lock-keywords))
  (font-lock-fontify-buffer)
  )

(provide 'ink-mode)
