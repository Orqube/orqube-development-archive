# Run from the ORQUBE_SAFE_HIKING project root after copying the patch files.
firebase deploy --project orqube-576e7 --only "firestore:rules,functions:qrRewardClaim,functions:qrRewardConfirmPaid"
