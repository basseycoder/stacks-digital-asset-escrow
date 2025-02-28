;; -------------------------------------------------------------
;; Digital Asset Escrow Contract
;; Enables secure transactions for gaming assets using Stacks blockchain
;; -------------------------------------------------------------

;; Constants for contract roles and error handling
(define-constant ESCROW_MANAGER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_MISSING_ESCROW (err u101))
(define-constant ERR_ALREADY_PROCESSED (err u102))
(define-constant ERR_TXN_FAILED (err u103))
(define-constant ERR_INVALID_ID (err u104))
(define-constant ERR_INVALID_VALUE (err u105))
(define-constant ERR_INVALID_SELLER (err u106))
(define-constant ERR_ESCROW_TIMEOUT (err u107))
(define-constant ESCROW_EXPIRATION_BLOCKS u1008) ;; ~7 days based on block height

;; Mapping of escrows with their attributes
(define-map EscrowRecords
  { escrow-id: uint }
  {
    buyer: principal,
    seller: principal,
    asset-code: uint,
    deposit: uint,
    escrow-status: (string-ascii 10),
    created-at: uint,
    expires-at: uint
  }
)

;; Tracking the last assigned escrow ID
(define-data-var last-escrow-id uint u0)

;; -------------------------------------------------------------
;; Helper Functions
;; -------------------------------------------------------------

;; Validate if the provided seller is different from the contract caller
(define-private (is-valid-seller (seller principal))
  (and 
    (not (is-eq seller tx-sender))
    (not (is-eq seller (as-contract tx-sender)))
  )
)

;; Validate whether an escrow ID exists
(define-private (is-valid-escrow-id (escrow-id uint))
  (<= escrow-id (var-get last-escrow-id))
)