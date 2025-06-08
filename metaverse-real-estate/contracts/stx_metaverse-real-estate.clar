;; Virtual World Land Ownership System
;; A smart contract for managing land parcels in a virtual world

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_LAND_NOT_EXISTS (err u101))
(define-constant ERR_LAND_ALREADY_OWNED (err u102))
(define-constant ERR_NOT_LAND_OWNER (err u103))
(define-constant ERR_INVALID_COORDINATES (err u104))
(define-constant ERR_INSUFFICIENT_PAYMENT (err u105))
(define-constant ERR_LAND_NOT_FOR_SALE (err u106))

;; Data Variables
(define-data-var world-size-x uint u1000)
(define-data-var world-size-y uint u1000)
(define-data-var base-land-price uint u1000000) ;; Base price in microSTX

;; Land Structure
(define-map lands
  { x: uint, y: uint }
  {
    owner: principal,
    name: (string-ascii 50),
    description: (string-ascii 200),
    price: uint,
    for-sale: bool,
    last-updated: uint
  }
)

;; Owner's land count
(define-map owner-land-count principal uint)

;; Land transaction history
(define-map land-history
  { x: uint, y: uint, block-height: uint }
  {
    from: (optional principal),
    to: principal,
    price: uint,
    transaction-type: (string-ascii 20)
  }
)

;; Public Functions

;; Initialize/claim a new land parcel
(define-public (claim-land (x uint) (y uint) (name (string-ascii 50)) (description (string-ascii 200)))
  (let (
    (land-key { x: x, y: y })
  )
    (asserts! (is-valid-coordinates x y) ERR_INVALID_COORDINATES)
    (asserts! (is-none (map-get? lands land-key)) ERR_LAND_ALREADY_OWNED)
    
    ;; Create the land parcel
    (map-set lands land-key {
      owner: tx-sender,
      name: name,
      description: description,
      price: u0,
      for-sale: false,
      last-updated: stacks-block-height
    })
    
    ;; Update owner land count
    (update-owner-land-count tx-sender u1)
    
    ;; Record transaction history
    (map-set land-history 
      { x: x, y: y, block-height: stacks-block-height }
      {
        from: none,
        to: tx-sender,
        price: u0,
        transaction-type: "claim"
      }
    )
    
    (ok land-key)
  )
)

;; Update land information (only by owner)
(define-public (update-land (x uint) (y uint) (name (string-ascii 50)) (description (string-ascii 200)))
  (let (
    (land-key { x: x, y: y })
    (land-data (unwrap! (map-get? lands land-key) ERR_LAND_NOT_EXISTS))
  )
    (asserts! (is-eq tx-sender (get owner land-data)) ERR_NOT_LAND_OWNER)
    
    (map-set lands land-key (merge land-data {
      name: name,
      description: description,
      last-updated: stacks-block-height
    }))
    
    (ok true)
  )
)

;; Set land for sale
(define-public (set-land-for-sale (x uint) (y uint) (price uint))
  (let (
    (land-key { x: x, y: y })
    (land-data (unwrap! (map-get? lands land-key) ERR_LAND_NOT_EXISTS))
  )
    (asserts! (is-eq tx-sender (get owner land-data)) ERR_NOT_LAND_OWNER)
    (asserts! (> price u0) ERR_INSUFFICIENT_PAYMENT)
    
    (map-set lands land-key (merge land-data {
      price: price,
      for-sale: true,
      last-updated: stacks-block-height
    }))
    
    (ok true)
  )
)

;; Remove land from sale
(define-public (remove-land-from-sale (x uint) (y uint))
  (let (
    (land-key { x: x, y: y })
    (land-data (unwrap! (map-get? lands land-key) ERR_LAND_NOT_EXISTS))
  )
    (asserts! (is-eq tx-sender (get owner land-data)) ERR_NOT_LAND_OWNER)
    
    (map-set lands land-key (merge land-data {
      price: u0,
      for-sale: false,
      last-updated: stacks-block-height
    }))
    
    (ok true)
  )
)

;; Buy land from another player
(define-public (buy-land (x uint) (y uint))
  (let (
    (land-key { x: x, y: y })
    (land-data (unwrap! (map-get? lands land-key) ERR_LAND_NOT_EXISTS))
    (current-owner (get owner land-data))
    (sale-price (get price land-data))
  )
    (asserts! (get for-sale land-data) ERR_LAND_NOT_FOR_SALE)
    (asserts! (not (is-eq tx-sender current-owner)) ERR_NOT_AUTHORIZED)
    
    ;; Transfer STX from buyer to seller
    (try! (stx-transfer? sale-price tx-sender current-owner))
    
    ;; Update land ownership
    (map-set lands land-key (merge land-data {
      owner: tx-sender,
      price: u0,
      for-sale: false,
      last-updated: stacks-block-height
    }))
    
    ;; Update land counts
    (decrease-owner-land-count current-owner)
    (update-owner-land-count tx-sender u1)
    
    ;; Record transaction history
    (map-set land-history 
      { x: x, y: y, block-height: stacks-block-height }
      {
        from: (some current-owner),
        to: tx-sender,
        price: sale-price,
        transaction-type: "purchase"
      }
    )
    
    (ok true)
  )
)

;; Transfer land to another user (gift)
(define-public (transfer-land (x uint) (y uint) (new-owner principal))
  (let (
    (land-key { x: x, y: y })
    (land-data (unwrap! (map-get? lands land-key) ERR_LAND_NOT_EXISTS))
    (current-owner (get owner land-data))
  )
    (asserts! (is-eq tx-sender current-owner) ERR_NOT_LAND_OWNER)
    (asserts! (not (is-eq tx-sender new-owner)) ERR_NOT_AUTHORIZED)
    
    ;; Update land ownership
    (map-set lands land-key (merge land-data {
      owner: new-owner,
      price: u0,
      for-sale: false,
      last-updated: block-height
    }))
    
    ;; Update land counts
    (decrease-owner-land-count current-owner)
    (update-owner-land-count new-owner u1)
    
    ;; Record transaction history
    (map-set land-history 
      { x: x, y: y, block-height: block-height }
      {
        from: (some current-owner),
        to: new-owner,
        price: u0,
        transaction-type: "transfer"
      }
    )
    
    (ok true)
  )
)

;; Read-only functions

;; Get land information
(define-read-only (get-land-info (x uint) (y uint))
  (map-get? lands { x: x, y: y })
)

;; Check if coordinates are valid
(define-read-only (is-valid-coordinates (x uint) (y uint))
  (and 
    (< x (var-get world-size-x))
    (< y (var-get world-size-y))
  )
)

;; Get owner's land count
(define-read-only (get-owner-land-count (owner principal))
  (default-to u0 (map-get? owner-land-count owner))
)

;; Check if land is owned
(define-read-only (is-land-owned (x uint) (y uint))
  (is-some (map-get? lands { x: x, y: y }))
)

;; Get land owner
(define-read-only (get-land-owner (x uint) (y uint))
  (match (map-get? lands { x: x, y: y })
    land-data (some (get owner land-data))
    none
  )
)

;; Check if land is for sale
(define-read-only (is-land-for-sale (x uint) (y uint))
  (match (map-get? lands { x: x, y: y })
    land-data (get for-sale land-data)
    false
  )
)

;; Get land price
(define-read-only (get-land-price (x uint) (y uint))
  (match (map-get? lands { x: x, y: y })
    land-data (get price land-data)
    u0
  )
)

;; Get world dimensions
(define-read-only (get-world-size)
  {
    x: (var-get world-size-x),
    y: (var-get world-size-y)
  }
)

;; Get transaction history for a land parcel
(define-read-only (get-land-transaction (x uint) (y uint) (block uint))
  (map-get? land-history { x: x, y: y, block-height: block })
)

;; Private functions

;; Update owner land count
(define-private (update-owner-land-count (owner principal) (change uint))
  (let (
    (current-count (get-owner-land-count owner))
    (new-count (+ current-count change))
  )
    (map-set owner-land-count owner new-count)
  )
)

;; Decrease owner land count
(define-private (decrease-owner-land-count (owner principal))
  (let (
    (current-count (get-owner-land-count owner))
    (new-count (if (> current-count u0) (- current-count u1) u0))
  )
    (map-set owner-land-count owner new-count)
  )
)

;; Admin functions (only contract owner)

;; Set world size (only contract owner)
(define-public (set-world-size (new-x uint) (new-y uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (var-set world-size-x new-x)
    (var-set world-size-y new-y)
    (ok true)
  )
)

;; Set base land price (only contract owner)
(define-public (set-base-land-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (var-set base-land-price new-price)
    (ok true)
  )
)