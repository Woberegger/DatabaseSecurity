# this is a sample $ORACLE_HOME/network/admin/sqlnet.ora file, configured for Oracle NNE
NAMES.DIRECTORY_PATH= (TNSNAMES, EZCONNECT, HOSTNAME)
DISABLE_OOB=ON
# disable weak crypto methods
SQLNET.ALLOW_WEAK_CRYPTO=FALSE
# server side encryption
SQLNET.ENCRYPTION_SERVER = REQUIRED
SQLNET.ENCRYPTION_TYPES_SERVER = AES256
SQLNET.CRYPTO_CHECKSUM_SERVER = REQUIRED
SQLNET.CRYPTO_CHECKSUM_TYPES_SERVER = SHA512
SQLNET.ALLOW_WEAK_CRYPTO_CLIENTS = FALSE
# client side encryption
SQLNET.ENCRYPTION_CLIENT = REQUIRED
SQLNET.ENCRYPTION_TYPES_CLIENT = AES256
SQLNET.CRYPTO_CHECKSUM_CLIENT = REQUIRED
SQLNET.CRYPTO_CHECKSUM_TYPES_CLIENT = SHA512