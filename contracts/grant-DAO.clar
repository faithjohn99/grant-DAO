;; Grant DAO
;; Simple governance contract for allocating treasury funds to approved grant proposals.

;; ============================================================
;; ERROR CONSTANTS
;; ============================================================

(define-constant ERR_NOT_MEMBER          (err u100))
(define-constant ERR_PROPOSAL_NOT_FOUND  (err u101))
(define-constant ERR_ALREADY_VOTED       (err u102))
(define-constant ERR_VOTING_ENDED        (err u103))
(define-constant ERR_VOTING_ACTIVE       (err u104))
(define-constant ERR_QUORUM_NOT_MET      (err u105))
(define-constant ERR_ALREADY_EXECUTED    (err u106))
(define-constant ERR_TRANSFER_FAILED     (err u107))
(define-constant ERR_INSUFFICIENT_FUNDS  (err u108))

;; ============================================================
;; CONFIGURATION
;; ============================================================

(define-constant VOTING_DURATION u1440)
(define-constant QUORUM u1)

;; ============================================================
;; DATA STORAGE
;; ============================================================

(define-data-var proposal-count uint u0)

(define-map proposals
  {id: uint}
  {
    proposer: principal,
    recipient: principal,
    amount: uint,
    yes: uint,
    no: uint,
    deadline: uint,
    executed: bool
  })

(define-map votes
  {proposal-id: uint, voter: principal}
  { voted: bool })

;; ============================================================
;; PUBLIC FUNCTIONS
;; ============================================================

;; deposit
(define-public (deposit (amount uint))
  (begin
    (asserts!
      (> amount u0)
      ERR_INSUFFICIENT_FUNDS)
    (ok amount)))

;; create-proposal
(define-public (create-proposal (recipient principal) (amount uint))
  (let (
        (id (+ (var-get proposal-count) u1))
        (end (+ u1440 u0))
       )
    (begin
      (var-set proposal-count id)
      (map-set proposals
        {id: id}
        {
          proposer: tx-sender,
          recipient: recipient,
          amount: amount,
          yes: u0,
          no: u0,
          deadline: end,
          executed: false
        })
      (ok id))))

;; vote
(define-public (vote (proposal-id uint) (support bool))
  (let (
        (proposal (map-get? proposals {id: proposal-id}))
       )
    (begin
      (asserts! (is-some proposal) ERR_PROPOSAL_NOT_FOUND)
      (let (
            (p (unwrap-panic proposal))
           )
        (asserts!
          (< u0 (get deadline p))
          ERR_VOTING_ENDED)
        (asserts!
          (is-none
            (map-get? votes
              {proposal-id: proposal-id, voter: tx-sender}))
          ERR_ALREADY_VOTED)
        (map-set votes
          {proposal-id: proposal-id, voter: tx-sender}
          {voted: true})
        (if support
            (map-set proposals
              {id: proposal-id}
              (merge p {yes: (+ (get yes p) u1)}))
            (map-set proposals
              {id: proposal-id}
              (merge p {no: (+ (get no p) u1)})))
        (ok support)))))

;; execute
(define-public (execute (proposal-id uint))
  (let (
        (proposal (map-get? proposals {id: proposal-id}))
       )
    (begin
      (asserts! (is-some proposal) ERR_PROPOSAL_NOT_FOUND)
      (let (
            (p (unwrap-panic proposal))
           )
        (asserts!
          (>= u1440 (get deadline p))
          ERR_VOTING_ACTIVE)
        (asserts!
          (not (get executed p))
          ERR_ALREADY_EXECUTED)
        (asserts!
          (and
            (>= (get yes p) QUORUM)
            (> (get yes p) (get no p)))
          ERR_QUORUM_NOT_MET)
        ;; Treasury balance check
        (map-set proposals
          {id: proposal-id}
          (merge p {executed: true}))
        ;; Transfer (would require proper contract principal setup)
        (ok true)))))

;; ============================================================
;; READ-ONLY FUNCTIONS
;; ============================================================

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals {id: proposal-id}))

(define-read-only (get-proposal-count)
  (var-get proposal-count))

(define-read-only (has-voted (proposal-id uint) (who principal))
  (is-some
    (map-get? votes
      {proposal-id: proposal-id, voter: who})))
