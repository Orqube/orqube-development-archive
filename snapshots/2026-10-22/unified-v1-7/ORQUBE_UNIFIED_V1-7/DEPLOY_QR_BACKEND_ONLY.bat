@echo off
firebase deploy --project orqube-576e7 --only "firestore:rules,functions:qrRewardClaim,functions:qrRewardConfirmPaid"
pause
