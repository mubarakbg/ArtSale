;; Decentralized Art Auction Smart Contract

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-not-active (err u101))
(define-constant err-bid-too-low (err u102))
(define-constant err-auction-ended (err u103))

;; Define data variables
(define-data-var minimum-bid uint u1000000) ;; 1 STX
(define-data-var auction-duration uint u1440) ;; 24 hours in blocks (assuming 1 block per minute)

;; Define data maps
(define-map auctions
  { auction-id: uint }
  {
    artist: principal,
    nft-asset-contract: principal,
    nft-asset-id: uint,
    start-block: uint,
    end-block: uint,
    reserve-price: uint,
    highest-bid: uint,
    highest-bidder: (optional principal)
  }
)

(define-map bids
  { auction-id: uint, bidder: principal }
  { amount: uint }
)

;; Define NFT trait
(use-trait nft-trait .sip-009-nft-trait.nft-trait)

;; Function to create a new auction
(define-public (create-auction (nft-contract <nft-trait>) (nft-id uint) (reserve-price uint))
  (let
    (
      (auction-id (+ (var-get last-auction-id) u1))
      (start-block block-height)
      (end-block (+ block-height (var-get auction-duration)))
    )
    (try! (contract-call? nft-contract transfer nft-id tx-sender (as-contract tx-sender)))
    (map-set auctions
      { auction-id: auction-id }
      {
        artist: tx-sender,
        nft-asset-contract: (contract-of nft-contract),
        nft-asset-id: nft-id,
        start-block: start-block,
        end-block: end-block,
        reserve-price: reserve-price,
        highest-bid: u0,
        highest-bidder: none
      }
    )
    (var-set last-auction-id auction-id)
    (ok auction-id)
  )
)

;; Function to place a bid
(define-public (place-bid (auction-id uint) (bid-amount uint))
  (let
    (
      (auction (unwrap! (map-get? auctions { auction-id: auction-id }) (err u404)))
      (current-highest-bid (get highest-bid auction))
    )
    (asserts! (< block-height (get end-block auction)) err-auction-ended)
    (asserts! (> bid-amount current-highest-bid) err-bid-too-low)
    (asserts! (>= bid-amount (get reserve-price auction)) err-bid-too-low)

    ;; Return previous highest bid if exists
    (match (get highest-bidder auction)
      prev-bidder (as-contract (try! (stx-transfer? current-highest-bid tx-sender prev-bidder)))
      none true
    )

    ;; Transfer bid amount to contract
    (try! (stx-transfer? bid-amount tx-sender (as-contract tx-sender)))

    ;; Update auction details
    (map-set auctions
      { auction-id: auction-id }
      (merge auction { highest-bid: bid-amount, highest-bidder: (some tx-sender) })
    )

    ;; Record bid
    (map-set bids { auction-id: auction-id, bidder: tx-sender } { amount: bid-amount })

    (ok true)
  )
)

;; Function to end auction
(define-public (end-auction (auction-id uint))
  (let
    (
      (auction (unwrap! (map-get? auctions { auction-id: auction-id }) (err u404)))
    )
    (asserts! (>= block-height (get end-block auction)) err-auction-ended)

    (match (get highest-bidder auction)
      winner
        (begin
          ;; Transfer NFT to winner
          (try! (as-contract (contract-call? .nft-trait transfer
            (get nft-asset-id auction)
            tx-sender
            winner
          )))
          ;; Transfer funds to artist
          (try! (as-contract (stx-transfer? (get highest-bid auction) tx-sender (get artist auction))))
        )
      none
        ;; Return NFT to artist if no bids
        (try! (as-contract (contract-call? .nft-trait transfer
          (get nft-asset-id auction)
          tx-sender
          (get artist auction)
        )))
    )

    (ok true)
  )
)

