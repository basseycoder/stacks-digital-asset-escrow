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

;; -------------------------------------------------------------
;; Public Functions
;; -------------------------------------------------------------

;; Initiate a new escrow for a gaming asset
(define-public (create-escrow (seller principal) (asset-code uint) (deposit uint))
  (let 
    (
      (new-id (+ (var-get last-escrow-id) u1))
      (expiry (+ block-height ESCROW_EXPIRATION_BLOCKS))
    )
    (asserts! (> deposit u0) ERR_INVALID_VALUE)
    (asserts! (is-valid-seller seller) ERR_INVALID_SELLER)
    (match (stx-transfer? deposit tx-sender (as-contract tx-sender))
      success
        (begin
          (var-set last-escrow-id new-id)
          (print {event: "escrow_created", escrow-id: new-id, buyer: tx-sender, seller: seller, asset-code: asset-code, deposit: deposit})
          (ok new-id)
        )
      error ERR_TXN_FAILED
    )
  )
)

;; Complete an escrow and transfer the asset to the buyer
(define-public (finalize-escrow (escrow-id uint))
  (begin
    (asserts! (is-valid-escrow-id escrow-id) ERR_INVALID_ID)
    (let
      (
        (escrow-info (unwrap! (map-get? EscrowRecords { escrow-id: escrow-id }) ERR_MISSING_ESCROW))
        (seller (get seller escrow-info))
        (deposit (get deposit escrow-info))
        (asset (get asset-code escrow-info))
      )
      (asserts! (or (is-eq tx-sender ESCROW_MANAGER) (is-eq tx-sender (get buyer escrow-info))) ERR_UNAUTHORIZED)
      (asserts! (is-eq (get escrow-status escrow-info) "pending") ERR_ALREADY_PROCESSED)
      (asserts! (<= block-height (get expires-at escrow-info)) ERR_ESCROW_TIMEOUT)
      (match (as-contract (stx-transfer? deposit tx-sender seller))
        success
          (begin
            (map-set EscrowRecords
              { escrow-id: escrow-id }
              (merge escrow-info { escrow-status: "completed" })
            )
            (print {event: "escrow_completed", escrow-id: escrow-id, seller: seller, asset-code: asset, deposit: deposit})
            (ok true)
          )
        error ERR_TXN_FAILED
      )
    )
  )
)

;; Refund the buyer in case of failed escrow
(define-public (refund-buyer (escrow-id uint))
  (begin
    (asserts! (is-valid-escrow-id escrow-id) ERR_INVALID_ID)
    (let
      (
        (escrow-info (unwrap! (map-get? EscrowRecords { escrow-id: escrow-id }) ERR_MISSING_ESCROW))
        (buyer (get buyer escrow-info))
        (deposit (get deposit escrow-info))
      )
      (asserts! (is-eq tx-sender ESCROW_MANAGER) ERR_UNAUTHORIZED)
      (asserts! (is-eq (get escrow-status escrow-info) "pending") ERR_ALREADY_PROCESSED)
      (match (as-contract (stx-transfer? deposit tx-sender buyer))
        success
          (begin
            (map-set EscrowRecords
              { escrow-id: escrow-id }
              (merge escrow-info { escrow-status: "refunded" })
            )
            (print {event: "buyer_refunded", escrow-id: escrow-id, buyer: buyer, deposit: deposit})
            (ok true)
          )
        error ERR_TXN_FAILED
      )
    )
  )
)

;; -------------------------------------------------------------
;; Read-Only Functions
;; -------------------------------------------------------------

;; Fetch escrow details
(define-read-only (fetch-escrow (escrow-id uint))
  (begin
    (asserts! (is-valid-escrow-id escrow-id) ERR_INVALID_ID)
    (match (map-get? EscrowRecords { escrow-id: escrow-id })
      escrow-data (ok escrow-data)
      ERR_MISSING_ESCROW
    )
  )
)

;; Retrieve the latest escrow ID created
(define-read-only (latest-escrow-id)
  (ok (var-get last-escrow-id))
)


