# $TNS_ADMIN/tnsnames.ora Network Configuration File:
# the other records beside IMS_SSL should have been existing and should be kept, as they were!!!

FREE =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = FREE)
    )
  )

LISTENER_FREE =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))

FREEPDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = FREEPDB1)
    )
  )

EXTPROC_CONNECTION_DATA =
  (DESCRIPTION =
     (ADDRESS_LIST =
       (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC_FOR_FREE))
     )
     (CONNECT_DATA =
       (SID = PLSExtProc)
       (PRESENTATION = RO)
     )
  )

IMS =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = IMS)
    )
  )

# this record was added to support TLS
IMS_SSL =
  (DESCRIPTION =
    (SECURITY=(SSL_SERVER_CERT_DN="CN=db35249253d541.localdomain"))
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCPS)(HOST = localhost)(PORT = 2484))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = IMS)
    )
  )
