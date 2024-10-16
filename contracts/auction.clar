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
