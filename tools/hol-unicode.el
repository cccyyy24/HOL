(global-set-key (kbd "C-!") "∀")
(global-set-key (kbd "C-?") "∃")
(global-set-key (kbd "C-&") "∧")
(global-set-key (kbd "C-|") "∨")
(global-set-key (kbd "C-S-u") "∪")
(global-set-key (kbd "C-S-i") "∩")
(global-set-key (kbd "C-:") "∈")
(global-set-key (kbd "C-~") (lambda () (interactive) (insert "¬")))
(global-set-key (kbd "C-S-c") "⊆")

;; Greek : C-S-<char> for lower case version of Greek <char>
;;         add the Meta modifier for upper case Greek letter.
(define-prefix-command 'hol-unicode-p-map)
(define-prefix-command 'hol-unicode-P-map)
(define-key global-map (kbd "C-S-p") 'hol-unicode-p-map)
(define-key global-map (kbd "C-M-S-p") 'hol-unicode-P-map)

(global-set-key (kbd "C-S-a") "α")
(global-set-key (kbd "C-S-b") "β")
(global-set-key (kbd "C-S-g") "γ")
(global-set-key (kbd "C-S-d") "δ")
(global-set-key (kbd "C-S-l") "λ")
(global-set-key (kbd "C-S-m") "μ")
(define-key hol-unicode-p-map "i" "π")
(global-set-key (kbd "C-S-r") "ρ")
(global-set-key (kbd "C-S-s") "σ")
(global-set-key (kbd "C-S-t") "τ")
(define-key hol-unicode-p-map "h" "φ")
(define-key hol-unicode-p-map "s" "ψ")

(global-set-key (kbd "C-S-M-g") "Γ")
(global-set-key (kbd "C-S-M-d") "Δ")
(global-set-key (kbd "C-S-M-l") "Λ")
(define-key hol-unicode-P-map "i" "Π")
(define-key hol-unicode-P-map "h" "Φ")
(define-key hol-unicode-P-map "s" "Ψ")

;; ₀ ₁ ₂ ₃ ₄ ₅ ₆ ₇ ₈ ₉ ₊ ₋ ₌