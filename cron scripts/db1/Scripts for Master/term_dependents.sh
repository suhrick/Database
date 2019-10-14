echo "[`date +%Y-%m-%d-%H:%M:%S`]"
mysql teladoc_eds<<!
CALL sp_term_dependents();
!
echo "[`date +%Y-%m-%d-%H:%M:%S`]"